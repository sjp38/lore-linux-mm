Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id E19806B005C
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 08:34:45 -0500 (EST)
From: Maxime Coquelin <maxime.coquelin@stericsson.com>
Subject: [RFCv1 6/6] PASR: Ux500: Add PASR support
Date: Mon, 30 Jan 2012 14:33:56 +0100
Message-ID: <1327930436-10263-7-git-send-email-maxime.coquelin@stericsson.com>
In-Reply-To: <1327930436-10263-1-git-send-email-maxime.coquelin@stericsson.com>
References: <1327930436-10263-1-git-send-email-maxime.coquelin@stericsson.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Mel Gorman <mel@csn.ul.ie>, Ankita Garg <ankita@in.ibm.com>
Cc: linux-kernel@vger.kernel.org, Maxime Coquelin <maxime.coquelin@stericsson.com>, linus.walleij@stericsson.com, andrea.gallo@stericsson.com, vincent.guittot@stericsson.com, philippe.langlais@stericsson.com, loic.pallardy@stericsson.com

The MR16/MR17 PASR mask registers are generally accessible through the DDR
controller. At probe time, the DDR controller driver should register the
callback used by PASR Framework to apply the refresh mask for every DDR die
using pasr_register_mask_function(die_addr, callback, cookie).

The callback passed to apply mask must not sleep since it can me called in
interrupt contexts.

This example creates a new PASR stubbed driver for Nova platforms.

Signed-off-by: Maxime Coquelin <maxime.coquelin@stericsson.com>
---
 arch/arm/Kconfig                            |    1 +
 arch/arm/mach-ux500/include/mach/hardware.h |   11 ++++
 arch/arm/mach-ux500/include/mach/memory.h   |    8 +++
 drivers/mfd/db8500-prcmu.c                  |   67 +++++++++++++++++++++++++++
 drivers/staging/pasr/Kconfig                |    5 ++
 drivers/staging/pasr/Makefile               |    1 +
 drivers/staging/pasr/ux500.c                |   58 +++++++++++++++++++++++
 include/linux/ux500-pasr.h                  |   11 ++++
 8 files changed, 162 insertions(+), 0 deletions(-)
 create mode 100644 drivers/staging/pasr/ux500.c
 create mode 100644 include/linux/ux500-pasr.h

diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index 3df3573..b8981ee 100644
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -826,6 +826,7 @@ config ARCH_U8500
 	select HAVE_CLK
 	select ARCH_HAS_CPUFREQ
 	select NOMADIK_GPIO
+	select ARCH_HAS_PASR
 	help
 	  Support for ST-Ericsson's Ux500 architecture
 
diff --git a/arch/arm/mach-ux500/include/mach/hardware.h b/arch/arm/mach-ux500/include/mach/hardware.h
index d8f218b..11c23b1 100644
--- a/arch/arm/mach-ux500/include/mach/hardware.h
+++ b/arch/arm/mach-ux500/include/mach/hardware.h
@@ -39,6 +39,17 @@
 #include <mach/db5500-regs.h>
 
 /*
+ * DDR Dies base addresses for PASR
+ */
+#define U8500_CS0_BASE_ADDR	0x00000000
+#define U8500_CS1_BASE_ADDR	0x10000000
+
+#define U9540_DDR0_CS0_BASE_ADDR 0x00000000
+#define U9540_DDR0_CS1_BASE_ADDR 0x20000000
+#define U9540_DDR1_CS0_BASE_ADDR 0xC0000000
+#define U9540_DDR1_CS1_BASE_ADDR 0xE0000000
+
+/*
  * FIFO offsets for IPs
  */
 #define MSP_TX_RX_REG_OFFSET	0
diff --git a/arch/arm/mach-ux500/include/mach/memory.h b/arch/arm/mach-ux500/include/mach/memory.h
index ada8ad0..5f5c339 100644
--- a/arch/arm/mach-ux500/include/mach/memory.h
+++ b/arch/arm/mach-ux500/include/mach/memory.h
@@ -15,6 +15,14 @@
 #define PLAT_PHYS_OFFSET	UL(0x00000000)
 #define BUS_OFFSET	UL(0x00000000)
 
