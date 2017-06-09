Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4A3956B0317
	for <linux-mm@kvack.org>; Fri,  9 Jun 2017 10:21:34 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id v104so8660532wrb.6
        for <linux-mm@kvack.org>; Fri, 09 Jun 2017 07:21:34 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id o6si1393880wrc.161.2017.06.09.07.21.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Jun 2017 07:21:32 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v59EIdih012904
	for <linux-mm@kvack.org>; Fri, 9 Jun 2017 10:21:31 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2ayu4gq6s2-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 09 Jun 2017 10:21:31 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Fri, 9 Jun 2017 15:21:28 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [RFC v4 06/20] mm: Provide speculative fault infrastructure
Date: Fri,  9 Jun 2017 16:20:55 +0200
In-Reply-To: <1497018069-17790-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1497018069-17790-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1497018069-17790-7-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com

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
[Rename vma_is_dead() to vma_has_changed()]
[Call p4d_alloc() as it is safe since pgd is valid]
[Call pud_alloc() as it is safe since p4d is valid]
Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 include/linux/mm.h |   3 ++
 mm/memory.c        | 148 +++++++++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 148 insertions(+), 3 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 6b7ec2a76953..671541e00d26 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -315,6 +315,7 @@ struct vm_fault {
 	gfp_t gfp_mask;			/* gfp mask to be used for allocations */
 	pgoff_t pgoff;			/* Logical page offset based on vma */
 	unsigned long address;		/* Faulting virtual address */
+	unsigned int sequence;
 	pmd_t *pmd;			/* Pointer to pmd entry matching
 					 * the 'address' */
 	pud_t *pud;			/* Pointer to pud entry matching
@@ -1286,6 +1287,8 @@ int invalidate_inode_page(struct page *page);
 #ifdef CONFIG_MMU
 extern int handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 		unsigned int flags);
+extern int handle_speculative_fault(struct mm_struct *mm,
+				    unsigned long address, unsigned int flags);
 extern int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
 			    unsigned long address, unsigned int fault_flags,
 			    bool *unlocked);
diff --git a/mm/memory.c b/mm/memory.c
index 8f0468d099fc..8c43895e9310 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2244,15 +2244,66 @@ static inline void wp_page_reuse(struct vm_fault *vmf)
 
 static bool pte_spinlock(struct vm_fault *vmf)
 {
+	bool ret = false;
+
+	/* Check if vma is still valid */
+	if (!(vmf->flags & FAULT_FLAG_SPECULATIVE)) {
+		vmf->ptl = pte_lockptr(vmf->vma->vm_mm, vmf->pmd);
+		spin_lock(vmf->ptl);
+		return true;
+	}
+
+	local_irq_disable();
+	if (vma_has_changed(vmf->vma, vmf->sequence))
+		goto out;
+
 	vmf->ptl = pte_lockptr(vmf->vma->vm_mm, vmf->pmd);
 	spin_lock(vmf->ptl);
-	return true;
+
+	if (vma_has_changed(vmf->vma, vmf->sequence)) {
+		spin_unlock(vmf->ptl);
+		goto out;
+	}
+
+	ret = true;
+out:
+	local_irq_enable();
+	return ret;
 }
 
 static bool pte_map_lock(struct vm_fault *vmf)
 {
-	vmf->pte = pte_offset_map_lock(vmf->vma->vm_mm, vmf->pmd, vmf->address, &vmf->ptl);
-	return true;
+	bool ret = false;
+
+	if (!(vmf->flags & FAULT_FLAG_SPECULATIVE)) {
+		vmf->pte = pte_offset_map_lock(vmf->vma->vm_mm, vmf->pmd,
+					       vmf->address, &vmf->ptl);
+		return true;
+	}
+
+	/*
+	 * The first vma_has_changed() guarantees the page-tables are still
+	 * valid, having IRQs disabled ensures they stay around, hence the
+	 * second vma_has_changed() to make sure they are still valid once
+	 * we've got the lock. After that a concurrent zap_pte_range() will
+	 * block on the PTL and thus we're safe.
+	 */
+	local_irq_disable();
+	if (vma_has_changed(vmf->vma, vmf->sequence))
+		goto out;
+
+	vmf->pte = pte_offset_map_lock(vmf->vma->vm_mm, vmf->pmd,
+				       vmf->address, &vmf->ptl);
+
+	if (vma_has_changed(vmf->vma, vmf->sequence)) {
+		pte_unmap_unlock(vmf->pte, vmf->ptl);
+		goto out;
+	}
+
+	ret = true;
+out:
+	local_irq_enable();
+	return ret;
 }
 
 /*
@@ -2684,6 +2735,7 @@ int do_swap_page(struct vm_fault *vmf)
 	entry = pte_to_swp_entry(vmf->orig_pte);
 	if (unlikely(non_swap_entry(entry))) {
 		if (is_migration_entry(entry)) {
+			/* XXX fe->pmd might be dead */
 			migration_entry_wait(vma->vm_mm, vmf->pmd,
 					     vmf->address);
 		} else if (is_hwpoison_entry(entry)) {
@@ -3868,6 +3920,96 @@ static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 	return handle_pte_fault(&vmf);
 }
 
+int handle_speculative_fault(struct mm_struct *mm, unsigned long address,
+			     unsigned int flags)
+{
+	struct vm_fault vmf = {
+		.address = address,
+		.flags = flags | FAULT_FLAG_SPECULATIVE,
+	};
+	pgd_t *pgd;
+	p4d_t *p4d;
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
+	p4d = p4d_alloc(mm, pgd, address);
+	if (p4d_none(*p4d) || unlikely(p4d_bad(*p4d)))
+		goto out_walk;
+
+	pud = pud_alloc(mm, p4d, address);
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
+	vmf.vma = vma;
+	vmf.pmd = pmd;
+	vmf.pgoff = linear_page_index(vma, address);
+	vmf.gfp_mask = __get_fault_gfp_mask(vma);
+	vmf.sequence = seq;
+
+	local_irq_enable();
+
+	ret = handle_pte_fault(&vmf);
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
