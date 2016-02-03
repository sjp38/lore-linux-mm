Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id B9D1C828DF
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 10:15:44 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id uo6so15231256pac.1
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 07:15:44 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id a6si9902783pfj.20.2016.02.03.07.15.43
        for <linux-mm@kvack.org>;
        Wed, 03 Feb 2016 07:15:43 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 4/4] thp: rewrite freeze_page()/unfreeze_page() with generic rmap walkers
Date: Wed,  3 Feb 2016 18:14:19 +0300
Message-Id: <1454512459-94334-5-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1454512459-94334-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1454512459-94334-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

freeze_page() and unfreeze_page() helpers evolved in rather complex
beasts. It would be nice to cut complexity of this code.

This patch rewrites freeze_page() using standard try_to_unmap().
unfreeze_page() is rewritten with remove_migration_ptes().

The result is much simpler.

But the new variant is somewhat slower. Current helpers iterates over
VMAs the compound page is mapped to, and then over ptes within this VMA.
New helpers iterates over small page, then over VMA the small page
mapped to, and only then find relevant pte.

Also we've lost optimization which allows to split PMD directly into
migration entries.

I don't think the slowdown is critical, considering how much simpler
result is and that split_huge_page() is quite rare nowadays. It only
happens due memory pressure or migration.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c | 214 +++++++------------------------------------------------
 1 file changed, 24 insertions(+), 190 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 4213c76c8434..3bab26781f8d 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2825,7 +2825,7 @@ static void __split_huge_zero_page_pmd(struct vm_area_struct *vma,
 }
 
 static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
-		unsigned long haddr, bool freeze)
+		unsigned long haddr)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	struct page *page;
@@ -2867,18 +2867,12 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 		 * transferred to avoid any possibility of altering
 		 * permissions across VMAs.
 		 */
-		if (freeze) {
-			swp_entry_t swp_entry;
-			swp_entry = make_migration_entry(page + i, write);
-			entry = swp_entry_to_pte(swp_entry);
-		} else {
-			entry = mk_pte(page + i, vma->vm_page_prot);
-			entry = maybe_mkwrite(entry, vma);
-			if (!write)
-				entry = pte_wrprotect(entry);
-			if (!young)
-				entry = pte_mkold(entry);
-		}
+		entry = mk_pte(page + i, vma->vm_page_prot);
+		entry = maybe_mkwrite(entry, vma);
+		if (!write)
+			entry = pte_wrprotect(entry);
+		if (!young)
+			entry = pte_mkold(entry);
 		if (dirty)
 			SetPageDirty(page + i);
 		pte = pte_offset_map(&_pmd, haddr);
@@ -2931,13 +2925,6 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 	 */
 	pmdp_invalidate(vma, haddr, pmd);
 	pmd_populate(mm, pmd, pgtable);
-
-	if (freeze) {
-		for (i = 0; i < HPAGE_PMD_NR; i++, haddr += PAGE_SIZE) {
-			page_remove_rmap(page + i, false);
-			put_page(page + i);
-		}
-	}
 }
 
 void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
@@ -2958,7 +2945,7 @@ void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 			page = NULL;
 	} else if (!pmd_devmap(*pmd))
 		goto out;
-	__split_huge_pmd_locked(vma, pmd, haddr, false);
+	__split_huge_pmd_locked(vma, pmd, haddr);
 out:
 	spin_unlock(ptl);
 	mmu_notifier_invalidate_range_end(mm, haddr, haddr + HPAGE_PMD_SIZE);
@@ -3035,180 +3022,27 @@ void vma_adjust_trans_huge(struct vm_area_struct *vma,
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
-
-		/* No need to invalidate - it was non-present before */
-		update_mmu_cache(vma, address, pte);
-	}
-	pte_unmap_unlock(pte - 1, ptl);
+	/* We only need TTU_SPLIT_HUGE_PMD once */
+	ret = try_to_unmap(page, ttu_flags | TTU_SPLIT_HUGE_PMD);
+	for (i = 1; !ret && i < HPAGE_PMD_NR; i++)
+		ret = try_to_unmap(page + i, ttu_flags);
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
@@ -3286,7 +3120,7 @@ static void __split_huge_page(struct page *page, struct list_head *list)
 	ClearPageCompound(head);
 	spin_unlock_irq(&zone->lru_lock);
 
-	unfreeze_page(page_anon_vma(head), head);
+	unfreeze_page(head);
 
 	for (i = 0; i < HPAGE_PMD_NR; i++) {
 		struct page *subpage = head + i;
@@ -3382,7 +3216,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 	}
 
 	mlocked = PageMlocked(page);
-	freeze_page(anon_vma, head);
+	freeze_page(head);
 	VM_BUG_ON_PAGE(compound_mapcount(head), head);
 
 	/* Make sure the page is not on per-CPU pagevec as it takes pin */
@@ -3411,7 +3245,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 		BUG();
 	} else {
 		spin_unlock_irqrestore(&pgdata->split_queue_lock, flags);
-		unfreeze_page(anon_vma, head);
+		unfreeze_page(head);
 		ret = -EBUSY;
 	}
 
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
