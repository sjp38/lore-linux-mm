Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0A9376B0499
	for <linux-mm@kvack.org>; Mon,  4 Sep 2017 04:32:24 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id k126so11923496qkb.3
        for <linux-mm@kvack.org>; Mon, 04 Sep 2017 01:32:24 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id o22si6625085qtk.120.2017.09.04.01.32.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Sep 2017 01:32:22 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v848T88t033331
	for <linux-mm@kvack.org>; Mon, 4 Sep 2017 04:32:22 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2cs1evw3fu-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 04 Sep 2017 04:32:22 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Mon, 4 Sep 2017 09:32:20 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH] x86/mm: Fix fault error path using unsafe vma pointer
Date: Mon,  4 Sep 2017 10:32:15 +0200
Message-Id: <1504513935-12742-1-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>

The commit 7b2d0dbac489 ("x86/mm/pkeys: Pass VMA down in to fault signal
generation code") pass down a vma pointer to the error path, but that is
done once the mmap_sem is released when calling mm_fault_error() from
__do_page_fault().

This is dangerous as the pointed vma structure is no more safe to be used
once the mmap_sem has been released. As only the protection key value is
required in the error processing, we could just pass down this value.

This patch fixes this by passing a pointer to a protection key value down
to the fault signal generation code. The use of a pointer allows to keep
the check generating a warning message in fill_sig_info_pkey() when the vma
was not known. If the pointer is valid, the protection value can be
accessed by deferencing the pointer.

Fixes: 7b2d0dbac489 ("x86/mm/pkeys: Pass VMA down in to fault signal
generation code")
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 arch/x86/mm/fault.c | 47 ++++++++++++++++++++++++-----------------------
 1 file changed, 24 insertions(+), 23 deletions(-)

diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 2a1fa10c6a98..c18e737c5f9b 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -192,8 +192,7 @@ is_prefetch(struct pt_regs *regs, unsigned long error_code, unsigned long addr)
  * 6. T1   : reaches here, sees vma_pkey(vma)=5, when we really
  *	     faulted on a pte with its pkey=4.
  */
-static void fill_sig_info_pkey(int si_code, siginfo_t *info,
-		struct vm_area_struct *vma)
+static void fill_sig_info_pkey(int si_code, siginfo_t *info, int *pkey)
 {
 	/* This is effectively an #ifdef */
 	if (!boot_cpu_has(X86_FEATURE_OSPKE))
@@ -209,7 +208,7 @@ static void fill_sig_info_pkey(int si_code, siginfo_t *info,
 	 * valid VMA, so we should never reach this without a
 	 * valid VMA.
 	 */
-	if (!vma) {
+	if (!pkey) {
 		WARN_ONCE(1, "PKU fault with no VMA passed in");
 		info->si_pkey = 0;
 		return;
@@ -219,13 +218,12 @@ static void fill_sig_info_pkey(int si_code, siginfo_t *info,
 	 * absolutely guranteed to be 100% accurate because of
 	 * the race explained above.
 	 */
-	info->si_pkey = vma_pkey(vma);
+	info->si_pkey = *pkey;
 }
 
 static void
 force_sig_info_fault(int si_signo, int si_code, unsigned long address,
-		     struct task_struct *tsk, struct vm_area_struct *vma,
-		     int fault)
+		     struct task_struct *tsk, int *pkey, int fault)
 {
 	unsigned lsb = 0;
 	siginfo_t info;
@@ -240,7 +238,7 @@ force_sig_info_fault(int si_signo, int si_code, unsigned long address,
 		lsb = PAGE_SHIFT;
 	info.si_addr_lsb = lsb;
 
-	fill_sig_info_pkey(si_code, &info, vma);
+	fill_sig_info_pkey(si_code, &info, pkey);
 
 	force_sig_info(si_signo, &info, tsk);
 }
@@ -758,8 +756,6 @@ no_context(struct pt_regs *regs, unsigned long error_code,
 	struct task_struct *tsk = current;
 	unsigned long flags;
 	int sig;
-	/* No context means no VMA to pass down */
-	struct vm_area_struct *vma = NULL;
 
 	/* Are we prepared to handle this kernel fault? */
 	if (fixup_exception(regs, X86_TRAP_PF)) {
@@ -784,7 +780,7 @@ no_context(struct pt_regs *regs, unsigned long error_code,
 
 			/* XXX: hwpoison faults will set the wrong code. */
 			force_sig_info_fault(signal, si_code, address,
-					     tsk, vma, 0);
+					     tsk, NULL, 0);
 		}
 
 		/*
@@ -893,8 +889,7 @@ show_signal_msg(struct pt_regs *regs, unsigned long error_code,
 
 static void
 __bad_area_nosemaphore(struct pt_regs *regs, unsigned long error_code,
-		       unsigned long address, struct vm_area_struct *vma,
-		       int si_code)
+		       unsigned long address, int *pkey, int si_code)
 {
 	struct task_struct *tsk = current;
 
@@ -942,7 +937,7 @@ __bad_area_nosemaphore(struct pt_regs *regs, unsigned long error_code,
 		tsk->thread.error_code	= error_code;
 		tsk->thread.trap_nr	= X86_TRAP_PF;
 
-		force_sig_info_fault(SIGSEGV, si_code, address, tsk, vma, 0);
+		force_sig_info_fault(SIGSEGV, si_code, address, tsk, pkey, 0);
 
 		return;
 	}
@@ -955,9 +950,9 @@ __bad_area_nosemaphore(struct pt_regs *regs, unsigned long error_code,
 
 static noinline void
 bad_area_nosemaphore(struct pt_regs *regs, unsigned long error_code,
-		     unsigned long address, struct vm_area_struct *vma)
+		     unsigned long address, int *pkey)
 {
-	__bad_area_nosemaphore(regs, error_code, address, vma, SEGV_MAPERR);
+	__bad_area_nosemaphore(regs, error_code, address, pkey, SEGV_MAPERR);
 }
 
 static void
@@ -965,6 +960,10 @@ __bad_area(struct pt_regs *regs, unsigned long error_code,
 	   unsigned long address,  struct vm_area_struct *vma, int si_code)
 {
 	struct mm_struct *mm = current->mm;
+	int pkey;
+
+	if (vma)
+		pkey = vma_pkey(vma);
 
 	/*
 	 * Something tried to access memory that isn't in our memory map..
@@ -972,7 +971,8 @@ __bad_area(struct pt_regs *regs, unsigned long error_code,
 	 */
 	up_read(&mm->mmap_sem);
 
-	__bad_area_nosemaphore(regs, error_code, address, vma, si_code);
+	__bad_area_nosemaphore(regs, error_code, address,
+			       (vma) ? &pkey : NULL, si_code);
 }
 
 static noinline void
@@ -1015,7 +1015,7 @@ bad_area_access_error(struct pt_regs *regs, unsigned long error_code,
 
 static void
 do_sigbus(struct pt_regs *regs, unsigned long error_code, unsigned long address,
-	  struct vm_area_struct *vma, unsigned int fault)
+	  int *pkey, unsigned int fault)
 {
 	struct task_struct *tsk = current;
 	int code = BUS_ADRERR;
@@ -1042,13 +1042,12 @@ do_sigbus(struct pt_regs *regs, unsigned long error_code, unsigned long address,
 		code = BUS_MCEERR_AR;
 	}
 #endif
-	force_sig_info_fault(SIGBUS, code, address, tsk, vma, fault);
+	force_sig_info_fault(SIGBUS, code, address, tsk, pkey, fault);
 }
 
 static noinline void
 mm_fault_error(struct pt_regs *regs, unsigned long error_code,
-	       unsigned long address, struct vm_area_struct *vma,
-	       unsigned int fault)
+	       unsigned long address, int *pkey, unsigned int fault)
 {
 	if (fatal_signal_pending(current) && !(error_code & PF_USER)) {
 		no_context(regs, error_code, address, 0, 0);
@@ -1072,9 +1071,9 @@ mm_fault_error(struct pt_regs *regs, unsigned long error_code,
 	} else {
 		if (fault & (VM_FAULT_SIGBUS|VM_FAULT_HWPOISON|
 			     VM_FAULT_HWPOISON_LARGE))
-			do_sigbus(regs, error_code, address, vma, fault);
+			do_sigbus(regs, error_code, address, pkey, fault);
 		else if (fault & VM_FAULT_SIGSEGV)
-			bad_area_nosemaphore(regs, error_code, address, vma);
+			bad_area_nosemaphore(regs, error_code, address, pkey);
 		else
 			BUG();
 	}
@@ -1268,6 +1267,7 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
 	struct mm_struct *mm;
 	int fault, major = 0;
 	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	int pkey;
 
 	tsk = current;
 	mm = tsk->mm;
@@ -1468,9 +1468,10 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
 		return;
 	}
 
+	pkey = vma_pkey(vma);
 	up_read(&mm->mmap_sem);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
-		mm_fault_error(regs, error_code, address, vma, fault);
+		mm_fault_error(regs, error_code, address, &pkey, fault);
 		return;
 	}
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
