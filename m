Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7DEA2828E4
	for <linux-mm@kvack.org>; Mon,  7 Mar 2016 06:57:28 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id fy10so77539972pac.1
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 03:57:28 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id 21si2717103pfj.62.2016.03.07.03.57.23
        for <linux-mm@kvack.org>;
        Mon, 07 Mar 2016 03:57:23 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 4/4] thp: rewrite freeze_page()/unfreeze_page() with generic rmap walkers
Date: Mon,  7 Mar 2016 14:57:18 +0300
Message-Id: <1457351838-114702-5-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1457351838-114702-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1457351838-114702-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

freeze_page() and unfreeze_page() helpers evolved in rather complex
beasts. It would be nice to cut complexity of this code.

This patch rewrites freeze_page() using standard try_to_unmap().
unfreeze_page() is rewritten with remove_migration_ptes().

The result is much simpler.

But the new variant is somewhat slower for PTE-mapped THPs.
Current helpers iterates over VMAs the compound page is mapped to, and
then over ptes within this VMA. New helpers iterates over small page,
then over VMA the small page mapped to, and only then find relevant pte.

We have short cut for PMD-mapped THP: we directly install migration
entries on PMD split.

I don't think the slowdown is critical, considering how much simpler
result is and that split_huge_page() is quite rare nowadays. It only
happens due memory pressure or migration.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/huge_mm.h |  10 ++-
 mm/huge_memory.c        | 201 +++++++-----------------------------------------
 mm/rmap.c               |   9 ++-
 3 files changed, 40 insertions(+), 180 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index c47067151ffd..74271f9e3c03 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -101,18 +101,20 @@ static inline int split_huge_page(struct page *page)
 void deferred_split_huge_page(struct page *page);
 
 void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
-		unsigned long address);
+		unsigned long address, bool freeze);
 
 #define split_huge_pmd(__vma, __pmd, __address)				\
 	do {								\
 		pmd_t *____pmd = (__pmd);				\
 		if (pmd_trans_huge(*____pmd)				\
 					|| pmd_devmap(*____pmd))	\
-			__split_huge_pmd(__vma, __pmd, __address);	\
+			__split_huge_pmd(__vma, __pmd, __address,	\
+						false);			\
 	}  while (0)
 
 
-void split_huge_pmd_address(struct vm_area_struct *vma, unsigned long address);
+void split_huge_pmd_address(struct vm_area_struct *vma, unsigned long address,
+		bool freeze);
 
 #if HPAGE_PMD_ORDER >= MAX_ORDER
 #error "hugepages can't be allocated by the buddy allocator"
@@ -183,7 +185,7 @@ static inline void deferred_split_huge_page(struct page *page) {}
 	do { } while (0)
 
 static inline void split_huge_pmd_address(struct vm_area_struct *vma,
-		unsigned long address) {}
+		unsigned long address, bool freeze) {}
 
 static inline int hugepage_madvise(struct vm_area_struct *vma,
 				   unsigned long *vm_flags, int advice)
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 354464b484a7..1f18687b96d3 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -3020,7 +3020,7 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 }
 
 void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
-		unsigned long address)
+		unsigned long address, bool freeze)
 {
 	spinlock_t *ptl;
 	struct mm_struct *mm = vma->vm_mm;
@@ -3037,7 +3037,7 @@ void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 			page = NULL;
 	} else if (!pmd_devmap(*pmd))
 		goto out;
-	__split_huge_pmd_locked(vma, pmd, haddr, false);
+	__split_huge_pmd_locked(vma, pmd, haddr, freeze);
 out:
 	spin_unlock(ptl);
 	mmu_notifier_invalidate_range_end(mm, haddr, haddr + HPAGE_PMD_SIZE);
@@ -3049,7 +3049,8 @@ out:
 	}
 }
 
