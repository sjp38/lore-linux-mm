Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 64C3C6B0008
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 13:58:52 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id x9so329209oie.2
        for <linux-mm@kvack.org>; Thu, 15 Feb 2018 10:58:52 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id u71si1566561oiu.58.2018.02.15.10.58.50
        for <linux-mm@kvack.org>;
        Thu, 15 Feb 2018 10:58:51 -0800 (PST)
From: James Morse <james.morse@arm.com>
Subject: [PATCH 01/11] ACPI / APEI: Move the estatus queue code up, and under its own ifdef
Date: Thu, 15 Feb 2018 18:55:56 +0000
Message-Id: <20180215185606.26736-2-james.morse@arm.com>
In-Reply-To: <20180215185606.26736-1-james.morse@arm.com>
References: <20180215185606.26736-1-james.morse@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-acpi@vger.kernel.org
Cc: kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, Christoffer Dall <christoffer.dall@linaro.org>, Marc Zyngier <marc.zyngier@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Punit Agrawal <punit.agrawal@arm.com>, James Morse <james.morse@arm.com>

To support asynchronous NMI-like notifications on arm64 we need to use
the estatus-queue. These patches refactor it to allow multiple APEI
notification types to use it.

First we move the estatus-queue code higher in the file so that any
notify_foo() handler can make user of it.

This patch moves code around ... and makes the following trivial change:
Freshen the dated comment above ghes_estatus_llist. printk() is no
longer the issue, its the helpers like memory_failure_queue() that
still aren't nmi safe.

Signed-off-by: James Morse <james.morse@arm.com>
---
 drivers/acpi/apei/ghes.c | 267 ++++++++++++++++++++++++-----------------------
 1 file changed, 139 insertions(+), 128 deletions(-)

diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
index 1efefe919555..e42b587c509b 100644
--- a/drivers/acpi/apei/ghes.c
+++ b/drivers/acpi/apei/ghes.c
@@ -545,6 +545,16 @@ static int ghes_print_estatus(const char *pfx,
 	return 0;
 }
 
