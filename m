Date: Wed, 30 Apr 2003 02:59:15 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.68-mm3
Message-Id: <20030430025915.1692ffdd.akpm@digeo.com>
In-Reply-To: <1051696273.591.4.camel@teapot.felipe-alfaro.com>
References: <20030429235959.3064d579.akpm@digeo.com>
	<1051696273.591.4.camel@teapot.felipe-alfaro.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Felipe Alfaro Solana <felipe_alfaro@linuxmail.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Russell King <rmk@arm.linux.org.uk>
List-ID: <linux-mm.kvack.org>

Felipe Alfaro Solana <felipe_alfaro@linuxmail.org> wrote:
>
> drivers/pcmcia/cs.c: In function `pcmcia_register_socket':
> drivers/pcmcia/cs.c:361: `dev' undeclared (first use in this function)
> drivers/pcmcia/cs.c:361: (Each undeclared identifier is reported only
> once
> drivers/pcmcia/cs.c:361: for each function it appears in.)
> drivers/pcmcia/cs.c: At top level:
> drivers/pcmcia/cs.c:391: conflicting types for
> `pcmcia_unregister_socket'



diff -puN drivers/pcmcia/cs.c~pcmcia-fix drivers/pcmcia/cs.c
--- 25/drivers/pcmcia/cs.c~pcmcia-fix	2003-04-30 02:55:46.000000000 -0700
+++ 25-akpm/drivers/pcmcia/cs.c	2003-04-30 02:58:54.000000000 -0700
@@ -303,7 +303,7 @@ static int proc_read_clients(char *buf, 
 ======================================================================*/
 
 static int pccardd(void *__skt);
-void pcmcia_unregister_socket(struct device *dev);
+static void pcmcia_unregister_socket(struct class_device *class_dev);
 
 #define to_class_data(dev) dev->class_data
 
@@ -358,7 +358,7 @@ int pcmcia_register_socket(struct class_
 		spin_lock_init(&s->thread_lock);
 		ret = kernel_thread(pccardd, s, CLONE_KERNEL);
 		if (ret < 0) {
-			pcmcia_unregister_socket(dev);
+			pcmcia_unregister_socket(class_dev);
 			break;
 		}
 
@@ -387,7 +387,7 @@ int pcmcia_register_socket(struct class_
 /**
  * pcmcia_unregister_socket - remove a pcmcia socket device
  */
-void pcmcia_unregister_socket(struct class_device *class_dev)
+static void pcmcia_unregister_socket(struct class_device *class_dev)
 {
 	struct pcmcia_socket_class_data *cls_d = class_get_devdata(class_dev);
 	unsigned int i;

_
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
