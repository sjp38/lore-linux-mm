Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1444B6B03FA
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 06:09:25 -0500 (EST)
Received: by mail-yw0-f198.google.com with SMTP id t125so45831151ywc.4
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 03:09:25 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id z2si1548804ywg.443.2016.11.18.03.09.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Nov 2016 03:09:24 -0800 (PST)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAIB9I8G145168
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 06:09:24 -0500
Received: from e06smtp09.uk.ibm.com (e06smtp09.uk.ibm.com [195.75.94.105])
	by mx0b-001b2d01.pphosted.com with ESMTP id 26sx9jeeac-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 06:09:23 -0500
Received: from localhost
	by e06smtp09.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Fri, 18 Nov 2016 11:08:57 -0000
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 133622190023
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 11:08:09 +0000 (GMT)
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uAIB8uZ232637172
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 11:08:56 GMT
Received: from d06av01.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uAIB8tDS020912
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 04:08:55 -0700
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [RFC PATCH v2 6/7] mm: Provide speculative fault infrastructure
Date: Fri, 18 Nov 2016 12:08:50 +0100
In-Reply-To: <cover.1479465699.git.ldufour@linux.vnet.ibm.com>
References: <20161018150243.GZ3117@twins.programming.kicks-ass.net>
 <cover.1479465699.git.ldufour@linux.vnet.ibm.com>
In-Reply-To: <cover.1479465699.git.ldufour@linux.vnet.ibm.com>
References: <cover.1479465699.git.ldufour@linux.vnet.ibm.com>
Message-Id: <301fb863785f37c319b493bd0d43167353871804.1479465699.git.ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A . Shutemov" <kirill@shutemov.name>, Peter Zijlstra <peterz@infradead.org>
Cc: Linux MM <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.cz>

From: Peter Zijlstra <peterz@infradead.org>

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
[Fix newly introduced pte_spinlock() for speculative page fault]
Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 include/linux/mm.h |   3 ++
 mm/memory.c        | 146 +++++++++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 146 insertions(+), 3 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index e8e9e3dc4a0d..6d4285c0df65 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -320,6 +320,7 @@ struct fault_env {
 	struct vm_area_struct *vma;	/* Target VMA */
 	unsigned long address;		/* Faulting virtual address */
 	unsigned int flags;		/* FAULT_FLAG_xxx flags */
+	unsigned int sequence;
 	pmd_t *pmd;			/* Pointer to pmd entry matching
 					 * the 'address'
 					 */
@@ -1258,6 +1259,8 @@ int invalidate_inode_page(struct page *page);
 #ifdef CONFIG_MMU
 extern int handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 		unsigned int flags);
+extern int handle_speculative_fault(struct mm_struct *mm,
+			unsigned long address, unsigned int flags);
 extern int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
 			    unsigned long address, unsigned int fault_flags,
 			    bool *unlocked);
diff --git a/mm/memory.c b/mm/memory.c
index ec32cf710403..1c06b45c6097 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2099,15 +2099,66 @@ static inline int wp_page_reuse(struct fault_env *fe, pte_t orig_pte,
 
 static bool pte_spinlock(struct fault_env *fe)
 {
+	bool ret = false;
+
+	/* Check if vma is still valid */
+	if (!(fe->flags & FAULT_FLAG_SPECULATIVE)) {
+		fe->ptl = pte_lockptr(fe->vma->vm_mm, fe->pmd);
+		spin_lock(fe->ptl);
+		return true;
+	}
+
+	local_irq_disable();
+	if (vma_is_dead(fe->vma, fe->sequence))
+		goto out;
+
 	fe->ptl = pte_lockptr(fe->vma->vm_mm, fe->pmd);
 	spin_lock(fe->ptl);
-	return true;
+
+	if (vma_is_dead(fe->vma, fe->sequence)) {
+		spin_unlock(fe->ptl);
+		goto out;
+	}
+
+	ret = true;
+out:
+	local_irq_enable();
+	return ret;
 }
 
 static bool pte_map_lock(struct fault_env *fe)
 {
-	fe->pte = pte_offset_map_lock(fe->vma->vm_mm, fe->pmd, fe->address, &fe->ptl);
-	return true;
+	bool ret = false;
+
+	if (!(fe->flags & FAULT_FLAG_SPECULATIVE)) {
+		fe->pte = pte_offset_map_lock(fe->vma->vm_mm, fe->pmd,
+					      fe->address, &fe->ptl);
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
+	fe->pte = pte_offset_map_lock(fe->vma->vm_mm, fe->pmd,
+				      fe->address, &fe->ptl);
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
@@ -2533,6 +2584,7 @@ int do_swap_page(struct fault_env *fe, pte_t orig_pte)
 	entry = pte_to_swp_entry(orig_pte);
 	if (unlikely(non_swap_entry(entry))) {
 		if (is_migration_entry(entry)) {
+			/* XXX fe->pmd might be dead */
 			migration_entry_wait(vma->vm_mm, fe->pmd, fe->address);
 		} else if (is_hwpoison_entry(entry)) {
 			ret = VM_FAULT_HWPOISON;
@@ -3625,6 +3677,94 @@ static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 	return handle_pte_fault(&fe);
 }
 
+int handle_speculative_fault(struct mm_struct *mm, unsigned long address, unsigned int flags)
+{
+	struct fault_env fe = {
+		.address = address,
+		.flags = flags | FAULT_FLAG_SPECULATIVE,
+	};
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
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
+#if 0
+#warning This is done in handle_pte_fault()...
+	pte = pte_offset_map(pmd, address);
+	fe.entry = ACCESS_ONCE(pte); /* XXX gup_get_pte() */
+	pte_unmap(pte);
+#endif
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
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
