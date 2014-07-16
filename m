Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 9863F6B0037
	for <linux-mm@kvack.org>; Tue, 15 Jul 2014 23:05:21 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id et14so434762pad.35
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 20:05:21 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id zt4si13280500pbc.55.2014.07.15.20.05.18
        for <linux-mm@kvack.org>;
        Tue, 15 Jul 2014 20:05:19 -0700 (PDT)
From: "Chen, Gong" <gong.chen@linux.intel.com>
Subject: [RFC PATCH 2/3] x86, MCE: Avoid potential deadlock in MCE context
Date: Tue, 15 Jul 2014 22:34:41 -0400
Message-Id: <1405478082-30757-3-git-send-email-gong.chen@linux.intel.com>
In-Reply-To: <1405478082-30757-1-git-send-email-gong.chen@linux.intel.com>
References: <1405478082-30757-1-git-send-email-gong.chen@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tony.luck@intel.com, bp@alien8.de
Cc: linux-acpi@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, "Chen, Gong" <gong.chen@linux.intel.com>

When Uncorrected error happens, an MCE will be raised. Some
notification callbacks will be called in MCE context. If
some notification call printk it will cause potential
deadlock because MCE can preempt normal interrupts like NMI does.

Since printk is not safe in MCE context. So a lock-less memory
allocator (genpool) is used to save information which are
organized via a lock-less list. Print will be delayed into IRQ
context via irq_work. This idea is inspired by APEI/GHES driver.

Reported-by: Xie XiuQi <xiexiuqi@huawei.com>
Signed-off-by: Chen, Gong <gong.chen@linux.intel.com>
---
 arch/x86/Kconfig                          |   1 +
 arch/x86/include/asm/mce.h                |   2 +-
 arch/x86/kernel/cpu/mcheck/Makefile       |   2 +-
 arch/x86/kernel/cpu/mcheck/mce-apei.c     |   2 +-
 arch/x86/kernel/cpu/mcheck/mce-genpool.c  | 109 ++++++++++++++++++++++++++++++
 arch/x86/kernel/cpu/mcheck/mce-internal.h |   9 +++
 arch/x86/kernel/cpu/mcheck/mce.c          |  21 ++++--
 arch/x86/kernel/cpu/mcheck/mce_amd.c      |   2 +-
 8 files changed, 137 insertions(+), 11 deletions(-)
 create mode 100644 arch/x86/kernel/cpu/mcheck/mce-genpool.c

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index a8f749e..2632732 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -861,6 +861,7 @@ config X86_REROUTE_FOR_BROKEN_BOOT_IRQS
 
 config X86_MCE
 	bool "Machine Check / overheating reporting"
+	select GENERIC_ALLOCATOR
 	default y
 	---help---
 	  Machine Check support allows the processor to notify the
diff --git a/arch/x86/include/asm/mce.h b/arch/x86/include/asm/mce.h
index 958b90f..e90d8ac 100644
--- a/arch/x86/include/asm/mce.h
+++ b/arch/x86/include/asm/mce.h
@@ -141,7 +141,7 @@ static inline void enable_p5_mce(void) {}
 #endif
 
 void mce_setup(struct mce *m);
