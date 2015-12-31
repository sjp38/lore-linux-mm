Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 239636B0008
	for <linux-mm@kvack.org>; Sun,  3 Jan 2016 20:26:48 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id do7so3352114pab.2
        for <linux-mm@kvack.org>; Sun, 03 Jan 2016 17:26:48 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id w74si70222967pfi.130.2016.01.03.17.26.47
        for <linux-mm@kvack.org>;
        Sun, 03 Jan 2016 17:26:47 -0800 (PST)
Message-Id: <ec20ff32232ddad7f4dc76851392ad1affb8dc8d.1451869360.git.tony.luck@intel.com>
In-Reply-To: <cover.1451869360.git.tony.luck@intel.com>
References: <cover.1451869360.git.tony.luck@intel.com>
From: Tony Luck <tony.luck@intel.com>
Date: Thu, 31 Dec 2015 11:40:27 -0800
Subject: [PATCH v6 3/4] x86, mce: Check for faults tagged in EXTABLE_CLASS_FAULT exception table entries
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Borislav Petkov <bp@alien8.de>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, elliott@hpe.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@ml01.01.org, x86@kernel.org

Extend the severity checking code to add a new context IN_KERN_RECOV
which is used to indicate that the machine check was triggered by code
in the kernel with a EXTABLE_CLASS_FAULT fixup entry.

Major re-work to the tail code in do_machine_check() to make all this
readable/maintainable. One functional change is that tolerant=3 no longer
stops recovery actions. Revert to only skipping sending SIGBUS to the
current process.

Signed-off-by: Tony Luck <tony.luck@intel.com>
---
 arch/x86/kernel/cpu/mcheck/mce-severity.c | 32 +++++++++++++-
 arch/x86/kernel/cpu/mcheck/mce.c          | 71 ++++++++++++++++---------------
 2 files changed, 67 insertions(+), 36 deletions(-)

diff --git a/arch/x86/kernel/cpu/mcheck/mce-severity.c b/arch/x86/kernel/cpu/mcheck/mce-severity.c
index 9c682c222071..b6eee8e9b2a6 100644
--- a/arch/x86/kernel/cpu/mcheck/mce-severity.c
+++ b/arch/x86/kernel/cpu/mcheck/mce-severity.c
@@ -13,7 +13,9 @@
 #include <linux/seq_file.h>
 #include <linux/init.h>
 #include <linux/debugfs.h>
+#include <linux/module.h>
 #include <asm/mce.h>
+#include <asm/uaccess.h>
 
 #include "mce-internal.h"
 
@@ -29,7 +31,7 @@
  * panic situations)
  */
 
-enum context { IN_KERNEL = 1, IN_USER = 2 };
+enum context { IN_KERNEL = 1, IN_USER = 2, IN_KERNEL_RECOV = 3 };
 enum ser { SER_REQUIRED = 1, NO_SER = 2 };
 enum exception { EXCP_CONTEXT = 1, NO_EXCP = 2 };
 
