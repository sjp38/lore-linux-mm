Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id AE1EF6B6A7C
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 13:07:09 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id 62so5950180otr.14
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 10:07:09 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id s205si6182708oig.116.2018.12.03.10.07.07
        for <linux-mm@kvack.org>;
        Mon, 03 Dec 2018 10:07:08 -0800 (PST)
From: James Morse <james.morse@arm.com>
Subject: [PATCH v7 09/25] ACPI / APEI: Generalise the estatus queue's notify code
Date: Mon,  3 Dec 2018 18:05:57 +0000
Message-Id: <20181203180613.228133-10-james.morse@arm.com>
In-Reply-To: <20181203180613.228133-1-james.morse@arm.com>
References: <20181203180613.228133-1-james.morse@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-acpi@vger.kernel.org
Cc: kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Fan Wu <wufan@codeaurora.org>, James Morse <james.morse@arm.com>

Refactor the estatus queue's pool notification routine from
NOTIFY_NMI's handlers. This will allow another notification
method to use the estatus queue without duplicating this code.

This patch adds rcu_read_lock()/rcu_read_unlock() around the list
list_for_each_entry_rcu() walker. These aren't strictly necessary as
the whole nmi_enter/nmi_exit() window is a spooky RCU read-side
critical section.

_in_nmi_notify_one() is separate from the rcu-list walker for a later
caller that doesn't need to walk a list.

Signed-off-by: James Morse <james.morse@arm.com>
Reviewed-by: Punit Agrawal <punit.agrawal@arm.com>
Tested-by: Tyler Baicar <tbaicar@codeaurora.org>

---
Changes since v6:
 * Removed pool grow/remove code as this is no longer necessary.

Changes since v3:
 * Removed duplicate or redundant paragraphs in commit message.
 * Fixed the style of a zero check.
Changes since v1:
   * Tidied up _in_nmi_notify_one().
---
 drivers/acpi/apei/ghes.c | 63 ++++++++++++++++++++++++++--------------
 1 file changed, 41 insertions(+), 22 deletions(-)

diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
index d06456e60318..366dbdd41ef3 100644
--- a/drivers/acpi/apei/ghes.c
+++ b/drivers/acpi/apei/ghes.c
@@ -907,37 +907,56 @@ static void __process_error(struct ghes *ghes)
 #endif
 }
 
-static int ghes_notify_nmi(unsigned int cmd, struct pt_regs *regs)
+static int _in_nmi_notify_one(struct ghes *ghes)
 {
 	u64 buf_paddr;
-	struct ghes *ghes;
-	int sev, ret = NMI_DONE;
+	int sev;
 
-	if (!atomic_add_unless(&ghes_in_nmi, 1, 1))
-		return ret;
+	if (ghes_read_estatus(ghes, &buf_paddr)) {
+		ghes_clear_estatus(ghes, buf_paddr);
+		return -ENOENT;
+	}
 
-	list_for_each_entry_rcu(ghes, &ghes_nmi, list) {
-		if (ghes_read_estatus(ghes, &buf_paddr)) {
-			ghes_clear_estatus(ghes, buf_paddr);
-			continue;
-		} else {
-			ret = NMI_HANDLED;
-		}
+	sev = ghes_severity(ghes->estatus->error_severity);
+	if (sev >= GHES_SEV_PANIC) {
+		ghes_print_queued_estatus();
+		__ghes_panic(ghes);
+	}
 
-		sev = ghes_severity(ghes->estatus->error_severity);
-		if (sev >= GHES_SEV_PANIC) {
-			ghes_print_queued_estatus();
-			__ghes_panic(ghes);
-		}
+	__process_error(ghes);
+	ghes_clear_estatus(ghes, buf_paddr);
 
-		__process_error(ghes);
-		ghes_clear_estatus(ghes, buf_paddr);
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
 	}
+	rcu_read_unlock();
 
-#ifdef CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG
-	if (ret == NMI_HANDLED)
+	if (IS_ENABLED(CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG) && !ret)
 		irq_work_queue(&ghes_proc_irq_work);
-#endif
+
+	return ret;
+}
+
+static int ghes_notify_nmi(unsigned int cmd, struct pt_regs *regs)
+{
+	int ret = NMI_DONE;
+
+	if (!atomic_add_unless(&ghes_in_nmi, 1, 1))
+		return ret;
+
+	if (!ghes_estatus_queue_notified(&ghes_nmi))
+		ret = NMI_HANDLED;
+
 	atomic_dec(&ghes_in_nmi);
 	return ret;
 }
-- 
2.19.2