-void mce_log(struct mce *m);
+void mce_log(struct mce *m, int);
 DECLARE_PER_CPU(struct device *, mce_device);
 
 /*
diff --git a/arch/x86/kernel/cpu/mcheck/Makefile b/arch/x86/kernel/cpu/mcheck/Makefile
index bb34b03..a3311c8 100644
--- a/arch/x86/kernel/cpu/mcheck/Makefile
+++ b/arch/x86/kernel/cpu/mcheck/Makefile
@@ -1,4 +1,4 @@
-obj-y				=  mce.o mce-severity.o
+obj-y				=  mce.o mce-severity.o mce-genpool.o
 
 obj-$(CONFIG_X86_ANCIENT_MCE)	+= winchip.o p5.o
 obj-$(CONFIG_X86_MCE_INTEL)	+= mce_intel.o
diff --git a/arch/x86/kernel/cpu/mcheck/mce-apei.c b/arch/x86/kernel/cpu/mcheck/mce-apei.c
index a1aef95..7b92089 100644
--- a/arch/x86/kernel/cpu/mcheck/mce-apei.c
+++ b/arch/x86/kernel/cpu/mcheck/mce-apei.c
@@ -56,7 +56,7 @@ void apei_mce_report_mem_error(int severity, struct cper_sec_mem_err *mem_err)
 		m.status |= MCI_STATUS_PCC;
 
 	m.addr = mem_err->physical_addr;
-	mce_log(&m);
+	mce_log(&m, 0);
 	mce_notify_irq();
 }
 EXPORT_SYMBOL_GPL(apei_mce_report_mem_error);
diff --git a/arch/x86/kernel/cpu/mcheck/mce-genpool.c b/arch/x86/kernel/cpu/mcheck/mce-genpool.c
new file mode 100644
index 0000000..1c08c37
--- /dev/null
+++ b/arch/x86/kernel/cpu/mcheck/mce-genpool.c
@@ -0,0 +1,109 @@
+/*
+ * Print memory pool management in MCE context
+ *
+ * Copyright (C) 2014 Intel Corp.
+ * Author: Chen, Gong <gong.chen@linux.intel.com>
+ *
+ * This file is licensed under GPLv2.
+ */
+#include <linux/mm.h>
+#include <linux/genalloc.h>
+#include <linux/llist.h>
+#include <linux/irq_work.h>
+#include "mce-internal.h"
+
+/*
+ * printk is not safe in MCE context. So a lock-less memory allocator
+ * (genpool) is used to save information which are organized via a lock-less
+ * list. Print will be delayed into IRQ context via irq_work.
+ */
+static struct gen_pool *mce_evt_pool;
+static struct llist_head mce_event_llist;
+static struct irq_work mce_irqwork;
+static int mce_evt_len;
+static bool pool_inactive;
+
+/*
+ * This memory pool is only to be used to save MCE records in MCE context.
+ * The MCE event is rare so a fixed size memory pool should be enough.
+ */
+static int mce_genpool_create(void)
+{
+	int i, ret, pages;
+	unsigned long addr;
+
+	mce_evt_len = sizeof(struct mce_evt_llist);
+	mce_evt_pool = gen_pool_create(ilog2(mce_evt_len), -1);
+	if (!mce_evt_pool)
+		return -ENOMEM;
+
+	/* two pages should be enough */
+	pages = 2;
+	for (i = 0; i < pages; i++) {
+		addr = __get_free_page(GFP_KERNEL);
+		if (!addr)
+			return -ENOMEM;
+		ret = gen_pool_add(mce_evt_pool, addr, PAGE_SIZE, -1);
+		if (ret)
+			return ret;
+	}
+
+	return 0;
+}
+
+static void free_chunk_page(struct gen_pool *pool,
+		struct gen_pool_chunk *chunk, void *data)
+{
+	free_page(chunk->start_addr);
+}
+
+static void mce_evt_pool_destroy(void)
+{
+	gen_pool_for_each_chunk(mce_evt_pool, free_chunk_page, NULL);
+	gen_pool_destroy(mce_evt_pool);
+}
+
+static void do_mce_irqwork(struct irq_work *irq_work)
+{
+	struct llist_node *llnode, *next;
+	struct mce_evt_llist *node;
+	struct mce *mce;
+
+	llnode = llist_del_all(&mce_event_llist);
+	/* print MCE event record from the oldest */
+	llnode = llist_reverse_order(llnode);
+	while (llnode) {
+		next = llnode->next;
+		node = llist_entry(llnode, struct mce_evt_llist, llnode);
+		mce = &node->mce;
+		atomic_notifier_call_chain(&x86_mce_decoder_chain, 0, mce);
+		gen_pool_free(mce_evt_pool, (unsigned long)node, mce_evt_len);
+		llnode = next;
+	}
+}
+
+void mce_evt_save_ll(struct mce *mce)
+{
+	struct mce_evt_llist *node;
+
+	if (unlikely(pool_inactive))
+		return;
+
+	node = (void *)gen_pool_alloc(mce_evt_pool, mce_evt_len);
+	if (node) {
+		memcpy(&node->mce, mce, mce_evt_len);
+		llist_add(&node->llnode, &mce_event_llist);
+		irq_work_queue(&mce_irqwork);
+	}
+}
+
+void __init mce_genpool_init(void)
+{
+	if (mce_genpool_create() != 0)
+		pool_inactive = true;
+
+	if (pool_inactive)
+		mce_evt_pool_destroy();
+	else
+		init_irq_work(&mce_irqwork, do_mce_irqwork);
+}
diff --git a/arch/x86/kernel/cpu/mcheck/mce-internal.h b/arch/x86/kernel/cpu/mcheck/mce-internal.h
index 09edd0b..005a688 100644
--- a/arch/x86/kernel/cpu/mcheck/mce-internal.h
+++ b/arch/x86/kernel/cpu/mcheck/mce-internal.h
@@ -11,6 +11,8 @@ enum severity_level {
 	MCE_PANIC_SEVERITY,
 };
 
