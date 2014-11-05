Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 1402A6B009E
	for <linux-mm@kvack.org>; Wed,  5 Nov 2014 09:50:29 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id kx10so898265pab.40
        for <linux-mm@kvack.org>; Wed, 05 Nov 2014 06:50:28 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id qd3si3316359pac.23.2014.11.05.06.50.17
        for <linux-mm@kvack.org>;
        Wed, 05 Nov 2014 06:50:18 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 18/19] tho, mm: use migration entries to freeze page counts on split
Date: Wed,  5 Nov 2014 16:49:53 +0200
Message-Id: <1415198994-15252-19-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1415198994-15252-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1415198994-15252-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Currently, we rely on compound_lock() to get page counts stable on
splitting page refcounting. To get it work we also take the lock on
get_page() and put_page() which is hot path.

This patch rework splitting code to setup migration entries to stabilaze
page count/mapcount before distribute refcounts. It means we don't need
to compound lock in get_page()/put_page().

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/migrate.h |   3 +
 mm/huge_memory.c        | 173 ++++++++++++++++++++++++++++++++++--------------
 mm/migrate.c            |  15 +++--
 3 files changed, 135 insertions(+), 56 deletions(-)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index a2901c414664..edbbed27fb7c 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -55,6 +55,9 @@ extern int migrate_page_move_mapping(struct address_space *mapping,
 		struct page *newpage, struct page *page,
 		struct buffer_head *head, enum migrate_mode mode,
 		int extra_count);
+extern int remove_migration_pte(struct page *new, struct vm_area_struct *vma,
+		unsigned long addr, void *old);
+
 #else
 
 static inline void putback_movable_pages(struct list_head *l) {}
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 555a9134dfa0..4e087091a809 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -23,6 +23,7 @@
 #include <linux/pagemap.h>
 #include <linux/migrate.h>
 #include <linux/hashtable.h>
+#include <linux/swapops.h>
 
 #include <asm/tlb.h>
 #include <asm/pgalloc.h>
@@ -1567,7 +1568,7 @@ static void __split_huge_zero_page_pmd(struct vm_area_struct *vma,
 
 
 static void __split_huge_pmd_locked(struct vm_area_struct *vma,
-		pmd_t *pmd, unsigned long address)
+		pmd_t *pmd, unsigned long address, int freeze)
 {
 	unsigned long haddr = address & HPAGE_PMD_MASK;
 	struct page *page;
@@ -1600,12 +1601,19 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma,
 		 * any possibility that pte_numa leaks to a PROT_NONE VMA by
 		 * accident.
 		 */
-		entry = mk_pte(page + i, vma->vm_page_prot);
-		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
-		if (!pmd_write(*pmd))
-			entry = pte_wrprotect(entry);
-		if (!pmd_young(*pmd))
-			entry = pte_mkold(entry);
+		if (freeze) {
+			swp_entry_t swp_entry;
+			swp_entry = make_migration_entry(page + i,
+					pmd_write(*pmd));
+			entry = swp_entry_to_pte(swp_entry);
+		} else {
+			entry = mk_pte(page + i, vma->vm_page_prot);
+			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+			if (!pmd_write(*pmd))
+				entry = pte_wrprotect(entry);
+			if (!pmd_young(*pmd))
+				entry = pte_mkold(entry);
+		}
 		pte = pte_offset_map(&_pmd, haddr);
 		BUG_ON(!pte_none(*pte));
 		atomic_inc(&page[i]._mapcount);
@@ -1631,7 +1639,7 @@ void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
 	ptl = pmd_lock(mm, pmd);
 	if (likely(pmd_trans_huge(*pmd)))
-		__split_huge_pmd_locked(vma, pmd, address);
+		__split_huge_pmd_locked(vma, pmd, address, 0);
 	spin_unlock(ptl);
 	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
 }
@@ -1666,20 +1674,106 @@ static void split_huge_page_address(struct vm_area_struct *vma,
 	__split_huge_pmd(vma, pmd, address);
 }
 
