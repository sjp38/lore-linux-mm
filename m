Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 91E826B026C
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 06:08:31 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r68so13544836wmr.6
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 03:08:31 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id e8si6762937edc.183.2017.10.09.03.08.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Oct 2017 03:08:29 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v99A4Q11011628
	for <linux-mm@kvack.org>; Mon, 9 Oct 2017 06:08:28 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2dg4cp71tv-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 09 Oct 2017 06:08:27 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Mon, 9 Oct 2017 11:08:25 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH v4 07/20] mm: Cache some VMA fields in the vm_fault structure
Date: Mon,  9 Oct 2017 12:07:39 +0200
In-Reply-To: <1507543672-25821-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1507543672-25821-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1507543672-25821-8-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

When handling speculative page fault, the vma->vm_flags and
vma->vm_page_prot fields are read once the page table lock is released. So
there is no more guarantee that these fields would not change in our back.
They will be saved in the vm_fault structure before the VMA is checked for
changes.

This patch also set the fields in hugetlb_no_page() and
__collapse_huge_page_swapin even if it is not need for the callee.

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 include/linux/mm.h |  6 ++++++
 mm/hugetlb.c       |  2 ++
 mm/khugepaged.c    |  2 ++
 mm/memory.c        | 38 ++++++++++++++++++++------------------
 4 files changed, 30 insertions(+), 18 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index aa06332fc01e..ccb718e28ebe 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -350,6 +350,12 @@ struct vm_fault {
 					 * page table to avoid allocation from
 					 * atomic context.
 					 */
+	/*
+	 * These entries are required when handling speculative page fault.
+	 * This way the page handling is done using consistent field values.
+	 */
+	unsigned long vma_flags;
+	pgprot_t vma_page_prot;
 };
 
 /* page entry size for vm->huge_fault() */
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 72fb45db8330..a9ed37a92ac6 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3686,6 +3686,8 @@ static int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
 				.vma = vma,
 				.address = address,
 				.flags = flags,
+				.vma_flags = vma->vm_flags,
+				.vma_page_prot = vma->vm_page_prot,
 				/*
 				 * Hard to debug if it ends up being
 				 * used by a callee that assumes
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index f723d42140db..f9bf337f73c7 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -881,6 +881,8 @@ static bool __collapse_huge_page_swapin(struct mm_struct *mm,
 		.flags = FAULT_FLAG_ALLOW_RETRY,
 		.pmd = pmd,
 		.pgoff = linear_page_index(vma, address),
+		.vma_flags = vma->vm_flags,
+		.vma_page_prot = vma->vm_page_prot,
 	};
 
 	/* we only decide to swapin, if there is enough young ptes */
diff --git a/mm/memory.c b/mm/memory.c
index ac6822356a37..65cd35b5d0c0 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2599,7 +2599,7 @@ static int wp_page_copy(struct vm_fault *vmf)
 		 * Don't let another task, with possibly unlocked vma,
 		 * keep the mlocked page.
 		 */
