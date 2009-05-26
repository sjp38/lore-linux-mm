Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D3AFA6B0089
	for <linux-mm@kvack.org>; Tue, 26 May 2009 00:57:06 -0400 (EDT)
Received: by yw-out-1718.google.com with SMTP id 5so1607695ywm.26
        for <linux-mm@kvack.org>; Mon, 25 May 2009 21:57:59 -0700 (PDT)
Date: Tue, 26 May 2009 13:57:33 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH][mmtom] clean up once printk routine
Message-Id: <20090526135733.3c38f758.minchan.kim@barrios-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: Randy Dunlap <randy.dunlap@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, Pavel Machek <pavel@ucw.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, "David S. Miller" <davem@davemloft.net>, Dominik Brodowski <linux@dominikbrodowski.net>, Ingo Molnar <mingo@elte.hu>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


On Tue, 26 May 2009 12:29:34 +0900
Paul Mundt <lethal@linux-sh.org> wrote:

> On Sun, May 24, 2009 at 07:42:02PM -0700, Randy Dunlap wrote:
> > KOSAKI Motohiro wrote:
> > >> +	if (!printed) {
> > >> +		printed = 1;
> > >> +		printk(KERN_WARNING "All of swap is in use. Some pages cannot be swapped out.");
> > >> +	}
> > > 
> > > Why don't you use WARN_ONCE()?
> > 
> > Someone earlier in this patch thread (maybe Pavel?) commented that
> > WARN_ONCE() would cause a stack dump and that would be too harsh,
> > especially for users.  I.e., just the message is needed here, not a
> > stack dump.
> > 
> Note that this is precisely what we have printk_once() for these days,
> which will do what this patch is doing already. Of course if the variable
> will be reset, then it is best left as is.

Yes. There are also some places to be able to use printk_once().
Are there any place I missed ?

== CUT HERE ==

There are some places to be able to use printk_once instead of hard coding.

It will help code readability and maintenance.
This patch doesn't change function's behavior.

Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
CC: Dominik Brodowski <linux@dominikbrodowski.net>
CC: David S. Miller <davem@davemloft.net>
CC: Ingo Molnar <mingo@elte.hu>
---
 arch/x86/kernel/cpu/common.c  |    8 ++------
 drivers/net/3c515.c           |    7 ++-----
 drivers/pcmcia/pcmcia_ioctl.c |    9 +++------
 3 files changed, 7 insertions(+), 17 deletions(-)

diff --git a/arch/x86/kernel/cpu/common.c b/arch/x86/kernel/cpu/common.c
index 82bec86..dc0f694 100644
--- a/arch/x86/kernel/cpu/common.c
+++ b/arch/x86/kernel/cpu/common.c
@@ -496,13 +496,9 @@ static void __cpuinit get_cpu_vendor(struct cpuinfo_x86 *c)
 		}
 	}
 
-	if (!printed) {
-		printed++;
-		printk(KERN_ERR
+	printk_once(KERN_ERR
 		    "CPU: vendor_id '%s' unknown, using generic init.\n", v);
-
-		printk(KERN_ERR "CPU: Your system may be unstable.\n");
-	}
+	printk_once(KERN_ERR "CPU: Your system may be unstable.\n");
 
 	c->x86_vendor = X86_VENDOR_UNKNOWN;
 	this_cpu = &default_cpu;
diff --git a/drivers/net/3c515.c b/drivers/net/3c515.c
index 167bf23..0450605 100644
--- a/drivers/net/3c515.c
+++ b/drivers/net/3c515.c
@@ -430,15 +430,12 @@ int init_module(void)
 struct net_device *tc515_probe(int unit)
 {
 	struct net_device *dev = corkscrew_scan(unit);
-	static int printed;
 
 	if (!dev)
 		return ERR_PTR(-ENODEV);
 
-	if (corkscrew_debug > 0 && !printed) {
-		printed = 1;
-		printk(version);
-	}
+	if (corkscrew_debug > 0) 
+		printk_once(version);
 
 	return dev;
 }
diff --git a/drivers/pcmcia/pcmcia_ioctl.c b/drivers/pcmcia/pcmcia_ioctl.c
index 1703b20..78af368 100644
--- a/drivers/pcmcia/pcmcia_ioctl.c
+++ b/drivers/pcmcia/pcmcia_ioctl.c
@@ -915,12 +915,9 @@ static int ds_ioctl(struct inode * inode, struct file * file,
 		err = -EPERM;
 		goto free_out;
 	} else {
-		static int printed = 0;
-		if (!printed) {
-			printk(KERN_WARNING "2.6. kernels use pcmciamtd instead of memory_cs.c and do not require special\n");
-			printk(KERN_WARNING "MTD handling any more.\n");
-			printed++;
-		}
+			printk_once(KERN_WARNING 
+				"2.6. kernels use pcmciamtd instead of memory_cs.c and do not require special\n");
+			printk_once(KERN_WARNING "MTD handling any more.\n");
 	}
 	err = -EINVAL;
 	goto free_out;
-- 
1.5.4.3



-- 
Kinds Regards
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
