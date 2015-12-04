Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 6F2F282F64
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 20:14:51 -0500 (EST)
Received: by pfnn128 with SMTP id n128so17225791pfn.0
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 17:14:51 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id v14si15461881pfi.156.2015.12.03.17.14.41
        for <linux-mm@kvack.org>;
        Thu, 03 Dec 2015 17:14:41 -0800 (PST)
Subject: [PATCH 11/34] x86, pkeys: pass VMA down in to fault signal generation code
From: Dave Hansen <dave@sr71.net>
Date: Thu, 03 Dec 2015 17:14:40 -0800
References: <20151204011424.8A36E365@viggo.jf.intel.com>
In-Reply-To: <20151204011424.8A36E365@viggo.jf.intel.com>
Message-Id: <20151204011440.2E08E11A@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>

During a page fault, we look up the VMA to ensure that the fault
is in a region with a valid mapping.  But, in the top-level page
fault code we don't need the VMA for much else.  Once we have
decided that an access is bad, we are going to send a signal no
matter what and do not need the VMA any more.  So we do not pass
it down in to the signal generation code.

But, for protection keys, we need the VMA.  It tells us *which*
protection key we violated if we get a PF_PK.  So, we need to
pass the VMA down and fill in siginfo->si_pkey.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
---

 b/arch/x86/mm/fault.c |   50 ++++++++++++++++++++++++++++----------------------
 1 file changed, 28 insertions(+), 22 deletions(-)

