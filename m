Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 8376C6B00E8
	for <linux-mm@kvack.org>; Wed, 20 Jul 2011 04:57:29 -0400 (EDT)
Received: from spt2.w1.samsung.com (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LOM005BIJJOYK@mailout1.w1.samsung.com> for linux-mm@kvack.org;
 Wed, 20 Jul 2011 09:57:24 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LOM009ROJJNFB@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 20 Jul 2011 09:57:23 +0100 (BST)
Date: Wed, 20 Jul 2011 10:57:20 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH 8/8] ARM: S5PV210: example of CMA private area for FIMC device
 on Goni board
In-reply-to: <1311152240-16384-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1311152240-16384-9-git-send-email-m.szyprowski@samsung.com>
MIME-version: 1.0
Content-type: TEXT/PLAIN
Content-transfer-encoding: 7BIT
References: <1311152240-16384-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org
Cc: Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Mel Gorman <mel@csn.ul.ie>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Chunsang Jeong <chunsang.jeong@linaro.org>, Russell King <linux@arm.linux.org.uk>

This patch is an example how device private CMA area can be activated.
It creates one CMA region and assigns it to the first s5p-fimc device on
Samsung Goni S5PC110 board.

Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 arch/arm/mach-s5pv210/Kconfig     |    1 +
 arch/arm/mach-s5pv210/mach-goni.c |    8 ++++++++
 2 files changed, 9 insertions(+), 0 deletions(-)

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
diff --git a/arch/arm/mach-s5pv210/mach-goni.c b/arch/arm/mach-s5pv210/mach-goni.c
index 31d5aa7..d9e565d 100644
--- a/arch/arm/mach-s5pv210/mach-goni.c
+++ b/arch/arm/mach-s5pv210/mach-goni.c
@@ -26,6 +26,7 @@
 #include <linux/input.h>
 #include <linux/gpio.h>
 #include <linux/interrupt.h>
+#include <linux/dma-contiguous.h>
 
 #include <asm/mach/arch.h>
 #include <asm/mach/map.h>
@@ -886,6 +887,12 @@ static void __init goni_machine_init(void)
 	platform_add_devices(goni_devices, ARRAY_SIZE(goni_devices));
 }
 
+static void __init goni_reserve(void)
+{
+	/* Create private 16MiB contiguous memory area for s5p-fimc.0 device */
+	dma_declare_contiguous(&s5p_device_fimc0.dev, 16*SZ_1M, 0);
+}
+
 MACHINE_START(GONI, "GONI")
 	/* Maintainers: Kyungmin Park <kyungmin.park@samsung.com> */
 	.boot_params	= S5P_PA_SDRAM + 0x100,
@@ -893,4 +900,5 @@ MACHINE_START(GONI, "GONI")
 	.map_io		= goni_map_io,
 	.init_machine	= goni_machine_init,
 	.timer		= &s5p_timer,
+	.reserve	= goni_reserve,
 MACHINE_END
-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
