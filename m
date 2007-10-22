Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id l9MAj8aP017406
	for <linux-mm@kvack.org>; Mon, 22 Oct 2007 20:45:09 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9MAlT5X274892
	for <linux-mm@kvack.org>; Mon, 22 Oct 2007 20:47:29 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9MAhsa3017392
	for <linux-mm@kvack.org>; Mon, 22 Oct 2007 20:43:54 +1000
Message-Id: <20071022104531.394323390@linux.vnet.ibm.com>>
References: <20071022104518.985992030@linux.vnet.ibm.com>>
Date: Mon, 22 Oct 2007 16:15:26 +0530
From: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
Subject: [PATCH/RFC 7/9] Add page fault code for PPC64 path
Content-Disposition: inline; filename=7_fault-powerpc.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Alexis Bruemmer <alexisb@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

---
 arch/powerpc/mm/fault.c |   44 +++++++++++++++++++++++++++++++++-----------
 1 file changed, 33 insertions(+), 11 deletions(-)

--- linux-2.6.23-rc8.orig/arch/powerpc/mm/fault.c
+++ linux-2.6.23-rc8/arch/powerpc/mm/fault.c
@@ -148,6 +148,7 @@ int __kprobes do_page_fault(struct pt_re
 	int is_write = 0, ret;
 	int trap = TRAP(regs);
  	int is_exec = trap == 0x400;
+	int locked = 0;
 
 #if !(defined(CONFIG_4xx) || defined(CONFIG_BOOKE))
 	/*
@@ -211,14 +212,22 @@ int __kprobes do_page_fault(struct pt_re
 	 * source.  If this is invalid we can skip the address space check,
 	 * thus avoiding the deadlock.
 	 */
-	if (!down_read_trylock(&mm->mmap_sem)) {
-		if (!user_mode(regs) && !search_exception_tables(regs->nip))
-			goto bad_area_nosemaphore;
-
+//	if (!down_read_trylock(&mm->mmap_sem)) {
+//		if (!user_mode(regs) && !search_exception_tables(regs->nip))
+//			goto bad_area_nosemaphore;
+//
+//		down_read(&mm->mmap_sem);
+//	}
+
+again:
+	if (likely(!locked)) {
+		vma = __find_get_vma(mm, address, &locked);
+	} else {
 		down_read(&mm->mmap_sem);
-	}
+		vma = find_vma(mm, address);
+		get_vma(vma);
+	}
 
-	vma = find_vma(mm, address);
 	if (!vma)
 		goto bad_area;
 	if (vma->vm_start <= address)
@@ -257,10 +266,19 @@ int __kprobes do_page_fault(struct pt_re
 		    && (!user_mode(regs) || !store_updates_sp(regs)))
 			goto bad_area;
 	}
+	if (!locked) {
+		put_vma(vma);
+		locked = 1;
+		goto again;
+	}
 	if (expand_stack(vma, address))
 		goto bad_area;
 
 good_area:
+	if (locked) {
+		up_read(&mm->mmap_sem);
+		locked = 0;
+	}
 	code = SEGV_ACCERR;
 #if defined(CONFIG_6xx)
 	if (error_code & 0x95700000)
@@ -311,7 +329,7 @@ good_area:
 				pte_update(ptep, 0, _PAGE_HWEXEC);
 				_tlbie(address);
 				pte_unmap_unlock(ptep, ptl);
-				up_read(&mm->mmap_sem);
+				put_vma(vma);
 				return 0;
 			}
 			pte_unmap_unlock(ptep, ptl);
@@ -348,11 +366,15 @@ good_area:
 		current->maj_flt++;
 	else
 		current->min_flt++;
-	up_read(&mm->mmap_sem);
+	put_vma(vma);
 	return 0;
 
 bad_area:
-	up_read(&mm->mmap_sem);
+	if (locked) {
+		up_read(&mm->mmap_sem);
+		locked = 0;
+	}
+	put_vma(vma);
 
 bad_area_nosemaphore:
 	/* User mode accesses cause a SIGSEGV */
@@ -374,7 +396,7 @@ bad_area_nosemaphore:
  * us unable to handle the page fault gracefully.
  */
 out_of_memory:
-	up_read(&mm->mmap_sem);
+	put_vma(vma);
 	if (is_init(current)) {
 		yield();
 		down_read(&mm->mmap_sem);
@@ -386,7 +408,7 @@ out_of_memory:
 	return SIGKILL;
 
 do_sigbus:
-	up_read(&mm->mmap_sem);
+	put_vma(vma);
 	if (user_mode(regs)) {
 		info.si_signo = SIGBUS;
 		info.si_errno = 0;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
