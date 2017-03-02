Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id E0E456B03A5
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 10:16:30 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id 126so58124399oig.2
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 07:16:30 -0800 (PST)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0053.outbound.protection.outlook.com. [104.47.38.53])
        by mx.google.com with ESMTPS id 62si3541514ott.143.2017.03.02.07.16.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 02 Mar 2017 07:16:28 -0800 (PST)
Subject: [RFC PATCH v2 19/32] crypto: ccp: Introduce the AMD Secure
 Processor device
From: Brijesh Singh <brijesh.singh@amd.com>
Date: Thu, 2 Mar 2017 10:16:15 -0500
Message-ID: <148846777589.2349.11698765767451886038.stgit@brijesh-build-machine>
In-Reply-To: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
References: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: simon.guinot@sequanux.org, linux-efi@vger.kernel.org, brijesh.singh@amd.com, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linux-pci@vger.kernel.org, linus.walleij@linaro.org, gary.hook@amd.com, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, cl@linux.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, peterz@infradead.org, piotr.luc@intel.com, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, bp@suse.de, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, arnd@arndb.de, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, luto@kernel.org, devel@linuxdriverproject.org, bhelgaas@google.com, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, mst@redhat.com, linux-crypto@vger.kernel.org, tj@kernel.org, pbonzini@redhat.com, akpm@linux-foundation.org, davem@davemloft.net

The CCP device is part of the AMD Secure Processor. In order to expand the
usage of the AMD Secure Processor, create a framework that allows functional
components of the AMD Secure Processor to be initialized and handled
appropriately.

Signed-off-by: Brijesh Singh <brijesh.singh@amd.com>
Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/crypto/Kconfig           |   10 +
 drivers/crypto/ccp/Kconfig       |   43 +++--
 drivers/crypto/ccp/Makefile      |    8 -
 drivers/crypto/ccp/ccp-dev-v3.c  |   86 +++++-----
 drivers/crypto/ccp/ccp-dev-v5.c  |   73 ++++-----
 drivers/crypto/ccp/ccp-dev.c     |  137 +++++++++-------
 drivers/crypto/ccp/ccp-dev.h     |   35 ----
 drivers/crypto/ccp/sp-dev.c      |  308 ++++++++++++++++++++++++++++++++++++
 drivers/crypto/ccp/sp-dev.h      |  140 ++++++++++++++++
 drivers/crypto/ccp/sp-pci.c      |  324 ++++++++++++++++++++++++++++++++++++++
 drivers/crypto/ccp/sp-platform.c |  268 +++++++++++++++++++++++++++++++
 include/linux/ccp.h              |    3 
 12 files changed, 1240 insertions(+), 195 deletions(-)
 create mode 100644 drivers/crypto/ccp/sp-dev.c
 create mode 100644 drivers/crypto/ccp/sp-dev.h
 create mode 100644 drivers/crypto/ccp/sp-pci.c
 create mode 100644 drivers/crypto/ccp/sp-platform.c

diff --git a/drivers/crypto/Kconfig b/drivers/crypto/Kconfig
index 7956478..d31b469 100644
--- a/drivers/crypto/Kconfig
+++ b/drivers/crypto/Kconfig
@@ -456,14 +456,14 @@ config CRYPTO_DEV_ATMEL_SHA
 	  To compile this driver as a module, choose M here: the module
 	  will be called atmel-sha.
 
-config CRYPTO_DEV_CCP
-	bool "Support for AMD Cryptographic Coprocessor"
+config CRYPTO_DEV_SP
+	bool "Support for AMD Secure Processor"
 	depends on ((X86 && PCI) || (ARM64 && (OF_ADDRESS || ACPI))) && HAS_IOMEM
 	help
-	  The AMD Cryptographic Coprocessor provides hardware offload support
-	  for encryption, hashing and related operations.
+	  The AMD Secure Processor provides hardware offload support for memory
+	  encryption in virtualization and cryptographic hashing and related operations.
 
-if CRYPTO_DEV_CCP
+if CRYPTO_DEV_SP
 	source "drivers/crypto/ccp/Kconfig"
 endif
 
diff --git a/drivers/crypto/ccp/Kconfig b/drivers/crypto/ccp/Kconfig
index 2238f77..bc08f03 100644
--- a/drivers/crypto/ccp/Kconfig
+++ b/drivers/crypto/ccp/Kconfig
@@ -1,26 +1,37 @@
-config CRYPTO_DEV_CCP_DD
-	tristate "Cryptographic Coprocessor device driver"
-	depends on CRYPTO_DEV_CCP
-	default m
-	select HW_RANDOM
-	select DMA_ENGINE
-	select DMADEVICES
-	select CRYPTO_SHA1
-	select CRYPTO_SHA256
-	help
-	  Provides the interface to use the AMD Cryptographic Coprocessor
-	  which can be used to offload encryption operations such as SHA,
-	  AES and more. If you choose 'M' here, this module will be called
-	  ccp.
-
 config CRYPTO_DEV_CCP_CRYPTO
 	tristate "Encryption and hashing offload support"
-	depends on CRYPTO_DEV_CCP_DD
+	depends on CRYPTO_DEV_SP_DD
 	default m
 	select CRYPTO_HASH
 	select CRYPTO_BLKCIPHER
 	select CRYPTO_AUTHENC
+	select CRYPTO_DEV_CCP
 	help
 	  Support for using the cryptographic API with the AMD Cryptographic
 	  Coprocessor. This module supports offload of SHA and AES algorithms.
 	  If you choose 'M' here, this module will be called ccp_crypto.
+
+config CRYPTO_DEV_SP_DD
+	tristate "Secure Processor device driver"
+	depends on CRYPTO_DEV_SP
+	default m
+	help
+	  Provides the interface to use the AMD Secure Processor. The
+	  AMD Secure Processor support the Platform Security Processor (PSP)
+	  and Cryptographic Coprocessor (CCP). If you choose 'M' here, this
+	  module will be called ccp.
+
+if CRYPTO_DEV_SP_DD
+config CRYPTO_DEV_CCP
+	bool "Cryptographic Coprocessor interface"
+	default y
+	select HW_RANDOM
+	select DMA_ENGINE
+	select DMADEVICES
+	select CRYPTO_SHA1
+	select CRYPTO_SHA256
+	help
+	  Provides the interface to use the AMD Cryptographic Coprocessor
+	  which can be used to offload encryption operations such as SHA,
+	  AES and more.
+endif
diff --git a/drivers/crypto/ccp/Makefile b/drivers/crypto/ccp/Makefile
index 346ceb8..8127e18 100644
--- a/drivers/crypto/ccp/Makefile
+++ b/drivers/crypto/ccp/Makefile
@@ -1,11 +1,11 @@
-obj-$(CONFIG_CRYPTO_DEV_CCP_DD) += ccp.o
-ccp-objs := ccp-dev.o \
+obj-$(CONFIG_CRYPTO_DEV_SP_DD) += ccp.o
+ccp-objs := sp-dev.o sp-platform.o
+ccp-$(CONFIG_PCI) += sp-pci.o
+ccp-$(CONFIG_CRYPTO_DEV_CCP) += ccp-dev.o \
 	    ccp-ops.o \
 	    ccp-dev-v3.o \
 	    ccp-dev-v5.o \
-	    ccp-platform.o \
 	    ccp-dmaengine.o
