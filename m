Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6D2D06B6A9F
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 13:08:07 -0500 (EST)
Received: by mail-oi1-f200.google.com with SMTP id w128so8715539oie.20
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 10:08:07 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id j5si5986037oiw.131.2018.12.03.10.08.06
        for <linux-mm@kvack.org>;
        Mon, 03 Dec 2018 10:08:06 -0800 (PST)
From: James Morse <james.morse@arm.com>
Subject: [PATCH v7 25/25] ACPI / APEI: Add support for the SDEI GHES Notification type
Date: Mon,  3 Dec 2018 18:06:13 +0000
Message-Id: <20181203180613.228133-26-james.morse@arm.com>
In-Reply-To: <20181203180613.228133-1-james.morse@arm.com>
References: <20181203180613.228133-1-james.morse@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-acpi@vger.kernel.org
Cc: kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Fan Wu <wufan@codeaurora.org>, James Morse <james.morse@arm.com>

If the GHES notification type is SDEI, register the provided event
using the SDEI-GHES helper.

SDEI may be one of two types of event, normal and critical. Critical
events can interrupt normal events, so these must have separate
fixmap slots and locks in case both event types are in use.

Signed-off-by: James Morse <james.morse@arm.com>

--
Changes since v6:
 * Tinkering due to the absence of #ifdef
 * Added SDEI to the new ghes_is_synchronous() helper.
---
 drivers/acpi/apei/ghes.c | 82 +++++++++++++++++++++++++++++++++++++++-
 include/linux/arm_sdei.h |  3 ++
 2 files changed, 84 insertions(+), 1 deletion(-)

diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
index 3e7da9243153..6325f1d6d9df 100644
--- a/drivers/acpi/apei/ghes.c
+++ b/drivers/acpi/apei/ghes.c
@@ -25,6 +25,7 @@
  * GNU General Public License for more details.
  */
 
+#include <linux/arm_sdei.h>
 #include <linux/kernel.h>
 #include <linux/moduleparam.h>
 #include <linux/init.h>
@@ -93,6 +94,10 @@
 #ifndef CONFIG_ACPI_APEI_SEA
 #define FIX_APEI_GHES_SEA	-1
 #endif
