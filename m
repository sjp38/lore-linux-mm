Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5BC516B03C0
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 04:17:31 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id g23so9587925wme.4
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 01:17:31 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ld3si6711969wjc.127.2016.11.18.01.17.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 18 Nov 2016 01:17:30 -0800 (PST)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 07/20] mm: Add orig_pte field into vm_fault
Date: Fri, 18 Nov 2016 10:17:11 +0100
Message-Id: <1479460644-25076-8-git-send-email-jack@suse.cz>
In-Reply-To: <1479460644-25076-1-git-send-email-jack@suse.cz>
References: <1479460644-25076-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Jan Kara <jack@suse.cz>

Add orig_pte field to vm_fault structure to allow ->page_mkwrite
handlers to fully handle the fault. This also allows us to save some
passing of extra arguments around.

Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 include/linux/mm.h |  4 +--
 mm/internal.h      |  2 +-
 mm/khugepaged.c    |  7 ++---
 mm/memory.c        | 82 +++++++++++++++++++++++++++---------------------------
 4 files changed, 47 insertions(+), 48 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index df3958437473..5cc679b874eb 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -298,8 +298,8 @@ struct vm_fault {
 	pgoff_t pgoff;			/* Logical page offset based on vma */
 	unsigned long address;		/* Faulting virtual address */
 	pmd_t *pmd;			/* Pointer to pmd entry matching
-					 * the 'address'
-					 */
+					 * the 'address' */
+	pte_t orig_pte;			/* Value of PTE at the time of fault */
 
 	struct page *cow_page;		/* Handler may choose to COW */
 	struct page *page;		/* ->fault handlers should return a
diff --git a/mm/internal.h b/mm/internal.h
index 093b1eacc91b..44d68895a9b9 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -36,7 +36,7 @@
 /* Do not use these with a slab allocator */
 #define GFP_SLAB_BUG_MASK (__GFP_DMA32|__GFP_HIGHMEM|~__GFP_BITS_MASK)
 
-int do_swap_page(struct vm_fault *vmf, pte_t orig_pte);
+int do_swap_page(struct vm_fault *vmf);
 
 void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
 		unsigned long floor, unsigned long ceiling);
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index d7df06383b10..1f20f25fe029 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -873,7 +873,6 @@ static bool __collapse_huge_page_swapin(struct mm_struct *mm,
 					unsigned long address, pmd_t *pmd,
 					int referenced)
 {
-	pte_t pteval;
 	int swapped_in = 0, ret = 0;
 	struct vm_fault vmf = {
 		.vma = vma,
@@ -891,11 +890,11 @@ static bool __collapse_huge_page_swapin(struct mm_struct *mm,
 	vmf.pte = pte_offset_map(pmd, address);
 	for (; vmf.address < address + HPAGE_PMD_NR*PAGE_SIZE;
 			vmf.pte++, vmf.address += PAGE_SIZE) {
-		pteval = *vmf.pte;
-		if (!is_swap_pte(pteval))
+		vmf.orig_pte = *vmf.pte;
+		if (!is_swap_pte(vmf.orig_pte))
 			continue;
 		swapped_in++;
-		ret = do_swap_page(&vmf, pteval);
+		ret = do_swap_page(&vmf);
 
 		/* do_swap_page returns VM_FAULT_RETRY with released mmap_sem */
 		if (ret & VM_FAULT_RETRY) {
diff --git a/mm/memory.c b/mm/memory.c
index 372722e07659..e95e0231b746 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2074,8 +2074,8 @@ static int do_page_mkwrite(struct vm_area_struct *vma, struct page *page,
  * case, all we need to do here is to mark the page as writable and update
  * any related book-keeping.
  */
-static inline int wp_page_reuse(struct vm_fault *vmf, pte_t orig_pte,
-			struct page *page, int page_mkwrite, int dirty_shared)
+static inline int wp_page_reuse(struct vm_fault *vmf, struct page *page,
+				int page_mkwrite, int dirty_shared)
 	__releases(vmf->ptl)
 {
 	struct vm_area_struct *vma = vmf->vma;
@@ -2088,8 +2088,8 @@ static inline int wp_page_reuse(struct vm_fault *vmf, pte_t orig_pte,
 	if (page)
 		page_cpupid_xchg_last(page, (1 << LAST_CPUPID_SHIFT) - 1);
 
-	flush_cache_page(vma, vmf->address, pte_pfn(orig_pte));
-	entry = pte_mkyoung(orig_pte);
+	flush_cache_page(vma, vmf->address, pte_pfn(vmf->orig_pte));
+	entry = pte_mkyoung(vmf->orig_pte);
 	entry = maybe_mkwrite(pte_mkdirty(entry), vma);
 	if (ptep_set_access_flags(vma, vmf->address, vmf->pte, entry, 1))
 		update_mmu_cache(vma, vmf->address, vmf->pte);
@@ -2139,8 +2139,7 @@ static inline int wp_page_reuse(struct vm_fault *vmf, pte_t orig_pte,
  *   held to the old page, as well as updating the rmap.
  * - In any case, unlock the PTL and drop the reference we took to the old page.
  */
-static int wp_page_copy(struct vm_fault *vmf, pte_t orig_pte,
-		struct page *old_page)
+static int wp_page_copy(struct vm_fault *vmf, struct page *old_page)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	struct mm_struct *mm = vma->vm_mm;
@@ -2154,7 +2153,7 @@ static int wp_page_copy(struct vm_fault *vmf, pte_t orig_pte,
 	if (unlikely(anon_vma_prepare(vma)))
 		goto oom;
 
-	if (is_zero_pfn(pte_pfn(orig_pte))) {
+	if (is_zero_pfn(pte_pfn(vmf->orig_pte))) {
 		new_page = alloc_zeroed_user_highpage_movable(vma,
 							      vmf->address);
 		if (!new_page)
@@ -2178,7 +2177,7 @@ static int wp_page_copy(struct vm_fault *vmf, pte_t orig_pte,
 	 * Re-check the pte - we dropped the lock
 	 */
 	vmf->pte = pte_offset_map_lock(mm, vmf->pmd, vmf->address, &vmf->ptl);
-	if (likely(pte_same(*vmf->pte, orig_pte))) {
+	if (likely(pte_same(*vmf->pte, vmf->orig_pte))) {
 		if (old_page) {
 			if (!PageAnon(old_page)) {
 				dec_mm_counter_fast(mm,
@@ -2188,7 +2187,7 @@ static int wp_page_copy(struct vm_fault *vmf, pte_t orig_pte,
 		} else {
 			inc_mm_counter_fast(mm, MM_ANONPAGES);
 		}
-		flush_cache_page(vma, vmf->address, pte_pfn(orig_pte));
+		flush_cache_page(vma, vmf->address, pte_pfn(vmf->orig_pte));
 		entry = mk_pte(new_page, vma->vm_page_prot);
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
 		/*
@@ -2272,7 +2271,7 @@ static int wp_page_copy(struct vm_fault *vmf, pte_t orig_pte,
  * Handle write page faults for VM_MIXEDMAP or VM_PFNMAP for a VM_SHARED
  * mapping
  */
-static int wp_pfn_shared(struct vm_fault *vmf, pte_t orig_pte)
+static int wp_pfn_shared(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 
@@ -2290,16 +2289,15 @@ static int wp_pfn_shared(struct vm_fault *vmf, pte_t orig_pte)
 		 * We might have raced with another page fault while we
 		 * released the pte_offset_map_lock.
 		 */
-		if (!pte_same(*vmf->pte, orig_pte)) {
+		if (!pte_same(*vmf->pte, vmf->orig_pte)) {
 			pte_unmap_unlock(vmf->pte, vmf->ptl);
 			return 0;
 		}
 	}
-	return wp_page_reuse(vmf, orig_pte, NULL, 0, 0);
+	return wp_page_reuse(vmf, NULL, 0, 0);
 }
 
-static int wp_page_shared(struct vm_fault *vmf, pte_t orig_pte,
-		struct page *old_page)
+static int wp_page_shared(struct vm_fault *vmf, struct page *old_page)
 	__releases(vmf->ptl)
 {
 	struct vm_area_struct *vma = vmf->vma;
@@ -2325,7 +2323,7 @@ static int wp_page_shared(struct vm_fault *vmf, pte_t orig_pte,
 		 */
 		vmf->pte = pte_offset_map_lock(vma->vm_mm, vmf->pmd,
 						vmf->address, &vmf->ptl);
-		if (!pte_same(*vmf->pte, orig_pte)) {
+		if (!pte_same(*vmf->pte, vmf->orig_pte)) {
 			unlock_page(old_page);
 			pte_unmap_unlock(vmf->pte, vmf->ptl);
 			put_page(old_page);
@@ -2334,7 +2332,7 @@ static int wp_page_shared(struct vm_fault *vmf, pte_t orig_pte,
 		page_mkwrite = 1;
 	}
 
-	return wp_page_reuse(vmf, orig_pte, old_page, page_mkwrite, 1);
+	return wp_page_reuse(vmf, old_page, page_mkwrite, 1);
 }
 
 /*
@@ -2355,13 +2353,13 @@ static int wp_page_shared(struct vm_fault *vmf, pte_t orig_pte,
  * but allow concurrent faults), with pte both mapped and locked.
  * We return with mmap_sem still held, but pte unmapped and unlocked.
  */
-static int do_wp_page(struct vm_fault *vmf, pte_t orig_pte)
+static int do_wp_page(struct vm_fault *vmf)
 	__releases(vmf->ptl)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	struct page *old_page;
 
-	old_page = vm_normal_page(vma, vmf->address, orig_pte);
+	old_page = vm_normal_page(vma, vmf->address, vmf->orig_pte);
 	if (!old_page) {
 		/*
 		 * VM_MIXEDMAP !pfn_valid() case, or VM_SOFTDIRTY clear on a
@@ -2372,10 +2370,10 @@ static int do_wp_page(struct vm_fault *vmf, pte_t orig_pte)
 		 */
 		if ((vma->vm_flags & (VM_WRITE|VM_SHARED)) ==
 				     (VM_WRITE|VM_SHARED))
-			return wp_pfn_shared(vmf, orig_pte);
+			return wp_pfn_shared(vmf);
 
 		pte_unmap_unlock(vmf->pte, vmf->ptl);
-		return wp_page_copy(vmf, orig_pte, old_page);
+		return wp_page_copy(vmf, old_page);
 	}
 
 	/*
@@ -2390,7 +2388,7 @@ static int do_wp_page(struct vm_fault *vmf, pte_t orig_pte)
 			lock_page(old_page);
 			vmf->pte = pte_offset_map_lock(vma->vm_mm, vmf->pmd,
 					vmf->address, &vmf->ptl);
-			if (!pte_same(*vmf->pte, orig_pte)) {
+			if (!pte_same(*vmf->pte, vmf->orig_pte)) {
 				unlock_page(old_page);
 				pte_unmap_unlock(vmf->pte, vmf->ptl);
 				put_page(old_page);
@@ -2410,12 +2408,12 @@ static int do_wp_page(struct vm_fault *vmf, pte_t orig_pte)
 				page_move_anon_rmap(old_page, vma);
 			}
 			unlock_page(old_page);
-			return wp_page_reuse(vmf, orig_pte, old_page, 0, 0);
+			return wp_page_reuse(vmf, old_page, 0, 0);
 		}
 		unlock_page(old_page);
 	} else if (unlikely((vma->vm_flags & (VM_WRITE|VM_SHARED)) ==
 					(VM_WRITE|VM_SHARED))) {
-		return wp_page_shared(vmf, orig_pte, old_page);
+		return wp_page_shared(vmf, old_page);
 	}
 
 	/*
@@ -2424,7 +2422,7 @@ static int do_wp_page(struct vm_fault *vmf, pte_t orig_pte)
 	get_page(old_page);
 
 	pte_unmap_unlock(vmf->pte, vmf->ptl);
-	return wp_page_copy(vmf, orig_pte, old_page);
+	return wp_page_copy(vmf, old_page);
 }
 
 static void unmap_mapping_range_vma(struct vm_area_struct *vma,
@@ -2512,7 +2510,7 @@ EXPORT_SYMBOL(unmap_mapping_range);
  * We return with the mmap_sem locked or unlocked in the same cases
  * as does filemap_fault().
  */
-int do_swap_page(struct vm_fault *vmf, pte_t orig_pte)
+int do_swap_page(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	struct page *page, *swapcache;
@@ -2523,10 +2521,10 @@ int do_swap_page(struct vm_fault *vmf, pte_t orig_pte)
 	int exclusive = 0;
 	int ret = 0;
 
-	if (!pte_unmap_same(vma->vm_mm, vmf->pmd, vmf->pte, orig_pte))
+	if (!pte_unmap_same(vma->vm_mm, vmf->pmd, vmf->pte, vmf->orig_pte))
 		goto out;
 
-	entry = pte_to_swp_entry(orig_pte);
+	entry = pte_to_swp_entry(vmf->orig_pte);
 	if (unlikely(non_swap_entry(entry))) {
 		if (is_migration_entry(entry)) {
 			migration_entry_wait(vma->vm_mm, vmf->pmd,
@@ -2534,7 +2532,7 @@ int do_swap_page(struct vm_fault *vmf, pte_t orig_pte)
 		} else if (is_hwpoison_entry(entry)) {
 			ret = VM_FAULT_HWPOISON;
 		} else {
-			print_bad_pte(vma, vmf->address, orig_pte, NULL);
+			print_bad_pte(vma, vmf->address, vmf->orig_pte, NULL);
 			ret = VM_FAULT_SIGBUS;
 		}
 		goto out;
@@ -2551,7 +2549,7 @@ int do_swap_page(struct vm_fault *vmf, pte_t orig_pte)
 			 */
 			vmf->pte = pte_offset_map_lock(vma->vm_mm, vmf->pmd,
 					vmf->address, &vmf->ptl);
-			if (likely(pte_same(*vmf->pte, orig_pte)))
+			if (likely(pte_same(*vmf->pte, vmf->orig_pte)))
 				ret = VM_FAULT_OOM;
 			delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
 			goto unlock;
@@ -2608,7 +2606,7 @@ int do_swap_page(struct vm_fault *vmf, pte_t orig_pte)
 	 */
 	vmf->pte = pte_offset_map_lock(vma->vm_mm, vmf->pmd, vmf->address,
 			&vmf->ptl);
-	if (unlikely(!pte_same(*vmf->pte, orig_pte)))
+	if (unlikely(!pte_same(*vmf->pte, vmf->orig_pte)))
 		goto out_nomap;
 
 	if (unlikely(!PageUptodate(page))) {
@@ -2636,9 +2634,10 @@ int do_swap_page(struct vm_fault *vmf, pte_t orig_pte)
 		exclusive = RMAP_EXCLUSIVE;
 	}
 	flush_icache_page(vma, page);
-	if (pte_swp_soft_dirty(orig_pte))
+	if (pte_swp_soft_dirty(vmf->orig_pte))
 		pte = pte_mksoft_dirty(pte);
 	set_pte_at(vma->vm_mm, vmf->address, vmf->pte, pte);
+	vmf->orig_pte = pte;
 	if (page == swapcache) {
 		do_page_add_anon_rmap(page, vma, vmf->address, exclusive);
 		mem_cgroup_commit_charge(page, memcg, true, false);
@@ -2668,7 +2667,7 @@ int do_swap_page(struct vm_fault *vmf, pte_t orig_pte)
 	}
 
 	if (vmf->flags & FAULT_FLAG_WRITE) {
-		ret |= do_wp_page(vmf, pte);
+		ret |= do_wp_page(vmf);
 		if (ret & VM_FAULT_ERROR)
 			ret &= VM_FAULT_ERROR;
 		goto out;
@@ -3328,7 +3327,7 @@ static int numa_migrate_prep(struct page *page, struct vm_area_struct *vma,
 	return mpol_misplaced(page, vma, addr);
 }
 
-static int do_numa_page(struct vm_fault *vmf, pte_t pte)
+static int do_numa_page(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	struct page *page = NULL;
@@ -3336,6 +3335,7 @@ static int do_numa_page(struct vm_fault *vmf, pte_t pte)
 	int last_cpupid;
 	int target_nid;
 	bool migrated = false;
+	pte_t pte = vmf->orig_pte;
 	bool was_writable = pte_write(pte);
 	int flags = 0;
 
@@ -3486,8 +3486,7 @@ static int handle_pte_fault(struct vm_fault *vmf)
 		 * So now it's safe to run pte_offset_map().
 		 */
 		vmf->pte = pte_offset_map(vmf->pmd, vmf->address);
-
-		entry = *vmf->pte;
+		vmf->orig_pte = *vmf->pte;
 
 		/*
 		 * some architectures can have larger ptes than wordsize,
@@ -3498,7 +3497,7 @@ static int handle_pte_fault(struct vm_fault *vmf)
 		 * ptl lock held. So here a barrier will do.
 		 */
 		barrier();
-		if (pte_none(entry)) {
+		if (pte_none(vmf->orig_pte)) {
 			pte_unmap(vmf->pte);
 			vmf->pte = NULL;
 		}
@@ -3511,19 +3510,20 @@ static int handle_pte_fault(struct vm_fault *vmf)
 			return do_fault(vmf);
 	}
 
-	if (!pte_present(entry))
-		return do_swap_page(vmf, entry);
+	if (!pte_present(vmf->orig_pte))
+		return do_swap_page(vmf);
 
-	if (pte_protnone(entry) && vma_is_accessible(vmf->vma))
-		return do_numa_page(vmf, entry);
+	if (pte_protnone(vmf->orig_pte) && vma_is_accessible(vmf->vma))
+		return do_numa_page(vmf);
 
 	vmf->ptl = pte_lockptr(vmf->vma->vm_mm, vmf->pmd);
 	spin_lock(vmf->ptl);
+	entry = vmf->orig_pte;
 	if (unlikely(!pte_same(*vmf->pte, entry)))
 		goto unlock;
 	if (vmf->flags & FAULT_FLAG_WRITE) {
 		if (!pte_write(entry))
-			return do_wp_page(vmf, entry);
+			return do_wp_page(vmf);
 		entry = pte_mkdirty(entry);
 	}
 	entry = pte_mkyoung(entry);
-- 
2.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
