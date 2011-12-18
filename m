Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id D1E726B004D
	for <linux-mm@kvack.org>; Sun, 18 Dec 2011 15:48:33 -0500 (EST)
From: Philip Prindeville <philipp_subx@redfish-solutions.com>
Subject: [PATCH 3/4] geos: Platform driver for Geos and Geos2 single-board computers.
Date: Sun, 18 Dec 2011 13:48:26 -0700
Message-Id: <1324241306-7738-1-git-send-email-philipp_subx@redfish-solutions.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ed Wildgoose <ed@wildgooses.com>, Andrew Morton <akpm@linux-foundation.org>, linux-geode@lists.infradead.org, Andres Salomon <dilinger@queued.net>
Cc: Nathan Williams <nathan@traverse.com.au>, Guy Ellis <guy@traverse.com.au>, David Woodhouse <dwmw2@infradead.org>, Patrick Georgi <patrick.georgi@secunet.com>, Carl-Daniel Hailfinger <c-d.hailfinger.devel.2006@gmx.net>, linux-mm@kvack.org

From: Philip Prindeville <philipp@redfish-solutions.com>

Trivial platform driver for Traverse Technologies Geos and Geos2
single-board computers. Uses Coreboot BIOS to identify platform.
Based on progressive revisions of the leds-net5501 driver that
was rewritten by Ed Wildgoose as a platform driver.

Supports GPIO-based LEDs (3) and 1 polled button which is
typically used for a soft reset.

Signed-off-by: Philip Prindeville <philipp@redfish-solutions.com>
Reviewed-by: Ed Wildgoose <ed@wildgooses.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andres Salomon <dilinger@queued.net>
Cc: Nathan Williams <nathan@traverse.com.au>
Cc: Guy Ellis <guy@traverse.com.au>
Cc: David Woodhouse <dwmw2@infradead.org>
Cc: Patrick Georgi <patrick.georgi@secunet.com>
Cc: Carl-Daniel Hailfinger <c-d.hailfinger.devel.2006@gmx.net>
Cc: linux-geode@lists.infradead.org
Cc: Alessandro Zummo <a.zummo@towertech.it>
Cc: Constantin Baranov <const@mimas.ru>
---
 arch/x86/Kconfig                 |    7 ++
 arch/x86/platform/geode/Makefile |    1 +
 arch/x86/platform/geode/geos.c   |  127 ++++++++++++++++++++++++++++++++++++++
 3 files changed, 135 insertions(+), 0 deletions(-)
 create mode 100644 arch/x86/platform/geode/geos.c

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 9f195f1..de8e783 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -2161,6 +2161,13 @@ config ALIX
 
 	  Note: You have to set alix.force=1 for boards with Award BIOS.
 
+config GEOS
+	bool "Traverse Technologies GEOS System Support (LEDS, GPIO, etc)"
+	select GPIOLIB
+	select COREBOOT
+	---help---
+	  This option enables system support for the Traverse Technologies GEOS.
+
 endif # X86_32
 
 config AMD_NB
diff --git a/arch/x86/platform/geode/Makefile b/arch/x86/platform/geode/Makefile
index 07c9cd0..d8ba564 100644
--- a/arch/x86/platform/geode/Makefile
+++ b/arch/x86/platform/geode/Makefile
@@ -1 +1,2 @@
 obj-$(CONFIG_ALIX)		+= alix.o
+obj-$(CONFIG_GEOS)		+= geos.o
diff --git a/arch/x86/platform/geode/geos.c b/arch/x86/platform/geode/geos.c
new file mode 100644
index 0000000..68106a5
--- /dev/null
+++ b/arch/x86/platform/geode/geos.c
@@ -0,0 +1,127 @@
+/*
+ * System Specific setup for Traverse Technologies GEOS.
+ * At the moment this means setup of GPIO control of LEDs.
+ *
+ * Copyright (C) 2008 Constantin Baranov <const@mimas.ru>
+ * Copyright (C) 2011 Ed Wildgoose <kernel@wildgooses.com>
+ *                and Philip Prindeville <philipp@redfish-solutions.com>
+ *
+ * TODO: There are large similarities with leds-net5501.c
+ * by Alessandro Zummo <a.zummo@towertech.it>
+ * In the future leds-net5501.c should be migrated over to platform
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.
+ */
+
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/io.h>
+#include <linux/string.h>
+#include <linux/module.h>
+#include <linux/leds.h>
+#include <linux/platform_device.h>
+#include <linux/gpio.h>
+#include <linux/input.h>
+#include <linux/gpio_keys.h>
+#include <linux/mm.h>
+
+#include <asm/geode.h>
+#include <linux/coreboot.h>
+
+static struct gpio_keys_button geos_gpio_buttons[] = {
+	{
+		.code = KEY_RESTART,
+		.gpio = 3,
+		.active_low = 1,
+		.desc = "Reset button",
+		.type = EV_KEY,
+		.wakeup = 0,
+		.debounce_interval = 100,
+		.can_disable = 0,
+	}
+};
+static struct gpio_keys_platform_data geos_buttons_data = {
+	.buttons = geos_gpio_buttons,
+	.nbuttons = ARRAY_SIZE(geos_gpio_buttons),
+	.poll_interval = 20,
+};
+
+static struct platform_device geos_buttons_dev = {
+	.name = "gpio-keys-polled",
+	.id = 1,
+	.dev = {
+		.platform_data = &geos_buttons_data,
+	}
+};
+
+static struct gpio_led geos_leds[] = {
+	{
+		.name = "geos:1",
+		.gpio = 6,
+		.default_trigger = "default-on",
+		.active_low = 1,
+	},
+	{
+		.name = "geos:2",
+		.gpio = 25,
+		.default_trigger = "default-off",
+		.active_low = 1,
+	},
+	{
+		.name = "geos:3",
+		.gpio = 27,
+		.default_trigger = "default-off",
+		.active_low = 1,
+	},
+};
+
+static struct gpio_led_platform_data geos_leds_data = {
+	.num_leds = ARRAY_SIZE(geos_leds),
+	.leds = geos_leds,
+};
+
+static struct platform_device geos_leds_dev = {
+	.name = "leds-gpio",
+	.id = -1,
+	.dev.platform_data = &geos_leds_data,
+};
+
+static struct __initdata platform_device *geos_devs[] = {
+	&geos_buttons_dev,
+	&geos_leds_dev,
+};
+
+static void __init register_geos(void)
+{
+	/* Setup LED control through leds-gpio driver */
+	platform_add_devices(geos_devs, ARRAY_SIZE(geos_devs));
+}
+
+static int __init geos_init(void)
+{
+	const char *vendor, *model;
+
+	if (!is_geode() || !coreboot_init())
+		return 0;
+
+	vendor = coreboot_vendor();
+	model = coreboot_part();
+
+	if (strcmp(vendor, "Traverse Technologies")
+	 || strcmp(model, "Geos"))
+		return 0;
+
+	printk(KERN_INFO "geos: board %s %s\n", vendor, model);
+
+	register_geos();
+
+	return 0;
+}
+
+module_init(geos_init);
+
+MODULE_AUTHOR("Philip Prindeville <philipp@redfish-solutions.com>");
+MODULE_DESCRIPTION("Traverse Technologies Geos System Setup");
+MODULE_LICENSE("GPL");
-- 
1.7.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
