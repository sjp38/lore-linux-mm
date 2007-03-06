Message-Id: <20070306014211.409657000@taijtu.programming.kicks-ass.net>
References: <20070306013815.951032000@taijtu.programming.kicks-ass.net>
Date: Tue, 06 Mar 2007 02:38:19 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 4/5] i386: lockless fault handler
Content-Disposition: inline; filename=fault-i386.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Christoph Lameter <clameter@engr.sgi.com>, "Paul E. McKenney" <paulmck@us.ibm.com>, Nick Piggin <npiggin@suse.de>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Use the new lockless vma lookup in the i386 fault handler.
This avoids the exclusive cacheline access for the mmap_sem.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 arch/i386/mm/fault.c |   34 ++++++----------------------------
 1 file changed, 6 insertions(+), 28 deletions(-)

Index: linux-2.6/arch/i386/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/i386/mm/fault.c
+++ linux-2.6/arch/i386/mm/fault.c
@@ -381,29 +381,7 @@ fastcall void __kprobes do_page_fault(st
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
-		down_read(&mm->mmap_sem);
-	}
-
-	vma = find_vma(mm, address);
+	vma = find_get_vma(mm, address);
 	if (!vma)
 		goto bad_area;
 	if (vma->vm_start <= address)
@@ -473,7 +451,7 @@ good_area:
 		if (bit < 32)
 			tsk->thread.screen_bitmap |= 1 << bit;
 	}
-	up_read(&mm->mmap_sem);
+	put_vma(vma);
 	return;
 
 /*
@@ -481,7 +459,7 @@ good_area:
  * Fix it, but check if it's kernel or user first..
  */
 bad_area:
-	up_read(&mm->mmap_sem);
+	put_vma(vma);
 
 bad_area_nosemaphore:
 	/* User mode accesses just cause a SIGSEGV */
@@ -588,10 +566,10 @@ no_context:
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
@@ -600,7 +578,7 @@ out_of_memory:
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