diff -puN arch/x86/mm/fault.c~pkeys-08-pass-down-vma arch/x86/mm/fault.c
--- a/arch/x86/mm/fault.c~pkeys-08-pass-down-vma	2015-12-03 16:21:22.995551986 -0800
+++ b/arch/x86/mm/fault.c	2015-12-03 16:21:22.998552122 -0800
@@ -171,7 +171,8 @@ is_prefetch(struct pt_regs *regs, unsign
 
 static void
 force_sig_info_fault(int si_signo, int si_code, unsigned long address,
-		     struct task_struct *tsk, int fault)
+		     struct task_struct *tsk, struct vm_area_struct *vma,
+		     int fault)
 {
 	unsigned lsb = 0;
 	siginfo_t info;
@@ -656,6 +657,8 @@ no_context(struct pt_regs *regs, unsigne
 	struct task_struct *tsk = current;
 	unsigned long flags;
 	int sig;
+	/* No context means no VMA to pass down */
+	struct vm_area_struct *vma = NULL;
 
 	/* Are we prepared to handle this kernel fault? */
 	if (fixup_exception(regs)) {
@@ -679,7 +682,8 @@ no_context(struct pt_regs *regs, unsigne
 			tsk->thread.cr2 = address;
 
 			/* XXX: hwpoison faults will set the wrong code. */
-			force_sig_info_fault(signal, si_code, address, tsk, 0);
+			force_sig_info_fault(signal, si_code, address,
+					     tsk, vma, 0);
 		}
 
 		/*
@@ -756,7 +760,8 @@ show_signal_msg(struct pt_regs *regs, un
 
 static void
 __bad_area_nosemaphore(struct pt_regs *regs, unsigned long error_code,
-		       unsigned long address, int si_code)
+		       unsigned long address, struct vm_area_struct *vma,
+		       int si_code)
 {
 	struct task_struct *tsk = current;
 
@@ -799,7 +804,7 @@ __bad_area_nosemaphore(struct pt_regs *r
 		tsk->thread.error_code	= error_code;
 		tsk->thread.trap_nr	= X86_TRAP_PF;
 
-		force_sig_info_fault(SIGSEGV, si_code, address, tsk, 0);
+		force_sig_info_fault(SIGSEGV, si_code, address, tsk, vma, 0);
 
 		return;
 	}
@@ -812,14 +817,14 @@ __bad_area_nosemaphore(struct pt_regs *r
 
 static noinline void
 bad_area_nosemaphore(struct pt_regs *regs, unsigned long error_code,
-		     unsigned long address)
+		     unsigned long address, struct vm_area_struct *vma)
 {
-	__bad_area_nosemaphore(regs, error_code, address, SEGV_MAPERR);
+	__bad_area_nosemaphore(regs, error_code, address, vma, SEGV_MAPERR);
 }
 
 static void
 __bad_area(struct pt_regs *regs, unsigned long error_code,
-	   unsigned long address, int si_code)
+	   unsigned long address,  struct vm_area_struct *vma, int si_code)
 {
 	struct mm_struct *mm = current->mm;
 
@@ -829,25 +834,25 @@ __bad_area(struct pt_regs *regs, unsigne
 	 */
 	up_read(&mm->mmap_sem);
 
-	__bad_area_nosemaphore(regs, error_code, address, si_code);
+	__bad_area_nosemaphore(regs, error_code, address, vma, si_code);
 }
 
 static noinline void
 bad_area(struct pt_regs *regs, unsigned long error_code, unsigned long address)
 {
-	__bad_area(regs, error_code, address, SEGV_MAPERR);
+	__bad_area(regs, error_code, address, NULL, SEGV_MAPERR);
 }
 
 static noinline void
 bad_area_access_error(struct pt_regs *regs, unsigned long error_code,
-		      unsigned long address)
+		      unsigned long address, struct vm_area_struct *vma)
 {
-	__bad_area(regs, error_code, address, SEGV_ACCERR);
+	__bad_area(regs, error_code, address, vma, SEGV_ACCERR);
 }
 
 static void
 do_sigbus(struct pt_regs *regs, unsigned long error_code, unsigned long address,
-	  unsigned int fault)
+	  struct vm_area_struct *vma, unsigned int fault)
 {
 	struct task_struct *tsk = current;
 	int code = BUS_ADRERR;
@@ -874,12 +879,13 @@ do_sigbus(struct pt_regs *regs, unsigned
 		code = BUS_MCEERR_AR;
 	}
 #endif
-	force_sig_info_fault(SIGBUS, code, address, tsk, fault);
+	force_sig_info_fault(SIGBUS, code, address, tsk, vma, fault);
 }
 
 static noinline void
 mm_fault_error(struct pt_regs *regs, unsigned long error_code,
-	       unsigned long address, unsigned int fault)
+	       unsigned long address, struct vm_area_struct *vma,
+	       unsigned int fault)
 {
 	if (fatal_signal_pending(current) && !(error_code & PF_USER)) {
 		no_context(regs, error_code, address, 0, 0);
@@ -903,9 +909,9 @@ mm_fault_error(struct pt_regs *regs, uns
 	} else {
 		if (fault & (VM_FAULT_SIGBUS|VM_FAULT_HWPOISON|
 			     VM_FAULT_HWPOISON_LARGE))
-			do_sigbus(regs, error_code, address, fault);
+			do_sigbus(regs, error_code, address, vma, fault);
 		else if (fault & VM_FAULT_SIGSEGV)
-			bad_area_nosemaphore(regs, error_code, address);
+			bad_area_nosemaphore(regs, error_code, address, vma);
 		else
 			BUG();
 	}
@@ -1119,7 +1125,7 @@ __do_page_fault(struct pt_regs *regs, un
 		 * Don't take the mm semaphore here. If we fixup a prefetch
 		 * fault we could otherwise deadlock:
 		 */
-		bad_area_nosemaphore(regs, error_code, address);
+		bad_area_nosemaphore(regs, error_code, address, NULL);
 
 		return;
 	}
@@ -1132,7 +1138,7 @@ __do_page_fault(struct pt_regs *regs, un
 		pgtable_bad(regs, error_code, address);
 
 	if (unlikely(smap_violation(error_code, regs))) {
-		bad_area_nosemaphore(regs, error_code, address);
+		bad_area_nosemaphore(regs, error_code, address, NULL);
 		return;
 	}
 
@@ -1141,7 +1147,7 @@ __do_page_fault(struct pt_regs *regs, un
 	 * in a region with pagefaults disabled then we must not take the fault
 	 */
 	if (unlikely(faulthandler_disabled() || !mm)) {
-		bad_area_nosemaphore(regs, error_code, address);
+		bad_area_nosemaphore(regs, error_code, address, NULL);
 		return;
 	}
 
@@ -1185,7 +1191,7 @@ __do_page_fault(struct pt_regs *regs, un
 	if (unlikely(!down_read_trylock(&mm->mmap_sem))) {
 		if ((error_code & PF_USER) == 0 &&
 		    !search_exception_tables(regs->ip)) {
-			bad_area_nosemaphore(regs, error_code, address);
+			bad_area_nosemaphore(regs, error_code, address, NULL);
 			return;
 		}
 retry:
@@ -1233,7 +1239,7 @@ retry:
 	 */
 good_area:
 	if (unlikely(access_error(error_code, vma))) {
-		bad_area_access_error(regs, error_code, address);
+		bad_area_access_error(regs, error_code, address, vma);
 		return;
 	}
 
@@ -1271,7 +1277,7 @@ good_area:
 
 	up_read(&mm->mmap_sem);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
-		mm_fault_error(regs, error_code, address, fault);
+		mm_fault_error(regs, error_code, address, vma, fault);
 		return;
 	}
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
