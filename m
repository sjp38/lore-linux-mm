Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9017C8E0001
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 18:17:53 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id e38-v6so13811352otj.15
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 15:17:53 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id s8-v6si10269727ote.403.2018.09.21.15.17.52
        for <linux-mm@kvack.org>;
        Fri, 21 Sep 2018 15:17:52 -0700 (PDT)
From: James Morse <james.morse@arm.com>
Subject: [PATCH v6 02/18] ACPI / APEI: Generalise the estatus queue's add/remove and notify code
Date: Fri, 21 Sep 2018 23:16:49 +0100
Message-Id: <20180921221705.6478-3-james.morse@arm.com>
In-Reply-To: <20180921221705.6478-1-james.morse@arm.com>
References: <20180921221705.6478-1-james.morse@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-acpi@vger.kernel.org
Cc: kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Punit Agrawal <punit.agrawal@arm.com>, jonathan.zhang@cavium.com, James Morse <james.morse@arm.com>

Refactor the estatus queue's pool grow/shrink code and notification
routine from NOTIFY_NMI's handlers. This will allow another notification
method to use the estatus queue without duplicating this code.

This patch adds rcu_read_lock()/rcu_read_unlock() around the list
list_for_each_entry_rcu() walker. These aren't strictly necessary as
the whole nmi_enter/nmi_exit() window is a spooky RCU read-side
critical section.

The existing ghes_estatus_pool_shrink() is folded into the new
ghes_estatus_queue_shrink_pool() as only the queue uses it.

_in_nmi_notify_one() is separate from the rcu-list walker for a later
caller that doesn't need to walk a list.

Signed-off-by: James Morse <james.morse@arm.com>
Reviewed-by: Punit Agrawal <punit.agrawal@arm.com>
Tested-by: Tyler Baicar <tbaicar@codeaurora.org>

---
Changes since v3:
 * Removed dupicate or redundant paragraphs in commit message.
 * Fixed the style of a zero check
Changes since v1:
 * Tidied up _in_nmi_notify_one().
---
 drivers/acpi/apei/ghes.c | 100 +++++++++++++++++++++++++--------------
 1 file changed, 65 insertions(+), 35 deletions(-)

diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
index f5732e6b5be8..29d863ff2f87 100644
--- a/drivers/acpi/apei/ghes.c
+++ b/drivers/acpi/apei/ghes.c
@@ -747,6 +747,51 @@ static void __process_error(struct ghes *ghes)
 #endif
 }
 
+static int _in_nmi_notify_one(struct ghes *ghes)
+{
+	int sev;
+
+	if (ghes_read_estatus(ghes, 1)) {
+		ghes_clear_estatus(ghes);
+		return -ENOENT;
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
+		return 0;
+
+	__process_error(ghes);
+	ghes_clear_estatus(ghes);
+
+	return 0;
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
+	if (IS_ENABLED(CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG) && !ret)
+		irq_work_queue(&ghes_proc_irq_work);
+
+	return ret;
+}
+
 static unsigned long ghes_esource_prealloc_size(
 	const struct acpi_hest_generic *generic)
 {
@@ -762,11 +807,24 @@ static unsigned long ghes_esource_prealloc_size(
 	return prealloc_size;
 }
 
-static void ghes_estatus_pool_shrink(unsigned long len)
+/* After removing a queue user, we can shrink the pool */
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
@@ -965,48 +1023,22 @@ static LIST_HEAD(ghes_nmi);
 
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
+	if (!ghes_estatus_queue_notified(&ghes_nmi))
+		ret = NMI_HANDLED;
 
-		if (!(ghes->flags & GHES_TO_CLEAR))
-			continue;
-
-		__process_error(ghes);
-		ghes_clear_estatus(ghes);
-	}
-
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
@@ -1016,8 +1048,6 @@ static void ghes_nmi_add(struct ghes *ghes)
 
 static void ghes_nmi_remove(struct ghes *ghes)
 {
-	unsigned long len;
-
 	mutex_lock(&ghes_list_mutex);
 	list_del_rcu(&ghes->list);
 	if (list_empty(&ghes_nmi))
@@ -1028,8 +1058,8 @@ static void ghes_nmi_remove(struct ghes *ghes)
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
2.19.0
