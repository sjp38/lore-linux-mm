Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5023B8E0001
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 18:18:11 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id b8-v6so13459691oib.4
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 15:18:11 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id r204-v6si12032213oih.29.2018.09.21.15.18.09
        for <linux-mm@kvack.org>;
        Fri, 21 Sep 2018 15:18:09 -0700 (PDT)
From: James Morse <james.morse@arm.com>
Subject: [PATCH v6 06/18] KVM: arm/arm64: Add kvm_ras.h to collect kvm specific RAS plumbing
Date: Fri, 21 Sep 2018 23:16:53 +0100
Message-Id: <20180921221705.6478-7-james.morse@arm.com>
In-Reply-To: <20180921221705.6478-1-james.morse@arm.com>
References: <20180921221705.6478-1-james.morse@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-acpi@vger.kernel.org
Cc: kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Punit Agrawal <punit.agrawal@arm.com>, jonathan.zhang@cavium.com, James Morse <james.morse@arm.com>

To split up APEIs in_nmi() path, we need any nmi-like callers to always
be in_nmi(). KVM shouldn't have to know about this, pull the RAS plumbing
out into a header file.

Currently guest synchronous external aborts are claimed as RAS
notifications by handle_guest_sea(), which is hidden in the arch codes
mm/fault.c. 32bit gets a dummy declaration in system_misc.h.

There is going to be more of this in the future if/when we support
the SError-based firmware-first notification mechanism and/or
kernel-first notifications for both synchronous external abort and
SError. Each of these will come with some Kconfig symbols and a
handful of header files.

Create a header file for all this.

This patch gives handle_guest_sea() a 'kvm_' prefix, and moves the
declarations to kvm_ras.h as preparation for a future patch that moves
the ACPI-specific RAS code out of mm/fault.c.

Signed-off-by: James Morse <james.morse@arm.com>
Reviewed-by: Punit Agrawal <punit.agrawal@arm.com>
Acked-by: Marc Zyngier <marc.zyngier@arm.com>
Tested-by: Tyler Baicar <tbaicar@codeaurora.org>
---
 arch/arm/include/asm/kvm_ras.h       | 14 ++++++++++++++
 arch/arm/include/asm/system_misc.h   |  5 -----
 arch/arm64/include/asm/kvm_ras.h     | 11 +++++++++++
 arch/arm64/include/asm/system_misc.h |  2 --
 arch/arm64/mm/fault.c                |  2 +-
 virt/kvm/arm/mmu.c                   |  4 ++--
 6 files changed, 28 insertions(+), 10 deletions(-)
 create mode 100644 arch/arm/include/asm/kvm_ras.h
 create mode 100644 arch/arm64/include/asm/kvm_ras.h

diff --git a/arch/arm/include/asm/kvm_ras.h b/arch/arm/include/asm/kvm_ras.h
new file mode 100644
index 000000000000..aaff56bf338f
--- /dev/null
+++ b/arch/arm/include/asm/kvm_ras.h
@@ -0,0 +1,14 @@
+// SPDX-License-Identifier: GPL-2.0
+// Copyright (C) 2018 - Arm Ltd
+
+#ifndef __ARM_KVM_RAS_H__
+#define __ARM_KVM_RAS_H__
+
+#include <linux/types.h>
+
+static inline int kvm_handle_guest_sea(phys_addr_t addr, unsigned int esr)
+{
+	return -1;
+}
+
+#endif /* __ARM_KVM_RAS_H__ */
diff --git a/arch/arm/include/asm/system_misc.h b/arch/arm/include/asm/system_misc.h
index 8e76db83c498..66f6a3ae68d2 100644
--- a/arch/arm/include/asm/system_misc.h
+++ b/arch/arm/include/asm/system_misc.h
@@ -38,11 +38,6 @@ static inline void harden_branch_predictor(void)
 
 extern unsigned int user_debug;
 
-static inline int handle_guest_sea(phys_addr_t addr, unsigned int esr)
-{
-	return -1;
-}
-
 #endif /* !__ASSEMBLY__ */
 
 #endif /* __ASM_ARM_SYSTEM_MISC_H */
diff --git a/arch/arm64/include/asm/kvm_ras.h b/arch/arm64/include/asm/kvm_ras.h
new file mode 100644
index 000000000000..5f72b07b7912
--- /dev/null
+++ b/arch/arm64/include/asm/kvm_ras.h
@@ -0,0 +1,11 @@
+// SPDX-License-Identifier: GPL-2.0
+// Copyright (C) 2018 - Arm Ltd
+
+#ifndef __ARM64_KVM_RAS_H__
+#define __ARM64_KVM_RAS_H__
+
+#include <linux/types.h>
+
+int kvm_handle_guest_sea(phys_addr_t addr, unsigned int esr);
+
+#endif /* __ARM64_KVM_RAS_H__ */
diff --git a/arch/arm64/include/asm/system_misc.h b/arch/arm64/include/asm/system_misc.h
index 28893a0b141d..48ded3628a89 100644
--- a/arch/arm64/include/asm/system_misc.h
+++ b/arch/arm64/include/asm/system_misc.h
@@ -45,8 +45,6 @@ extern void __show_regs(struct pt_regs *);
 
 extern void (*arm_pm_restart)(enum reboot_mode reboot_mode, const char *cmd);
 
-int handle_guest_sea(phys_addr_t addr, unsigned int esr);
-
 #endif	/* __ASSEMBLY__ */
 
 #endif	/* __ASM_SYSTEM_MISC_H */
diff --git a/arch/arm64/mm/fault.c b/arch/arm64/mm/fault.c
index 50b30ff30de4..1a30d7a8c9bf 100644
--- a/arch/arm64/mm/fault.c
+++ b/arch/arm64/mm/fault.c
@@ -725,7 +725,7 @@ static const struct fault_info fault_info[] = {
 	{ do_bad,		SIGKILL, SI_KERNEL,	"unknown 63"			},
 };
 
-int handle_guest_sea(phys_addr_t addr, unsigned int esr)
+int kvm_handle_guest_sea(phys_addr_t addr, unsigned int esr)
 {
 	return ghes_notify_sea();
 }
diff --git a/virt/kvm/arm/mmu.c b/virt/kvm/arm/mmu.c
index ed162a6c57c5..100c8f2d67ac 100644
--- a/virt/kvm/arm/mmu.c
+++ b/virt/kvm/arm/mmu.c
@@ -27,10 +27,10 @@
 #include <asm/kvm_arm.h>
 #include <asm/kvm_mmu.h>
 #include <asm/kvm_mmio.h>
+#include <asm/kvm_ras.h>
 #include <asm/kvm_asm.h>
 #include <asm/kvm_emulate.h>
 #include <asm/virt.h>
-#include <asm/system_misc.h>
 
 #include "trace.h"
 
@@ -1699,7 +1699,7 @@ int kvm_handle_guest_abort(struct kvm_vcpu *vcpu, struct kvm_run *run)
 		 * For RAS the host kernel may handle this abort.
 		 * There is no need to pass the error into the guest.
 		 */
-		if (!handle_guest_sea(fault_ipa, kvm_vcpu_get_hsr(vcpu)))
+		if (!kvm_handle_guest_sea(fault_ipa, kvm_vcpu_get_hsr(vcpu)))
 			return 1;
 
 		if (unlikely(!is_iabt)) {
-- 
2.19.0
