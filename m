Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 61BA4600068
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 15:49:29 -0500 (EST)
Message-Id: <20100104182813.753545361@chello.nl>
References: <20100104182429.833180340@chello.nl>
Date: Mon, 04 Jan 2010 19:24:35 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 6/8] mm: handle_speculative_fault()
Content-Disposition: inline; filename=mm-foo-8.patch
Sender: owner-linux-mm@kvack.org
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, cl@linux-foundation.org, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Generic speculative fault handler, tries to service a pagefault
without holding mmap_sem.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/mm.h |    2 +
 mm/memory.c        |   59 ++++++++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 60 insertions(+), 1 deletion(-)

Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -1998,7 +1998,7 @@ again:
 	if (!*ptep)
 		goto out;
 
-	if (vma_is_dead(vma, seq))
+	if (vma && vma_is_dead(vma, seq))
 		goto unlock;
 
 	unpin_page_tables();
@@ -3112,6 +3112,63 @@ int handle_mm_fault(struct mm_struct *mm
 	return handle_pte_fault(mm, vma, address, entry, pmd, flags, 0);
 }
 
+int handle_speculative_fault(struct mm_struct *mm, unsigned long address,
+		unsigned int flags)
+{
+	pmd_t *pmd = NULL;
+	pte_t *pte, entry;
+	spinlock_t *ptl;
+	struct vm_area_struct *vma;
+	unsigned int seq;
+	int ret = VM_FAULT_RETRY;
+	int dead;
+
+	__set_current_state(TASK_RUNNING);
+	flags |= FAULT_FLAG_SPECULATIVE;
+
+	count_vm_event(PGFAULT);
+
+	rcu_read_lock();
+	if (!pte_map_lock(mm, NULL, address, pmd, flags, 0, &pte, &ptl))
+		goto out_unlock;
+
+	vma = find_vma(mm, address);
+
+	if (!vma)
+		goto out_unmap;
+
+	dead = RB_EMPTY_NODE(&vma->vm_rb);
+	seq = vma->vm_sequence.sequence;
+	/*
+	 * Matches both the wmb in write_seqcount_begin/end() and
+	 * the wmb in detach_vmas_to_be_unmapped()/__unlink_vma().
+	 */
+	smp_rmb();
+	if (dead || seq & 1)
+		goto out_unmap;
+
+	if (!(vma->vm_end > address && vma->vm_start <= address))
+		goto out_unmap;
+
+	if (read_seqcount_retry(&vma->vm_sequence, seq))
+		goto out_unmap;
+
+	entry = *pte;
+
+	pte_unmap_unlock(pte, ptl);
+
+	ret = handle_pte_fault(mm, vma, address, entry, pmd, flags, seq);
+
+out_unlock:
+	rcu_read_unlock();
+	return ret;
+
+out_unmap:
+	pte_unmap_unlock(pte, ptl);
+	goto out_unlock;
+}
+
+
 #ifndef __PAGETABLE_PUD_FOLDED
 /*
  * Allocate page upper directory.
Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h
+++ linux-2.6/include/linux/mm.h
@@ -829,6 +829,8 @@ int invalidate_inode_page(struct page *p
 #ifdef CONFIG_MMU
 extern int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 			unsigned long address, unsigned int flags);
+extern int handle_speculative_fault(struct mm_struct *mm,
+			unsigned long address, unsigned int flags);
 #else
 static inline int handle_mm_fault(struct mm_struct *mm,
 			struct vm_area_struct *vma, unsigned long address,

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
