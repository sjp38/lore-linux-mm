Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 9F59B6B0098
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 10:58:34 -0500 (EST)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from spt2.w1.samsung.com ([210.118.77.14]) by mailout4.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LC500JDI31FUQ20@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 19 Nov 2010 15:58:27 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LC500BOS31EOC@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 19 Nov 2010 15:58:27 +0000 (GMT)
Date: Fri, 19 Nov 2010 16:58:11 +0100
From: Michal Nazarewicz <m.nazarewicz@samsung.com>
Subject: [RFCv6 13/13] ARM: cma: Added CMA to Aquila,
 Goni and c210 universal boards
In-reply-to: <cover.1290172312.git.m.nazarewicz@samsung.com>
Message-id: 
 <c5e5580e35e1a8edf211228c4b5aea83830a7ee6.1290172312.git.m.nazarewicz@samsung.com>
References: <cover.1290172312.git.m.nazarewicz@samsung.com>
Sender: owner-linux-mm@kvack.org
To: mina86@mina86.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Ankita Garg <ankita@in.ibm.com>, Bryan Huntsman <bryanh@codeaurora.org>, Daniel Walker <dwalker@codeaurora.org>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Hans Verkuil <hverkuil@xs4all.nl>, Johan Mossberg <johan.xx.mossberg@stericsson.com>, Jonathan Corbet <corbet@lwn.net>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Marcus LORENTZON <marcus.xm.lorentzon@stericsson.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mark Brown <broonie@opensource.wolfsonmicro.com>, Mel Gorman <mel@csn.ul.ie>, Pawel Osciak <pawel@osciak.com>, Russell King <linux@arm.linux.org.uk>, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, Zach Pfeffer <zpfeffer@codeaurora.org>, dipankar@in.ibm.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This commit adds CMA memory reservation code to Aquila, Goni and c210
universal boards.

Signed-off-by: Michal Nazarewicz <m.nazarewicz@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 arch/arm/mach-s5pv210/mach-aquila.c         |   26 ++++++++++++++++++++++++++
 arch/arm/mach-s5pv210/mach-goni.c           |   26 ++++++++++++++++++++++++++
 arch/arm/mach-s5pv310/mach-universal_c210.c |   17 +++++++++++++++++
 3 files changed, 69 insertions(+), 0 deletions(-)

diff --git a/arch/arm/mach-s5pv210/mach-aquila.c b/arch/arm/mach-s5pv210/mach-aquila.c
index 28677ca..f1feb73 100644
--- a/arch/arm/mach-s5pv210/mach-aquila.c
+++ b/arch/arm/mach-s5pv210/mach-aquila.c
@@ -21,6 +21,7 @@
 #include <linux/gpio_keys.h>
 #include <linux/input.h>
 #include <linux/gpio.h>
+#include <linux/cma.h>
 
 #include <asm/mach/arch.h>
 #include <asm/mach/map.h>
@@ -650,6 +651,30 @@ static void __init aquila_sound_init(void)
 	__raw_writel(__raw_readl(S5P_OTHERS) | (0x3 << 8), S5P_OTHERS);
 }
 
