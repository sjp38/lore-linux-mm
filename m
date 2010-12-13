Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 36A536B008C
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 06:27:02 -0500 (EST)
Received: from eu_spt1 (mailout2.w1.samsung.com [210.118.77.12])
 by mailout2.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LDD00M866GZ5R@mailout2.w1.samsung.com> for linux-mm@kvack.org;
 Mon, 13 Dec 2010 11:26:59 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LDD00IFB6GYYE@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 13 Dec 2010 11:26:59 +0000 (GMT)
Date: Mon, 13 Dec 2010 12:26:51 +0100
From: Michal Nazarewicz <m.nazarewicz@samsung.com>
Subject: [PATCHv7 10/10] ARM: cma: Added CMA to Aquila,
 Goni and c210 universal boards
In-reply-to: <cover.1292004520.git.m.nazarewicz@samsung.com>
Message-id: 
 <cb1df81fb822b99ff00d2f4387525f8b07f05e57.1292004520.git.m.nazarewicz@samsung.com>
MIME-version: 1.0
Content-type: TEXT/PLAIN
Content-transfer-encoding: 7BIT
References: <cover.1292004520.git.m.nazarewicz@samsung.com>
Sender: owner-linux-mm@kvack.org
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ankita Garg <ankita@in.ibm.com>, BooJin Kim <boojin.kim@samsung.com>, Daniel Walker <dwalker@codeaurora.org>, Johan MOSSBERG <johan.xx.mossberg@stericsson.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mel@csn.ul.ie>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, linux-mm@kvack.org, Michal Nazarewicz <m.nazarewicz@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>
List-ID: <linux-mm.kvack.org>

This commit adds CMA memory reservation code to Aquila, Goni and c210
universal boards.

Signed-off-by: Michal Nazarewicz <m.nazarewicz@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 arch/arm/mach-s5pv210/mach-aquila.c         |    2 +
 arch/arm/mach-s5pv210/mach-goni.c           |    2 +
 arch/arm/mach-s5pv310/mach-universal_c210.c |    2 +
 arch/arm/plat-s5p/Makefile                  |    2 +
 arch/arm/plat-s5p/cma-stub.c                |   49 +++++++++++++++++++++++++++
 arch/arm/plat-s5p/include/plat/cma-stub.h   |   21 +++++++++++
 6 files changed, 78 insertions(+), 0 deletions(-)
 create mode 100644 arch/arm/plat-s5p/cma-stub.c
 create mode 100644 arch/arm/plat-s5p/include/plat/cma-stub.h

diff --git a/arch/arm/mach-s5pv210/mach-aquila.c b/arch/arm/mach-s5pv210/mach-aquila.c
index 28677ca..8608a16 100644
--- a/arch/arm/mach-s5pv210/mach-aquila.c
+++ b/arch/arm/mach-s5pv210/mach-aquila.c
@@ -39,6 +39,7 @@
 #include <plat/fb.h>
 #include <plat/fimc-core.h>
 #include <plat/sdhci.h>
+#include <plat/cma-stub.h>
 
 /* Following are default values for UCON, ULCON and UFCON UART registers */
 #define AQUILA_UCON_DEFAULT	(S3C2410_UCON_TXILEVEL |	\
@@ -690,4 +691,5 @@ MACHINE_START(AQUILA, "Aquila")
 	.map_io		= aquila_map_io,
 	.init_machine	= aquila_machine_init,
 	.timer		= &s3c24xx_timer,
+	.reserve	= cma_mach_reserve,
 MACHINE_END
diff --git a/arch/arm/mach-s5pv210/mach-goni.c b/arch/arm/mach-s5pv210/mach-goni.c
index b1dcf96..b1bf079 100644
--- a/arch/arm/mach-s5pv210/mach-goni.c
+++ b/arch/arm/mach-s5pv210/mach-goni.c
@@ -45,6 +45,7 @@
 #include <plat/keypad.h>
 #include <plat/sdhci.h>
 #include <plat/clock.h>
+#include <plat/cma-stub.h>
 
 /* Following are default values for UCON, ULCON and UFCON UART registers */
 #define GONI_UCON_DEFAULT	(S3C2410_UCON_TXILEVEL |	\
@@ -865,4 +866,5 @@ MACHINE_START(GONI, "GONI")
 	.map_io		= goni_map_io,
 	.init_machine	= goni_machine_init,
 	.timer		= &s3c24xx_timer,
+	.reserve	= cma_mach_reserve,
 MACHINE_END
