Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0B8B18D0095
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 08:08:24 -0500 (EST)
Received: from zeta.dmz-ap.st.com (ns6.st.com [138.198.234.13])
	by beta.dmz-ap.st.com (STMicroelectronics) with ESMTP id 1697FED
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 13:08:04 +0000 (GMT)
Received: from relay1.stm.gmessaging.net (unknown [10.230.100.17])
	by zeta.dmz-ap.st.com (STMicroelectronics) with ESMTP id C87BA792
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 13:08:03 +0000 (GMT)
Received: from exdcvycastm004.EQ1STM.local (alteon-source-exch [10.230.100.61])
	(using TLSv1 with cipher RC4-MD5 (128/128 bits))
	(Client CN "exdcvycastm004", Issuer "exdcvycastm004" (not verified))
	by relay1.stm.gmessaging.net (Postfix) with ESMTPS id 6ECDE24C07C
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 14:07:56 +0100 (CET)
From: Johan Mossberg <johan.xx.mossberg@stericsson.com>
Subject: [PATCH 3/3] hwmem: Add hwmem to ux500 and mop500
Date: Tue, 16 Nov 2010 14:08:02 +0100
Message-ID: <1289912882-23996-4-git-send-email-johan.xx.mossberg@stericsson.com>
In-Reply-To: <1289912882-23996-3-git-send-email-johan.xx.mossberg@stericsson.com>
References: <1289912882-23996-1-git-send-email-johan.xx.mossberg@stericsson.com>
 <1289912882-23996-2-git-send-email-johan.xx.mossberg@stericsson.com>
 <1289912882-23996-3-git-send-email-johan.xx.mossberg@stericsson.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Johan Mossberg <johan.xx.mossberg@stericsson.com>
List-ID: <linux-mm.kvack.org>

Signed-off-by: Johan Mossberg <johan.xx.mossberg@stericsson.com>
Acked-by: Linus Walleij <linus.walleij@stericsson.com>
---
 arch/arm/mach-ux500/board-mop500.c         |    1 +
 arch/arm/mach-ux500/devices.c              |   31 ++++++++++++++++++++++++++++
 arch/arm/mach-ux500/include/mach/devices.h |    1 +
 3 files changed, 33 insertions(+), 0 deletions(-)

diff --git a/arch/arm/mach-ux500/board-mop500.c b/arch/arm/mach-ux500/board-mop500.c
index 2c89e70..7a0b604 100644
--- a/arch/arm/mach-ux500/board-mop500.c
+++ b/arch/arm/mach-ux500/board-mop500.c
@@ -304,6 +304,7 @@ static struct ske_keypad_platform_data ske_keypad_board = {
 /* add any platform devices here - TODO */
 static struct platform_device *platform_devs[] __initdata = {
 	&ux500_ske_keypad_device,
+	&ux500_hwmem_device,
 };
 
 #ifdef CONFIG_STE_DMA40
diff --git a/arch/arm/mach-ux500/devices.c b/arch/arm/mach-ux500/devices.c
index ea0a2f9..a8db519 100644
--- a/arch/arm/mach-ux500/devices.c
+++ b/arch/arm/mach-ux500/devices.c
@@ -10,10 +10,41 @@
 #include <linux/interrupt.h>
 #include <linux/io.h>
 #include <linux/amba/bus.h>
+#include <linux/hwmem.h>
 
 #include <mach/hardware.h>
 #include <mach/setup.h>
 
+static struct hwmem_platform_data hwmem_pdata = {
+	.start = 0,
+	.size = 0,
+};
+
+static int __init early_hwmem(char *p)
+{
+	hwmem_pdata.size = memparse(p, &p);
+
+	if (*p != '@')
+		goto no_at;
+
+	hwmem_pdata.start = memparse(p + 1, &p);
+
+	return 0;
+
+no_at:
+	hwmem_pdata.size = 0;
+
+	return -EINVAL;
+}
+early_param("hwmem", early_hwmem);
+
+struct platform_device ux500_hwmem_device = {
+	.name = "hwmem",
+	.dev = {
+		.platform_data = &hwmem_pdata,
+	},
+};
+
 void __init amba_add_devices(struct amba_device *devs[], int num)
 {
 	int i;
diff --git a/arch/arm/mach-ux500/include/mach/devices.h b/arch/arm/mach-ux500/include/mach/devices.h
index 020b636..d5182e2 100644
--- a/arch/arm/mach-ux500/include/mach/devices.h
+++ b/arch/arm/mach-ux500/include/mach/devices.h
@@ -17,6 +17,7 @@ extern struct amba_device ux500_pl031_device;
 
 extern struct platform_device u8500_dma40_device;
 extern struct platform_device ux500_ske_keypad_device;
+extern struct platform_device ux500_hwmem_device;
 
 void dma40_u8500ed_fixup(void);
 
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
