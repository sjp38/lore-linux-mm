Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id CA89A6B0035
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 20:20:05 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id p10so9953899pdj.22
        for <linux-mm@kvack.org>; Mon, 21 Jul 2014 17:20:05 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id 11si7920490pdj.31.2014.07.21.17.20.04
        for <linux-mm@kvack.org>;
        Mon, 21 Jul 2014 17:20:04 -0700 (PDT)
Message-Id: <f6ee27db104e769822437234b3fee199d51b5177.1405982894.git.tony.luck@intel.com>
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F32871435@ORSMSX114.amr.corp.intel.com>
From: Tony Luck <tony.luck@intel.com>
Date: Mon, 21 Jul 2014 15:44:06 -0700
Subject: RE: [RFC PATCH 2/3] x86, MCE: Avoid potential deadlock in MCE
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: "Chen, Gong" <gong.chen@linux.jf.intel.com>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>


This is how much cleaner things could be with a couple of task_struct
fields instead of the mce_info silliness ... untested.

---
 arch/x86/kernel/cpu/mcheck/mce.c | 58 ++++------------------------------------
 include/linux/sched.h            |  4 +++
 2 files changed, 9 insertions(+), 53 deletions(-)

diff --git a/arch/x86/kernel/cpu/mcheck/mce.c b/arch/x86/kernel/cpu/mcheck/mce.c
index bb92f38153b2..b08398e69b5c 100644
--- a/arch/x86/kernel/cpu/mcheck/mce.c
+++ b/arch/x86/kernel/cpu/mcheck/mce.c
@@ -956,51 +956,6 @@ static void mce_clear_state(unsigned long *toclear)
 }
 
 /*
- * Need to save faulting physical address associated with a process
- * in the machine check handler some place where we can grab it back
- * later in mce_notify_process()
- */
-#define	MCE_INFO_MAX	16
-
-struct mce_info {
-	atomic_t		inuse;
-	struct task_struct	*t;
-	__u64			paddr;
-	int			restartable;
-} mce_info[MCE_INFO_MAX];
-
-static void mce_save_info(__u64 addr, int c)
-{
-	struct mce_info *mi;
-
-	for (mi = mce_info; mi < &mce_info[MCE_INFO_MAX]; mi++) {
-		if (atomic_cmpxchg(&mi->inuse, 0, 1) == 0) {
-			mi->t = current;
-			mi->paddr = addr;
-			mi->restartable = c;
-			return;
-		}
-	}
-
-	mce_panic("Too many concurrent recoverable errors", NULL, NULL);
-}
-
-static struct mce_info *mce_find_info(void)
-{
-	struct mce_info *mi;
-
-	for (mi = mce_info; mi < &mce_info[MCE_INFO_MAX]; mi++)
-		if (atomic_read(&mi->inuse) && mi->t == current)
-			return mi;
-	return NULL;
-}
-
-static void mce_clear_info(struct mce_info *mi)
-{
-	atomic_set(&mi->inuse, 0);
-}
-
-/*
  * The actual machine check handler. This only handles real
  * exceptions when something got corrupted coming in through int 18.
  *
@@ -1156,7 +1111,8 @@ void do_machine_check(struct pt_regs *regs, long error_code)
 			mce_panic("Fatal machine check on current CPU", &m, msg);
 		if (worst == MCE_AR_SEVERITY) {
 			/* schedule action before return to userland */
-			mce_save_info(m.addr, m.mcgstatus & MCG_STATUS_RIPV);
+			current->paddr = m.addr;
+			current->restartable = m.mcgstatus & MCG_STATUS_RIPV;
 			set_thread_flag(TIF_MCE_NOTIFY);
 		} else if (kill_it) {
 			force_sig(SIGBUS, current);
@@ -1195,29 +1151,25 @@ int memory_failure(unsigned long pfn, int vector, int flags)
 void mce_notify_process(void)
 {
 	unsigned long pfn;
-	struct mce_info *mi = mce_find_info();
 	int flags = MF_ACTION_REQUIRED;
 
-	if (!mi)
-		mce_panic("Lost physical address for unconsumed uncorrectable error", NULL, NULL);
-	pfn = mi->paddr >> PAGE_SHIFT;
+	pfn = current->paddr >> PAGE_SHIFT;
 
 	clear_thread_flag(TIF_MCE_NOTIFY);
 
 	pr_err("Uncorrected hardware memory error in user-access at %llx",
-		 mi->paddr);
+		 current->paddr);
 	/*
 	 * We must call memory_failure() here even if the current process is
 	 * doomed. We still need to mark the page as poisoned and alert any
 	 * other users of the page.
 	 */
-	if (!mi->restartable)
+	if (!current->restartable)
 		flags |= MF_MUST_KILL;
 	if (memory_failure(pfn, MCE_VECTOR, flags) < 0) {
 		pr_err("Memory error not recovered");
 		force_sig(SIGBUS, current);
 	}
-	mce_clear_info(mi);
 }
 
 /*
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 0376b054a0d0..91db69a4acd7 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1655,6 +1655,10 @@ struct task_struct {
 	unsigned int	sequential_io;
 	unsigned int	sequential_io_avg;
 #endif
+#ifdef CONFIG_MEMORY_FAILURE
+	__u64	paddr;
+	int	restartable;
+#endif
 };
 
 /* Future-safe accessor for struct task_struct's cpus_allowed. */
-- 
1.8.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