+extern struct atomic_notifier_head x86_mce_decoder_chain;
+
 #define ATTR_LEN		16
 
 /* One object for each MCE bank, shared by all CPUs */
@@ -21,6 +23,13 @@ struct mce_bank {
 	char			attrname[ATTR_LEN];	/* attribute name */
 };
 
+struct mce_evt_llist {
+	struct llist_node llnode;
+	struct mce mce;
+};
+
+void mce_evt_save_ll(struct mce *mce);
+void __init mce_genpool_init(void);
 int mce_severity(struct mce *a, int tolerant, char **msg);
 struct dentry *mce_get_debugfs_dir(void);
 
diff --git a/arch/x86/kernel/cpu/mcheck/mce.c b/arch/x86/kernel/cpu/mcheck/mce.c
index bb92f38..dcca519 100644
--- a/arch/x86/kernel/cpu/mcheck/mce.c
+++ b/arch/x86/kernel/cpu/mcheck/mce.c
@@ -147,7 +147,7 @@ static struct mce_log mcelog = {
 	.recordlen	= sizeof(struct mce),
 };
 
-void mce_log(struct mce *mce)
+void mce_log(struct mce *mce, int in_mce)
 {
 	unsigned next, entry;
 	int ret = 0;
@@ -155,9 +155,14 @@ void mce_log(struct mce *mce)
 	/* Emit the trace record: */
 	trace_mce_record(mce);
 
-	ret = atomic_notifier_call_chain(&x86_mce_decoder_chain, 0, mce);
-	if (ret == NOTIFY_STOP)
-		return;
+	if (in_mce)
+		mce_evt_save_ll(mce);
+	else {
+		ret = atomic_notifier_call_chain(&x86_mce_decoder_chain, 0,
+						 mce);
+		if (ret == NOTIFY_STOP)
+			return;
+	}
 
 	mce->finished = 0;
 	wmb();
@@ -635,7 +640,7 @@ void machine_check_poll(enum mcp_flags flags, mce_banks_t *b)
 		 * have anything to do with the actual error location.
 		 */
 		if (!(flags & MCP_DONTLOG) && !mca_cfg.dont_log_ce)
-			mce_log(&m);
+			mce_log(&m, 0);
 
 		/*
 		 * Clear state for this bank.
@@ -1124,7 +1129,7 @@ void do_machine_check(struct pt_regs *regs, long error_code)
 		if (severity == MCE_AO_SEVERITY && mce_usable_address(&m))
 			mce_ring_add(m.addr >> PAGE_SHIFT);
 
-		mce_log(&m);
+		mce_log(&m, 1);
 
 		if (severity > worst) {
 			*final = m;
@@ -1254,7 +1259,7 @@ void mce_log_therm_throt_event(__u64 status)
 	mce_setup(&m);
 	m.bank = MCE_THERMAL_BANK;
 	m.status = status;
-	mce_log(&m);
+	mce_log(&m, 0);
 }
 #endif /* CONFIG_X86_MCE_INTEL */
 
@@ -2466,6 +2471,8 @@ static __init int mcheck_init_device(void)
 	if (err)
 		goto err_register;
 
+	mce_genpool_init();
+
 	return 0;
 
 err_register:
diff --git a/arch/x86/kernel/cpu/mcheck/mce_amd.c b/arch/x86/kernel/cpu/mcheck/mce_amd.c
index 603df4f..ca64641 100644
--- a/arch/x86/kernel/cpu/mcheck/mce_amd.c
+++ b/arch/x86/kernel/cpu/mcheck/mce_amd.c
@@ -319,7 +319,7 @@ static void amd_threshold_interrupt(void)
 				m.bank = K8_MCE_THRESHOLD_BASE
 				       + bank * NR_BLOCKS
 				       + block;
-				mce_log(&m);
+				mce_log(&m, 0);
 				return;
 			}
 		}
-- 
2.0.0.rc2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