-static int __split_huge_page_refcount(struct page *page,
-				       struct list_head *list)
+static void freeze_page(struct anon_vma *anon_vma, struct page *page)
+{
+	struct anon_vma_chain *avc;
+	struct mm_struct *mm;
+	struct vm_area_struct *vma;
+	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+	unsigned long addr, haddr;
+	unsigned long mmun_start, mmun_end;
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
+	pte_t *start_pte, *pte;
+	spinlock_t *ptl;
+
+	anon_vma_interval_tree_foreach(avc, &anon_vma->rb_root, pgoff, pgoff) {
+		vma = avc->vma;
+		mm = vma->vm_mm;
+		haddr = addr = vma_address(page, vma) & HPAGE_PMD_MASK;
+		mmun_start = haddr;
+		mmun_end   = haddr + HPAGE_PMD_SIZE;
+		mmu_notifier_invalidate_range_start(vma->vm_mm,
+				mmun_start, mmun_end);
+
+		pgd = pgd_offset(vma->vm_mm, addr);
+		if (!pgd_present(*pgd))
+			goto next;
+		pud = pud_offset(pgd, addr);
+		if (!pud_present(*pud))
+			goto next;
+		pmd = pmd_offset(pud, addr);
+
+		ptl = pmd_lock(vma->vm_mm, pmd);
+		if (!pmd_present(*pmd)) {
+			spin_unlock(ptl);
+			goto next;
+		}
+		if (pmd_trans_huge(*pmd)) {
+			if (page == pmd_page(*pmd))
+				__split_huge_pmd_locked(vma, pmd, addr, 1);
+			spin_unlock(ptl);
+			goto next;
+		}
+		spin_unlock(ptl);
+
+		start_pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
+		pte = start_pte;
+		do {
+			pte_t entry, swp_pte;
+			swp_entry_t swp_entry;
+
+			if (!pte_present(*pte))
+				continue;
+			if (page_to_pfn(page) != pte_pfn(*pte))
+				continue;
+			flush_cache_page(vma, addr, page_to_pfn(page));
+			entry = ptep_clear_flush(vma, addr, pte);
+			swp_entry = make_migration_entry(page,
+					pte_write(entry));
+			swp_pte = swp_entry_to_pte(swp_entry);
+			if (pte_soft_dirty(entry))
+				swp_pte = pte_swp_mksoft_dirty(swp_pte);
+			set_pte_at(vma->vm_mm, addr, pte, swp_pte);
+		} while (pte++, addr += PAGE_SIZE, page++, addr != mmun_end);
+		pte_unmap_unlock(start_pte, ptl);
+next:
+		mmu_notifier_invalidate_range_end(vma->vm_mm,
+				mmun_start, mmun_end);
+	}
+}
+
+static void unfreeze_page(struct anon_vma *anon_vma, struct page *page)
+{
+	struct anon_vma_chain *avc;
+	struct vm_area_struct *vma;
+	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+	unsigned long addr;
+
+	anon_vma_interval_tree_foreach(avc, &anon_vma->rb_root, pgoff, pgoff) {
+		vma = avc->vma;
+		addr = vma_address(page, vma);
+		remove_migration_pte(page, vma, addr, page);
+	}
+}
+
+static int __split_huge_page_refcount(struct anon_vma *anon_vma,
+		struct page *page, struct list_head *list)
 {
 	int i;
 	struct zone *zone = page_zone(page);
 	struct lruvec *lruvec;
 	int tail_mapcount = 0;
 
+	lock_page(page);
+	freeze_page(anon_vma, page);
+	BUG_ON(compound_mapcount(page));
+
 	/* prevent PageLRU to go away from under us, and freeze lru stats */
 	spin_lock_irq(&zone->lru_lock);
 	lruvec = mem_cgroup_page_lruvec(page, zone);
 
-	compound_lock(page);
-
 	/*
 	 * We cannot split pinned THP page: we expect page count to be equal
 	 * to sum of mapcount of all sub-pages plus one (split_huge_page()
@@ -1695,8 +1789,9 @@ static int __split_huge_page_refcount(struct page *page,
 		tail_mapcount += page_mapcount(page + i);
 	if (tail_mapcount != page_count(page) - 1) {
 		BUG_ON(tail_mapcount > page_count(page) - 1);
-		compound_unlock(page);
 		spin_unlock_irq(&zone->lru_lock);
+		unfreeze_page(anon_vma, page);
+		unlock_page(page);
 		return -EBUSY;
 	}
 
@@ -1743,6 +1838,7 @@ static int __split_huge_page_refcount(struct page *page,
 				      (1L << PG_mlocked) |
 				      (1L << PG_uptodate) |
 				      (1L << PG_active) |
+				      (1L << PG_locked) |
 				      (1L << PG_unevictable)));
 		page_tail->flags |= (1L << PG_dirty);
 
@@ -1768,12 +1864,16 @@ static int __split_huge_page_refcount(struct page *page,
 	__mod_zone_page_state(zone, NR_ANON_TRANSPARENT_HUGEPAGES, -1);
 
 	ClearPageCompound(page);
-	compound_unlock(page);
 	spin_unlock_irq(&zone->lru_lock);
 
+	unfreeze_page(anon_vma, page);
+	unlock_page(page);
+
 	for (i = 1; i < HPAGE_PMD_NR; i++) {
 		struct page *page_tail = page + i;
 		BUG_ON(page_count(page_tail) <= 0);
+		unfreeze_page(anon_vma, page_tail);
+		unlock_page(page_tail);
 		/*
 		 * Tail pages may be freed if there wasn't any mapping
 		 * like if add_to_swap() is running on a lru page that
@@ -1802,10 +1902,8 @@ static int __split_huge_page_refcount(struct page *page,
 int split_huge_page_to_list(struct page *page, struct list_head *list)
 {
 	struct anon_vma *anon_vma;
-	struct anon_vma_chain *avc;
-	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
 	int i, tail_mapcount;
-	int ret = -EBUSY;
+	int ret = 0;
 
 	BUG_ON(is_huge_zero_page(page));
 	BUG_ON(!PageAnon(page));
@@ -1819,15 +1917,12 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 	 */
 	anon_vma = page_get_anon_vma(page);
 	if (!anon_vma)
-		goto out;
+		return -EBUSY;
 	anon_vma_lock_write(anon_vma);
 
-	if (!PageCompound(page)) {
-		ret = 0;
-		goto out_unlock;
-	}
-
 	BUG_ON(!PageSwapBacked(page));
+	if (!PageCompound(page))
+		goto out;
 
 	/*
 	 * Racy check if __split_huge_page_refcount() can be successful, before
@@ -1839,39 +1934,15 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 	if (tail_mapcount != page_count(page) - 1) {
 		VM_BUG_ON_PAGE(tail_mapcount > page_count(page) - 1, page);
 		ret = -EBUSY;
-		goto out_unlock;
-	}
-
-	anon_vma_interval_tree_foreach(avc, &anon_vma->rb_root, pgoff, pgoff) {
-		struct vm_area_struct *vma = avc->vma;
-		unsigned long addr = vma_address(page, vma);
-		spinlock_t *ptl;
-		pmd_t *pmd;
-		unsigned long haddr = addr & HPAGE_PMD_MASK;
-		unsigned long mmun_start;	/* For mmu_notifiers */
-		unsigned long mmun_end;		/* For mmu_notifiers */
-
-		mmun_start = haddr;
-		mmun_end   = haddr + HPAGE_PMD_SIZE;
-		mmu_notifier_invalidate_range_start(vma->vm_mm,
-				mmun_start, mmun_end);
-		pmd = page_check_address_pmd(page, vma->vm_mm, addr, &ptl);
-		if (pmd) {
-			__split_huge_pmd_locked(vma, pmd, addr);
-			spin_unlock(ptl);
-		}
-		mmu_notifier_invalidate_range_end(vma->vm_mm,
-				mmun_start, mmun_end);
+		goto out;
 	}
 
