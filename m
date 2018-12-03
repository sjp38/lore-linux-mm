Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 556546B6A7F
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 13:07:21 -0500 (EST)
Received: by mail-ot1-f72.google.com with SMTP id c26so5971829otl.19
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 10:07:21 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 4si6455839otq.38.2018.12.03.10.07.19
        for <linux-mm@kvack.org>;
        Mon, 03 Dec 2018 10:07:20 -0800 (PST)
From: James Morse <james.morse@arm.com>
Subject: [PATCH v7 12/25] ACPI / APEI: Switch NOTIFY_SEA to use the estatus queue
Date: Mon,  3 Dec 2018 18:06:00 +0000
Message-Id: <20181203180613.228133-13-james.morse@arm.com>
In-Reply-To: <20181203180613.228133-1-james.morse@arm.com>
References: <20181203180613.228133-1-james.morse@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-acpi@vger.kernel.org
Cc: kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Fan Wu <wufan@codeaurora.org>, James Morse <james.morse@arm.com>

Now that the estatus queue can be used by more than one notification
method, we can move notifications that have NMI-like behaviour over.

Switch NOTIFY_SEA over to use the estatus queue. This makes it behave
in the same way as x86's NOTIFY_NMI.

Remove Kconfig's ability to turn ACPI_APEI_SEA off if ACPI_APEI_GHES
is selected. This roughly matches the x86 NOTIFY_NMI behaviour, and means
each architecture has at least one user of the estatus-queue, meaning it
doesn't need guarding with ifdef.

Signed-off-by: James Morse <james.morse@arm.com>
---
Changes since v6:
 * Lost all the pool grow/shrink stuff,
 * Changed Kconfig so this can't be turned off to avoid kconfig complexity:
 * Dropped Tyler's tested-by.
 * For now we need #ifdef around the SEA code as the arch code assumes its there.
 * Removed Punit's reviewed-by due to the swirling #ifdeffery
---
 drivers/acpi/apei/Kconfig | 12 +-----------
 drivers/acpi/apei/ghes.c  | 22 +++++-----------------
 2 files changed, 6 insertions(+), 28 deletions(-)

diff --git a/drivers/acpi/apei/Kconfig b/drivers/acpi/apei/Kconfig
index 52ae5438edeb..6b18f8bc7be3 100644
--- a/drivers/acpi/apei/Kconfig
+++ b/drivers/acpi/apei/Kconfig
@@ -41,19 +41,9 @@ config ACPI_APEI_PCIEAER
 	  Turn on this option to enable the corresponding support.
 
 config ACPI_APEI_SEA
-	bool "APEI Synchronous External Abort logging/recovering support"
+	bool
 	depends on ARM64 && ACPI_APEI_GHES
 	default y
-	help
-	  This option should be enabled if the system supports
-	  firmware first handling of SEA (Synchronous External Abort).
-	  SEA happens with certain faults of data abort or instruction
-	  abort synchronous exceptions on ARMv8 systems. If a system
-	  supports firmware first handling of SEA, the platform analyzes
-	  and handles hardware error notifications from SEA, and it may then
-	  form a HW error record for the OS to parse and handle. This
-	  option allows the OS to look for such hardware error record, and
-	  take appropriate action.
 
 config ACPI_APEI_MEMORY_FAILURE
 	bool "APEI memory error recovering support"
diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
index 00fe4785e469..4b33fa562e32 100644
--- a/drivers/acpi/apei/ghes.c
+++ b/drivers/acpi/apei/ghes.c
@@ -765,7 +765,6 @@ static struct notifier_block ghes_notifier_hed = {
 	.notifier_call = ghes_notify_hed,
 };
 
-#ifdef CONFIG_HAVE_ACPI_APEI_NMI
 /*
  * Handlers for CPER records may not be NMI safe. For example,
  * memory_failure_queue() takes spinlocks and calls schedule_work_on().
@@ -905,7 +904,6 @@ static int ghes_estatus_queue_notified(struct list_head *rcu_list)
 
 	return ret;
 }
-#endif /* CONFIG_HAVE_ACPI_APEI_NMI */
 
 #ifdef CONFIG_ACPI_APEI_SEA
 static LIST_HEAD(ghes_sea);
@@ -916,16 +914,7 @@ static LIST_HEAD(ghes_sea);
  */
 int ghes_notify_sea(void)
 {
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
+	return ghes_estatus_queue_notified(&ghes_sea);
 }
 
 static void ghes_sea_add(struct ghes *ghes)
@@ -992,16 +981,15 @@ static void ghes_nmi_remove(struct ghes *ghes)
 	 */
 	synchronize_rcu();
 }
+#else /* CONFIG_HAVE_ACPI_APEI_NMI */
+static inline void ghes_nmi_add(struct ghes *ghes) { }
+static inline void ghes_nmi_remove(struct ghes *ghes) { }
+#endif /* CONFIG_HAVE_ACPI_APEI_NMI */
 
 static void ghes_nmi_init_cxt(void)
 {
 	init_irq_work(&ghes_proc_irq_work, ghes_proc_in_irq);
 }
-#else /* CONFIG_HAVE_ACPI_APEI_NMI */
-static inline void ghes_nmi_add(struct ghes *ghes) { }
-static inline void ghes_nmi_remove(struct ghes *ghes) { }
-static inline void ghes_nmi_init_cxt(void) { }
-#endif /* CONFIG_HAVE_ACPI_APEI_NMI */
 
 static int ghes_probe(struct platform_device *ghes_dev)
 {
-- 
2.19.2