+#ifdef CONFIG_CMA
+
+static void __init aquila_reserve(void)
+{
+	static struct cma_region regions[] = {
+		CMA_REGION("fw",  1 << 20, 128 << 10, 0x32000000),
+		CMA_REGION("b1", 32 << 20,         0, 0x33000000),
+		CMA_REGION("b2", 16 << 20,         0, 0x44000000),
+		{ }
+	};
+
+	static const char map[] __initconst =
+		"s5p-mfc5/f=fw;s5p-mfc5/a=b1;s5p-mfc5/b=b2;*=b1,b2";
+
+	cma_set_defaults(regions, map);
+	cma_early_regions_reserve(NULL);
+}
+
+#else
+
+#define aquila_reserve NULL
+
+#endif
+
 static void __init aquila_map_io(void)
 {
 	s5p_init_io(NULL, 0, S5P_VA_CHIPID);
@@ -690,4 +715,5 @@ MACHINE_START(AQUILA, "Aquila")
 	.map_io		= aquila_map_io,
 	.init_machine	= aquila_machine_init,
 	.timer		= &s3c24xx_timer,
+	.reserve	= aquila_reserve,
 MACHINE_END
diff --git a/arch/arm/mach-s5pv210/mach-goni.c b/arch/arm/mach-s5pv210/mach-goni.c
index b1dcf96..0bda14f 100644
--- a/arch/arm/mach-s5pv210/mach-goni.c
+++ b/arch/arm/mach-s5pv210/mach-goni.c
@@ -25,6 +25,7 @@
 #include <linux/gpio_keys.h>
 #include <linux/input.h>
 #include <linux/gpio.h>
+#include <linux/cma.h>
 
 #include <asm/mach/arch.h>
 #include <asm/mach/map.h>
@@ -809,6 +810,30 @@ static void __init goni_sound_init(void)
 	__raw_writel(__raw_readl(S5P_OTHERS) | (0x3 << 8), S5P_OTHERS);
 }
 
+#ifdef CONFIG_CMA
+
+static void __init goni_reserve(void)
+{
+	static struct cma_region regions[] = {
+		CMA_REGION("fw",  1 << 20, 128 << 10, 0x32000000),
+		CMA_REGION("b1", 32 << 20,         0, 0x33000000),
+		CMA_REGION("b2", 16 << 20,         0, 0x44000000),
+		{ }
+	};
+
+	static const char map[] __initconst =
+		"s5p-mfc5/f=fw;s5p-mfc5/a=b1;s5p-mfc5/b=b2;*=b1,b2";
+
+	cma_set_defaults(regions, map);
+	cma_early_regions_reserve(NULL);
+}
+
+#else
+
+#define goni_reserve NULL
+
+#endif
+
 static void __init goni_map_io(void)
 {
 	s5p_init_io(NULL, 0, S5P_VA_CHIPID);
@@ -865,4 +890,5 @@ MACHINE_START(GONI, "GONI")
 	.map_io		= goni_map_io,
 	.init_machine	= goni_machine_init,
 	.timer		= &s3c24xx_timer,
+	.reserve	= goni_reserve,
 MACHINE_END
diff --git a/arch/arm/mach-s5pv310/mach-universal_c210.c b/arch/arm/mach-s5pv310/mach-universal_c210.c
index 16d8fc0..90a2296 100644
--- a/arch/arm/mach-s5pv310/mach-universal_c210.c
+++ b/arch/arm/mach-s5pv310/mach-universal_c210.c
@@ -13,6 +13,7 @@
 #include <linux/i2c.h>
 #include <linux/gpio_keys.h>
 #include <linux/gpio.h>
+#include <linux/cma.h>
 
 #include <asm/mach/arch.h>
 #include <asm/mach-types.h>
@@ -138,6 +139,21 @@ static void __init universal_map_io(void)
 	s3c24xx_init_uarts(universal_uartcfgs, ARRAY_SIZE(universal_uartcfgs));
 }
 
+static void __init universal_reserve(void)
+{
+	static struct cma_region regions[] = {
+		CMA_REGION("r" , 64 << 20, 0, 0),
+		CMA_REGION("fw",  1 << 20, 128 << 10),
+		{ }
+	};
+
+	static const char map[] __initconst =
+		"s3c-mfc5/f=fw;*=r";
+
+	cma_set_defaults(regions, map);
+	cma_early_regions_reserve(NULL);
+}
+
 static void __init universal_machine_init(void)
 {
 	i2c_register_board_info(0, i2c0_devs, ARRAY_SIZE(i2c0_devs));
@@ -152,6 +168,7 @@ MACHINE_START(UNIVERSAL_C210, "UNIVERSAL_C210")
 	.boot_params	= S5P_PA_SDRAM + 0x100,
 	.init_irq	= s5pv310_init_irq,
 	.map_io		= universal_map_io,
+	.reserve	= universal_reserve,
 	.init_machine	= universal_machine_init,
 	.timer		= &s5pv310_timer,
 MACHINE_END
-- 
1.7.2.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
