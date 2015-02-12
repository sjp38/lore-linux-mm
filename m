Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 51F55900016
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 11:19:18 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id fa1so12449971pad.2
        for <linux-mm@kvack.org>; Thu, 12 Feb 2015 08:19:18 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id hn1si2942142pdb.148.2015.02.12.08.19.05
        for <linux-mm@kvack.org>;
        Thu, 12 Feb 2015 08:19:05 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 19/24] thp, mm: use migration entries to freeze page counts on split
Date: Thu, 12 Feb 2015 18:18:33 +0200
Message-Id: <1423757918-197669-20-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1423757918-197669-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1423757918-197669-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Currently, we rely on compound_lock() to get page counts stable on
splitting page refcounting. To get it work we also take the lock on
get_page() and put_page() which is hot path.

This patch rework splitting code to setup migration entries to stabilaze
page count/mapcount before distribute refcounts. It means we don't need
to compound lock in get_page()/put_page().

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/migrate.h |   3 +
 include/linux/mm.h      |   1 +
 include/linux/pagemap.h |   9 ++-
 mm/huge_memory.c        | 184 ++++++++++++++++++++++++++++++++++--------------
 mm/internal.h           |  26 +++++--
 mm/migrate.c            |   2 +-
 mm/rmap.c               |  21 ------
 7 files changed, 168 insertions(+), 78 deletions(-)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index 78baed5f2952..6b02c11a3c40 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -43,6 +43,9 @@ extern int migrate_page_move_mapping(struct address_space *mapping,
 		struct page *newpage, struct page *page,
 		struct buffer_head *head, enum migrate_mode mode,
 		int extra_count);
+extern int remove_migration_pte(struct page *new, struct vm_area_struct *vma,
+		unsigned long addr, void *old);
+
 #else
 
 static inline void putback_movable_pages(struct list_head *l) {}
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 5b7498631322..655d2bfabdd9 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -981,6 +981,7 @@ extern struct address_space *page_mapping(struct page *page);
 /* Neutral page->mapping pointer to address_space or anon_vma or other */
 static inline void *page_rmapping(struct page *page)
 {
+	page = compound_head(page);
 	return (void *)((unsigned long)page->mapping & ~PAGE_MAPPING_FLAGS);
 }
 
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index ad6da4e49555..faef48e04fc4 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -387,10 +387,17 @@ static inline struct page *read_mapping_page(struct address_space *mapping,
  */
 static inline pgoff_t page_to_pgoff(struct page *page)
 {
+	pgoff_t pgoff;
+
 	if (unlikely(PageHeadHuge(page)))
 		return page->index << compound_order(page);
-	else
+
+	if (likely(!PageTransTail(page)))
 		return page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+
+	pgoff = page->first_page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+	pgoff += page - page->first_page;
+	return pgoff;
 }
 
 /*
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index bb9be39de242..7157975eeb1a 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -23,6 +23,7 @@
 #include <linux/pagemap.h>
 #include <linux/migrate.h>
 #include <linux/hashtable.h>
+#include <linux/swapops.h>
 
 #include <asm/tlb.h>
 #include <asm/pgalloc.h>
@@ -1599,7 +1600,7 @@ static void __split_huge_zero_page_pmd(struct vm_area_struct *vma,
 
 
 static void __split_huge_pmd_locked(struct vm_area_struct *vma,
-		pmd_t *pmd, unsigned long address)
+		pmd_t *pmd, unsigned long address, int freeze)
 {
 	unsigned long haddr = address & HPAGE_PMD_MASK;
 	struct page *page;
@@ -1632,12 +1633,19 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma,
 		 * transferred to avoid any possibility of altering
 		 * permissions across VMAs.
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
@@ -1663,7 +1671,7 @@ void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
 	ptl = pmd_lock(mm, pmd);
 	if (likely(pmd_trans_huge(*pmd)))
-		__split_huge_pmd_locked(vma, pmd, address);
+		__split_huge_pmd_locked(vma, pmd, address, 0);
 	spin_unlock(ptl);
 	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
 }
@@ -1698,20 +1706,119 @@ static void split_huge_pmd_address(struct vm_area_struct *vma,
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
+		haddr = addr = __vma_address(page, vma) & HPAGE_PMD_MASK;
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
+	pgoff_t pgoff = page_to_pgoff(page);
+	unsigned long addr;
+	int i;
+
+	for (i = 0; i < HPAGE_PMD_NR; i++, pgoff++, page++) {
+		if (!page_mapcount(page))
+			continue;
+
+		anon_vma_interval_tree_foreach(avc, &anon_vma->rb_root,
+				pgoff, pgoff) {
+			addr = vma_address(page, avc->vma);
+
+			remove_migration_pte(page, avc->vma, addr, page);
+
+			/*
+			 * remove_migration_pte() adds page to rmap, but we
+			 * didn't remove it on freeze_page().
+			 * Let's fix it up here.
+			 */
+			page_remove_rmap(page, false);
+			put_page(page);
+		}
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
@@ -1727,8 +1834,8 @@ static int __split_huge_page_refcount(struct page *page,
 		tail_mapcount += page_mapcount(page + i);
 	if (tail_mapcount != page_count(page) - 1) {
 		BUG_ON(tail_mapcount > page_count(page) - 1);
-		compound_unlock(page);
 		spin_unlock_irq(&zone->lru_lock);
+		unfreeze_page(anon_vma, page);
 		return -EBUSY;
 	}
 
@@ -1775,6 +1882,7 @@ static int __split_huge_page_refcount(struct page *page,
 				      (1L << PG_mlocked) |
 				      (1L << PG_uptodate) |
 				      (1L << PG_active) |
+				      (1L << PG_locked) |
 				      (1L << PG_unevictable)));
 		page_tail->flags |= (1L << PG_dirty);
 
