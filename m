Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id BFCCF82F99
	for <linux-mm@kvack.org>; Thu, 24 Dec 2015 16:10:06 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id cy9so70402654pac.0
        for <linux-mm@kvack.org>; Thu, 24 Dec 2015 13:10:06 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id fk7si10947848pab.219.2015.12.24.13.10.05
        for <linux-mm@kvack.org>;
        Thu, 24 Dec 2015 13:10:05 -0800 (PST)
Message-Id: <acbb5f013073018d01c3048e719b5e69ade08077.1450990481.git.tony.luck@intel.com>
In-Reply-To: <cover.1450990481.git.tony.luck@intel.com>
References: <cover.1450990481.git.tony.luck@intel.com>
From: Tony Luck <tony.luck@intel.com>
Date: Tue, 15 Dec 2015 17:29:59 -0800
Subject: [PATCHV4 2/3] x86, ras: Extend machine check recovery code to annotated
 ring0 areas
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Borislav Petkov <bp@alien8.de>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, elliott@hpe.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@ml01.01.org, x86@kernel.org

Extend the severity checking code to add a new context IN_KERN_RECOV
which is used to indicate that the machine check was triggered by code
in the kernel with a fixup entry.

Add code to check for this situation and respond by altering the return
IP to the fixup address.

Major re-work to the tail code in do_machine_check() to make all this
readable/maintainable. One functional change is that tolerant=3 no longer
stops recovery actions. Revert to only skipping sending SIGBUS to the
current process.

Reviewed-by: Borislav Petkov <bp@suse.de>
Signed-off-by: Tony Luck <tony.luck@intel.com>
---
 arch/x86/kernel/cpu/mcheck/mce-severity.c | 21 +++++++++-
 arch/x86/kernel/cpu/mcheck/mce.c          | 70 ++++++++++++++++---------------
 2 files changed, 55 insertions(+), 36 deletions(-)

diff --git a/arch/x86/kernel/cpu/mcheck/mce-severity.c b/arch/x86/kernel/cpu/mcheck/mce-severity.c
index 9c682c222071..cc7136351820 100644
--- a/arch/x86/kernel/cpu/mcheck/mce-severity.c
+++ b/arch/x86/kernel/cpu/mcheck/mce-severity.c
@@ -29,7 +29,7 @@
  * panic situations)
  */
 
-enum context { IN_KERNEL = 1, IN_USER = 2 };
+enum context { IN_KERNEL = 1, IN_USER = 2, IN_KERNEL_RECOV = 3 };
 enum ser { SER_REQUIRED = 1, NO_SER = 2 };
 enum exception { EXCP_CONTEXT = 1, NO_EXCP = 2 };
 
@@ -48,6 +48,7 @@ static struct severity {
 #define MCESEV(s, m, c...) { .sev = MCE_ ## s ## _SEVERITY, .msg = m, ## c }
 #define  KERNEL		.context = IN_KERNEL
 #define  USER		.context = IN_USER
+#define  KERNEL_RECOV	.context = IN_KERNEL_RECOV
 #define  SER		.ser = SER_REQUIRED
 #define  NOSER		.ser = NO_SER
 #define  EXCP		.excp = EXCP_CONTEXT
@@ -87,6 +88,10 @@ static struct severity {
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
@@ -123,6 +128,11 @@ static struct severity {
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
@@ -170,6 +180,9 @@ static struct severity {
 		)	/* always matches. keep at end */
 };
 
+#define mc_recoverable(mcg) (((mcg) & (MCG_STATUS_RIPV|MCG_STATUS_EIPV)) == \
+				(MCG_STATUS_RIPV|MCG_STATUS_EIPV))
+
 /*
  * If mcgstatus indicated that ip/cs on the stack were
  * no good, then "m->cs" will be zero and we will have
@@ -183,7 +196,11 @@ static struct severity {
  */
 static int error_context(struct mce *m)
 {
-	return ((m->cs & 3) == 3) ? IN_USER : IN_KERNEL;
+	if ((m->cs & 3) == 3)
+		return IN_USER;
+	if (mc_recoverable(m->mcgstatus) && search_mcexception_tables(m->ip))
+		return IN_KERNEL_RECOV;
+	return IN_KERNEL;
 }
 
 /*
diff --git a/arch/x86/kernel/cpu/mcheck/mce.c b/arch/x86/kernel/cpu/mcheck/mce.c
index 0111cd49ee94..e848b583e840 100644
--- a/arch/x86/kernel/cpu/mcheck/mce.c
+++ b/arch/x86/kernel/cpu/mcheck/mce.c
@@ -959,6 +959,20 @@ static void mce_clear_state(unsigned long *toclear)
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
@@ -996,8 +1010,6 @@ void do_machine_check(struct pt_regs *regs, long error_code)
 	DECLARE_BITMAP(toclear, MAX_NR_BANKS);
 	DECLARE_BITMAP(valid_banks, MAX_NR_BANKS);
 	char *msg = "Unknown";
-	u64 recover_paddr = ~0ull;
-	int flags = MF_ACTION_REQUIRED;
 	int lmce = 0;
 
 	ist_enter(regs);
@@ -1124,22 +1136,13 @@ void do_machine_check(struct pt_regs *regs, long error_code)
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
@@ -1147,25 +1150,24 @@ void do_machine_check(struct pt_regs *regs, long error_code)
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
+		if (!fixup_mcexception(regs))
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
