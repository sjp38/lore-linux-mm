Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id D4FDF6B0022
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 13:59:22 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id w23so335036otj.19
        for <linux-mm@kvack.org>; Thu, 15 Feb 2018 10:59:22 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 2si5630628otq.23.2018.02.15.10.59.21
        for <linux-mm@kvack.org>;
        Thu, 15 Feb 2018 10:59:21 -0800 (PST)
From: James Morse <james.morse@arm.com>
Subject: [PATCH 09/11] ACPI / APEI: Add support for the SDEI GHES Notification type
Date: Thu, 15 Feb 2018 18:56:04 +0000
Message-Id: <20180215185606.26736-10-james.morse@arm.com>
In-Reply-To: <20180215185606.26736-1-james.morse@arm.com>
References: <20180215185606.26736-1-james.morse@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-acpi@vger.kernel.org
Cc: kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, Christoffer Dall <christoffer.dall@linaro.org>, Marc Zyngier <marc.zyngier@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Punit Agrawal <punit.agrawal@arm.com>, James Morse <james.morse@arm.com>

If the GHES notification type is SDEI, register the provided event
number and point the callback at ghes_sdei_callback().

Signed-off-by: James Morse <james.morse@arm.com>
---
 drivers/acpi/apei/ghes.c | 66 ++++++++++++++++++++++++++++++++++++++++++++++--
 include/linux/arm_sdei.h |  3 +++
 2 files changed, 67 insertions(+), 2 deletions(-)

diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
index 280c0a58c700..5eaf0a772be7 100644
--- a/drivers/acpi/apei/ghes.c
+++ b/drivers/acpi/apei/ghes.c
@@ -25,6 +25,7 @@
  * GNU General Public License for more details.
  */
 
+#include <linux/arm_sdei.h>
 #include <linux/kernel.h>
 #include <linux/moduleparam.h>
 #include <linux/init.h>
@@ -59,7 +60,7 @@
 
 #define GHES_PFX	"GHES: "
 
-#if defined(CONFIG_HAVE_ACPI_APEI_NMI) || defined(CONFIG_ACPI_APEI_SEA)
+#if defined(CONFIG_HAVE_ACPI_APEI_NMI) || defined(CONFIG_ACPI_APEI_SEA) || defined(CONFIG_ARM_SDE_INTERFACE)
 #define WANT_NMI_ESTATUS_QUEUE	1
 #endif
 
@@ -753,7 +754,7 @@ static int _in_nmi_notify_one(struct ghes *ghes)
 	return ret;
 }
 
-static int ghes_estatus_queue_notified(struct list_head *rcu_list)
+static int __maybe_unused ghes_estatus_queue_notified(struct list_head *rcu_list)
 {
 	int ret = -ENOENT;
 	struct ghes *ghes;
@@ -1047,6 +1048,49 @@ static inline void ghes_nmi_add(struct ghes *ghes) { }
 static inline void ghes_nmi_remove(struct ghes *ghes) { }
 #endif /* CONFIG_HAVE_ACPI_APEI_NMI */
 
+static int ghes_sdei_callback(u32 event_num, struct pt_regs *regs, void *arg)
+{
+	struct ghes *ghes = arg;
+
+	if (!_in_nmi_notify_one(ghes)) {
+		if (IS_ENABLED(CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG))
+			irq_work_queue(&ghes_proc_irq_work);
+
+		return 0;
+	}
+
+	return -ENOENT;
+}
+
+static int apei_sdei_register_ghes(struct ghes *ghes)
+{
+	int err = -EINVAL;
+
+	if (IS_ENABLED(CONFIG_ARM_SDE_INTERFACE)) {
+		ghes_estatus_queue_grow_pool(ghes);
+
+		err = sdei_register_ghes(ghes, ghes_sdei_callback);
+		if (err)
+			ghes_estatus_queue_shrink_pool(ghes);
+	}
+
+	return err;
+}
+
+static int apei_sdei_unregister_ghes(struct ghes *ghes)
+{
+	int err = -EINVAL;
+
+	if (IS_ENABLED(CONFIG_ARM_SDE_INTERFACE)) {
+		err = sdei_unregister_ghes(ghes);
+
+		if (!err)
+			ghes_estatus_queue_shrink_pool(ghes);
+	}
+
+	return err;
+}
+
 static int ghes_probe(struct platform_device *ghes_dev)
 {
 	struct acpi_hest_generic *generic;
@@ -1081,6 +1125,13 @@ static int ghes_probe(struct platform_device *ghes_dev)
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
@@ -1154,6 +1205,11 @@ static int ghes_probe(struct platform_device *ghes_dev)
 	case ACPI_HEST_NOTIFY_NMI:
 		ghes_nmi_add(ghes);
 		break;
+	case ACPI_HEST_NOTIFY_SOFTWARE_DELEGATED:
+		rc = apei_sdei_register_ghes(ghes);
+		if (rc)
+			goto err_edac_unreg;
+		break;
 	default:
 		BUG();
 	}
@@ -1175,6 +1231,7 @@ err:
 
 static int ghes_remove(struct platform_device *ghes_dev)
 {
+	int rc;
 	struct ghes *ghes;
 	struct acpi_hest_generic *generic;
 
@@ -1207,6 +1264,11 @@ static int ghes_remove(struct platform_device *ghes_dev)
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
index 5fdf799be026..f49063ca206d 100644
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
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