-ccp-$(CONFIG_PCI) += ccp-pci.o
 
 obj-$(CONFIG_CRYPTO_DEV_CCP_CRYPTO) += ccp-crypto.o
 ccp-crypto-objs := ccp-crypto-main.o \
diff --git a/drivers/crypto/ccp/ccp-dev-v3.c b/drivers/crypto/ccp/ccp-dev-v3.c
index 7bc0998..5c50d14 100644
--- a/drivers/crypto/ccp/ccp-dev-v3.c
+++ b/drivers/crypto/ccp/ccp-dev-v3.c
@@ -315,6 +315,39 @@ static int ccp_perform_ecc(struct ccp_op *op)
 	return ccp_do_cmd(op, cr, ARRAY_SIZE(cr));
 }
 
+static irqreturn_t ccp_irq_handler(int irq, void *data)
+{
+	struct ccp_device *ccp = data;
+	struct ccp_cmd_queue *cmd_q;
+	u32 q_int, status;
+	unsigned int i;
+
+	status = ioread32(ccp->io_regs + IRQ_STATUS_REG);
+
+	for (i = 0; i < ccp->cmd_q_count; i++) {
+		cmd_q = &ccp->cmd_q[i];
+
+		q_int = status & (cmd_q->int_ok | cmd_q->int_err);
+		if (q_int) {
+			cmd_q->int_status = status;
+			cmd_q->q_status = ioread32(cmd_q->reg_status);
+			cmd_q->q_int_status = ioread32(cmd_q->reg_int_status);
+
+			/* On error, only save the first error value */
+			if ((q_int & cmd_q->int_err) && !cmd_q->cmd_error)
+				cmd_q->cmd_error = CMD_Q_ERROR(cmd_q->q_status);
+
+			cmd_q->int_rcvd = 1;
+
+			/* Acknowledge the interrupt and wake the kthread */
+			iowrite32(q_int, ccp->io_regs + IRQ_STATUS_REG);
+			wake_up_interruptible(&cmd_q->int_queue);
+		}
+	}
+
+	return IRQ_HANDLED;
+}
+
 static int ccp_init(struct ccp_device *ccp)
 {
 	struct device *dev = ccp->dev;
@@ -374,7 +407,7 @@ static int ccp_init(struct ccp_device *ccp)
 
 #ifdef CONFIG_ARM64
 		/* For arm64 set the recommended queue cache settings */
-		iowrite32(ccp->axcache, ccp->io_regs + CMD_Q_CACHE_BASE +
+		iowrite32(ccp->sp->axcache, ccp->io_regs + CMD_Q_CACHE_BASE +
 			  (CMD_Q_CACHE_INC * i));
 #endif
 
@@ -398,7 +431,7 @@ static int ccp_init(struct ccp_device *ccp)
 	iowrite32(qim, ccp->io_regs + IRQ_STATUS_REG);
 
 	/* Request an irq */
-	ret = ccp->get_irq(ccp);
+	ret = sp_request_ccp_irq(ccp->sp, ccp_irq_handler, ccp->name, ccp);
 	if (ret) {
 		dev_err(dev, "unable to allocate an IRQ\n");
 		goto e_pool;
@@ -450,7 +483,7 @@ static int ccp_init(struct ccp_device *ccp)
 		if (ccp->cmd_q[i].kthread)
 			kthread_stop(ccp->cmd_q[i].kthread);
 
-	ccp->free_irq(ccp);
+	sp_free_ccp_irq(ccp->sp, ccp);
 
 e_pool:
 	for (i = 0; i < ccp->cmd_q_count; i++)
@@ -496,7 +529,7 @@ static void ccp_destroy(struct ccp_device *ccp)
 		if (ccp->cmd_q[i].kthread)
 			kthread_stop(ccp->cmd_q[i].kthread);
 
-	ccp->free_irq(ccp);
+	sp_free_ccp_irq(ccp->sp, ccp);
 
 	for (i = 0; i < ccp->cmd_q_count; i++)
 		dma_pool_destroy(ccp->cmd_q[i].dma_pool);
@@ -516,40 +549,6 @@ static void ccp_destroy(struct ccp_device *ccp)
 	}
 }
 
-static irqreturn_t ccp_irq_handler(int irq, void *data)
-{
-	struct device *dev = data;
-	struct ccp_device *ccp = dev_get_drvdata(dev);
-	struct ccp_cmd_queue *cmd_q;
-	u32 q_int, status;
-	unsigned int i;
-
-	status = ioread32(ccp->io_regs + IRQ_STATUS_REG);
-
-	for (i = 0; i < ccp->cmd_q_count; i++) {
-		cmd_q = &ccp->cmd_q[i];
-
-		q_int = status & (cmd_q->int_ok | cmd_q->int_err);
-		if (q_int) {
-			cmd_q->int_status = status;
-			cmd_q->q_status = ioread32(cmd_q->reg_status);
-			cmd_q->q_int_status = ioread32(cmd_q->reg_int_status);
-
-			/* On error, only save the first error value */
-			if ((q_int & cmd_q->int_err) && !cmd_q->cmd_error)
-				cmd_q->cmd_error = CMD_Q_ERROR(cmd_q->q_status);
-
-			cmd_q->int_rcvd = 1;
-
-			/* Acknowledge the interrupt and wake the kthread */
-			iowrite32(q_int, ccp->io_regs + IRQ_STATUS_REG);
-			wake_up_interruptible(&cmd_q->int_queue);
-		}
-	}
-
-	return IRQ_HANDLED;
-}
-
 static const struct ccp_actions ccp3_actions = {
 	.aes = ccp_perform_aes,
 	.xts_aes = ccp_perform_xts_aes,
@@ -562,13 +561,18 @@ static const struct ccp_actions ccp3_actions = {
 	.init = ccp_init,
 	.destroy = ccp_destroy,
 	.get_free_slots = ccp_get_free_slots,
-	.irqhandler = ccp_irq_handler,
 };
 
-const struct ccp_vdata ccpv3 = {
+const struct ccp_vdata ccpv3_platform = {
+	.version = CCP_VERSION(3, 0),
+	.setup = NULL,
+	.perform = &ccp3_actions,
+	.offset = 0,
+};
+
+const struct ccp_vdata ccpv3_pci = {
 	.version = CCP_VERSION(3, 0),
 	.setup = NULL,
 	.perform = &ccp3_actions,
-	.bar = 2,
 	.offset = 0x20000,
 };
diff --git a/drivers/crypto/ccp/ccp-dev-v5.c b/drivers/crypto/ccp/ccp-dev-v5.c
index 612898b..dd6335b 100644
--- a/drivers/crypto/ccp/ccp-dev-v5.c
+++ b/drivers/crypto/ccp/ccp-dev-v5.c
@@ -651,6 +651,38 @@ static int ccp_assign_lsbs(struct ccp_device *ccp)
 	return rc;
 }
 
+static irqreturn_t ccp5_irq_handler(int irq, void *data)
+{
+	struct device *dev = data;
+	struct ccp_device *ccp = dev_get_drvdata(dev);
+	u32 status;
+	unsigned int i;
+
+	for (i = 0; i < ccp->cmd_q_count; i++) {
+		struct ccp_cmd_queue *cmd_q = &ccp->cmd_q[i];
+
+		status = ioread32(cmd_q->reg_interrupt_status);
+
+		if (status) {
+			cmd_q->int_status = status;
+			cmd_q->q_status = ioread32(cmd_q->reg_status);
+			cmd_q->q_int_status = ioread32(cmd_q->reg_int_status);
+
+			/* On error, only save the first error value */
+			if ((status & INT_ERROR) && !cmd_q->cmd_error)
+				cmd_q->cmd_error = CMD_Q_ERROR(cmd_q->q_status);
+
+			cmd_q->int_rcvd = 1;
+
+			/* Acknowledge the interrupt and wake the kthread */
+			iowrite32(ALL_INTERRUPTS, cmd_q->reg_interrupt_status);
+			wake_up_interruptible(&cmd_q->int_queue);
+		}
+	}
+
+	return IRQ_HANDLED;
+}
+
 static int ccp5_init(struct ccp_device *ccp)
 {
 	struct device *dev = ccp->dev;
@@ -752,7 +784,7 @@ static int ccp5_init(struct ccp_device *ccp)
 
 	dev_dbg(dev, "Requesting an IRQ...\n");
 	/* Request an irq */
-	ret = ccp->get_irq(ccp);
+	ret = sp_request_ccp_irq(ccp->sp, ccp5_irq_handler, ccp->name, ccp);
 	if (ret) {
 		dev_err(dev, "unable to allocate an IRQ\n");
 		goto e_pool;
@@ -855,7 +887,7 @@ static int ccp5_init(struct ccp_device *ccp)
 			kthread_stop(ccp->cmd_q[i].kthread);
 
 e_irq:
-	ccp->free_irq(ccp);
+	sp_free_ccp_irq(ccp->sp, ccp);
 
 e_pool:
 	for (i = 0; i < ccp->cmd_q_count; i++)
@@ -901,7 +933,7 @@ static void ccp5_destroy(struct ccp_device *ccp)
 		if (ccp->cmd_q[i].kthread)
 			kthread_stop(ccp->cmd_q[i].kthread);
 
-	ccp->free_irq(ccp);
+	sp_free_ccp_irq(ccp->sp, ccp);
 
 	for (i = 0; i < ccp->cmd_q_count; i++) {
 		cmd_q = &ccp->cmd_q[i];
@@ -924,38 +956,6 @@ static void ccp5_destroy(struct ccp_device *ccp)
 	}
 }
 
-static irqreturn_t ccp5_irq_handler(int irq, void *data)
-{
-	struct device *dev = data;
-	struct ccp_device *ccp = dev_get_drvdata(dev);
-	u32 status;
-	unsigned int i;
-
-	for (i = 0; i < ccp->cmd_q_count; i++) {
-		struct ccp_cmd_queue *cmd_q = &ccp->cmd_q[i];
-
-		status = ioread32(cmd_q->reg_interrupt_status);
-
-		if (status) {
-			cmd_q->int_status = status;
-			cmd_q->q_status = ioread32(cmd_q->reg_status);
-			cmd_q->q_int_status = ioread32(cmd_q->reg_int_status);
-
-			/* On error, only save the first error value */
-			if ((status & INT_ERROR) && !cmd_q->cmd_error)
-				cmd_q->cmd_error = CMD_Q_ERROR(cmd_q->q_status);
-
-			cmd_q->int_rcvd = 1;
-
-			/* Acknowledge the interrupt and wake the kthread */
-			iowrite32(ALL_INTERRUPTS, cmd_q->reg_interrupt_status);
-			wake_up_interruptible(&cmd_q->int_queue);
-		}
-	}
-
-	return IRQ_HANDLED;
-}
-
 static void ccp5_config(struct ccp_device *ccp)
 {
 	/* Public side */
@@ -1001,14 +1001,12 @@ static const struct ccp_actions ccp5_actions = {
 	.init = ccp5_init,
 	.destroy = ccp5_destroy,
 	.get_free_slots = ccp5_get_free_slots,
-	.irqhandler = ccp5_irq_handler,
 };
 
 const struct ccp_vdata ccpv5a = {
 	.version = CCP_VERSION(5, 0),
 	.setup = ccp5_config,
 	.perform = &ccp5_actions,
-	.bar = 2,
 	.offset = 0x0,
 };
 
@@ -1016,6 +1014,5 @@ const struct ccp_vdata ccpv5b = {
 	.version = CCP_VERSION(5, 0),
 	.setup = ccp5other_config,
 	.perform = &ccp5_actions,
-	.bar = 2,
 	.offset = 0x0,
 };
diff --git a/drivers/crypto/ccp/ccp-dev.c b/drivers/crypto/ccp/ccp-dev.c
index 511ab04..0fa8c4a 100644
--- a/drivers/crypto/ccp/ccp-dev.c
+++ b/drivers/crypto/ccp/ccp-dev.c
@@ -22,19 +22,11 @@
 #include <linux/mutex.h>
 #include <linux/delay.h>
 #include <linux/hw_random.h>
-#include <linux/cpu.h>
-#ifdef CONFIG_X86
-#include <asm/cpu_device_id.h>
-#endif
 #include <linux/ccp.h>
 
+#include "sp-dev.h"
 #include "ccp-dev.h"
 
-MODULE_AUTHOR("Tom Lendacky <thomas.lendacky@amd.com>");
-MODULE_LICENSE("GPL");
-MODULE_VERSION("1.0.0");
-MODULE_DESCRIPTION("AMD Cryptographic Coprocessor driver");
-
 struct ccp_tasklet_data {
 	struct completion completion;
 	struct ccp_cmd *cmd;
@@ -110,13 +102,6 @@ static LIST_HEAD(ccp_units);
 static DEFINE_SPINLOCK(ccp_rr_lock);
 static struct ccp_device *ccp_rr;
 
-/* Ever-increasing value to produce unique unit numbers */
-static atomic_t ccp_unit_ordinal;
-static unsigned int ccp_increment_unit_ordinal(void)
-{
-	return atomic_inc_return(&ccp_unit_ordinal);
-}
-
 /**
  * ccp_add_device - add a CCP device to the list
  *
@@ -455,19 +440,17 @@ int ccp_cmd_queue_thread(void *data)
 	return 0;
 }
 
-/**
- * ccp_alloc_struct - allocate and initialize the ccp_device struct
- *
- * @dev: device struct of the CCP
- */
-struct ccp_device *ccp_alloc_struct(struct device *dev)
+static struct ccp_device *ccp_alloc_struct(struct sp_device *sp)
 {
+	struct device *dev = sp->dev;
 	struct ccp_device *ccp;
 
 	ccp = devm_kzalloc(dev, sizeof(*ccp), GFP_KERNEL);
 	if (!ccp)
 		return NULL;
+
 	ccp->dev = dev;
+	ccp->sp = sp;
 
 	INIT_LIST_HEAD(&ccp->cmd);
 	INIT_LIST_HEAD(&ccp->backlog);
@@ -482,9 +465,8 @@ struct ccp_device *ccp_alloc_struct(struct device *dev)
 	init_waitqueue_head(&ccp->sb_queue);
 	init_waitqueue_head(&ccp->suspend_queue);
 
-	ccp->ord = ccp_increment_unit_ordinal();
-	snprintf(ccp->name, MAX_CCP_NAME_LEN, "ccp-%u", ccp->ord);
-	snprintf(ccp->rngname, MAX_CCP_NAME_LEN, "ccp-%u-rng", ccp->ord);
+	snprintf(ccp->name, MAX_CCP_NAME_LEN, "ccp-%u", sp->ord);
+	snprintf(ccp->rngname, MAX_CCP_NAME_LEN, "ccp-%u-rng", sp->ord);
 
 	return ccp;
 }
@@ -536,53 +518,94 @@ bool ccp_queues_suspended(struct ccp_device *ccp)
 }
 #endif
 
-static int __init ccp_mod_init(void)
+int ccp_dev_init(struct sp_device *sp)
 {
-#ifdef CONFIG_X86
+	struct device *dev = sp->dev;
+	struct ccp_device *ccp;
 	int ret;
 
-	ret = ccp_pci_init();
-	if (ret)
-		return ret;
-
-	/* Don't leave the driver loaded if init failed */
-	if (ccp_present() != 0) {
-		ccp_pci_exit();
-		return -ENODEV;
+	ret = -ENOMEM;
+	ccp = ccp_alloc_struct(sp);
+	if (!ccp)
+		goto e_err;
+	sp->ccp_data = ccp;
+
+	ccp->vdata = (struct ccp_vdata *)sp->dev_data->ccp_vdata;
+	if (!ccp->vdata || !ccp->vdata->version) {
+		ret = -ENODEV;
+		dev_err(dev, "missing driver data\n");
+		goto e_err;
 	}
 
-	return 0;
-#endif
+	ccp->io_regs = sp->io_map + ccp->vdata->offset;
 
-#ifdef CONFIG_ARM64
-	int ret;
+	if (ccp->vdata->setup)
+		ccp->vdata->setup(ccp);
 
-	ret = ccp_platform_init();
+	ret = ccp->vdata->perform->init(ccp);
 	if (ret)
-		return ret;
+		goto e_err;
 
-	/* Don't leave the driver loaded if init failed */
-	if (ccp_present() != 0) {
-		ccp_platform_exit();
-		return -ENODEV;
-	}
+	dev_notice(dev, "ccp enabled\n");
 
 	return 0;
-#endif
 
-	return -ENODEV;
+e_err:
+	sp->ccp_data = NULL;
+
+	dev_notice(dev, "ccp initialization failed\n");
+
+	return ret;
 }
 
-static void __exit ccp_mod_exit(void)
+void ccp_dev_destroy(struct sp_device *sp)
 {
-#ifdef CONFIG_X86
-	ccp_pci_exit();
-#endif
+	struct ccp_device *ccp = sp->ccp_data;
 
-#ifdef CONFIG_ARM64
-	ccp_platform_exit();
-#endif
+	ccp->vdata->perform->destroy(ccp);
+}
+
+int ccp_dev_suspend(struct sp_device *sp, pm_message_t state)
+{
+	struct ccp_device *ccp = sp->ccp_data;
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
 }
 
-module_init(ccp_mod_init);
-module_exit(ccp_mod_exit);
+int ccp_dev_resume(struct sp_device *sp)
+{
+	struct ccp_device *ccp = sp->ccp_data;
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
diff --git a/drivers/crypto/ccp/ccp-dev.h b/drivers/crypto/ccp/ccp-dev.h
index 649e561..25a4bfd 100644
--- a/drivers/crypto/ccp/ccp-dev.h
+++ b/drivers/crypto/ccp/ccp-dev.h
@@ -27,6 +27,8 @@
 #include <linux/irqreturn.h>
 #include <linux/dmaengine.h>
 
+#include "sp-dev.h"
+
 #define MAX_CCP_NAME_LEN		16
 #define MAX_DMAPOOL_NAME_LEN		32
 
@@ -35,9 +37,6 @@
 
 #define TRNG_RETRIES			10
 
-#define CACHE_NONE			0x00
-#define CACHE_WB_NO_ALLOC		0xb7
-
 /****** Register Mappings ******/
 #define Q_MASK_REG			0x000
 #define TRNG_OUT_REG			0x00c
@@ -322,18 +321,15 @@ struct ccp_device {
 	struct list_head entry;
 
 	struct ccp_vdata *vdata;
-	unsigned int ord;
 	char name[MAX_CCP_NAME_LEN];
 	char rngname[MAX_CCP_NAME_LEN];
 
 	struct device *dev;
+	struct sp_device *sp;
 
 	/* Bus specific device information
 	 */
 	void *dev_specific;
-	int (*get_irq)(struct ccp_device *ccp);
-	void (*free_irq)(struct ccp_device *ccp);
-	unsigned int irq;
 
 	/* I/O area used for device communication. The register mapping
 	 * starts at an offset into the mapped bar.
@@ -342,7 +338,6 @@ struct ccp_device {
 	 *   them.
 	 */
 	struct mutex req_mutex ____cacheline_aligned;
-	void __iomem *io_map;
 	void __iomem *io_regs;
 
 	/* Master lists that all cmds are queued on. Because there can be
@@ -407,9 +402,6 @@ struct ccp_device {
 	/* Suspend support */
 	unsigned int suspending;
 	wait_queue_head_t suspend_queue;
-
-	/* DMA caching attribute support */
-	unsigned int axcache;
 };
 
 enum ccp_memtype {
@@ -592,18 +584,11 @@ struct ccp5_desc {
 	struct dword7 dw7;
 };
 
-int ccp_pci_init(void);
-void ccp_pci_exit(void);
-
-int ccp_platform_init(void);
-void ccp_platform_exit(void);
-
 void ccp_add_device(struct ccp_device *ccp);
 void ccp_del_device(struct ccp_device *ccp);
 
 extern void ccp_log_error(struct ccp_device *, int);
 
-struct ccp_device *ccp_alloc_struct(struct device *dev);
 bool ccp_queues_suspended(struct ccp_device *ccp);
 int ccp_cmd_queue_thread(void *data);
 int ccp_trng_read(struct hwrng *rng, void *data, size_t max, bool wait);
@@ -629,20 +614,6 @@ struct ccp_actions {
 	unsigned int (*get_free_slots)(struct ccp_cmd_queue *);
 	int (*init)(struct ccp_device *);
 	void (*destroy)(struct ccp_device *);
-	irqreturn_t (*irqhandler)(int, void *);
-};
-
-/* Structure to hold CCP version-specific values */
-struct ccp_vdata {
-	const unsigned int version;
-	void (*setup)(struct ccp_device *);
-	const struct ccp_actions *perform;
-	const unsigned int bar;
-	const unsigned int offset;
 };
 
-extern const struct ccp_vdata ccpv3;
-extern const struct ccp_vdata ccpv5a;
-extern const struct ccp_vdata ccpv5b;
-
 #endif
diff --git a/drivers/crypto/ccp/sp-dev.c b/drivers/crypto/ccp/sp-dev.c
new file mode 100644
index 0000000..e47fb8e
--- /dev/null
+++ b/drivers/crypto/ccp/sp-dev.c
@@ -0,0 +1,308 @@
+/*
+ * AMD Secure Processor driver
+ *
+ * Copyright (C) 2017 Advanced Micro Devices, Inc.
+ *
+ * Author: Brijesh Singh <brijesh.singh@amd.com>
+ *	Tom Lendacky <thomas.lendacky@amd.com>
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
+
+#include "sp-dev.h"
+
+MODULE_AUTHOR("Tom Lendacky <thomas.lendacky@amd.com>");
+MODULE_LICENSE("GPL");
+MODULE_VERSION("1.1.0");
+MODULE_DESCRIPTION("AMD Secure Processor driver");
+
+/* List of SPs, SP count, read-write access lock, and access functions
+ *
+ * Lock structure: get sp_unit_lock for reading whenever we need to
+ * examine the SP list.
+ */
+static DEFINE_RWLOCK(sp_unit_lock);
+static LIST_HEAD(sp_units);
+
+/* Ever-increasing value to produce unique unit numbers */
+static atomic_t sp_ordinal;
+
+static void sp_add_device(struct sp_device *sp)
+{
+	unsigned long flags;
+
+	write_lock_irqsave(&sp_unit_lock, flags);
+
+	list_add_tail(&sp->entry, &sp_units);
+
+	write_unlock_irqrestore(&sp_unit_lock, flags);
+}
+
+static void sp_del_device(struct sp_device *sp)
+{
+	unsigned long flags;
+
+	write_lock_irqsave(&sp_unit_lock, flags);
+
+	list_del(&sp->entry);
+
+	write_unlock_irqrestore(&sp_unit_lock, flags);
+}
+
+struct sp_device *sp_get_device(void)
+{
+	struct sp_device *sp = NULL;
+	unsigned long flags;
+
+	write_lock_irqsave(&sp_unit_lock, flags);
+
+	if (list_empty(&sp_units))
+		goto unlock;
+
+	sp = list_first_entry(&sp_units, struct sp_device, entry);
+
+	list_add_tail(&sp->entry, &sp_units);
+unlock:
+	write_unlock_irqrestore(&sp_unit_lock, flags);
+	return sp;
+}
+
+static irqreturn_t sp_irq_handler(int irq, void *data)
+{
+	struct sp_device *sp = data;
+
+	if (sp->psp_irq_handler)
+		sp->psp_irq_handler(irq, sp->psp_irq_data);
+
+	if (sp->ccp_irq_handler)
+		sp->ccp_irq_handler(irq, sp->ccp_irq_data);
+
+	return IRQ_HANDLED;
+}
+
+int sp_request_psp_irq(struct sp_device *sp, irq_handler_t handler,
+		       const char *name, void *data)
+{
+	int ret;
+
+	if ((sp->psp_irq == sp->ccp_irq) && sp->dev_data->ccp_vdata) {
+		/* Need a common routine to manager all interrupts */
+		sp->psp_irq_data = data;
+		sp->psp_irq_handler = handler;
+
+		if (!sp->irq_registered) {
+			ret = request_irq(sp->psp_irq, sp_irq_handler, 0,
+					  sp->name, sp);
+			if (ret)
+				return ret;
+
+			sp->irq_registered = true;
+		}
+	} else {
+		/* Each sub-device can manage it's own interrupt */
+		ret = request_irq(sp->psp_irq, handler, 0, name, data);
+		if (ret)
+			return ret;
+	}
+
+	return 0;
+}
+
+int sp_request_ccp_irq(struct sp_device *sp, irq_handler_t handler,
+		       const char *name, void *data)
+{
+	int ret;
+
+	if ((sp->psp_irq == sp->ccp_irq) && sp->dev_data->psp_vdata) {
+		/* Need a common routine to manager all interrupts */
+		sp->ccp_irq_data = data;
+		sp->ccp_irq_handler = handler;
+
+		if (!sp->irq_registered) {
+			ret = request_irq(sp->ccp_irq, sp_irq_handler, 0,
+					  sp->name, sp);
+			if (ret)
+				return ret;
+
+			sp->irq_registered = true;
+		}
+	} else {
+		/* Each sub-device can manage it's own interrupt */
+		ret = request_irq(sp->ccp_irq, handler, 0, name, data);
+		if (ret)
+			return ret;
+	}
+
+	return 0;
+}
+
+void sp_free_psp_irq(struct sp_device *sp, void *data)
+{
+	if ((sp->psp_irq == sp->ccp_irq) && sp->dev_data->ccp_vdata) {
+		/* Using a common routine to manager all interrupts */
+		if (!sp->ccp_irq_handler) {
+			/* Nothing else using it, so free it */
+			free_irq(sp->psp_irq, sp);
+
+			sp->irq_registered = false;
+		}
+
+		sp->psp_irq_handler = NULL;
+		sp->psp_irq_data = NULL;
+	} else {
+		/* Each sub-device can manage it's own interrupt */
+		free_irq(sp->psp_irq, data);
+	}
+}
+
+void sp_free_ccp_irq(struct sp_device *sp, void *data)
+{
+	if ((sp->psp_irq == sp->ccp_irq) && sp->dev_data->psp_vdata) {
+		/* Using a common routine to manager all interrupts */
+		if (!sp->psp_irq_handler) {
+			/* Nothing else using it, so free it */
+			free_irq(sp->ccp_irq, sp);
+
+			sp->irq_registered = false;
+		}
+
+		sp->ccp_irq_handler = NULL;
+		sp->ccp_irq_data = NULL;
+	} else {
+		/* Each sub-device can manage it's own interrupt */
+		free_irq(sp->ccp_irq, data);
+	}
+}
+
+/**
+ * sp_alloc_struct - allocate and initialize the sp_device struct
+ *
+ * @dev: device struct of the SP
+ */
+struct sp_device *sp_alloc_struct(struct device *dev)
+{
+	struct sp_device *sp;
+
+	sp = devm_kzalloc(dev, sizeof(*sp), GFP_KERNEL);
+	if (!sp)
+		return NULL;
+
+	sp->dev = dev;
+	sp->ord = atomic_inc_return(&sp_ordinal) - 1;
+	snprintf(sp->name, SP_MAX_NAME_LEN, "sp-%u", sp->ord);
+
+	return sp;
+}
+
+int sp_init(struct sp_device *sp)
+{
+	sp_add_device(sp);
+
+	if (sp->dev_data->ccp_vdata)
+		ccp_dev_init(sp);
+
+	return 0;
+}
+
+void sp_destroy(struct sp_device *sp)
+{
+	if (sp->dev_data->ccp_vdata)
+		ccp_dev_destroy(sp);
+
+	sp_del_device(sp);
+}
+
+int sp_suspend(struct sp_device *sp, pm_message_t state)
+{
+	int ret;
+
+	if (sp->dev_data->ccp_vdata) {
+		ret = ccp_dev_suspend(sp, state);
+		if (ret)
+			return ret;
+	}
+
+	return 0;
+}
+
+int sp_resume(struct sp_device *sp)
+{
+	int ret;
+
+	if (sp->dev_data->ccp_vdata) {
+		ret = ccp_dev_resume(sp);
+		if (ret)
+			return ret;
+	}
+
+	return 0;
+}
+
+struct sp_device *sp_get_psp_master_device(void)
+{
+	struct sp_device *sp = sp_get_device();
+
+	if (!sp)
+		return NULL;
+
+	if (!sp->psp_data)
+		return NULL;
+
+	return sp->get_master_device();
+}
+
+void sp_set_psp_master(struct sp_device *sp)
+{
+	if (sp->psp_data)
+		sp->set_master_device(sp);
+}
+
+static int __init sp_mod_init(void)
+{
+#ifdef CONFIG_X86
+	int ret;
+
+	ret = sp_pci_init();
+	if (ret)
+		return ret;
+
+	return 0;
+#endif
+
+#ifdef CONFIG_ARM64
+	int ret;
+
+	ret = sp_platform_init();
+	if (ret)
+		return ret;
+
+	return 0;
+#endif
+
+	return -ENODEV;
+}
+
+static void __exit sp_mod_exit(void)
+{
+#ifdef CONFIG_X86
+	sp_pci_exit();
+#endif
+
+#ifdef CONFIG_ARM64
+	sp_platform_exit();
+#endif
+}
+
+module_init(sp_mod_init);
+module_exit(sp_mod_exit);
diff --git a/drivers/crypto/ccp/sp-dev.h b/drivers/crypto/ccp/sp-dev.h
new file mode 100644
index 0000000..9a8a8f8
--- /dev/null
+++ b/drivers/crypto/ccp/sp-dev.h
@@ -0,0 +1,140 @@
+/*
+ * AMD Secure Processor driver
+ *
+ * Copyright (C) 2017 Advanced Micro Devices, Inc.
+ *
+ * Author: Brijesh Singh <brijesh.singh@amd.com>
+ *	Tom Lendacky <thomas.lendacky@amd.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#ifndef __SP_DEV_H__
+#define __SP_DEV_H__
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
+
+#define SP_MAX_NAME_LEN		32
+
+#define CACHE_NONE			0x00
+#define CACHE_WB_NO_ALLOC		0xb7
+
+/* Structure to hold CCP device data */
+struct ccp_device;
+struct ccp_vdata {
+	const unsigned int version;
+	void (*setup)(struct ccp_device *);
+	const struct ccp_actions *perform;
+	const unsigned int offset;
+};
+
+/* Structure to hold SP device data */
+struct sp_dev_data {
+	const unsigned int bar;
+
+	const struct ccp_vdata *ccp_vdata;
+	const void *psp_vdata;
+};
+
+struct sp_device {
+	struct list_head entry;
+
+	struct device *dev;
+
+	struct sp_dev_data *dev_data;
+	unsigned int ord;
+	char name[SP_MAX_NAME_LEN];
+
+	/* Bus specific device information */
+	void *dev_specific;
+
+	/* I/O area used for device communication. */
+	void __iomem *io_map;
+
+	/* DMA caching attribute support */
+	unsigned int axcache;
+
+	bool irq_registered;
+
+	/* get and set master device */
+	struct sp_device*(*get_master_device) (void);
+	void(*set_master_device) (struct sp_device *);
+
+	unsigned int psp_irq;
+	irq_handler_t psp_irq_handler;
+	void *psp_irq_data;
+
+	unsigned int ccp_irq;
+	irq_handler_t ccp_irq_handler;
+	void *ccp_irq_data;
+
+	void *psp_data;
+	void *ccp_data;
+};
+
+int sp_pci_init(void);
+void sp_pci_exit(void);
+
+int sp_platform_init(void);
+void sp_platform_exit(void);
+
+struct sp_device *sp_alloc_struct(struct device *dev);
+
+int sp_init(struct sp_device *sp);
+void sp_destroy(struct sp_device *sp);
+struct sp_device *sp_get_master(void);
+
+int sp_suspend(struct sp_device *sp, pm_message_t state);
+int sp_resume(struct sp_device *sp);
+
+int sp_request_psp_irq(struct sp_device *sp, irq_handler_t handler,
+		       const char *name, void *data);
+void sp_free_psp_irq(struct sp_device *sp, void *data);
+
+int sp_request_ccp_irq(struct sp_device *sp, irq_handler_t handler,
+		       const char *name, void *data);
+void sp_free_ccp_irq(struct sp_device *sp, void *data);
+
+void sp_set_psp_master(struct sp_device *sp);
+struct sp_device *sp_get_psp_master_device(void);
+
+#ifdef CONFIG_CRYPTO_DEV_CCP
+
+int ccp_dev_init(struct sp_device *sp);
+void ccp_dev_destroy(struct sp_device *sp);
+
+int ccp_dev_suspend(struct sp_device *sp, pm_message_t state);
+int ccp_dev_resume(struct sp_device *sp);
+
+#else	/* !CONFIG_CRYPTO_DEV_CCP */
+
+static inline int ccp_dev_init(struct sp_device *sp)
+{
+	return 0;
+}
+static inline void ccp_dev_destroy(struct sp_device *sp) { }
+
+static inline int ccp_dev_suspend(struct sp_device *sp, pm_message_t state)
+{
+	return 0;
+}
+static inline int ccp_dev_resume(struct sp_device *sp)
+{
+	return 0;
+}
+
+#endif	/* CONFIG_CRYPTO_DEV_CCP */
+
+#endif
diff --git a/drivers/crypto/ccp/sp-pci.c b/drivers/crypto/ccp/sp-pci.c
new file mode 100644
index 0000000..0960e2d
--- /dev/null
+++ b/drivers/crypto/ccp/sp-pci.c
@@ -0,0 +1,324 @@
+/*
+ * AMD Secure Processor driver
+ *
+ * Copyright (C) 2017 Advanced Micro Devices, Inc.
+ *
+ * Author: Brijesh Singh <brijesh.singh@amd.com>
+ * 	   Tom Lendacky <thomas.lendacky@amd.com>
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
+#include <linux/kthread.h>
+#include <linux/sched.h>
+#include <linux/interrupt.h>
+#include <linux/spinlock.h>
+
+#include "sp-dev.h"
+
+#define MSIX_VECTORS			2
+
+struct sp_pci {
+	int msix_count;
+	struct msix_entry msix_entry[MSIX_VECTORS];
+};
+
+static struct sp_device *sp_dev_master;
+
+static int sp_get_msix_irqs(struct sp_device *sp)
+{
+	struct sp_pci *sp_pci = sp->dev_specific;
+	struct device *dev = sp->dev;
+	struct pci_dev *pdev = to_pci_dev(dev);
+	int v, ret;
+
+	for (v = 0; v < ARRAY_SIZE(sp_pci->msix_entry); v++)
+		sp_pci->msix_entry[v].entry = v;
+
+	ret = pci_enable_msix_range(pdev, sp_pci->msix_entry, 1, v);
+	if (ret < 0)
+		return ret;
+
+	sp_pci->msix_count = ret;
+
+	sp->psp_irq = sp_pci->msix_entry[0].vector;
+	sp->ccp_irq = (sp_pci->msix_count > 1) ? sp_pci->msix_entry[1].vector
+					       : sp_pci->msix_entry[0].vector;
+
+	return 0;
+}
+
+static int sp_get_msi_irq(struct sp_device *sp)
+{
+	struct device *dev = sp->dev;
+	struct pci_dev *pdev = to_pci_dev(dev);
+	int ret;
+
+	ret = pci_enable_msi(pdev);
+	if (ret)
+		return ret;
+
+	sp->psp_irq = pdev->irq;
+	sp->ccp_irq = pdev->irq;
+
+	return 0;
+}
+
+static int sp_get_irqs(struct sp_device *sp)
+{
+	struct device *dev = sp->dev;
+	int ret;
+
+	ret = sp_get_msix_irqs(sp);
+	if (!ret)
+		return 0;
+
+	/* Couldn't get MSI-X vectors, try MSI */
+	dev_notice(dev, "could not enable MSI-X (%d), trying MSI\n", ret);
+	ret = sp_get_msi_irq(sp);
+	if (!ret)
+		return 0;
+
+	/* Couldn't get MSI interrupt */
+	dev_notice(dev, "could not enable MSI (%d)\n", ret);
+
+	return ret;
+}
+
+static void sp_free_irqs(struct sp_device *sp)
+{
+	struct sp_pci *sp_pci = sp->dev_specific;
+	struct device *dev = sp->dev;
+	struct pci_dev *pdev = to_pci_dev(dev);
+
+	if (sp_pci->msix_count)
+		pci_disable_msix(pdev);
+	else if (sp->psp_irq)
+		pci_disable_msi(pdev);
+
+	sp->psp_irq = 0;
+	sp->ccp_irq = 0;
+}
+
+static bool sp_pci_is_master(struct sp_device *sp)
+{
+	struct device *dev_cur, *dev_new;
+	struct pci_dev *pdev_cur, *pdev_new;
+
+	dev_new = sp->dev;
+	dev_cur = sp_dev_master->dev;
+
+	pdev_new = to_pci_dev(dev_new);
+	pdev_cur = to_pci_dev(dev_cur);
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
+static void sp_pci_set_master(struct sp_device *sp)
+{
+	if (!sp_dev_master) {
+		sp_dev_master = sp;
+		return;
+	}
+
+	if (sp_pci_is_master(sp))
+		sp_dev_master = sp;
+}
+
+static struct sp_device *sp_pci_get_master(void)
+{
+	return sp_dev_master;
+}
+
+static int sp_pci_probe(struct pci_dev *pdev, const struct pci_device_id *id)
+{
+	struct sp_device *sp;
+	struct sp_pci *sp_pci;
+	struct device *dev = &pdev->dev;
+	void __iomem * const *iomap_table;
+	int bar_mask;
+	int ret;
+
+	ret = -ENOMEM;
+	sp = sp_alloc_struct(dev);
+	if (!sp)
+		goto e_err;
+
+	sp_pci = devm_kzalloc(dev, sizeof(*sp_pci), GFP_KERNEL);
+	if (!sp_pci)
+		goto e_err;
+	sp->dev_specific = sp_pci;
+
+	sp->dev_data = (struct sp_dev_data *)id->driver_data;
+	if (!sp->dev_data) {
+		ret = -ENODEV;
+		dev_err(dev, "missing driver data\n");
+		goto e_err;
+	}
+
+	ret = pcim_enable_device(pdev);
+	if (ret) {
+		dev_err(dev, "pcim_enable_device failed (%d)\n", ret);
+		goto e_err;
+	}
+
+	bar_mask = pci_select_bars(pdev, IORESOURCE_MEM);
+	ret = pcim_iomap_regions(pdev, bar_mask, "sp");
+	if (ret) {
+		dev_err(dev, "pcim_iomap_regions failed (%d)\n", ret);
+		goto e_err;
+	}
+
+	iomap_table = pcim_iomap_table(pdev);
+	if (!iomap_table) {
+		dev_err(dev, "pcim_iomap_table failed\n");
+		ret = -ENOMEM;
+		goto e_err;
+	}
+
+	sp->io_map = iomap_table[sp->dev_data->bar];
+	if (!sp->io_map) {
+		dev_err(dev, "ioremap failed\n");
+		ret = -ENOMEM;
+		goto e_err;
+	}
+
+	ret = sp_get_irqs(sp);
+	if (ret)
+		goto e_err;
+
+	pci_set_master(pdev);
+
+	sp->set_master_device = sp_pci_set_master;
+	sp->get_master_device = sp_pci_get_master;
+
+	ret = dma_set_mask_and_coherent(dev, DMA_BIT_MASK(48));
+	if (ret) {
+		ret = dma_set_mask_and_coherent(dev, DMA_BIT_MASK(32));
+		if (ret) {
+			dev_err(dev, "dma_set_mask_and_coherent failed (%d)\n",
+				ret);
+			goto e_err;
+		}
+	}
+
+	dev_set_drvdata(dev, sp);
+
+	ret = sp_init(sp);
+	if (ret)
+		goto e_err;
+
+	dev_notice(dev, "enabled\n");
+
+	return 0;
+
+e_err:
+	dev_notice(dev, "initialization failed\n");
+
+	return ret;
+}
+
+static void sp_pci_remove(struct pci_dev *pdev)
+{
+	struct device *dev = &pdev->dev;
+	struct sp_device *sp = dev_get_drvdata(dev);
+
+	if (!sp)
+		return;
+
+	sp_destroy(sp);
+
+	sp_free_irqs(sp);
+
+	dev_notice(dev, "disabled\n");
+}
+
+#ifdef CONFIG_PM
+static int sp_pci_suspend(struct pci_dev *pdev, pm_message_t state)
+{
+	struct device *dev = &pdev->dev;
+	struct sp_device *sp = dev_get_drvdata(dev);
+
+	return sp_suspend(sp, state);
+}
+
+static int sp_pci_resume(struct pci_dev *pdev)
+{
+	struct device *dev = &pdev->dev;
+	struct sp_device *sp = dev_get_drvdata(dev);
+
+	return sp_resume(sp);
+}
+#endif
+
+extern struct ccp_vdata ccpv3_pci;
+extern struct ccp_vdata ccpv5a;
+extern struct ccp_vdata ccpv5b;
+
+static const struct sp_dev_data dev_data[] = {
+	{
+		.bar = 2,
+#ifdef CONFIG_CRYPTO_DEV_CCP
+		.ccp_vdata = &ccpv3_pci,
+#endif
+	},
+	{
+		.bar = 2,
+#ifdef CONFIG_CRYPTO_DEV_CCP
+		.ccp_vdata = &ccpv5a,
+#endif
+	},
+	{
+		.bar = 2,
+#ifdef CONFIG_CRYPTO_DEV_CCP
+		.ccp_vdata = &ccpv5b,
+#endif
+	},
+};
+
+static const struct pci_device_id sp_pci_table[] = {
+	{ PCI_VDEVICE(AMD, 0x1537), (kernel_ulong_t)&dev_data[0] },
+	{ PCI_VDEVICE(AMD, 0x1456), (kernel_ulong_t)&dev_data[1] },
+	{ PCI_VDEVICE(AMD, 0x1468), (kernel_ulong_t)&dev_data[2] },
+	/* Last entry must be zero */
+	{ 0, }
+};
+MODULE_DEVICE_TABLE(pci, sp_pci_table);
+
+static struct pci_driver sp_pci_driver = {
+	.name = "sp",
+	.id_table = sp_pci_table,
+	.probe = sp_pci_probe,
+	.remove = sp_pci_remove,
+#ifdef CONFIG_PM
+	.suspend = sp_pci_suspend,
+	.resume = sp_pci_resume,
+#endif
+};
+
+int sp_pci_init(void)
+{
+	return pci_register_driver(&sp_pci_driver);
+}
+
+void sp_pci_exit(void)
+{
+	pci_unregister_driver(&sp_pci_driver);
+}
diff --git a/drivers/crypto/ccp/sp-platform.c b/drivers/crypto/ccp/sp-platform.c
new file mode 100644
index 0000000..a918238
--- /dev/null
+++ b/drivers/crypto/ccp/sp-platform.c
@@ -0,0 +1,268 @@
+/*
+ * AMD Secure Processor driver
+ *
+ * Copyright (C) 2017 Advanced Micro Devices, Inc.
+ *
+ * Author: Brijesh Singh <brijesh.singh@amd.com>
+ * 	   Tom Lendacky <thomas.lendacky@amd.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/device.h>
+#include <linux/platform_device.h>
+#include <linux/ioport.h>
+#include <linux/dma-mapping.h>
+#include <linux/interrupt.h>
+#include <linux/spinlock.h>
+#include <linux/of.h>
+#include <linux/of_address.h>
+#include <linux/acpi.h>
+
+#include "sp-dev.h"
+
+struct sp_platform {
+	int coherent;
+	unsigned int irq_count;
+};
+
+static struct sp_device *sp_dev_master;
+static const struct acpi_device_id sp_acpi_match[];
+static const struct of_device_id sp_of_match[];
+
+static struct sp_dev_data *sp_get_of_dev_data(struct platform_device *pdev)
+{
+#ifdef CONFIG_OF
+	const struct of_device_id *match;
+
+	match = of_match_node(sp_of_match, pdev->dev.of_node);
+	if (match && match->data)
+		return (struct sp_dev_data *)match->data;
+#endif
+
+	return NULL;
+}
+
+static struct sp_dev_data *sp_get_acpi_dev_data(struct platform_device *pdev)
+{
+#ifdef CONFIG_ACPI
+	const struct acpi_device_id *match;
+
+	match = acpi_match_device(sp_acpi_match, &pdev->dev);
+	if (match && match->driver_data)
+		return (struct sp_dev_data *)match->driver_data;
+#endif
+
+	return NULL;
+}
+
+static int sp_get_irqs(struct sp_device *sp)
+{
+	struct sp_platform *sp_platform = sp->dev_specific;
+	struct device *dev = sp->dev;
+	struct platform_device *pdev = to_platform_device(dev);
+	unsigned int i, count;
+	int ret;
+
+	for (i = 0, count = 0; i < pdev->num_resources; i++) {
+		struct resource *res = &pdev->resource[i];
+
+		if (resource_type(res) == IORESOURCE_IRQ)
+			count++;
+	}
+
+	sp_platform->irq_count = count;
+
+	ret = platform_get_irq(pdev, 0);
+	if (ret < 0)
+		return ret;
+
+	sp->psp_irq = ret;
+	if (count == 1) {
+		sp->ccp_irq = ret;
+	} else {
+		ret = platform_get_irq(pdev, 1);
+		if (ret < 0)
+			return ret;
+
+		sp->ccp_irq = ret;
+	}
+
+	return 0;
+}
+
+void sp_platform_set_master(struct sp_device *sp)
+{
+	if (!sp_dev_master)
+		sp_dev_master = sp;
+}
+
+static int sp_platform_probe(struct platform_device *pdev)
+{
+	struct sp_device *sp;
+	struct sp_platform *sp_platform;
+	struct device *dev = &pdev->dev;
+	enum dev_dma_attr attr;
+	struct resource *ior;
+	int ret;
+
+	ret = -ENOMEM;
+	sp = sp_alloc_struct(dev);
+	if (!sp)
+		goto e_err;
+
+	sp_platform = devm_kzalloc(dev, sizeof(*sp_platform), GFP_KERNEL);
+	if (!sp_platform)
+		goto e_err;
+
+	sp->dev_specific = sp_platform;
+	sp->dev_data = pdev->dev.of_node ? sp_get_of_dev_data(pdev)
+					 : sp_get_acpi_dev_data(pdev);
+	if (!sp->dev_data) {
+		ret = -ENODEV;
+		dev_err(dev, "missing driver data\n");
+		goto e_err;
+	}
+
+	ior = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	sp->io_map = devm_ioremap_resource(dev, ior);
+	if (IS_ERR(sp->io_map)) {
+		ret = PTR_ERR(sp->io_map);
+		goto e_err;
+	}
+
+	attr = device_get_dma_attr(dev);
+	if (attr == DEV_DMA_NOT_SUPPORTED) {
+		dev_err(dev, "DMA is not supported");
+		goto e_err;
+	}
+
+	sp_platform->coherent = (attr == DEV_DMA_COHERENT);
+	if (sp_platform->coherent)
+		sp->axcache = CACHE_WB_NO_ALLOC;
+	else
+		sp->axcache = CACHE_NONE;
+
+	ret = dma_set_mask_and_coherent(dev, DMA_BIT_MASK(48));
+	if (ret) {
+		dev_err(dev, "dma_set_mask_and_coherent failed (%d)\n", ret);
+		goto e_err;
+	}
+
+	ret = sp_get_irqs(sp);
+	if (ret)
+		goto e_err;
+
+	dev_set_drvdata(dev, sp);
+
+	ret = sp_init(sp);
+	if (ret)
+		goto e_err;
+
+	dev_notice(dev, "enabled\n");
+
+	return 0;
+
+e_err:
+	dev_notice(dev, "initialization failed\n");
+
+	return ret;
+}
+
+static int sp_platform_remove(struct platform_device *pdev)
+{
+	struct device *dev = &pdev->dev;
+	struct sp_device *sp = dev_get_drvdata(dev);
+
+	if (!sp)
+		return 0;
+
+	sp_destroy(sp);
+
+	dev_notice(dev, "disabled\n");
+
+	return 0;
+}
+
+#ifdef CONFIG_PM
+static int sp_platform_suspend(struct platform_device *pdev,
+			       pm_message_t state)
+{
+	struct device *dev = &pdev->dev;
+	struct sp_device *sp = dev_get_drvdata(dev);
+
+	return sp_suspend(sp, state);
+}
+
+static int sp_platform_resume(struct platform_device *pdev)
+{
+	struct device *dev = &pdev->dev;
+	struct sp_device *sp = dev_get_drvdata(dev);
+
+	return sp_resume(sp);
+}
+#endif
+
+extern struct ccp_vdata ccpv3_platform;
+
+static const struct sp_dev_data dev_data[] = {
+	{
+#ifdef CONFIG_AMD_CCP
+		.ccp_vdata = &ccpv3_platform,
+#endif
+	},
+};
+
+#ifdef CONFIG_ACPI
+static const struct acpi_device_id sp_acpi_match[] = {
+	{ "AMDI0C00", (kernel_ulong_t)&dev_data[0] },
+	{ },
+};
+MODULE_DEVICE_TABLE(acpi, sp_acpi_match);
+#endif
+
+#ifdef CONFIG_OF
+static const struct of_device_id sp_of_match[] = {
+	{ .compatible = "amd,ccp-seattle-v1a",
+	  .data = (const void *)&dev_data[0] },
+	{ },
+};
+MODULE_DEVICE_TABLE(of, sp_of_match);
+#endif
+
+static struct platform_driver sp_platform_driver = {
+	.driver = {
+		.name = "sp",
+#ifdef CONFIG_ACPI
+		.acpi_match_table = sp_acpi_match,
+#endif
+#ifdef CONFIG_OF
+		.of_match_table = sp_of_match,
+#endif
+	},
+	.probe = sp_platform_probe,
+	.remove = sp_platform_remove,
+#ifdef CONFIG_PM
+	.suspend = sp_platform_suspend,
+	.resume = sp_platform_resume,
+#endif
+};
+
+struct sp_device *sp_platform_get_master(void)
+{
+	return sp_dev_master;
+}
+
+int sp_platform_init(void)
+{
+	return platform_driver_register(&sp_platform_driver);
+}
+
+void sp_platform_exit(void)
+{
+	platform_driver_unregister(&sp_platform_driver);
+}
diff --git a/include/linux/ccp.h b/include/linux/ccp.h
index c71dd8f..1ea14e6 100644
--- a/include/linux/ccp.h
+++ b/include/linux/ccp.h
@@ -24,8 +24,7 @@
 struct ccp_device;
 struct ccp_cmd;
 
-#if defined(CONFIG_CRYPTO_DEV_CCP_DD) || \
-	defined(CONFIG_CRYPTO_DEV_CCP_DD_MODULE)
+#if defined(CONFIG_CRYPTO_DEV_CCP)
 
 /**
  * ccp_present - check if a CCP device is present

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