diff --git a/arch/arm/mach-s5pv310/mach-universal_c210.c b/arch/arm/mach-s5pv310/mach-universal_c210.c
index 16d8fc0..d65703a 100644
--- a/arch/arm/mach-s5pv310/mach-universal_c210.c
+++ b/arch/arm/mach-s5pv310/mach-universal_c210.c
@@ -21,6 +21,7 @@
 #include <plat/s5pv310.h>
 #include <plat/cpu.h>
 #include <plat/devs.h>
+#include <plat/cma-stub.h>
 
 #include <mach/map.h>
 
@@ -152,6 +153,7 @@ MACHINE_START(UNIVERSAL_C210, "UNIVERSAL_C210")
 	.boot_params	= S5P_PA_SDRAM + 0x100,
 	.init_irq	= s5pv310_init_irq,
 	.map_io		= universal_map_io,
+	.reserve	= cma_mach_reserve,
 	.init_machine	= universal_machine_init,
 	.timer		= &s5pv310_timer,
 MACHINE_END
diff --git a/arch/arm/plat-s5p/Makefile b/arch/arm/plat-s5p/Makefile
index de65238..6fdb6ce 100644
--- a/arch/arm/plat-s5p/Makefile
+++ b/arch/arm/plat-s5p/Makefile
@@ -28,3 +28,5 @@ obj-$(CONFIG_S5P_DEV_FIMC0)	+= dev-fimc0.o
 obj-$(CONFIG_S5P_DEV_FIMC1)	+= dev-fimc1.o
 obj-$(CONFIG_S5P_DEV_FIMC2)	+= dev-fimc2.o
 obj-$(CONFIG_S5P_DEV_ONENAND)	+= dev-onenand.o
+
+obj-$(CONFIG_CMA) += cma-stub.o
diff --git a/arch/arm/plat-s5p/cma-stub.c b/arch/arm/plat-s5p/cma-stub.c
new file mode 100644
index 0000000..716e56d
--- /dev/null
+++ b/arch/arm/plat-s5p/cma-stub.c
@@ -0,0 +1,49 @@
+/*
+ * This file is just a quick and dirty hack to get CMA testing device
+ * working.  The cma_mach_reserve() should be called as mach's reserve
+ * callback.  CMA testing device will use cma_ctx for allocations.
+ */
+
+#include <plat/cma-stub.h>
+
+#include <linux/cma.h>
+#include <linux/err.h>
+#include <linux/init.h>
+#include <linux/kernel.h>
+
+struct cma *cma_ctx;
+
+#define cma_size (32UL << 20) /* 32 MiB */
+
+static unsigned long cma_start __initdata;
+
+void __init cma_mach_reserve(void)
+{
+	unsigned long start = cma_reserve(0, cma_size, 0);
+	if (IS_ERR_VALUE(start))
+		printk(KERN_WARNING "cma: unable to reserve %lu for CMA: %d\n",
+		       cma_size >> 20, (int)start);
+	else
+		cma_start = start;
+}
+
+static int __init cma_mach_init(void)
+{
+	int ret = -ENOMEM;
+
+	if (cma_start) {
+		struct cma *ctx = cma_create(cma_start, cma_size);
+		if (IS_ERR(ctx)) {
+			ret = PTR_ERR(ctx);
+			printk(KERN_WARNING
+			       "cma: cma_create(%p, %p) failed: %d\n",
+			       (void *)cma_start, (void *)cma_size, ret);
+		} else {
+			cma_ctx = ctx;
+			ret = 0;
+		}
+	}
+
+	return ret;
+}
+device_initcall(cma_mach_init);
diff --git a/arch/arm/plat-s5p/include/plat/cma-stub.h b/arch/arm/plat-s5p/include/plat/cma-stub.h
new file mode 100644
index 0000000..a24a03b
--- /dev/null
+++ b/arch/arm/plat-s5p/include/plat/cma-stub.h
@@ -0,0 +1,21 @@
+/*
+ * This file is just a quick and dirty hack to get CMA testing device
+ * working.  The cma_mach_reserve() should be called as mach's reserve
+ * callback.  CMA testing device will use cma_ctx for allocations.
+ */
+
+struct cma;
+
+#ifdef CONFIG_CMA
+
+extern struct cma *cma_ctx;
+
+void cma_mach_reserve(void);
+
+#else
+
+#define cma_ctx ((struct cma *)NULL)
+
+#define cma_mach_reserve NULL
+
+#endif
-- 
1.7.2.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
