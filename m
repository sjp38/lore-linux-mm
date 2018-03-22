Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 762156B0268
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 14:18:21 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id 129-v6so4941377oid.12
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 11:18:21 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id r82si32021oia.276.2018.03.22.11.18.20
        for <linux-mm@kvack.org>;
        Thu, 22 Mar 2018 11:18:20 -0700 (PDT)
From: James Morse <james.morse@arm.com>
Subject: [PATCH v2 11/11] arm64: acpi: Make apei_claim_sea() synchronise with APEI's irq work
Date: Thu, 22 Mar 2018 18:14:45 +0000
Message-Id: <20180322181445.23298-12-james.morse@arm.com>
In-Reply-To: <20180322181445.23298-1-james.morse@arm.com>
References: <20180322181445.23298-1-james.morse@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-acpi@vger.kernel.org
Cc: kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <cdall@kernel.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Punit Agrawal <punit.agrawal@arm.com>, James Morse <james.morse@arm.com>

APEI is unable to do all of its error handling work in nmi-context, so
it defers non-fatal work onto the irq_work queue. arch_irq_work_raise()
sends an IPI to the calling cpu, but we can't guarantee this will be
taken before we return.

Unless we interrupted a context with irqs-masked, we can call
irq_work_run() to do the work now. Otherwise return -EINPROGRESS to
indicate ghes_notify_sea() found some work to do, but it hasn't
finished yet.

With this we can take apei_claim_sea() returning '0' to mean this
external-abort was also notification of a firmware-first RAS error,
and that APEI has processed the CPER records.

Signed-off-by: James Morse <james.morse@arm.com>
Reviewed-by: Punit Agrawal <punit.agrawal@arm.com>
CC: Xie XiuQi <xiexiuqi@huawei.com>
CC: gengdongjiu <gengdongjiu@huawei.com>
---
 arch/arm64/kernel/acpi.c | 19 +++++++++++++++++++
 arch/arm64/mm/fault.c    |  9 ++++-----
 2 files changed, 23 insertions(+), 5 deletions(-)

diff --git a/arch/arm64/kernel/acpi.c b/arch/arm64/kernel/acpi.c
index 6a4823a3eb5e..a51a7abd98e0 100644
--- a/arch/arm64/kernel/acpi.c
+++ b/arch/arm64/kernel/acpi.c
@@ -22,6 +22,7 @@
 #include <linux/init.h>
 #include <linux/irq.h>
 #include <linux/irqdomain.h>
+#include <linux/irq_work.h>
 #include <linux/memblock.h>
 #include <linux/of_fdt.h>
 #include <linux/smp.h>
@@ -275,10 +276,14 @@ int apei_claim_sea(struct pt_regs *regs)
 {
 	int err = -ENOENT;
 	unsigned long current_flags = arch_local_save_flags();
+	unsigned long interrupted_flags = current_flags;
 
 	if (!IS_ENABLED(CONFIG_ACPI_APEI_SEA))
 		return err;
 
+	if (regs)
+		interrupted_flags = regs->pstate;
+
 	/*
 	 * APEI expects an NMI-like notification to always be called
 	 * in NMI context.
@@ -287,6 +292,20 @@ int apei_claim_sea(struct pt_regs *regs)
 	nmi_enter();
 	err = ghes_notify_sea();
 	nmi_exit();
+
+	/*
+	 * APEI NMI-like notifications are deferred to irq_work. Unless
+	 * we interrupted irqs-masked code, we can do that now.
+	 */
+	if (!err) {
+		if (!arch_irqs_disabled_flags(interrupted_flags)) {
+			local_daif_restore(DAIF_PROCCTX_NOIRQ);
+			irq_work_run();
+		} else {
+			err = -EINPROGRESS;
+		}
+	}
+
 	local_daif_restore(current_flags);
 
 	return err;
diff --git a/arch/arm64/mm/fault.c b/arch/arm64/mm/fault.c
index 303c8b425c82..e218e291a17a 100644
--- a/arch/arm64/mm/fault.c
+++ b/arch/arm64/mm/fault.c
@@ -580,11 +580,10 @@ static int do_sea(unsigned long addr, unsigned int esr, struct pt_regs *regs)
 		inf->name, esr, addr);
 
 	if (IS_ENABLED(CONFIG_ACPI_APEI_SEA)) {
-		/*
-		 * Return value ignored as we rely on signal merging.
-		 * Future patches will make this more robust.
-		 */
-		apei_claim_sea(regs);
+		if (apei_claim_sea(regs) == 0) {
+			/* APEI claimed this as a firmware-first notification */
+			return 0;
+		}
 	}
 
 	info.si_signo = SIGBUS;
-- 
2.16.2
