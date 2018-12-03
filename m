Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id BD86B6B6A7E
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 13:07:17 -0500 (EST)
Received: by mail-ot1-f71.google.com with SMTP id s3so5996330otb.0
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 10:07:17 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id q82si6483304oic.178.2018.12.03.10.07.16
        for <linux-mm@kvack.org>;
        Mon, 03 Dec 2018 10:07:16 -0800 (PST)
From: James Morse <james.morse@arm.com>
Subject: [PATCH v7 11/25] ACPI / APEI: Move NOTIFY_SEA between the estatus-queue and NOTIFY_NMI
Date: Mon,  3 Dec 2018 18:05:59 +0000
Message-Id: <20181203180613.228133-12-james.morse@arm.com>
In-Reply-To: <20181203180613.228133-1-james.morse@arm.com>
References: <20181203180613.228133-1-james.morse@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-acpi@vger.kernel.org
Cc: kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Fan Wu <wufan@codeaurora.org>, James Morse <james.morse@arm.com>

The estatus-queue code is currently hidden by the NOTIFY_NMI #ifdefs.
Once NOTIFY_SEA starts using the estatus-queue we can stop hiding
it as each architecture has a user that can't be turned off.

Split the existing CONFIG_HAVE_ACPI_APEI_NMI block in two, and move
the SEA code into the gap.

This patch moves code around ... and changes the stale comment
describing why the status queue is necessary: printk() is no
longer the issue, its the helpers like memory_failure_queue() that
aren't nmi safe.

Signed-off-by: James Morse <james.morse@arm.com>
---
 drivers/acpi/apei/ghes.c | 113 ++++++++++++++++++++-------------------
 1 file changed, 59 insertions(+), 54 deletions(-)

diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
index 15d94373ba72..00fe4785e469 100644
--- a/drivers/acpi/apei/ghes.c
+++ b/drivers/acpi/apei/ghes.c
@@ -765,66 +765,21 @@ static struct notifier_block ghes_notifier_hed = {
 	.notifier_call = ghes_notify_hed,
 };
 
-#ifdef CONFIG_ACPI_APEI_SEA
-static LIST_HEAD(ghes_sea);
-
-/*
- * Return 0 only if one of the SEA error sources successfully reported an error
- * record sent from the firmware.
- */
-int ghes_notify_sea(void)
-{
-	struct ghes *ghes;
-	int ret = -ENOENT;
-
-	rcu_read_lock();
-	list_for_each_entry_rcu(ghes, &ghes_sea, list) {
-		if (!ghes_proc(ghes))
-			ret = 0;
-	}
-	rcu_read_unlock();
-	return ret;
-}
-
-static void ghes_sea_add(struct ghes *ghes)
-{
-	mutex_lock(&ghes_list_mutex);
-	list_add_rcu(&ghes->list, &ghes_sea);
-	mutex_unlock(&ghes_list_mutex);
-}
-
-static void ghes_sea_remove(struct ghes *ghes)
-{
-	mutex_lock(&ghes_list_mutex);
-	list_del_rcu(&ghes->list);
-	mutex_unlock(&ghes_list_mutex);
-	synchronize_rcu();
-}
-#else /* CONFIG_ACPI_APEI_SEA */
-static inline void ghes_sea_add(struct ghes *ghes) { }
-static inline void ghes_sea_remove(struct ghes *ghes) { }
-#endif /* CONFIG_ACPI_APEI_SEA */
-
 #ifdef CONFIG_HAVE_ACPI_APEI_NMI
 /*
- * printk is not safe in NMI context.  So in NMI handler, we allocate
- * required memory from lock-less memory allocator
- * (ghes_estatus_pool), save estatus into it, put them into lock-less
- * list (ghes_estatus_llist), then delay printk into IRQ context via
- * irq_work (ghes_proc_irq_work).  ghes_estatus_size_request record
- * required pool size by all NMI error source.
+ * Handlers for CPER records may not be NMI safe. For example,
+ * memory_failure_queue() takes spinlocks and calls schedule_work_on().
+ * In any NMI-like handler, memory from ghes_estatus_pool is used to save
+ * estatus, and added to the ghes_estatus_llist. irq_work_queue() causes
+ * ghes_proc_in_irq() to run in IRQ context where each estatus in
+ * ghes_estatus_llist is processed.
+ *
+ * Memory from the ghes_estatus_pool is also used with the ghes_estatus_cache
+ * to suppress frequent messages.
  */
 static struct llist_head ghes_estatus_llist;
 static struct irq_work ghes_proc_irq_work;
 
-/*
- * NMI may be triggered on any CPU, so ghes_in_nmi is used for
- * having only one concurrent reader.
- */
-static atomic_t ghes_in_nmi = ATOMIC_INIT(0);
-
-static LIST_HEAD(ghes_nmi);
-
 static void ghes_proc_in_irq(struct irq_work *irq_work)
 {
 	struct llist_node *llnode, *next;
@@ -950,6 +905,56 @@ static int ghes_estatus_queue_notified(struct list_head *rcu_list)
 
 	return ret;
 }
+#endif /* CONFIG_HAVE_ACPI_APEI_NMI */
+
+#ifdef CONFIG_ACPI_APEI_SEA
+static LIST_HEAD(ghes_sea);
+
+/*
+ * Return 0 only if one of the SEA error sources successfully reported an error
+ * record sent from the firmware.
+ */
+int ghes_notify_sea(void)
+{
+	struct ghes *ghes;
+	int ret = -ENOENT;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(ghes, &ghes_sea, list) {
+		if (!ghes_proc(ghes))
+			ret = 0;
+	}
+	rcu_read_unlock();
+	return ret;
+}
+
+static void ghes_sea_add(struct ghes *ghes)
+{
+	mutex_lock(&ghes_list_mutex);
+	list_add_rcu(&ghes->list, &ghes_sea);
+	mutex_unlock(&ghes_list_mutex);
+}
+
+static void ghes_sea_remove(struct ghes *ghes)
+{
+	mutex_lock(&ghes_list_mutex);
+	list_del_rcu(&ghes->list);
+	mutex_unlock(&ghes_list_mutex);
+	synchronize_rcu();
+}
+#else /* CONFIG_ACPI_APEI_SEA */
+static inline void ghes_sea_add(struct ghes *ghes) { }
+static inline void ghes_sea_remove(struct ghes *ghes) { }
+#endif /* CONFIG_ACPI_APEI_SEA */
+
+#ifdef CONFIG_HAVE_ACPI_APEI_NMI
+/*
+ * NMI may be triggered on any CPU, so ghes_in_nmi is used for
+ * having only one concurrent reader.
+ */
+static atomic_t ghes_in_nmi = ATOMIC_INIT(0);
+
+static LIST_HEAD(ghes_nmi);
 
 static int ghes_notify_nmi(unsigned int cmd, struct pt_regs *regs)
 {
-- 
2.19.2
