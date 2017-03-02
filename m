Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id D45186B03AC
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 10:16:42 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id 62so62292406oih.5
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 07:16:42 -0800 (PST)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0081.outbound.protection.outlook.com. [104.47.38.81])
        by mx.google.com with ESMTPS id u42si3544419oth.195.2017.03.02.07.16.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 02 Mar 2017 07:16:41 -0800 (PST)
Subject: [RFC PATCH v2 20/32] crypto: ccp: Add Platform Security Processor
 (PSP) interface support
From: Brijesh Singh <brijesh.singh@amd.com>
Date: Thu, 2 Mar 2017 10:16:32 -0500
Message-ID: <148846779224.2349.7159735938287530197.stgit@brijesh-build-machine>
In-Reply-To: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
References: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: simon.guinot@sequanux.org, linux-efi@vger.kernel.org, brijesh.singh@amd.com, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linux-pci@vger.kernel.org, linus.walleij@linaro.org, gary.hook@amd.com, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, cl@linux.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, peterz@infradead.org, piotr.luc@intel.com, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, bp@suse.de, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, arnd@arndb.de, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, luto@kernel.org, devel@linuxdriverproject.org, bhelgaas@google.com, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, mst@redhat.com, linux-crypto@vger.kernel.org, tj@kernel.org, pbonzini@redhat.com, akpm@linux-foundation.org, davem@davemloft.net

AMD Platform Security Processor (PSP) is a dedicated processor that
provides the support for encrypting the guest memory in a Secure Encrypted
Virtualiztion (SEV) mode, along with software-based Tursted Executation
Environment (TEE) to enable the third-party tursted applications.

Signed-off-by: Brijesh Singh <brijesh.singh@amd.com>
---
 drivers/crypto/ccp/Kconfig   |    7 +
 drivers/crypto/ccp/Makefile  |    1 
 drivers/crypto/ccp/psp-dev.c |  211 ++++++++++++++++++++++++++++++++++++++++++
 drivers/crypto/ccp/psp-dev.h |  102 ++++++++++++++++++++
 drivers/crypto/ccp/sp-dev.c  |   16 +++
 drivers/crypto/ccp/sp-dev.h  |   34 +++++++
 drivers/crypto/ccp/sp-pci.c  |    4 +
 7 files changed, 374 insertions(+), 1 deletion(-)
 create mode 100644 drivers/crypto/ccp/psp-dev.c
 create mode 100644 drivers/crypto/ccp/psp-dev.h

diff --git a/drivers/crypto/ccp/Kconfig b/drivers/crypto/ccp/Kconfig
index bc08f03..59c207e 100644
--- a/drivers/crypto/ccp/Kconfig
+++ b/drivers/crypto/ccp/Kconfig
@@ -34,4 +34,11 @@ config CRYPTO_DEV_CCP
 	  Provides the interface to use the AMD Cryptographic Coprocessor
 	  which can be used to offload encryption operations such as SHA,
 	  AES and more.
+
+config CRYPTO_DEV_PSP
+	bool "Platform Security Processor interface"
+	default y
+	help
+	 Provide the interface for AMD Platform Security Processor (PSP) device.
+
 endif
diff --git a/drivers/crypto/ccp/Makefile b/drivers/crypto/ccp/Makefile
index 8127e18..12e569d 100644
--- a/drivers/crypto/ccp/Makefile
+++ b/drivers/crypto/ccp/Makefile
@@ -6,6 +6,7 @@ ccp-$(CONFIG_CRYPTO_DEV_CCP) += ccp-dev.o \
 	    ccp-dev-v3.o \
 	    ccp-dev-v5.o \
 	    ccp-dmaengine.o
+ccp-$(CONFIG_CRYPTO_DEV_PSP) += psp-dev.o
 
 obj-$(CONFIG_CRYPTO_DEV_CCP_CRYPTO) += ccp-crypto.o
 ccp-crypto-objs := ccp-crypto-main.o \