+static void __ghes_panic(struct ghes *ghes)
+{
+	__ghes_print_estatus(KERN_EMERG, ghes->generic, ghes->estatus);
+
+	/* reboot to log the error! */
+	if (!panic_timeout)
+		panic_timeout = ghes_panic_timeout;
+	panic("Fatal hardware error!");
+}
+
 /*
  * GHES error status reporting throttle, to report more kinds of
  * errors, instead of just most frequently occurred errors.
@@ -672,6 +682,135 @@ static void ghes_estatus_cache_add(
 	rcu_read_unlock();
 }
 
+#ifdef CONFIG_HAVE_ACPI_APEI_NMI
+/*
+ * While printk() now has an in_nmi() path, the handling for CPER records
+ * does not. For example, memory_failure_queue() takes spinlocks and calls
+ * schedule_work_on().
+ *
+ * So in any NMI-like handler, we allocate required memory from lock-less
+ * memory allocator (ghes_estatus_pool), save estatus into it, put them into
+ * lock-less list (ghes_estatus_llist), then delay printk into IRQ context via
+ * irq_work (ghes_proc_irq_work).  ghes_estatus_size_request record
+ * required pool size by all NMI error source.
+ *
+ * Memory from the ghes_estatus_pool is also used with the ghes_estatus_cache
+ * to suppress frequent messages.
+ */
+static struct llist_head ghes_estatus_llist;
+static struct irq_work ghes_proc_irq_work;
+
+static void ghes_print_queued_estatus(void)
+{
+	struct llist_node *llnode;
+	struct ghes_estatus_node *estatus_node;
+	struct acpi_hest_generic *generic;
+	struct acpi_hest_generic_status *estatus;
+
+	llnode = llist_del_all(&ghes_estatus_llist);
+	/*
+	 * Because the time order of estatus in list is reversed,
+	 * revert it back to proper order.
+	 */
+	llnode = llist_reverse_order(llnode);
+	while (llnode) {
+		estatus_node = llist_entry(llnode, struct ghes_estatus_node,
+					   llnode);
+		estatus = GHES_ESTATUS_FROM_NODE(estatus_node);
+		generic = estatus_node->generic;
+		ghes_print_estatus(NULL, generic, estatus);
+		llnode = llnode->next;
+	}
+}
+
+/* Save estatus for further processing in IRQ context */
+static void __process_error(struct ghes *ghes)
+{
+#ifdef CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG
+	u32 len, node_len;
+	struct ghes_estatus_node *estatus_node;
+	struct acpi_hest_generic_status *estatus;
+
+	if (ghes_estatus_cached(ghes->estatus))
+		return;
+
+	len = cper_estatus_len(ghes->estatus);
+	node_len = GHES_ESTATUS_NODE_LEN(len);
+
+	estatus_node = (void *)gen_pool_alloc(ghes_estatus_pool, node_len);
+	if (!estatus_node)
+		return;
+
+	estatus_node->ghes = ghes;
+	estatus_node->generic = ghes->generic;
+	estatus = GHES_ESTATUS_FROM_NODE(estatus_node);
+	memcpy(estatus, ghes->estatus, len);
+	llist_add(&estatus_node->llnode, &ghes_estatus_llist);
+#endif
+}
+
+static unsigned long ghes_esource_prealloc_size(
+	const struct acpi_hest_generic *generic)
+{
+	unsigned long block_length, prealloc_records, prealloc_size;
+
+	block_length = min_t(unsigned long, generic->error_block_length,
+			     GHES_ESTATUS_MAX_SIZE);
+	prealloc_records = max_t(unsigned long,
+				 generic->records_to_preallocate, 1);
+	prealloc_size = min_t(unsigned long, block_length * prealloc_records,
+			      GHES_ESOURCE_PREALLOC_MAX_SIZE);
+
+	return prealloc_size;
+}
+
+static void ghes_estatus_pool_shrink(unsigned long len)
+{
+	ghes_estatus_pool_size_request -= PAGE_ALIGN(len);
+}
+
+static void ghes_proc_in_irq(struct irq_work *irq_work)
+{
+	struct llist_node *llnode, *next;
+	struct ghes_estatus_node *estatus_node;
+	struct acpi_hest_generic *generic;
+	struct acpi_hest_generic_status *estatus;
+	u32 len, node_len;
+
+	llnode = llist_del_all(&ghes_estatus_llist);
+	/*
+	 * Because the time order of estatus in list is reversed,
+	 * revert it back to proper order.
+	 */
+	llnode = llist_reverse_order(llnode);
+	while (llnode) {
+		next = llnode->next;
+		estatus_node = llist_entry(llnode, struct ghes_estatus_node,
+					   llnode);
+		estatus = GHES_ESTATUS_FROM_NODE(estatus_node);
+		len = cper_estatus_len(estatus);
+		node_len = GHES_ESTATUS_NODE_LEN(len);
+		ghes_do_proc(estatus_node->ghes, estatus);
+		if (!ghes_estatus_cached(estatus)) {
+			generic = estatus_node->generic;
+			if (ghes_print_estatus(NULL, generic, estatus))
+				ghes_estatus_cache_add(generic, estatus);
+		}
+		gen_pool_free(ghes_estatus_pool, (unsigned long)estatus_node,
+			      node_len);
+		llnode = next;
+	}
+}
+
+static void ghes_nmi_init_cxt(void)
+{
+	init_irq_work(&ghes_proc_irq_work, ghes_proc_in_irq);
+}
+
+#else
+static inline void ghes_nmi_init_cxt(void) { }
+#endif /* CONFIG_HAVE_ACPI_APEI_NMI */
+
 static int ghes_ack_error(struct acpi_hest_generic_v2 *gv2)
 {
 	int rc;
@@ -687,16 +826,6 @@ static int ghes_ack_error(struct acpi_hest_generic_v2 *gv2)
 	return apei_write(val, &gv2->read_ack_register);
 }
 
