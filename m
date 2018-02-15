Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 684E46B000A
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 13:58:56 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id d84so324286oia.4
        for <linux-mm@kvack.org>; Thu, 15 Feb 2018 10:58:56 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id z24si1403785otd.435.2018.02.15.10.58.54
        for <linux-mm@kvack.org>;
        Thu, 15 Feb 2018 10:58:55 -0800 (PST)
From: James Morse <james.morse@arm.com>
Subject: [PATCH 02/11] ACPI / APEI: Generalise the estatus queue's add/remove and notify code
Date: Thu, 15 Feb 2018 18:55:57 +0000
Message-Id: <20180215185606.26736-3-james.morse@arm.com>
In-Reply-To: <20180215185606.26736-1-james.morse@arm.com>
References: <20180215185606.26736-1-james.morse@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-acpi@vger.kernel.org
Cc: kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, Christoffer Dall <christoffer.dall@linaro.org>, Marc Zyngier <marc.zyngier@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Punit Agrawal <punit.agrawal@arm.com>, James Morse <james.morse@arm.com>

To support asynchronous NMI-like notifications on arm64 we need to use
the estatus-queue. These patches refactor it to allow multiple APEI
notification types to use it.

Refactor the estatus queue's pool grow/shrink code and notification
routine from NOTIFY_NMI's handlers. This will allow another notification
method to use the estatus queue without duplicating this code.

This patch adds rcu_read_lock()/rcu_read_unlock() around the list
list_for_each_entry_rcu() walker. These aren't strictly necessary as
the whole nmi_enter/nmi_exit() window is a spooky RCU read-side
critical section.

Keep the oops_begin() call for x86, arm64 doesn't have one of these,
and APEI is the only thing outside arch code calling this..

The existing ghes_estatus_pool_shrink() is folded into the new
ghes_estatus_queue_shrink_pool() as only the queue uses it.

_in_nmi_notify_one() is separate from the rcu-list walker for a later
caller that doesn't need to walk a list.

Signed-off-by: James Morse <james.morse@arm.com>
---
 drivers/acpi/apei/ghes.c | 103 +++++++++++++++++++++++++++++++----------------
 1 file changed, 68 insertions(+), 35 deletions(-)

diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
index e42b587c509b..d3cc5bd5b496 100644
--- a/drivers/acpi/apei/ghes.c
+++ b/drivers/acpi/apei/ghes.c
@@ -749,6 +749,54 @@ static void __process_error(struct ghes *ghes)
 #endif
 }
 
+static int _in_nmi_notify_one(struct ghes *ghes)
+{
+	int sev;
+	int ret = -ENOENT;
+
+	if (ghes_read_estatus(ghes, 1)) {
+		ghes_clear_estatus(ghes);
+		return ret;
+	} else {
+		ret = 0;
+	}
+
+	sev = ghes_severity(ghes->estatus->error_severity);
+	if (sev >= GHES_SEV_PANIC) {
+#ifdef CONFIG_X86
+		oops_begin();
+#endif
+		ghes_print_queued_estatus();
+		__ghes_panic(ghes);
+	}
+
+	if (!(ghes->flags & GHES_TO_CLEAR))
+		return ret;
+
+	__process_error(ghes);
+	ghes_clear_estatus(ghes);
+
+	return ret;
+}
+
+static int ghes_estatus_queue_notified(struct list_head *rcu_list)
+{
+	int ret = -ENOENT;
+	struct ghes *ghes;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(ghes, rcu_list, list) {
+		if (!_in_nmi_notify_one(ghes))
+			ret = 0;
+	}
+	rcu_read_unlock();
+
+	if (IS_ENABLED(CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG) && ret == 0)
+		irq_work_queue(&ghes_proc_irq_work);
+
+	return ret;
+}
+
 static unsigned long ghes_esource_prealloc_size(
 	const struct acpi_hest_generic *generic)
 {
@@ -764,11 +812,24 @@ static unsigned long ghes_esource_prealloc_size(
 	return prealloc_size;
 }
 
-static void ghes_estatus_pool_shrink(unsigned long len)
+/* After removing a queue user, we can shrink to pool */
+static void ghes_estatus_queue_shrink_pool(struct ghes *ghes)
 {
+	unsigned long len;
+
+	len = ghes_esource_prealloc_size(ghes->generic);
 	ghes_estatus_pool_size_request -= PAGE_ALIGN(len);
 }
 
+/* Before adding a queue user, grow the pool */
+static void ghes_estatus_queue_grow_pool(struct ghes *ghes)
+{
+	unsigned long len;
+
+	len = ghes_esource_prealloc_size(ghes->generic);
+	ghes_estatus_pool_expand(len);
+}
+
 static void ghes_proc_in_irq(struct irq_work *irq_work)
 {
 	struct llist_node *llnode, *next;
@@ -967,48 +1028,22 @@ static LIST_HEAD(ghes_nmi);
 
 static int ghes_notify_nmi(unsigned int cmd, struct pt_regs *regs)
 {
-	struct ghes *ghes;
-	int sev, ret = NMI_DONE;
+	int ret = NMI_DONE;
 
 	if (!atomic_add_unless(&ghes_in_nmi, 1, 1))
 		return ret;
 
-	list_for_each_entry_rcu(ghes, &ghes_nmi, list) {
-		if (ghes_read_estatus(ghes, 1)) {
-			ghes_clear_estatus(ghes);
-			continue;
-		} else {
-			ret = NMI_HANDLED;
-		}
-
-		sev = ghes_severity(ghes->estatus->error_severity);
-		if (sev >= GHES_SEV_PANIC) {
-			oops_begin();
-			ghes_print_queued_estatus();
-			__ghes_panic(ghes);
-		}
-
-		if (!(ghes->flags & GHES_TO_CLEAR))
-			continue;
-
-		__process_error(ghes);
-		ghes_clear_estatus(ghes);
-	}
+	if (!ghes_estatus_queue_notified(&ghes_nmi))
+		ret = NMI_HANDLED;
 
-#ifdef CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG
-	if (ret == NMI_HANDLED)
-		irq_work_queue(&ghes_proc_irq_work);
-#endif
 	atomic_dec(&ghes_in_nmi);
 	return ret;
 }
 
 static void ghes_nmi_add(struct ghes *ghes)
 {
-	unsigned long len;
+	ghes_estatus_queue_grow_pool(ghes);
 
-	len = ghes_esource_prealloc_size(ghes->generic);
-	ghes_estatus_pool_expand(len);
 	mutex_lock(&ghes_list_mutex);
 	if (list_empty(&ghes_nmi))
 		register_nmi_handler(NMI_LOCAL, ghes_notify_nmi, 0, "ghes");
@@ -1018,8 +1053,6 @@ static void ghes_nmi_add(struct ghes *ghes)
 
 static void ghes_nmi_remove(struct ghes *ghes)
 {
-	unsigned long len;
-
 	mutex_lock(&ghes_list_mutex);
 	list_del_rcu(&ghes->list);
 	if (list_empty(&ghes_nmi))
@@ -1030,8 +1063,8 @@ static void ghes_nmi_remove(struct ghes *ghes)
 	 * freed after NMI handler finishes.
 	 */
 	synchronize_rcu();
-	len = ghes_esource_prealloc_size(ghes->generic);
-	ghes_estatus_pool_shrink(len);
+
+	ghes_estatus_queue_shrink_pool(ghes);
 }
 
 #else /* CONFIG_HAVE_ACPI_APEI_NMI */
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
