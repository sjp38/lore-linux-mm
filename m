Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 534746B0276
	for <linux-mm@kvack.org>; Tue, 26 Jun 2018 13:02:23 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id h19-v6so12411092otk.16
        for <linux-mm@kvack.org>; Tue, 26 Jun 2018 10:02:23 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id h6-v6si376408oib.203.2018.06.26.10.02.18
        for <linux-mm@kvack.org>;
        Tue, 26 Jun 2018 10:02:19 -0700 (PDT)
From: James Morse <james.morse@arm.com>
Subject: [PATCH v5 07/20] arm64: KVM/mm: Move SEA handling behind a single 'claim' interface
Date: Tue, 26 Jun 2018 18:01:03 +0100
Message-Id: <20180626170116.25825-8-james.morse@arm.com>
In-Reply-To: <20180626170116.25825-1-james.morse@arm.com>
References: <20180626170116.25825-1-james.morse@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-acpi@vger.kernel.org
Cc: kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Punit Agrawal <punit.agrawal@arm.com>, jonathan.zhang@cavium.com, James Morse <james.morse@arm.com>

To split up APEIs in_nmi() path, we need the nmi-like callers to always
be in_nmi(). Add a helper to do the work and claim the notification.

When KVM or the arch code takes an exception that might be a RAS
notification, it asks the APEI firmware-first code whether it wants
to claim the exception. We can then go on to see if (a future)
kernel-first mechanism wants to claim the notification, before
falling through to the existing default behaviour.

The NOTIFY_SEA code was merged before we had multiple, possibly
interacting, NMI-like notifications and the need to consider kernel
first in the future. Make the 'claiming' behaviour explicit.

As we're restructuring the APEI code to allow multiple NMI-like
notifications, any notification that might interrupt interrupts-masked
code must always be wrapped in nmi_enter()/nmi_exit(). This allows APEI
to use in_nmi() to use the right fixmap entries.

We mask SError over this window to prevent an asynchronous RAS error
arriving and tripping 'nmi_enter()'s BUG_ON(in_nmi()).

Signed-off-by: James Morse <james.morse@arm.com>
Acked-by: Marc Zyngier <marc.zyngier@arm.com>
Tested-by: Tyler Baicar <tbaicar@codeaurora.org>

---
Why does apei_claim_sea() take a pt_regs? This gets used later to take
APEI by the hand through NMI->IRQ context, depending on what we
interrupted.

Changes since v4:
 * Made irqs-unmasked comment a lockdep assert.

Changes since v3:
 * Removed spurious whitespace change
 * Updated comment in acpi.c to cover SError masking

Changes since v2:
 * Added dummy definition for !ACPI and culled IS_ENABLED() checks.

squash: make 'call with irqs unmaksed' a lockdep assert, much better
---
 arch/arm64/include/asm/acpi.h      |  4 ++++
 arch/arm64/include/asm/daifflags.h |  1 +
 arch/arm64/include/asm/kvm_ras.h   | 16 +++++++++++++++-
 arch/arm64/kernel/acpi.c           | 30 ++++++++++++++++++++++++++++++
 arch/arm64/mm/fault.c              | 29 +++++------------------------
 5 files changed, 55 insertions(+), 25 deletions(-)

diff --git a/arch/arm64/include/asm/acpi.h b/arch/arm64/include/asm/acpi.h
index 0db62a4cbce2..bfd23f0f0060 100644
--- a/arch/arm64/include/asm/acpi.h
+++ b/arch/arm64/include/asm/acpi.h
@@ -16,6 +16,7 @@
 #include <linux/psci.h>
 
 #include <asm/cputype.h>
+#include <asm/ptrace.h>
 #include <asm/smp_plat.h>
 #include <asm/tlbflush.h>
 
@@ -130,6 +131,9 @@ static inline const char *acpi_get_enable_method(int cpu)
  */
 #define acpi_disable_cmcff 1
 pgprot_t arch_apei_get_mem_attribute(phys_addr_t addr);
+int apei_claim_sea(struct pt_regs *regs);
+#else
+static inline int apei_claim_sea(struct pt_regs *regs) { return -ENOENT; }
 #endif /* CONFIG_ACPI_APEI */
 
 #ifdef CONFIG_ACPI_NUMA
diff --git a/arch/arm64/include/asm/daifflags.h b/arch/arm64/include/asm/daifflags.h
index 22e4c83de5a5..cbd753855bf3 100644
--- a/arch/arm64/include/asm/daifflags.h
+++ b/arch/arm64/include/asm/daifflags.h
@@ -20,6 +20,7 @@
 
 #define DAIF_PROCCTX		0
 #define DAIF_PROCCTX_NOIRQ	PSR_I_BIT
+#define DAIF_ERRCTX		(PSR_I_BIT | PSR_A_BIT)
 
 /* mask/save/unmask/restore all exceptions, including interrupts. */
 static inline void local_daif_mask(void)
