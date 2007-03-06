Message-Id: <20070306014211.523201000@taijtu.programming.kicks-ass.net>
References: <20070306013815.951032000@taijtu.programming.kicks-ass.net>
Date: Tue, 06 Mar 2007 02:38:20 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 5/5] x86_64: lockless fault handler
Content-Disposition: inline; filename=fault-x86_64.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Christoph Lameter <clameter@engr.sgi.com>, "Paul E. McKenney" <paulmck@us.ibm.com>, Nick Piggin <npiggin@suse.de>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

avoid taking the rw-sem

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 arch/x86_64/mm/fault.c |   17 +++++------------
 1 file changed, 5 insertions(+), 12 deletions(-)

Index: linux-2.6/arch/x86_64/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/x86_64/mm/fault.c
+++ linux-2.6/arch/x86_64/mm/fault.c
@@ -344,7 +344,6 @@ asmlinkage void __kprobes do_page_fault(
 
 	tsk = current;
 	mm = tsk->mm;
-	prefetchw(&mm->mmap_sem);
 
 	/* get the address */
 	__asm__("movq %%cr2,%0":"=r" (address));
@@ -423,14 +422,8 @@ asmlinkage void __kprobes do_page_fault(
 	 * source.  If this is invalid we can skip the address space check,
 	 * thus avoiding the deadlock.
 	 */
-	if (!down_read_trylock(&mm->mmap_sem)) {
-		if ((error_code & PF_USER) == 0 &&
-		    !search_exception_tables(regs->rip))
-			goto bad_area_nosemaphore;
-		down_read(&mm->mmap_sem);
-	}
 
-	vma = find_vma(mm, address);
+	vma = find_get_vma(mm, address);
 	if (!vma)
 		goto bad_area;
 	if (likely(vma->vm_start <= address))
@@ -486,7 +479,7 @@ good_area:
 		goto out_of_memory;
 	}
 
-	up_read(&mm->mmap_sem);
+	put_vma(vma);
 	return;
 
 /*
@@ -494,7 +487,7 @@ good_area:
  * Fix it, but check if it's kernel or user first..
  */
 bad_area:
-	up_read(&mm->mmap_sem);
+	put_vma(vma);
 
 bad_area_nosemaphore:
 	/* User mode accesses just cause a SIGSEGV */
@@ -579,7 +572,7 @@ no_context:
  * us unable to handle the page fault gracefully.
  */
 out_of_memory:
-	up_read(&mm->mmap_sem);
+	put_vma(vma);
 	if (is_init(current)) {
 		yield();
 		goto again;
@@ -590,7 +583,7 @@ out_of_memory:
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
