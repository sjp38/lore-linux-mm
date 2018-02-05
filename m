Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 97A926B002A
	for <linux-mm@kvack.org>; Sun,  4 Feb 2018 20:28:07 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id 3so7801164pla.1
        for <linux-mm@kvack.org>; Sun, 04 Feb 2018 17:28:07 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a1-v6si1803614pln.399.2018.02.04.17.28.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 04 Feb 2018 17:28:06 -0800 (PST)
From: Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 27/64] arch/{x86,sh,ppc}: teach bad_area() about range locking
Date: Mon,  5 Feb 2018 02:27:17 +0100
Message-Id: <20180205012754.23615-28-dbueso@wotan.suse.de>
In-Reply-To: <20180205012754.23615-1-dbueso@wotan.suse.de>
References: <20180205012754.23615-1-dbueso@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mingo@kernel.org
Cc: peterz@infradead.org, ldufour@linux.vnet.ibm.com, jack@suse.cz, mhocko@kernel.org, kirill.shutemov@linux.intel.com, mawilcox@microsoft.com, mgorman@techsingularity.net, dave@stgolabs.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>

From: Davidlohr Bueso <dave@stgolabs.net>

Such architectures will drop the mmap_sem inside __bad_area(),
which in turn calls bad_area_nosemaphore(). The rest of the
archs will implement this logic within do_page_fault(), so
they remain unchanged as we already have the mmrange.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 arch/powerpc/mm/fault.c | 32 +++++++++++++++++---------------
 arch/sh/mm/fault.c      | 47 ++++++++++++++++++++++++++---------------------
 arch/x86/mm/fault.c     | 35 ++++++++++++++++++++---------------
 3 files changed, 63 insertions(+), 51 deletions(-)

diff --git a/arch/powerpc/mm/fault.c b/arch/powerpc/mm/fault.c
index d562dc88687d..80e4cf0e4c3b 100644
--- a/arch/powerpc/mm/fault.c
+++ b/arch/powerpc/mm/fault.c
@@ -129,7 +129,7 @@ static noinline int bad_area_nosemaphore(struct pt_regs *regs, unsigned long add
 }
 
 static int __bad_area(struct pt_regs *regs, unsigned long address, int si_code,
-			int pkey)
+		      int pkey, struct range_lock *mmrange)
 {
 	struct mm_struct *mm = current->mm;
 
@@ -137,14 +137,15 @@ static int __bad_area(struct pt_regs *regs, unsigned long address, int si_code,
 	 * Something tried to access memory that isn't in our memory map..
 	 * Fix it, but check if it's kernel or user first..
 	 */
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, mmrange);
 
 	return __bad_area_nosemaphore(regs, address, si_code, pkey);
 }
 
