Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1627C82F66
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 19:27:45 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id ez1so233417829pab.1
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 16:27:45 -0700 (PDT)
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (mail-co1nam03on0050.outbound.protection.outlook.com. [104.47.40.50])
        by mx.google.com with ESMTPS id y24si517802pff.12.2016.08.22.16.27.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 22 Aug 2016 16:27:42 -0700 (PDT)
Subject: [RFC PATCH v1 18/28] crypto: add AMD Platform Security Processor
 driver
From: Brijesh Singh <brijesh.singh@amd.com>
Date: Mon, 22 Aug 2016 19:27:22 -0400
Message-ID: <147190844204.9523.14931918358168729826.stgit@brijesh-build-machine>
In-Reply-To: <147190820782.9523.4967724730957229273.stgit@brijesh-build-machine>
References: <147190820782.9523.4967724730957229273.stgit@brijesh-build-machine>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: simon.guinot@sequanux.org, linux-efi@vger.kernel.org, brijesh.singh@amd.com, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linus.walleij@linaro.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, bp@suse.de, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, devel@linuxdriverproject.org, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, linux-crypto@vger.kernel.org, pbonzini@redhat.com, akpm@linux-foundation.org, davem@davemloft.net

The driver to communicate with Secure Encrypted Virtualization (SEV)
firmware running within the AMD secure processor providing a secure key
management interface for SEV guests.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
Signed-off-by: Brijesh Singh <brijesh.singh@amd.com>
---
 drivers/crypto/Kconfig       |   11 +
 drivers/crypto/Makefile      |    1 
 drivers/crypto/psp/Kconfig   |    8 
 drivers/crypto/psp/Makefile  |    3 
 drivers/crypto/psp/psp-dev.c |  220 +++++++++++
 drivers/crypto/psp/psp-dev.h |   95 +++++
 drivers/crypto/psp/psp-ops.c |  454 +++++++++++++++++++++++
 drivers/crypto/psp/psp-pci.c |  376 +++++++++++++++++++
 include/linux/ccp-psp.h      |  833 ++++++++++++++++++++++++++++++++++++++++++
 include/uapi/linux/Kbuild    |    1 
 include/uapi/linux/ccp-psp.h |  182 +++++++++
 11 files changed, 2184 insertions(+)
 create mode 100644 drivers/crypto/psp/Kconfig
 create mode 100644 drivers/crypto/psp/Makefile
 create mode 100644 drivers/crypto/psp/psp-dev.c
 create mode 100644 drivers/crypto/psp/psp-dev.h
 create mode 100644 drivers/crypto/psp/psp-ops.c
 create mode 100644 drivers/crypto/psp/psp-pci.c
 create mode 100644 include/linux/ccp-psp.h
 create mode 100644 include/uapi/linux/ccp-psp.h

diff --git a/drivers/crypto/Kconfig b/drivers/crypto/Kconfig
index 1af94e2..3bdbc51 100644
--- a/drivers/crypto/Kconfig
+++ b/drivers/crypto/Kconfig
@@ -464,6 +464,17 @@ if CRYPTO_DEV_CCP
 	source "drivers/crypto/ccp/Kconfig"
 endif
 
+config CRYPTO_DEV_PSP
+	bool "Support for AMD Platform Security Processor"
+	depends on X86 && PCI
+	help
+	  The AMD Platform Security Processor provides hardware key-
+	  management services for VMGuard encrypted memory.
+
+if CRYPTO_DEV_PSP
+	source "drivers/crypto/psp/Kconfig"
+endif
+
 config CRYPTO_DEV_MXS_DCP
 	tristate "Support for Freescale MXS DCP"
 	depends on (ARCH_MXS || ARCH_MXC)
diff --git a/drivers/crypto/Makefile b/drivers/crypto/Makefile
index 3c6432d..1ea1e08 100644
--- a/drivers/crypto/Makefile
+++ b/drivers/crypto/Makefile
@@ -3,6 +3,7 @@ obj-$(CONFIG_CRYPTO_DEV_ATMEL_SHA) += atmel-sha.o
 obj-$(CONFIG_CRYPTO_DEV_ATMEL_TDES) += atmel-tdes.o
 obj-$(CONFIG_CRYPTO_DEV_BFIN_CRC) += bfin_crc.o
 obj-$(CONFIG_CRYPTO_DEV_CCP) += ccp/
+obj-$(CONFIG_CRYPTO_DEV_PSP) += psp/
 obj-$(CONFIG_CRYPTO_DEV_FSL_CAAM) += caam/
 obj-$(CONFIG_CRYPTO_DEV_GEODE) += geode-aes.o
 obj-$(CONFIG_CRYPTO_DEV_HIFN_795X) += hifn_795x.o
