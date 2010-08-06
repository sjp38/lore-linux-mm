Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id F1EC9600299
	for <linux-mm@kvack.org>; Fri,  6 Aug 2010 09:20:48 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from eu_spt1 ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0L6Q00G4YFQLU050@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 06 Aug 2010 14:20:45 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0L6Q00FHYFQKCP@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 06 Aug 2010 14:20:44 +0100 (BST)
Date: Fri, 06 Aug 2010 15:22:12 +0200
From: Michal Nazarewicz <m.nazarewicz@samsung.com>
Subject: [PATCH/RFCv3 6/6] arm: Added CMA to Aquila and Goni
In-reply-to: 
 <f62f8940644b4d0c585bc8ad1fdcb17be0922a0d.1281100495.git.m.nazarewicz@samsung.com>
Message-id: 
 <6e351192baf33fefce3fb186e67c4c5f3c7d9d30.1281100495.git.m.nazarewicz@samsung.com>
References: <cover.1281100495.git.m.nazarewicz@samsung.com>
 <743102607e2c5fb20e3c0676fadbcb93d501a78e.1281100495.git.m.nazarewicz@samsung.com>
 <6a924738f412a7ad738e99123411b7a20f761ae1.1281100495.git.m.nazarewicz@samsung.com>
 <a5061fdb8e8819f1cc281c4279c295146fab6d68.1281100495.git.m.nazarewicz@samsung.com>
 <05957b9dc9231d296525203d8347d4c9c5246c15.1281100495.git.m.nazarewicz@samsung.com>
 <f62f8940644b4d0c585bc8ad1fdcb17be0922a0d.1281100495.git.m.nazarewicz@samsung.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Hans Verkuil <hverkuil@xs4all.nl>, Marek Szyprowski <m.szyprowski@samsung.com>, Daniel Walker <dwalker@codeaurora.org>, Jonathan Corbet <corbet@lwn.net>, Pawel Osciak <p.osciak@samsung.com>, Mark Brown <broonie@opensource.wolfsonmicro.com>, Hiremath Vaibhav <hvaibhav@ti.com>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Kyungmin Park <kyungmin.park@samsung.com>, Zach Pfeffer <zpfeffer@codeaurora.org>, Russell King <linux@arm.linux.org.uk>, jaeryul.oh@samsung.com, kgene.kim@samsung.com, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-kernel@vger.kernel.org, Michal Nazarewicz <m.nazarewicz@samsung.com>
List-ID: <linux-mm.kvack.org>

Added the CMA initialisation code to two Samsung platforms.

Signed-off-by: Michal Nazarewicz <m.nazarewicz@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 arch/arm/mach-s5pv210/mach-aquila.c |   31 +++++++++++++++++++++++++++++++
 arch/arm/mach-s5pv210/mach-goni.c   |   31 +++++++++++++++++++++++++++++++
 2 files changed, 62 insertions(+), 0 deletions(-)

diff --git a/arch/arm/mach-s5pv210/mach-aquila.c b/arch/arm/mach-s5pv210/mach-aquila.c
index 0992618..e99fe4c 100644
--- a/arch/arm/mach-s5pv210/mach-aquila.c
+++ b/arch/arm/mach-s5pv210/mach-aquila.c
@@ -19,6 +19,7 @@
 #include <linux/gpio_keys.h>
 #include <linux/input.h>
 #include <linux/gpio.h>
+#include <linux/cma.h>
 
 #include <asm/mach/arch.h>
 #include <asm/mach/map.h>
@@ -454,6 +455,35 @@ static void __init aquila_map_io(void)
 	s3c24xx_init_uarts(aquila_uartcfgs, ARRAY_SIZE(aquila_uartcfgs));
 }
 
+static void __init aquila_reserve(void)
+{
+	static struct cma_region regions[] = {
+		{
+			.name		= "fw",
+			.size		=   1 << 20,
+			{ .alignment	= 128 << 10 },
+		},
+		{
+			.name		= "b1",
+			.size		=  32 << 20,
+			.asterisk	= 1,
+		},
+		{
+			.name		= "b2",
+			.size		=  16 << 20,
+			.start		= 0x40000000,
+			.asterisk	= 1,
+		},
+		{ }
+	};
+
+	static const char map[] __initconst =
+		"s3c-mfc5/f=fw;s3c-mfc5/a=b1;s3c-mfc5/b=b2";
+
+	cma_set_defaults(regions, map);
+	cma_early_regions_reserve(NULL);
+}
+
 static void __init aquila_machine_init(void)
 {
 	/* PMIC */
@@ -478,4 +508,5 @@ MACHINE_START(AQUILA, "Aquila")
 	.map_io		= aquila_map_io,
 	.init_machine	= aquila_machine_init,
 	.timer		= &s3c24xx_timer,
+	.reserve	= aquila_reserve,
 MACHINE_END
diff --git a/arch/arm/mach-s5pv210/mach-goni.c b/arch/arm/mach-s5pv210/mach-goni.c
index 7b18505..42549e9 100644
--- a/arch/arm/mach-s5pv210/mach-goni.c
+++ b/arch/arm/mach-s5pv210/mach-goni.c
@@ -19,6 +19,7 @@
 #include <linux/gpio_keys.h>
 #include <linux/input.h>
 #include <linux/gpio.h>
+#include <linux/cma.h>
 
 #include <asm/mach/arch.h>
 #include <asm/mach/map.h>
@@ -435,6 +436,35 @@ static void __init goni_map_io(void)
 	s3c24xx_init_uarts(goni_uartcfgs, ARRAY_SIZE(goni_uartcfgs));
 }
 
+static void __init goni_reserve(void)
+{
+	static struct cma_region regions[] = {
+		{
+			.name		= "fw",
+			.size		=   1 << 20,
+			{ .alignment	= 128 << 10 },
+		},
+		{
+			.name		= "b1",
+			.size		=  32 << 20,
+			.asterisk	= 1,
+		},
+		{
+			.name		= "b2",
+			.size		=  16 << 20,
+			.start		= 0x40000000,
+			.asterisk	= 1,
+		},
+		{ }
+	};
+
+	static const char map[] __initconst =
+		"s3c-mfc5/f=fw;s3c-mfc5/a=b1;s3c-mfc5/b=b2";
+
+	cma_set_defaults(regions, map);
+	cma_early_regions_reserve(NULL);
+}
+
 static void __init goni_machine_init(void)
 {
 	/* PMIC */
@@ -456,4 +486,5 @@ MACHINE_START(GONI, "GONI")
 	.map_io		= goni_map_io,
 	.init_machine	= goni_machine_init,
 	.timer		= &s3c24xx_timer,
+	.reserve	= goni_reserve,
 MACHINE_END
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
