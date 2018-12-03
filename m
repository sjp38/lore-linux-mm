Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id E94C86B6A9D
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 13:08:03 -0500 (EST)
Received: by mail-oi1-f197.google.com with SMTP id h85so8764435oib.9
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 10:08:03 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id f36si6885153otf.163.2018.12.03.10.08.02
        for <linux-mm@kvack.org>;
        Mon, 03 Dec 2018 10:08:02 -0800 (PST)
From: James Morse <james.morse@arm.com>
Subject: [PATCH v7 24/25] firmware: arm_sdei: Add ACPI GHES registration helper
Date: Mon,  3 Dec 2018 18:06:12 +0000
Message-Id: <20181203180613.228133-25-james.morse@arm.com>
In-Reply-To: <20181203180613.228133-1-james.morse@arm.com>
References: <20181203180613.228133-1-james.morse@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-acpi@vger.kernel.org
Cc: kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Fan Wu <wufan@codeaurora.org>, James Morse <james.morse@arm.com>

APEI's Generic Hardware Error Source structures do not describe
whether the SDEI event is shared or private, as this information is
discoverable via the API.

GHES needs to know whether an event is normal or critical to avoid
sharing locks or fixmap entries, but GHES shouldn't have to know about
the SDEI API.

Add a helper to register the GHES using the appropriate normal or
critical callback.

Signed-off-by: James Morse <james.morse@arm.com>
---
Changes since v4:
 * Moved normal/critical callbacks into the helper, as APEI needs to know.
 * Tinkered with the commit message.
 * Dropped Punit's Reviewed-by.

Changes since v3:
 * Removed acpi_disabled() checks that aren't necessary after v2s #ifdef
   change.

Changes since v2:
 * Added header file, thanks kbuild-robot!
 * changed ifdef to the GHES version to match the fixmap definition

Changes since v1:
 * ghes->fixmap_idx variable rename
---
 arch/arm64/include/asm/fixmap.h |  4 ++
 drivers/firmware/arm_sdei.c     | 70 +++++++++++++++++++++++++++++++++
 include/linux/arm_sdei.h        |  6 +++
 3 files changed, 80 insertions(+)

diff --git a/arch/arm64/include/asm/fixmap.h b/arch/arm64/include/asm/fixmap.h
index 966dd4bb23f2..f987b8a8f325 100644
--- a/arch/arm64/include/asm/fixmap.h
+++ b/arch/arm64/include/asm/fixmap.h
@@ -56,6 +56,10 @@ enum fixed_addresses {
 	/* Used for GHES mapping from assorted contexts */
 	FIX_APEI_GHES_IRQ,
 	FIX_APEI_GHES_SEA,
+#ifdef CONFIG_ARM_SDE_INTERFACE
+	FIX_APEI_GHES_SDEI_NORMAL,
+	FIX_APEI_GHES_SDEI_CRITICAL,
+#endif
 #endif /* CONFIG_ACPI_APEI_GHES */
 
 #ifdef CONFIG_UNMAP_KERNEL_AT_EL0
diff --git a/drivers/firmware/arm_sdei.c b/drivers/firmware/arm_sdei.c
index 1ea71640fdc2..4bcbe3a3f597 100644
--- a/drivers/firmware/arm_sdei.c
+++ b/drivers/firmware/arm_sdei.c
@@ -2,6 +2,7 @@
 // Copyright (C) 2017 Arm Ltd.
 #define pr_fmt(fmt) "sdei: " fmt
 
+#include <acpi/ghes.h>
 #include <linux/acpi.h>
 #include <linux/arm_sdei.h>
 #include <linux/arm-smccc.h>
@@ -32,6 +33,8 @@
 #include <linux/spinlock.h>
 #include <linux/uaccess.h>
 
+#include <asm/fixmap.h>
+
 /*
  * The call to use to reach the firmware.
  */
@@ -887,6 +890,73 @@ static void sdei_smccc_hvc(unsigned long function_id,
 	arm_smccc_hvc(function_id, arg0, arg1, arg2, arg3, arg4, 0, 0, res);
 }
 
+int sdei_register_ghes(struct ghes *ghes, sdei_event_callback *normal_cb,
+		       sdei_event_callback *critical_cb)
+{
+	int err;
+	u64 result;
+	u32 event_num;
+	sdei_event_callback *cb;
+
+	if (!IS_ENABLED(CONFIG_ACPI_APEI_GHES))
+		return -EOPNOTSUPP;
+
+	event_num = ghes->generic->notify.vector;
+	if (event_num == 0) {
+		/*
+		 * Event 0 is reserved by the specification for
+		 * SDEI_EVENT_SIGNAL.
+		 */
+		return -EINVAL;
+	}
+
+	err = sdei_api_event_get_info(event_num, SDEI_EVENT_INFO_EV_PRIORITY,
+				      &result);
+	if (err)
+		return err;
+
+	if (result == SDEI_EVENT_PRIORITY_CRITICAL)
+		cb = critical_cb;
+	else
+		cb = normal_cb;
+
+	err = sdei_event_register(event_num, cb, ghes);
+	if (!err)
+		err = sdei_event_enable(event_num);
+
+	return err;
+}
+
+int sdei_unregister_ghes(struct ghes *ghes)
+{
+	int i;
+	int err;
+	u32 event_num = ghes->generic->notify.vector;
+
+	might_sleep();
+
+	if (!IS_ENABLED(CONFIG_ACPI_APEI_GHES))
+		return -EOPNOTSUPP;
+
+	/*
+	 * The event may be running on another CPU. Disable it
+	 * to stop new events, then try to unregister a few times.
+	 */
+	err = sdei_event_disable(event_num);
+	if (err)
+		return err;
+
+	for (i = 0; i < 3; i++) {
+		err = sdei_event_unregister(event_num);
+		if (err != -EINPROGRESS)
+			break;
+
+		schedule();
+	}
+
+	return err;
+}
+
 static int sdei_get_conduit(struct platform_device *pdev)
 {
 	const char *method;
diff --git a/include/linux/arm_sdei.h b/include/linux/arm_sdei.h
index 942afbd544b7..393899192906 100644
--- a/include/linux/arm_sdei.h
+++ b/include/linux/arm_sdei.h
@@ -11,6 +11,7 @@ enum sdei_conduit_types {
 	CONDUIT_HVC,
 };
 
+#include <acpi/ghes.h>
 #include <asm/sdei.h>
 
 /* Arch code should override this to set the entry point from firmware... */
@@ -39,6 +40,11 @@ int sdei_event_unregister(u32 event_num);
 int sdei_event_enable(u32 event_num);
 int sdei_event_disable(u32 event_num);
 
+/* GHES register/unregister helpers */
+int sdei_register_ghes(struct ghes *ghes, sdei_event_callback *normal_cb,
+		       sdei_event_callback *critical_cb);
+int sdei_unregister_ghes(struct ghes *ghes);
+
 #ifdef CONFIG_ARM_SDE_INTERFACE
 /* For use by arch code when CPU hotplug notifiers are not appropriate. */
 int sdei_mask_local_cpu(void);
-- 
2.19.2
