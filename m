Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 753FA83293
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 13:53:05 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id m5so48410574pgn.1
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 10:53:05 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id g13si2610122pln.618.2017.06.16.10.53.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jun 2017 10:53:04 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5GHn8Tg064589
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 13:53:04 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2b4jeskrch-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 13:53:03 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Fri, 16 Jun 2017 18:53:01 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [RFC v5 08/11] mm: Provide speculative fault infrastructure
Date: Fri, 16 Jun 2017 19:52:32 +0200
In-Reply-To: <1497635555-25679-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1497635555-25679-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1497635555-25679-9-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>

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

[Manage the newly introduced pte_spinlock() for speculative page
 fault to fail if the VMA is touched in our back]
[Rename vma_is_dead() to vma_has_changed()]
[Call p4d_alloc() as it is safe since pgd is valid]
[Call pud_alloc() as it is safe since p4d is valid]
[Set fe.sequence in __handle_mm_fault()]
[Abort speculative path when handle_userfault() has to be called]
[Add additional VMA's flags checks in handle_speculative_fault()]
[Clear FAULT_FLAG_ALLOW_RETRY in handle_speculative_fault()]
[Don't set vmf->pte and vmf->ptl if pte_map_lock() failed]
[Remove warning comment about waiting for !seq&1 since we don't want
 to wait]
[Remove warning about no huge page support, mention it explictly]
Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 include/linux/mm.h |   3 +
 mm/memory.c        | 181 ++++++++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 181 insertions(+), 3 deletions(-)

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
index 5d259cd67a83..0645cb21155f 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2244,15 +2244,69 @@ static inline void wp_page_reuse(struct vm_fault *vmf)
 
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
+	pte_t *pte;
+	spinlock_t *ptl;
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
+	pte = pte_offset_map_lock(vmf->vma->vm_mm, vmf->pmd,
+				  vmf->address, &ptl);
+	if (vma_has_changed(vmf->vma, vmf->sequence)) {
+		pte_unmap_unlock(pte, ptl);
+		goto out;
+	}
+
+	vmf->pte = pte;
+	vmf->ptl = ptl;
+	ret = true;
+out:
+	local_irq_enable();
+	return ret;
 }
 
 /*
@@ -2938,6 +2992,8 @@ static int do_anonymous_page(struct vm_fault *vmf)
 		/* Deliver the page fault to userland, check inside PT lock */
 		if (userfaultfd_missing(vma)) {
 			pte_unmap_unlock(vmf->pte, vmf->ptl);
+			if (vmf->flags & FAULT_FLAG_SPECULATIVE)
+				return VM_FAULT_RETRY;
 			return handle_userfault(vmf, VM_UFFD_MISSING);
 		}
 		goto setpte;
@@ -2977,6 +3033,8 @@ static int do_anonymous_page(struct vm_fault *vmf)
 		pte_unmap_unlock(vmf->pte, vmf->ptl);
 		mem_cgroup_cancel_charge(page, memcg, false);
 		put_page(page);
+		if (vmf->flags & FAULT_FLAG_SPECULATIVE)
+			return VM_FAULT_RETRY;
 		return handle_userfault(vmf, VM_UFFD_MISSING);
 	}
 
@@ -3839,6 +3897,7 @@ static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 	vmf.pmd = pmd_alloc(mm, vmf.pud, address);
 	if (!vmf.pmd)
 		return VM_FAULT_OOM;
+	vmf.sequence = raw_read_seqcount(&vma->vm_sequence);
 	if (pmd_none(*vmf.pmd) && transparent_hugepage_enabled(vma)) {
 		ret = create_huge_pmd(&vmf);
 		if (!(ret & VM_FAULT_FALLBACK))
@@ -3866,6 +3925,122 @@ static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 	return handle_pte_fault(&vmf);
 }
 
+int handle_speculative_fault(struct mm_struct *mm, unsigned long address,
+			     unsigned int flags)
+{
+	struct vm_fault vmf = {
+		.address = address,
+	};
+	pgd_t *pgd;
+	p4d_t *p4d;
+	pud_t *pud;
+	pmd_t *pmd;
+	int dead, seq, idx, ret = VM_FAULT_RETRY;
+	struct vm_area_struct *vma;
+
+	/* Clear flags that may lead to release the mmap_sem to retry */
+	flags &= ~(FAULT_FLAG_ALLOW_RETRY|FAULT_FLAG_KILLABLE);
+	flags |= FAULT_FLAG_SPECULATIVE;
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
+	if ((seq & 1) || dead)
+		goto unlock;
+
+	if (address < vma->vm_start || vma->vm_end <= address)
+		goto unlock;
+
+	/*
+	 * Huge pages are not yet supported.
+	 */
+	if (unlikely(is_vm_hugetlb_page(vma)))
+		goto unlock;
+
+	/*
+	 * The three following checks are copied from access_error from
+	 * arch/x86/mm/fault.c
+	 */
+	if (!arch_vma_access_permitted(vma, flags & FAULT_FLAG_WRITE,
+				       flags & FAULT_FLAG_INSTRUCTION,
+				       flags & FAULT_FLAG_REMOTE))
+		goto unlock;
+
+	/* This is one is required to check that the VMA has write access set */
+	if (flags & FAULT_FLAG_WRITE) {
+		if (unlikely(!(vma->vm_flags & VM_WRITE)))
+			goto unlock;
+	} else {
+		if (unlikely(!(vma->vm_flags & (VM_READ | VM_EXEC | VM_WRITE))))
+			goto unlock;
+	}
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
+	 */
+
+	if (unlikely(pmd_huge(*pmd)))
+		goto out_walk;
+
+	vmf.vma = vma;
+	vmf.pmd = pmd;
+	vmf.pgoff = linear_page_index(vma, address);
+	vmf.gfp_mask = __get_fault_gfp_mask(vma);
+	vmf.sequence = seq;
+	vmf.flags = flags;
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
