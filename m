Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id DAFC96B000E
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 13:59:07 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id 15so320610oip.7
        for <linux-mm@kvack.org>; Thu, 15 Feb 2018 10:59:07 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id y131si568326oia.180.2018.02.15.10.59.06
        for <linux-mm@kvack.org>;
        Thu, 15 Feb 2018 10:59:06 -0800 (PST)
From: James Morse <james.morse@arm.com>
Subject: [PATCH 05/11] arm64: KVM/mm: Move SEA handling behind a single 'claim' interface
Date: Thu, 15 Feb 2018 18:56:00 +0000
Message-Id: <20180215185606.26736-6-james.morse@arm.com>
In-Reply-To: <20180215185606.26736-1-james.morse@arm.com>
References: <20180215185606.26736-1-james.morse@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-acpi@vger.kernel.org
Cc: kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, Christoffer Dall <christoffer.dall@linaro.org>, Marc Zyngier <marc.zyngier@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Punit Agrawal <punit.agrawal@arm.com>, James Morse <james.morse@arm.com>

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
to use in_nmi() so choose between the raw/regular spinlock routines.

We mask SError over this window to prevent an asynchronous RAS error
arriving and tripping 'nmi_enter()'s BUG_ON(in_nmi()).

Signed-off-by: James Morse <james.morse@arm.com>
CC: Tyler Baicar <tbaicar@codeaurora.org>
---
Why does apei_claim_sea() take a pt_regs? This gets used later to take
APEI by the hand through NMI->IRQ context, depending on what we
interrupted.

 arch/arm64/include/asm/acpi.h      |  3 +++
 arch/arm64/include/asm/daifflags.h |  1 +
 arch/arm64/include/asm/kvm_ras.h   | 20 +++++++++++++++++++-
 arch/arm64/kernel/acpi.c           | 30 ++++++++++++++++++++++++++++++
 arch/arm64/mm/fault.c              | 31 +++++++------------------------
 5 files changed, 60 insertions(+), 25 deletions(-)

diff --git a/arch/arm64/include/asm/acpi.h b/arch/arm64/include/asm/acpi.h
index 32f465a80e4e..256811cd4b8b 100644
--- a/arch/arm64/include/asm/acpi.h
+++ b/arch/arm64/include/asm/acpi.h
@@ -16,6 +16,7 @@
 #include <linux/psci.h>
 
 #include <asm/cputype.h>
+#include <asm/ptrace.h>
 #include <asm/smp_plat.h>
 #include <asm/tlbflush.h>
 
@@ -94,6 +95,8 @@ void __init acpi_init_cpus(void);
 static inline void acpi_init_cpus(void) { }
 #endif /* CONFIG_ACPI */
 
+int apei_claim_sea(struct pt_regs *regs);
+
 #ifdef CONFIG_ARM64_ACPI_PARKING_PROTOCOL
 bool acpi_parking_protocol_valid(int cpu);
 void __init
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
index 5f72b07b7912..9d52bc333110 100644
--- a/arch/arm64/include/asm/kvm_ras.h
+++ b/arch/arm64/include/asm/kvm_ras.h
@@ -4,8 +4,26 @@
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
+ * Call with irqs unmaksed.
+ */
+static inline int kvm_handle_guest_sea(phys_addr_t addr, unsigned int esr)
+{
+	int ret = -ENOENT;
+
+	if (IS_ENABLED(CONFIG_ACPI_APEI_SEA))
+		ret = apei_claim_sea(NULL);
+
+	return ret;
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
index adac28ce9be3..8cbbd9a5ec7d 100644
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
@@ -44,8 +46,6 @@
 #include <asm/pgtable.h>
 #include <asm/tlbflush.h>
 
-#include <acpi/ghes.h>
-
 struct fault_info {
 	int	(*fn)(unsigned long addr, unsigned int esr,
 		      struct pt_regs *regs);
@@ -579,19 +579,12 @@ static int do_sea(unsigned long addr, unsigned int esr, struct pt_regs *regs)
 	pr_err("Synchronous External Abort: %s (0x%08x) at 0x%016lx\n",
 		inf->name, esr, addr);
 
-	/*
-	 * Synchronous aborts may interrupt code which had interrupts masked.
-	 * Before calling out into the wider kernel tell the interested
-	 * subsystems.
-	 */
 	if (IS_ENABLED(CONFIG_ACPI_APEI_SEA)) {
-		if (interrupts_enabled(regs))
-			nmi_enter();
-
-		ghes_notify_sea();
-
-		if (interrupts_enabled(regs))
-			nmi_exit();
+		/*
+		 * Return value ignored as we rely on signal merging.
+		 * Future patches will make this more robust.
+		 */
+		apei_claim_sea(regs);
 	}
 
 	info.si_signo = SIGBUS;
@@ -673,16 +666,6 @@ static const struct fault_info fault_info[] = {
 	{ do_bad,		SIGBUS,  BUS_FIXME,	"unknown 63"			},
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
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
