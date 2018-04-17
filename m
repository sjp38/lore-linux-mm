Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3C6126B0024
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 10:34:28 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z7so5880991wrg.11
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 07:34:28 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id l1si793044edi.372.2018.04.17.07.34.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Apr 2018 07:34:26 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w3HESvPV100691
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 10:34:25 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2hdhth37fx-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 10:34:24 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Tue, 17 Apr 2018 15:34:21 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH v10 12/25] mm: cache some VMA fields in the vm_fault structure
Date: Tue, 17 Apr 2018 16:33:18 +0200
In-Reply-To: <1523975611-15978-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1523975611-15978-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1523975611-15978-13-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@kernel.org, peterz@infradead.org, kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, David Rientjes <rientjes@google.com>, Jerome Glisse <jglisse@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, paulmck@linux.vnet.ibm.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

When handling speculative page fault, the vma->vm_flags and
vma->vm_page_prot fields are read once the page table lock is released. So
there is no more guarantee that these fields would not change in our back.
They will be saved in the vm_fault structure before the VMA is checked for
changes.

This patch also set the fields in hugetlb_no_page() and
__collapse_huge_page_swapin even if it is not need for the callee.

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 include/linux/mm.h | 10 ++++++++--
 mm/huge_memory.c   |  6 +++---
 mm/hugetlb.c       |  2 ++
 mm/khugepaged.c    |  2 ++
 mm/memory.c        | 50 ++++++++++++++++++++++++++------------------------
 mm/migrate.c       |  2 +-
 6 files changed, 42 insertions(+), 30 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index f6edd15563bc..c65205c8c558 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -367,6 +367,12 @@ struct vm_fault {
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
@@ -687,9 +693,9 @@ void free_compound_page(struct page *page);
  * pte_mkwrite.  But get_user_pages can cause write faults for mappings
  * that do not have writing enabled, when used by access_process_vm.
  */
-static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
+static inline pte_t maybe_mkwrite(pte_t pte, unsigned long vma_flags)
 {
-	if (likely(vma->vm_flags & VM_WRITE))
+	if (likely(vma_flags & VM_WRITE))
 		pte = pte_mkwrite(pte);
 	return pte;
 }
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index a3a1815f8e11..da2afda67e68 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1194,8 +1194,8 @@ static int do_huge_pmd_wp_page_fallback(struct vm_fault *vmf, pmd_t orig_pmd,
 
 	for (i = 0; i < HPAGE_PMD_NR; i++, haddr += PAGE_SIZE) {
 		pte_t entry;
-		entry = mk_pte(pages[i], vma->vm_page_prot);
-		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+		entry = mk_pte(pages[i], vmf->vma_page_prot);
+		entry = maybe_mkwrite(pte_mkdirty(entry), vmf->vma_flags);
 		memcg = (void *)page_private(pages[i]);
 		set_page_private(pages[i], 0);
 		page_add_new_anon_rmap(pages[i], vmf->vma, haddr, false);
@@ -2168,7 +2168,7 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 				entry = pte_swp_mksoft_dirty(entry);
 		} else {
 			entry = mk_pte(page + i, READ_ONCE(vma->vm_page_prot));
-			entry = maybe_mkwrite(entry, vma);
+			entry = maybe_mkwrite(entry, vma->vm_flags);
 			if (!write)
 				entry = pte_wrprotect(entry);
 			if (!young)
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 218679138255..774864153407 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3718,6 +3718,8 @@ static int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
 				.vma = vma,
 				.address = address,
 				.flags = flags,
+				.vma_flags = vma->vm_flags,
+				.vma_page_prot = vma->vm_page_prot,
 				/*
 				 * Hard to debug if it ends up being
 				 * used by a callee that assumes
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index 0b28af4b950d..2b02a9f9589e 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -887,6 +887,8 @@ static bool __collapse_huge_page_swapin(struct mm_struct *mm,
 		.flags = FAULT_FLAG_ALLOW_RETRY,
 		.pmd = pmd,
 		.pgoff = linear_page_index(vma, address),
+		.vma_flags = vma->vm_flags,
+		.vma_page_prot = vma->vm_page_prot,
 	};
 
 	/* we only decide to swapin, if there is enough young ptes */
diff --git a/mm/memory.c b/mm/memory.c
index f76f5027d251..2fb9920e06a5 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1826,7 +1826,7 @@ static int insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 out_mkwrite:
 	if (mkwrite) {
 		entry = pte_mkyoung(entry);
-		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+		entry = maybe_mkwrite(pte_mkdirty(entry), vma->vm_flags);
 	}
 
 	set_pte_at(mm, addr, pte, entry);
@@ -2472,7 +2472,7 @@ static inline void wp_page_reuse(struct vm_fault *vmf)
 
 	flush_cache_page(vma, vmf->address, pte_pfn(vmf->orig_pte));
 	entry = pte_mkyoung(vmf->orig_pte);
-	entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+	entry = maybe_mkwrite(pte_mkdirty(entry), vmf->vma_flags);
 	if (ptep_set_access_flags(vma, vmf->address, vmf->pte, entry, 1))
 		update_mmu_cache(vma, vmf->address, vmf->pte);
 	pte_unmap_unlock(vmf->pte, vmf->ptl);
@@ -2548,8 +2548,8 @@ static int wp_page_copy(struct vm_fault *vmf)
 			inc_mm_counter_fast(mm, MM_ANONPAGES);
 		}
 		flush_cache_page(vma, vmf->address, pte_pfn(vmf->orig_pte));
-		entry = mk_pte(new_page, vma->vm_page_prot);
-		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+		entry = mk_pte(new_page, vmf->vma_page_prot);
+		entry = maybe_mkwrite(pte_mkdirty(entry), vmf->vma_flags);
 		/*
 		 * Clear the pte entry and flush it first, before updating the
 		 * pte with the new entry. This will avoid a race condition
@@ -2614,7 +2614,7 @@ static int wp_page_copy(struct vm_fault *vmf)
 		 * Don't let another task, with possibly unlocked vma,
 		 * keep the mlocked page.
 		 */
-		if (page_copied && (vma->vm_flags & VM_LOCKED)) {
+		if (page_copied && (vmf->vma_flags & VM_LOCKED)) {
 			lock_page(old_page);	/* LRU manipulation */
 			if (PageMlocked(old_page))
 				munlock_vma_page(old_page);
@@ -2650,7 +2650,7 @@ static int wp_page_copy(struct vm_fault *vmf)
  */
 int finish_mkwrite_fault(struct vm_fault *vmf)
 {
-	WARN_ON_ONCE(!(vmf->vma->vm_flags & VM_SHARED));
+	WARN_ON_ONCE(!(vmf->vma_flags & VM_SHARED));
 	if (!pte_map_lock(vmf))
 		return VM_FAULT_RETRY;
 	/*
@@ -2752,7 +2752,7 @@ static int do_wp_page(struct vm_fault *vmf)
 		 * We should not cow pages in a shared writeable mapping.
 		 * Just mark the pages writable and/or call ops->pfn_mkwrite.
 		 */
-		if ((vma->vm_flags & (VM_WRITE|VM_SHARED)) ==
+		if ((vmf->vma_flags & (VM_WRITE|VM_SHARED)) ==
 				     (VM_WRITE|VM_SHARED))
 			return wp_pfn_shared(vmf);
 
@@ -2799,7 +2799,7 @@ static int do_wp_page(struct vm_fault *vmf)
 			return VM_FAULT_WRITE;
 		}
 		unlock_page(vmf->page);
-	} else if (unlikely((vma->vm_flags & (VM_WRITE|VM_SHARED)) ==
+	} else if (unlikely((vmf->vma_flags & (VM_WRITE|VM_SHARED)) ==
 					(VM_WRITE|VM_SHARED))) {
 		return wp_page_shared(vmf);
 	}
@@ -3078,9 +3078,9 @@ int do_swap_page(struct vm_fault *vmf)
 
 	inc_mm_counter_fast(vma->vm_mm, MM_ANONPAGES);
 	dec_mm_counter_fast(vma->vm_mm, MM_SWAPENTS);
-	pte = mk_pte(page, vma->vm_page_prot);
+	pte = mk_pte(page, vmf->vma_page_prot);
 	if ((vmf->flags & FAULT_FLAG_WRITE) && reuse_swap_page(page, NULL)) {
-		pte = maybe_mkwrite(pte_mkdirty(pte), vma);
+		pte = maybe_mkwrite(pte_mkdirty(pte), vmf->vma_flags);
 		vmf->flags &= ~FAULT_FLAG_WRITE;
 		ret |= VM_FAULT_WRITE;
 		exclusive = RMAP_EXCLUSIVE;
@@ -3105,7 +3105,7 @@ int do_swap_page(struct vm_fault *vmf)
 
 	swap_free(entry);
 	if (mem_cgroup_swap_full(page) ||
-	    (vma->vm_flags & VM_LOCKED) || PageMlocked(page))
+	    (vmf->vma_flags & VM_LOCKED) || PageMlocked(page))
 		try_to_free_swap(page);
 	unlock_page(page);
 	if (page != swapcache && swapcache) {
@@ -3163,7 +3163,7 @@ static int do_anonymous_page(struct vm_fault *vmf)
 	pte_t entry;
 
 	/* File mapping without ->vm_ops ? */
-	if (vma->vm_flags & VM_SHARED)
+	if (vmf->vma_flags & VM_SHARED)
 		return VM_FAULT_SIGBUS;
 
 	/*
@@ -3187,7 +3187,7 @@ static int do_anonymous_page(struct vm_fault *vmf)
 	if (!(vmf->flags & FAULT_FLAG_WRITE) &&
 			!mm_forbids_zeropage(vma->vm_mm)) {
 		entry = pte_mkspecial(pfn_pte(my_zero_pfn(vmf->address),
-						vma->vm_page_prot));
+						vmf->vma_page_prot));
 		if (!pte_map_lock(vmf))
 			return VM_FAULT_RETRY;
 		if (!pte_none(*vmf->pte))
@@ -3220,8 +3220,8 @@ static int do_anonymous_page(struct vm_fault *vmf)
 	 */
 	__SetPageUptodate(page);
 
-	entry = mk_pte(page, vma->vm_page_prot);
-	if (vma->vm_flags & VM_WRITE)
+	entry = mk_pte(page, vmf->vma_page_prot);
+	if (vmf->vma_flags & VM_WRITE)
 		entry = pte_mkwrite(pte_mkdirty(entry));
 
 	if (!pte_map_lock(vmf)) {
@@ -3418,7 +3418,7 @@ static int do_set_pmd(struct vm_fault *vmf, struct page *page)
 	for (i = 0; i < HPAGE_PMD_NR; i++)
 		flush_icache_page(vma, page + i);
 
-	entry = mk_huge_pmd(page, vma->vm_page_prot);
+	entry = mk_huge_pmd(page, vmf->vma_page_prot);
 	if (write)
 		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
 
@@ -3492,11 +3492,11 @@ int alloc_set_pte(struct vm_fault *vmf, struct mem_cgroup *memcg,
 		return VM_FAULT_NOPAGE;
 
 	flush_icache_page(vma, page);
-	entry = mk_pte(page, vma->vm_page_prot);
+	entry = mk_pte(page, vmf->vma_page_prot);
 	if (write)
-		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+		entry = maybe_mkwrite(pte_mkdirty(entry), vmf->vma_flags);
 	/* copy-on-write page */
-	if (write && !(vma->vm_flags & VM_SHARED)) {
+	if (write && !(vmf->vma_flags & VM_SHARED)) {
 		inc_mm_counter_fast(vma->vm_mm, MM_ANONPAGES);
 		page_add_new_anon_rmap(page, vma, vmf->address, false);
 		mem_cgroup_commit_charge(page, memcg, false, false);
@@ -3535,7 +3535,7 @@ int finish_fault(struct vm_fault *vmf)
 
 	/* Did we COW the page? */
 	if ((vmf->flags & FAULT_FLAG_WRITE) &&
-	    !(vmf->vma->vm_flags & VM_SHARED))
+	    !(vmf->vma_flags & VM_SHARED))
 		page = vmf->cow_page;
 	else
 		page = vmf->page;
@@ -3789,7 +3789,7 @@ static int do_fault(struct vm_fault *vmf)
 		ret = VM_FAULT_SIGBUS;
 	else if (!(vmf->flags & FAULT_FLAG_WRITE))
 		ret = do_read_fault(vmf);
-	else if (!(vma->vm_flags & VM_SHARED))
+	else if (!(vmf->vma_flags & VM_SHARED))
 		ret = do_cow_fault(vmf);
 	else
 		ret = do_shared_fault(vmf);
@@ -3846,7 +3846,7 @@ static int do_numa_page(struct vm_fault *vmf)
 	 * accessible ptes, some can allow access by kernel mode.
 	 */
 	pte = ptep_modify_prot_start(vma->vm_mm, vmf->address, vmf->pte);
-	pte = pte_modify(pte, vma->vm_page_prot);
+	pte = pte_modify(pte, vmf->vma_page_prot);
 	pte = pte_mkyoung(pte);
 	if (was_writable)
 		pte = pte_mkwrite(pte);
@@ -3880,7 +3880,7 @@ static int do_numa_page(struct vm_fault *vmf)
 	 * Flag if the page is shared between multiple address spaces. This
 	 * is later used when determining whether to group tasks together
 	 */
-	if (page_mapcount(page) > 1 && (vma->vm_flags & VM_SHARED))
+	if (page_mapcount(page) > 1 && (vmf->vma_flags & VM_SHARED))
 		flags |= TNF_SHARED;
 
 	last_cpupid = page_cpupid_last(page);
@@ -3925,7 +3925,7 @@ static inline int wp_huge_pmd(struct vm_fault *vmf, pmd_t orig_pmd)
 		return vmf->vma->vm_ops->huge_fault(vmf, PE_SIZE_PMD);
 
 	/* COW handled on pte level: split pmd */
-	VM_BUG_ON_VMA(vmf->vma->vm_flags & VM_SHARED, vmf->vma);
+	VM_BUG_ON_VMA(vmf->vma_flags & VM_SHARED, vmf->vma);
 	__split_huge_pmd(vmf->vma, vmf->pmd, vmf->address, false, NULL);
 
 	return VM_FAULT_FALLBACK;
@@ -4072,6 +4072,8 @@ static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 		.flags = flags,
 		.pgoff = linear_page_index(vma, address),
 		.gfp_mask = __get_fault_gfp_mask(vma),
+		.vma_flags = vma->vm_flags,
+		.vma_page_prot = vma->vm_page_prot,
 	};
 	unsigned int dirty = flags & FAULT_FLAG_WRITE;
 	struct mm_struct *mm = vma->vm_mm;
diff --git a/mm/migrate.c b/mm/migrate.c
index bb6367d70a3e..44d7007cfc1c 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -240,7 +240,7 @@ static bool remove_migration_pte(struct page *page, struct vm_area_struct *vma,
 		 */
 		entry = pte_to_swp_entry(*pvmw.pte);
 		if (is_write_migration_entry(entry))
-			pte = maybe_mkwrite(pte, vma);
+			pte = maybe_mkwrite(pte, vma->vm_flags);
 
 		if (unlikely(is_zone_device_page(new))) {
 			if (is_device_private_page(new)) {
-- 
2.7.4
