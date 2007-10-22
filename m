Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id l9MAi1LE016188
	for <linux-mm@kvack.org>; Mon, 22 Oct 2007 20:44:01 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9MAi2JZ1724478
	for <linux-mm@kvack.org>; Mon, 22 Oct 2007 20:44:02 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9MAhlql010149
	for <linux-mm@kvack.org>; Mon, 22 Oct 2007 20:43:47 +1000
Message-Id: <20071022104531.235851166@linux.vnet.ibm.com>>
References: <20071022104518.985992030@linux.vnet.ibm.com>>
Date: Mon, 22 Oct 2007 16:15:25 +0530
From: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
Subject: [PATCH/RFC 6/9] x86_64: rcu vma lookups for faults
Content-Disposition: inline; filename=6_fault-x86_64.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Alexis Bruemmer <alexisb@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

---
 arch/x86_64/mm/fault.c |   36 +++++++++++++++++++++++++-----------
 1 file changed, 25 insertions(+), 11 deletions(-)

--- linux-2.6.23-rc6.orig/arch/x86_64/mm/fault.c
+++ linux-2.6.23-rc6/arch/x86_64/mm/fault.c
@@ -310,10 +310,10 @@ asmlinkage void __kprobes do_page_fault(
 	int write, fault;
 	unsigned long flags;
 	siginfo_t info;
+	int locked = 0;
 
 	tsk = current;
 	mm = tsk->mm;
-	prefetchw(&mm->mmap_sem);
 
 	/* get the address */
 	address = read_cr2();
@@ -390,14 +390,14 @@ asmlinkage void __kprobes do_page_fault(
 	 * source.  If this is invalid we can skip the address space check,
 	 * thus avoiding the deadlock.
 	 */
-	if (!down_read_trylock(&mm->mmap_sem)) {
-		if ((error_code & PF_USER) == 0 &&
-		    !search_exception_tables(regs->rip))
-			goto bad_area_nosemaphore;
+
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
 	if (likely(vma->vm_start <= address))
@@ -411,6 +411,11 @@ asmlinkage void __kprobes do_page_fault(
 		if (address + 65536 + 32 * sizeof(unsigned long) < regs->rsp)
 			goto bad_area;
 	}
+	if (!locked) {
+		put_vma(vma);
+		locked = 1;
+		goto again;
+	}
 	if (expand_stack(vma, address))
 		goto bad_area;
 /*
@@ -418,6 +423,11 @@ asmlinkage void __kprobes do_page_fault(
  * we can handle it..
  */
 good_area:
+	if (locked) {
+		up_read(&mm->mmap_sem);
+		locked = 0;
+	}
+
 	info.si_code = SEGV_ACCERR;
 	write = 0;
 	switch (error_code & (PF_PROT|PF_WRITE)) {
@@ -452,7 +462,7 @@ good_area:
 		tsk->maj_flt++;
 	else
 		tsk->min_flt++;
-	up_read(&mm->mmap_sem);
+	put_vma(vma);
 	return;
 
 /*
@@ -460,7 +470,11 @@ good_area:
  * Fix it, but check if it's kernel or user first..
  */
 bad_area:
-	up_read(&mm->mmap_sem);
+	if (locked) {
+		up_read(&mm->mmap_sem);
+		locked = 0;
+	}
+	put_vma(vma);
 
 bad_area_nosemaphore:
 	/* User mode accesses just cause a SIGSEGV */
@@ -552,7 +566,7 @@ no_context:
  * us unable to handle the page fault gracefully.
  */
 out_of_memory:
-	up_read(&mm->mmap_sem);
+	put_vma(vma);
 	if (is_init(current)) {
 		yield();
 		goto again;
@@ -563,7 +577,7 @@ out_of_memory:
 	goto no_context;
 
 do_sigbus:
-	up_read(&mm->mmap_sem);
+	put_vma(vma);
 
 	/* Kernel mode? Handle exceptions or die */
 	if (!(error_code & PF_USER))

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
