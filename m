Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp01.au.ibm.com (8.13.1/8.13.1) with ESMTP id l9MAjdhM032372
	for <linux-mm@kvack.org>; Mon, 22 Oct 2007 20:45:39 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9MAlflA274910
	for <linux-mm@kvack.org>; Mon, 22 Oct 2007 20:47:41 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9MAhoU8003386
	for <linux-mm@kvack.org>; Mon, 22 Oct 2007 20:43:50 +1000
Message-Id: <20071022104531.084439828@linux.vnet.ibm.com>>
References: <20071022104518.985992030@linux.vnet.ibm.com>>
Date: Mon, 22 Oct 2007 16:15:24 +0530
From: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
Subject: [PATCH/RFC 5/9] i386: rcu vma lookups for faults
Content-Disposition: inline; filename=5_fault-i386.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Alexis Bruemmer <alexisb@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Use the new lockless vma lookup in the i386 fault handler.
This avoids the exclusive cacheline access for the mmap_sem.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 arch/i386/mm/fault.c |   56 +++++++++++++++++++++++++++------------------------
 1 file changed, 30 insertions(+), 26 deletions(-)

--- linux-2.6.23-rc6.orig/arch/i386/mm/fault.c
+++ linux-2.6.23-rc6/arch/i386/mm/fault.c
@@ -307,6 +307,7 @@ fastcall void __kprobes do_page_fault(st
 	unsigned long address;
 	int write, si_code;
 	int fault;
+	int locked = 0;
 
 	/* get the address */
         address = read_cr2();
@@ -357,29 +358,14 @@ fastcall void __kprobes do_page_fault(st
 	if (in_atomic() || !mm)
 		goto bad_area_nosemaphore;
 
-	/* When running in the kernel we expect faults to occur only to
-	 * addresses in user space.  All other faults represent errors in the
-	 * kernel and should generate an OOPS.  Unfortunatly, in the case of an
-	 * erroneous fault occurring in a code path which already holds mmap_sem
-	 * we will deadlock attempting to validate the fault against the
-	 * address space.  Luckily the kernel only validly references user
-	 * space from well defined areas of code, which are listed in the
-	 * exceptions table.
-	 *
-	 * As the vast majority of faults will be valid we will only perform
-	 * the source reference check when there is a possibilty of a deadlock.
-	 * Attempt to lock the address space, if we cannot we then validate the
-	 * source.  If this is invalid we can skip the address space check,
-	 * thus avoiding the deadlock.
-	 */
-	if (!down_read_trylock(&mm->mmap_sem)) {
-		if ((error_code & 4) == 0 &&
-		    !search_exception_tables(regs->eip))
-			goto bad_area_nosemaphore;
+again:
+	if (likely(!locked)) {
+		vma = __find_get_vma(mm, address, &locked);
+	} else {
 		down_read(&mm->mmap_sem);
+		vma = find_vma(mm, address);
+		get_vma(vma);
 	}
-
-	vma = find_vma(mm, address);
 	if (!vma)
 		goto bad_area;
 	if (vma->vm_start <= address)
@@ -396,6 +382,15 @@ fastcall void __kprobes do_page_fault(st
 		if (address + 65536 + 32 * sizeof(unsigned long) < regs->esp)
 			goto bad_area;
 	}
+	/*
+	 * expand_stack needs the read lock, hence retry the whole thing
+	 * read locked.
+	 */
+	if (!locked) {
+		put_vma(vma);
+		locked = 1;
+		goto again;
+	}
 	if (expand_stack(vma, address))
 		goto bad_area;
 /*
@@ -403,6 +398,11 @@ fastcall void __kprobes do_page_fault(st
  * we can handle it..
  */
 good_area:
+	if (unlikely(locked)) {
+		up_read(&mm->mmap_sem);
+		locked = 0;
+	}
+
 	si_code = SEGV_ACCERR;
 	write = 0;
 	switch (error_code & 3) {
@@ -447,7 +447,7 @@ good_area:
 		if (bit < 32)
 			tsk->thread.screen_bitmap |= 1 << bit;
 	}
-	up_read(&mm->mmap_sem);
+	put_vma(vma);
 	return;
 
 /*
@@ -455,7 +455,11 @@ good_area:
  * Fix it, but check if it's kernel or user first..
  */
 bad_area:
-	up_read(&mm->mmap_sem);
+	if (unlikely(locked)) {
+		up_read(&mm->mmap_sem);
+		locked = 0;
+	}
+	put_vma(vma);
 
 bad_area_nosemaphore:
 	/* User mode accesses just cause a SIGSEGV */
@@ -590,10 +594,10 @@ no_context:
  * us unable to handle the page fault gracefully.
  */
 out_of_memory:
-	up_read(&mm->mmap_sem);
+	put_vma(vma);
 	if (is_init(tsk)) {
 		yield();
-		down_read(&mm->mmap_sem);
+		vma = find_get_vma(mm, address);
 		goto survive;
 	}
 	printk("VM: killing process %s\n", tsk->comm);
@@ -602,7 +606,7 @@ out_of_memory:
 	goto no_context;
 
 do_sigbus:
-	up_read(&mm->mmap_sem);
+	put_vma(vma);
 
 	/* Kernel mode? Handle exceptions or die */
 	if (!(error_code & 4))

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
