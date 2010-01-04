Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3E10A6005A4
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 15:49:46 -0500 (EST)
Message-Id: <20100104182813.936315444@chello.nl>
References: <20100104182429.833180340@chello.nl>
Date: Mon, 04 Jan 2010 19:24:37 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 8/8] mm: Optimize pte_map_lock()
Content-Disposition: inline; filename=mm-foo-11.patch
Sender: owner-linux-mm@kvack.org
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, cl@linux-foundation.org, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

If we ensure the pagetable invariance by also guarding against unmap,
we can skip part of the pagetable walk by validating the vma early.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 mm/memory.c |   58 ++++++++++++++++++++++++++++++++++++----------------------
 1 file changed, 36 insertions(+), 22 deletions(-)

Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -956,6 +956,7 @@ static unsigned long unmap_page_range(st
 		details = NULL;
 
 	BUG_ON(addr >= end);
+	write_seqcount_begin(&vma->vm_sequence);
 	mem_cgroup_uncharge_start();
 	tlb_start_vma(tlb, vma);
 	pgd = pgd_offset(vma->vm_mm, addr);
@@ -970,6 +971,7 @@ static unsigned long unmap_page_range(st
 	} while (pgd++, addr = next, (addr != end && *zap_work > 0));
 	tlb_end_vma(tlb, vma);
 	mem_cgroup_uncharge_end();
+	write_seqcount_end(&vma->vm_sequence);
 
 	return addr;
 }
@@ -1961,9 +1963,6 @@ static int pte_map_lock(struct mm_struct
 		unsigned long address, pmd_t *pmd, unsigned int flags,
 		unsigned int seq, pte_t **ptep, spinlock_t **ptlp)
 {
-	pgd_t *pgd;
-	pud_t *pud;
-
 	if (!(flags & FAULT_FLAG_SPECULATIVE)) {
 		*ptep = pte_offset_map_lock(mm, pmd, address, ptlp);
 		return 1;
@@ -1972,19 +1971,7 @@ static int pte_map_lock(struct mm_struct
 again:
 	pin_page_tables();
 
-	pgd = pgd_offset(mm, address);
-	if (pgd_none(*pgd) || unlikely(pgd_bad(*pgd)))
-		goto out;
-
-	pud = pud_offset(pgd, address);
-	if (pud_none(*pud) || unlikely(pud_bad(*pud)))
-		goto out;
-
-	pmd = pmd_offset(pud, address);
-	if (pmd_none(*pmd) || unlikely(pmd_bad(*pmd)))
-		goto out;
-
-	if (pmd_huge(*pmd))
+	if (vma_is_dead(vma, seq))
 		goto out;
 
 	*ptlp = pte_lockptr(mm, pmd);
@@ -1998,7 +1985,7 @@ again:
 	if (!*ptep)
 		goto out;
 
-	if (vma && vma_is_dead(vma, seq))
+	if (vma_is_dead(vma, seq))
 		goto unlock;
 
 	unpin_page_tables();
@@ -3115,13 +3102,14 @@ int handle_mm_fault(struct mm_struct *mm
 int handle_speculative_fault(struct mm_struct *mm, unsigned long address,
 		unsigned int flags)
 {
-	pmd_t *pmd = NULL;
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
 	pte_t *pte, entry;
 	spinlock_t *ptl;
 	struct vm_area_struct *vma;
 	unsigned int seq;
-	int ret = VM_FAULT_RETRY;
-	int dead;
+	int dead, ret = VM_FAULT_RETRY;
 
 	__set_current_state(TASK_RUNNING);
 	flags |= FAULT_FLAG_SPECULATIVE;
@@ -3129,8 +3117,31 @@ int handle_speculative_fault(struct mm_s
 	count_vm_event(PGFAULT);
 
 	rcu_read_lock();
-	if (!pte_map_lock(mm, NULL, address, pmd, flags, 0, &pte, &ptl))
-		goto out_unlock;
+again:
+	pin_page_tables();
+
+	pgd = pgd_offset(mm, address);
+	if (pgd_none(*pgd) || unlikely(pgd_bad(*pgd)))
+		goto out;
+
+	pud = pud_offset(pgd, address);
+	if (pud_none(*pud) || unlikely(pud_bad(*pud)))
+		goto out;
+
+	pmd = pmd_offset(pud, address);
+	if (pmd_none(*pmd) || unlikely(pmd_bad(*pmd)))
+		goto out;
+
+	if (pmd_huge(*pmd))
+		goto out;
+
+	ptl = pte_lockptr(mm, pmd);
+	pte = pte_offset_map(pmd, address);
+	if (!spin_trylock(ptl)) {
+		pte_unmap(pte);
+		unpin_page_tables();
+		goto again;
+	}
 
 	vma = find_vma(mm, address);
 
@@ -3156,6 +3167,7 @@ int handle_speculative_fault(struct mm_s
 	entry = *pte;
 
 	pte_unmap_unlock(pte, ptl);
+	unpin_page_tables();
 
 	ret = handle_pte_fault(mm, vma, address, entry, pmd, flags, seq);
 
@@ -3165,6 +3177,8 @@ out_unlock:
 
 out_unmap:
 	pte_unmap_unlock(pte, ptl);
+out:
+	unpin_page_tables();
 	goto out_unlock;
 }
 

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