-void split_huge_pmd_address(struct vm_area_struct *vma, unsigned long address)
+void split_huge_pmd_address(struct vm_area_struct *vma, unsigned long address,
+		bool freeze)
 {
 	pgd_t *pgd;
 	pud_t *pud;
@@ -3070,7 +3071,7 @@ void split_huge_pmd_address(struct vm_area_struct *vma, unsigned long address)
 	 * Caller holds the mmap_sem write mode, so a huge pmd cannot
 	 * materialize from under us.
 	 */
-	split_huge_pmd(vma, pmd, address);
+	__split_huge_pmd(vma, pmd, address, freeze);
 }
 
 void vma_adjust_trans_huge(struct vm_area_struct *vma,
@@ -3086,7 +3087,7 @@ void vma_adjust_trans_huge(struct vm_area_struct *vma,
 	if (start & ~HPAGE_PMD_MASK &&
 	    (start & HPAGE_PMD_MASK) >= vma->vm_start &&
 	    (start & HPAGE_PMD_MASK) + HPAGE_PMD_SIZE <= vma->vm_end)
-		split_huge_pmd_address(vma, start);
+		split_huge_pmd_address(vma, start, false);
 
 	/*
 	 * If the new end address isn't hpage aligned and it could
@@ -3096,7 +3097,7 @@ void vma_adjust_trans_huge(struct vm_area_struct *vma,
 	if (end & ~HPAGE_PMD_MASK &&
 	    (end & HPAGE_PMD_MASK) >= vma->vm_start &&
 	    (end & HPAGE_PMD_MASK) + HPAGE_PMD_SIZE <= vma->vm_end)
-		split_huge_pmd_address(vma, end);
+		split_huge_pmd_address(vma, end, false);
 
 	/*
 	 * If we're also updating the vma->vm_next->vm_start, if the new
@@ -3110,184 +3111,36 @@ void vma_adjust_trans_huge(struct vm_area_struct *vma,
 		if (nstart & ~HPAGE_PMD_MASK &&
 		    (nstart & HPAGE_PMD_MASK) >= next->vm_start &&
 		    (nstart & HPAGE_PMD_MASK) + HPAGE_PMD_SIZE <= next->vm_end)
-			split_huge_pmd_address(next, nstart);
+			split_huge_pmd_address(next, nstart, false);
 	}
 }
 
-static void freeze_page_vma(struct vm_area_struct *vma, struct page *page,
-		unsigned long address)
+static void freeze_page(struct page *page)
 {
-	unsigned long haddr = address & HPAGE_PMD_MASK;
-	spinlock_t *ptl;
-	pgd_t *pgd;
-	pud_t *pud;
-	pmd_t *pmd;
-	pte_t *pte;
-	int i, nr = HPAGE_PMD_NR;
-
-	/* Skip pages which doesn't belong to the VMA */
-	if (address < vma->vm_start) {
-		int off = (vma->vm_start - address) >> PAGE_SHIFT;
-		page += off;
-		nr -= off;
-		address = vma->vm_start;
-	}
-
-	pgd = pgd_offset(vma->vm_mm, address);
-	if (!pgd_present(*pgd))
-		return;
-	pud = pud_offset(pgd, address);
-	if (!pud_present(*pud))
-		return;
-	pmd = pmd_offset(pud, address);
-	ptl = pmd_lock(vma->vm_mm, pmd);
-	if (!pmd_present(*pmd)) {
-		spin_unlock(ptl);
-		return;
-	}
-	if (pmd_trans_huge(*pmd)) {
-		if (page == pmd_page(*pmd))
-			__split_huge_pmd_locked(vma, pmd, haddr, true);
-		spin_unlock(ptl);
-		return;
-	}
-	spin_unlock(ptl);
-
-	pte = pte_offset_map_lock(vma->vm_mm, pmd, address, &ptl);
-	for (i = 0; i < nr; i++, address += PAGE_SIZE, page++, pte++) {
-		pte_t entry, swp_pte;
-		swp_entry_t swp_entry;
-
-		/*
-		 * We've just crossed page table boundary: need to map next one.
-		 * It can happen if THP was mremaped to non PMD-aligned address.
-		 */
-		if (unlikely(address == haddr + HPAGE_PMD_SIZE)) {
-			pte_unmap_unlock(pte - 1, ptl);
-			pmd = mm_find_pmd(vma->vm_mm, address);
-			if (!pmd)
-				return;
-			pte = pte_offset_map_lock(vma->vm_mm, pmd,
-					address, &ptl);
-		}
-
-		if (!pte_present(*pte))
-			continue;
-		if (page_to_pfn(page) != pte_pfn(*pte))
-			continue;
-		flush_cache_page(vma, address, page_to_pfn(page));
-		entry = ptep_clear_flush(vma, address, pte);
-		if (pte_dirty(entry))
-			SetPageDirty(page);
-		swp_entry = make_migration_entry(page, pte_write(entry));
-		swp_pte = swp_entry_to_pte(swp_entry);
-		if (pte_soft_dirty(entry))
-			swp_pte = pte_swp_mksoft_dirty(swp_pte);
-		set_pte_at(vma->vm_mm, address, pte, swp_pte);
-		page_remove_rmap(page, false);
-		put_page(page);
-	}
-	pte_unmap_unlock(pte - 1, ptl);
-}
-
-static void freeze_page(struct anon_vma *anon_vma, struct page *page)
-{
-	struct anon_vma_chain *avc;
-	pgoff_t pgoff = page_to_pgoff(page);
+	enum ttu_flags ttu_flags = TTU_MIGRATION | TTU_IGNORE_MLOCK |
+		TTU_IGNORE_ACCESS | TTU_RMAP_LOCKED;
+	int i, ret;
 
 	VM_BUG_ON_PAGE(!PageHead(page), page);
 
-	anon_vma_interval_tree_foreach(avc, &anon_vma->rb_root, pgoff,
-			pgoff + HPAGE_PMD_NR - 1) {
-		unsigned long address = __vma_address(page, avc->vma);
-
-		mmu_notifier_invalidate_range_start(avc->vma->vm_mm,
-				address, address + HPAGE_PMD_SIZE);
-		freeze_page_vma(avc->vma, page, address);
-		mmu_notifier_invalidate_range_end(avc->vma->vm_mm,
-				address, address + HPAGE_PMD_SIZE);
-	}
-}
-
-static void unfreeze_page_vma(struct vm_area_struct *vma, struct page *page,
-		unsigned long address)
-{
-	spinlock_t *ptl;
-	pmd_t *pmd;
-	pte_t *pte, entry;
-	swp_entry_t swp_entry;
-	unsigned long haddr = address & HPAGE_PMD_MASK;
-	int i, nr = HPAGE_PMD_NR;
-
-	/* Skip pages which doesn't belong to the VMA */
-	if (address < vma->vm_start) {
-		int off = (vma->vm_start - address) >> PAGE_SHIFT;
-		page += off;
-		nr -= off;
-		address = vma->vm_start;
-	}
-
-	pmd = mm_find_pmd(vma->vm_mm, address);
-	if (!pmd)
-		return;
-
-	pte = pte_offset_map_lock(vma->vm_mm, pmd, address, &ptl);
-	for (i = 0; i < nr; i++, address += PAGE_SIZE, page++, pte++) {
-		/*
-		 * We've just crossed page table boundary: need to map next one.
-		 * It can happen if THP was mremaped to non-PMD aligned address.
-		 */
-		if (unlikely(address == haddr + HPAGE_PMD_SIZE)) {
-			pte_unmap_unlock(pte - 1, ptl);
-			pmd = mm_find_pmd(vma->vm_mm, address);
-			if (!pmd)
-				return;
-			pte = pte_offset_map_lock(vma->vm_mm, pmd,
-					address, &ptl);
-		}
-
-		if (!is_swap_pte(*pte))
-			continue;
-
-		swp_entry = pte_to_swp_entry(*pte);
-		if (!is_migration_entry(swp_entry))
-			continue;
-		if (migration_entry_to_page(swp_entry) != page)
-			continue;
-
-		get_page(page);
-		page_add_anon_rmap(page, vma, address, false);
-
-		entry = pte_mkold(mk_pte(page, vma->vm_page_prot));
-		if (PageDirty(page))
-			entry = pte_mkdirty(entry);
-		if (is_write_migration_entry(swp_entry))
-			entry = maybe_mkwrite(entry, vma);
-
-		flush_dcache_page(page);
-		set_pte_at(vma->vm_mm, address, pte, entry);
+	/* We only need TTU_SPLIT_HUGE_PMD once */
+	ret = try_to_unmap(page, ttu_flags | TTU_SPLIT_HUGE_PMD);
+	for (i = 1; !ret && i < HPAGE_PMD_NR; i++) {
+		/* Cut short if the page is unmapped */
+		if (page_count(page) == 1)
+			return;
 
-		/* No need to invalidate - it was non-present before */
-		update_mmu_cache(vma, address, pte);
+		ret = try_to_unmap(page + i, ttu_flags);
 	}
-	pte_unmap_unlock(pte - 1, ptl);
+	VM_BUG_ON(ret);
 }
 
-static void unfreeze_page(struct anon_vma *anon_vma, struct page *page)
+static void unfreeze_page(struct page *page)
 {
-	struct anon_vma_chain *avc;
-	pgoff_t pgoff = page_to_pgoff(page);
-
-	anon_vma_interval_tree_foreach(avc, &anon_vma->rb_root,
-			pgoff, pgoff + HPAGE_PMD_NR - 1) {
-		unsigned long address = __vma_address(page, avc->vma);
+	int i;
 
-		mmu_notifier_invalidate_range_start(avc->vma->vm_mm,
-				address, address + HPAGE_PMD_SIZE);
-		unfreeze_page_vma(avc->vma, page, address);
-		mmu_notifier_invalidate_range_end(avc->vma->vm_mm,
-				address, address + HPAGE_PMD_SIZE);
-	}
+	for (i = 0; i < HPAGE_PMD_NR; i++)
+		remove_migration_ptes(page + i, page + i, true);
 }
 
 static void __split_huge_page_tail(struct page *head, int tail,
@@ -3365,7 +3218,7 @@ static void __split_huge_page(struct page *page, struct list_head *list)
 	ClearPageCompound(head);
 	spin_unlock_irq(&zone->lru_lock);
 
-	unfreeze_page(page_anon_vma(head), head);
+	unfreeze_page(head);
 
 	for (i = 0; i < HPAGE_PMD_NR; i++) {
 		struct page *subpage = head + i;
@@ -3461,7 +3314,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 	}
 
 	mlocked = PageMlocked(page);
-	freeze_page(anon_vma, head);
+	freeze_page(head);
 	VM_BUG_ON_PAGE(compound_mapcount(head), head);
 
 	/* Make sure the page is not on per-CPU pagevec as it takes pin */
@@ -3490,7 +3343,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 		BUG();
 	} else {
 		spin_unlock_irqrestore(&pgdata->split_queue_lock, flags);
-		unfreeze_page(anon_vma, head);
+		unfreeze_page(head);
 		ret = -EBUSY;
 	}
 
diff --git a/mm/rmap.c b/mm/rmap.c
index 945933a01010..8fa96fa3225e 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1431,8 +1431,13 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	if ((flags & TTU_MUNLOCK) && !(vma->vm_flags & VM_LOCKED))
 		goto out;
 
-	if (flags & TTU_SPLIT_HUGE_PMD)
-		split_huge_pmd_address(vma, address);
+	if (flags & TTU_SPLIT_HUGE_PMD) {
+		split_huge_pmd_address(vma, address, flags & TTU_MIGRATION);
+		/* check if we have anything to do after split */
+		if (page_mapcount(page) == 0)
+			goto out;
+	}
+
 	pte = page_check_address(page, mm, address, &ptl, 0);
 	if (!pte)
 		goto out;
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
