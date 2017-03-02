Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8501C6B03A7
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 10:16:55 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id w189so48312718pfb.4
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 07:16:55 -0800 (PST)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0077.outbound.protection.outlook.com. [104.47.38.77])
        by mx.google.com with ESMTPS id f126si1018900pfg.135.2017.03.02.07.16.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 02 Mar 2017 07:16:53 -0800 (PST)
Subject: [RFC PATCH v2 21/32] crypto: ccp: Add Secure Encrypted
 Virtualization (SEV) interface support
From: Brijesh Singh <brijesh.singh@amd.com>
Date: Thu, 2 Mar 2017 10:16:45 -0500
Message-ID: <148846780558.2349.2104104217663748050.stgit@brijesh-build-machine>
In-Reply-To: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
References: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: simon.guinot@sequanux.org, linux-efi@vger.kernel.org, brijesh.singh@amd.com, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linux-pci@vger.kernel.org, linus.walleij@linaro.org, gary.hook@amd.com, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, cl@linux.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, peterz@infradead.org, piotr.luc@intel.com, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, bp@suse.de, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, arnd@arndb.de, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, luto@kernel.org, devel@linuxdriverproject.org, bhelgaas@google.com, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, mst@redhat.com, linux-crypto@vger.kernel.org, tj@kernel.org, pbonzini@redhat.com, akpm@linux-foundation.org, davem@davemloft.net

The Secure Encrypted Virtualization (SEV) interface allows the memory
contents of a virtual machine (VM) to be transparently encrypted with
a key unique to the guest.

The interface provides:
  - /dev/sev device and ioctl (SEV_ISSUE_CMD) to execute the platform
    provisioning commands from the userspace.
  - in-kernel API's to encrypt the guest memory region. The in-kernel APIs
    will be used by KVM to bootstrap and debug the SEV guest.

SEV key management spec is available here [1]
[1] http://support.amd.com/TechDocs/55766_SEV-KM%20API_Specification.pdf

Signed-off-by: Brijesh Singh <brijesh.singh@amd.com>
---
 drivers/crypto/ccp/Kconfig   |    7 
 drivers/crypto/ccp/Makefile  |    1 
 drivers/crypto/ccp/psp-dev.h |    6 
 drivers/crypto/ccp/sev-dev.c |  348 ++++++++++++++++++++++
 drivers/crypto/ccp/sev-dev.h |   67 ++++
 drivers/crypto/ccp/sev-ops.c |  324 ++++++++++++++++++++
 include/linux/psp-sev.h      |  672 ++++++++++++++++++++++++++++++++++++++++++
 include/uapi/linux/Kbuild    |    1 
 include/uapi/linux/psp-sev.h |  123 ++++++++
 9 files changed, 1546 insertions(+), 3 deletions(-)
 create mode 100644 drivers/crypto/ccp/sev-dev.c
 create mode 100644 drivers/crypto/ccp/sev-dev.h
 create mode 100644 drivers/crypto/ccp/sev-ops.c
 create mode 100644 include/linux/psp-sev.h
 create mode 100644 include/uapi/linux/psp-sev.h

diff --git a/drivers/crypto/ccp/Kconfig b/drivers/crypto/ccp/Kconfig
index 59c207e..67d1917 100644
--- a/drivers/crypto/ccp/Kconfig
+++ b/drivers/crypto/ccp/Kconfig
@@ -41,4 +41,11 @@ config CRYPTO_DEV_PSP
 	help
 	 Provide the interface for AMD Platform Security Processor (PSP) device.
 
+config CRYPTO_DEV_SEV
+	bool "Secure Encrypted Virtualization (SEV) interface"
+	default y
+	help
+	 Provide the kernel and userspace (/dev/sev) interface to issue the
+	 Secure Encrypted Virtualization (SEV) commands.
+
 endif
diff --git a/drivers/crypto/ccp/Makefile b/drivers/crypto/ccp/Makefile
index 12e569d..4c4e77e 100644
--- a/drivers/crypto/ccp/Makefile
+++ b/drivers/crypto/ccp/Makefile
@@ -7,6 +7,7 @@ ccp-$(CONFIG_CRYPTO_DEV_CCP) += ccp-dev.o \
 	    ccp-dev-v5.o \
 	    ccp-dmaengine.o
 ccp-$(CONFIG_CRYPTO_DEV_PSP) += psp-dev.o
+ccp-$(CONFIG_CRYPTO_DEV_SEV) += sev-dev.o sev-ops.o
 
 obj-$(CONFIG_CRYPTO_DEV_CCP_CRYPTO) += ccp-crypto.o
 ccp-crypto-objs := ccp-crypto-main.o \
diff --git a/drivers/crypto/ccp/psp-dev.h b/drivers/crypto/ccp/psp-dev.h
index bbd3d96..fd67b14 100644
--- a/drivers/crypto/ccp/psp-dev.h
+++ b/drivers/crypto/ccp/psp-dev.h
@@ -70,14 +70,14 @@ int psp_free_sev_irq(struct psp_device *psp, void *data);
 
 struct psp_device *psp_get_master_device(void);
 
-#ifdef CONFIG_AMD_SEV
+#ifdef CONFIG_CRYPTO_DEV_SEV
 
 int sev_dev_init(struct psp_device *psp);
 void sev_dev_destroy(struct psp_device *psp);
 int sev_dev_resume(struct psp_device *psp);
 int sev_dev_suspend(struct psp_device *psp, pm_message_t state);
 
-#else
+#else /* !CONFIG_CRYPTO_DEV_SEV */
 
 static inline int sev_dev_init(struct psp_device *psp)
 {
@@ -96,7 +96,7 @@ static inline int sev_dev_suspend(struct psp_device *psp, pm_message_t state)
 	return -ENODEV;
 }
 
-#endif /* __AMD_SEV_H */
+#endif /* CONFIG_CRYPTO_DEV_SEV */
 
 #endif /* __PSP_DEV_H */
 