+
+#ifdef CONFIG_UX500_PASR
+#define PASR_SECTION_SZ_BITS	26 /* 64MB sections */
+#define PASR_SECTION_SZ	(1 << PASR_SECTION_SZ_BITS)
+#define PASR_MAX_DIE_NR		4
+#define PASR_MAX_SECTION_NR_PER_DIE	8 /* 32 * 64MB = 2GB */
+#endif
+
 #ifdef CONFIG_UX500_SOC_DB8500
 /*
  * STE NMF CM driver only used on the U8500 allocate using dma_alloc_coherent:
diff --git a/drivers/mfd/db8500-prcmu.c b/drivers/mfd/db8500-prcmu.c
index 65a644d..db4ebd8 100644
--- a/drivers/mfd/db8500-prcmu.c
+++ b/drivers/mfd/db8500-prcmu.c
@@ -30,6 +30,7 @@
 #include <linux/mfd/dbx500-prcmu.h>
 #include <linux/regulator/db8500-prcmu.h>
 #include <linux/regulator/machine.h>
+#include <linux/ux500-pasr.h>
 #include <mach/hardware.h>
 #include <mach/irqs.h>
 #include <mach/db8500-regs.h>
@@ -105,6 +106,10 @@
 #define MB0H_CONFIG_WAKEUPS_EXE		1
 #define MB0H_READ_WAKEUP_ACK		3
 #define MB0H_CONFIG_WAKEUPS_SLEEP	4
+#define MB0H_SET_PASR_DDR0_CS0		5
+#define MB0H_SET_PASR_DDR0_CS1		6
+#define MB0H_SET_PASR_DDR1_CS0		7
+#define MB0H_SET_PASR_DDR1_CS1		8
 
 #define MB0H_WAKEUP_EXE 2
 #define MB0H_WAKEUP_SLEEP 5
@@ -116,6 +121,8 @@
 #define PRCM_REQ_MB0_DO_NOT_WFI		(PRCM_REQ_MB0 + 0x3)
 #define PRCM_REQ_MB0_WAKEUP_8500	(PRCM_REQ_MB0 + 0x4)
 #define PRCM_REQ_MB0_WAKEUP_4500	(PRCM_REQ_MB0 + 0x8)
+#define PRCM_REQ_MB0_PASR_MR16		(PRCM_REQ_MB0 + 0x0)
+#define PRCM_REQ_MB0_PASR_MR17		(PRCM_REQ_MB0 + 0x2)
 
 /* Mailbox 0 ACKs */
 #define PRCM_ACK_MB0_AP_PWRSTTR_STATUS	(PRCM_ACK_MB0 + 0x0)
@@ -3909,6 +3916,52 @@ static struct mfd_cell db8500_prcmu_devs[] = {
 	},
 };
 
