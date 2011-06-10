Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 36B356B0092
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 05:55:05 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from eu_spt1 ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LMK00B3BJJRPWA0@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 10 Jun 2011 10:55:03 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LMK00DGDJJOMY@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 10 Jun 2011 10:55:01 +0100 (BST)
Date: Fri, 10 Jun 2011 11:54:58 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH 10/10] ARM: S5PV210: add CMA support for FIMC devices on Aquila
 board
In-reply-to: <1307699698-29369-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1307699698-29369-11-git-send-email-m.szyprowski@samsung.com>
References: <1307699698-29369-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org
Cc: Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Johan MOSSBERG <johan.xx.mossberg@stericsson.com>, Mel Gorman <mel@csn.ul.ie>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>

This patch is an example how CMA can be activated for particular devices
in the system. It creates one CMA region and assigns it to all s5p-fimc
devices on Samsung Aquila S5PC110 board.

Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 arch/arm/mach-s5pv210/Kconfig       |    1 +
 arch/arm/mach-s5pv210/mach-aquila.c |   26 ++++++++++++++++++++++++++
 2 files changed, 27 insertions(+), 0 deletions(-)

diff --git a/arch/arm/mach-s5pv210/Kconfig b/arch/arm/mach-s5pv210/Kconfig
index 37b5a97..c09a92c 100644
--- a/arch/arm/mach-s5pv210/Kconfig
+++ b/arch/arm/mach-s5pv210/Kconfig
@@ -64,6 +64,7 @@ menu "S5PC110 Machines"
 config MACH_AQUILA
 	bool "Aquila"
 	select CPU_S5PV210
+	select CMA
 	select S3C_DEV_FB
 	select S5P_DEV_FIMC0
 	select S5P_DEV_FIMC1
diff --git a/arch/arm/mach-s5pv210/mach-aquila.c b/arch/arm/mach-s5pv210/mach-aquila.c
index 4e1d8ff..8c404e5 100644
--- a/arch/arm/mach-s5pv210/mach-aquila.c
+++ b/arch/arm/mach-s5pv210/mach-aquila.c
@@ -21,6 +21,8 @@
 #include <linux/gpio_keys.h>
 #include <linux/input.h>
 #include <linux/gpio.h>
+#include <linux/cma.h>
+#include <linux/dma-mapping.h>
 
 #include <asm/mach/arch.h>
 #include <asm/mach/map.h>
@@ -650,6 +652,19 @@ static void __init aquila_map_io(void)
 	s5p_set_timer_source(S5P_PWM3, S5P_PWM4);
 }
 
+unsigned long cma_area_start;
+unsigned long cma_area_size = 32 << 20;
+
+static void __init aquila_reserve(void)
+{
+	unsigned long ret = cma_reserve(cma_area_start, cma_area_size);
+	
+	if (!IS_ERR_VALUE(ret)) {
+		cma_area_start = ret;
+		printk(KERN_INFO "cma: reserved %ld bytes at %lx\n", cma_area_size, cma_area_start);
+	}
+}
+
 static void __init aquila_machine_init(void)
 {
 	/* PMIC */
@@ -672,6 +687,16 @@ static void __init aquila_machine_init(void)
 	s3c_fb_set_platdata(&aquila_lcd_pdata);
 
 	platform_add_devices(aquila_devices, ARRAY_SIZE(aquila_devices));
+
+	if (cma_area_start) {
+		struct cma *cma;
+		cma = cma_create(cma_area_start, cma_area_size);
+		if (cma) {
+			set_dev_cma_area(&s5p_device_fimc0.dev, cma);
+			set_dev_cma_area(&s5p_device_fimc1.dev, cma);
+			set_dev_cma_area(&s5p_device_fimc2.dev, cma);
+		}
+	}
 }
 
 MACHINE_START(AQUILA, "Aquila")
@@ -683,4 +708,5 @@ MACHINE_START(AQUILA, "Aquila")
 	.map_io		= aquila_map_io,
 	.init_machine	= aquila_machine_init,
 	.timer		= &s5p_timer,
+	.reserve	= aquila_reserve,
 MACHINE_END
-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