+#ifndef CONFIG_ARM_SDE_INTERFACE
+#define FIX_APEI_GHES_SDEI_NORMAL	-1
+#define FIX_APEI_GHES_SDEI_CRITICAL	-1
+#endif
 
 static inline bool is_hest_type_generic_v2(struct ghes *ghes)
 {
@@ -128,6 +133,8 @@ static DEFINE_MUTEX(ghes_list_mutex);
  * simultaneously.
  */
 static DEFINE_SPINLOCK(ghes_notify_lock_irq);
+static DEFINE_RAW_SPINLOCK(ghes_notify_lock_sdei_normal);
+static DEFINE_RAW_SPINLOCK(ghes_notify_lock_sdei_critical);
 
 static struct gen_pool *ghes_estatus_pool;
 static unsigned long ghes_estatus_pool_size_request;
@@ -141,7 +148,8 @@ static bool ghes_is_synchronous(struct ghes *ghes)
 {
 	switch (ghes->generic->notify.type) {
 	case ACPI_HEST_NOTIFY_NMI:	/* fall through */
-	case ACPI_HEST_NOTIFY_SEA:
+	case ACPI_HEST_NOTIFY_SEA:	/* fall through */
+	case ACPI_HEST_NOTIFY_SOFTWARE_DELEGATED:
 		/*
 		 * These notifications could be repeated if the interrupted
 		 * instruction is run again. e.g. a read of bad-memory causing
@@ -1100,6 +1108,60 @@ static void ghes_nmi_init_cxt(void)
 	init_irq_work(&ghes_proc_irq_work, ghes_proc_in_irq);
 }
 
+static int __ghes_sdei_callback(struct ghes *ghes, int fixmap_idx)
+{
+	if (!_in_nmi_notify_one(ghes, fixmap_idx)) {
+		irq_work_queue(&ghes_proc_irq_work);
+
+		return 0;
+	}
+
+	return -ENOENT;
+}
+
+static int ghes_sdei_normal_callback(u32 event_num, struct pt_regs *regs,
+				      void *arg)
+{
+	int err;
+	struct ghes *ghes = arg;
+
+	raw_spin_lock(&ghes_notify_lock_sdei_normal);
+	err = __ghes_sdei_callback(ghes, FIX_APEI_GHES_SDEI_NORMAL);
+	raw_spin_unlock(&ghes_notify_lock_sdei_normal);
+
+	return err;
+}
+
+static int ghes_sdei_critical_callback(u32 event_num, struct pt_regs *regs,
+				       void *arg)
+{
+	int err;
+	struct ghes *ghes = arg;
+
+	raw_spin_lock(&ghes_notify_lock_sdei_critical);
+	err = __ghes_sdei_callback(ghes, FIX_APEI_GHES_SDEI_CRITICAL);
+	raw_spin_unlock(&ghes_notify_lock_sdei_critical);
+
+	return err;
+}
+
+static int apei_sdei_register_ghes(struct ghes *ghes)
+{
+	if (!IS_ENABLED(CONFIG_ARM_SDE_INTERFACE))
+		return -EOPNOTSUPP;
+
+	return sdei_register_ghes(ghes, ghes_sdei_normal_callback,
+				 ghes_sdei_critical_callback);
+}
+
+static int apei_sdei_unregister_ghes(struct ghes *ghes)
+{
+	if (!IS_ENABLED(CONFIG_ARM_SDE_INTERFACE))
+		return -EOPNOTSUPP;
+
+	return sdei_unregister_ghes(ghes);
+}
+
 static int ghes_probe(struct platform_device *ghes_dev)
 {
 	struct acpi_hest_generic *generic;
@@ -1135,6 +1197,13 @@ static int ghes_probe(struct platform_device *ghes_dev)
 			goto err;
 		}
 		break;
+	case ACPI_HEST_NOTIFY_SOFTWARE_DELEGATED:
+		if (!IS_ENABLED(CONFIG_ARM_SDE_INTERFACE)) {
+			pr_warn(GHES_PFX "Generic hardware error source: %d notified via SDE Interface is not supported!\n",
+				generic->header.source_id);
+			goto err;
+		}
+		break;
 	case ACPI_HEST_NOTIFY_LOCAL:
 		pr_warning(GHES_PFX "Generic hardware error source: %d notified via local interrupt is not supported!\n",
 			   generic->header.source_id);
@@ -1198,6 +1267,11 @@ static int ghes_probe(struct platform_device *ghes_dev)
 	case ACPI_HEST_NOTIFY_NMI:
 		ghes_nmi_add(ghes);
 		break;
+	case ACPI_HEST_NOTIFY_SOFTWARE_DELEGATED:
+		rc = apei_sdei_register_ghes(ghes);
+		if (rc)
+			goto err;
+		break;
 	default:
 		BUG();
 	}
@@ -1223,6 +1297,7 @@ static int ghes_probe(struct platform_device *ghes_dev)
 
 static int ghes_remove(struct platform_device *ghes_dev)
 {
+	int rc;
 	struct ghes *ghes;
 	struct acpi_hest_generic *generic;
 
@@ -1255,6 +1330,11 @@ static int ghes_remove(struct platform_device *ghes_dev)
 	case ACPI_HEST_NOTIFY_NMI:
 		ghes_nmi_remove(ghes);
 		break;
+	case ACPI_HEST_NOTIFY_SOFTWARE_DELEGATED:
+		rc = apei_sdei_unregister_ghes(ghes);
+		if (rc)
+			return rc;
+		break;
 	default:
 		BUG();
 		break;
diff --git a/include/linux/arm_sdei.h b/include/linux/arm_sdei.h
index 393899192906..3305ea7f9dc7 100644
--- a/include/linux/arm_sdei.h
+++ b/include/linux/arm_sdei.h
@@ -12,7 +12,10 @@ enum sdei_conduit_types {
 };
 
 #include <acpi/ghes.h>
+
+#ifdef CONFIG_ARM_SDE_INTERFACE
 #include <asm/sdei.h>
+#endif
 
 /* Arch code should override this to set the entry point from firmware... */
 #ifndef sdei_arch_get_entry_point
-- 
2.19.2
