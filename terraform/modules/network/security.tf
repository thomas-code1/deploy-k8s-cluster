# CREATION OF K8S SECURITY GROUPS


# Controlplane Security Group
resource "aws_security_group" "controlplane_sg" {
  name        = "K8S Controlplane SG"
  description = "K8S Controlplane Security Group"
  vpc_id      = aws_vpc.cluster_vpc.id

  tags = {
    Name = "K8S Controlplane SG"
  }
}

# Worker Security Group
resource "aws_security_group" "worker_sg" {
  name        = "K8S Worker SG"
  description = "K8S Worker Security Group"
  vpc_id      = aws_vpc.cluster_vpc.id

  tags = {
    Name = "K8S Worker SG"
  }
}


# DECLARATION OF SECURITY RULES

locals {
  sg = {
    "controlplane" = aws_security_group.controlplane_sg.id
    "worker"       = aws_security_group.worker_sg.id
  }
}

# SSH Port Rule

resource "aws_security_group_rule" "ssh" {
  for_each          = local.sg
  security_group_id = each.value

  description = "SSH"
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

# Outbound Traffic Port Rule

resource "aws_security_group_rule" "all_outbound" {
  for_each          = local.sg
  security_group_id = each.value

  description = "All outbound"
  type        = "egress"

  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}


# Controlplane port rules

resource "aws_security_group_rule" "k8s_controlplane_rules" {

  for_each                 = local.controlplane_port_rules
  security_group_id        = aws_security_group.controlplane_sg.id
  source_security_group_id = aws_security_group.worker_sg.id

  description = each.value.description
  type        = "ingress"
  from_port   = each.value.from_port
  to_port     = each.value.to_port
  protocol    = "tcp"
}


# Worker port rules

resource "aws_security_group_rule" "k8s_worker_rules" {

  for_each                 = local.worker_port_rules
  security_group_id        = aws_security_group.worker_sg.id
  source_security_group_id = aws_security_group.controlplane_sg.id

  description = each.value.description
  type        = "ingress"
  from_port   = each.value.from_port
  to_port     = each.value.to_port
  protocol    = "tcp"
}