diff --git a/drivers/crypto/ccp/psp-dev.c b/drivers/crypto/ccp/psp-dev.c
new file mode 100644
index 0000000..6f64aa7
--- /dev/null
+++ b/drivers/crypto/ccp/psp-dev.c
@@ -0,0 +1,211 @@
+/*
+ * AMD Platform Security Processor (PSP) interface
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
+#include <linux/hw_random.h>
+#include <linux/ccp.h>
+
+#include "sp-dev.h"
+#include "psp-dev.h"
+
+static LIST_HEAD(psp_devs);
+static DEFINE_SPINLOCK(psp_devs_lock);
+
+const struct psp_vdata psp_entry = {
+	.offset = 0x10500,
+};
+
+void psp_add_device(struct psp_device *psp)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&psp_devs_lock, flags);
+
+	list_add_tail(&psp->entry, &psp_devs);
+
+	spin_unlock_irqrestore(&psp_devs_lock, flags);
+}
+
+void psp_del_device(struct psp_device *psp)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&psp_devs_lock, flags);
+
+	list_del(&psp->entry);
+	spin_unlock_irqrestore(&psp_devs_lock, flags);
+}
+
+static struct psp_device *psp_alloc_struct(struct sp_device *sp)
+{
+	struct device *dev = sp->dev;
+	struct psp_device *psp;
+
+	psp = devm_kzalloc(dev, sizeof(*psp), GFP_KERNEL);
+	if (!psp)
+		return NULL;
+
+	psp->dev = dev;
+	psp->sp = sp;
+
+	snprintf(psp->name, sizeof(psp->name), "psp-%u", sp->ord);
+
+	return psp;
+}
+
+irqreturn_t psp_irq_handler(int irq, void *data)
+{
+	unsigned int status;
+	irqreturn_t ret = IRQ_HANDLED;
+	struct psp_device *psp = data;
+
+	/* read the interrupt status */
+	status = ioread32(psp->io_regs + PSP_P2CMSG_INTSTS);
+
+	/* invoke subdevice interrupt handlers */
+	if (status) {
+		if (psp->sev_irq_handler)
+			ret = psp->sev_irq_handler(irq, psp->sev_irq_data);
+	}
+
+	/* clear the interrupt status */
+	iowrite32(status, psp->io_regs + PSP_P2CMSG_INTSTS);
+
+	return ret;
+}
+
+static int psp_init(struct psp_device *psp)
+{
+	psp_add_device(psp);
+
+	sev_dev_init(psp);
+
+	return 0;
+}
+
+int psp_dev_init(struct sp_device *sp)
+{
+	struct device *dev = sp->dev;
+	struct psp_device *psp;
+	int ret;
+
+	ret = -ENOMEM;
+	psp = psp_alloc_struct(sp);
+	if (!psp)
+		goto e_err;
+	sp->psp_data = psp;
+
+	psp->vdata = (struct psp_vdata *)sp->dev_data->psp_vdata;
+	if (!psp->vdata) {
+		ret = -ENODEV;
+		dev_err(dev, "missing driver data\n");
+		goto e_err;
+	}
+
+	psp->io_regs = sp->io_map + psp->vdata->offset;
+
+	/* Disable and clear interrupts until ready */
+	iowrite32(0, psp->io_regs + PSP_P2CMSG_INTEN);
+	iowrite32(0xffffffff, psp->io_regs + PSP_P2CMSG_INTSTS);
+
+	dev_dbg(dev, "requesting an IRQ ...\n");
+	/* Request an irq */
+	ret = sp_request_psp_irq(psp->sp, psp_irq_handler, psp->name, psp);
+	if (ret) {
+		dev_err(dev, "psp: unable to allocate an IRQ\n");
+		goto e_err;
+	}
+
+	sp_set_psp_master(sp);
+
+	dev_dbg(dev, "initializing psp\n");
+	ret = psp_init(psp);
+	if (ret) {
+		dev_err(dev, "failed to init psp\n");
+		goto e_irq;
+	}
+
+	/* Enable interrupt */
+	dev_dbg(dev, "Enabling interrupts ...\n");
+	iowrite32(7, psp->io_regs + PSP_P2CMSG_INTEN);
+
+	dev_notice(dev, "psp enabled\n");
+
+	return 0;
+
+e_irq:
+	sp_free_psp_irq(psp->sp, psp);
+e_err:
+	sp->psp_data = NULL;
+
+	dev_notice(dev, "psp initialization failed\n");
+
+	return ret;
+}
+
+void psp_dev_destroy(struct sp_device *sp)
+{
+	struct psp_device *psp = sp->psp_data;
+
+	sev_dev_destroy(psp);
+
+	sp_free_psp_irq(sp, psp);
+
+	psp_del_device(psp);
+}
+
+int psp_dev_resume(struct sp_device *sp)
+{
+	sev_dev_resume(sp->psp_data);
+	return 0;
+}
+
+int psp_dev_suspend(struct sp_device *sp, pm_message_t state)
+{
+	sev_dev_suspend(sp->psp_data, state);
+	return 0;
+}
+
+int psp_request_sev_irq(struct psp_device *psp, irq_handler_t handler,
+			void *data)
+{
+	psp->sev_irq_data = data;
+	psp->sev_irq_handler = handler;
+
+	return 0;
+}
+
+int psp_free_sev_irq(struct psp_device *psp, void *data)
+{
+	if (psp->sev_irq_handler) {
+		psp->sev_irq_data = NULL;
+		psp->sev_irq_handler = NULL;
+	}
+
+	return 0;
+}
+
+struct psp_device *psp_get_master_device(void)
+{
+	struct sp_device *sp = sp_get_psp_master_device();
+
+	return sp ? sp->psp_data : NULL;
+}
diff --git a/drivers/crypto/ccp/psp-dev.h b/drivers/crypto/ccp/psp-dev.h
new file mode 100644
index 0000000..bbd3d96
--- /dev/null
+++ b/drivers/crypto/ccp/psp-dev.h
@@ -0,0 +1,102 @@
+/*
+ * AMD Platform Security Processor (PSP) interface driver
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
+#include <linux/bitops.h>
+#include <linux/interrupt.h>
+#include <linux/irqreturn.h>
+#include <linux/dmaengine.h>
+
+#include "sp-dev.h"
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
+#define PSP_CMDRESP_CMD_SHIFT		16
+#define PSP_CMDRESP_IOC			BIT(0)
+#define PSP_CMDRESP_RESP		BIT(31)
+#define PSP_CMDRESP_ERR_MASK		0xffff
+
+#define MAX_PSP_NAME_LEN		16
+
+struct psp_device {
+	struct list_head entry;
+
+	struct psp_vdata *vdata;
+	char name[MAX_PSP_NAME_LEN];
+
+	struct device *dev;
+	struct sp_device *sp;
+
+	void __iomem *io_regs;
+
+	irq_handler_t sev_irq_handler;
+	void *sev_irq_data;
+
+	void *sev_data;
+};
+
+void psp_add_device(struct psp_device *psp);
+void psp_del_device(struct psp_device *psp);
+
+int psp_request_sev_irq(struct psp_device *psp, irq_handler_t handler,
+			void *data);
+int psp_free_sev_irq(struct psp_device *psp, void *data);
+
+struct psp_device *psp_get_master_device(void);
+
+#ifdef CONFIG_AMD_SEV
+
+int sev_dev_init(struct psp_device *psp);
+void sev_dev_destroy(struct psp_device *psp);
+int sev_dev_resume(struct psp_device *psp);
+int sev_dev_suspend(struct psp_device *psp, pm_message_t state);
+
+#else
+
+static inline int sev_dev_init(struct psp_device *psp)
+{
+	return -ENODEV;
+}
+
+static inline void sev_dev_destroy(struct psp_device *psp) { }
+
+static inline int sev_dev_resume(struct psp_device *psp)
+{
+	return -ENODEV;
+}
+
+static inline int sev_dev_suspend(struct psp_device *psp, pm_message_t state)
+{
+	return -ENODEV;
+}
+
+#endif /* __AMD_SEV_H */
+
+#endif /* __PSP_DEV_H */
+
diff --git a/drivers/crypto/ccp/sp-dev.c b/drivers/crypto/ccp/sp-dev.c
index e47fb8e..975a435 100644
--- a/drivers/crypto/ccp/sp-dev.c
+++ b/drivers/crypto/ccp/sp-dev.c
@@ -212,6 +212,8 @@ int sp_init(struct sp_device *sp)
 	if (sp->dev_data->ccp_vdata)
 		ccp_dev_init(sp);
 
