Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id F2AA16B0038
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 08:25:53 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r202so3843495wmd.1
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 05:25:53 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 12si9530149wmg.56.2017.10.03.05.25.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Oct 2017 05:25:52 -0700 (PDT)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 4.9 55/64] x86/mm: Fix fault error path using unsafe vma pointer
Date: Tue,  3 Oct 2017 14:23:47 +0200
Message-Id: <20171003114231.611407056@linuxfoundation.org>
In-Reply-To: <20171003114228.884821129@linuxfoundation.org>
References: <20171003114228.884821129@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, Laurent Dufour <ldufour@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, Dave Hansen <dave.hansen@linux.intel.com>

4.9-stable review patch.  If anyone has any objections, please let me know.

------------------

From: Laurent Dufour <ldufour@linux.vnet.ibm.com>

commit a3c4fb7c9c2ebfd50b8c60f6c069932bb319bc37 upstream.

commit 7b2d0dbac489 ("x86/mm/pkeys: Pass VMA down in to fault signal
generation code") passes down a vma pointer to the error path, but that is
done once the mmap_sem is released when calling mm_fault_error() from
__do_page_fault().

This is dangerous as the vma structure is no more safe to be used once the
mmap_sem has been released. As only the protection key value is required in
the error processing, we could just pass down this value.

Fix it by passing a pointer to a protection key value down to the fault
signal generation code. The use of a pointer allows to keep the check
generating a warning message in fill_sig_info_pkey() when the vma was not
known. If the pointer is valid, the protection value can be accessed by
deferencing the pointer.

[ tglx: Made *pkey u32 as that's the type which is passed in siginfo ]

Fixes: 7b2d0dbac489 ("x86/mm/pkeys: Pass VMA down in to fault signal generation code")
Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-mm@kvack.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Link: http://lkml.kernel.org/r/1504513935-12742-1-git-send-email-ldufour@linux.vnet.ibm.com
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
 arch/x86/mm/fault.c |   47 ++++++++++++++++++++++++-----------------------
 1 file changed, 24 insertions(+), 23 deletions(-)

--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -191,8 +191,7 @@ is_prefetch(struct pt_regs *regs, unsign
  * 6. T1   : reaches here, sees vma_pkey(vma)=5, when we really
  *	     faulted on a pte with its pkey=4.
  */
-static void fill_sig_info_pkey(int si_code, siginfo_t *info,
-		struct vm_area_struct *vma)
+static void fill_sig_info_pkey(int si_code, siginfo_t *info, u32 *pkey)
 {
 	/* This is effectively an #ifdef */
 	if (!boot_cpu_has(X86_FEATURE_OSPKE))
@@ -208,7 +207,7 @@ static void fill_sig_info_pkey(int si_co
 	 * valid VMA, so we should never reach this without a
 	 * valid VMA.
 	 */
-	if (!vma) {
+	if (!pkey) {
 		WARN_ONCE(1, "PKU fault with no VMA passed in");
 		info->si_pkey = 0;
 		return;
@@ -218,13 +217,12 @@ static void fill_sig_info_pkey(int si_co
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
+		     struct task_struct *tsk, u32 *pkey, int fault)
 {
 	unsigned lsb = 0;
 	siginfo_t info;
@@ -239,7 +237,7 @@ force_sig_info_fault(int si_signo, int s
 		lsb = PAGE_SHIFT;
 	info.si_addr_lsb = lsb;
 
-	fill_sig_info_pkey(si_code, &info, vma);
+	fill_sig_info_pkey(si_code, &info, pkey);
 
 	force_sig_info(si_signo, &info, tsk);
 }
@@ -718,8 +716,6 @@ no_context(struct pt_regs *regs, unsigne
 	struct task_struct *tsk = current;
 	unsigned long flags;
 	int sig;
-	/* No context means no VMA to pass down */
-	struct vm_area_struct *vma = NULL;
 
 	/* Are we prepared to handle this kernel fault? */
 	if (fixup_exception(regs, X86_TRAP_PF)) {
@@ -744,7 +740,7 @@ no_context(struct pt_regs *regs, unsigne
 
 			/* XXX: hwpoison faults will set the wrong code. */
 			force_sig_info_fault(signal, si_code, address,
-					     tsk, vma, 0);
+					     tsk, NULL, 0);
 		}
 
 		/*
@@ -853,8 +849,7 @@ show_signal_msg(struct pt_regs *regs, un
 
 static void
 __bad_area_nosemaphore(struct pt_regs *regs, unsigned long error_code,
-		       unsigned long address, struct vm_area_struct *vma,
-		       int si_code)
+		       unsigned long address, u32 *pkey, int si_code)
 {
 	struct task_struct *tsk = current;
 
@@ -902,7 +897,7 @@ __bad_area_nosemaphore(struct pt_regs *r
 		tsk->thread.error_code	= error_code;
 		tsk->thread.trap_nr	= X86_TRAP_PF;
 
-		force_sig_info_fault(SIGSEGV, si_code, address, tsk, vma, 0);
+		force_sig_info_fault(SIGSEGV, si_code, address, tsk, pkey, 0);
 
 		return;
 	}
@@ -915,9 +910,9 @@ __bad_area_nosemaphore(struct pt_regs *r
 
 static noinline void
 bad_area_nosemaphore(struct pt_regs *regs, unsigned long error_code,
-		     unsigned long address, struct vm_area_struct *vma)
+		     unsigned long address, u32 *pkey)
 {
-	__bad_area_nosemaphore(regs, error_code, address, vma, SEGV_MAPERR);
+	__bad_area_nosemaphore(regs, error_code, address, pkey, SEGV_MAPERR);
 }
 
 static void
@@ -925,6 +920,10 @@ __bad_area(struct pt_regs *regs, unsigne
 	   unsigned long address,  struct vm_area_struct *vma, int si_code)
 {
 	struct mm_struct *mm = current->mm;
+	u32 pkey;
+
+	if (vma)
+		pkey = vma_pkey(vma);
 
 	/*
 	 * Something tried to access memory that isn't in our memory map..
@@ -932,7 +931,8 @@ __bad_area(struct pt_regs *regs, unsigne
 	 */
 	up_read(&mm->mmap_sem);
 
-	__bad_area_nosemaphore(regs, error_code, address, vma, si_code);
+	__bad_area_nosemaphore(regs, error_code, address,
+			       (vma) ? &pkey : NULL, si_code);
 }
 
 static noinline void
@@ -975,7 +975,7 @@ bad_area_access_error(struct pt_regs *re
 
 static void
 do_sigbus(struct pt_regs *regs, unsigned long error_code, unsigned long address,
-	  struct vm_area_struct *vma, unsigned int fault)
+	  u32 *pkey, unsigned int fault)
 {
 	struct task_struct *tsk = current;
 	int code = BUS_ADRERR;
@@ -1002,13 +1002,12 @@ do_sigbus(struct pt_regs *regs, unsigned
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
+	       unsigned long address, u32 *pkey, unsigned int fault)
 {
 	if (fatal_signal_pending(current) && !(error_code & PF_USER)) {
 		no_context(regs, error_code, address, 0, 0);
@@ -1032,9 +1031,9 @@ mm_fault_error(struct pt_regs *regs, uns
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
@@ -1220,6 +1219,7 @@ __do_page_fault(struct pt_regs *regs, un
 	struct mm_struct *mm;
 	int fault, major = 0;
 	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	u32 pkey;
 
 	tsk = current;
 	mm = tsk->mm;
@@ -1420,9 +1420,10 @@ good_area:
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