@@ -1800,12 +1908,14 @@ static int __split_huge_page_refcount(struct page *page,
 	__mod_zone_page_state(zone, NR_ANON_TRANSPARENT_HUGEPAGES, -1);
 
 	ClearPageCompound(page);
-	compound_unlock(page);
 	spin_unlock_irq(&zone->lru_lock);
 
+	unfreeze_page(anon_vma, page);
+
 	for (i = 1; i < HPAGE_PMD_NR; i++) {
 		struct page *page_tail = page + i;
 		BUG_ON(page_count(page_tail) <= 0);
+		unlock_page(page_tail);
 		/*
 		 * Tail pages may be freed if there wasn't any mapping
 		 * like if add_to_swap() is running on a lru page that
@@ -1834,14 +1944,13 @@ static int __split_huge_page_refcount(struct page *page,
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
 	BUG_ON(!PageLocked(page));
+	BUG_ON(PageTail(page));
 
 	/*
 	 * The caller does not necessarily hold an mmap_sem that would prevent
@@ -1852,15 +1961,12 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
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
@@ -1872,39 +1978,15 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
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
diff --git a/mm/internal.h b/mm/internal.h
index ed57cc24802b..dc2db7a45acd 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -13,6 +13,7 @@
 
 #include <linux/fs.h>
 #include <linux/mm.h>
+#include <linux/pagemap.h>
 
 void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
 		unsigned long floor, unsigned long ceiling);
@@ -261,10 +262,27 @@ static inline void mlock_migrate_page(struct page *newpage, struct page *page)
 
 extern pmd_t maybe_pmd_mkwrite(pmd_t pmd, struct vm_area_struct *vma);
 
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
-extern unsigned long vma_address(struct page *page,
-				 struct vm_area_struct *vma);
-#endif
+/*
+ * At what user virtual address is page expected in @vma?
+ */
+static inline unsigned long
+__vma_address(struct page *page, struct vm_area_struct *vma)
+{
+	pgoff_t pgoff = page_to_pgoff(page);
+	return vma->vm_start + ((pgoff - vma->vm_pgoff) << PAGE_SHIFT);
+}
+
+static inline unsigned long
+vma_address(struct page *page, struct vm_area_struct *vma)
+{
+	unsigned long address = __vma_address(page, vma);
+
+	/* page should be within @vma mapping range */
+	VM_BUG_ON_VMA(address < vma->vm_start || address >= vma->vm_end, vma);
+
+	return address;
+}
+
 #else /* !CONFIG_MMU */
 static inline void clear_page_mlock(struct page *page) { }
 static inline void mlock_vma_page(struct page *page) { }
diff --git a/mm/migrate.c b/mm/migrate.c
index 91a67029bb18..b163e46201ee 100644
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
diff --git a/mm/rmap.c b/mm/rmap.c
index eb2f4a0d3961..2dc26770d1d3 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -554,27 +554,6 @@ void page_unlock_anon_vma_read(struct anon_vma *anon_vma)
 }
 
 /*
- * At what user virtual address is page expected in @vma?
- */
-static inline unsigned long
-__vma_address(struct page *page, struct vm_area_struct *vma)
-{
-	pgoff_t pgoff = page_to_pgoff(page);
-	return vma->vm_start + ((pgoff - vma->vm_pgoff) << PAGE_SHIFT);
-}
-
-inline unsigned long
-vma_address(struct page *page, struct vm_area_struct *vma)
-{
-	unsigned long address = __vma_address(page, vma);
-
-	/* page should be within @vma mapping range */
-	VM_BUG_ON_VMA(address < vma->vm_start || address >= vma->vm_end, vma);
-
-	return address;
-}
-
-/*
  * At what user virtual address is page expected in vma?
  * Caller should check the page is actually part of the vma.
  */
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