diff --git a/arch/arm64/include/asm/kvm_ras.h b/arch/arm64/include/asm/kvm_ras.h
index 5f72b07b7912..5b56e7e297b1 100644
--- a/arch/arm64/include/asm/kvm_ras.h
+++ b/arch/arm64/include/asm/kvm_ras.h
@@ -4,8 +4,22 @@
 #ifndef __ARM64_KVM_RAS_H__
 #define __ARM64_KVM_RAS_H__
 
+#include <linux/acpi.h>
+#include <linux/errno.h>
 #include <linux/types.h>
 
-int kvm_handle_guest_sea(phys_addr_t addr, unsigned int esr);
+#include <asm/acpi.h>
+
+/*
+ * Was this synchronous external abort a RAS notification?
+ * Returns '0' for errors handled by some RAS subsystem, or -ENOENT.
+ */
+static inline int kvm_handle_guest_sea(phys_addr_t addr, unsigned int esr)
+{
+	/* apei_claim_sea(NULL) expects to mask interrupts itself */
+	lockdep_assert_irqs_enabled();
+
+	return apei_claim_sea(NULL);
+}
 
 #endif /* __ARM64_KVM_RAS_H__ */
diff --git a/arch/arm64/kernel/acpi.c b/arch/arm64/kernel/acpi.c
index 7b09487ff8fb..df2c6bff8c58 100644
--- a/arch/arm64/kernel/acpi.c
+++ b/arch/arm64/kernel/acpi.c
@@ -33,6 +33,8 @@
 
 #ifdef CONFIG_ACPI_APEI
 # include <linux/efi.h>
+# include <acpi/ghes.h>
+# include <asm/daifflags.h>
 # include <asm/pgtable.h>
 #endif
 
@@ -261,4 +263,32 @@ pgprot_t arch_apei_get_mem_attribute(phys_addr_t addr)
 		return __pgprot(PROT_NORMAL_NC);
 	return __pgprot(PROT_DEVICE_nGnRnE);
 }
+
+
+/*
+ * Claim Synchronous External Aborts as a firmware first notification.
+ *
+ * Used by KVM and the arch do_sea handler.
+ * @regs may be NULL when called from process context.
+ */
+int apei_claim_sea(struct pt_regs *regs)
+{
+	int err = -ENOENT;
+	unsigned long current_flags = arch_local_save_flags();
+
+	if (!IS_ENABLED(CONFIG_ACPI_APEI_SEA))
+		return err;
+
+	/*
+	 * SEA can interrupt SError, mask it and describe this as an NMI so
+	 * that APEI defers the handling.
+	 */
+	local_daif_restore(DAIF_ERRCTX);
+	nmi_enter();
+	err = ghes_notify_sea();
+	nmi_exit();
+	local_daif_restore(current_flags);
+
+	return err;
+}
 #endif
diff --git a/arch/arm64/mm/fault.c b/arch/arm64/mm/fault.c
index 167772fe4360..fb2761172cd4 100644
--- a/arch/arm64/mm/fault.c
+++ b/arch/arm64/mm/fault.c
@@ -18,6 +18,7 @@
  * along with this program.  If not, see <http://www.gnu.org/licenses/>.
  */
 
+#include <linux/acpi.h>
 #include <linux/extable.h>
 #include <linux/signal.h>
 #include <linux/mm.h>
@@ -33,6 +34,7 @@
 #include <linux/preempt.h>
 #include <linux/hugetlb.h>
 
+#include <asm/acpi.h>
 #include <asm/bug.h>
 #include <asm/cmpxchg.h>
 #include <asm/cpufeature.h>
@@ -45,8 +47,6 @@
 #include <asm/tlbflush.h>
 #include <asm/traps.h>
 
-#include <acpi/ghes.h>
-
 struct fault_info {
 	int	(*fn)(unsigned long addr, unsigned int esr,
 		      struct pt_regs *regs);
@@ -631,19 +631,10 @@ static int do_sea(unsigned long addr, unsigned int esr, struct pt_regs *regs)
 	inf = esr_to_fault_info(esr);
 
 	/*
-	 * Synchronous aborts may interrupt code which had interrupts masked.
-	 * Before calling out into the wider kernel tell the interested
-	 * subsystems.
+	 * Return value ignored as we rely on signal merging.
+	 * Future patches will make this more robust.
 	 */
-	if (IS_ENABLED(CONFIG_ACPI_APEI_SEA)) {
-		if (interrupts_enabled(regs))
-			nmi_enter();
-
-		ghes_notify_sea();
-
-		if (interrupts_enabled(regs))
-			nmi_exit();
-	}
+	apei_claim_sea(regs);
 
 	clear_siginfo(&info);
 	info.si_signo = inf->sig;
@@ -725,16 +716,6 @@ static const struct fault_info fault_info[] = {
 	{ do_bad,		SIGKILL, SI_KERNEL,	"unknown 63"			},
 };
 
-int kvm_handle_guest_sea(phys_addr_t addr, unsigned int esr)
-{
-	int ret = -ENOENT;
-
-	if (IS_ENABLED(CONFIG_ACPI_APEI_SEA))
-		ret = ghes_notify_sea();
-
-	return ret;
-}
-
 asmlinkage void __exception do_mem_abort(unsigned long addr, unsigned int esr,
 					 struct pt_regs *regs)
 {
-- 
2.17.1