+	if (sp->dev_data->psp_vdata)
+		psp_dev_init(sp);
 	return 0;
 }
 
@@ -220,6 +222,9 @@ void sp_destroy(struct sp_device *sp)
 	if (sp->dev_data->ccp_vdata)
 		ccp_dev_destroy(sp);
 
+	if (sp->dev_data->psp_vdata)
+		psp_dev_destroy(sp);
+
 	sp_del_device(sp);
 }
 
@@ -233,6 +238,12 @@ int sp_suspend(struct sp_device *sp, pm_message_t state)
 			return ret;
 	}
 
+	if (sp->dev_data->psp_vdata) {
+		ret = psp_dev_suspend(sp, state);
+		if (ret)
+			return ret;
+	}
+
 	return 0;
 }
 
@@ -246,6 +257,11 @@ int sp_resume(struct sp_device *sp)
 			return ret;
 	}
 
+	if (sp->dev_data->psp_vdata) {
+		ret = psp_dev_resume(sp);
+		if (ret)
+			return ret;
+	}
 	return 0;
 }
 
diff --git a/drivers/crypto/ccp/sp-dev.h b/drivers/crypto/ccp/sp-dev.h
index 9a8a8f8..aeff7a0 100644
--- a/drivers/crypto/ccp/sp-dev.h
+++ b/drivers/crypto/ccp/sp-dev.h
@@ -40,12 +40,18 @@ struct ccp_vdata {
 	const unsigned int offset;
 };
 
