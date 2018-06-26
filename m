Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1D7776B028D
	for <linux-mm@kvack.org>; Tue, 26 Jun 2018 13:03:07 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id s22-v6so2395889otk.7
        for <linux-mm@kvack.org>; Tue, 26 Jun 2018 10:03:07 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id t204-v6si682920oit.379.2018.06.26.10.03.05
        for <linux-mm@kvack.org>;
        Tue, 26 Jun 2018 10:03:05 -0700 (PDT)
From: James Morse <james.morse@arm.com>
Subject: [PATCH v5 18/20] ACPI / APEI: Add support for the SDEI GHES Notification type
Date: Tue, 26 Jun 2018 18:01:14 +0100
Message-Id: <20180626170116.25825-19-james.morse@arm.com>
In-Reply-To: <20180626170116.25825-1-james.morse@arm.com>
References: <20180626170116.25825-1-james.morse@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-acpi@vger.kernel.org
Cc: kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Punit Agrawal <punit.agrawal@arm.com>, jonathan.zhang@cavium.com, James Morse <james.morse@arm.com>

If the GHES notification type is SDEI, register the provided event
using the SDEI-GHES helper.

SDEI may be one of two types of event, normal and critical. Critical
events can interrupt normal events, so these must have separate
fixmap slots and locks in case both event types are in use.

Signed-off-by: James Morse <james.morse@arm.com>
---
Changes since v4:
 * We now have two callbacks and separate locks and fixmap entries for
   normal/critical calls.
 * Use the new Kconfig selector for ESTATUS_QUEUE

 arch/arm64/include/asm/fixmap.h |  2 +-
 drivers/acpi/apei/Kconfig       |  5 ++
 drivers/acpi/apei/ghes.c        | 92 ++++++++++++++++++++++++++++++++-
 drivers/firmware/Kconfig        |  1 +
 drivers/firmware/arm_sdei.c     |  4 +-
 include/linux/arm_sdei.h        |  3 ++
 6 files changed, 102 insertions(+), 5 deletions(-)

diff --git a/arch/arm64/include/asm/fixmap.h b/arch/arm64/include/asm/fixmap.h
index e2b423a5feaf..e875b97032ce 100644
--- a/arch/arm64/include/asm/fixmap.h
+++ b/arch/arm64/include/asm/fixmap.h
@@ -58,7 +58,7 @@ enum fixed_addresses {
 #ifdef CONFIG_ACPI_APEI_SEA
 	FIX_APEI_GHES_SEA,
 #endif
-#ifdef CONFIG_ARM_SDE_INTERFACE
+#ifdef CONFIG_ACPI_APEI_SDEI
 	FIX_APEI_GHES_SDEI_NORMAL,
 	FIX_APEI_GHES_SDEI_CRITICAL,
 #endif
diff --git a/drivers/acpi/apei/Kconfig b/drivers/acpi/apei/Kconfig
index 2b191e09b647..a8d09065e6a9 100644
--- a/drivers/acpi/apei/Kconfig
+++ b/drivers/acpi/apei/Kconfig
@@ -61,6 +61,11 @@ config ACPI_APEI_SEA
 	  option allows the OS to look for such hardware error record, and
 	  take appropriate action.
 
+config ACPI_APEI_SDEI
+	bool
+	depends on ACPI_APEI_GHES && ARM_SDE_INTERFACE
+	select ACPI_APEI_GHES_ESTATUS_QUEUE
+
 config ACPI_APEI_MEMORY_FAILURE
 	bool "APEI memory error recovering support"
 	depends on ACPI_APEI && MEMORY_FAILURE
diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
index 15d472048aa8..b7b335450a6b 100644
--- a/drivers/acpi/apei/ghes.c
+++ b/drivers/acpi/apei/ghes.c
@@ -25,6 +25,7 @@
  * GNU General Public License for more details.
  */
 
+#include <linux/arm_sdei.h>
 #include <linux/kernel.h>
 #include <linux/moduleparam.h>
 #include <linux/init.h>
@@ -763,8 +764,8 @@ static int _in_nmi_notify_one(struct ghes *ghes, int fixmap_idx)
 	return rc;
 }
 
