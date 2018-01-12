Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id D057B6B0275
	for <linux-mm@kvack.org>; Fri, 12 Jan 2018 12:27:20 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id v195so920056qka.10
        for <linux-mm@kvack.org>; Fri, 12 Jan 2018 09:27:20 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id r20si4685111qtj.262.2018.01.12.09.27.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jan 2018 09:27:19 -0800 (PST)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w0CHOPUA054048
	for <linux-mm@kvack.org>; Fri, 12 Jan 2018 12:27:18 -0500
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2feyqkxjkq-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 12 Jan 2018 12:27:18 -0500
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Fri, 12 Jan 2018 17:27:15 -0000
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH v6 17/24] mm: Provide speculative fault infrastructure
Date: Fri, 12 Jan 2018 18:26:01 +0100
In-Reply-To: <1515777968-867-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1515777968-867-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1515777968-867-18-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

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
[Rename vma_is_dead() to vma_has_changed() and declare it here]
[Fetch p4d and pud]
[Set vmd.sequence in __handle_mm_fault()]
[Abort speculative path when handle_userfault() has to be called]
[Add additional VMA's flags checks in handle_speculative_fault()]
[Clear FAULT_FLAG_ALLOW_RETRY in handle_speculative_fault()]
[Don't set vmf->pte and vmf->ptl if pte_map_lock() failed]
[Remove warning comment about waiting for !seq&1 since we don't want
 to wait]
[Remove warning about no huge page support, mention it explictly]
[Don't call do_fault() in the speculative path as __do_fault() calls
 vma->vm_ops->fault() which may want to release mmap_sem]
[Only vm_fault pointer argument for vma_has_changed()]
[Fix check against huge page, calling pmd_trans_huge()]
[Use READ_ONCE() when reading VMA's fields in the speculative path]
[Explicitly check for __HAVE_ARCH_PTE_SPECIAL as we can't support for
 processing done in vm_normal_page()]
[Check that vma->anon_vma is already set when starting the speculative
 path]
[Check for memory policy as we can't support MPOL_INTERLEAVE case due to
 the processing done in mpol_misplaced()]
[Don't support VMA growing up or down]
[Move check on vm_sequence just before calling handle_pte_fault()]
[Don't build SPF services if !CONFIG_SPF]
[Add mem cgroup oom check]
[Use READ_ONCE to access p*d entries]
[Replace deprecated ACCESS_ONCE() by READ_ONCE() in vma_has_changed()]
[Don't fetch pte again in handle_pte_fault() when running the speculative
 path]
[Check PMD against concurrent collapsing operation]
Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 include/linux/hugetlb_inline.h |   2 +-
 include/linux/mm.h             |   8 +
 include/linux/pagemap.h        |   4 +-
 mm/internal.h                  |  16 +-
 mm/memory.c                    | 321 ++++++++++++++++++++++++++++++++++++++++-
 5 files changed, 344 insertions(+), 7 deletions(-)

diff --git a/include/linux/hugetlb_inline.h b/include/linux/hugetlb_inline.h
index 0660a03d37d9..9e25283d6fc9 100644
--- a/include/linux/hugetlb_inline.h
+++ b/include/linux/hugetlb_inline.h
@@ -8,7 +8,7 @@
 
 static inline bool is_vm_hugetlb_page(struct vm_area_struct *vma)
 {
-	return !!(vma->vm_flags & VM_HUGETLB);
+	return !!(READ_ONCE(vma->vm_flags) & VM_HUGETLB);
 }
 
 #else
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0d1b8d2d1e4f..4d8a7621da8a 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -331,6 +331,10 @@ struct vm_fault {
 	gfp_t gfp_mask;			/* gfp mask to be used for allocations */
 	pgoff_t pgoff;			/* Logical page offset based on vma */
 	unsigned long address;		/* Faulting virtual address */
+#ifdef CONFIG_SPF
+	unsigned int sequence;
+	pmd_t orig_pmd;			/* value of PMD at the time of fault */
+#endif
 	pmd_t *pmd;			/* Pointer to pmd entry matching
 					 * the 'address' */
 	pud_t *pud;			/* Pointer to pud entry matching
@@ -1348,6 +1352,10 @@ int invalidate_inode_page(struct page *page);
 #ifdef CONFIG_MMU
 extern int handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 		unsigned int flags);
+#ifdef CONFIG_SPF
+extern int handle_speculative_fault(struct mm_struct *mm,
+				    unsigned long address, unsigned int flags);
+#endif /* CONFIG_SPF */
 extern int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
 			    unsigned long address, unsigned int fault_flags,
 			    bool *unlocked);
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 34ce3ebf97d5..70e4d2688e7b 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -456,8 +456,8 @@ static inline pgoff_t linear_page_index(struct vm_area_struct *vma,
 	pgoff_t pgoff;
 	if (unlikely(is_vm_hugetlb_page(vma)))
 		return linear_hugepage_index(vma, address);
-	pgoff = (address - vma->vm_start) >> PAGE_SHIFT;
-	pgoff += vma->vm_pgoff;
+	pgoff = (address - READ_ONCE(vma->vm_start)) >> PAGE_SHIFT;
+	pgoff += READ_ONCE(vma->vm_pgoff);
 	return pgoff;
 }
 
diff --git a/mm/internal.h b/mm/internal.h
index 4b9c3357bd6c..f35998b72183 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -44,7 +44,21 @@ int do_swap_page(struct vm_fault *vmf);
 extern struct vm_area_struct *get_vma(struct mm_struct *mm,
 				      unsigned long addr);
 extern void put_vma(struct vm_area_struct *vma);
-#endif
+
+static inline bool vma_has_changed(struct vm_fault *vmf)
+{
+	int ret = RB_EMPTY_NODE(&vmf->vma->vm_rb);
+	unsigned int seq = READ_ONCE(vmf->vma->vm_sequence.sequence);
+
+	/*
+	 * Matches both the wmb in write_seqlock_{begin,end}() and
+	 * the wmb in vma_rb_erase().
+	 */
+	smp_rmb();
+
+	return ret || seq != vmf->sequence;
+}
+#endif /* CONFIG_SPF */
 
 void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
 		unsigned long floor, unsigned long ceiling);
diff --git a/mm/memory.c b/mm/memory.c
index 0ce303260ad1..96720cc7ca74 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -769,7 +769,8 @@ static void print_bad_pte(struct vm_area_struct *vma, unsigned long addr,
 	if (page)
 		dump_page(page, "bad pte");
 	pr_alert("addr:%p vm_flags:%08lx anon_vma:%p mapping:%p index:%lx\n",
-		 (void *)addr, vma->vm_flags, vma->anon_vma, mapping, index);
+		 (void *)addr, READ_ONCE(vma->vm_flags), vma->anon_vma,
+		 mapping, index);
 	pr_alert("file:%pD fault:%pf mmap:%pf readpage:%pf\n",
 		 vma->vm_file,
 		 vma->vm_ops ? vma->vm_ops->fault : NULL,
@@ -2445,19 +2446,108 @@ static inline void wp_page_reuse(struct vm_fault *vmf)
 	pte_unmap_unlock(vmf->pte, vmf->ptl);
 }
 
+#ifdef CONFIG_SPF
 static bool pte_spinlock(struct vm_fault *vmf)
 {
+	bool ret = false;
+	pmd_t pmdval;
+
+	/* Check if vma is still valid */
+	if (!(vmf->flags & FAULT_FLAG_SPECULATIVE)) {
+		vmf->ptl = pte_lockptr(vmf->vma->vm_mm, vmf->pmd);
+		spin_lock(vmf->ptl);
+		return true;
+	}
+
+	local_irq_disable();
+	if (vma_has_changed(vmf))
+		goto out;
+
+	/*
+	 * We check if the pmd value is still the same to ensure that there
+	 * is a huge collapse operation in progress in our back.
+	 */
+	pmdval = READ_ONCE(*vmf->pmd);
+	if (!pmd_same(pmdval, vmf->orig_pmd))
+		goto out;
+
+	vmf->ptl = pte_lockptr(vmf->vma->vm_mm, vmf->pmd);
+	spin_lock(vmf->ptl);
+
+	if (vma_has_changed(vmf)) {
+		spin_unlock(vmf->ptl);
+		goto out;
+	}
+
+	ret = true;
+out:
+	local_irq_enable();
+	return ret;
+}
+#else
+static inline bool pte_spinlock(struct vm_fault *vmf)
+{
 	vmf->ptl = pte_lockptr(vmf->vma->vm_mm, vmf->pmd);
 	spin_lock(vmf->ptl);
 	return true;
 }
+#endif /* CONFIG_SPF */
 
+#ifdef CONFIG_SPF
 static bool pte_map_lock(struct vm_fault *vmf)
 {
+	bool ret = false;
+	pte_t *pte;
+	pmd_t pmdval;
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
+	if (vma_has_changed(vmf))
+		goto out;
+
+	/*
+	 * We check if the pmd value is still the same to ensure that there
+	 * is a huge collapse operation in progress in our back.
+	 */
+	pmdval = READ_ONCE(*vmf->pmd);
+	if (!pmd_same(pmdval, vmf->orig_pmd))
+		goto out;
+
+	pte = pte_offset_map_lock(vmf->vma->vm_mm, vmf->pmd,
+				  vmf->address, &ptl);
+	if (vma_has_changed(vmf)) {
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
+}
+#else
+static inline bool pte_map_lock(struct vm_fault *vmf)
+{
 	vmf->pte = pte_offset_map_lock(vmf->vma->vm_mm, vmf->pmd,
 				       vmf->address, &vmf->ptl);
 	return true;
 }
+#endif /* CONFIG_SPF */
 
 /*
  * Handle the case of a page which we actually need to copy to a new page.
@@ -3182,6 +3272,14 @@ static int do_anonymous_page(struct vm_fault *vmf)
 		ret = check_stable_address_space(vma->vm_mm);
 		if (ret)
 			goto unlock;
+		/*
+		 * Don't call the userfaultfd during the speculative path.
+		 * We already checked for the VMA to not be managed through
+		 * userfaultfd, but it may be set in our back once we have lock
+		 * the pte. In such a case we can ignore it this time.
+		 */
+		if (vmf->flags & FAULT_FLAG_SPECULATIVE)
+			goto setpte;
 		/* Deliver the page fault to userland, check inside PT lock */
 		if (userfaultfd_missing(vma)) {
 			pte_unmap_unlock(vmf->pte, vmf->ptl);
@@ -3224,7 +3322,7 @@ static int do_anonymous_page(struct vm_fault *vmf)
 		goto release;
 
 	/* Deliver the page fault to userland, check inside PT lock */
-	if (userfaultfd_missing(vma)) {
+	if (!(vmf->flags & FAULT_FLAG_SPECULATIVE) && userfaultfd_missing(vma)) {
 		pte_unmap_unlock(vmf->pte, vmf->ptl);
 		mem_cgroup_cancel_charge(page, memcg, false);
 		put_page(page);
@@ -3967,13 +4065,22 @@ static int handle_pte_fault(struct vm_fault *vmf)
 
 	if (unlikely(pmd_none(*vmf->pmd))) {
 		/*
+		 * In the case of the speculative page fault handler we abort
+		 * the speculative path immediately as the pmd is probably
+		 * in the way to be converted in a huge one. We will try
+		 * again holding the mmap_sem (which implies that the collapse
+		 * operation is done).
+		 */
+		if (vmf->flags & FAULT_FLAG_SPECULATIVE)
+			return VM_FAULT_RETRY;
+		/*
 		 * Leave __pte_alloc() until later: because vm_ops->fault may
 		 * want to allocate huge page, and if we expose page table
 		 * for an instant, it will be difficult to retract from
 		 * concurrent faults and from rmap lookups.
 		 */
 		vmf->pte = NULL;
-	} else {
+	} else if (!(vmf->flags & FAULT_FLAG_SPECULATIVE)) {
 		/* See comment in pte_alloc_one_map() */
 		if (pmd_devmap_trans_unstable(vmf->pmd))
 			return 0;
@@ -3982,6 +4089,9 @@ static int handle_pte_fault(struct vm_fault *vmf)
 		 * pmd from under us anymore at this point because we hold the
 		 * mmap_sem read mode and khugepaged takes it in write mode.
 		 * So now it's safe to run pte_offset_map().
+		 * This is not applicable to the speculative page fault handler
+		 * but in that case, the pte is fetched earlier in
+		 * handle_speculative_fault().
 		 */
 		vmf->pte = pte_offset_map(vmf->pmd, vmf->address);
 		vmf->orig_pte = *vmf->pte;
@@ -4004,6 +4114,8 @@ static int handle_pte_fault(struct vm_fault *vmf)
 	if (!vmf->pte) {
 		if (vma_is_anonymous(vmf->vma))
 			return do_anonymous_page(vmf);
+		else if (vmf->flags & FAULT_FLAG_SPECULATIVE)
+			return VM_FAULT_RETRY;
 		else
 			return do_fault(vmf);
 	}
@@ -4101,6 +4213,9 @@ static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 	vmf.pmd = pmd_alloc(mm, vmf.pud, address);
 	if (!vmf.pmd)
 		return VM_FAULT_OOM;
+#ifdef CONFIG_SPF
+	vmf.sequence = raw_read_seqcount(&vma->vm_sequence);
+#endif
 	if (pmd_none(*vmf.pmd) && transparent_hugepage_enabled(vma)) {
 		ret = create_huge_pmd(&vmf);
 		if (!(ret & VM_FAULT_FALLBACK))
@@ -4134,6 +4249,206 @@ static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 	return handle_pte_fault(&vmf);
 }
 
+#ifdef CONFIG_SPF
+
+#ifndef __HAVE_ARCH_PTE_SPECIAL
+/* This is required by vm_normal_page() */
+#error "Speculative page fault handler requires __HAVE_ARCH_PTE_SPECIAL"
+#endif
+
+/*
+ * vm_normal_page() adds some processing which should be done while
+ * hodling the mmap_sem.
+ */
+int handle_speculative_fault(struct mm_struct *mm, unsigned long address,
+			     unsigned int flags)
+{
+	struct vm_fault vmf = {
+		.address = address,
+	};
+	pgd_t *pgd, pgdval;
+	p4d_t *p4d, p4dval;
+	pud_t pudval;
+	int seq, ret = VM_FAULT_RETRY;
+	struct vm_area_struct *vma;
+#ifdef CONFIG_NUMA
+	struct mempolicy *pol;
+#endif
+
+	/* Clear flags that may lead to release the mmap_sem to retry */
+	flags &= ~(FAULT_FLAG_ALLOW_RETRY|FAULT_FLAG_KILLABLE);
+	flags |= FAULT_FLAG_SPECULATIVE;
+
+	vma = get_vma(mm, address);
+	if (!vma)
+		return ret;
+
+	seq = raw_read_seqcount(&vma->vm_sequence); /* rmb <-> seqlock,vma_rb_erase() */
+	if (seq & 1)
+		goto out_put;
+
+	/*
+	 * Can't call vm_ops service has we don't know what they would do
+	 * with the VMA.
+	 * This include huge page from hugetlbfs.
+	 */
+	if (vma->vm_ops)
+		goto out_put;
+
+	/*
+	 * __anon_vma_prepare() requires the mmap_sem to be held
+	 * because vm_next and vm_prev must be safe. This can't be guaranteed
+	 * in the speculative path.
+	 */
+	if (unlikely(!vma->anon_vma))
+		goto out_put;
+
+	vmf.vma_flags = READ_ONCE(vma->vm_flags);
+	vmf.vma_page_prot = READ_ONCE(vma->vm_page_prot);
+
+	/* Can't call userland page fault handler in the speculative path */
+	if (unlikely(vmf.vma_flags & VM_UFFD_MISSING))
+		goto out_put;
+
+	if (vmf.vma_flags & VM_GROWSDOWN || vmf.vma_flags & VM_GROWSUP)
+		/*
+		 * This could be detected by the check address against VMA's
+		 * boundaries but we want to trace it as not supported instead
+		 * of changed.
+		 */
+		goto out_put;
+
+	if (address < READ_ONCE(vma->vm_start)
+	    || READ_ONCE(vma->vm_end) <= address)
+		goto out_put;
+
+	if (!arch_vma_access_permitted(vma, flags & FAULT_FLAG_WRITE,
+				       flags & FAULT_FLAG_INSTRUCTION,
+				       flags & FAULT_FLAG_REMOTE)) {
+		ret = VM_FAULT_SIGSEGV;
+		goto out_put;
+	}
+
+	/* This is one is required to check that the VMA has write access set */
+	if (flags & FAULT_FLAG_WRITE) {
+		if (unlikely(!(vmf.vma_flags & VM_WRITE))) {
+			ret = VM_FAULT_SIGSEGV;
+			goto out_put;
+		}
+	} else if (unlikely(!(vmf.vma_flags & (VM_READ|VM_EXEC|VM_WRITE)))) {
+		ret = VM_FAULT_SIGSEGV;
+		goto out_put;
+	}
+
+#ifdef CONFIG_NUMA
+	/*
+	 * MPOL_INTERLEAVE implies additional check in mpol_misplaced() which
+	 * are not compatible with the speculative page fault processing.
+	 */
+	pol = __get_vma_policy(vma, address);
+	if (!pol)
+		pol = get_task_policy(current);
+	if (pol && pol->mode == MPOL_INTERLEAVE)
+		goto out_put;
+#endif
+
+	/*
+	 * Do a speculative lookup of the PTE entry.
+	 */
+	local_irq_disable();
+	pgd = pgd_offset(mm, address);
+	pgdval = READ_ONCE(*pgd);
+	if (pgd_none(pgdval) || unlikely(pgd_bad(pgdval)))
+		goto out_walk;
+
+	p4d = p4d_offset(pgd, address);
+	p4dval = READ_ONCE(*p4d);
+	if (p4d_none(p4dval) || unlikely(p4d_bad(p4dval)))
+		goto out_walk;
+
+	vmf.pud = pud_offset(p4d, address);
+	pudval = READ_ONCE(*vmf.pud);
+	if (pud_none(pudval) || unlikely(pud_bad(pudval)))
+		goto out_walk;
+
+	/* Huge pages at PUD level are not supported. */
+	if (unlikely(pud_trans_huge(pudval)))
+		goto out_walk;
+
+	vmf.pmd = pmd_offset(vmf.pud, address);
+	vmf.orig_pmd = READ_ONCE(*vmf.pmd);
+	/*
+	 * pmd_none could mean that a hugepage collapse is in progress
+	 * in our back as collapse_huge_page() mark it before
+	 * invalidating the pte (which is done once the IPI is catched
+	 * by all CPU and we have interrupt disabled).
+	 * For this reason we cannot handle THP in a speculative way since we
+	 * can't safely indentify an in progress collapse operation done in our
+	 * back on that PMD.
+	 * Regarding the order of the following checks, see comment in
+	 * pmd_devmap_trans_unstable()
+	 */
+	if (unlikely(pmd_devmap(vmf.orig_pmd) ||
+		     pmd_none(vmf.orig_pmd) || pmd_trans_huge(vmf.orig_pmd) ||
+		     is_swap_pmd(vmf.orig_pmd)))
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
+	vmf.pte = pte_offset_map(vmf.pmd, address);
+	vmf.orig_pte = READ_ONCE(*vmf.pte);
+	barrier(); /* See comment in handle_pte_fault() */
+	if (pte_none(vmf.orig_pte)) {
+		pte_unmap(vmf.pte);
+		vmf.pte = NULL;
+	}
+
+	vmf.vma = vma;
+	vmf.pgoff = linear_page_index(vma, address);
+	vmf.gfp_mask = __get_fault_gfp_mask(vma);
+	vmf.sequence = seq;
+	vmf.flags = flags;
+
+	local_irq_enable();
+
+	/*
+	 * We need to re-validate the VMA after checking the bounds, otherwise
+	 * we might have a false positive on the bounds.
+	 */
+	if (read_seqcount_retry(&vma->vm_sequence, seq))
+		goto out_put;
+
+	mem_cgroup_oom_enable();
+	ret = handle_pte_fault(&vmf);
+	mem_cgroup_oom_disable();
+
+	put_vma(vma);
+
+	/*
+	 * The task may have entered a memcg OOM situation but
+	 * if the allocation error was handled gracefully (no
+	 * VM_FAULT_OOM), there is no need to kill anything.
+	 * Just clean up the OOM state peacefully.
+	 */
+	if (task_in_memcg_oom(current) && !(ret & VM_FAULT_OOM))
+		mem_cgroup_oom_synchronize(false);
+	return ret;
+
+out_walk:
+	local_irq_enable();
+out_put:
+	put_vma(vma);
+	return ret;
+}
+#endif /* CONFIG_SPF */
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