-static noinline int bad_area(struct pt_regs *regs, unsigned long address)
+static noinline int bad_area(struct pt_regs *regs, unsigned long address,
+			     struct range_lock *mmrange)
 {
-	return __bad_area(regs, address, SEGV_MAPERR, 0);
+	return __bad_area(regs, address, SEGV_MAPERR, 0, mmrange);
 }
 
 static int bad_key_fault_exception(struct pt_regs *regs, unsigned long address,
@@ -153,9 +154,10 @@ static int bad_key_fault_exception(struct pt_regs *regs, unsigned long address,
 	return __bad_area_nosemaphore(regs, address, SEGV_PKUERR, pkey);
 }
 
-static noinline int bad_access(struct pt_regs *regs, unsigned long address)
+static noinline int bad_access(struct pt_regs *regs, unsigned long address,
+			       struct range_lock *mmrange)
 {
-	return __bad_area(regs, address, SEGV_ACCERR, 0);
+	return __bad_area(regs, address, SEGV_ACCERR, 0, mmrange);
 }
 
 static int do_sigbus(struct pt_regs *regs, unsigned long address,
@@ -475,12 +477,12 @@ static int __do_page_fault(struct pt_regs *regs, unsigned long address,
 	 * source.  If this is invalid we can skip the address space check,
 	 * thus avoiding the deadlock.
 	 */
-	if (unlikely(!down_read_trylock(&mm->mmap_sem))) {
+	if (unlikely(!mm_read_trylock(mm, &mmrange))) {
 		if (!is_user && !search_exception_tables(regs->nip))
 			return bad_area_nosemaphore(regs, address);
 
 retry:
-		down_read(&mm->mmap_sem);
+		mm_read_lock(mm, &mmrange);
 	} else {
 		/*
 		 * The above down_read_trylock() might have succeeded in
@@ -492,23 +494,23 @@ static int __do_page_fault(struct pt_regs *regs, unsigned long address,
 
 	vma = find_vma(mm, address);
 	if (unlikely(!vma))
-		return bad_area(regs, address);
+		return bad_area(regs, address, &mmrange);
 	if (likely(vma->vm_start <= address))
 		goto good_area;
 	if (unlikely(!(vma->vm_flags & VM_GROWSDOWN)))
-		return bad_area(regs, address);
+		return bad_area(regs, address, &mmrange);
 
 	/* The stack is being expanded, check if it's valid */
 	if (unlikely(bad_stack_expansion(regs, address, vma, store_update_sp)))
-		return bad_area(regs, address);
+		return bad_area(regs, address, &mmrange);
 
 	/* Try to expand it */
 	if (unlikely(expand_stack(vma, address)))
-		return bad_area(regs, address);
+		return bad_area(regs, address, &mmrange);
 
 good_area:
 	if (unlikely(access_error(is_write, is_exec, vma)))
-		return bad_access(regs, address);
+		return bad_access(regs, address, &mmrange);
 
 	/*
 	 * If for any reason at all we couldn't handle the fault,
@@ -535,7 +537,7 @@ static int __do_page_fault(struct pt_regs *regs, unsigned long address,
 		int pkey = vma_pkey(vma);
 
 		if (likely(pkey)) {
-			up_read(&mm->mmap_sem);
+			mm_read_unlock(mm, &mmrange);
 			return bad_key_fault_exception(regs, address, pkey);
 		}
 	}
@@ -567,7 +569,7 @@ static int __do_page_fault(struct pt_regs *regs, unsigned long address,
 		return is_user ? 0 : SIGBUS;
 	}
 
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm, &mmrange);
 
 	if (unlikely(fault & VM_FAULT_ERROR))
 		return mm_fault_error(regs, address, fault);
diff --git a/arch/sh/mm/fault.c b/arch/sh/mm/fault.c
index d36106564728..a9f75dc1abb3 100644
--- a/arch/sh/mm/fault.c
+++ b/arch/sh/mm/fault.c
@@ -277,7 +277,8 @@ bad_area_nosemaphore(struct pt_regs *regs, unsigned long error_code,
 
 static void
 __bad_area(struct pt_regs *regs, unsigned long error_code,
-	   unsigned long address, int si_code)
+	   unsigned long address, int si_code,
+	   struct range_lock *mmrange)
 {
 	struct mm_struct *mm = current->mm;
 
@@ -285,31 +286,34 @@ __bad_area(struct pt_regs *regs, unsigned long error_code,
 	 * Something tried to access memory that isn't in our memory map..
 	 * Fix it, but check if it's kernel or user first..
 	 */
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, mmrange);
 
 	__bad_area_nosemaphore(regs, error_code, address, si_code);
 }
 
 static noinline void
-bad_area(struct pt_regs *regs, unsigned long error_code, unsigned long address)
+bad_area(struct pt_regs *regs, unsigned long error_code, unsigned long address,
+	 struct range_lock *mmrange)
 {
-	__bad_area(regs, error_code, address, SEGV_MAPERR);
+	__bad_area(regs, error_code, address, SEGV_MAPERR, mmrange);
 }
 
 static noinline void
 bad_area_access_error(struct pt_regs *regs, unsigned long error_code,
-		      unsigned long address)
+		      unsigned long address,
+		      struct range_lock *mmrange)
 {
-	__bad_area(regs, error_code, address, SEGV_ACCERR);
+	__bad_area(regs, error_code, address, SEGV_ACCERR, mmrange);
 }
 
 static void
-do_sigbus(struct pt_regs *regs, unsigned long error_code, unsigned long address)
+do_sigbus(struct pt_regs *regs, unsigned long error_code, unsigned long address,
+	  struct range_lock *mmrange)
 {
 	struct task_struct *tsk = current;
 	struct mm_struct *mm = tsk->mm;
 
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, mmrange);
 
 	/* Kernel mode? Handle exceptions or die: */
 	if (!user_mode(regs))
@@ -320,7 +324,8 @@ do_sigbus(struct pt_regs *regs, unsigned long error_code, unsigned long address)
 
 static noinline int
 mm_fault_error(struct pt_regs *regs, unsigned long error_code,
-	       unsigned long address, unsigned int fault)
+	       unsigned long address, unsigned int fault,
+	       struct range_lock *mmrange)
 {
 	/*
 	 * Pagefault was interrupted by SIGKILL. We have no reason to
@@ -328,7 +333,7 @@ mm_fault_error(struct pt_regs *regs, unsigned long error_code,
 	 */
 	if (fatal_signal_pending(current)) {
 		if (!(fault & VM_FAULT_RETRY))
-			up_read(&current->mm->mmap_sem);
+			mm_read_unlock(current->mm, mmrange);
 		if (!user_mode(regs))
 			no_context(regs, error_code, address);
 		return 1;
@@ -340,11 +345,11 @@ mm_fault_error(struct pt_regs *regs, unsigned long error_code,
 	if (fault & VM_FAULT_OOM) {
 		/* Kernel mode? Handle exceptions or die: */
 		if (!user_mode(regs)) {
-			up_read(&current->mm->mmap_sem);
+			mm_read_unlock(current->mm, mmrange);
 			no_context(regs, error_code, address);
 			return 1;
 		}
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm, mmrange);
 
 		/*
 		 * We ran out of memory, call the OOM killer, and return the
@@ -354,9 +359,9 @@ mm_fault_error(struct pt_regs *regs, unsigned long error_code,
 		pagefault_out_of_memory();
 	} else {
 		if (fault & VM_FAULT_SIGBUS)
-			do_sigbus(regs, error_code, address);
+			do_sigbus(regs, error_code, address, mmrange);
 		else if (fault & VM_FAULT_SIGSEGV)
-			bad_area(regs, error_code, address);
+			bad_area(regs, error_code, address, mmrange);
 		else
 			BUG();
 	}
@@ -449,21 +454,21 @@ asmlinkage void __kprobes do_page_fault(struct pt_regs *regs,
 	}
 
 retry:
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 
 	vma = find_vma(mm, address);
 	if (unlikely(!vma)) {
-		bad_area(regs, error_code, address);
+		bad_area(regs, error_code, address, &mmrange);
 		return;
 	}
 	if (likely(vma->vm_start <= address))
 		goto good_area;
 	if (unlikely(!(vma->vm_flags & VM_GROWSDOWN))) {
-		bad_area(regs, error_code, address);
+		bad_area(regs, error_code, address, &mmrange);
 		return;
 	}
 	if (unlikely(expand_stack(vma, address))) {
-		bad_area(regs, error_code, address);
+		bad_area(regs, error_code, address, &mmrange);
 		return;
 	}
 
@@ -473,7 +478,7 @@ asmlinkage void __kprobes do_page_fault(struct pt_regs *regs,
 	 */
 good_area:
 	if (unlikely(access_error(error_code, vma))) {
-		bad_area_access_error(regs, error_code, address);
+		bad_area_access_error(regs, error_code, address, &mmrange);
 		return;
 	}
 
@@ -492,7 +497,7 @@ asmlinkage void __kprobes do_page_fault(struct pt_regs *regs,
 	fault = handle_mm_fault(vma, address, flags, &mmrange);
 
 	if (unlikely(fault & (VM_FAULT_RETRY | VM_FAULT_ERROR)))
-		if (mm_fault_error(regs, error_code, address, fault))
+		if (mm_fault_error(regs, error_code, address, fault, &mmrange))
 			return;
 
 	if (flags & FAULT_FLAG_ALLOW_RETRY) {
@@ -518,5 +523,5 @@ asmlinkage void __kprobes do_page_fault(struct pt_regs *regs,
 		}
 	}
 
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 }
diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 93f1b8d4c88e..87bdcb26a907 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -937,7 +937,8 @@ bad_area_nosemaphore(struct pt_regs *regs, unsigned long error_code,
 
 static void
 __bad_area(struct pt_regs *regs, unsigned long error_code,
-	   unsigned long address,  struct vm_area_struct *vma, int si_code)
+	   unsigned long address,  struct vm_area_struct *vma, int si_code,
+	   struct range_lock *mmrange)
 {
 	struct mm_struct *mm = current->mm;
 	u32 pkey;
@@ -949,16 +950,17 @@ __bad_area(struct pt_regs *regs, unsigned long error_code,
 	 * Something tried to access memory that isn't in our memory map..
 	 * Fix it, but check if it's kernel or user first..
 	 */
-	up_read(&mm->mmap_sem);
+        mm_read_unlock(mm, mmrange);
 
 	__bad_area_nosemaphore(regs, error_code, address,
 			       (vma) ? &pkey : NULL, si_code);
 }
 
 static noinline void
-bad_area(struct pt_regs *regs, unsigned long error_code, unsigned long address)
+bad_area(struct pt_regs *regs, unsigned long error_code, unsigned long address,
+	 struct range_lock *mmrange)
 {
-	__bad_area(regs, error_code, address, NULL, SEGV_MAPERR);
+	__bad_area(regs, error_code, address, NULL, SEGV_MAPERR, mmrange);
 }
 
 static inline bool bad_area_access_from_pkeys(unsigned long error_code,
@@ -980,7 +982,8 @@ static inline bool bad_area_access_from_pkeys(unsigned long error_code,
 
 static noinline void
 bad_area_access_error(struct pt_regs *regs, unsigned long error_code,
-		      unsigned long address, struct vm_area_struct *vma)
+		      unsigned long address, struct vm_area_struct *vma,
+		      struct range_lock *mmrange)
 {
 	/*
 	 * This OSPKE check is not strictly necessary at runtime.
@@ -988,9 +991,11 @@ bad_area_access_error(struct pt_regs *regs, unsigned long error_code,
 	 * if pkeys are compiled out.
 	 */
 	if (bad_area_access_from_pkeys(error_code, vma))
-		__bad_area(regs, error_code, address, vma, SEGV_PKUERR);
+		__bad_area(regs, error_code, address, vma, SEGV_PKUERR,
+			   mmrange);
 	else
-		__bad_area(regs, error_code, address, vma, SEGV_ACCERR);
+		__bad_area(regs, error_code, address, vma, SEGV_ACCERR,
+			   mmrange);
 }
 
 static void
@@ -1353,14 +1358,14 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
 	 * validate the source. If this is invalid we can skip the address
 	 * space check, thus avoiding the deadlock:
 	 */
-	if (unlikely(!down_read_trylock(&mm->mmap_sem))) {
+	if (unlikely(!mm_read_trylock(mm, &mmrange))) {
 		if (!(error_code & X86_PF_USER) &&
 		    !search_exception_tables(regs->ip)) {
 			bad_area_nosemaphore(regs, error_code, address, NULL);
 			return;
 		}
 retry:
-		down_read(&mm->mmap_sem);
+	        mm_read_lock(mm, &mmrange);
 	} else {
 		/*
 		 * The above down_read_trylock() might have succeeded in
@@ -1372,13 +1377,13 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
 
 	vma = find_vma(mm, address);
 	if (unlikely(!vma)) {
-		bad_area(regs, error_code, address);
+		bad_area(regs, error_code, address, &mmrange);
 		return;
 	}
 	if (likely(vma->vm_start <= address))
 		goto good_area;
 	if (unlikely(!(vma->vm_flags & VM_GROWSDOWN))) {
-		bad_area(regs, error_code, address);
+		bad_area(regs, error_code, address, &mmrange);
 		return;
 	}
 	if (error_code & X86_PF_USER) {
@@ -1389,12 +1394,12 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
 		 * 32 pointers and then decrements %sp by 65535.)
 		 */
 		if (unlikely(address + 65536 + 32 * sizeof(unsigned long) < regs->sp)) {
-			bad_area(regs, error_code, address);
+			bad_area(regs, error_code, address, &mmrange);
 			return;
 		}
 	}
 	if (unlikely(expand_stack(vma, address))) {
-		bad_area(regs, error_code, address);
+		bad_area(regs, error_code, address, &mmrange);
 		return;
 	}
 
@@ -1404,7 +1409,7 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
 	 */
 good_area:
 	if (unlikely(access_error(error_code, vma))) {
-		bad_area_access_error(regs, error_code, address, vma);
+		bad_area_access_error(regs, error_code, address, vma, &mmrange);
 		return;
 	}
 
@@ -1450,7 +1455,7 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
 		return;
 	}
 
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		mm_fault_error(regs, error_code, address, &pkey, fault);
 		return;
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