diff --git a/drivers/crypto/ccp/sev-dev.c b/drivers/crypto/ccp/sev-dev.c
new file mode 100644
index 0000000..a67e2d7
--- /dev/null
+++ b/drivers/crypto/ccp/sev-dev.c
@@ -0,0 +1,348 @@
+/*
+ * AMD Secure Encrypted Virtualization (SEV) interface
+ *
+ * Copyright (C) 2016 Advanced Micro Devices, Inc.
+ *
+ * Author: Brijesh Singh <brijesh.singh@amd.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/kthread.h>
+#include <linux/sched.h>
+#include <linux/interrupt.h>
+#include <linux/spinlock.h>
+#include <linux/spinlock_types.h>
+#include <linux/types.h>
+#include <linux/mutex.h>
+#include <linux/delay.h>
+#include <linux/wait.h>
+#include <linux/jiffies.h>
+
+#include "psp-dev.h"
+#include "sev-dev.h"
+
+extern struct file_operations sev_fops;
+
+static LIST_HEAD(sev_devs);
+static DEFINE_SPINLOCK(sev_devs_lock);
+static atomic_t sev_id;
+
+static unsigned int psp_poll;
+module_param(psp_poll, uint, 0444);
+MODULE_PARM_DESC(psp_poll, "Poll for sev command completion - any non-zero value");
+
+DEFINE_MUTEX(sev_cmd_mutex);
+
+void sev_add_device(struct sev_device *sev)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&sev_devs_lock, flags);
+
+	list_add_tail(&sev->entry, &sev_devs);
+
+	spin_unlock_irqrestore(&sev_devs_lock, flags);
+}
+
+void sev_del_device(struct sev_device *sev)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&sev_devs_lock, flags);
+
+	list_del(&sev->entry);
+	spin_unlock_irqrestore(&sev_devs_lock, flags);
+}
+
+static struct sev_device *get_sev_master_device(void)
+{
+	struct psp_device *psp = psp_get_master_device();
+
+	return psp ? psp->sev_data : NULL;
+}
+
+static int sev_wait_cmd_poll(struct sev_device *sev, unsigned int timeout,
+			     unsigned int *reg)
+{
+	int wait = timeout * 10;	/* 100ms sleep => timeout * 10 */
+
+	while (--wait) {
+		msleep(100);
+
+		*reg = ioread32(sev->io_regs + PSP_CMDRESP);
+		if (*reg & PSP_CMDRESP_RESP)
+			break;
+	}
+
+	if (!wait) {
+		dev_err(sev->dev, "sev command timed out\n");
+		return -ETIMEDOUT;
+	}
+
+	return 0;
+}
+
+static int sev_wait_cmd_ioc(struct sev_device *sev, unsigned int timeout,
+			    unsigned int *reg)
+{
+	unsigned long jiffie_timeout = timeout;
+	long ret;
+
+	jiffie_timeout *= HZ;
+
+	sev->int_rcvd = 0;
+
+	ret = wait_event_interruptible_timeout(sev->int_queue, sev->int_rcvd,
+						jiffie_timeout);
+	if (ret <= 0) {
+		dev_err(sev->dev, "sev command (%#x) timed out\n",
+				*reg >> PSP_CMDRESP_CMD_SHIFT);
+		return -ETIMEDOUT;
+	}
+
+	*reg = ioread32(sev->io_regs + PSP_CMDRESP);
+
+	return 0;
+}
+
+static int sev_wait_cmd(struct sev_device *sev, unsigned int timeout,
+			unsigned int *reg)
+{
+	return (*reg & PSP_CMDRESP_IOC) ? sev_wait_cmd_ioc(sev, timeout, reg)
+					: sev_wait_cmd_poll(sev, timeout, reg);
+}
+
+static struct sev_device *sev_alloc_struct(struct psp_device *psp)
+{
+	struct device *dev = psp->dev;
+	struct sev_device *sev;
+
+	sev = devm_kzalloc(dev, sizeof(*sev), GFP_KERNEL);
+	if (!sev)
+		return NULL;
+
+	sev->dev = dev;
+	sev->psp = psp;
+	sev->id = atomic_inc_return(&sev_id);
+
+	snprintf(sev->name, sizeof(sev->name), "sev%u", sev->id);
+	init_waitqueue_head(&sev->int_queue);
+
+	return sev;
+}
+
+irqreturn_t sev_irq_handler(int irq, void *data)
+{
+	struct sev_device *sev = data;
+	unsigned int status;
+
+	status = ioread32(sev->io_regs + PSP_P2CMSG_INTSTS);
+	if (status & (1 << PSP_CMD_COMPLETE_REG)) {
+		int reg;
+
+		reg = ioread32(sev->io_regs + PSP_CMDRESP);
+		if (reg & PSP_CMDRESP_RESP) {
+			sev->int_rcvd = 1;
+			wake_up_interruptible(&sev->int_queue);
+		}
+	}
+
+	return IRQ_HANDLED;
+}
+
+static bool check_sev_support(struct sev_device *sev)
+{
+	/* Bit 0 in PSP_FEATURE_REG is set then SEV is support in PSP */
+	if (ioread32(sev->io_regs + PSP_FEATURE_REG) & 1)
+		return true;
+
+	return false;
+}
+
+int sev_dev_init(struct psp_device *psp)
+{
+	struct device *dev = psp->dev;
+	struct sev_device *sev;
+	int ret;
+
+	ret = -ENOMEM;
+	sev = sev_alloc_struct(psp);
+	if (!sev)
+		goto e_err;
+	psp->sev_data = sev;
+	
+	sev->io_regs = psp->io_regs;
+
+	dev_dbg(dev, "checking SEV support ...\n");
+	/* check SEV support */
+	if (!check_sev_support(sev)) {
+		dev_dbg(dev, "device does not support SEV\n");
+		goto e_err;
+	}
+
+	dev_dbg(dev, "requesting an IRQ ...\n");
+	/* Request an irq */
+	ret = psp_request_sev_irq(sev->psp, sev_irq_handler, sev);
+	if (ret) {
+		dev_err(dev, "unable to allocate an IRQ\n");
+		goto e_err;
+	}
+
+	/* initialize SEV ops */
+	dev_dbg(dev, "init sev ops\n");
+	ret = sev_ops_init(sev);
+	if (ret) {
+		dev_err(dev, "failed to init sev ops\n");
+		goto e_irq;
+	}
+
+	sev_add_device(sev);
+
+	dev_notice(dev, "sev enabled\n");
+
+	return 0;
+
+e_irq:
+	psp_free_sev_irq(psp, sev);
+e_err:
+	psp->sev_data = NULL;
+
+	dev_notice(dev, "sev initialization failed\n");
+
+	return ret;
+}
+
+void sev_dev_destroy(struct psp_device *psp)
+{
+	struct sev_device *sev = psp->sev_data;
+
+	psp_free_sev_irq(psp, sev);
+
+	sev_ops_destroy(sev);
+
+	sev_del_device(sev);
+}
+
+int sev_dev_resume(struct psp_device *psp)
+{
+	return 0;
+}
+
+int sev_dev_suspend(struct psp_device *psp, pm_message_t state)
+{
+	return 0;
+}
+
+int sev_issue_cmd(int cmd, void *data, unsigned int timeout, int *psp_ret)
+{
+	struct sev_device *sev = get_sev_master_device();
+	unsigned int phys_lsb, phys_msb;
+	unsigned int reg, ret;
+
+	if (!sev)
+		return -ENODEV;
+
+	if (psp_ret)
+		*psp_ret = 0;
+
+	/* Set the physical address for the PSP */
+	phys_lsb = data ? lower_32_bits(__psp_pa(data)) : 0;
+	phys_msb = data ? upper_32_bits(__psp_pa(data)) : 0;
+
+	dev_dbg(sev->dev, "sev command id %#x buffer 0x%08x%08x\n",
+			cmd, phys_msb, phys_lsb);
+
+	/* Only one command at a time... */
+	mutex_lock(&sev_cmd_mutex);
+
+	iowrite32(phys_lsb, sev->io_regs + PSP_CMDBUFF_ADDR_LO);
+	iowrite32(phys_msb, sev->io_regs + PSP_CMDBUFF_ADDR_HI);
+	wmb();
+
+	reg = cmd;
+	reg <<= PSP_CMDRESP_CMD_SHIFT;
+	reg |= psp_poll ? 0 : PSP_CMDRESP_IOC;
+	iowrite32(reg, sev->io_regs + PSP_CMDRESP);
+
+	ret = sev_wait_cmd(sev, timeout, &reg);
+	if (ret)
+		goto unlock;
+
+	if (psp_ret)
+		*psp_ret = reg & PSP_CMDRESP_ERR_MASK;
+
+	if (reg & PSP_CMDRESP_ERR_MASK) {
+		dev_dbg(sev->dev, "sev command %u failed (%#010x)\n",
+			cmd, reg & PSP_CMDRESP_ERR_MASK);
+		ret = -EIO;
+	}
+
+unlock:
+	mutex_unlock(&sev_cmd_mutex);
+
+	return ret;
+}
+
+int sev_platform_init(struct sev_data_init *data, int *error)
+{
+	return sev_issue_cmd(SEV_CMD_INIT, data, SEV_DEFAULT_TIMEOUT, error);
+}
+EXPORT_SYMBOL_GPL(sev_platform_init);
+
+int sev_platform_shutdown(int *error)
+{
+	return sev_issue_cmd(SEV_CMD_SHUTDOWN, 0, SEV_DEFAULT_TIMEOUT, error);
+}
+EXPORT_SYMBOL_GPL(sev_platform_shutdown);
+
+int sev_platform_status(struct sev_data_status *data, int *error)
+{
+	return sev_issue_cmd(SEV_CMD_PLATFORM_STATUS, data,
+			SEV_DEFAULT_TIMEOUT, error);
+}
+EXPORT_SYMBOL_GPL(sev_platform_status);
+
+int sev_issue_cmd_external_user(struct file *filep, unsigned int cmd,
+				void *data, int timeout, int *error)
+{
+	if (!filep || filep->f_op != &sev_fops)
+		return -EBADF;
+
+	return sev_issue_cmd(cmd, data,
+			timeout ? timeout : SEV_DEFAULT_TIMEOUT, error);
+}
+EXPORT_SYMBOL_GPL(sev_issue_cmd_external_user);
+
+int sev_guest_deactivate(struct sev_data_deactivate *data, int *error)
+{
+	return sev_issue_cmd(SEV_CMD_DEACTIVATE, data,
+			SEV_DEFAULT_TIMEOUT, error);
+}
+EXPORT_SYMBOL_GPL(sev_guest_deactivate);
+
+int sev_guest_activate(struct sev_data_activate *data, int *error)
+{
+	return sev_issue_cmd(SEV_CMD_ACTIVATE, data,
+			SEV_DEFAULT_TIMEOUT, error);
+}
+EXPORT_SYMBOL_GPL(sev_guest_activate);
+
+int sev_guest_decommission(struct sev_data_decommission *data, int *error)
+{
+	return sev_issue_cmd(SEV_CMD_DECOMMISSION, data,
+			SEV_DEFAULT_TIMEOUT, error);
+}
+EXPORT_SYMBOL_GPL(sev_guest_decommission);
+
+int sev_guest_df_flush(int *error)
+{
+	return sev_issue_cmd(SEV_CMD_DF_FLUSH, 0,
+			SEV_DEFAULT_TIMEOUT, error);
+}
+EXPORT_SYMBOL_GPL(sev_guest_df_flush);
+
diff --git a/drivers/crypto/ccp/sev-dev.h b/drivers/crypto/ccp/sev-dev.h
new file mode 100644
index 0000000..0df6ead
--- /dev/null
+++ b/drivers/crypto/ccp/sev-dev.h
@@ -0,0 +1,67 @@
+/*
+ * AMD Secure Encrypted Virtualization (SEV) interface
+ *
+ * Copyright (C) 2013,2016 Advanced Micro Devices, Inc.
+ *
+ * Author: Brijesh Singh <brijesh.singh@amd.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#ifndef __SEV_DEV_H__
+#define __SEV_DEV_H__
+
+#include <linux/device.h>
+#include <linux/spinlock.h>
+#include <linux/mutex.h>
+#include <linux/list.h>
+#include <linux/wait.h>
+#include <linux/interrupt.h>
+#include <linux/irqreturn.h>
+#include <linux/miscdevice.h>
+
+#include <linux/psp-sev.h>
+
+#define PSP_C2PMSG(_num)		((_num) << 2)
+#define PSP_CMDRESP			PSP_C2PMSG(32)
+#define PSP_CMDBUFF_ADDR_LO		PSP_C2PMSG(56)
+#define PSP_CMDBUFF_ADDR_HI             PSP_C2PMSG(57)
+#define PSP_FEATURE_REG			PSP_C2PMSG(63)
+
+#define PSP_P2CMSG(_num)		(_num << 2)
+#define PSP_CMD_COMPLETE_REG		1
+#define PSP_CMD_COMPLETE		PSP_P2CMSG(PSP_CMD_COMPLETE_REG)
+
+#define MAX_PSP_NAME_LEN		16
+#define SEV_DEFAULT_TIMEOUT		5
+
+struct sev_device {
+	struct list_head entry;
+
+	struct dentry *debugfs;
+	struct miscdevice misc;
+
+	unsigned int id;
+	char name[MAX_PSP_NAME_LEN];
+
+	struct device *dev;
+	struct sp_device *sp;
+	struct psp_device *psp;
+
+	void __iomem *io_regs;
+
+	unsigned int int_rcvd;
+	wait_queue_head_t int_queue;
+};
+
+void sev_add_device(struct sev_device *sev);
+void sev_del_device(struct sev_device *sev);
+
+int sev_ops_init(struct sev_device *sev);
+void sev_ops_destroy(struct sev_device *sev);
+
+int sev_issue_cmd(int cmd, void *data, unsigned int timeout, int *error);
+
+#endif /* __SEV_DEV_H */
diff --git a/drivers/crypto/ccp/sev-ops.c b/drivers/crypto/ccp/sev-ops.c
new file mode 100644
index 0000000..727a8db
--- /dev/null
+++ b/drivers/crypto/ccp/sev-ops.c
@@ -0,0 +1,324 @@
+/*
+ * AMD Secure Encrypted Virtualization (SEV) command interface
+ *
+ * Copyright (C) 2016 Advanced Micro Devices, Inc.
+ *
+ * Author: Brijesh Singh <brijesh.singh@amd.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/kthread.h>
+#include <linux/sched.h>
+#include <linux/interrupt.h>
+#include <linux/spinlock.h>
+#include <linux/spinlock_types.h>
+#include <linux/types.h>
+#include <linux/mutex.h>
+#include <linux/uaccess.h>
+
+#include <uapi/linux/psp-sev.h>
+
+#include "psp-dev.h"
+#include "sev-dev.h"
+
+static int sev_ioctl_init(struct sev_issue_cmd *argp)
+{
+	int ret;
+	struct sev_data_init *data;
+
+	data = kzalloc(sizeof(*data), GFP_KERNEL);
+	if (!data)
+		return -ENOMEM;
+
+	ret = sev_platform_init(data, &argp->error);
+
+	kfree(data);
+	return ret;
+}
+
+static int sev_ioctl_platform_status(struct sev_issue_cmd *argp)
+{
+	int ret;
+	struct sev_data_status *data;
+
+	data = kzalloc(sizeof(*data), GFP_KERNEL);
+	if (!data)
+		return -ENOMEM;
+
+	ret = sev_platform_status(data, &argp->error);
+
+	if (copy_to_user((void *)argp->data, data, sizeof(*data)))
+		ret = -EFAULT;
+
+	kfree(data);
+	return ret;
+}
+
+static int sev_ioctl_pek_csr(struct sev_issue_cmd *argp)
+{
+	int ret;
+	void *csr_addr = NULL;
+	struct sev_data_pek_csr *data;
+	struct sev_user_data_pek_csr input;
+
+	if (copy_from_user(&input, (void *)argp->data,
+			sizeof(struct sev_user_data_pek_csr)))
+		return -EFAULT;
+
+	data = kzalloc(sizeof(*data), GFP_KERNEL);
+	if (!data)
+		return -ENOMEM;
+
+	/* copy PEK certificate from userspace */
+	if (input.address && input.length) {
+		csr_addr = kmalloc(input.length, GFP_KERNEL);
+		if (!csr_addr) {
+			ret = -ENOMEM;
+			goto e_err;
+		}
+		if (copy_from_user(csr_addr, (void *)input.address,
+				input.length)) {
+			ret = -EFAULT;
+			goto e_csr_free;
+		}
+
+		data->address = __psp_pa(csr_addr);
+		data->length = input.length;
+	}
+
+	ret = sev_issue_cmd(SEV_CMD_PEK_CSR,
+			data, SEV_DEFAULT_TIMEOUT, &argp->error);
+
+	input.length = data->length;
+
+	/* copy PEK certificate length to userspace */
+	if (copy_to_user((void *)argp->data, &input,
+			sizeof(struct sev_user_data_pek_csr)))
+		ret = -EFAULT;
+e_csr_free:
+	kfree(csr_addr);
+e_err:
+	kfree(data);
+	return ret;
+}
+
+static int sev_ioctl_pek_cert_import(struct sev_issue_cmd *argp)
+{
+	int ret;
+	struct sev_data_pek_cert_import *data;
+	struct sev_user_data_pek_cert_import input;
+	void *pek_cert, *oca_cert;
+
+	if (copy_from_user(&input, (void *)argp->data, sizeof(*data)))
+		return -EFAULT;
+
+	if (!input.pek_cert_address || !input.pek_cert_length ||
+		!input.oca_cert_address || !input.oca_cert_length)
+		return -EINVAL;
+
+	data = kzalloc(sizeof(*data), GFP_KERNEL);
+	if (!data)
+		return -ENOMEM;
+
+	/* copy PEK certificate from userspace */
+	pek_cert = kmalloc(input.pek_cert_length, GFP_KERNEL);
+	if (!pek_cert) {
+		ret = -ENOMEM;
+		goto e_free;
+	}
+	if (copy_from_user(pek_cert, (void *)input.pek_cert_address,
+				input.pek_cert_length)) {
+		ret = -EFAULT;
+		goto e_free_pek_cert;
+	}
+
+	data->pek_cert_address = __psp_pa(pek_cert);
+	data->pek_cert_length = input.pek_cert_length;
+
+	/* copy OCA certificate from userspace */
+	oca_cert = kmalloc(input.oca_cert_length, GFP_KERNEL);
+	if (!oca_cert) {
+		ret = -ENOMEM;
+		goto e_free_pek_cert;
+	}
+	if (copy_from_user(oca_cert, (void *)input.oca_cert_address,
+				input.oca_cert_length)) {
+		ret = -EFAULT;
+		goto e_free_oca_cert;
+	}
+
+	data->oca_cert_address = __psp_pa(oca_cert);
+	data->oca_cert_length = input.oca_cert_length;
+
+	ret = sev_issue_cmd(SEV_CMD_PEK_CERT_IMPORT,
+			data, SEV_DEFAULT_TIMEOUT, &argp->error);
+e_free_oca_cert:
+	kfree(oca_cert);
+e_free_pek_cert:
+	kfree(pek_cert);
+e_free:
+	kfree(data);
+	return ret;
+}
+
+static int sev_ioctl_pdh_cert_export(struct sev_issue_cmd *argp)
+{
+	int ret;
+	struct sev_data_pdh_cert_export *data;
+	struct sev_user_data_pdh_cert_export input;
+	void *pdh_cert = NULL, *cert_chain = NULL;
+
+	if (copy_from_user(&input, (void *)argp->data, sizeof(*data)))
+		return -EFAULT;
+
+	data = kzalloc(sizeof(*data), GFP_KERNEL);
+	if (!data)
+		return -ENOMEM;
+
+	/* copy pdh certificate from userspace */
+	if (input.pdh_cert_length && input.pdh_cert_address) {
+		pdh_cert = kmalloc(input.pdh_cert_length, GFP_KERNEL);
+		if (!pdh_cert) {
+			ret = -ENOMEM;
+			goto e_free;
+		}
+		if (copy_from_user(pdh_cert, (void *)input.pdh_cert_address,
+					input.pdh_cert_length)) {
+			ret = -EFAULT;
+			goto e_free_pdh_cert;
+		}
+
+		data->pdh_cert_address = __psp_pa(pdh_cert);
+		data->pdh_cert_length = input.pdh_cert_length;
+	}
+
+	/* copy cert_chain certificate from userspace */
+	if (input.cert_chain_length && input.cert_chain_address) {
+		cert_chain = kmalloc(input.cert_chain_length, GFP_KERNEL);
+		if (!cert_chain) {
+			ret = -ENOMEM;
+			goto e_free_pdh_cert;
+		}
+		if (copy_from_user(cert_chain, (void *)input.cert_chain_address,
+					input.cert_chain_length)) {
+			ret = -EFAULT;
+			goto e_free_cert_chain;
+		}
+
+		data->cert_chain_address = __psp_pa(cert_chain);
+		data->cert_chain_length = input.cert_chain_length;
+	}
+
+	ret = sev_issue_cmd(SEV_CMD_PDH_CERT_EXPORT,
+			data, SEV_DEFAULT_TIMEOUT, &argp->error);
+
+	input.cert_chain_length = data->cert_chain_length;
+	input.pdh_cert_length = data->pdh_cert_length;
+
+	/* copy certificate length to userspace */
+	if (copy_to_user((void *)argp->data, &input,
+			sizeof(struct sev_user_data_pek_csr)))
+		ret = -EFAULT;
+
+e_free_cert_chain:
+	kfree(cert_chain);
+e_free_pdh_cert:
+	kfree(pdh_cert);
+e_free:
+	kfree(data);
+	return ret;
+}
+
+static long sev_ioctl(struct file *file, unsigned int ioctl, unsigned long arg)
+{
+	int ret = -EFAULT;
+	void __user *argp = (void __user *)arg;
+	struct sev_issue_cmd input;
+
+	if (ioctl != SEV_ISSUE_CMD)
+		return -EINVAL;
+
+	if (copy_from_user(&input, argp, sizeof(struct sev_issue_cmd)))
+		return -EFAULT;
+
+	if (input.cmd > SEV_CMD_MAX)
+		return -EINVAL;
+
+	switch (input.cmd) {
+
+	case SEV_USER_CMD_INIT: {
+		ret = sev_ioctl_init(&input);
+		break;
+	}
+	case SEV_USER_CMD_SHUTDOWN: {
+		ret = sev_platform_shutdown(&input.error);
+		break;
+	}
+	case SEV_USER_CMD_FACTORY_RESET: {
+		ret = sev_issue_cmd(SEV_CMD_FACTORY_RESET, 0,
+				SEV_DEFAULT_TIMEOUT, &input.error);
+		break;
+	}
+	case SEV_USER_CMD_PLATFORM_STATUS: {
+		ret = sev_ioctl_platform_status(&input);
+		break;
+	}
+	case SEV_USER_CMD_PEK_GEN: {
+		ret = sev_issue_cmd(SEV_CMD_PEK_GEN, 0,
+				SEV_DEFAULT_TIMEOUT, &input.error);
+		break;
+	}
+	case SEV_USER_CMD_PDH_GEN: {
+		ret = sev_issue_cmd(SEV_CMD_PDH_GEN, 0,
+				SEV_DEFAULT_TIMEOUT, &input.error);
+		break;
+	}
+	case SEV_USER_CMD_PEK_CSR: {
+		ret = sev_ioctl_pek_csr(&input);
+		break;
+	}
+	case SEV_USER_CMD_PEK_CERT_IMPORT: {
+		ret = sev_ioctl_pek_cert_import(&input);
+		break;
+	}
+	case SEV_USER_CMD_PDH_CERT_EXPORT: {
+		ret = sev_ioctl_pdh_cert_export(&input);
+		break;
+	}
+	default:
+		ret = -EINVAL;
+		break;
+	}
+
+	if (copy_to_user(argp, &input, sizeof(struct sev_issue_cmd)))
+		ret = -EFAULT;
+
+	return ret;
+}
+
+const struct file_operations sev_fops = {
+	.owner	= THIS_MODULE,
+	.unlocked_ioctl = sev_ioctl,
+};
+
+int sev_ops_init(struct sev_device *sev)
+{
+	struct miscdevice *misc = &sev->misc;
+
+	misc->minor = MISC_DYNAMIC_MINOR;
+	misc->name = sev->name;
+	misc->fops = &sev_fops;
+
+	return misc_register(misc);
+}
+
+void sev_ops_destroy(struct sev_device *sev)
+{
+	misc_deregister(&sev->misc);
+}
+
diff --git a/include/linux/psp-sev.h b/include/linux/psp-sev.h
new file mode 100644
index 0000000..acce6ed
--- /dev/null
+++ b/include/linux/psp-sev.h
@@ -0,0 +1,672 @@
+/*
+ * AMD Secure Encrypted Virtualization (SEV) driver interface
+ *
+ * Copyright (C) 2016 Advanced Micro Devices, Inc.
+ *
+ * Author: Brijesh Singh <brijesh.singh@amd.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#ifndef __PSP_SEV_H__
+#define __PSP_SEV_H__
+
+#ifdef CONFIG_X86
+#include <linux/mem_encrypt.h>
+
+#define __psp_pa(x)	__sme_pa(x)
+#else
+#define __psp_pa(x)	__pa(x)
+#endif
+
+/**
+ * SEV platform and guest management commands
+ */
+enum sev_cmd {
+	/* platform commands */
+	SEV_CMD_INIT			= 0x001,
+	SEV_CMD_SHUTDOWN		= 0x002,
+	SEV_CMD_FACTORY_RESET		= 0x003,
+	SEV_CMD_PLATFORM_STATUS		= 0x004,
+	SEV_CMD_PEK_GEN			= 0x005,
+	SEV_CMD_PEK_CSR			= 0x006,
+	SEV_CMD_PEK_CERT_IMPORT		= 0x007,
+	SEV_CMD_PDH_GEN			= 0x008,
+	SEV_CMD_PDH_CERT_EXPORT		= 0x009,
+	SEV_CMD_DF_FLUSH		= 0x00A,
+
+	/* Guest commands */
+	SEV_CMD_DECOMMISSION		= 0x020,
+	SEV_CMD_ACTIVATE		= 0x021,
+	SEV_CMD_DEACTIVATE		= 0x022,
+	SEV_CMD_GUEST_STATUS		= 0x023,
+
+	/* Guest launch commands */
+	SEV_CMD_LAUNCH_START		= 0x030,
+	SEV_CMD_LAUNCH_UPDATE_DATA	= 0x031,
+	SEV_CMD_LAUNCH_UPDATE_VMSA	= 0x032,
+	SEV_CMD_LAUNCH_MEASURE		= 0x033,
+	SEV_CMD_LAUNCH_UPDATE_SECRET	= 0x034,
+	SEV_CMD_LAUNCH_FINISH		= 0x035,
+
+	/* Guest migration commands (outgoing) */
+	SEV_CMD_SEND_START		= 0x040,
+	SEV_CMD_SEND_UPDATE_DATA	= 0x041,
+	SEV_CMD_SEND_UPDATE_VMSA	= 0x042,
+	SEV_CMD_SEND_FINISH		= 0x043,
+
+	/* Guest migration commands (incoming) */
+	SEV_CMD_RECEIVE_START		= 0x050,
+	SEV_CMD_RECEIVE_UPDATE_DATA	= 0x051,
+	SEV_CMD_RECEIVE_UPDATE_VMSA	= 0x052,
+	SEV_CMD_RECEIVE_FINISH		= 0x053,
+
+	/* Guest debug commands */
+	SEV_CMD_DBG_DECRYPT		= 0x060,
+	SEV_CMD_DBG_ENCRYPT		= 0x061,
+
+	SEV_CMD_MAX,
+};
+
+/**
+ * status code returned by the commands
+ */
+enum psp_ret_code {
+	SEV_RET_SUCCESS = 0,
+	SEV_RET_INVALID_PLATFORM_STATE,
+	SEV_RET_INVALID_GUEST_STATE,
+	SEV_RET_INAVLID_CONFIG,
+	SEV_RET_INVALID_LENGTH,
+	SEV_RET_ALREADY_OWNED,
+	SEV_RET_INVALID_CERTIFICATE,
+	SEV_RET_POLICY_FAILURE,
+	SEV_RET_INACTIVE,
+	SEV_RET_INVALID_ADDRESS,
+	SEV_RET_BAD_SIGNATURE,
+	SEV_RET_BAD_MEASUREMENT,
+	SEV_RET_ASID_OWNED,
+	SEV_RET_INVALID_ASID,
+	SEV_RET_WBINVD_REQUIRED,
+	SEV_RET_DFFLUSH_REQUIRED,
+	SEV_RET_INVALID_GUEST,
+	SEV_RET_INVALID_COMMAND,
+	SEV_RET_ACTIVE,
+	SEV_RET_HWSEV_RET_PLATFORM,
+	SEV_RET_HWSEV_RET_UNSAFE,
+	SEV_RET_UNSUPPORTED,
+	SEV_RET_MAX,
+};
+
+/**
+ * struct sev_data_init - INIT command parameters
+ *
+ * @flags: processing flags
+ * @tmr_address: system physical address used for SEV-ES
+ * @tmr_length: length of tmr_address
+ */
+struct sev_data_init {
+	__u32 flags;				/* In */
+	__u32 reserved;				/* In */
+	__u64 tmr_address;			/* In */
+	__u32 tmr_length;			/* In */
+};
+
+/**
+ * struct sev_data_status - PLATFORM_STATUS command parameters
+ *
+ * @major: major API version
+ * @minor: minor API version
+ * @state: platform state
+ * @owner: self-owned or externally owned
+ * @config: platform config flags
+ * @guest_count: number of active guests
+ */
+struct sev_data_status {
+	__u8 api_major;				/* Out */
+	__u8 api_minor;				/* Out */
+	__u8 state;				/* Out */
+	__u8 owner;				/* Out */
+	__u32 config;				/* Out */
+	__u32 guest_count;			/* Out */
+};
+
+/**
+ * struct sev_data_pek_csr - PEK_CSR command parameters
+ *
+ * @address: PEK certificate chain
+ * @length: length of certificate
+ */
+struct sev_data_pek_csr {
+	__u64 address;					/* In */
+	__u32 length;					/* In/Out */
+};
+
+/**
+ * struct sev_data_cert_import - PEK_CERT_IMPORT command parameters
+ *
+ * @pek_address: PEK certificate chain
+ * @pek_length: length of PEK certificate
+ * @oca_address: OCA certificate chain
+ * @oca_length: length of OCA certificate
+ */
+struct sev_data_pek_cert_import {
+	__u64 pek_cert_address;				/* In */
+	__u32 pek_cert_length;				/* In */
+	__u32 reserved;					/* In */
+	__u64 oca_cert_address;				/* In */
+	__u32 oca_cert_length;				/* In */
+};
+
+/**
+ * struct sev_data_pdh_cert_export - PDH_CERT_EXPORT command parameters
+ *
+ * @pdh_address: PDH certificate address
+ * @pdh_length: length of PDH certificate
+ * @cert_chain_address: PDH certificate chain
+ * @cert_chain_length: length of PDH certificate chain
+ */
+struct sev_data_pdh_cert_export {
+	__u64 pdh_cert_address;				/* In */
+	__u32 pdh_cert_length;				/* In/Out */
+	__u32 reserved;					/* In */
+	__u64 cert_chain_address;			/* In */
+	__u32 cert_chain_length;			/* In/Out */
+};
+
+/**
+ * struct sev_data_decommission - DECOMMISSION command parameters
+ *
+ * @handle: handle of the VM to decommission
+ */
+struct sev_data_decommission {
+	u32 handle;				/* In */
+};
+
+/**
+ * struct sev_data_activate - ACTIVATE command parameters
+ *
+ * @handle: handle of the VM to activate
+ * @asid: asid assigned to the VM
+ */
+struct sev_data_activate {
+	u32 handle;				/* In */
+	u32 asid;				/* In */
+};
+
+/**
+ * struct sev_data_deactivate - DEACTIVATE command parameters
+ *
+ * @handle: handle of the VM to deactivate
+ */
+struct sev_data_deactivate {
+	u32 handle;				/* In */
+};
+
+/**
+ * struct sev_data_guest_status - SEV GUEST_STATUS command parameters
+ *
+ * @handle: handle of the VM to retrieve status
+ * @policy: policy information for the VM
+ * @asid: current ASID of the VM
+ * @state: current state of the VM
+ */
+struct sev_data_guest_status {
+	u32 handle;				/* In */
+	u32 policy;				/* Out */
+	u32 asid;				/* Out */
+	u8 state;				/* Out */
+};
+
+/**
+ * struct sev_data_launch_start - LAUNCH_START command parameters
+ *
+ * @handle: handle assigned to the VM
+ * @policy: guest launch policy
+ * @dh_cert_address: physical address of DH certificate blob
+ * @dh_cert_length: length of DH certificate blob
+ * @session_address: physical address of session parameters
+ * @session_len: length of session parameters
+ */
+struct sev_data_launch_start {
+	u32 handle;				/* In/Out */
+	u32 policy;				/* In */
+	u64 dh_cert_address;			/* In */
+	u32 dh_cert_length;			/* In */
+	u32 reserved;				/* In */
+	u64 session_data_address;		/* In */
+	u32 session_data_length;		/* In */
+};
+
+/**
+ * struct sev_data_launch_update_data - LAUNCH_UPDATE_DATA command parameter
+ *
+ * @handle: handle of the VM to update
+ * @length: length of memory to be encrypted
+ * @address: physical address of memory region to encrypt
+ */
+struct sev_data_launch_update_data {
+	u32 handle;				/* In */
+	u32 reserved;
+	u64 address;				/* In */
+	u32 length;				/* In */
+};
+
+/**
+ * struct sev_data_launch_update_vmsa - LAUNCH_UPDATE_VMSA command
+ *
+ * @handle: handle of the VM
+ * @address: physical address of memory region to encrypt
+ * @length: length of memory region to encrypt
+ */
+struct sev_data_launch_update_vmsa {
+	u32 handle;				/* In */
+	u32 reserved;
+	u64 address;				/* In */
+	u32 length;				/* In */
+};
+
+/**
+ * struct sev_data_launch_measure - LAUNCH_MEASURE command parameters
+ *
+ * @handle: handle of the VM to process
+ * @address: physical address containing the measurement blob
+ * @length: length of measurement blob
+ */
+struct sev_data_launch_measure {
+	u32 handle;				/* In */
+	u32 reserved;
+	u64 address;				/* In */
+	u32 length;				/* In/Out */
+};
+
+/**
+ * struct sev_data_launch_secret - LAUNCH_SECRET command parameters
+ *
+ * @handle: handle of the VM to process
+ * @hdr_address: physical address containing the packet header
+ * @hdr_length: length of packet header
+ * @guest_address: system physical address of guest memory region
+ * @guest_length: length of guest_paddr
+ * @trans_address: physical address of transport memory buffer
+ * @trans_length: length of transport memory buffer
+ */
+struct sev_data_launch_secret {
+	u32 handle;				/* In */
+	u32 reserved1;
+	u64 hdr_address;			/* In */
+	u32 hdr_length;				/* In */
+	u32 reserved2;
+	u64 guest_address;			/* In */
+	u32 guest_length;			/* In */
+	u32 reserved3;
+	u64 trans_address;			/* In */
+	u32 trans_length;			/* In */
+};
+
+/**
+ * struct sev_data_launch_finish - LAUNCH_FINISH command parameters
+ *
+ * @handle: handle of the VM to process
+ */
+struct sev_data_launch_finish {
+	u32 handle;				/* In */
+};
+
+/**
+ * struct sev_data_send_start - SEND_START command parameters
+ *
+ * @handle: handle of the VM to process
+ * @pdh_cert_address: physical address containing PDH certificate
+ * @pdh_cert_length: length of PDH certificate
+ * @plat_certs_address: physical address containing platform certificate
+ * @plat_certs_length: length of platform certificate
+ * @amd_certs_address: physical address containing AMD certificate
+ * @amd_certs_length: length of AMD certificate
+ * @session_data_address: physical address containing Session data
+ * @session_length: length of session data
+ */
+struct sev_data_send_start {
+	u32 handle;				/* In */
+	u32 reserved1;
+	u64 pdh_cert_address;			/* In */
+	u32 pdh_cert_length;			/* In/Out */
+	u32 reserved2;
+	u64 plat_cert_address;			/* In */
+	u32 plat_cert_length;			/* In/Out */
+	u32 reserved3;
+	u64 amd_cert_address;			/* In */
+	u32 amd_cert_length;			/* In/Out */
+	u32 reserved4;
+	u64 session_data_address;		/* In */
+	u32 session_data_length;		/* In/Out */
+};
+
+/**
+ * struct sev_data_send_update - SEND_UPDATE_DATA command
+ *
+ * @handle: handle of the VM to process
+ * @hdr_address: physical address containing packet header
+ * @hdr_length: length of packet header
+ * @guest_address: physical address of guest memory region to send
+ * @guest_length: length of guest memory region to send
+ * @trans_address: physical address of host memory region
+ * @trans_length: length of host memory region
+ */
+struct sev_data_send_update_data {
+	u32 handle;				/* In */
+	u32 reserved1;
+	u64 hdr_address;			/* In */
+	u32 hdr_length;				/* In/Out */
+	u32 reserved2;
+	u64 guest_address;			/* In */
+	u32 guest_length;			/* In */
+	u32 reserved3;
+	u64 trans_address;			/* In */
+	u32 trans_length;			/* In */
+};
+
+/**
+ * struct sev_data_send_update - SEND_UPDATE_VMSA command
+ *
+ * @handle: handle of the VM to process
+ * @hdr_address: physical address containing packet header
+ * @hdr_length: length of packet header
+ * @guest_address: physical address of guest memory region to send
+ * @guest_length: length of guest memory region to send
+ * @trans_address: physical address of host memory region
+ * @trans_length: length of host memory region
+ */
+struct sev_data_send_update_vmsa {
+	u32 handle;				/* In */
+	u64 hdr_address;			/* In */
+	u32 hdr_length;				/* In/Out */
+	u32 reserved2;
+	u64 guest_address;			/* In */
+	u32 guest_length;			/* In */
+	u32 reserved3;
+	u64 trans_address;			/* In */
+	u32 trans_length;			/* In */
+};
+
+/**
+ * struct sev_data_send_finish - SEND_FINISH command parameters
+ *
+ * @handle: handle of the VM to process
+ */
+struct sev_data_send_finish {
+	u32 handle;				/* In */
+};
+
+/**
+ * struct sev_data_receive_start - RECEIVE_START command parameters
+ *
+ * @handle: handle of the VM to perform receive operation
+ * @pdh_cert_address: system physical address containing PDH certificate blob
+ * @pdh_cert_length: length of PDH certificate blob
+ * @session_address: system physical address containing session blob
+ * @session_length: length of session blob
+ */
+struct sev_data_receive_start {
+	u32 handle;				/* In/Out */
+	u32 reserved1;
+	u64 pdh_cert_address;			/* In */
+	u32 pdh_cert_length;			/* In */
+	u32 reserved2;
+	u64 session_data_address;		/* In */
+	u32 session_data_length;		/* In/Out */
+};
+
+/**
+ * struct sev_data_receive_update_data - RECEIVE_UPDATE_DATA command parameters
+ *
+ * @handle: handle of the VM to update
+ * @hdr_address: physical address containing packet header blob
+ * @hdr_length: length of packet header
+ * @guest_address: system physical address of guest memory region
+ * @guest_length: length of guest memory region
+ * @trans_address: system physical address of transport buffer
+ * @trans_length: length of transport buffer
+ */
+struct sev_data_receive_update_data {
+	u32 handle;				/* In */
+	u32 reserved1;
+	u64 hdr_address;			/* In */
+	u32 hdr_length;				/* In */
+	u32 reserved2;
+	u64 guest_address;			/* In */
+	u32 guest_length;			/* In */
+	u32 reserved3;
+	u64 trans_address;			/* In */
+	u32 trans_length;			/* In */
+};
+
+/**
+ * struct sev_data_receive_update_vmsa - RECEIVE_UPDATE_VMSA command parameters
+ *
+ * @handle: handle of the VM to update
+ * @hdr_address: physical address containing packet header blob
+ * @hdr_length: length of packet header
+ * @guest_address: system physical address of guest memory region
+ * @guest_length: length of guest memory region
+ * @trans_address: system physical address of transport buffer
+ * @trans_length: length of transport buffer
+ */
+struct sev_data_receive_update_vmsa {
+	u32 handle;				/* In */
+	u32 reserved1;
+	u64 hdr_address;			/* In */
+	u32 hdr_length;				/* In */
+	u32 reserved2;
+	u64 guest_address;			/* In */
+	u32 guest_length;			/* In */
+	u32 reserved3;
+	u64 trans_address;			/* In */
+	u32 trans_length;			/* In */
+};
+
+/**
+ * struct sev_data_receive_finish - RECEIVE_FINISH command parameters
+ *
+ * @handle: handle of the VM to finish
+ */
+struct sev_data_receive_finish {
+	u32 handle;				/* In */
+};
+
+/**
+ * struct sev_data_dbg - DBG_ENCRYPT/DBG_DECRYPT command parameters
+ *
+ * @handle: handle of the VM to perform debug operation
+ * @src_addr: source address of data to operate on
+ * @dst_addr: destination address of data to operate on
+ * @length: length of data to operate on
+ */
+struct sev_data_dbg {
+	u32 handle;				/* In */
+	u32 reserved;
+	u64 src_addr;				/* In */
+	u64 dst_addr;				/* In */
+	u32 length;				/* In */
+};
+
+#if defined(CONFIG_CRYPTO_DEV_SEV)
+
+/**
+ * sev_platform_init - perform SEV INIT command
+ *
+ * @init: sev_data_init structure to be processed
+ * @error: SEV command return code
+ *
+ * Returns:
+ * 0 if the SEV successfully processed the command
+ * -%ENODEV    if the SEV device is not available
+ * -%ENOTSUPP  if the SEV does not support SEV
+ * -%ETIMEDOUT if the SEV command timed out
+ * -%EIO       if the SEV returned a non-zero return code
+ */
+int sev_platform_init(struct sev_data_init *init, int *error);
+
+/**
+ * sev_platform_shutdown - perform SEV SHUTDOWN command
+ *
+ * @error: SEV command return code
+ *
+ * Returns:
+ * 0 if the SEV successfully processed the command
+ * -%ENODEV    if the SEV device is not available
+ * -%ENOTSUPP  if the SEV does not support SEV
+ * -%ETIMEDOUT if the SEV command timed out
+ * -%EIO       if the SEV returned a non-zero return code
+ */
+int sev_platform_shutdown(int *error);
+
+/**
+ * sev_platform_status - perform SEV PLATFORM_STATUS command
+ *
+ * @init: sev_data_status structure to be processed
+ * @error: SEV command return code
+ *
+ * Returns:
+ * 0 if the SEV successfully processed the command
+ * -%ENODEV    if the SEV device is not available
+ * -%ENOTSUPP  if the SEV does not support SEV
+ * -%ETIMEDOUT if the SEV command timed out
+ * -%EIO       if the SEV returned a non-zero return code
+ */
+int sev_platform_status(struct sev_data_status *status, int *error);
+
+/**
+ * sev_issue_cmd_external_user - issue SEV command by other driver
+ *
+ * The function can be used by other drivers to issue a SEV command on
+ * behalf by userspace. The caller must pass a valid SEV file descriptor
+ * so that we know that caller has access to SEV device.
+ *
+ * @filep - SEV device file pointer
+ * @cmd - command to issue
+ * @data - command buffer
+ * @timeout - If zero then use default timeout
+ * @error: SEV command return code
+ *
+ * Returns:
+ * 0 if the SEV successfully processed the command
+ * -%ENODEV    if the SEV device is not available
+ * -%ENOTSUPP  if the SEV does not support SEV
+ * -%ETIMEDOUT if the SEV command timed out
+ * -%EIO       if the SEV returned a non-zero return code
+ * -%EINVAL    if the SEV file descriptor is not valid
+ */
+int sev_issue_cmd_external_user(struct file *filep, unsigned int id,
+				void *data, int timeout, int *error);
+
+/**
+ * sev_guest_deactivate - perform SEV DEACTIVATE command
+ *
+ * @deactivate: sev_data_deactivate structure to be processed
+ * @sev_ret: sev command return code
+ *
+ * Returns:
+ * 0 if the sev successfully processed the command
+ * -%ENODEV    if the sev device is not available
+ * -%ENOTSUPP  if the sev does not support SEV
+ * -%ETIMEDOUT if the sev command timed out
+ * -%EIO       if the sev returned a non-zero return code
+ */
+int sev_guest_deactivate(struct sev_data_deactivate *data, int *error);
+
+/**
+ * sev_guest_activate - perform SEV ACTIVATE command
+ *
+ * @activate: sev_data_activate structure to be processed
+ * @sev_ret: sev command return code
+ *
+ * Returns:
+ * 0 if the sev successfully processed the command
+ * -%ENODEV    if the sev device is not available
+ * -%ENOTSUPP  if the sev does not support SEV
+ * -%ETIMEDOUT if the sev command timed out
+ * -%EIO       if the sev returned a non-zero return code
+ */
+int sev_guest_activate(struct sev_data_activate *data, int *error);
+
+/**
+ * sev_guest_df_flush - perform SEV DF_FLUSH command
+ *
+ * @sev_ret: sev command return code
+ *
+ * Returns:
+ * 0 if the sev successfully processed the command
+ * -%ENODEV    if the sev device is not available
+ * -%ENOTSUPP  if the sev does not support SEV
+ * -%ETIMEDOUT if the sev command timed out
+ * -%EIO       if the sev returned a non-zero return code
+ */
+int sev_guest_df_flush(int *error);
+
+/**
+ * sev_guest_decommission - perform SEV DECOMMISSION command
+ *
+ * @decommission: sev_data_decommission structure to be processed
+ * @sev_ret: sev command return code
+ *
+ * Returns:
+ * 0 if the sev successfully processed the command
+ * -%ENODEV    if the sev device is not available
+ * -%ENOTSUPP  if the sev does not support SEV
+ * -%ETIMEDOUT if the sev command timed out
+ * -%EIO       if the sev returned a non-zero return code
+ */
+int sev_guest_decommission(struct sev_data_decommission *data, int *error);
+
+#else	/* !CONFIG_CRYPTO_DEV_SEV */
+
+static inline int sev_platform_status(struct sev_data_status *status,
+				      int *error)
+{
+	return -ENODEV;
+}
+
+static inline int sev_platform_init(struct sev_data_init *init, int *error)
+{
+	return -ENODEV;
+}
+
+static inline int sev_platform_shutdown(int *error)
+{
+	return -ENODEV;
+}
+
+static inline int sev_issue_cmd_external_user(int fd, unsigned int id,
+					void *data, int timeout, int *error)
+{
+	return -ENODEV;
+}
+
+static inline int sev_guest_deactivate(struct sev_data_deactivate *data,
+					int *error)
+{
+	return -ENODEV;
+}
+
+static inline int sev_guest_decommission(struct sev_data_decommission *data,
+					int *error)
+{
+	return -ENODEV;
+}
+
+static inline int sev_guest_activate(struct sev_data_activate *data,
+					int *error)
+{
+	return -ENODEV;
+}
+
+static inline int sev_guest_df_flush(int *error)
+{
+	return -ENODEV;
+}
+
+#endif	/* CONFIG_CRYPTO_DEV_SEV */
+
+#endif	/* __PSP_SEV_H__ */
diff --git a/include/uapi/linux/Kbuild b/include/uapi/linux/Kbuild
index f330ba4..2e15ea7 100644
--- a/include/uapi/linux/Kbuild
+++ b/include/uapi/linux/Kbuild
@@ -481,3 +481,4 @@ header-y += xilinx-v4l2-controls.h
 header-y += zorro.h
 header-y += zorro_ids.h
 header-y += userfaultfd.h
