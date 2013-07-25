Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 6179D6B0036
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 18:25:58 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 4/6] x86: finish user fault error path with fatal signal
Date: Thu, 25 Jul 2013 18:25:36 -0400
Message-Id: <1374791138-15665-5-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1374791138-15665-1-git-send-email-hannes@cmpxchg.org>
References: <1374791138-15665-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, azurIt <azurit@pobox.sk>, linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

The x86 fault handler bails in the middle of error handling when the
task has a fatal signal pending.  For a subsequent patch this is a
problem in OOM situations because it relies on
pagefault_out_of_memory() being called even when the task has been
killed, to perform proper per-task OOM state unwinding.

Shortcutting the fault like this is a rather minor optimization that
saves a few instructions in rare cases.  Just remove it for
user-triggered faults.

Use the opportunity to split the fault retry handling from actual
fault errors and add locking documentation that reads suprisingly
similar to ARM's.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 arch/x86/mm/fault.c | 35 +++++++++++++++++------------------
 1 file changed, 17 insertions(+), 18 deletions(-)

diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 6d77c38..3aaeffc 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -842,23 +842,15 @@ do_sigbus(struct pt_regs *regs, unsigned long error_code, unsigned long address,
 	force_sig_info_fault(SIGBUS, code, address, tsk, fault);
 }
 
-static noinline int
+static noinline void
 mm_fault_error(struct pt_regs *regs, unsigned long error_code,
 	       unsigned long address, unsigned int fault)
 {
-	/*
-	 * Pagefault was interrupted by SIGKILL. We have no reason to
-	 * continue pagefault.
-	 */
-	if (fatal_signal_pending(current)) {
-		if (!(fault & VM_FAULT_RETRY))
-			up_read(&current->mm->mmap_sem);
-		if (!(error_code & PF_USER))
-			no_context(regs, error_code, address, 0, 0);
-		return 1;
+	if (fatal_signal_pending(current) && !(error_code & PF_USER)) {
+		up_read(&current->mm->mmap_sem);
+		no_context(regs, error_code, address, 0, 0);
+		return;
 	}
-	if (!(fault & VM_FAULT_ERROR))
-		return 0;
 
 	if (fault & VM_FAULT_OOM) {
 		/* Kernel mode? Handle exceptions or die: */
@@ -866,7 +858,7 @@ mm_fault_error(struct pt_regs *regs, unsigned long error_code,
 			up_read(&current->mm->mmap_sem);
 			no_context(regs, error_code, address,
 				   SIGSEGV, SEGV_MAPERR);
-			return 1;
+			return;
 		}
 
 		up_read(&current->mm->mmap_sem);
@@ -884,7 +876,6 @@ mm_fault_error(struct pt_regs *regs, unsigned long error_code,
 		else
 			BUG();
 	}
-	return 1;
 }
 
 static int spurious_fault_check(unsigned long error_code, pte_t *pte)
@@ -1189,9 +1180,17 @@ good_area:
 	 */
 	fault = handle_mm_fault(mm, vma, address, flags);
 
-	if (unlikely(fault & (VM_FAULT_RETRY|VM_FAULT_ERROR))) {
-		if (mm_fault_error(regs, error_code, address, fault))
-			return;
+	/*
+	 * If we need to retry but a fatal signal is pending, handle the
+	 * signal first. We do not need to release the mmap_sem because it
+	 * would already be released in __lock_page_or_retry in mm/filemap.c.
+	 */
+	if (unlikely((fault & VM_FAULT_RETRY) && fatal_signal_pending(current)))
+		return;
+
+	if (unlikely(fault & VM_FAULT_ERROR)) {
+		mm_fault_error(regs, error_code, address, fault);
+		return;
 	}
 
 	/*
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
