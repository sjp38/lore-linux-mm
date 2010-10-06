Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E7E966B0087
	for <linux-mm@kvack.org>; Wed,  6 Oct 2010 16:57:35 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH 2/2] x86: HWPOISON: Report correct address granuality for huge hwpoison faults
Date: Wed,  6 Oct 2010 22:57:21 +0200
Message-Id: <1286398641-11862-3-git-send-email-andi@firstfloor.org>
In-Reply-To: <1286398641-11862-1-git-send-email-andi@firstfloor.org>
References: <1286398641-11862-1-git-send-email-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, fengguang.wu@intel.com, n-horiguchi@ah.jp.nec.com, x86@kernel.org, Andi Kleen <ak@linux.intel.com>
List-ID: <linux-mm.kvack.org>

From: Andi Kleen <ak@linux.intel.com>

An earlier patch fixed the hwpoison fault handling to encode the
huge page size in the fault code of the page fault handler.

This is needed to report this information in SIGBUS to user space.

This is a straight forward patch to pass this information
through to the signal handling in the x86 specific fault.c

Cc: x86@kernel.org
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: fengguang.wu@intel.com
Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 arch/x86/mm/fault.c |   19 +++++++++++++------
 1 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 4c4508e..1d15a27 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -11,6 +11,7 @@
 #include <linux/kprobes.h>		/* __kprobes, ...		*/
 #include <linux/mmiotrace.h>		/* kmmio_handler, ...		*/
 #include <linux/perf_event.h>		/* perf_sw_event		*/
+#include <linux/hugetlb.h>		/* hstate_index_to_shift	*/
 
 #include <asm/traps.h>			/* dotraplinkage, ...		*/
 #include <asm/pgalloc.h>		/* pgd_*(), ...			*/
@@ -160,15 +161,20 @@ is_prefetch(struct pt_regs *regs, unsigned long error_code, unsigned long addr)
 
 static void
 force_sig_info_fault(int si_signo, int si_code, unsigned long address,
-		     struct task_struct *tsk)
+		     struct task_struct *tsk, int fault)
 {
+	unsigned lsb = 0;
 	siginfo_t info;
 
 	info.si_signo	= si_signo;
 	info.si_errno	= 0;
 	info.si_code	= si_code;
 	info.si_addr	= (void __user *)address;
-	info.si_addr_lsb = si_code == BUS_MCEERR_AR ? PAGE_SHIFT : 0;
+	if (fault & VM_FAULT_HWPOISON_LARGE)
+		lsb = hstate_index_to_shift(VM_FAULT_GET_HINDEX(fault)); 
+	if (fault & VM_FAULT_HWPOISON)
+		lsb = PAGE_SHIFT;
+	info.si_addr_lsb = lsb;
 
 	force_sig_info(si_signo, &info, tsk);
 }
@@ -731,7 +737,7 @@ __bad_area_nosemaphore(struct pt_regs *regs, unsigned long error_code,
 		tsk->thread.error_code	= error_code | (address >= TASK_SIZE);
 		tsk->thread.trap_no	= 14;
 
-		force_sig_info_fault(SIGSEGV, si_code, address, tsk);
+		force_sig_info_fault(SIGSEGV, si_code, address, tsk, 0);
 
 		return;
 	}
@@ -816,14 +822,14 @@ do_sigbus(struct pt_regs *regs, unsigned long error_code, unsigned long address,
 	tsk->thread.trap_no	= 14;
 
 #ifdef CONFIG_MEMORY_FAILURE
-	if (fault & VM_FAULT_HWPOISON) {
+	if (fault & (VM_FAULT_HWPOISON|VM_FAULT_HWPOISON_LARGE)) {
 		printk(KERN_ERR
 	"MCE: Killing %s:%d due to hardware memory corruption fault at %lx\n",
 			tsk->comm, tsk->pid, address);
 		code = BUS_MCEERR_AR;
 	}
 #endif
-	force_sig_info_fault(SIGBUS, code, address, tsk);
+	force_sig_info_fault(SIGBUS, code, address, tsk, fault);
 }
 
 static noinline void
@@ -833,7 +839,8 @@ mm_fault_error(struct pt_regs *regs, unsigned long error_code,
 	if (fault & VM_FAULT_OOM) {
 		out_of_memory(regs, error_code, address);
 	} else {
-		if (fault & (VM_FAULT_SIGBUS|VM_FAULT_HWPOISON))
+		if (fault & (VM_FAULT_SIGBUS|VM_FAULT_HWPOISON|
+			     VM_FAULT_HWPOISON_LARGE))
 			do_sigbus(regs, error_code, address, fault);
 		else
 			BUG();
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