-static void __ghes_panic(struct ghes *ghes)
-{
-	__ghes_print_estatus(KERN_EMERG, ghes->generic, ghes->estatus);
-
-	/* reboot to log the error! */
-	if (!panic_timeout)
-		panic_timeout = ghes_panic_timeout;
-	panic("Fatal hardware error!");
-}
-
 static int ghes_proc(struct ghes *ghes)
 {
 	int rc;
@@ -828,17 +957,6 @@ static inline void ghes_sea_remove(struct ghes *ghes) { }
 #endif /* CONFIG_ACPI_APEI_SEA */
 
 #ifdef CONFIG_HAVE_ACPI_APEI_NMI
-/*
- * printk is not safe in NMI context.  So in NMI handler, we allocate
- * required memory from lock-less memory allocator
- * (ghes_estatus_pool), save estatus into it, put them into lock-less
- * list (ghes_estatus_llist), then delay printk into IRQ context via
- * irq_work (ghes_proc_irq_work).  ghes_estatus_size_request record
- * required pool size by all NMI error source.
- */
-static struct llist_head ghes_estatus_llist;
-static struct irq_work ghes_proc_irq_work;
-
 /*
  * NMI may be triggered on any CPU, so ghes_in_nmi is used for
  * having only one concurrent reader.
@@ -847,88 +965,6 @@ static atomic_t ghes_in_nmi = ATOMIC_INIT(0);
 
 static LIST_HEAD(ghes_nmi);
 
-static void ghes_proc_in_irq(struct irq_work *irq_work)
-{
-	struct llist_node *llnode, *next;
-	struct ghes_estatus_node *estatus_node;
-	struct acpi_hest_generic *generic;
-	struct acpi_hest_generic_status *estatus;
-	u32 len, node_len;
-
-	llnode = llist_del_all(&ghes_estatus_llist);
-	/*
-	 * Because the time order of estatus in list is reversed,
-	 * revert it back to proper order.
-	 */
-	llnode = llist_reverse_order(llnode);
-	while (llnode) {
-		next = llnode->next;
-		estatus_node = llist_entry(llnode, struct ghes_estatus_node,
-					   llnode);
-		estatus = GHES_ESTATUS_FROM_NODE(estatus_node);
-		len = cper_estatus_len(estatus);
-		node_len = GHES_ESTATUS_NODE_LEN(len);
-		ghes_do_proc(estatus_node->ghes, estatus);
-		if (!ghes_estatus_cached(estatus)) {
-			generic = estatus_node->generic;
-			if (ghes_print_estatus(NULL, generic, estatus))
-				ghes_estatus_cache_add(generic, estatus);
-		}
-		gen_pool_free(ghes_estatus_pool, (unsigned long)estatus_node,
-			      node_len);
-		llnode = next;
-	}
-}
-
-static void ghes_print_queued_estatus(void)
-{
-	struct llist_node *llnode;
-	struct ghes_estatus_node *estatus_node;
-	struct acpi_hest_generic *generic;
-	struct acpi_hest_generic_status *estatus;
-
-	llnode = llist_del_all(&ghes_estatus_llist);
-	/*
-	 * Because the time order of estatus in list is reversed,
-	 * revert it back to proper order.
-	 */
-	llnode = llist_reverse_order(llnode);
-	while (llnode) {
-		estatus_node = llist_entry(llnode, struct ghes_estatus_node,
-					   llnode);
-		estatus = GHES_ESTATUS_FROM_NODE(estatus_node);
-		generic = estatus_node->generic;
-		ghes_print_estatus(NULL, generic, estatus);
-		llnode = llnode->next;
-	}
-}
-
-/* Save estatus for further processing in IRQ context */
-static void __process_error(struct ghes *ghes)
-{
-#ifdef CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG
-	u32 len, node_len;
-	struct ghes_estatus_node *estatus_node;
-	struct acpi_hest_generic_status *estatus;
-
-	if (ghes_estatus_cached(ghes->estatus))
-		return;
-
-	len = cper_estatus_len(ghes->estatus);
-	node_len = GHES_ESTATUS_NODE_LEN(len);
-
-	estatus_node = (void *)gen_pool_alloc(ghes_estatus_pool, node_len);
-	if (!estatus_node)
-		return;
-
-	estatus_node->ghes = ghes;
-	estatus_node->generic = ghes->generic;
-	estatus = GHES_ESTATUS_FROM_NODE(estatus_node);
-	memcpy(estatus, ghes->estatus, len);
-	llist_add(&estatus_node->llnode, &ghes_estatus_llist);
-#endif
-}
-
 static int ghes_notify_nmi(unsigned int cmd, struct pt_regs *regs)
 {
 	struct ghes *ghes;
@@ -967,26 +1003,6 @@ static int ghes_notify_nmi(unsigned int cmd, struct pt_regs *regs)
 	return ret;
 }
 
-static unsigned long ghes_esource_prealloc_size(
-	const struct acpi_hest_generic *generic)
-{
-	unsigned long block_length, prealloc_records, prealloc_size;
-
-	block_length = min_t(unsigned long, generic->error_block_length,
-			     GHES_ESTATUS_MAX_SIZE);
-	prealloc_records = max_t(unsigned long,
-				 generic->records_to_preallocate, 1);
-	prealloc_size = min_t(unsigned long, block_length * prealloc_records,
-			      GHES_ESOURCE_PREALLOC_MAX_SIZE);
-
-	return prealloc_size;
-}
-
-static void ghes_estatus_pool_shrink(unsigned long len)
-{
-	ghes_estatus_pool_size_request -= PAGE_ALIGN(len);
-}
-
 static void ghes_nmi_add(struct ghes *ghes)
 {
 	unsigned long len;
@@ -1018,14 +1034,9 @@ static void ghes_nmi_remove(struct ghes *ghes)
 	ghes_estatus_pool_shrink(len);
 }
 
-static void ghes_nmi_init_cxt(void)
-{
-	init_irq_work(&ghes_proc_irq_work, ghes_proc_in_irq);
-}
 #else /* CONFIG_HAVE_ACPI_APEI_NMI */
 static inline void ghes_nmi_add(struct ghes *ghes) { }
 static inline void ghes_nmi_remove(struct ghes *ghes) { }
-static inline void ghes_nmi_init_cxt(void) { }
 #endif /* CONFIG_HAVE_ACPI_APEI_NMI */
 
 static int ghes_probe(struct platform_device *ghes_dev)
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
