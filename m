Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id C86916B0071
	for <linux-mm@kvack.org>; Mon, 20 Oct 2014 18:41:55 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id r10so11592pdi.24
        for <linux-mm@kvack.org>; Mon, 20 Oct 2014 15:41:55 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id j5si9178139pdk.48.2014.10.20.15.41.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Oct 2014 15:41:52 -0700 (PDT)
Message-Id: <20141020222841.490529442@infradead.org>
Date: Mon, 20 Oct 2014 23:56:38 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: [RFC][PATCH 5/6] mm: Provide speculative fault infrastructure
References: <20141020215633.717315139@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=peterz-mm-speculative-fault.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org, paulmck@linux.vnet.ibm.com, tglx@linutronix.de, akpm@linux-foundation.org, riel@redhat.com, mgorman@suse.de, oleg@redhat.com, mingo@redhat.com, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com, viro@zeniv.linux.org.uk, laijs@cn.fujitsu.com, dave@stgolabs.net
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>

Provide infrastructure to do a speculative fault (not holding
mmap_sem).

The not holding of mmap_sem means we can race against VMA
change/removal and page-table destruction. We use the SRCU VMA freeing
to keep the VMA around. We use the VMA seqcount to detect change
(including umapping / page-table deletion) and we use gup_fast() style
page-table walking to deal with page-table races.

Once we've obtained the page and are ready to update the PTE, we
validate if the state we started the fault with is still valid, if
not, we'll fail the fault with VM_FAULT_RETRY, otherwise we update the
PTE and we're done.

Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 include/linux/mm.h |    2 
 mm/memory.c        |  118 ++++++++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 119 insertions(+), 1 deletion(-)

--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1162,6 +1162,8 @@ int generic_error_remove_page(struct add
 int invalidate_inode_page(struct page *page);
 
 #ifdef CONFIG_MMU
+extern int handle_speculative_fault(struct mm_struct *mm,
+			unsigned long address, unsigned int flags);
 extern int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 			unsigned long address, unsigned int flags);
 extern int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2004,12 +2004,40 @@ struct fault_env {
 	pte_t entry;
 	spinlock_t *ptl;
 	unsigned int flags;
+	unsigned int sequence;
 };
 
 static bool pte_map_lock(struct fault_env *fe)
 {
+	bool ret = false;
+
+	if (!(fe->flags & FAULT_FLAG_SPECULATIVE)) {
+		fe->pte = pte_offset_map_lock(fe->mm, fe->pmd, fe->address, &fe->ptl);
+		return true;
+	}
+
+	/*
+	 * The first vma_is_dead() guarantees the page-tables are still valid,
+	 * having IRQs disabled ensures they stay around, hence the second
+	 * vma_is_dead() to make sure they are still valid once we've got the
+	 * lock. After that a concurrent zap_pte_range() will block on the PTL
+	 * and thus we're safe.
+	 */
+	local_irq_disable();
+	if (vma_is_dead(fe->vma, fe->sequence))
+		goto out;
+
 	fe->pte = pte_offset_map_lock(fe->mm, fe->pmd, fe->address, &fe->ptl);
-	return true;
+
+	if (vma_is_dead(fe->vma, fe->sequence)) {
+		pte_unmap_unlock(fe->pte, fe->ptl);
+		goto out;
+	}
+
+	ret = true;
+out:
+	local_irq_enable();
+	return ret;
 }
 
 /*
@@ -2432,6 +2460,7 @@ static int do_swap_page(struct fault_env
 	entry = pte_to_swp_entry(fe->entry);
 	if (unlikely(non_swap_entry(entry))) {
 		if (is_migration_entry(entry)) {
+			/* XXX fe->pmd might be dead */
 			migration_entry_wait(fe->mm, fe->pmd, fe->address);
 		} else if (is_hwpoison_entry(entry)) {
 			ret = VM_FAULT_HWPOISON;
@@ -3357,6 +3386,93 @@ static int __handle_mm_fault(struct mm_s
 	return handle_pte_fault(&fe);
 }
 
+int handle_speculative_fault(struct mm_struct *mm, unsigned long address, unsigned int flags)
+{
+	struct fault_env fe = {
+		.mm = mm,
+		.address = address,
+		.flags = flags | FAULT_FLAG_SPECULATIVE,
+	};
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
+	pte_t *pte;
+	int dead, seq, idx, ret = VM_FAULT_RETRY;
+	struct vm_area_struct *vma;
+
+	idx = srcu_read_lock(&vma_srcu);
+	vma = find_vma_srcu(mm, address);
+	if (!vma)
+		goto unlock;
+
+	/*
+	 * Validate the VMA found by the lockless lookup.
+	 */
+	dead = RB_EMPTY_NODE(&vma->vm_rb);
+	seq = raw_read_seqcount(&vma->vm_sequence); /* rmb <-> seqlock,vma_rb_erase() */
+	if ((seq & 1) || dead) /* XXX wait for !&1 instead? */
+		goto unlock;
+
+	if (address < vma->vm_start || vma->vm_end <= address)
+		goto unlock;
+
+	/*
+	 * We need to re-validate the VMA after checking the bounds, otherwise
+	 * we might have a false positive on the bounds.
+	 */
+	if (read_seqcount_retry(&vma->vm_sequence, seq))
+		goto unlock;
+
+	/*
+	 * Do a speculative lookup of the PTE entry.
+	 */
+	local_irq_disable();
+	pgd = pgd_offset(mm, address);
+	if (pgd_none(*pgd) || unlikely(pgd_bad(*pgd)))
+		goto out_walk;
+
+	pud = pud_offset(pgd, address);
+	if (pud_none(*pud) || unlikely(pud_bad(*pud)))
+		goto out_walk;
+
+	pmd = pmd_offset(pud, address);
+	if (pmd_none(*pmd) || unlikely(pmd_bad(*pmd)))
+		goto out_walk;
+
+	/*
+	 * The above does not allocate/instantiate page-tables because doing so
+	 * would lead to the possibility of instantiating page-tables after
+	 * free_pgtables() -- and consequently leaking them.
+	 *
+	 * The result is that we take at least one !speculative fault per PMD
+	 * in order to instantiate it.
+	 *
+	 * XXX try and fix that.. should be possible somehow.
+	 */
+
+	if (pmd_huge(*pmd)) /* XXX no huge support */
+		goto out_walk;
+
+	fe.vma = vma;
+	fe.pmd = pmd;
+	fe.sequence = seq;
+
+	pte = pte_offset_map(pmd, address);
+	fe.entry = ACCESS_ONCE(pte); /* XXX gup_get_pte() */
+	pte_unmap(pte);
+	local_irq_enable();
+
+	ret = handle_pte_fault(&fe);
+
+unlock:
+	srcu_read_unlock(&vma_srcu, idx);
+	return ret;
+
+out_walk:
+	local_irq_enable();
+	goto unlock;
+}
+
 /*
  * By the time we get here, we already hold the mm semaphore
  *


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