+struct psp_vdata {
+	const unsigned int version;
+	const struct psp_actions *perform;
+	const unsigned int offset;
+};
+
 /* Structure to hold SP device data */
 struct sp_dev_data {
 	const unsigned int bar;
 
 	const struct ccp_vdata *ccp_vdata;
-	const void *psp_vdata;
+	const struct psp_vdata *psp_vdata;
 };
 
 struct sp_device {
@@ -137,4 +143,30 @@ static inline int ccp_dev_resume(struct sp_device *sp)
 
 #endif	/* CONFIG_CRYPTO_DEV_CCP */
 
+#ifdef CONFIG_CRYPTO_DEV_PSP
+
+int psp_dev_init(struct sp_device *sp);
+void psp_dev_destroy(struct sp_device *sp);
+
+int psp_dev_suspend(struct sp_device *sp, pm_message_t state);
+int psp_dev_resume(struct sp_device *sp);
+#else /* !CONFIG_CRYPTO_DEV_CCP */
+
+static inline int psp_dev_init(struct sp_device *sp)
+{
+	return 0;
+}
+static inline void psp_dev_destroy(struct sp_device *sp) { }
+
+static inline int psp_dev_suspend(struct sp_device *sp, pm_message_t state)
+{
+	return 0;
+}
+static inline int psp_dev_resume(struct sp_device *sp)
+{
+	return 0;
+}
+
+#endif /* CONFIG_CRYPTO_DEV_CCP */
+
 #endif
diff --git a/drivers/crypto/ccp/sp-pci.c b/drivers/crypto/ccp/sp-pci.c
index 0960e2d..4999662 100644
--- a/drivers/crypto/ccp/sp-pci.c
+++ b/drivers/crypto/ccp/sp-pci.c
@@ -271,6 +271,7 @@ static int sp_pci_resume(struct pci_dev *pdev)
 extern struct ccp_vdata ccpv3_pci;
 extern struct ccp_vdata ccpv5a;
 extern struct ccp_vdata ccpv5b;
+extern struct psp_vdata psp_entry;
 
 static const struct sp_dev_data dev_data[] = {
 	{
@@ -284,6 +285,9 @@ static const struct sp_dev_data dev_data[] = {
 #ifdef CONFIG_CRYPTO_DEV_CCP
 		.ccp_vdata = &ccpv5a,
 #endif
+#ifdef CONFIG_CRYPTO_DEV_PSP
+		.psp_vdata = &psp_entry
+#endif
 	},
 	{
 		.bar = 2,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