-	BUG_ON(compound_mapcount(page));
-	ret = __split_huge_page_refcount(page, list);
+	ret = __split_huge_page_refcount(anon_vma, page, list);
 	BUG_ON(!ret && PageCompound(page));
-
-out_unlock:
+out:
 	anon_vma_unlock_write(anon_vma);
 	put_anon_vma(anon_vma);
-out:
+
 	if (ret)
 		count_vm_event(THP_SPLIT_PAGE_FAILED);
 	else
diff --git a/mm/migrate.c b/mm/migrate.c
index 4dc941100388..326064547b51 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -102,7 +102,7 @@ void putback_movable_pages(struct list_head *l)
 /*
  * Restore a potential migration pte to a working pte entry
  */
-static int remove_migration_pte(struct page *new, struct vm_area_struct *vma,
+int remove_migration_pte(struct page *new, struct vm_area_struct *vma,
 				 unsigned long addr, void *old)
 {
 	struct mm_struct *mm = vma->vm_mm;
@@ -139,7 +139,7 @@ static int remove_migration_pte(struct page *new, struct vm_area_struct *vma,
 	entry = pte_to_swp_entry(pte);
 
 	if (!is_migration_entry(entry) ||
-	    migration_entry_to_page(entry) != old)
+	    compound_head(migration_entry_to_page(entry)) != old)
 		goto unlock;
 
 	get_page(new);
@@ -162,9 +162,14 @@ static int remove_migration_pte(struct page *new, struct vm_area_struct *vma,
 			hugepage_add_anon_rmap(new, vma, addr);
 		else
 			page_dup_rmap(new, false);
-	} else if (PageAnon(new))
-		page_add_anon_rmap(new, vma, addr, false);
-	else
+	} else if (PageAnon(new)) {
+		/* unfreeze_page() case: the page wasn't removed from rmap */
+		if (PageCompound(new)) {
+			VM_BUG_ON(compound_head(new) != old);
+			put_page(new);
+		} else
+			page_add_anon_rmap(new, vma, addr, false);
+	} else
 		page_add_file_rmap(new);
 
 	/* No need to invalidate - it was non-present before */
-- 
2.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