diff --git a/drivers/crypto/psp/Kconfig b/drivers/crypto/psp/Kconfig
new file mode 100644
index 0000000..acd9b87
--- /dev/null
+++ b/drivers/crypto/psp/Kconfig
@@ -0,0 +1,8 @@
+config CRYPTO_DEV_PSP_DD
+	tristate "PSP Key Management device driver"
+	depends on CRYPTO_DEV_PSP
+	default m
+	help
+	  Provides the interface to use the AMD PSP key management APIs
+	  for use with the AMD Secure Enhanced Virtualization. If you
+	  choose 'M' here, this module will be called psp.
diff --git a/drivers/crypto/psp/Makefile b/drivers/crypto/psp/Makefile
new file mode 100644
index 0000000..1b7d00c
--- /dev/null
+++ b/drivers/crypto/psp/Makefile
@@ -0,0 +1,3 @@
+obj-$(CONFIG_CRYPTO_DEV_PSP_DD) += psp.o
+psp-objs := psp-dev.o psp-ops.o
+psp-$(CONFIG_PCI) += psp-pci.o
diff --git a/drivers/crypto/psp/psp-dev.c b/drivers/crypto/psp/psp-dev.c
new file mode 100644
index 0000000..65d5c7e
--- /dev/null
+++ b/drivers/crypto/psp/psp-dev.c
@@ -0,0 +1,220 @@
+/*
+ * AMD Cryptographic Coprocessor (CCP) driver
+ *
+ * Copyright (C) 2016 Advanced Micro Devices, Inc.
+ *
+ * Author: Tom Lendacky <thomas.lendacky@amd.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/interrupt.h>
+#include <linux/dma-mapping.h>
+#include <linux/string.h>
+#include <linux/wait.h>
+
+#include "psp-dev.h"
+
+MODULE_AUTHOR("Advanced Micro Devices, Inc.");
+MODULE_LICENSE("GPL");
+MODULE_VERSION("0.1.0");
+MODULE_DESCRIPTION("AMD VMGuard key-management driver prototype");
+
+static struct psp_device *psp_master;
+
+static LIST_HEAD(psp_devs);
+static DEFINE_SPINLOCK(psp_devs_lock);
+
+static atomic_t psp_id;
+
+static void psp_add_device(struct psp_device *psp)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&psp_devs_lock, flags);
+
+	list_add_tail(&psp->entry, &psp_devs);
+	psp_master = psp->get_master(&psp_devs);
+
+	spin_unlock_irqrestore(&psp_devs_lock, flags);
+}
+
+static void psp_del_device(struct psp_device *psp)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&psp_devs_lock, flags);
+
+	list_del(&psp->entry);
+	if (psp == psp_master)
+		psp_master = NULL;
+
+	spin_unlock_irqrestore(&psp_devs_lock, flags);
+}
+
+static void psp_check_support(struct psp_device *psp)
+{
+	if (ioread32(psp->io_regs + PSP_CMDRESP))
+		psp->sev_enabled = 1;
+}
+
+/**
+ * psp_get_master_device - returns a pointer to the PSP master device structure
+ *
+ * Returns NULL if a PSP master device is not present, PSP device structure
+ * otherwise.
+ */
+struct psp_device *psp_get_master_device(void)
+{
+	return psp_master;
+}
+EXPORT_SYMBOL_GPL(psp_get_master_device);
+
+/**
+ * psp_get_device - returns a pointer to the PSP device structure
+ *
+ * Returns NULL if a PSP device is not present, PSP device structure otherwise.
+ */
+struct psp_device *psp_get_device(void)
+{
+	struct psp_device *psp = NULL;
+	unsigned long flags;
+
+	spin_lock_irqsave(&psp_devs_lock, flags);
+
+	if (list_empty(&psp_devs))
+		goto unlock;
+
+	psp = list_first_entry(&psp_devs, struct psp_device, entry);
+
+unlock:
+	spin_unlock_irqrestore(&psp_devs_lock, flags);
+
+	return psp;
+}
+EXPORT_SYMBOL_GPL(psp_get_device);
+
+/**
+ * psp_alloc_struct - allocate and initialize the psp_device struct
+ *
+ * @dev: device struct of the PSP
+ */
+struct psp_device *psp_alloc_struct(struct device *dev)
+{
+	struct psp_device *psp;
+
+	psp = devm_kzalloc(dev, sizeof(*psp), GFP_KERNEL);
+	if (psp == NULL) {
+		dev_err(dev, "unable to allocate device struct\n");
+		return NULL;
+	}
+	psp->dev = dev;
+
+	psp->id = atomic_inc_return(&psp_id);
+	snprintf(psp->name, sizeof(psp->name), "psp%u", psp->id);
+
+	init_waitqueue_head(&psp->int_queue);
+
+	return psp;
+}
+
+/**
+ * psp_init - initialize the PSP device
+ *
+ * @psp: psp_device struct
+ */
+int psp_init(struct psp_device *psp)
+{
+	int ret;
+
+	psp_check_support(psp);
+
+	/* Disable and clear interrupts until ready */
+	iowrite32(0, psp->io_regs + PSP_P2CMSG_INTEN);
+	iowrite32(0xffffffff, psp->io_regs + PSP_P2CMSG_INTSTS);
+
+	/* Request an irq */
+	ret = psp->get_irq(psp);
+	if (ret) {
+		dev_err(psp->dev, "unable to allocate IRQ\n");
+		return ret;
+	}
+
+	/* Make the device struct available */
+	psp_add_device(psp);
+
+	/* Enable interrupts */
+	iowrite32(1 << PSP_CMD_COMPLETE_REG, psp->io_regs + PSP_P2CMSG_INTEN);
+
+	ret = psp_ops_init(psp);
+	if (ret)
+		dev_err(psp->dev, "psp_ops_init returned %d\n", ret);
+
+	return 0;
+}
+
+/**
+ * psp_destroy - tear down the PSP device
+ *
+ * @psp: psp_device struct
+ */
+void psp_destroy(struct psp_device *psp)
+{
+	psp_ops_exit(psp);
+
+	/* Remove general access to the device struct */
+	psp_del_device(psp);
+
+	psp->free_irq(psp);
+}
+
+/**
+ * psp_irq_handler - handle interrupts generated by the PSP device
+ *
+ * @irq: the irq associated with the interrupt
+ * @data: the data value supplied when the irq was created
+ */
+irqreturn_t psp_irq_handler(int irq, void *data)
+{
+	struct device *dev = data;
+	struct psp_device *psp = dev_get_drvdata(dev);
+	unsigned int status;
+
+	status = ioread32(psp->io_regs + PSP_P2CMSG_INTSTS);
+	if (status & (1 << PSP_CMD_COMPLETE_REG)) {
+		int reg;
+
+		reg = ioread32(psp->io_regs + PSP_CMDRESP);
+		if (reg & PSP_CMDRESP_RESP) {
+			psp->int_rcvd = 1;
+			wake_up_interruptible(&psp->int_queue);
+		}
+	}
+
+	iowrite32(status, psp->io_regs + PSP_P2CMSG_INTSTS);
+
+	return IRQ_HANDLED;
+}
+
+static int __init psp_mod_init(void)
+{
+	int ret;
+
+	ret = psp_pci_init();
+	if (ret)
+		return ret;
+
+	return 0;
+}
+module_init(psp_mod_init);
+
+static void __exit psp_mod_exit(void)
+{
+	psp_pci_exit();
+}
+module_exit(psp_mod_exit);
diff --git a/drivers/crypto/psp/psp-dev.h b/drivers/crypto/psp/psp-dev.h
new file mode 100644
index 0000000..bb75ca2
--- /dev/null
+++ b/drivers/crypto/psp/psp-dev.h
@@ -0,0 +1,95 @@
+
+#ifndef __PSP_DEV_H__
+#define __PSP_DEV_H__
+
+#include <linux/device.h>
+#include <linux/pci.h>
+#include <linux/spinlock.h>
+#include <linux/mutex.h>
+#include <linux/list.h>
+#include <linux/wait.h>
+#include <linux/dmapool.h>
+#include <linux/hw_random.h>
+#include <linux/interrupt.h>
+#include <linux/miscdevice.h>
+
+#define PSP_P2CMSG_INTEN		0x0110
+#define PSP_P2CMSG_INTSTS		0x0114
+
+#define PSP_C2PMSG_ATTR_0		0x0118
+#define PSP_C2PMSG_ATTR_1		0x011c
+#define PSP_C2PMSG_ATTR_2		0x0120
+#define PSP_C2PMSG_ATTR_3		0x0124
+#define PSP_P2CMSG_ATTR_0		0x0128
+
+#define PSP_C2PMSG(_num)		((_num) << 2)
+#define PSP_CMDRESP			PSP_C2PMSG(32)
+#define PSP_CMDBUFF_ADDR_LO		PSP_C2PMSG(56)
+#define PSP_CMDBUFF_ADDR_HI 		PSP_C2PMSG(57)
+
+#define PSP_P2CMSG(_num)		(_num << 2)
+#define PSP_CMD_COMPLETE_REG		1
+#define PSP_CMD_COMPLETE		PSP_P2CMSG(PSP_CMD_COMPLETE_REG)
+
+#define PSP_CMDRESP_CMD_SHIFT		16
+#define PSP_CMDRESP_IOC			BIT(0)
+#define PSP_CMDRESP_RESP		BIT(31)
+#define PSP_CMDRESP_ERR_MASK		0xffff
+
+#define PSP_DRIVER_NAME			"psp"
+
+struct psp_device {
+	struct list_head entry;
+
+	struct device *dev;
+
+	unsigned int id;
+	char name[32];
+
+	struct dentry *debugfs;
+	struct miscdevice misc;
+
+	unsigned int sev_enabled;
+
+	/*
+	 * Bus-specific device information
+	 */
+	void *dev_specific;
+	int (*get_irq)(struct psp_device *);
+	void (*free_irq)(struct psp_device *);
+	unsigned int irq;
+	struct psp_device *(*get_master)(struct list_head *list);
+
+	/*
+	 * I/O area used for device communication. Writing to the
+	 * mailbox registers generates an interrupt on the PSP.
+	 */
+	void __iomem *io_map;
+	void __iomem *io_regs;
+
+	/* Interrupt wait queue */
+	wait_queue_head_t int_queue;
+	unsigned int int_rcvd;
+};
+
+struct psp_device *psp_get_master_device(void);
+struct psp_device *psp_get_device(void);
+
+#ifdef CONFIG_PCI
+int psp_pci_init(void);
+void psp_pci_exit(void);
+#else
+static inline int psp_pci_init(void) { return 0; }
+static inline void psp_pci_exit(void) { }
+#endif
+
+struct psp_device *psp_alloc_struct(struct device *dev);
+int psp_init(struct psp_device *psp);
+void psp_destroy(struct psp_device *psp);
+
+int psp_ops_init(struct psp_device *psp);
+void psp_ops_exit(struct psp_device *psp);
+
+irqreturn_t psp_irq_handler(int irq, void *data);
+
+#endif /* PSP_DEV_H */
diff --git a/drivers/crypto/psp/psp-ops.c b/drivers/crypto/psp/psp-ops.c
new file mode 100644
index 0000000..81e8dc8
--- /dev/null
+++ b/drivers/crypto/psp/psp-ops.c
@@ -0,0 +1,454 @@
+
+#include <linux/module.h>
+#include <linux/fs.h>
+#include <linux/miscdevice.h>
+#include <linux/delay.h>
+#include <linux/jiffies.h>
+#include <linux/wait.h>
+#include <linux/mutex.h>
+#include <linux/ccp-psp.h>
+
+#include "psp-dev.h"
+
+static unsigned int psp_poll = 0;
+module_param(psp_poll, uint, 0444);
+MODULE_PARM_DESC(psp_poll, "Poll for command completion - any non-zero value");
+
+#define PSP_DEFAULT_TIMEOUT	2
+
+DEFINE_MUTEX(psp_cmd_mutex);
+
+static int psp_wait_cmd_poll(struct psp_device *psp, unsigned int timeout,
+			     unsigned int *reg)
+{
+	int wait = timeout * 10;	/* 100ms sleep => timeout * 10 */
+
+	while (--wait) {
+		msleep(100);
+
+		*reg = ioread32(psp->io_regs + PSP_CMDRESP);
+		if (*reg & PSP_CMDRESP_RESP)
+			break;
+	}
+
+	if (!wait) {
+		dev_err(psp->dev, "psp command timed out\n");
+		return -ETIMEDOUT;
+	}
+
+	return 0;
+}
+
+static int psp_wait_cmd_ioc(struct psp_device *psp, unsigned int timeout,
+			    unsigned int *reg)
+{
+	unsigned long jiffie_timeout = timeout;
+	long ret;
+
+	jiffie_timeout *= HZ;
+
+	ret = wait_event_interruptible_timeout(psp->int_queue, psp->int_rcvd,
+					       jiffie_timeout);
+	if (ret <= 0) {
+		dev_err(psp->dev, "psp command timed out\n");
+		return -ETIMEDOUT;
+	}
+
+	psp->int_rcvd = 0;
+
+	*reg = ioread32(psp->io_regs + PSP_CMDRESP);
+
+	return 0;
+}
+
+static int psp_wait_cmd(struct psp_device *psp, unsigned int timeout,
+			unsigned int *reg)
+{
+	return (*reg & PSP_CMDRESP_IOC) ? psp_wait_cmd_ioc(psp, timeout, reg)
+					: psp_wait_cmd_poll(psp, timeout, reg);
+}
+
+static int psp_issue_cmd(enum psp_cmd cmd, void *data, unsigned int timeout,
+			 int *psp_ret)
+{
+	struct psp_device *psp = psp_get_master_device();
+	unsigned int phys_lsb, phys_msb;
+	unsigned int reg, ret;
+
+	if (psp_ret)
+		*psp_ret = 0;
+
+	if (!psp)
+		return -ENODEV;
+
+	if (!psp->sev_enabled)
+		return -ENOTSUPP;
+
+	/* Set the physical address for the PSP */
+	phys_lsb = data ? lower_32_bits(__psp_pa(data)) : 0;
+	phys_msb = data ? upper_32_bits(__psp_pa(data)) : 0;
+
+	/* Only one command at a time... */
+	mutex_lock(&psp_cmd_mutex);
+
+	iowrite32(phys_lsb, psp->io_regs + PSP_CMDBUFF_ADDR_LO);
+	iowrite32(phys_msb, psp->io_regs + PSP_CMDBUFF_ADDR_HI);
+	wmb();
+
+	reg = cmd;
+	reg <<= PSP_CMDRESP_CMD_SHIFT;
+	reg |= psp_poll ? 0 : PSP_CMDRESP_IOC;
+	iowrite32(reg, psp->io_regs + PSP_CMDRESP);
+
+	ret = psp_wait_cmd(psp, timeout, &reg);
+	if (ret)
+		goto unlock;
+
+	if (psp_ret)
+		*psp_ret = reg & PSP_CMDRESP_ERR_MASK;
+
+	if (reg & PSP_CMDRESP_ERR_MASK) {
+		dev_err(psp->dev, "psp command %u failed (%#010x)\n", cmd, reg & PSP_CMDRESP_ERR_MASK);
+		ret = -EIO;
+	}
+
+unlock:
+	mutex_unlock(&psp_cmd_mutex);
+
+	return ret;
+}
+
+int psp_platform_init(struct psp_data_init *data, int *psp_ret)
+{
+	return psp_issue_cmd(PSP_CMD_INIT, data, PSP_DEFAULT_TIMEOUT,
+			     psp_ret);
+}
+EXPORT_SYMBOL_GPL(psp_platform_init);
+
+int psp_platform_shutdown(int *psp_ret)
+{
+	return psp_issue_cmd(PSP_CMD_SHUTDOWN, NULL, PSP_DEFAULT_TIMEOUT,
+			     psp_ret);
+}
+EXPORT_SYMBOL_GPL(psp_platform_shutdown);
+
+int psp_platform_status(struct psp_data_status *data, int *psp_ret)
+{
+	return psp_issue_cmd(PSP_CMD_PLATFORM_STATUS, data,
+			     PSP_DEFAULT_TIMEOUT, psp_ret);
+}
+EXPORT_SYMBOL_GPL(psp_platform_status);
+
+int psp_guest_launch_start(struct psp_data_launch_start *data, int *psp_ret)
+{
+	return psp_issue_cmd(PSP_CMD_LAUNCH_START, data, PSP_DEFAULT_TIMEOUT,
+			     psp_ret);
+}
+EXPORT_SYMBOL_GPL(psp_guest_launch_start);
+
+int psp_guest_launch_update(struct psp_data_launch_update *data,
+			    unsigned int timeout, int *psp_ret)
+{
+	return psp_issue_cmd(PSP_CMD_LAUNCH_UPDATE, data, timeout, psp_ret);
+}
+EXPORT_SYMBOL_GPL(psp_guest_launch_update);
+
+int psp_guest_launch_finish(struct psp_data_launch_finish *data, int *psp_ret)
+{
+	return psp_issue_cmd(PSP_CMD_LAUNCH_FINISH, data, PSP_DEFAULT_TIMEOUT,
+			     psp_ret);
+}
+EXPORT_SYMBOL_GPL(psp_guest_launch_finish);
+
+int psp_guest_activate(struct psp_data_activate *data, int *psp_ret)
+{
+	return psp_issue_cmd(PSP_CMD_ACTIVATE, data, PSP_DEFAULT_TIMEOUT,
+			     psp_ret);
+}
+EXPORT_SYMBOL_GPL(psp_guest_activate);
+
+int psp_guest_deactivate(struct psp_data_deactivate *data, int *psp_ret)
+{
+	return psp_issue_cmd(PSP_CMD_DEACTIVATE, data, PSP_DEFAULT_TIMEOUT,
+			     psp_ret);
+}
+EXPORT_SYMBOL_GPL(psp_guest_deactivate);
+
+int psp_guest_df_flush(int *psp_ret)
+{
+	return psp_issue_cmd(PSP_CMD_DF_FLUSH, NULL, PSP_DEFAULT_TIMEOUT,
+			     psp_ret);
+}
+EXPORT_SYMBOL_GPL(psp_guest_df_flush);
+
+int psp_guest_decommission(struct psp_data_decommission *data, int *psp_ret)
+{
+	return psp_issue_cmd(PSP_CMD_DECOMMISSION, data, PSP_DEFAULT_TIMEOUT,
+			     psp_ret);
+}
+EXPORT_SYMBOL_GPL(psp_guest_decommission);
+
+int psp_guest_status(struct psp_data_guest_status *data, int *psp_ret)
+{
+	return psp_issue_cmd(PSP_CMD_GUEST_STATUS, data, PSP_DEFAULT_TIMEOUT,
+			     psp_ret);
+}
+EXPORT_SYMBOL_GPL(psp_guest_status);
+
+int psp_dbg_decrypt(struct psp_data_dbg *data, int *psp_ret)
+{
+	return psp_issue_cmd(PSP_CMD_DBG_DECRYPT, data, PSP_DEFAULT_TIMEOUT,
+			     psp_ret);
+}
+EXPORT_SYMBOL_GPL(psp_dbg_decrypt);
+
+int psp_dbg_encrypt(struct psp_data_dbg *data, int *psp_ret)
+{
+	return psp_issue_cmd(PSP_CMD_DBG_ENCRYPT, data, PSP_DEFAULT_TIMEOUT,
+			     psp_ret);
+}
+EXPORT_SYMBOL_GPL(psp_dbg_encrypt);
+
+int psp_guest_receive_start(struct psp_data_receive_start *data, int *psp_ret)
+{
+	return psp_issue_cmd(PSP_CMD_RECEIVE_START, data, PSP_DEFAULT_TIMEOUT,
+			     psp_ret);
+}
+EXPORT_SYMBOL_GPL(psp_guest_receive_start);
+
+int psp_guest_receive_update(struct psp_data_receive_update *data,
+			    unsigned int timeout, int *psp_ret)
+{
+	return psp_issue_cmd(PSP_CMD_RECEIVE_UPDATE, data, timeout, psp_ret);
+}
+EXPORT_SYMBOL_GPL(psp_guest_receive_update);
+
+int psp_guest_receive_finish(struct psp_data_receive_finish *data, int *psp_ret)
+{
+	return psp_issue_cmd(PSP_CMD_RECEIVE_FINISH, data, PSP_DEFAULT_TIMEOUT,
+			     psp_ret);
+}
+EXPORT_SYMBOL_GPL(psp_guest_receive_finish);
+
+int psp_guest_send_start(struct psp_data_send_start *data, int *psp_ret)
+{
+	return psp_issue_cmd(PSP_CMD_SEND_START, data, PSP_DEFAULT_TIMEOUT,
+			     psp_ret);
+}
+EXPORT_SYMBOL_GPL(psp_guest_send_start);
+
+int psp_guest_send_update(struct psp_data_send_update *data,
+			    unsigned int timeout, int *psp_ret)
+{
+	return psp_issue_cmd(PSP_CMD_SEND_UPDATE, data, timeout, psp_ret);
+}
+EXPORT_SYMBOL_GPL(psp_guest_send_update);
+
+int psp_guest_send_finish(struct psp_data_send_finish *data, int *psp_ret)
+{
+	return psp_issue_cmd(PSP_CMD_SEND_FINISH, data, PSP_DEFAULT_TIMEOUT,
+			     psp_ret);
+}
+EXPORT_SYMBOL_GPL(psp_guest_send_finish);
+
+int psp_platform_pdh_gen(int *psp_ret)
+{
+	return psp_issue_cmd(PSP_CMD_PDH_GEN, NULL, PSP_DEFAULT_TIMEOUT,
+			     psp_ret);
+}
+EXPORT_SYMBOL_GPL(psp_platform_pdh_gen);
+
+int psp_platform_pdh_cert_export(struct psp_data_pdh_cert_export *data,
+				int *psp_ret)
+{
+	return psp_issue_cmd(PSP_CMD_PDH_CERT_EXPORT, data, PSP_DEFAULT_TIMEOUT,
+			     psp_ret);
+}
+EXPORT_SYMBOL_GPL(psp_platform_pdh_cert_export);
+
+int psp_platform_pek_gen(int *psp_ret)
+{
+	return psp_issue_cmd(PSP_CMD_PEK_GEN, NULL, PSP_DEFAULT_TIMEOUT,
+			     psp_ret);
+}
+EXPORT_SYMBOL_GPL(psp_platform_pek_gen);
+
+int psp_platform_pek_cert_import(struct psp_data_pek_cert_import *data,
+				 int *psp_ret)
+{
+	return psp_issue_cmd(PSP_CMD_PEK_CERT_IMPORT, data, PSP_DEFAULT_TIMEOUT,
+			     psp_ret);
+}
+EXPORT_SYMBOL_GPL(psp_platform_pek_cert_import);
+
+int psp_platform_pek_csr(struct psp_data_pek_csr *data, int *psp_ret)
+{
+	return psp_issue_cmd(PSP_CMD_PEK_CSR, data, PSP_DEFAULT_TIMEOUT,
+			     psp_ret);
+}
+EXPORT_SYMBOL_GPL(psp_platform_pek_csr);
+
+int psp_platform_factory_reset(int *psp_ret)
+{
+	return psp_issue_cmd(PSP_CMD_FACTORY_RESET, NULL, PSP_DEFAULT_TIMEOUT,
+			     psp_ret);
+}
+EXPORT_SYMBOL_GPL(psp_platform_factory_reset);
+
+static int psp_copy_to_user(void __user *argp, void *data, size_t size)
+{
+	int ret = 0;
+
+	if (copy_to_user(argp, data, size))
+		ret = -EFAULT;
+	free_pages_exact(data, size);
+
+	return ret;
+}
+
+static void *psp_copy_from_user(void __user *argp, size_t *size)
+{
+	u32 buffer_len;
+	void *data;
+
+	if (copy_from_user(&buffer_len, argp, sizeof(buffer_len)))
+		return ERR_PTR(-EFAULT);
+
+	data = alloc_pages_exact(buffer_len, GFP_KERNEL | __GFP_ZERO);
+	if (!data)
+		return ERR_PTR(-ENOMEM);
+	*size = buffer_len;
+
+	if (copy_from_user(data, argp, buffer_len)) {
+		free_pages_exact(data, *size);
+		return ERR_PTR(-EFAULT);
+	}
+
+	return data;
+}
+
+static long psp_ioctl(struct file *file, unsigned int ioctl, unsigned long arg)
+{
+	int ret = -EFAULT;
+	void *data = NULL;
+	size_t buffer_len = 0;
+	void __user *argp = (void __user *)arg;
+	struct psp_issue_cmd input;
+
+	if (ioctl != PSP_ISSUE_CMD)
+		return -EINVAL;
+
+	/* get input parameters */
+	if (copy_from_user(&input, argp, sizeof(struct psp_issue_cmd)))
+	       return -EFAULT;
+
+	if (input.cmd > PSP_CMD_MAX)
+		return -EINVAL;
+
+	switch (input.cmd) {
+
+	case PSP_CMD_INIT: {
+		struct psp_data_init *init;
+
+		data = psp_copy_from_user((void*)input.opaque, &buffer_len);
+		if (IS_ERR(data))
+			break;
+
+		init = data;
+		ret = psp_platform_init(init, &input.psp_ret);
+		break;
+	}
+	case PSP_CMD_SHUTDOWN: {
+		ret = psp_platform_shutdown(&input.psp_ret);
+		break;
+	}
+	case PSP_CMD_FACTORY_RESET: {
+		ret = psp_platform_factory_reset(&input.psp_ret);
+		break;
+	}
+	case PSP_CMD_PLATFORM_STATUS: {
+		struct psp_data_status *status;
+
+		data = psp_copy_from_user((void*)input.opaque, &buffer_len);
+		if (IS_ERR(data))
+			break;
+
+		status = data;
+		ret = psp_platform_status(status, &input.psp_ret);
+		break;
+	}
+	case PSP_CMD_PEK_GEN: {
+		ret = psp_platform_pek_gen(&input.psp_ret);
+		break;
+	}
+	case PSP_CMD_PEK_CSR: {
+		struct psp_data_pek_csr *pek_csr;
+
+		data = psp_copy_from_user((void*)input.opaque, &buffer_len);
+		if (IS_ERR(data))
+			break;
+
+		pek_csr = data;
+		ret = psp_platform_pek_csr(pek_csr, &input.psp_ret);
+		break;
+	}
+	case PSP_CMD_PEK_CERT_IMPORT: {
+		struct psp_data_pek_cert_import *import;
+
+		data = psp_copy_from_user((void*)input.opaque, &buffer_len);
+		if (IS_ERR(data))
+			break;
+
+		import = data;
+		ret = psp_platform_pek_cert_import(import, &input.psp_ret);
+		break;
+	}
+	case PSP_CMD_PDH_GEN: {
+		ret = psp_platform_pdh_gen(&input.psp_ret);
+		break;
+	}
+	case PSP_CMD_PDH_CERT_EXPORT: {
+		struct psp_data_pdh_cert_export *export;
+
+		data = psp_copy_from_user((void*)input.opaque, &buffer_len);
+		if (IS_ERR(data))
+			break;
+
+		export = data;
+		ret = psp_platform_pdh_cert_export(export, &input.psp_ret);
+		break;
+	}
+	default:
+		ret = -EINVAL;
+	}
+
+	if (data && psp_copy_to_user((void *)input.opaque,
+				data, buffer_len))
+		ret = -EFAULT;
+
+	if (copy_to_user(argp, &input, sizeof(struct psp_issue_cmd)))
+		ret = -EFAULT;
+
+	return ret;
+}
+
+static const struct file_operations fops = {
+	.owner = THIS_MODULE,
+	.unlocked_ioctl = psp_ioctl,
+};
+
+int psp_ops_init(struct psp_device *psp)
+{
+	struct miscdevice *misc = &psp->misc;
+
+	misc->minor = MISC_DYNAMIC_MINOR;
+	misc->name = psp->name;
+	misc->fops = &fops;
+
+	return misc_register(misc);
+}
+
+void psp_ops_exit(struct psp_device *psp)
+{
+	misc_deregister(&psp->misc);
+}
diff --git a/drivers/crypto/psp/psp-pci.c b/drivers/crypto/psp/psp-pci.c
new file mode 100644
index 0000000..2b4c379
--- /dev/null
+++ b/drivers/crypto/psp/psp-pci.c
@@ -0,0 +1,376 @@
+/*
+ * AMD Cryptographic Coprocessor (CCP) driver
+ *
+ * Copyright (C) 2016 Advanced Micro Devices, Inc.
+ *
+ * Author: Tom Lendacky <thomas.lendacky@amd.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/device.h>
+#include <linux/pci.h>
+#include <linux/pci_ids.h>
+#include <linux/dma-mapping.h>
+#include <linux/sched.h>
+#include <linux/interrupt.h>
+
+#include "psp-dev.h"
+
+#define IO_BAR				2
+#define IO_OFFSET			0x10500
+
+#define MSIX_VECTORS			2
+
+struct psp_msix {
+	u32 vector;
+	char name[16];
+};
+
+struct psp_pci {
+	struct pci_dev *pdev;
+	int msix_count;
+	struct psp_msix msix[MSIX_VECTORS];
+};
+
+static int psp_get_msix_irqs(struct psp_device *psp)
+{
+	struct psp_pci *psp_pci = psp->dev_specific;
+	struct device *dev = psp->dev;
+	struct pci_dev *pdev = container_of(dev, struct pci_dev, dev);
+	struct msix_entry msix_entry[MSIX_VECTORS];
+	unsigned int name_len = sizeof(psp_pci->msix[0].name) - 1;
+	int v, ret;
+
+	for (v = 0; v < ARRAY_SIZE(msix_entry); v++)
+		msix_entry[v].entry = v;
+
+	ret = pci_enable_msix_range(pdev, msix_entry, 1, v);
+	if (ret < 0)
+		return ret;
+
+	psp_pci->msix_count = ret;
+	for (v = 0; v < psp_pci->msix_count; v++) {
+		/* Set the interrupt names and request the irqs */
+		snprintf(psp_pci->msix[v].name, name_len, "%s-%u", psp->name, v);
+		psp_pci->msix[v].vector = msix_entry[v].vector;
+		ret = request_irq(psp_pci->msix[v].vector, psp_irq_handler,
+				  0, psp_pci->msix[v].name, dev);
+		if (ret) {
+			dev_notice(dev, "unable to allocate MSI-X IRQ (%d)\n",
+				   ret);
+			goto e_irq;
+		}
+	}
+
+	return 0;
+
+e_irq:
+	while (v--)
+		free_irq(psp_pci->msix[v].vector, dev);
+	pci_disable_msix(pdev);
+	psp_pci->msix_count = 0;
+
+	return ret;
+}
+
+static int psp_get_msi_irq(struct psp_device *psp)
+{
+	struct device *dev = psp->dev;
+	struct pci_dev *pdev = container_of(dev, struct pci_dev, dev);
+	int ret;
+
+	ret = pci_enable_msi(pdev);
+	if (ret)
+		return ret;
+
+	psp->irq = pdev->irq;
+	ret = request_irq(psp->irq, psp_irq_handler, 0, psp->name, dev);
+	if (ret) {
+		dev_notice(dev, "unable to allocate MSI IRQ (%d)\n", ret);
+		goto e_msi;
+	}
+
+	return 0;
+
+e_msi:
+	pci_disable_msi(pdev);
+
+	return ret;
+}
+
+static int psp_get_irqs(struct psp_device *psp)
+{
+	struct device *dev = psp->dev;
+	int ret;
+
+	ret = psp_get_msix_irqs(psp);
+	if (!ret)
+		return 0;
+
+	/* Couldn't get MSI-X vectors, try MSI */
+	dev_notice(dev, "could not enable MSI-X (%d), trying MSI\n", ret);
+	ret = psp_get_msi_irq(psp);
+	if (!ret)
+		return 0;
+
+	/* Couldn't get MSI interrupt */
+	dev_notice(dev, "could not enable MSI (%d), trying PCI\n", ret);
+
+	return ret;
+}
+
+void psp_free_irqs(struct psp_device *psp)
+{
+	struct psp_pci *psp_pci = psp->dev_specific;
+	struct device *dev = psp->dev;
+	struct pci_dev *pdev = container_of(dev, struct pci_dev, dev);
+
+	if (psp_pci->msix_count) {
+		while (psp_pci->msix_count--)
+			free_irq(psp_pci->msix[psp_pci->msix_count].vector,
+				 dev);
+		pci_disable_msix(pdev);
+	} else {
+		free_irq(psp->irq, dev);
+		pci_disable_msi(pdev);
+	}
+}
+
+static bool psp_is_master(struct psp_device *cur, struct psp_device *new)
+{
+	struct psp_pci *psp_pci_cur, *psp_pci_new;
+	struct pci_dev *pdev_cur, *pdev_new;
+
+	psp_pci_cur = cur->dev_specific;
+	psp_pci_new = new->dev_specific;
+
+	pdev_cur = psp_pci_cur->pdev;
+	pdev_new = psp_pci_new->pdev;
+
+	if (pdev_new->bus->number < pdev_cur->bus->number)
+		return true;
+
+	if (PCI_SLOT(pdev_new->devfn) < PCI_SLOT(pdev_cur->devfn))
+		return true;
+
+	if (PCI_FUNC(pdev_new->devfn) < PCI_FUNC(pdev_cur->devfn))
+		return true;
+
+	return false;
+}
+
+static struct psp_device *psp_get_master(struct list_head *list)
+{
+	struct psp_device *psp, *tmp;
+
+	psp = NULL;
+	list_for_each_entry(tmp, list, entry) {
+		if (!psp || psp_is_master(psp, tmp))
+			psp = tmp;
+	}
+
+	return psp;
+}
+
+static int psp_find_mmio_area(struct psp_device *psp)
+{
+	struct device *dev = psp->dev;
+	struct pci_dev *pdev = container_of(dev, struct pci_dev, dev);
+	unsigned long io_flags;
+
+	io_flags = pci_resource_flags(pdev, IO_BAR);
+	if (io_flags & IORESOURCE_MEM)
+		return IO_BAR;
+
+	return -EIO;
+}
+
+static int psp_pci_probe(struct pci_dev *pdev, const struct pci_device_id *id)
+{
+	struct psp_device *psp;
+	struct psp_pci *psp_pci;
+	struct device *dev = &pdev->dev;
+	unsigned int bar;
+	int ret;
+
+	ret = -ENOMEM;
+	psp = psp_alloc_struct(dev);
+	if (!psp)
+		goto e_err;
+
+	psp_pci = devm_kzalloc(dev, sizeof(*psp_pci), GFP_KERNEL);
+	if (!psp_pci) {
+		ret = -ENOMEM;
+		goto e_err;
+	}
+	psp_pci->pdev = pdev;
+	psp->dev_specific = psp_pci;
+	psp->get_irq = psp_get_irqs;
+	psp->free_irq = psp_free_irqs;
+	psp->get_master = psp_get_master;
+
+	ret = pci_request_regions(pdev, PSP_DRIVER_NAME);
+	if (ret) {
+		dev_err(dev, "pci_request_regions failed (%d)\n", ret);
+		goto e_err;
+	}
+
+	ret = pci_enable_device(pdev);
+	if (ret) {
+		dev_err(dev, "pci_enable_device failed (%d)\n", ret);
+		goto e_regions;
+	}
+
+	pci_set_master(pdev);
+
+	ret = psp_find_mmio_area(psp);
+	if (ret < 0)
+		goto e_device;
+	bar = ret;
+
+	ret = -EIO;
+	psp->io_map = pci_iomap(pdev, bar, 0);
+	if (!psp->io_map) {
+		dev_err(dev, "pci_iomap failed\n");
+		goto e_device;
+	}
+	psp->io_regs = psp->io_map + IO_OFFSET;
+
+	ret = dma_set_mask_and_coherent(dev, DMA_BIT_MASK(48));
+	if (ret) {
+		ret = dma_set_mask_and_coherent(dev, DMA_BIT_MASK(32));
+		if (ret) {
+			dev_err(dev, "dma_set_mask_and_coherent failed (%d)\n",
+				ret);
+			goto e_iomap;
+		}
+	}
+
+	dev_set_drvdata(dev, psp);
+
+	ret = psp_init(psp);
+	if (ret)
+		goto e_iomap;
+
+	dev_notice(dev, "enabled\n");
+
+	return 0;
+
+e_iomap:
+	pci_iounmap(pdev, psp->io_map);
+
+e_device:
+	pci_disable_device(pdev);
+
+e_regions:
+	pci_release_regions(pdev);
+
+e_err:
+	dev_notice(dev, "initialization failed\n");
+	return ret;
+}
+
+static void psp_pci_remove(struct pci_dev *pdev)
+{
+	struct device *dev = &pdev->dev;
+	struct psp_device *psp = dev_get_drvdata(dev);
+
+	if (!psp)
+		return;
+
+	psp_destroy(psp);
+
+	pci_iounmap(pdev, psp->io_map);
+
+	pci_disable_device(pdev);
+
+	pci_release_regions(pdev);
+
+	dev_notice(dev, "disabled\n");
+}
+
+#if 0
+#ifdef CONFIG_PM
+static int ccp_pci_suspend(struct pci_dev *pdev, pm_message_t state)
+{
+	struct device *dev = &pdev->dev;
+	struct ccp_device *ccp = dev_get_drvdata(dev);
+	unsigned long flags;
+	unsigned int i;
+
+	spin_lock_irqsave(&ccp->cmd_lock, flags);
+
+	ccp->suspending = 1;
+
+	/* Wake all the queue kthreads to prepare for suspend */
+	for (i = 0; i < ccp->cmd_q_count; i++)
+		wake_up_process(ccp->cmd_q[i].kthread);
+
+	spin_unlock_irqrestore(&ccp->cmd_lock, flags);
+
+	/* Wait for all queue kthreads to say they're done */
+	while (!ccp_queues_suspended(ccp))
+		wait_event_interruptible(ccp->suspend_queue,
+					 ccp_queues_suspended(ccp));
+
+	return 0;
+}
+
+static int ccp_pci_resume(struct pci_dev *pdev)
+{
+	struct device *dev = &pdev->dev;
+	struct ccp_device *ccp = dev_get_drvdata(dev);
+	unsigned long flags;
+	unsigned int i;
+
+	spin_lock_irqsave(&ccp->cmd_lock, flags);
+
+	ccp->suspending = 0;
+
+	/* Wake up all the kthreads */
+	for (i = 0; i < ccp->cmd_q_count; i++) {
+		ccp->cmd_q[i].suspended = 0;
+		wake_up_process(ccp->cmd_q[i].kthread);
+	}
+
+	spin_unlock_irqrestore(&ccp->cmd_lock, flags);
+
+	return 0;
+}
+#endif
+#endif
+
+static const struct pci_device_id psp_pci_table[] = {
+	{ PCI_VDEVICE(AMD, 0x1456), },
+	/* Last entry must be zero */
+	{ 0, }
+};
+MODULE_DEVICE_TABLE(pci, psp_pci_table);
+
+static struct pci_driver psp_pci_driver = {
+	.name = PSP_DRIVER_NAME,
+	.id_table = psp_pci_table,
+	.probe = psp_pci_probe,
+	.remove = psp_pci_remove,
+#if 0
+#ifdef CONFIG_PM
+	.suspend = ccp_pci_suspend,
+	.resume = ccp_pci_resume,
+#endif
+#endif
+};
+
+int psp_pci_init(void)
+{
+	return pci_register_driver(&psp_pci_driver);
+}
+
+void psp_pci_exit(void)
+{
+	pci_unregister_driver(&psp_pci_driver);
+}
diff --git a/include/linux/ccp-psp.h b/include/linux/ccp-psp.h
new file mode 100644
index 0000000..b5e791c
--- /dev/null
+++ b/include/linux/ccp-psp.h
@@ -0,0 +1,833 @@
+/*
+ * AMD Secure Processor (PSP) driver
+ *
+ * Copyright (C) 2016 Advanced Micro Devices, Inc.
+ *
+ * Author: Tom Lendacky <thomas.lendacky@amd.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#ifndef __CPP_PSP_H__
+#define __CPP_PSP_H__
+
+#include <uapi/linux/ccp-psp.h>
+
+#ifdef CONFIG_X86
+#include <asm/mem_encrypt.h>
+
+#define __psp_pa(x)	__sme_pa(x)
+#else
+#define __psp_pa(x)	__pa(x)
+#endif
+
+/**
+ * struct psp_data_activate - PSP ACTIVATE command parameters
+ * @hdr: command header
+ * @handle: handle of the VM to activate
+ * @asid: asid assigned to the VM
+ */
+struct __attribute__ ((__packed__)) psp_data_activate {
+	struct psp_data_header hdr;		/* In/Out */
+	u32 handle;				/* In */
+	u32 asid;				/* In */
+};
+
+/**
+ * struct psp_data_deactivate - PSP DEACTIVATE command parameters
+ * @hdr: command header
+ * @handle: handle of the VM to deactivate
+ */
+struct __attribute__ ((__packed__)) psp_data_deactivate {
+	struct psp_data_header hdr;		/* In/Out */
+	u32 handle;				/* In */
+};
+
+/**
+ * struct psp_data_launch_start - PSP LAUNCH_START command parameters
+ * @hdr: command header
+ * @handle: handle assigned to the VM
+ * @flags: configuration flags for the VM
+ * @policy: policy information for the VM
+ * @dh_pub_qx: the Qx parameter of the VM owners ECDH public key
+ * @dh_pub_qy: the Qy parameter of the VM owners ECDH public key
+ * @nonce: nonce generated by the VM owner
+ */
+struct __attribute__ ((__packed__)) psp_data_launch_start {
+	struct psp_data_header hdr;
+	u32 handle;				/* In/Out */
+	u32 flags;				/* In */
+	u32 policy;				/* In */
+	u8  dh_pub_qx[32];			/* In */
+	u8  dh_pub_qy[32];			/* In */
+	u8  nonce[16];				/* In */
+};
+
+/**
+ * struct psp_data_launch_update - PSP LAUNCH_UPDATE command parameters
+ * @hdr: command header
+ * @handle: handle of the VM to update
+ * @length: length of memory to be encrypted
+ * @address: physical address of memory region to encrypt
+ */
+struct __attribute__ ((__packed__)) psp_data_launch_update {
+	struct psp_data_header hdr;		/* In/Out */
+	u32 handle;				/* In */
+	u64 address;				/* In */
+	u32 length;				/* In */
+};
+
+/**
+ * struct psp_data_launch_vcpus - PSP LAUNCH_FINISH VCPU state information
+ * @state_length: length of the VCPU state information to measure
+ * @state_mask_addr: mask of the bytes within the VCPU state information
+ *                   to use in the measurment
+ * @state_count: number of VCPUs to measure
+ * @state_addr: physical address of the VCPU state (VMCB)
+ */
+struct __attribute__ ((__packed__)) psp_data_launch_vcpus {
+	u32 state_length;			/* In */
+	u64 state_mask_addr;			/* In */
+	u32 state_count;			/* In */
+	u64 state_addr[];			/* In */
+};
+
+/**
+ * struct psp_data_launch_finish - PSP LAUNCH_FINISH command parameters
+ * @hdr: command header
+ * @handle: handle of the VM to process
+ * @measurement: the measurement of the encrypted VM memory areas
+ * @vcpus: the VCPU state information to include in the measurement
+ */
+struct __attribute__ ((__packed__)) psp_data_launch_finish {
+	struct psp_data_header hdr;		/* In/Out */
+	u32 handle;				/* In */
+	u8  measurement[32];			/* In/Out */
+	struct psp_data_launch_vcpus vcpus;	/* In */
+};
+
+/**
+ * struct psp_data_decommission - PSP DECOMMISSION command parameters
+ * @hdr: command header
+ * @handle: handle of the VM to decommission
+ */
+struct __attribute__ ((__packed__)) psp_data_decommission {
+	struct psp_data_header hdr;		/* In/Out */
+	u32 handle;				/* In */
+};
+
+/**
+ * struct psp_data_guest_status - PSP GUEST_STATUS command parameters
+ * @hdr: command header
+ * @handle: handle of the VM to retrieve status
+ * @policy: policy information for the VM
+ * @asid: current ASID of the VM
+ * @state: current state of the VM
+ */
+struct __attribute__ ((__packed__)) psp_data_guest_status {
+	struct psp_data_header hdr;		/* In/Out */
+	u32 handle;				/* In */
+	u32 policy;				/* Out */
+	u32 asid;				/* Out */
+	u8 state;				/* Out */
+};
+
+/**
+ * struct psp_data_dbg - PSP DBG_ENCRYPT/DBG_DECRYPT command parameters
+ * @hdr: command header
+ * @handle: handle of the VM to perform debug operation
+ * @src_addr: source address of data to operate on
+ * @dst_addr: destination address of data to operate on
+ * @length: length of data to operate on
+ */
+struct __attribute__ ((__packed__)) psp_data_dbg {
+	struct psp_data_header hdr;		/* In/Out */
+	u32 handle;				/* In */
+	u64 src_addr;				/* In */
+	u64 dst_addr;				/* In */
+	u32 length;				/* In */
+};
+
+/**
+ * struct psp_data_receive_start - PSP RECEIVE_START command parameters
+ *
+ * @hdr: command header
+ * @handle: handle of the VM to receiving the guest
+ * @flags: flags for the receive process
+ * @policy: guest policy flags
+ * @policy_meas: HMAC of policy keypad
+ * @wrapped_tek: wrapped transport encryption key
+ * @wrapped_tik: wrapped transport integrity key
+ * @ten: transport encryption nonce
+ * @dh_pub_qx: qx parameter of the origin's ECDH public key
+ * @dh_pub_qy: qy parameter of the origin's ECDH public key
+ * @nonce: nonce generated by the origin
+ */
+struct __attribute__((__packed__)) psp_data_receive_start {
+	struct psp_data_header hdr;	/* In/Out */
+	u32 handle;			/* In/Out */
+	u32 flags;			/* In */
+	u32 policy;			/* In */
+	u8 policy_meas[32];		/* In */
+	u8 wrapped_tek[24];		/* In */
+	u8 reserved1[8];
+	u8 wrapped_tik[24];		/* In */
+	u8 reserved2[8];
+	u8 ten[16];			/* In */
+	u8 dh_pub_qx[32];		/* In */
+	u8 dh_pub_qy[32];		/* In */
+	u8 nonce[16];			/* In */
+};
+
+/**
+ * struct psp_receive_update - PSP RECEIVE_UPDATE command parameters
+ *
+ * @hdr: command header
+ * @handle: handle of the VM to receiving the guest
+ * @iv: initialization vector for this blob of memory
+ * @count: number of memory areas to be encrypted
+ * @length: length of memory to be encrypted
+ * @address: physical address of memory region to encrypt
+ */
+struct __attribute__((__packed__)) psp_data_receive_update {
+	struct psp_data_header hdr;		/* In/Out */
+	u32 handle;				/* In */
+	u8 iv[16];				/* In */
+	u64 address;				/* In */
+	u32 length;				/* In */
+};
+
+/**
+ * struct psp_data_receive_finish - PSP RECEIVE_FINISH command parameters
+ * @hdr: command header
+ * @handle: handle of the VM to process
+ * @measurement: the measurement of the transported guest
+ */
+struct __attribute__ ((__packed__)) psp_data_receive_finish {
+	struct psp_data_header hdr;		/* In/Out */
+	u32 handle;				/* In */
+	u8  measurement[32];			/* In */
+};
+
+/**
+ * struct psp_data_send_start - PSP SEND_START command parameters
+ * @hdr: command header
+ * @nonce: nonce generated by firmware
+ * @policy: guest policy flags
+ * @policy_meas: HMAC of policy keyed with TIK
+ * @wrapped_tek: wrapped transport encryption key
+ * @wrapped_tik: wrapped transport integrity key
+ * @ten: transport encryrption nonce
+ * @iv: the IV of transport encryption block
+ * @handle: handle of the VM to process
+ * @flags: flags for send command
+ * @major: API major number
+ * @minor: API minor number
+ * @serial: platform serial number
+ * @dh_pub_qx: the Qx parameter of the target DH public key
+ * @dh_pub_qy: the Qy parameter of the target DH public key
+ * @pek_sig_r: the r component of the PEK signature
+ * @pek_sig_s: the s component of the PEK signature
+ * @cek_sig_r: the r component of the CEK signature
+ * @cek_sig_s: the s component of the CEK signature
+ * @cek_pub_qx: the Qx parameter of the CEK public key
+ * @cek_pub_qy: the Qy parameter of the CEK public key
+ * @ask_sig_r: the r component of the ASK signature
+ * @ask_sig_s: the s component of the ASK signature
+ * @ncerts: number of certificates in certificate chain
+ * @cert_len: length of certificates
+ * @certs: certificate in chain
+ */
+
+struct __attribute__((__packed__)) psp_data_send_start {
+	struct psp_data_header hdr;			/* In/Out */
+	u8 nonce[16];					/* Out */
+	u32 policy;					/* Out */
+	u8 policy_meas[32];				/* Out */
+	u8 wrapped_tek[24];				/* Out */
+	u8 reserved1[8];
+	u8 wrapped_tik[24];				/* Out */
+	u8 reserved2[8];
+	u8 ten[16];					/* Out */
+	u8 iv[16];					/* Out */
+	u32 handle;					/* In */
+	u32 flags;					/* In */
+	u8 api_major;					/* In */
+	u8 api_minor;					/* In */
+	u8 reserved3[2];
+	u32 serial;					/* In */
+	u8 dh_pub_qx[32];				/* In */
+	u8 dh_pub_qy[32];				/* In */
+	u8 pek_sig_r[32];				/* In */
+	u8 pek_sig_s[32];				/* In */
+	u8 cek_sig_r[32];				/* In */
+	u8 cek_sig_s[32];				/* In */
+	u8 cek_pub_qx[32];				/* In */
+	u8 cek_pub_qy[32];				/* In */
+	u8 ask_sig_r[32];				/* In */
+	u8 ask_sig_s[32];				/* In */
+	u32 ncerts;					/* In */
+	u32 cert_length;				/* In */
+	u8 certs[];					/* In */
+};
+
+/**
+ * struct psp_data_send_update - PSP SEND_UPDATE command parameters
+ *
+ * @hdr: command header
+ * @handle: handle of the VM to receiving the guest
+ * @len: length of memory region to encrypt
+ * @src_addr: physical address of memory region to encrypt from
+ * @dst_addr: physical address of memory region to encrypt to
+ */
+struct __attribute__((__packed__)) psp_data_send_update {
+	struct psp_data_header hdr;		/* In/Out */
+	u32 handle;				/* In */
+	u64 src_addr;				/* In */
+	u64 dst_addr;				/* In */
+	u32 length;				/* In */
+};
+
+/**
+ * struct psp_data_send_finish - PSP SEND_FINISH command parameters
+ * @hdr: command header
+ * @handle: handle of the VM to process
+ * @measurement: the measurement of the transported guest
+ */
+struct __attribute__ ((__packed__)) psp_data_send_finish {
+	struct psp_data_header hdr;		/* In/Out */
+	u32 handle;				/* In */
+	u8  measurement[32];			/* Out */
+};
+
+#if defined(CONFIG_CRYPTO_DEV_PSP_DD) || \
+	defined(CONFIG_CRYPTO_DEV_PSP_DD_MODULE)
+
+/**
+ * psp_platform_init - perform PSP INIT command
+ *
+ * @init: psp_data_init structure to be processed
+ * @psp_ret: PSP command return code
+ *
+ * Returns:
+ * 0 if the PSP successfully processed the command
+ * -%ENODEV    if the PSP device is not available
+ * -%ENOTSUPP  if the PSP does not support SEV
+ * -%ETIMEDOUT if the PSP command timed out
+ * -%EIO       if the PSP returned a non-zero return code
+ */
+int psp_platform_init(struct psp_data_init *init, int *psp_ret);
+
+/**
+ * psp_platform_shutdown - perform PSP SHUTDOWN command
+ *
+ * @psp_ret: PSP command return code
+ *
+ * Returns:
+ * 0 if the PSP successfully processed the command
+ * -%ENODEV    if the PSP device is not available
+ * -%ENOTSUPP  if the PSP does not support SEV
+ * -%ETIMEDOUT if the PSP command timed out
+ * -%EIO       if the PSP returned a non-zero return code
+ */
+int psp_platform_shutdown(int *psp_ret);
+
+/**
+ * psp_platform_status - perform PSP PLATFORM_STATUS command
+ *
+ * @init: psp_data_status structure to be processed
+ * @psp_ret: PSP command return code
+ *
+ * Returns:
+ * 0 if the PSP successfully processed the command
+ * -%ENODEV    if the PSP device is not available
+ * -%ENOTSUPP  if the PSP does not support SEV
+ * -%ETIMEDOUT if the PSP command timed out
+ * -%EIO       if the PSP returned a non-zero return code
+ */
+int psp_platform_status(struct psp_data_status *status, int *psp_ret);
+
+/**
+ * psp_guest_launch_start - perform PSP LAUNCH_START command
+ *
+ * @start: psp_data_launch_start structure to be processed
+ * @psp_ret: PSP command return code
+ *
+ * Returns:
+ * 0 if the PSP successfully processed the command
+ * -%ENODEV    if the PSP device is not available
+ * -%ENOTSUPP  if the PSP does not support SEV
+ * -%ETIMEDOUT if the PSP command timed out
+ * -%EIO       if the PSP returned a non-zero return code
+ */
+int psp_guest_launch_start(struct psp_data_launch_start *start, int *psp_ret);
+
+/**
+ * psp_guest_launch_update - perform PSP LAUNCH_UPDATE command
+ *
+ * @update: psp_data_launch_update structure to be processed
+ * @timeout: command timeout
+ * @psp_ret: PSP command return code
+ *
+ * Returns:
+ * 0 if the PSP successfully processed the command
+ * -%ENODEV    if the PSP device is not available
+ * -%ENOTSUPP  if the PSP does not support SEV
+ * -%ETIMEDOUT if the PSP command timed out
+ * -%EIO       if the PSP returned a non-zero return code
+ */
+int psp_guest_launch_update(struct psp_data_launch_update *update,
+			    unsigned int timeout, int *psp_ret);
+
+/**
+ * psp_guest_launch_finish - perform PSP LAUNCH_FINISH command
+ *
+ * @finish: psp_data_launch_finish structure to be processed
+ * @psp_ret: PSP command return code
+ *
+ * Returns:
+ * 0 if the PSP successfully processed the command
+ * -%ENODEV    if the PSP device is not available
+ * -%ENOTSUPP  if the PSP does not support SEV
+ * -%ETIMEDOUT if the PSP command timed out
+ * -%EIO       if the PSP returned a non-zero return code
+ */
+int psp_guest_launch_finish(struct psp_data_launch_finish *finish, int *psp_ret);
+
+/**
+ * psp_guest_activate - perform PSP ACTIVATE command
+ *
+ * @activate: psp_data_activate structure to be processed
+ * @psp_ret: PSP command return code
+ *
+ * Returns:
+ * 0 if the PSP successfully processed the command
+ * -%ENODEV    if the PSP device is not available
+ * -%ENOTSUPP  if the PSP does not support SEV
+ * -%ETIMEDOUT if the PSP command timed out
+ * -%EIO       if the PSP returned a non-zero return code
+ */
+int psp_guest_activate(struct psp_data_activate *activate, int *psp_ret);
+
+/**
+ * psp_guest_deactivate - perform PSP DEACTIVATE command
+ *
+ * @deactivate: psp_data_deactivate structure to be processed
+ * @psp_ret: PSP command return code
+ *
+ * Returns:
+ * 0 if the PSP successfully processed the command
+ * -%ENODEV    if the PSP device is not available
+ * -%ENOTSUPP  if the PSP does not support SEV
+ * -%ETIMEDOUT if the PSP command timed out
+ * -%EIO       if the PSP returned a non-zero return code
+ */
+int psp_guest_deactivate(struct psp_data_deactivate *deactivate, int *psp_ret);
+
+/**
+ * psp_guest_df_flush - perform PSP DF_FLUSH command
+ *
+ * @psp_ret: PSP command return code
+ *
+ * Returns:
+ * 0 if the PSP successfully processed the command
+ * -%ENODEV    if the PSP device is not available
+ * -%ENOTSUPP  if the PSP does not support SEV
+ * -%ETIMEDOUT if the PSP command timed out
+ * -%EIO       if the PSP returned a non-zero return code
+ */
+int psp_guest_df_flush(int *psp_ret);
+
+/**
+ * psp_guest_decommission - perform PSP DECOMMISSION command
+ *
+ * @decommission: psp_data_decommission structure to be processed
+ * @psp_ret: PSP command return code
+ *
+ * Returns:
+ * 0 if the PSP successfully processed the command
+ * -%ENODEV    if the PSP device is not available
+ * -%ENOTSUPP  if the PSP does not support SEV
+ * -%ETIMEDOUT if the PSP command timed out
+ * -%EIO       if the PSP returned a non-zero return code
+ */
+int psp_guest_decommission(struct psp_data_decommission *decommission,
+			   int *psp_ret);
+
+/**
+ * psp_guest_status - perform PSP GUEST_STATUS command
+ *
+ * @status: psp_data_guest_status structure to be processed
+ * @psp_ret: PSP command return code
+ *
+ * Returns:
+ * 0 if the PSP successfully processed the command
+ * -%ENODEV    if the PSP device is not available
+ * -%ENOTSUPP  if the PSP does not support SEV
+ * -%ETIMEDOUT if the PSP command timed out
+ * -%EIO       if the PSP returned a non-zero return code
+ */
+int psp_guest_status(struct psp_data_guest_status *status, int *psp_ret);
+
+/**
+ * psp_dbg_decrypt - perform PSP DBG_DECRYPT command
+ *
+ * @dbg: psp_data_dbg structure to be processed
+ * @psp_ret: PSP command return code
+ *
+ * Returns:
+ * 0 if the PSP successfully processed the command
+ * -%ENODEV    if the PSP device is not available
+ * -%ENOTSUPP  if the PSP does not support SEV
+ * -%ETIMEDOUT if the PSP command timed out
+ * -%EIO       if the PSP returned a non-zero return code
+ */
+int psp_dbg_decrypt(struct psp_data_dbg *dbg, int *psp_ret);
+
+/**
+ * psp_dbg_encrypt - perform PSP DBG_ENCRYPT command
+ *
+ * @dbg: psp_data_dbg structure to be processed
+ * @psp_ret: PSP command return code
+ *
+ * Returns:
+ * 0 if the PSP successfully processed the command
+ * -%ENODEV    if the PSP device is not available
+ * -%ENOTSUPP  if the PSP does not support SEV
+ * -%ETIMEDOUT if the PSP command timed out
+ * -%EIO       if the PSP returned a non-zero return code
+ */
+int psp_dbg_encrypt(struct psp_data_dbg *dbg, int *psp_ret);
+
+/**
+ * psp_guest_receive_start - perform PSP RECEIVE_START command
+ *
+ * @start: psp_data_receive_start structure to be processed
+ * @psp_ret: PSP command return code
+ *
+ * Returns:
+ * 0 if the PSP successfully processed the command
+ * -%ENODEV    if the PSP device is not available
+ * -%ENOTSUPP  if the PSP does not support SEV
+ * -%ETIMEDOUT if the PSP command timed out
+ * -%EIO       if the PSP returned a non-zero return code
+ */
+int psp_guest_receive_start(struct psp_data_receive_start *start, int *psp_ret);
+
+/**
+ * psp_guest_receive_update - perform PSP RECEIVE_UPDATE command
+ *
+ * @update: psp_data_receive_update structure to be processed
+ * @timeout: command timeout
+ * @psp_ret: PSP command return code
+ *
+ * Returns:
+ * 0 if the PSP successfully processed the command
+ * -%ENODEV    if the PSP device is not available
+ * -%ENOTSUPP  if the PSP does not support SEV
+ * -%ETIMEDOUT if the PSP command timed out
+ * -%EIO       if the PSP returned a non-zero return code
+ */
+int psp_guest_receive_update(struct psp_data_receive_update *update,
+			    unsigned int timeout, int *psp_ret);
+
+/**
+ * psp_guest_receive_finish - perform PSP RECEIVE_FINISH command
+ *
+ * @finish: psp_data_receive_finish structure to be processed
+ * @psp_ret: PSP command return code
+ *
+ * Returns:
+ * 0 if the PSP successfully processed the command
+ * -%ENODEV    if the PSP device is not available
+ * -%ENOTSUPP  if the PSP does not support SEV
+ * -%ETIMEDOUT if the PSP command timed out
+ * -%EIO       if the PSP returned a non-zero return code
+ */
+int psp_guest_receive_finish(struct psp_data_receive_finish *finish,
+			     int *psp_ret);
+
+/**
+ * psp_guest_send_start - perform PSP RECEIVE_START command
+ *
+ * @start: psp_data_send_start structure to be processed
+ * @psp_ret: PSP command return code
+ *
+ * Returns:
+ * 0 if the PSP successfully processed the command
+ * -%ENODEV    if the PSP device is not available
+ * -%ENOTSUPP  if the PSP does not support SEV
+ * -%ETIMEDOUT if the PSP command timed out
+ * -%EIO       if the PSP returned a non-zero return code
+ */
+int psp_guest_send_start(struct psp_data_send_start *start, int *psp_ret);
+
+/**
+ * psp_guest_send_update - perform PSP RECEIVE_UPDATE command
+ *
+ * @update: psp_data_send_update structure to be processed
+ * @timeout: command timeout
+ * @psp_ret: PSP command return code
+ *
+ * Returns:
+ * 0 if the PSP successfully processed the command
+ * -%ENODEV    if the PSP device is not available
+ * -%ENOTSUPP  if the PSP does not support SEV
+ * -%ETIMEDOUT if the PSP command timed out
+ * -%EIO       if the PSP returned a non-zero return code
+ */
+int psp_guest_send_update(struct psp_data_send_update *update,
+			    unsigned int timeout, int *psp_ret);
+
+/**
+ * psp_guest_send_finish - perform PSP RECEIVE_FINISH command
+ *
+ * @finish: psp_data_send_finish structure to be processed
+ * @psp_ret: PSP command return code
+ *
+ * Returns:
+ * 0 if the PSP successfully processed the command
+ * -%ENODEV    if the PSP device is not available
+ * -%ENOTSUPP  if the PSP does not support SEV
+ * -%ETIMEDOUT if the PSP command timed out
+ * -%EIO       if the PSP returned a non-zero return code
+ */
+int psp_guest_send_finish(struct psp_data_send_finish *finish,
+			     int *psp_ret);
+
+/**
+ * psp_platform_pdh_gen - perform PSP PDH_GEN command
+ *
+ * @psp_ret: PSP command return code
+ *
+ * Returns:
+ * 0 if the PSP successfully processed the command
+ * -%ENODEV    if the PSP device is not available
+ * -%ENOTSUPP  if the PSP does not support SEV
+ * -%ETIMEDOUT if the PSP command timed out
+ * -%EIO       if the PSP returned a non-zero return code
+ */
+int psp_platform_pdh_gen(int *psp_ret);
+
+/**
+ * psp_platform_pdh_cert_export - perform PSP PDH_CERT_EXPORT command
+ *
+ * @data: psp_data_platform_pdh_cert_export structure to be processed
+ * @psp_ret: PSP command return code
+ *
+ * Returns:
+ * 0 if the PSP successfully processed the command
+ * -%ENODEV    if the PSP device is not available
+ * -%ENOTSUPP  if the PSP does not support SEV
+ * -%ETIMEDOUT if the PSP command timed out
+ * -%EIO       if the PSP returned a non-zero return code
+ */
+int psp_platform_pdh_cert_export(struct psp_data_pdh_cert_export *data,
+				int *psp_ret);
+
+/**
+ * psp_platform_pek_gen - perform PSP PEK_GEN command
+ *
+ * @psp_ret: PSP command return code
+ *
+ * Returns:
+ * 0 if the PSP successfully processed the command
+ * -%ENODEV    if the PSP device is not available
+ * -%ENOTSUPP  if the PSP does not support SEV
+ * -%ETIMEDOUT if the PSP command timed out
+ * -%EIO       if the PSP returned a non-zero return code
+ */
+int psp_platform_pek_gen(int *psp_ret);
+
+/**
+ * psp_platform_pek_cert_import - perform PSP PEK_CERT_IMPORT command
+ *
+ * @data: psp_data_platform_pek_cert_import structure to be processed
+ * @psp_ret: PSP command return code
+ *
+ * Returns:
+ * 0 if the PSP successfully processed the command
+ * -%ENODEV    if the PSP device is not available
+ * -%ENOTSUPP  if the PSP does not support SEV
+ * -%ETIMEDOUT if the PSP command timed out
+ * -%EIO       if the PSP returned a non-zero return code
+ */
+int psp_platform_pek_cert_import(struct psp_data_pek_cert_import *data,
+				int *psp_ret);
+
+/**
+ * psp_platform_pek_csr - perform PSP PEK_CSR command
+ *
+ * @data: psp_data_platform_pek_csr structure to be processed
+ * @psp_ret: PSP command return code
+ *
+ * Returns:
+ * 0 if the PSP successfully processed the command
+ * -%ENODEV    if the PSP device is not available
+ * -%ENOTSUPP  if the PSP does not support SEV
+ * -%ETIMEDOUT if the PSP command timed out
+ * -%EIO       if the PSP returned a non-zero return code
+ */
+int psp_platform_pek_csr(struct psp_data_pek_csr *data, int *psp_ret);
+
+/**
+ * psp_platform_factory_reset - perform PSP FACTORY_RESET command
+ *
+ * @psp_ret: PSP command return code
+ *
+ * Returns:
+ * 0 if the PSP successfully processed the command
+ * -%ENODEV    if the PSP device is not available
+ * -%ENOTSUPP  if the PSP does not support SEV
+ * -%ETIMEDOUT if the PSP command timed out
+ * -%EIO       if the PSP returned a non-zero return code
+ */
+int psp_platform_factory_reset(int *psp_ret);
+
+#else	/* CONFIG_CRYPTO_DEV_PSP_DD is not enabled */
+
+static inline int psp_platform_status(struct psp_data_status *status,
+				      int *psp_ret)
+{
+	return -ENODEV;
+}
+
+static inline int psp_platform_init(struct psp_data_init *init, int *psp_ret)
+{
+	return -ENODEV;
+}
+
+static inline int psp_platform_shutdown(int *psp_ret)
+{
+	return -ENODEV;
+}
+
+static inline int psp_guest_launch_start(struct psp_data_launch_start *start,
+					 int *psp_ret)
+{
+	return -ENODEV;
+}
+
+static inline int psp_guest_launch_update(struct psp_data_launch_update *update,
+					  unsigned int timeout, int *psp_ret)
+{
+	return -ENODEV;
+}
+
+static inline int psp_guest_launch_finish(struct psp_data_launch_finish *finish,
+					  int *psp_ret)
+{
+	return -ENODEV;
+}
+
+static inline int psp_guest_activate(struct psp_data_activate *activate,
+				     int *psp_ret)
+{
+	return -ENODEV;
+}
+
+static inline int psp_guest_deactivate(struct psp_data_deactivate *deactivate,
+				       int *psp_ret)
+{
+	return -ENODEV;
+}
+
+static inline int psp_guest_df_flush(int *psp_ret)
+{
+	return -ENODEV;
+}
+
+static inline int psp_guest_decommission(struct psp_data_decommission *decommission,
+					 int *psp_ret)
+{
+	return -ENODEV;
+}
+
+static inline int psp_guest_status(struct psp_data_guest_status *status,
+				   int *psp_ret)
+{
+	return -ENODEV;
+}
+
+static inline int psp_dbg_decrypt(struct psp_data_dbg *dbg, int *psp_ret)
+{
+	return -ENODEV;
+}
+
+static inline int psp_dbg_encrypt(struct psp_data_dbg *dbg, int *psp_ret)
+{
+	return -ENODEV;
+}
+
+static inline int psp_guest_receive_start(struct psp_data_receive_start *start,
+					 int *psp_ret)
+{
+	return -ENODEV;
+}
+
+static inline int psp_guest_receive_update(struct psp_data_receive_update *update,
+					  unsigned int timeout, int *psp_ret)
+{
+	return -ENODEV;
+}
+
+static inline int psp_guest_receive_finish(struct psp_data_receive_finish *finish,
+					  int *psp_ret)
+{
+	return -ENODEV;
+}
+static inline int psp_guest_send_start(struct psp_data_send_start *start,
+					 int *psp_ret)
+{
+	return -ENODEV;
+}
+
+static inline int psp_guest_send_update(struct psp_data_send_update *update,
+					  unsigned int timeout, int *psp_ret)
+{
+	return -ENODEV;
+}
+
+static inline int psp_guest_send_finish(struct psp_data_send_finish *finish,
+					  int *psp_ret)
+{
+	return -ENODEV;
+}
+
+static inline int psp_platform_pdh_gen(int *psp_ret)
+{
+	return -ENODEV;
+}
+
+int psp_platform_pdh_cert_export(struct psp_data_pdh_cert_export *data,
+				int *psp_ret)
+{
+	return -ENODEV;
+}
+
+static inline int psp_platform_pek_gen(int *psp_ret)
+{
+	return -ENODEV;
+}
+
+int psp_platform_pek_cert_import(struct psp_data_pek_cert_import *data,
+				int *psp_ret)
+{
+	return -ENODEV;
+}
+
+int psp_platform_pek_csr(struct psp_data_pek_csr *data, int *psp_ret)
+{
+	return -ENODEV;
+}
+
+static inline int psp_platform_factory_reset(int *psp_ret)
+{
+	return -ENODEV;
+}
+
+#endif	/* CONFIG_CRYPTO_DEV_PSP_DD */
+
+#endif	/* __CPP_PSP_H__ */
diff --git a/include/uapi/linux/Kbuild b/include/uapi/linux/Kbuild
index 185f8ea..af2511a 100644
--- a/include/uapi/linux/Kbuild
+++ b/include/uapi/linux/Kbuild
@@ -470,3 +470,4 @@ header-y += xilinx-v4l2-controls.h
 header-y += zorro.h
 header-y += zorro_ids.h
 header-y += userfaultfd.h
