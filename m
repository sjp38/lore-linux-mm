Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 17C5D6B016D
	for <linux-mm@kvack.org>; Fri, 12 Aug 2011 06:58:39 -0400 (EDT)
Received: from eu_spt1 (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LPT0031CAHOUQ@mailout1.w1.samsung.com> for linux-mm@kvack.org;
 Fri, 12 Aug 2011 11:58:36 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LPT003DAAHNYX@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 12 Aug 2011 11:58:35 +0100 (BST)
Date: Fri, 12 Aug 2011 12:58:31 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH 9/9] ARM: S5PV210: example of CMA private area for FIMC device
 on Goni board
In-reply-to: <1313146711-1767-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1313146711-1767-10-git-send-email-m.szyprowski@samsung.com>
MIME-version: 1.0
Content-type: TEXT/PLAIN
Content-transfer-encoding: 7BIT
References: <1313146711-1767-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org
Cc: Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Mel Gorman <mel@csn.ul.ie>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>

This patch is an example how device private CMA area can be activated.
It creates one CMA region and assigns it to the first s5p-fimc device on
Samsung Goni S5PC110 board.

Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 arch/arm/mach-s5pv210/Kconfig     |    1 +
 arch/arm/mach-s5pv210/mach-goni.c |    4 ++++
 2 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/arch/arm/mach-s5pv210/Kconfig b/arch/arm/mach-s5pv210/Kconfig
index 69dd87c..697a5be 100644
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
index 85c2d51..665c4ae 100644
--- a/arch/arm/mach-s5pv210/mach-goni.c
+++ b/arch/arm/mach-s5pv210/mach-goni.c
@@ -26,6 +26,7 @@
 #include <linux/input.h>
 #include <linux/gpio.h>
 #include <linux/interrupt.h>
+#include <linux/dma-contiguous.h>
 
 #include <asm/mach/arch.h>
 #include <asm/mach/map.h>
@@ -848,6 +849,9 @@ static void __init goni_map_io(void)
 static void __init goni_reserve(void)
 {
 	s5p_mfc_reserve_mem(0x43000000, 8 << 20, 0x51000000, 8 << 20);
+
+	/* Create private 16MiB contiguous memory area for s5p-fimc.0 device */
+	dma_declare_contiguous(&s5p_device_fimc0.dev, 16*SZ_1M, 0);
 }
 
 static void __init goni_machine_init(void)
-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
