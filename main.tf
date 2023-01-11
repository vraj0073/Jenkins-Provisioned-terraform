

resource "aws_instance" "jenkins" {
  ami             = "ami-09d3b3274b6c5d4aa"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.web-traffic.name]
  key_name        = "jenkins"
provisioner "remote-exec"  {
inline  = [ 
    "sudo amazon-linux-extras install docker -y",
    "sudo service docker start",
    "sudo usermod -a -G docker ec2-user",
    "sudo chkconfig docker on",
    "sudo chmod 666 /var/run/docker.sock",
    "sudo yum install -y git",
    "docker run -d -p 8080:8080 -p 50000:50000 -v /var/run/docker.sock:/var/run/docker.sock -v $(which docker):/usr/bin/docker -v jenkins_home:/var/jenkins_home --restart=on-failure jenkins/jenkins"
      ]
   }
   connection {
    type         = "ssh"
    host         = self.public_ip
    user         = "ec2-user"
    private_key  = "${file("~/OneDrive/Desktop/jenkins/jenkins.pem")}" 
   }

  tags  = {
    "Name"      = "Jenkins-terraform"
      }
 

}

resource "aws_security_group" "web-traffic" {
  name        = "Allow web traffic"
  description = "inbound ports for ssh and standard http and everything outbound"
  dynamic "ingress" {
    for_each = var.ingressrules
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Terraform" = "true"
  }
}
 
 