+header-y += ccp-psp.h
diff --git a/include/uapi/linux/ccp-psp.h b/include/uapi/linux/ccp-psp.h
new file mode 100644
index 0000000..e780b46
--- /dev/null
+++ b/include/uapi/linux/ccp-psp.h
@@ -0,0 +1,182 @@
+#ifndef _UAPI_LINUX_CCP_PSP_
+#define _UAPI_LINUX_CCP_PSP_
+
+/*
+ * Userspace interface to communicated with CCP-PSP driver.
+ */
+
+#include <linux/types.h>
+#include <linux/ioctl.h>
+
+/**
+ * struct psp_data_header - Common PSP communication header
+ * @buffer_len: length of the buffer supplied to the PSP
+ */
+
+struct __attribute__ ((__packed__)) psp_data_header {
+	__u32 buffer_len;				/* In/Out */
+};
+
+/**
+ * struct psp_data_init - PSP INIT command parameters
+ * @hdr: command header
+ * @flags: processing flags
+ */
+struct __attribute__ ((__packed__)) psp_data_init {
+	struct psp_data_header hdr;
+	__u32 flags;				/* In */
+};
+
+/**
+ * struct psp_data_status - PSP PLATFORM_STATUS command parameters
+ * @hdr: command header
+ * @major: major API version
+ * @minor: minor API version
+ * @state: platform state
+ * @cert_status: bit fields describing certificate status
+ * @flags: platform flags
+ * @guest_count: number of active guests
+ */
+struct __attribute__ ((__packed__)) psp_data_status {
+	struct psp_data_header hdr;
+	__u8 api_major;				/* Out */
+	__u8 api_minor;				/* Out */
+	__u8 state;				/* Out */
+	__u8 cert_status;			/* Out */
+	__u32 flags;				/* Out */
+	__u32 guest_count;			/* Out */
+};
+
+/**
+ * struct psp_data_pek_csr - PSP PEK_CSR command parameters
+ * @hdr: command header
+ * @csr - certificate signing request formatted with PKCS
+ */
+struct __attribute__((__packed__)) psp_data_pek_csr {
+	struct psp_data_header hdr;			/* In/Out */
+	__u8 csr[];					/* Out */
+};
+
+/**
+ * struct psp_data_cert_import - PSP PEK_CERT_IMPORT command parameters
+ * @hdr: command header
+ * @ncerts: number of certificates in the chain
+ * @cert_len: length of certificates
+ * @certs: certificate chain starting with PEK and end with CA certificate
+ */
+struct __attribute__((__packed__)) psp_data_pek_cert_import {
+	struct psp_data_header hdr;			/* In/Out */
+	__u32 ncerts;					/* In */
+	__u32 cert_len;					/* In */
+	__u8 certs[];					/* In */
+};
+
+/**
+ * struct psp_data_pdh_cert_export - PSP PDH_CERT_EXPORT command parameters
+ * @hdr: command header
+ * @major: API major number
+ * @minor: API minor number
+ * @serial: platform serial number
+ * @pdh_pub_qx: the Qx parameter of the target PDH public key
+ * @pdh_pub_qy: the Qy parameter of the target PDH public key
+ * @pek_sig_r: the r component of the PEK signature
+ * @pek_sig_s: the s component of the PEK signature
+ * @cek_sig_r: the r component of the CEK signature
+ * @cek_sig_s: the s component of the CEK signature
+ * @cek_pub_qx: the Qx parameter of the CEK public key
+ * @cek_pub_qy: the Qy parameter of the CEK public key
+ * @ncerts: number of certificates in certificate chain
+ * @cert_len: length of certificates
+ * @certs: certificate chain starting with PEK and end with CA certificate
+ */
+struct __attribute__((__packed__)) psp_data_pdh_cert_export {
+	struct psp_data_header hdr;			/* In/Out */
+	__u8 api_major;					/* Out */
+	__u8 api_minor;					/* Out */
+	__u8 reserved1[2];
+	__u32 serial;					/* Out */
+	__u8 pdh_pub_qx[32];				/* Out */
+	__u8 pdh_pub_qy[32];				/* Out */
+	__u8 pek_sig_r[32];				/* Out */
+	__u8 pek_sig_s[32];				/* Out */
+	__u8 cek_sig_r[32];				/* Out */
+	__u8 cek_sig_s[32];				/* Out */
+	__u8 cek_pub_qx[32];				/* Out */
+	__u8 cek_pub_qy[32];				/* Out */
+	__u32 ncerts;					/* Out */
+	__u32 cert_len;					/* Out */
+	__u8 certs[];					/* Out */
+};
+
+/**
+ * platform and management commands
+ */
+enum psp_cmd {
+	PSP_CMD_INIT = 1,
+	PSP_CMD_LAUNCH_START,
+	PSP_CMD_LAUNCH_UPDATE,
+	PSP_CMD_LAUNCH_FINISH,
+	PSP_CMD_ACTIVATE,
+	PSP_CMD_DF_FLUSH,
+	PSP_CMD_SHUTDOWN,
+	PSP_CMD_FACTORY_RESET,
+	PSP_CMD_PLATFORM_STATUS,
+	PSP_CMD_PEK_GEN,
+	PSP_CMD_PEK_CSR,
+	PSP_CMD_PEK_CERT_IMPORT,
+	PSP_CMD_PDH_GEN,
+	PSP_CMD_PDH_CERT_EXPORT,
+	PSP_CMD_SEND_START,
+	PSP_CMD_SEND_UPDATE,
+	PSP_CMD_SEND_FINISH,
+	PSP_CMD_RECEIVE_START,
+	PSP_CMD_RECEIVE_UPDATE,
+	PSP_CMD_RECEIVE_FINISH,
+	PSP_CMD_GUEST_STATUS,
+	PSP_CMD_DEACTIVATE,
+	PSP_CMD_DECOMMISSION,
+	PSP_CMD_DBG_DECRYPT,
+	PSP_CMD_DBG_ENCRYPT,
+	PSP_CMD_MAX,
+};
+
+/**
+ * status code returned by the commands
+ */
+enum psp_ret_code {
+	PSP_RET_SUCCESS = 0,
+	PSP_RET_INVALID_PLATFORM_STATE,
+	PSP_RET_INVALID_GUEST_STATE,
+	PSP_RET_INAVLID_CONFIG,
+	PSP_RET_CMDBUF_TOO_SMALL,
+	PSP_RET_ALREADY_OWNED,
+	PSP_RET_INVALID_CERTIFICATE,
+	PSP_RET_POLICY_FAILURE,
+	PSP_RET_INACTIVE,
+	PSP_RET_INVALID_ADDRESS,
+	PSP_RET_BAD_SIGNATURE,
+	PSP_RET_BAD_MEASUREMENT,
+	PSP_RET_ASID_OWNED,
+	PSP_RET_INVALID_ASID,
+	PSP_RET_WBINVD_REQUIRED,
+	PSP_RET_DFFLUSH_REQUIRED,
+	PSP_RET_INVALID_GUEST,
+};
+
+/**
+ * struct psp_issue_cmd - PSP ioctl parameters
+ * @cmd: PSP commands to execute
+ * @opaque: pointer to the command structure
+ * @psp_ret: PSP return code on failure
+ */
+struct psp_issue_cmd {
+	__u32 cmd;					/* In */
+	__u64 opaque;					/* In */
+	__u32 psp_ret;					/* Out */
+};
+
+#define PSP_IOC_TYPE		'P'
+#define PSP_ISSUE_CMD	_IOWR(PSP_IOC_TYPE, 0x0, struct psp_issue_cmd)
+
+#endif /* _UAPI_LINUX_CCP_PSP_H */
+

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