-static int ghes_estatus_queue_notified(struct list_head *rcu_list,
-				       int fixmap_idx)
+static int __maybe_unused
+ghes_estatus_queue_notified(struct list_head *rcu_list, int fixmap_idx)
 {
 	int ret = -ENOENT;
 	struct ghes *ghes;
@@ -1069,6 +1070,75 @@ static inline void ghes_nmi_add(struct ghes *ghes) { }
 static inline void ghes_nmi_remove(struct ghes *ghes) { }
 #endif /* CONFIG_HAVE_ACPI_APEI_NMI */
 
+#ifdef CONFIG_ACPI_APEI_SDEI
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
+static DEFINE_RAW_SPINLOCK(ghes_notify_lock_sdei_normal);
+static DEFINE_RAW_SPINLOCK(ghes_notify_lock_sdei_critical);
+
+static int ghes_sdei_normal_callback(u32 event_num, struct pt_regs *regs,
+				      void *arg)
+{
+	int err = -ENOENT;
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
+	int err = -ENOENT;
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
+	int err;
+
+	ghes_estatus_queue_grow_pool(ghes);
+
+	err = sdei_register_ghes(ghes, ghes_sdei_normal_callback,
+				 ghes_sdei_critical_callback);
+	if (err)
+		ghes_estatus_queue_shrink_pool(ghes);
+
+	return err;
+}
+
+static int apei_sdei_unregister_ghes(struct ghes *ghes)
+{
+	int err = sdei_unregister_ghes(ghes);
+
+	if (!err)
+		ghes_estatus_queue_shrink_pool(ghes);
+
+	return err;
+}
+#else
+static int apei_sdei_register_ghes(struct ghes *ghes) { return -EINVAL; }
+static int apei_sdei_unregister_ghes(struct ghes *ghes) { return -EINVAL; }
+#endif /* CONFIG_ACPI_APEI_SDEI */
+
 static int ghes_probe(struct platform_device *ghes_dev)
 {
 	struct acpi_hest_generic *generic;
@@ -1103,6 +1173,13 @@ static int ghes_probe(struct platform_device *ghes_dev)
 			goto err;
 		}
 		break;
+	case ACPI_HEST_NOTIFY_SOFTWARE_DELEGATED:
+		if (!IS_ENABLED(CONFIG_ACPI_APEI_SDEI)) {
+			pr_warn(GHES_PFX "Generic hardware error source: %d notified via SDE Interface is not supported!\n",
+				generic->header.source_id);
+			goto err;
+		}
+		break;
 	case ACPI_HEST_NOTIFY_LOCAL:
 		pr_warning(GHES_PFX "Generic hardware error source: %d notified via local interrupt is not supported!\n",
 			   generic->header.source_id);
@@ -1166,6 +1243,11 @@ static int ghes_probe(struct platform_device *ghes_dev)
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
@@ -1189,6 +1271,7 @@ static int ghes_probe(struct platform_device *ghes_dev)
 
 static int ghes_remove(struct platform_device *ghes_dev)
 {
+	int rc;
 	struct ghes *ghes;
 	struct acpi_hest_generic *generic;
 
@@ -1221,6 +1304,11 @@ static int ghes_remove(struct platform_device *ghes_dev)
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
diff --git a/drivers/firmware/Kconfig b/drivers/firmware/Kconfig
index 6e83880046d7..69c52c0591da 100644
--- a/drivers/firmware/Kconfig
+++ b/drivers/firmware/Kconfig
@@ -85,6 +85,7 @@ config ARM_SCPI_POWER_DOMAIN
 config ARM_SDE_INTERFACE
 	bool "ARM Software Delegated Exception Interface (SDEI)"
 	depends on ARM64
+	select ACPI_APEI_SDEI if ACPI_APEI_GHES
 	help
 	  The Software Delegated Exception Interface (SDEI) is an ARM
 	  standard for registering callbacks from the platform firmware
diff --git a/drivers/firmware/arm_sdei.c b/drivers/firmware/arm_sdei.c
index c1b6591f2183..97fd8d22bf15 100644
--- a/drivers/firmware/arm_sdei.c
+++ b/drivers/firmware/arm_sdei.c
@@ -890,7 +890,7 @@ static void sdei_smccc_hvc(unsigned long function_id,
 	arm_smccc_hvc(function_id, arg0, arg1, arg2, arg3, arg4, 0, 0, res);
 }
 
-#ifdef CONFIG_ACPI_APEI_GHES
+#ifdef CONFIG_ACPI_APEI_SDEI
 int sdei_register_ghes(struct ghes *ghes, sdei_event_callback *normal_cb,
 		       sdei_event_callback *critical_cb)
 {
@@ -951,7 +951,7 @@ int sdei_unregister_ghes(struct ghes *ghes)
 
 	return err;
 }
-#endif /* CONFIG_ACPI_APEI_GHES */
+#endif /* CONFIG_ACPI_APEI_SDEI */
 
 static int sdei_get_conduit(struct platform_device *pdev)
 {
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
2.17.1