@@ -48,6 +50,7 @@ static struct severity {
 #define MCESEV(s, m, c...) { .sev = MCE_ ## s ## _SEVERITY, .msg = m, ## c }
 #define  KERNEL		.context = IN_KERNEL
 #define  USER		.context = IN_USER
+#define  KERNEL_RECOV	.context = IN_KERNEL_RECOV
 #define  SER		.ser = SER_REQUIRED
 #define  NOSER		.ser = NO_SER
 #define  EXCP		.excp = EXCP_CONTEXT
@@ -87,6 +90,10 @@ static struct severity {
 		EXCP, KERNEL, MCGMASK(MCG_STATUS_RIPV, 0)
 		),
 	MCESEV(
+		PANIC, "In kernel and no restart IP",
+		EXCP, KERNEL_RECOV, MCGMASK(MCG_STATUS_RIPV, 0)
+		),
+	MCESEV(
 		DEFERRED, "Deferred error",
 		NOSER, MASK(MCI_STATUS_UC|MCI_STATUS_DEFERRED|MCI_STATUS_POISON, MCI_STATUS_DEFERRED)
 		),
@@ -123,6 +130,11 @@ static struct severity {
 		MCGMASK(MCG_STATUS_RIPV|MCG_STATUS_EIPV, MCG_STATUS_RIPV)
 		),
 	MCESEV(
+		AR, "Action required: data load in error recoverable area of kernel",
+		SER, MASK(MCI_STATUS_OVER|MCI_UC_SAR|MCI_ADDR|MCACOD, MCI_UC_SAR|MCI_ADDR|MCACOD_DATA),
+		KERNEL_RECOV
+		),
+	MCESEV(
 		AR, "Action required: data load error in a user process",
 		SER, MASK(MCI_STATUS_OVER|MCI_UC_SAR|MCI_ADDR|MCACOD, MCI_UC_SAR|MCI_ADDR|MCACOD_DATA),
 		USER
@@ -170,6 +182,18 @@ static struct severity {
 		)	/* always matches. keep at end */
 };
 
+#define mc_recoverable(mcg) (((mcg) & (MCG_STATUS_RIPV|MCG_STATUS_EIPV)) == \
+				(MCG_STATUS_RIPV|MCG_STATUS_EIPV))
+
+static inline bool mce_in_kernel_recov(unsigned long addr)
+{
+	const struct exception_table_entry *fixup;
+
+	fixup = search_exception_tables(addr);
+
+	return fixup && ex_class(fixup) == EXTABLE_CLASS_FAULT;
+}
+
 /*
  * If mcgstatus indicated that ip/cs on the stack were
  * no good, then "m->cs" will be zero and we will have
@@ -183,7 +207,11 @@ static struct severity {
  */
 static int error_context(struct mce *m)
 {
-	return ((m->cs & 3) == 3) ? IN_USER : IN_KERNEL;
+	if ((m->cs & 3) == 3)
+		return IN_USER;
+	if (mc_recoverable(m->mcgstatus) && mce_in_kernel_recov(m->ip))
+		return IN_KERNEL_RECOV;
+	return IN_KERNEL;
 }
 
 /*
diff --git a/arch/x86/kernel/cpu/mcheck/mce.c b/arch/x86/kernel/cpu/mcheck/mce.c
index 9d014b82a124..d69a69b38c54 100644
--- a/arch/x86/kernel/cpu/mcheck/mce.c
+++ b/arch/x86/kernel/cpu/mcheck/mce.c
@@ -31,6 +31,7 @@
 #include <linux/types.h>
 #include <linux/slab.h>
 #include <linux/init.h>
+#include <linux/module.h>
 #include <linux/kmod.h>
 #include <linux/poll.h>
 #include <linux/nmi.h>
@@ -958,6 +959,20 @@ static void mce_clear_state(unsigned long *toclear)
 	}
 }
 
+static int do_memory_failure(struct mce *m)
+{
+	int flags = MF_ACTION_REQUIRED;
+	int ret;
+
+	pr_err("Uncorrected hardware memory error in user-access at %llx", m->addr);
+	if (!(m->mcgstatus & MCG_STATUS_RIPV))
+		flags |= MF_MUST_KILL;
+	ret = memory_failure(m->addr >> PAGE_SHIFT, MCE_VECTOR, flags);
+	if (ret)
+		pr_err("Memory error not recovered");
+	return ret;
+}
+
 /*
  * The actual machine check handler. This only handles real
  * exceptions when something got corrupted coming in through int 18.
@@ -995,8 +1010,6 @@ void do_machine_check(struct pt_regs *regs, long error_code)
 	DECLARE_BITMAP(toclear, MAX_NR_BANKS);
 	DECLARE_BITMAP(valid_banks, MAX_NR_BANKS);
 	char *msg = "Unknown";
-	u64 recover_paddr = ~0ull;
-	int flags = MF_ACTION_REQUIRED;
 	int lmce = 0;
 
 	ist_enter(regs);
@@ -1123,22 +1136,13 @@ void do_machine_check(struct pt_regs *regs, long error_code)
 	}
 
 	/*
-	 * At insane "tolerant" levels we take no action. Otherwise
-	 * we only die if we have no other choice. For less serious
-	 * issues we try to recover, or limit damage to the current
-	 * process.
+	 * If tolerant is at an insane level we drop requests to kill
+	 * processes and continue even when there is no way out.
 	 */
-	if (cfg->tolerant < 3) {
-		if (no_way_out)
-			mce_panic("Fatal machine check on current CPU", &m, msg);
-		if (worst == MCE_AR_SEVERITY) {
-			recover_paddr = m.addr;
-			if (!(m.mcgstatus & MCG_STATUS_RIPV))
-				flags |= MF_MUST_KILL;
-		} else if (kill_it) {
-			force_sig(SIGBUS, current);
-		}
-	}
+	if (cfg->tolerant == 3)
+		kill_it = 0;
+	else if (no_way_out)
+		mce_panic("Fatal machine check on current CPU", &m, msg);
 
 	if (worst > 0)
 		mce_report_event(regs);
@@ -1146,25 +1150,24 @@ void do_machine_check(struct pt_regs *regs, long error_code)
 out:
 	sync_core();
 
-	if (recover_paddr == ~0ull)
-		goto done;
+	if (worst != MCE_AR_SEVERITY && !kill_it)
+		goto out_ist;
 
-	pr_err("Uncorrected hardware memory error in user-access at %llx",
-		 recover_paddr);
-	/*
-	 * We must call memory_failure() here even if the current process is
-	 * doomed. We still need to mark the page as poisoned and alert any
-	 * other users of the page.
-	 */
-	ist_begin_non_atomic(regs);
-	local_irq_enable();
-	if (memory_failure(recover_paddr >> PAGE_SHIFT, MCE_VECTOR, flags) < 0) {
-		pr_err("Memory error not recovered");
-		force_sig(SIGBUS, current);
+	/* Fault was in user mode and we need to take some action */
+	if ((m.cs & 3) == 3) {
+		ist_begin_non_atomic(regs);
+		local_irq_enable();
+
+		if (kill_it || do_memory_failure(&m))
+			force_sig(SIGBUS, current);
+		local_irq_disable();
+		ist_end_non_atomic();
+	} else {
+		if (!fixup_exception(regs, X86_TRAP_MC))
+			mce_panic("Failed kernel mode recovery", &m, NULL);
 	}
-	local_irq_disable();
-	ist_end_non_atomic();
-done:
+
+out_ist:
 	ist_exit(regs);
 }
 EXPORT_SYMBOL_GPL(do_machine_check);
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
