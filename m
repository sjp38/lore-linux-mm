Date: Tue, 8 Apr 2003 09:10:48 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.67-mm1
Message-Id: <20030408091048.002a2e08.akpm@digeo.com>
In-Reply-To: <200304080917.15648.tomlins@cam.org>
References: <20030408042239.053e1d23.akpm@digeo.com>
	<200304080917.15648.tomlins@cam.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <tomlins@cam.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ed Tomlinson <tomlins@cam.org> wrote:
>
> Hi,
> 
> This does not boot here.  I loop with the following message. 
> 
> i8042.c: Can't get irq 12 for AUX, unregistering the port.
> 
> irq 12 is used (correctly) by my 20267 ide card.  My mouse is
> usb and AUX is not used.
> 

Does the below patch help?  Probably not...

And does reverting
ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.5/2.5.67/2.5.67-mm1/broken-out/earlier-keyboard-init.patch
fix it?

Thanks.

diff -puN drivers/input/serio/i8042.c~i8042-share-irqs drivers/input/serio/i8042.c
--- 25/drivers/input/serio/i8042.c~i8042-share-irqs	2003-04-08 09:05:16.000000000 -0700
+++ 25-akpm/drivers/input/serio/i8042.c	2003-04-08 09:05:59.000000000 -0700
@@ -235,7 +235,8 @@ static int i8042_open(struct serio *port
 		if (i8042_mux_open++)
 			return 0;
 
-	if (request_irq(values->irq, i8042_interrupt, 0, "i8042", NULL)) {
+	if (request_irq(values->irq, i8042_interrupt,
+			SA_SHIRQ, "i8042", NULL)) {
 		printk(KERN_ERR "i8042.c: Can't get irq %d for %s, unregistering the port.\n", values->irq, values->name);
 		values->exists = 0;
 		serio_unregister_port(port);
@@ -570,7 +571,7 @@ static int __init i8042_check_mux(struct
  * Check if AUX irq is available.
  */
 
-	if (request_irq(values->irq, i8042_interrupt, 0, "i8042", NULL))
+	if (request_irq(values->irq, i8042_interrupt, SA_SHIRQ, "i8042", NULL))
                 return -1;
 	free_irq(values->irq, NULL);
 
@@ -641,7 +642,7 @@ static int __init i8042_check_aux(struct
  * in trying to detect AUX presence.
  */
 
-	if (request_irq(values->irq, i8042_interrupt, 0, "i8042", NULL))
+	if (request_irq(values->irq, i8042_interrupt, SA_SHIRQ, "i8042", NULL))
                 return -1;
 	free_irq(values->irq, NULL);
 

_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
