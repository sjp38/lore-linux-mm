Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 981B46B000C
	for <linux-mm@kvack.org>; Fri, 27 Apr 2018 11:38:43 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id y49-v6so1430367oti.11
        for <linux-mm@kvack.org>; Fri, 27 Apr 2018 08:38:43 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id w6-v6si530655oif.136.2018.04.27.08.38.42
        for <linux-mm@kvack.org>;
        Fri, 27 Apr 2018 08:38:42 -0700 (PDT)
From: James Morse <james.morse@arm.com>
Subject: [PATCH v3 06/12] arm64: KVM/mm: Move SEA handling behind a single 'claim' interface
Date: Fri, 27 Apr 2018 16:35:04 +0100
Message-Id: <20180427153510.5799-7-james.morse@arm.com>
In-Reply-To: <20180427153510.5799-1-james.morse@arm.com>
References: <20180427153510.5799-1-james.morse@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-acpi@vger.kernel.org
Cc: kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <cdall@kernel.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Punit Agrawal <punit.agrawal@arm.com>, jonathan.zhang@cavium.com, James Morse <james.morse@arm.com>

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
to use in_nmi() to choose between the raw/regular spinlock routines.

We mask SError over this window to prevent an asynchronous RAS error
arriving and tripping 'nmi_enter()'s BUG_ON(in_nmi()).

Signed-off-by: James Morse <james.morse@arm.com>
Acked-by: Marc Zyngier <marc.zyngier@arm.com>
---
Why does apei_claim_sea() take a pt_regs? This gets used later to take
APEI by the hand through NMI->IRQ context, depending on what we
interrupted.

Changes since v2:
 * Added dummy definition for !ACPI and culled IS_ENABLED() checks.

 arch/arm64/include/asm/acpi.h      |  5 ++++-
 arch/arm64/include/asm/daifflags.h |  1 +
 arch/arm64/include/asm/kvm_ras.h   | 15 ++++++++++++++-
 arch/arm64/kernel/acpi.c           | 30 ++++++++++++++++++++++++++++++
 arch/arm64/mm/fault.c              | 29 +++++------------------------
 5 files changed, 54 insertions(+), 26 deletions(-)

diff --git a/arch/arm64/include/asm/acpi.h b/arch/arm64/include/asm/acpi.h
index 32f465a80e4e..e8e4f05b4776 100644
--- a/arch/arm64/include/asm/acpi.h
+++ b/arch/arm64/include/asm/acpi.h
@@ -16,6 +16,7 @@
 #include <linux/psci.h>
 
 #include <asm/cputype.h>
+#include <asm/ptrace.h>
 #include <asm/smp_plat.h>
 #include <asm/tlbflush.h>
 
@@ -89,7 +90,6 @@ struct acpi_madt_generic_interrupt *acpi_cpu_get_madt_gicc(int cpu);
 
 static inline void arch_fix_phys_package_id(int num, u32 slot) { }
 void __init acpi_init_cpus(void);
-
 #else
 static inline void acpi_init_cpus(void) { }
 #endif /* CONFIG_ACPI */
@@ -126,6 +126,9 @@ static inline const char *acpi_get_enable_method(int cpu)
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
index 5f72b07b7912..52edc9b3b937 100644
--- a/arch/arm64/include/asm/kvm_ras.h
+++ b/arch/arm64/include/asm/kvm_ras.h
@@ -4,8 +4,21 @@
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
+ *
+ * Call with irqs unmasked.
+ */
+static inline int kvm_handle_guest_sea(phys_addr_t addr, unsigned int esr)
+{
+	return apei_claim_sea(NULL);
+}
 
 #endif /* __ARM64_KVM_RAS_H__ */
diff --git a/arch/arm64/kernel/acpi.c b/arch/arm64/kernel/acpi.c
index 7b09487ff8fb..6a4823a3eb5e 100644
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
+	 * APEI expects an NMI-like notification to always be called
+	 * in NMI context.
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
index d61a886afec7..d7e89da0e5df 100644
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
@@ -569,19 +569,10 @@ static int do_sea(unsigned long addr, unsigned int esr, struct pt_regs *regs)
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
 
 	info.si_signo = inf->sig;
 	info.si_errno = 0;
@@ -662,16 +653,6 @@ static const struct fault_info fault_info[] = {
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
2.16.2