+header-y += psp-sev.h
diff --git a/include/uapi/linux/psp-sev.h b/include/uapi/linux/psp-sev.h
new file mode 100644
index 0000000..050976d
--- /dev/null
+++ b/include/uapi/linux/psp-sev.h
@@ -0,0 +1,123 @@
+
+/*
+ * Userspace interface for AMD Secure Encrypted Virtualization (SEV)
+ *
+ * Copyright (C) 2016 Advanced Micro Devices, Inc.
+ *
+ * Author: Brijesh Singh <brijesh.singh@amd.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#ifndef __PSP_SEV_USER_H__
+#define __PSP_SEV_USER_H__
+
+#include <linux/types.h>
+
+/**
+ * SEV platform commands
+ */
+enum {
+	SEV_USER_CMD_INIT = 0,
+	SEV_USER_CMD_SHUTDOWN,
+	SEV_USER_CMD_FACTORY_RESET,
+	SEV_USER_CMD_PLATFORM_STATUS,
+	SEV_USER_CMD_PEK_GEN,
+	SEV_USER_CMD_PEK_CSR,
+	SEV_USER_CMD_PDH_GEN,
+	SEV_USER_CMD_PDH_CERT_EXPORT,
+	SEV_USER_CMD_PEK_CERT_IMPORT,
+
+	SEV_USER_CMD_MAX,
+};
+
+/**
+ * struct sev_user_data_init - INIT command parameters
+ *
+ * @flags: processing flags
+ */
+struct sev_user_data_init {
+	__u32 flags;				/* In */
+};
+
+/**
+ * struct sev_user_data_status - PLATFORM_STATUS command parameters
+ *
+ * @major: major API version
+ * @minor: minor API version
+ * @state: platform state
+ * @owner: self-owned or externally owned
+ * @config: platform config flags
+ * @guest_count: number of active guests
+ */
+struct sev_user_data_status {
+	__u8 api_major;				/* Out */
+	__u8 api_minor;				/* Out */
+	__u8 state;				/* Out */
+	__u8 owner;				/* Out */
+	__u32 config;				/* Out */
+	__u32 guest_count;			/* Out */
+};
+
+/**
+ * struct sev_user_data_pek_csr - PEK_CSR command parameters
+ *
+ * @address: PEK certificate chain
+ * @length: length of certificate
+ */
+struct sev_user_data_pek_csr {
+	__u64 address;					/* In */
+	__u32 length;					/* In/Out */
+};
+
+/**
+ * q
+ * struct sev_user_data_cert_import - PEK_CERT_IMPORT command parameters
+ *
+ * @pek_address: PEK certificate chain
+ * @pek_length: length of PEK certificate
+ * @oca_address: OCA certificate chain
+ * @oca_length: length of OCA certificate
+ */
+struct sev_user_data_pek_cert_import {
+	__u64 pek_cert_address;				/* In */
+	__u32 pek_cert_length;				/* In */
+	__u64 oca_cert_address;				/* In */
+	__u32 oca_cert_length;				/* In */
+};
+
+/**
+ * struct sev_user_data_pdh_cert_export - PDH_CERT_EXPORT command parameters
+ *
+ * @pdh_address: PDH certificate address
+ * @pdh_length: length of PDH certificate
+ * @cert_chain_address: PDH certificate chain
+ * @cert_chain_length: length of PDH certificate chain
+ */
+struct sev_user_data_pdh_cert_export {
+	__u64 pdh_cert_address;				/* In */
+	__u32 pdh_cert_length;				/* In/Out */
+	__u64 cert_chain_address;			/* In */
+	__u32 cert_chain_length;			/* In/Out */
+};
+
+/**
+ * struct sev_issue_cmd - SEV ioctl parameters
+ *
+ * @cmd: SEV commands to execute
+ * @opaque: pointer to the command structure
+ * @error: SEV FW return code on failure
+ */
+struct sev_issue_cmd {
+	__u32 cmd;					/* In */
+	__u64 data;					/* In */
+	__u32 error;					/* Out */
+};
+
+#define SEV_IOC_TYPE		'S'
+#define SEV_ISSUE_CMD	_IOWR(SEV_IOC_TYPE, 0x0, struct sev_issue_cmd)
+
+#endif /* __PSP_USER_SEV_H */
+

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