+static struct ux500_pasr_data u9540_pasr_pdata[] = {
+	{
+		.base_addr = U9540_DDR0_CS0_BASE_ADDR,
+		.mailbox = MB0H_SET_PASR_DDR0_CS0,
+	},
+	{
+		.base_addr = U9540_DDR0_CS1_BASE_ADDR,
+		.mailbox = MB0H_SET_PASR_DDR0_CS1,
+	},
+	{
+		.base_addr = U9540_DDR1_CS0_BASE_ADDR,
+		.mailbox = MB0H_SET_PASR_DDR1_CS0,
+	},
+	{
+		.base_addr = U9540_DDR1_CS1_BASE_ADDR,
+		.mailbox = MB0H_SET_PASR_DDR1_CS1,
+	},
+	{
+		/*  End marker */
+		.base_addr = 0xFFFFFFFF
+	},
+};
+
+static struct ux500_pasr_data u8500_pasr_pdata[] = {
+	{
+		.base_addr = U8500_CS0_BASE_ADDR,
+		.mailbox = MB0H_SET_PASR_DDR0_CS0,
+	},
+	{
+		.base_addr = U8500_CS1_BASE_ADDR,
+		.mailbox = MB0H_SET_PASR_DDR0_CS1,
+	},
+	{
+		/*  End marker */
+		.base_addr = 0xFFFFFFFF
+	},
+};
+
+
+static struct mfd_cell ux500_pasr_devs[] = {
+	{
+		.name = "ux500-pasr",
+	},
+};
+
+
 /**
  * prcmu_fw_init - arch init call for the Linux PRCMU fw init logic
  *
@@ -3951,6 +4004,20 @@ static int __init db8500_prcmu_probe(struct platform_device *pdev)
 	else
 		pr_info("DB8500 PRCMU initialized\n");
 
+	if (cpu_is_u9540()) {
+		ux500_pasr_devs[0].platform_data = u9540_pasr_pdata;
+		ux500_pasr_devs[0].pdata_size = sizeof(u9540_pasr_pdata);
+	} else {
+		ux500_pasr_devs[0].platform_data = u8500_pasr_pdata;
+		ux500_pasr_devs[0].pdata_size = sizeof(u8500_pasr_pdata);
+	}
+
+	err = mfd_add_devices(&pdev->dev, 0, ux500_pasr_devs,
+			      ARRAY_SIZE(ux500_pasr_devs), NULL,
+			      0);
+	if (err)
+		pr_err("prcmu: Failed to add PASR subdevice\n");
+
 	/*
 	 * Temporary U9540 bringup code - Enable all clock gates.
 	 * Write 1 to all bits of PRCM_YYCLKEN0_MGT_SET and
diff --git a/drivers/staging/pasr/Kconfig b/drivers/staging/pasr/Kconfig
index 6bd2421..b8145e0 100644
--- a/drivers/staging/pasr/Kconfig
+++ b/drivers/staging/pasr/Kconfig
@@ -12,3 +12,8 @@ config PASR_DEBUG
 	bool "Add PASR debug prints"
 	def_bool n
 	depends on PASR
+
+config UX500_PASR
+	bool "Ux500 Family PASR driver"
+	def_bool n
+	depends on (PASR && UX500_SOC_DB8500)
diff --git a/drivers/staging/pasr/Makefile b/drivers/staging/pasr/Makefile
index d172294..0b18a79 100644
--- a/drivers/staging/pasr/Makefile
+++ b/drivers/staging/pasr/Makefile
@@ -1,5 +1,6 @@
 pasr-objs := helper.o init.o core.o
 
 obj-$(CONFIG_PASR) += pasr.o
+obj-$(CONFIG_UX500_PASR) += ux500.o
 
 ccflags-$(CONFIG_PASR_DEBUG) := -DDEBUG
diff --git a/drivers/staging/pasr/ux500.c b/drivers/staging/pasr/ux500.c
new file mode 100644
index 0000000..ce5df0c
--- /dev/null
+++ b/drivers/staging/pasr/ux500.c
@@ -0,0 +1,58 @@
+/*
+ * Copyright (C) ST-Ericsson SA 2012
+ * Author: Maxime Coquelin <maxime.coquelin@stericsson.com> for ST-Ericsson.
+ * License terms:  GNU General Public License (GPL), version 2
+ */
+#include <linux/module.h>
+#include <linux/platform_device.h>
+#include <linux/mfd/dbx500-prcmu.h>
+#include <linux/pasr.h>
+#include <linux/ux500-pasr.h>
+
+
+static void ux500_pasr_apply_mask(u16 *mem_reg, void *cookie)
+{
+	printk(KERN_INFO"%s: cookie = %d, mem_reg = 0x%04x\n",
+			__func__, (int)cookie, *mem_reg);
+}
+
+static int ux500_pasr_probe(struct platform_device *pdev)
+{
+	int i;
+	struct ux500_pasr_data *pasr_data = dev_get_platdata(&pdev->dev);
+
+	if (!pasr_data)
+		return -ENODEV;
+
+	for (i = 0; pasr_data[i].base_addr != 0xFFFFFFFF; i++) {
+		phys_addr_t base = pasr_data[i].base_addr;
+
+		/*
+		 * We don't have specific structure pointer to pass, but only
+		 * DDR die channel in PRCMU. This may change in future
+		 * version.
+		 */
+		void *cookie = (void *)(int)pasr_data[i].mailbox;
+
+		if (pasr_register_mask_function(base,
+				&ux500_pasr_apply_mask,
+				cookie))
+			printk(KERN_ERR"Pasr register failed\n");
+	}
+
+	return 0;
+}
+
+static struct platform_driver ux500_pasr_driver = {
+	.probe = ux500_pasr_probe,
+	.driver = {
+		.name = "ux500-pasr",
+		.owner = THIS_MODULE,
+	},
+};
+
+static int __init ux500_pasr_init(void)
+{
+	return platform_driver_register(&ux500_pasr_driver);
+}
+module_init(ux500_pasr_init);
diff --git a/include/linux/ux500-pasr.h b/include/linux/ux500-pasr.h
new file mode 100644
index 0000000..c62d961
--- /dev/null
+++ b/include/linux/ux500-pasr.h
@@ -0,0 +1,11 @@
+/*
+ * Copyright (C) ST-Ericsson SA 2012
+ * Author: Maxime Coquelin <maxime.coquelin@stericsson.com> for ST-Ericsson.
+ * License terms:  GNU General Public License (GPL), version 2
+ */
+
+struct ux500_pasr_data {
+	phys_addr_t base_addr;
+	u8 mailbox;
+};
+
-- 
1.7.8

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