-		if (page_copied && (vma->vm_flags & VM_LOCKED)) {
+		if (page_copied && (vmf->vma_flags & VM_LOCKED)) {
 			lock_page(old_page);	/* LRU manipulation */
 			if (PageMlocked(old_page))
 				munlock_vma_page(old_page);
@@ -2633,7 +2633,7 @@ static int wp_page_copy(struct vm_fault *vmf)
  */
 int finish_mkwrite_fault(struct vm_fault *vmf)
 {
-	WARN_ON_ONCE(!(vmf->vma->vm_flags & VM_SHARED));
+	WARN_ON_ONCE(!(vmf->vma_flags & VM_SHARED));
 	if (!pte_map_lock(vmf))
 		return VM_FAULT_RETRY;
 	/*
@@ -2735,7 +2735,7 @@ static int do_wp_page(struct vm_fault *vmf)
 		 * We should not cow pages in a shared writeable mapping.
 		 * Just mark the pages writable and/or call ops->pfn_mkwrite.
 		 */
-		if ((vma->vm_flags & (VM_WRITE|VM_SHARED)) ==
+		if ((vmf->vma_flags & (VM_WRITE|VM_SHARED)) ==
 				     (VM_WRITE|VM_SHARED))
 			return wp_pfn_shared(vmf);
 
@@ -2782,7 +2782,7 @@ static int do_wp_page(struct vm_fault *vmf)
 			return VM_FAULT_WRITE;
 		}
 		unlock_page(vmf->page);
-	} else if (unlikely((vma->vm_flags & (VM_WRITE|VM_SHARED)) ==
+	} else if (unlikely((vmf->vma_flags & (VM_WRITE|VM_SHARED)) ==
 					(VM_WRITE|VM_SHARED))) {
 		return wp_page_shared(vmf);
 	}
@@ -3044,7 +3044,7 @@ int do_swap_page(struct vm_fault *vmf)
 
 	inc_mm_counter_fast(vma->vm_mm, MM_ANONPAGES);
 	dec_mm_counter_fast(vma->vm_mm, MM_SWAPENTS);
-	pte = mk_pte(page, vma->vm_page_prot);
+	pte = mk_pte(page, vmf->vma_page_prot);
 	if ((vmf->flags & FAULT_FLAG_WRITE) && reuse_swap_page(page, NULL)) {
 		pte = maybe_mkwrite(pte_mkdirty(pte), vma);
 		vmf->flags &= ~FAULT_FLAG_WRITE;
@@ -3070,7 +3070,7 @@ int do_swap_page(struct vm_fault *vmf)
 
 	swap_free(entry);
 	if (mem_cgroup_swap_full(page) ||
-	    (vma->vm_flags & VM_LOCKED) || PageMlocked(page))
+	    (vmf->vma_flags & VM_LOCKED) || PageMlocked(page))
 		try_to_free_swap(page);
 	unlock_page(page);
 	if (page != swapcache && swapcache) {
@@ -3127,7 +3127,7 @@ static int do_anonymous_page(struct vm_fault *vmf)
 	pte_t entry;
 
 	/* File mapping without ->vm_ops ? */
-	if (vma->vm_flags & VM_SHARED)
+	if (vmf->vma_flags & VM_SHARED)
 		return VM_FAULT_SIGBUS;
 
 	/*
@@ -3151,7 +3151,7 @@ static int do_anonymous_page(struct vm_fault *vmf)
 	if (!(vmf->flags & FAULT_FLAG_WRITE) &&
 			!mm_forbids_zeropage(vma->vm_mm)) {
 		entry = pte_mkspecial(pfn_pte(my_zero_pfn(vmf->address),
-						vma->vm_page_prot));
+						vmf->vma_page_prot));
 		if (!pte_map_lock(vmf))
 			return VM_FAULT_RETRY;
 		if (!pte_none(*vmf->pte))
@@ -3184,8 +3184,8 @@ static int do_anonymous_page(struct vm_fault *vmf)
 	 */
 	__SetPageUptodate(page);
 
-	entry = mk_pte(page, vma->vm_page_prot);
-	if (vma->vm_flags & VM_WRITE)
+	entry = mk_pte(page, vmf->vma_page_prot);
+	if (vmf->vma_flags & VM_WRITE)
 		entry = pte_mkwrite(pte_mkdirty(entry));
 
 	if (!pte_map_lock(vmf)) {
@@ -3381,7 +3381,7 @@ static int do_set_pmd(struct vm_fault *vmf, struct page *page)
 	for (i = 0; i < HPAGE_PMD_NR; i++)
 		flush_icache_page(vma, page + i);
 
-	entry = mk_huge_pmd(page, vma->vm_page_prot);
+	entry = mk_huge_pmd(page, vmf->vma_page_prot);
 	if (write)
 		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
 
@@ -3455,11 +3455,11 @@ int alloc_set_pte(struct vm_fault *vmf, struct mem_cgroup *memcg,
 		return VM_FAULT_NOPAGE;
 
 	flush_icache_page(vma, page);
-	entry = mk_pte(page, vma->vm_page_prot);
+	entry = mk_pte(page, vmf->vma_page_prot);
 	if (write)
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
 	/* copy-on-write page */
-	if (write && !(vma->vm_flags & VM_SHARED)) {
+	if (write && !(vmf->vma_flags & VM_SHARED)) {
 		inc_mm_counter_fast(vma->vm_mm, MM_ANONPAGES);
 		page_add_new_anon_rmap(page, vma, vmf->address, false);
 		mem_cgroup_commit_charge(page, memcg, false, false);
@@ -3498,7 +3498,7 @@ int finish_fault(struct vm_fault *vmf)
 
 	/* Did we COW the page? */
 	if ((vmf->flags & FAULT_FLAG_WRITE) &&
-	    !(vmf->vma->vm_flags & VM_SHARED))
+	    !(vmf->vma_flags & VM_SHARED))
 		page = vmf->cow_page;
 	else
 		page = vmf->page;
@@ -3752,7 +3752,7 @@ static int do_fault(struct vm_fault *vmf)
 		ret = VM_FAULT_SIGBUS;
 	else if (!(vmf->flags & FAULT_FLAG_WRITE))
 		ret = do_read_fault(vmf);
-	else if (!(vma->vm_flags & VM_SHARED))
+	else if (!(vmf->vma_flags & VM_SHARED))
 		ret = do_cow_fault(vmf);
 	else
 		ret = do_shared_fault(vmf);
@@ -3809,7 +3809,7 @@ static int do_numa_page(struct vm_fault *vmf)
 	 * accessible ptes, some can allow access by kernel mode.
 	 */
 	pte = ptep_modify_prot_start(vma->vm_mm, vmf->address, vmf->pte);
-	pte = pte_modify(pte, vma->vm_page_prot);
+	pte = pte_modify(pte, vmf->vma_page_prot);
 	pte = pte_mkyoung(pte);
 	if (was_writable)
 		pte = pte_mkwrite(pte);
@@ -3843,7 +3843,7 @@ static int do_numa_page(struct vm_fault *vmf)
 	 * Flag if the page is shared between multiple address spaces. This
 	 * is later used when determining whether to group tasks together
 	 */
-	if (page_mapcount(page) > 1 && (vma->vm_flags & VM_SHARED))
+	if (page_mapcount(page) > 1 && (vmf->vma_flags & VM_SHARED))
 		flags |= TNF_SHARED;
 
 	last_cpupid = page_cpupid_last(page);
@@ -3887,7 +3887,7 @@ static int wp_huge_pmd(struct vm_fault *vmf, pmd_t orig_pmd)
 		return vmf->vma->vm_ops->huge_fault(vmf, PE_SIZE_PMD);
 
 	/* COW handled on pte level: split pmd */
-	VM_BUG_ON_VMA(vmf->vma->vm_flags & VM_SHARED, vmf->vma);
+	VM_BUG_ON_VMA(vmf->vma_flags & VM_SHARED, vmf->vma);
 	__split_huge_pmd(vmf->vma, vmf->pmd, vmf->address, false, NULL);
 
 	return VM_FAULT_FALLBACK;
@@ -4034,6 +4034,8 @@ static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 		.flags = flags,
 		.pgoff = linear_page_index(vma, address),
 		.gfp_mask = __get_fault_gfp_mask(vma),
+		.vma_flags = vma->vm_flags,
+		.vma_page_prot = vma->vm_page_prot,
 	};
 	unsigned int dirty = flags & FAULT_FLAG_WRITE;
 	struct mm_struct *mm = vma->vm_mm;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
