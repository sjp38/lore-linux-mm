Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id F3D916B006C
	for <linux-mm@kvack.org>; Wed,  1 Oct 2014 07:32:15 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id p10so99663pdj.29
        for <linux-mm@kvack.org>; Wed, 01 Oct 2014 04:32:15 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id ml10si495050pab.207.2014.10.01.04.32.14
        for <linux-mm@kvack.org>;
        Wed, 01 Oct 2014 04:32:14 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 2/3] mm: use VM_BUG_ON instead of VM_BUG_ON_PAGE everywhere
Date: Wed,  1 Oct 2014 14:32:00 +0300
Message-Id: <1412163121-4295-2-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1412163121-4295-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1412163121-4295-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>
Cc: Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Powered by sed.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/mm/gup.c              |  8 +++----
 include/linux/hugetlb.h        |  2 +-
 include/linux/hugetlb_cgroup.h |  4 ++--
 include/linux/mm.h             | 24 +++++++++----------
 include/linux/mmdebug.h        |  2 --
 include/linux/page-flags.h     | 10 ++++----
 include/linux/pagemap.h        | 10 ++++----
 mm/cleancache.c                |  6 ++---
 mm/compaction.c                |  2 +-
 mm/filemap.c                   | 18 +++++++-------
 mm/huge_memory.c               | 36 ++++++++++++++--------------
 mm/hugetlb.c                   | 10 ++++----
 mm/hugetlb_cgroup.c            |  2 +-
 mm/internal.h                  |  8 +++----
 mm/ksm.c                       | 12 +++++-----
 mm/memcontrol.c                | 54 +++++++++++++++++++++---------------------
 mm/memory.c                    |  6 ++---
 mm/migrate.c                   |  6 ++---
 mm/mlock.c                     |  4 ++--
 mm/page_alloc.c                | 20 ++++++++--------
 mm/page_io.c                   |  4 ++--
 mm/rmap.c                      | 12 +++++-----
 mm/shmem.c                     |  8 +++----
 mm/swap.c                      | 38 ++++++++++++++---------------
 mm/swap_state.c                | 16 ++++++-------
 mm/swapfile.c                  |  8 +++----
 mm/vmscan.c                    | 20 ++++++++--------
 27 files changed, 174 insertions(+), 176 deletions(-)

diff --git a/arch/x86/mm/gup.c b/arch/x86/mm/gup.c
index 207d9aef662d..7777bfd3abe6 100644
--- a/arch/x86/mm/gup.c
+++ b/arch/x86/mm/gup.c
@@ -108,8 +108,8 @@ static noinline int gup_pte_range(pmd_t pmd, unsigned long addr,
 
 static inline void get_head_page_multiple(struct page *page, int nr)
 {
-	VM_BUG_ON_PAGE(page != compound_head(page), page);
-	VM_BUG_ON_PAGE(page_count(page) == 0, page);
+	VM_BUG_ON(page != compound_head(page), page);
+	VM_BUG_ON(page_count(page) == 0, page);
 	atomic_add(nr, &page->_count);
 	SetPageReferenced(page);
 }
@@ -135,7 +135,7 @@ static noinline int gup_huge_pmd(pmd_t pmd, unsigned long addr,
 	head = pte_page(pte);
 	page = head + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
 	do {
-		VM_BUG_ON_PAGE(compound_head(page) != head, page);
+		VM_BUG_ON(compound_head(page) != head, page);
 		pages[*nr] = page;
 		if (PageTail(page))
 			get_huge_page_tail(page);
@@ -212,7 +212,7 @@ static noinline int gup_huge_pud(pud_t pud, unsigned long addr,
 	head = pte_page(pte);
 	page = head + ((addr & ~PUD_MASK) >> PAGE_SHIFT);
 	do {
-		VM_BUG_ON_PAGE(compound_head(page) != head, page);
+		VM_BUG_ON(compound_head(page) != head, page);
 		pages[*nr] = page;
 		if (PageTail(page))
 			get_huge_page_tail(page);
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 14020c7796af..a559612d0c3a 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -370,7 +370,7 @@ static inline pte_t arch_make_huge_pte(pte_t entry, struct vm_area_struct *vma,
 
 static inline struct hstate *page_hstate(struct page *page)
 {
-	VM_BUG_ON_PAGE(!PageHuge(page), page);
+	VM_BUG_ON(!PageHuge(page), page);
 	return size_to_hstate(PAGE_SIZE << compound_order(page));
 }
 
diff --git a/include/linux/hugetlb_cgroup.h b/include/linux/hugetlb_cgroup.h
index 0129f89cf98d..fd0424795677 100644
--- a/include/linux/hugetlb_cgroup.h
+++ b/include/linux/hugetlb_cgroup.h
@@ -29,7 +29,7 @@ struct hugetlb_cgroup;
 
 static inline struct hugetlb_cgroup *hugetlb_cgroup_from_page(struct page *page)
 {
-	VM_BUG_ON_PAGE(!PageHuge(page), page);
+	VM_BUG_ON(!PageHuge(page), page);
 
 	if (compound_order(page) < HUGETLB_CGROUP_MIN_ORDER)
 		return NULL;
@@ -39,7 +39,7 @@ static inline struct hugetlb_cgroup *hugetlb_cgroup_from_page(struct page *page)
 static inline
 int set_hugetlb_cgroup(struct page *page, struct hugetlb_cgroup *h_cg)
 {
-	VM_BUG_ON_PAGE(!PageHuge(page), page);
+	VM_BUG_ON(!PageHuge(page), page);
 
 	if (compound_order(page) < HUGETLB_CGROUP_MIN_ORDER)
 		return -1;
diff --git a/include/linux/mm.h b/include/linux/mm.h
index a91874b5a71a..183d39c1042a 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -319,7 +319,7 @@ static inline int get_freepage_migratetype(struct page *page)
  */
 static inline int put_page_testzero(struct page *page)
 {
-	VM_BUG_ON_PAGE(atomic_read(&page->_count) == 0, page);
+	VM_BUG_ON(atomic_read(&page->_count) == 0, page);
 	return atomic_dec_and_test(&page->_count);
 }
 
@@ -383,7 +383,7 @@ extern void kvfree(const void *addr);
 static inline void compound_lock(struct page *page)
 {
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
-	VM_BUG_ON_PAGE(PageSlab(page), page);
+	VM_BUG_ON(PageSlab(page), page);
 	bit_spin_lock(PG_compound_lock, &page->flags);
 #endif
 }
@@ -391,7 +391,7 @@ static inline void compound_lock(struct page *page)
 static inline void compound_unlock(struct page *page)
 {
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
-	VM_BUG_ON_PAGE(PageSlab(page), page);
+	VM_BUG_ON(PageSlab(page), page);
 	bit_spin_unlock(PG_compound_lock, &page->flags);
 #endif
 }
@@ -481,7 +481,7 @@ static inline bool __compound_tail_refcounted(struct page *page)
  */
 static inline bool compound_tail_refcounted(struct page *page)
 {
-	VM_BUG_ON_PAGE(!PageHead(page), page);
+	VM_BUG_ON(!PageHead(page), page);
 	return __compound_tail_refcounted(page);
 }
 
@@ -490,9 +490,9 @@ static inline void get_huge_page_tail(struct page *page)
 	/*
 	 * __split_huge_page_refcount() cannot run from under us.
 	 */
-	VM_BUG_ON_PAGE(!PageTail(page), page);
-	VM_BUG_ON_PAGE(page_mapcount(page) < 0, page);
-	VM_BUG_ON_PAGE(atomic_read(&page->_count) != 0, page);
+	VM_BUG_ON(!PageTail(page), page);
+	VM_BUG_ON(page_mapcount(page) < 0, page);
+	VM_BUG_ON(atomic_read(&page->_count) != 0, page);
 	if (compound_tail_refcounted(page->first_page))
 		atomic_inc(&page->_mapcount);
 }
@@ -508,7 +508,7 @@ static inline void get_page(struct page *page)
 	 * Getting a normal page or the head of a compound page
 	 * requires to already have an elevated page->_count.
 	 */
-	VM_BUG_ON_PAGE(atomic_read(&page->_count) <= 0, page);
+	VM_BUG_ON(atomic_read(&page->_count) <= 0, page);
 	atomic_inc(&page->_count);
 }
 
@@ -545,13 +545,13 @@ static inline int PageBuddy(struct page *page)
 
 static inline void __SetPageBuddy(struct page *page)
 {
-	VM_BUG_ON_PAGE(atomic_read(&page->_mapcount) != -1, page);
+	VM_BUG_ON(atomic_read(&page->_mapcount) != -1, page);
 	atomic_set(&page->_mapcount, PAGE_BUDDY_MAPCOUNT_VALUE);
 }
 
 static inline void __ClearPageBuddy(struct page *page)
 {
-	VM_BUG_ON_PAGE(!PageBuddy(page), page);
+	VM_BUG_ON(!PageBuddy(page), page);
 	atomic_set(&page->_mapcount, -1);
 }
 
@@ -1447,7 +1447,7 @@ static inline bool ptlock_init(struct page *page)
 	 * slab code uses page->slab_cache and page->first_page (for tail
 	 * pages), which share storage with page->ptl.
 	 */
-	VM_BUG_ON_PAGE(*(unsigned long *)&page->ptl, page);
+	VM_BUG_ON(*(unsigned long *)&page->ptl, page);
 	if (!ptlock_alloc(page))
 		return false;
 	spin_lock_init(ptlock_ptr(page));
@@ -1544,7 +1544,7 @@ static inline bool pgtable_pmd_page_ctor(struct page *page)
 static inline void pgtable_pmd_page_dtor(struct page *page)
 {
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
-	VM_BUG_ON_PAGE(page->pmd_huge_pte, page);
+	VM_BUG_ON(page->pmd_huge_pte, page);
 #endif
 	ptlock_free(page);
 }
diff --git a/include/linux/mmdebug.h b/include/linux/mmdebug.h
index 12f304a36b01..816cbd050ea9 100644
--- a/include/linux/mmdebug.h
+++ b/include/linux/mmdebug.h
@@ -60,7 +60,6 @@ void dump_mm(const struct mm_struct *mm);
 		_VM_BUG_ON_ARG2,					\
 		_VM_BUG_ON_ARG1,					\
 		BUG_ON)(__VA_ARGS__)
-#define VM_BUG_ON_PAGE VM_BUG_ON
 #define VM_BUG_ON_VMA VM_BUG_ON
 #define VM_BUG_ON_MM VM_BUG_ON
 #define VM_WARN_ON(cond) WARN_ON(cond)
@@ -68,7 +67,6 @@ void dump_mm(const struct mm_struct *mm);
 #define VM_WARN_ONCE(cond, format...) WARN_ONCE(cond, format)
 #else
 #define VM_BUG_ON(cond, ...) BUILD_BUG_ON_INVALID(cond)
-#define VM_BUG_ON_PAGE(cond, page) VM_BUG_ON(cond)
 #define VM_BUG_ON_VMA(cond, vma) VM_BUG_ON(cond)
 #define VM_BUG_ON_MM(cond, mm) VM_BUG_ON(cond)
 #define VM_WARN_ON(cond) BUILD_BUG_ON_INVALID(cond)
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index e1f5fcd79792..53bbb4292377 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -434,7 +434,7 @@ static inline void ClearPageCompound(struct page *page)
  */
 static inline int PageTransHuge(struct page *page)
 {
-	VM_BUG_ON_PAGE(PageTail(page), page);
+	VM_BUG_ON(PageTail(page), page);
 	return PageHead(page);
 }
 
@@ -482,25 +482,25 @@ static inline int PageTransTail(struct page *page)
  */
 static inline int PageSlabPfmemalloc(struct page *page)
 {
-	VM_BUG_ON_PAGE(!PageSlab(page), page);
+	VM_BUG_ON(!PageSlab(page), page);
 	return PageActive(page);
 }
 
 static inline void SetPageSlabPfmemalloc(struct page *page)
 {
-	VM_BUG_ON_PAGE(!PageSlab(page), page);
+	VM_BUG_ON(!PageSlab(page), page);
 	SetPageActive(page);
 }
 
 static inline void __ClearPageSlabPfmemalloc(struct page *page)
 {
-	VM_BUG_ON_PAGE(!PageSlab(page), page);
+	VM_BUG_ON(!PageSlab(page), page);
 	__ClearPageActive(page);
 }
 
 static inline void ClearPageSlabPfmemalloc(struct page *page)
 {
-	VM_BUG_ON_PAGE(!PageSlab(page), page);
+	VM_BUG_ON(!PageSlab(page), page);
 	ClearPageActive(page);
 }
 
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 19191d39c4f3..7446422ba046 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -173,7 +173,7 @@ static inline int page_cache_get_speculative(struct page *page)
 	 * disabling preempt, and hence no need for the "speculative get" that
 	 * SMP requires.
 	 */
-	VM_BUG_ON_PAGE(page_count(page) == 0, page);
+	VM_BUG_ON(page_count(page) == 0, page);
 	atomic_inc(&page->_count);
 
 #else
@@ -186,7 +186,7 @@ static inline int page_cache_get_speculative(struct page *page)
 		return 0;
 	}
 #endif
-	VM_BUG_ON_PAGE(PageTail(page), page);
+	VM_BUG_ON(PageTail(page), page);
 
 	return 1;
 }
@@ -202,14 +202,14 @@ static inline int page_cache_add_speculative(struct page *page, int count)
 # ifdef CONFIG_PREEMPT_COUNT
 	VM_BUG_ON(!in_atomic());
 # endif
-	VM_BUG_ON_PAGE(page_count(page) == 0, page);
+	VM_BUG_ON(page_count(page) == 0, page);
 	atomic_add(count, &page->_count);
 
 #else
 	if (unlikely(!atomic_add_unless(&page->_count, count, 0)))
 		return 0;
 #endif
-	VM_BUG_ON_PAGE(PageCompound(page) && page != compound_head(page), page);
+	VM_BUG_ON(PageCompound(page) && page != compound_head(page), page);
 
 	return 1;
 }
@@ -221,7 +221,7 @@ static inline int page_freeze_refs(struct page *page, int count)
 
 static inline void page_unfreeze_refs(struct page *page, int count)
 {
-	VM_BUG_ON_PAGE(page_count(page) != 0, page);
+	VM_BUG_ON(page_count(page) != 0, page);
 	VM_BUG_ON(count == 0);
 
 	atomic_set(&page->_count, count);
diff --git a/mm/cleancache.c b/mm/cleancache.c
index d0eac4350403..817e593350c9 100644
--- a/mm/cleancache.c
+++ b/mm/cleancache.c
@@ -237,7 +237,7 @@ int __cleancache_get_page(struct page *page)
 		goto out;
 	}
 
-	VM_BUG_ON_PAGE(!PageLocked(page), page);
+	VM_BUG_ON(!PageLocked(page), page);
 	fake_pool_id = page->mapping->host->i_sb->cleancache_poolid;
 	if (fake_pool_id < 0)
 		goto out;
@@ -279,7 +279,7 @@ void __cleancache_put_page(struct page *page)
 		return;
 	}
 
-	VM_BUG_ON_PAGE(!PageLocked(page), page);
+	VM_BUG_ON(!PageLocked(page), page);
 	fake_pool_id = page->mapping->host->i_sb->cleancache_poolid;
 	if (fake_pool_id < 0)
 		return;
@@ -318,7 +318,7 @@ void __cleancache_invalidate_page(struct address_space *mapping,
 		if (pool_id < 0)
 			return;
 
-		VM_BUG_ON_PAGE(!PageLocked(page), page);
+		VM_BUG_ON(!PageLocked(page), page);
 		if (cleancache_get_key(mapping->host, &key) >= 0) {
 			cleancache_ops->invalidate_page(pool_id,
 					key, page->index);
diff --git a/mm/compaction.c b/mm/compaction.c
index 92075d51ce90..fdf75f13b6e0 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -702,7 +702,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 		if (__isolate_lru_page(page, isolate_mode) != 0)
 			continue;
 
-		VM_BUG_ON_PAGE(PageTransCompound(page), page);
+		VM_BUG_ON(PageTransCompound(page), page);
 
 		/* Successfully isolated */
 		del_page_from_lru_list(page, lruvec, page_lru(page));
diff --git a/mm/filemap.c b/mm/filemap.c
index 0ab0a3ea5721..408bdeebbbe3 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -464,9 +464,9 @@ int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
 {
 	int error;
 
-	VM_BUG_ON_PAGE(!PageLocked(old), old);
-	VM_BUG_ON_PAGE(!PageLocked(new), new);
-	VM_BUG_ON_PAGE(new->mapping, new);
+	VM_BUG_ON(!PageLocked(old), old);
+	VM_BUG_ON(!PageLocked(new), new);
+	VM_BUG_ON(new->mapping, new);
 
 	error = radix_tree_preload(gfp_mask & ~__GFP_HIGHMEM);
 	if (!error) {
@@ -551,8 +551,8 @@ static int __add_to_page_cache_locked(struct page *page,
 	struct mem_cgroup *memcg;
 	int error;
 
-	VM_BUG_ON_PAGE(!PageLocked(page), page);
-	VM_BUG_ON_PAGE(PageSwapBacked(page), page);
+	VM_BUG_ON(!PageLocked(page), page);
+	VM_BUG_ON(PageSwapBacked(page), page);
 
 	if (!huge) {
 		error = mem_cgroup_try_charge(page, current->mm,
@@ -744,7 +744,7 @@ EXPORT_SYMBOL_GPL(add_page_wait_queue);
  */
 void unlock_page(struct page *page)
 {
-	VM_BUG_ON_PAGE(!PageLocked(page), page);
+	VM_BUG_ON(!PageLocked(page), page);
 	clear_bit_unlock(PG_locked, &page->flags);
 	smp_mb__after_atomic();
 	wake_up_page(page, PG_locked);
@@ -1035,7 +1035,7 @@ repeat:
 			page_cache_release(page);
 			goto repeat;
 		}
-		VM_BUG_ON_PAGE(page->index != offset, page);
+		VM_BUG_ON(page->index != offset, page);
 	}
 	return page;
 }
@@ -1095,7 +1095,7 @@ repeat:
 			page_cache_release(page);
 			goto repeat;
 		}
-		VM_BUG_ON_PAGE(page->index != offset, page);
+		VM_BUG_ON(page->index != offset, page);
 	}
 
 	if (page && (fgp_flags & FGP_ACCESSED))
@@ -1916,7 +1916,7 @@ retry_find:
 		put_page(page);
 		goto retry_find;
 	}
-	VM_BUG_ON_PAGE(page->index != offset, page);
+	VM_BUG_ON(page->index != offset, page);
 
 	/*
 	 * We have a locked page in the page cache, now we need to check
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index ba5dc2f14575..83e881610f96 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -719,7 +719,7 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 	pgtable_t pgtable;
 	spinlock_t *ptl;
 
-	VM_BUG_ON_PAGE(!PageCompound(page), page);
+	VM_BUG_ON(!PageCompound(page), page);
 
 	if (mem_cgroup_try_charge(page, mm, GFP_TRANSHUGE, &memcg))
 		return VM_FAULT_OOM;
@@ -902,7 +902,7 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		goto out;
 	}
 	src_page = pmd_page(pmd);
-	VM_BUG_ON_PAGE(!PageHead(src_page), src_page);
+	VM_BUG_ON(!PageHead(src_page), src_page);
 	get_page(src_page);
 	page_dup_rmap(src_page);
 	add_mm_counter(dst_mm, MM_ANONPAGES, HPAGE_PMD_NR);
@@ -1034,7 +1034,7 @@ static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
 	ptl = pmd_lock(mm, pmd);
 	if (unlikely(!pmd_same(*pmd, orig_pmd)))
 		goto out_free_pages;
-	VM_BUG_ON_PAGE(!PageHead(page), page);
+	VM_BUG_ON(!PageHead(page), page);
 
 	pmdp_clear_flush(vma, haddr, pmd);
 	/* leave pmd empty until pte is filled */
@@ -1105,7 +1105,7 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		goto out_unlock;
 
 	page = pmd_page(orig_pmd);
-	VM_BUG_ON_PAGE(!PageCompound(page) || !PageHead(page), page);
+	VM_BUG_ON(!PageCompound(page) || !PageHead(page), page);
 	if (page_mapcount(page) == 1) {
 		pmd_t entry;
 		entry = pmd_mkyoung(orig_pmd);
@@ -1189,7 +1189,7 @@ alloc:
 			add_mm_counter(mm, MM_ANONPAGES, HPAGE_PMD_NR);
 			put_huge_zero_page();
 		} else {
-			VM_BUG_ON_PAGE(!PageHead(page), page);
+			VM_BUG_ON(!PageHead(page), page);
 			page_remove_rmap(page);
 			put_page(page);
 		}
@@ -1227,7 +1227,7 @@ struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
 		goto out;
 
 	page = pmd_page(*pmd);
-	VM_BUG_ON_PAGE(!PageHead(page), page);
+	VM_BUG_ON(!PageHead(page), page);
 	if (flags & FOLL_TOUCH) {
 		pmd_t _pmd;
 		/*
@@ -1252,7 +1252,7 @@ struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
 		}
 	}
 	page += (addr & ~HPAGE_PMD_MASK) >> PAGE_SHIFT;
-	VM_BUG_ON_PAGE(!PageCompound(page), page);
+	VM_BUG_ON(!PageCompound(page), page);
 	if (flags & FOLL_GET)
 		get_page_foll(page);
 
@@ -1410,9 +1410,9 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		} else {
 			page = pmd_page(orig_pmd);
 			page_remove_rmap(page);
-			VM_BUG_ON_PAGE(page_mapcount(page) < 0, page);
+			VM_BUG_ON(page_mapcount(page) < 0, page);
 			add_mm_counter(tlb->mm, MM_ANONPAGES, -HPAGE_PMD_NR);
-			VM_BUG_ON_PAGE(!PageHead(page), page);
+			VM_BUG_ON(!PageHead(page), page);
 			atomic_long_dec(&tlb->mm->nr_ptes);
 			spin_unlock(ptl);
 			tlb_remove_page(tlb, page);
@@ -2159,9 +2159,9 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
 		if (unlikely(!page))
 			goto out;
 
-		VM_BUG_ON_PAGE(PageCompound(page), page);
-		VM_BUG_ON_PAGE(!PageAnon(page), page);
-		VM_BUG_ON_PAGE(!PageSwapBacked(page), page);
+		VM_BUG_ON(PageCompound(page), page);
+		VM_BUG_ON(!PageAnon(page), page);
+		VM_BUG_ON(!PageSwapBacked(page), page);
 
 		/* cannot use mapcount: can't collapse if there's a gup pin */
 		if (page_count(page) != 1)
@@ -2184,8 +2184,8 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
 		}
 		/* 0 stands for page_is_file_cache(page) == false */
 		inc_zone_page_state(page, NR_ISOLATED_ANON + 0);
-		VM_BUG_ON_PAGE(!PageLocked(page), page);
-		VM_BUG_ON_PAGE(PageLRU(page), page);
+		VM_BUG_ON(!PageLocked(page), page);
+		VM_BUG_ON(PageLRU(page), page);
 
 		/* If there is no mapped pte young don't collapse the page */
 		if (pte_young(pteval) || PageReferenced(page) ||
@@ -2215,7 +2215,7 @@ static void __collapse_huge_page_copy(pte_t *pte, struct page *page,
 		} else {
 			src_page = pte_page(pteval);
 			copy_user_highpage(page, src_page, address, vma);
-			VM_BUG_ON_PAGE(page_mapcount(src_page) != 1, src_page);
+			VM_BUG_ON(page_mapcount(src_page) != 1, src_page);
 			release_pte_page(src_page);
 			/*
 			 * ptl mostly unnecessary, but preempt has to
@@ -2318,7 +2318,7 @@ static struct page
 		       struct vm_area_struct *vma, unsigned long address,
 		       int node)
 {
-	VM_BUG_ON_PAGE(*hpage, *hpage);
+	VM_BUG_ON(*hpage, *hpage);
 
 	/*
 	 * Before allocating the hugepage, release the mmap_sem read lock.
@@ -2583,7 +2583,7 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
 		if (khugepaged_scan_abort(node))
 			goto out_unmap;
 		khugepaged_node_load[node]++;
-		VM_BUG_ON_PAGE(PageCompound(page), page);
+		VM_BUG_ON(PageCompound(page), page);
 		if (!PageLRU(page) || PageLocked(page) || !PageAnon(page))
 			goto out_unmap;
 		/* cannot use mapcount: can't collapse if there's a gup pin */
@@ -2879,7 +2879,7 @@ again:
 		return;
 	}
 	page = pmd_page(*pmd);
-	VM_BUG_ON_PAGE(!page_count(page), page);
+	VM_BUG_ON(!page_count(page), page);
 	get_page(page);
 	spin_unlock(ptl);
 	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 1ecb625bc498..f537e7d1ac92 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -832,7 +832,7 @@ static void update_and_free_page(struct hstate *h, struct page *page)
 				1 << PG_active | 1 << PG_private |
 				1 << PG_writeback);
 	}
-	VM_BUG_ON_PAGE(hugetlb_cgroup_from_page(page), page);
+	VM_BUG_ON(hugetlb_cgroup_from_page(page), page);
 	set_compound_page_dtor(page, NULL);
 	set_page_refcounted(page);
 	if (hstate_is_gigantic(h)) {
@@ -1269,7 +1269,7 @@ retry:
 		 * no users -- drop the buddy allocator's reference.
 		 */
 		put_page_testzero(page);
-		VM_BUG_ON_PAGE(page_count(page), page);
+		VM_BUG_ON(page_count(page), page);
 		enqueue_huge_page(h, page);
 	}
 free:
@@ -3779,7 +3779,7 @@ int dequeue_hwpoisoned_huge_page(struct page *hpage)
 
 bool isolate_huge_page(struct page *page, struct list_head *list)
 {
-	VM_BUG_ON_PAGE(!PageHead(page), page);
+	VM_BUG_ON(!PageHead(page), page);
 	if (!get_page_unless_zero(page))
 		return false;
 	spin_lock(&hugetlb_lock);
@@ -3790,7 +3790,7 @@ bool isolate_huge_page(struct page *page, struct list_head *list)
 
 void putback_active_hugepage(struct page *page)
 {
-	VM_BUG_ON_PAGE(!PageHead(page), page);
+	VM_BUG_ON(!PageHead(page), page);
 	spin_lock(&hugetlb_lock);
 	list_move_tail(&page->lru, &(page_hstate(page))->hugepage_activelist);
 	spin_unlock(&hugetlb_lock);
@@ -3799,7 +3799,7 @@ void putback_active_hugepage(struct page *page)
 
 bool is_hugepage_active(struct page *page)
 {
-	VM_BUG_ON_PAGE(!PageHuge(page), page);
+	VM_BUG_ON(!PageHuge(page), page);
 	/*
 	 * This function can be called for a tail page because the caller,
 	 * scan_movable_pages, scans through a given pfn-range which typically
diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
index a67c26e0f360..7738634f929e 100644
--- a/mm/hugetlb_cgroup.c
+++ b/mm/hugetlb_cgroup.c
@@ -390,7 +390,7 @@ void hugetlb_cgroup_migrate(struct page *oldhpage, struct page *newhpage)
 	if (hugetlb_cgroup_disabled())
 		return;
 
-	VM_BUG_ON_PAGE(!PageHuge(oldhpage), oldhpage);
+	VM_BUG_ON(!PageHuge(oldhpage), oldhpage);
 	spin_lock(&hugetlb_lock);
 	h_cg = hugetlb_cgroup_from_page(oldhpage);
 	set_hugetlb_cgroup(oldhpage, NULL);
diff --git a/mm/internal.h b/mm/internal.h
index 829304090b90..69fb41bf665f 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -42,8 +42,8 @@ static inline unsigned long ra_submit(struct file_ra_state *ra,
  */
 static inline void set_page_refcounted(struct page *page)
 {
-	VM_BUG_ON_PAGE(PageTail(page), page);
-	VM_BUG_ON_PAGE(atomic_read(&page->_count), page);
+	VM_BUG_ON(PageTail(page), page);
+	VM_BUG_ON(atomic_read(&page->_count), page);
 	set_page_count(page, 1);
 }
 
@@ -61,7 +61,7 @@ static inline void __get_page_tail_foll(struct page *page,
 	 * speculative page access (like in
 	 * page_cache_get_speculative()) on tail pages.
 	 */
-	VM_BUG_ON_PAGE(atomic_read(&page->first_page->_count) <= 0, page);
+	VM_BUG_ON(atomic_read(&page->first_page->_count) <= 0, page);
 	if (get_page_head)
 		atomic_inc(&page->first_page->_count);
 	get_huge_page_tail(page);
@@ -86,7 +86,7 @@ static inline void get_page_foll(struct page *page)
 		 * Getting a normal page or the head of a compound page
 		 * requires to already have an elevated page->_count.
 		 */
-		VM_BUG_ON_PAGE(atomic_read(&page->_count) <= 0, page);
+		VM_BUG_ON(atomic_read(&page->_count) <= 0, page);
 		atomic_inc(&page->_count);
 	}
 }
diff --git a/mm/ksm.c b/mm/ksm.c
index fb7590222706..a2323ffdfb09 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1897,13 +1897,13 @@ int rmap_walk_ksm(struct page *page, struct rmap_walk_control *rwc)
 	int ret = SWAP_AGAIN;
 	int search_new_forks = 0;
 
-	VM_BUG_ON_PAGE(!PageKsm(page), page);
+	VM_BUG_ON(!PageKsm(page), page);
 
 	/*
 	 * Rely on the page lock to protect against concurrent modifications
 	 * to that page's node of the stable tree.
 	 */
-	VM_BUG_ON_PAGE(!PageLocked(page), page);
+	VM_BUG_ON(!PageLocked(page), page);
 
 	stable_node = page_stable_node(page);
 	if (!stable_node)
@@ -1957,13 +1957,13 @@ void ksm_migrate_page(struct page *newpage, struct page *oldpage)
 {
 	struct stable_node *stable_node;
 
-	VM_BUG_ON_PAGE(!PageLocked(oldpage), oldpage);
-	VM_BUG_ON_PAGE(!PageLocked(newpage), newpage);
-	VM_BUG_ON_PAGE(newpage->mapping != oldpage->mapping, newpage);
+	VM_BUG_ON(!PageLocked(oldpage), oldpage);
+	VM_BUG_ON(!PageLocked(newpage), newpage);
+	VM_BUG_ON(newpage->mapping != oldpage->mapping, newpage);
 
 	stable_node = page_stable_node(newpage);
 	if (stable_node) {
-		VM_BUG_ON_PAGE(stable_node->kpfn != page_to_pfn(oldpage), oldpage);
+		VM_BUG_ON(stable_node->kpfn != page_to_pfn(oldpage), oldpage);
 		stable_node->kpfn = page_to_pfn(newpage);
 		/*
 		 * newpage->mapping was set in advance; now we need smp_wmb()
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 23976fd885fd..d67629b45b5e 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2661,7 +2661,7 @@ struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
 	unsigned short id;
 	swp_entry_t ent;
 
-	VM_BUG_ON_PAGE(!PageLocked(page), page);
+	VM_BUG_ON(!PageLocked(page), page);
 
 	pc = lookup_page_cgroup(page);
 	if (PageCgroupUsed(pc)) {
@@ -2704,7 +2704,7 @@ static void unlock_page_lru(struct page *page, int isolated)
 		struct lruvec *lruvec;
 
 		lruvec = mem_cgroup_page_lruvec(page, zone);
-		VM_BUG_ON_PAGE(PageLRU(page), page);
+		VM_BUG_ON(PageLRU(page), page);
 		SetPageLRU(page);
 		add_page_to_lru_list(page, lruvec, page_lru(page));
 	}
@@ -2717,7 +2717,7 @@ static void commit_charge(struct page *page, struct mem_cgroup *memcg,
 	struct page_cgroup *pc = lookup_page_cgroup(page);
 	int isolated;
 
-	VM_BUG_ON_PAGE(PageCgroupUsed(pc), page);
+	VM_BUG_ON(PageCgroupUsed(pc), page);
 	/*
 	 * we don't need page_cgroup_lock about tail pages, becase they are not
 	 * accessed by any other context at this point.
@@ -3297,7 +3297,7 @@ void __memcg_kmem_uncharge_pages(struct page *page, int order)
 	if (!memcg)
 		return;
 
-	VM_BUG_ON_PAGE(mem_cgroup_is_root(memcg), page);
+	VM_BUG_ON(mem_cgroup_is_root(memcg), page);
 	memcg_uncharge_kmem(memcg, PAGE_SIZE << order);
 }
 #else
@@ -3360,7 +3360,7 @@ static int mem_cgroup_move_account(struct page *page,
 	int ret;
 
 	VM_BUG_ON(from == to);
-	VM_BUG_ON_PAGE(PageLRU(page), page);
+	VM_BUG_ON(PageLRU(page), page);
 	/*
 	 * The page is isolated from LRU. So, collapse function
 	 * will not handle this page. But page splitting can happen.
@@ -3470,7 +3470,7 @@ static int mem_cgroup_move_parent(struct page *page,
 		parent = root_mem_cgroup;
 
 	if (nr_pages > 1) {
-		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
+		VM_BUG_ON(!PageTransHuge(page), page);
 		flags = compound_lock_irqsave(page);
 	}
 
@@ -5801,7 +5801,7 @@ static enum mc_target_type get_mctgt_type_thp(struct vm_area_struct *vma,
 	enum mc_target_type ret = MC_TARGET_NONE;
 
 	page = pmd_page(pmd);
-	VM_BUG_ON_PAGE(!page || !PageHead(page), page);
+	VM_BUG_ON(!page || !PageHead(page), page);
 	if (!move_anon())
 		return ret;
 	pc = lookup_page_cgroup(page);
@@ -6244,8 +6244,8 @@ void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
 	struct page_cgroup *pc;
 	unsigned short oldid;
 
-	VM_BUG_ON_PAGE(PageLRU(page), page);
-	VM_BUG_ON_PAGE(page_count(page), page);
+	VM_BUG_ON(PageLRU(page), page);
+	VM_BUG_ON(page_count(page), page);
 
 	if (!do_swap_account)
 		return;
@@ -6256,10 +6256,10 @@ void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
 	if (!PageCgroupUsed(pc))
 		return;
 
-	VM_BUG_ON_PAGE(!(pc->flags & PCG_MEMSW), page);
+	VM_BUG_ON(!(pc->flags & PCG_MEMSW), page);
 
 	oldid = swap_cgroup_record(entry, mem_cgroup_id(pc->mem_cgroup));
-	VM_BUG_ON_PAGE(oldid, page);
+	VM_BUG_ON(oldid, page);
 
 	pc->flags &= ~PCG_MEMSW;
 	css_get(&pc->mem_cgroup->css);
@@ -6335,7 +6335,7 @@ int mem_cgroup_try_charge(struct page *page, struct mm_struct *mm,
 
 	if (PageTransHuge(page)) {
 		nr_pages <<= compound_order(page);
-		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
+		VM_BUG_ON(!PageTransHuge(page), page);
 	}
 
 	if (do_swap_account && PageSwapCache(page))
@@ -6377,8 +6377,8 @@ void mem_cgroup_commit_charge(struct page *page, struct mem_cgroup *memcg,
 {
 	unsigned int nr_pages = 1;
 
-	VM_BUG_ON_PAGE(!page->mapping, page);
-	VM_BUG_ON_PAGE(PageLRU(page) && !lrucare, page);
+	VM_BUG_ON(!page->mapping, page);
+	VM_BUG_ON(PageLRU(page) && !lrucare, page);
 
 	if (mem_cgroup_disabled())
 		return;
@@ -6394,7 +6394,7 @@ void mem_cgroup_commit_charge(struct page *page, struct mem_cgroup *memcg,
 
 	if (PageTransHuge(page)) {
 		nr_pages <<= compound_order(page);
-		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
+		VM_BUG_ON(!PageTransHuge(page), page);
 	}
 
 	local_irq_disable();
@@ -6436,7 +6436,7 @@ void mem_cgroup_cancel_charge(struct page *page, struct mem_cgroup *memcg)
 
 	if (PageTransHuge(page)) {
 		nr_pages <<= compound_order(page);
-		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
+		VM_BUG_ON(!PageTransHuge(page), page);
 	}
 
 	cancel_charge(memcg, nr_pages);
@@ -6489,8 +6489,8 @@ static void uncharge_list(struct list_head *page_list)
 		page = list_entry(next, struct page, lru);
 		next = page->lru.next;
 
-		VM_BUG_ON_PAGE(PageLRU(page), page);
-		VM_BUG_ON_PAGE(page_count(page), page);
+		VM_BUG_ON(PageLRU(page), page);
+		VM_BUG_ON(page_count(page), page);
 
 		pc = lookup_page_cgroup(page);
 		if (!PageCgroupUsed(pc))
@@ -6514,7 +6514,7 @@ static void uncharge_list(struct list_head *page_list)
 
 		if (PageTransHuge(page)) {
 			nr_pages <<= compound_order(page);
-			VM_BUG_ON_PAGE(!PageTransHuge(page), page);
+			VM_BUG_ON(!PageTransHuge(page), page);
 			nr_huge += nr_pages;
 		}
 
@@ -6592,12 +6592,12 @@ void mem_cgroup_migrate(struct page *oldpage, struct page *newpage,
 	struct page_cgroup *pc;
 	int isolated;
 
-	VM_BUG_ON_PAGE(!PageLocked(oldpage), oldpage);
-	VM_BUG_ON_PAGE(!PageLocked(newpage), newpage);
-	VM_BUG_ON_PAGE(!lrucare && PageLRU(oldpage), oldpage);
-	VM_BUG_ON_PAGE(!lrucare && PageLRU(newpage), newpage);
-	VM_BUG_ON_PAGE(PageAnon(oldpage) != PageAnon(newpage), newpage);
-	VM_BUG_ON_PAGE(PageTransHuge(oldpage) != PageTransHuge(newpage),
+	VM_BUG_ON(!PageLocked(oldpage), oldpage);
+	VM_BUG_ON(!PageLocked(newpage), newpage);
+	VM_BUG_ON(!lrucare && PageLRU(oldpage), oldpage);
+	VM_BUG_ON(!lrucare && PageLRU(newpage), newpage);
+	VM_BUG_ON(PageAnon(oldpage) != PageAnon(newpage), newpage);
+	VM_BUG_ON(PageTransHuge(oldpage) != PageTransHuge(newpage),
 		       newpage);
 
 	if (mem_cgroup_disabled())
@@ -6613,8 +6613,8 @@ void mem_cgroup_migrate(struct page *oldpage, struct page *newpage,
 	if (!PageCgroupUsed(pc))
 		return;
 
-	VM_BUG_ON_PAGE(!(pc->flags & PCG_MEM), oldpage);
-	VM_BUG_ON_PAGE(do_swap_account && !(pc->flags & PCG_MEMSW), oldpage);
+	VM_BUG_ON(!(pc->flags & PCG_MEM), oldpage);
+	VM_BUG_ON(do_swap_account && !(pc->flags & PCG_MEMSW), oldpage);
 
 	if (lrucare)
 		lock_page_lru(oldpage, &isolated);
diff --git a/mm/memory.c b/mm/memory.c
index 64f82aacb0ce..919bd3ff71e6 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -301,7 +301,7 @@ int __tlb_remove_page(struct mmu_gather *tlb, struct page *page)
 			return 0;
 		batch = tlb->active;
 	}
-	VM_BUG_ON_PAGE(batch->nr > batch->max, page);
+	VM_BUG_ON(batch->nr > batch->max, page);
 
 	return batch->max - batch->nr;
 }
@@ -2014,7 +2014,7 @@ static int do_page_mkwrite(struct vm_area_struct *vma, struct page *page,
 		}
 		ret |= VM_FAULT_LOCKED;
 	} else
-		VM_BUG_ON_PAGE(!PageLocked(page), page);
+		VM_BUG_ON(!PageLocked(page), page);
 	return ret;
 }
 
@@ -2725,7 +2725,7 @@ static int __do_fault(struct vm_area_struct *vma, unsigned long address,
 	if (unlikely(!(ret & VM_FAULT_LOCKED)))
 		lock_page(vmf.page);
 	else
-		VM_BUG_ON_PAGE(!PageLocked(vmf.page), vmf.page);
+		VM_BUG_ON(!PageLocked(vmf.page), vmf.page);
 
 	*page = vmf.page;
 	return ret;
diff --git a/mm/migrate.c b/mm/migrate.c
index c9b5d13b3988..8bc25db0e864 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -529,7 +529,7 @@ void migrate_page_copy(struct page *newpage, struct page *page)
 	if (PageUptodate(page))
 		SetPageUptodate(newpage);
 	if (TestClearPageActive(page)) {
-		VM_BUG_ON_PAGE(PageUnevictable(page), page);
+		VM_BUG_ON(PageUnevictable(page), page);
 		SetPageActive(newpage);
 	} else if (TestClearPageUnevictable(page))
 		SetPageUnevictable(newpage);
@@ -898,7 +898,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 	 * free the metadata, so the page can be freed.
 	 */
 	if (!page->mapping) {
-		VM_BUG_ON_PAGE(PageAnon(page), page);
+		VM_BUG_ON(PageAnon(page), page);
 		if (page_has_private(page)) {
 			try_to_free_buffers(page);
 			goto out_unlock;
@@ -1664,7 +1664,7 @@ static int numamigrate_isolate_page(pg_data_t *pgdat, struct page *page)
 {
 	int page_lru;
 
-	VM_BUG_ON_PAGE(compound_order(page) && !PageTransHuge(page), page);
+	VM_BUG_ON(compound_order(page) && !PageTransHuge(page), page);
 
 	/* Avoid migrating to a node that is nearly full */
 	if (!migrate_balanced_pgdat(pgdat, 1UL << compound_order(page)))
diff --git a/mm/mlock.c b/mm/mlock.c
index 73cf0987088c..af98bc02e164 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -288,8 +288,8 @@ static int __mlock_posix_error_return(long retval)
 static bool __putback_lru_fast_prepare(struct page *page, struct pagevec *pvec,
 		int *pgrescued)
 {
-	VM_BUG_ON_PAGE(PageLRU(page), page);
-	VM_BUG_ON_PAGE(!PageLocked(page), page);
+	VM_BUG_ON(PageLRU(page), page);
+	VM_BUG_ON(!PageLocked(page), page);
 
 	if (page_mapcount(page) <= 1 && page_evictable(page)) {
 		pagevec_add(pvec, page);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 736d8e1b6381..60d47937dea4 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -511,7 +511,7 @@ static inline int page_is_buddy(struct page *page, struct page *buddy,
 		return 0;
 
 	if (page_is_guard(buddy) && page_order(buddy) == order) {
-		VM_BUG_ON_PAGE(page_count(buddy) != 0, buddy);
+		VM_BUG_ON(page_count(buddy) != 0, buddy);
 
 		if (page_zone_id(page) != page_zone_id(buddy))
 			return 0;
@@ -520,7 +520,7 @@ static inline int page_is_buddy(struct page *page, struct page *buddy,
 	}
 
 	if (PageBuddy(buddy) && page_order(buddy) == order) {
-		VM_BUG_ON_PAGE(page_count(buddy) != 0, buddy);
+		VM_BUG_ON(page_count(buddy) != 0, buddy);
 
 		/*
 		 * zone check is done late to avoid uselessly
@@ -580,8 +580,8 @@ static inline void __free_one_page(struct page *page,
 
 	page_idx = pfn & ((1 << MAX_ORDER) - 1);
 
-	VM_BUG_ON_PAGE(page_idx & ((1 << order) - 1), page);
-	VM_BUG_ON_PAGE(bad_range(zone, page), page);
+	VM_BUG_ON(page_idx & ((1 << order) - 1), page);
+	VM_BUG_ON(bad_range(zone, page), page);
 
 	while (order < MAX_ORDER-1) {
 		buddy_idx = __find_buddy_index(page_idx, order);
@@ -864,7 +864,7 @@ static inline void expand(struct zone *zone, struct page *page,
 		area--;
 		high--;
 		size >>= 1;
-		VM_BUG_ON_PAGE(bad_range(zone, &page[size]), &page[size]);
+		VM_BUG_ON(bad_range(zone, &page[size]), &page[size]);
 
 #ifdef CONFIG_DEBUG_PAGEALLOC
 		if (high < debug_guardpage_minorder()) {
@@ -1018,7 +1018,7 @@ int move_freepages(struct zone *zone,
 
 	for (page = start_page; page <= end_page;) {
 		/* Make sure we are not inadvertently changing nodes */
-		VM_BUG_ON_PAGE(page_to_nid(page) != zone_to_nid(zone), page);
+		VM_BUG_ON(page_to_nid(page) != zone_to_nid(zone), page);
 
 		if (!pfn_valid_within(page_to_pfn(page))) {
 			page++;
@@ -1467,8 +1467,8 @@ void split_page(struct page *page, unsigned int order)
 {
 	int i;
 
-	VM_BUG_ON_PAGE(PageCompound(page), page);
-	VM_BUG_ON_PAGE(!page_count(page), page);
+	VM_BUG_ON(PageCompound(page), page);
+	VM_BUG_ON(!page_count(page), page);
 
 #ifdef CONFIG_KMEMCHECK
 	/*
@@ -1619,7 +1619,7 @@ again:
 	zone_statistics(preferred_zone, zone, gfp_flags);
 	local_irq_restore(flags);
 
-	VM_BUG_ON_PAGE(bad_range(zone, page), page);
+	VM_BUG_ON(bad_range(zone, page), page);
 	if (prep_new_page(page, order, gfp_flags))
 		goto again;
 	return page;
@@ -6119,7 +6119,7 @@ void set_pfnblock_flags_mask(struct page *page, unsigned long flags,
 	word_bitidx = bitidx / BITS_PER_LONG;
 	bitidx &= (BITS_PER_LONG-1);
 
-	VM_BUG_ON_PAGE(!zone_spans_pfn(zone, pfn), page);
+	VM_BUG_ON(!zone_spans_pfn(zone, pfn), page);
 
 	bitidx += end_bitidx;
 	mask <<= (BITS_PER_LONG - bitidx - 1);
diff --git a/mm/page_io.c b/mm/page_io.c
index 955db8b0d497..417c3e92a560 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -339,8 +339,8 @@ int swap_readpage(struct page *page)
 	int ret = 0;
 	struct swap_info_struct *sis = page_swap_info(page);
 
-	VM_BUG_ON_PAGE(!PageLocked(page), page);
-	VM_BUG_ON_PAGE(PageUptodate(page), page);
+	VM_BUG_ON(!PageLocked(page), page);
+	VM_BUG_ON(PageUptodate(page), page);
 	if (frontswap_load(page) == 0) {
 		SetPageUptodate(page);
 		unlock_page(page);
diff --git a/mm/rmap.c b/mm/rmap.c
index 116a5053415b..cc9cf848472c 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -896,9 +896,9 @@ void page_move_anon_rmap(struct page *page,
 {
 	struct anon_vma *anon_vma = vma->anon_vma;
 
-	VM_BUG_ON_PAGE(!PageLocked(page), page);
+	VM_BUG_ON(!PageLocked(page), page);
 	VM_BUG_ON_VMA(!anon_vma, vma);
-	VM_BUG_ON_PAGE(page->index != linear_page_index(vma, address), page);
+	VM_BUG_ON(page->index != linear_page_index(vma, address), page);
 
 	anon_vma = (void *) anon_vma + PAGE_MAPPING_ANON;
 	page->mapping = (struct address_space *) anon_vma;
@@ -1003,7 +1003,7 @@ void do_page_add_anon_rmap(struct page *page,
 	if (unlikely(PageKsm(page)))
 		return;
 
-	VM_BUG_ON_PAGE(!PageLocked(page), page);
+	VM_BUG_ON(!PageLocked(page), page);
 	/* address might be in next vma when migration races vma_adjust */
 	if (first)
 		__page_set_anon_rmap(page, vma, address, exclusive);
@@ -1513,7 +1513,7 @@ int try_to_unmap(struct page *page, enum ttu_flags flags)
 		.anon_lock = page_lock_anon_vma_read,
 	};
 
-	VM_BUG_ON_PAGE(!PageHuge(page) && PageTransHuge(page), page);
+	VM_BUG_ON(!PageHuge(page) && PageTransHuge(page), page);
 
 	/*
 	 * During exec, a temporary VMA is setup and later moved.
@@ -1565,7 +1565,7 @@ int try_to_munlock(struct page *page)
 
 	};
 
-	VM_BUG_ON_PAGE(!PageLocked(page) || PageLRU(page), page);
+	VM_BUG_ON(!PageLocked(page) || PageLRU(page), page);
 
 	ret = rmap_walk(page, &rwc);
 	return ret;
@@ -1670,7 +1670,7 @@ static int rmap_walk_file(struct page *page, struct rmap_walk_control *rwc)
 	 * structure at mapping cannot be freed and reused yet,
 	 * so we can safely take mapping->i_mmap_mutex.
 	 */
-	VM_BUG_ON_PAGE(!PageLocked(page), page);
+	VM_BUG_ON(!PageLocked(page), page);
 
 	if (!mapping)
 		return ret;
diff --git a/mm/shmem.c b/mm/shmem.c
index cd6fc7590e54..f41bc1211680 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -300,8 +300,8 @@ static int shmem_add_to_page_cache(struct page *page,
 {
 	int error;
 
-	VM_BUG_ON_PAGE(!PageLocked(page), page);
-	VM_BUG_ON_PAGE(!PageSwapBacked(page), page);
+	VM_BUG_ON(!PageLocked(page), page);
+	VM_BUG_ON(!PageSwapBacked(page), page);
 
 	page_cache_get(page);
 	page->mapping = mapping;
@@ -441,7 +441,7 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 				continue;
 			if (!unfalloc || !PageUptodate(page)) {
 				if (page->mapping == mapping) {
-					VM_BUG_ON_PAGE(PageWriteback(page), page);
+					VM_BUG_ON(PageWriteback(page), page);
 					truncate_inode_page(mapping, page);
 				}
 			}
@@ -518,7 +518,7 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 			lock_page(page);
 			if (!unfalloc || !PageUptodate(page)) {
 				if (page->mapping == mapping) {
-					VM_BUG_ON_PAGE(PageWriteback(page), page);
+					VM_BUG_ON(PageWriteback(page), page);
 					truncate_inode_page(mapping, page);
 				} else {
 					/* Page was replaced by swap: retry */
diff --git a/mm/swap.c b/mm/swap.c
index 39affa1932ce..2268f8bd4d08 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -57,7 +57,7 @@ static void __page_cache_release(struct page *page)
 
 		spin_lock_irqsave(&zone->lru_lock, flags);
 		lruvec = mem_cgroup_page_lruvec(page, zone);
-		VM_BUG_ON_PAGE(!PageLRU(page), page);
+		VM_BUG_ON(!PageLRU(page), page);
 		__ClearPageLRU(page);
 		del_page_from_lru_list(page, lruvec, page_off_lru(page));
 		spin_unlock_irqrestore(&zone->lru_lock, flags);
@@ -122,8 +122,8 @@ void put_unrefcounted_compound_page(struct page *page_head, struct page *page)
 		 * __split_huge_page_refcount cannot race
 		 * here, see the comment above this function.
 		 */
-		VM_BUG_ON_PAGE(!PageHead(page_head), page_head);
-		VM_BUG_ON_PAGE(page_mapcount(page) != 0, page);
+		VM_BUG_ON(!PageHead(page_head), page_head);
+		VM_BUG_ON(page_mapcount(page) != 0, page);
 		if (put_page_testzero(page_head)) {
 			/*
 			 * If this is the tail of a slab THP page,
@@ -139,7 +139,7 @@ void put_unrefcounted_compound_page(struct page *page_head, struct page *page)
 			 * not go away until the compound page enters
 			 * the buddy allocator.
 			 */
-			VM_BUG_ON_PAGE(PageSlab(page_head), page_head);
+			VM_BUG_ON(PageSlab(page_head), page_head);
 			__put_compound_page(page_head);
 		}
 	} else
@@ -193,7 +193,7 @@ out_put_single:
 				__put_single_page(page);
 			return;
 		}
-		VM_BUG_ON_PAGE(page_head != page->first_page, page);
+		VM_BUG_ON(page_head != page->first_page, page);
 		/*
 		 * We can release the refcount taken by
 		 * get_page_unless_zero() now that
@@ -201,12 +201,12 @@ out_put_single:
 		 * compound_lock.
 		 */
 		if (put_page_testzero(page_head))
-			VM_BUG_ON_PAGE(1, page_head);
+			VM_BUG_ON(1, page_head);
 		/* __split_huge_page_refcount will wait now */
-		VM_BUG_ON_PAGE(page_mapcount(page) <= 0, page);
+		VM_BUG_ON(page_mapcount(page) <= 0, page);
 		atomic_dec(&page->_mapcount);
-		VM_BUG_ON_PAGE(atomic_read(&page_head->_count) <= 0, page_head);
-		VM_BUG_ON_PAGE(atomic_read(&page->_count) != 0, page);
+		VM_BUG_ON(atomic_read(&page_head->_count) <= 0, page_head);
+		VM_BUG_ON(atomic_read(&page->_count) != 0, page);
 		compound_unlock_irqrestore(page_head, flags);
 
 		if (put_page_testzero(page_head)) {
@@ -217,7 +217,7 @@ out_put_single:
 		}
 	} else {
 		/* @page_head is a dangling pointer */
-		VM_BUG_ON_PAGE(PageTail(page), page);
+		VM_BUG_ON(PageTail(page), page);
 		goto out_put_single;
 	}
 }
@@ -297,7 +297,7 @@ bool __get_page_tail(struct page *page)
 			 * page. __split_huge_page_refcount
 			 * cannot race here.
 			 */
-			VM_BUG_ON_PAGE(!PageHead(page_head), page_head);
+			VM_BUG_ON(!PageHead(page_head), page_head);
 			__get_page_tail_foll(page, true);
 			return true;
 		} else {
@@ -659,8 +659,8 @@ EXPORT_SYMBOL(lru_cache_add_file);
  */
 void lru_cache_add(struct page *page)
 {
-	VM_BUG_ON_PAGE(PageActive(page) && PageUnevictable(page), page);
-	VM_BUG_ON_PAGE(PageLRU(page), page);
+	VM_BUG_ON(PageActive(page) && PageUnevictable(page), page);
+	VM_BUG_ON(PageLRU(page), page);
 	__lru_cache_add(page);
 }
 
@@ -701,7 +701,7 @@ void add_page_to_unevictable_list(struct page *page)
 void lru_cache_add_active_or_unevictable(struct page *page,
 					 struct vm_area_struct *vma)
 {
-	VM_BUG_ON_PAGE(PageLRU(page), page);
+	VM_BUG_ON(PageLRU(page), page);
 
 	if (likely((vma->vm_flags & (VM_LOCKED | VM_SPECIAL)) != VM_LOCKED)) {
 		SetPageActive(page);
@@ -934,7 +934,7 @@ void release_pages(struct page **pages, int nr, bool cold)
 			}
 
 			lruvec = mem_cgroup_page_lruvec(page, zone);
-			VM_BUG_ON_PAGE(!PageLRU(page), page);
+			VM_BUG_ON(!PageLRU(page), page);
 			__ClearPageLRU(page);
 			del_page_from_lru_list(page, lruvec, page_off_lru(page));
 
@@ -987,9 +987,9 @@ void lru_add_page_tail(struct page *page, struct page *page_tail,
 {
 	const int file = 0;
 
-	VM_BUG_ON_PAGE(!PageHead(page), page);
-	VM_BUG_ON_PAGE(PageCompound(page_tail), page);
-	VM_BUG_ON_PAGE(PageLRU(page_tail), page);
+	VM_BUG_ON(!PageHead(page), page);
+	VM_BUG_ON(PageCompound(page_tail), page);
+	VM_BUG_ON(PageLRU(page_tail), page);
 	VM_BUG_ON(NR_CPUS != 1 &&
 		  !spin_is_locked(&lruvec_zone(lruvec)->lru_lock));
 
@@ -1028,7 +1028,7 @@ static void __pagevec_lru_add_fn(struct page *page, struct lruvec *lruvec,
 	int active = PageActive(page);
 	enum lru_list lru = page_lru(page);
 
-	VM_BUG_ON_PAGE(PageLRU(page), page);
+	VM_BUG_ON(PageLRU(page), page);
 
 	SetPageLRU(page);
 	add_page_to_lru_list(page, lruvec, lru);
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 154444918685..d770e8f0a8d2 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -88,9 +88,9 @@ int __add_to_swap_cache(struct page *page, swp_entry_t entry)
 	int error;
 	struct address_space *address_space;
 
-	VM_BUG_ON_PAGE(!PageLocked(page), page);
-	VM_BUG_ON_PAGE(PageSwapCache(page), page);
-	VM_BUG_ON_PAGE(!PageSwapBacked(page), page);
+	VM_BUG_ON(!PageLocked(page), page);
+	VM_BUG_ON(PageSwapCache(page), page);
+	VM_BUG_ON(!PageSwapBacked(page), page);
 
 	page_cache_get(page);
 	SetPageSwapCache(page);
@@ -144,9 +144,9 @@ void __delete_from_swap_cache(struct page *page)
 	swp_entry_t entry;
 	struct address_space *address_space;
 
-	VM_BUG_ON_PAGE(!PageLocked(page), page);
-	VM_BUG_ON_PAGE(!PageSwapCache(page), page);
-	VM_BUG_ON_PAGE(PageWriteback(page), page);
+	VM_BUG_ON(!PageLocked(page), page);
+	VM_BUG_ON(!PageSwapCache(page), page);
+	VM_BUG_ON(PageWriteback(page), page);
 
 	entry.val = page_private(page);
 	address_space = swap_address_space(entry);
@@ -170,8 +170,8 @@ int add_to_swap(struct page *page, struct list_head *list)
 	swp_entry_t entry;
 	int err;
 
-	VM_BUG_ON_PAGE(!PageLocked(page), page);
-	VM_BUG_ON_PAGE(!PageUptodate(page), page);
+	VM_BUG_ON(!PageLocked(page), page);
+	VM_BUG_ON(!PageUptodate(page), page);
 
 	entry = get_swap_page();
 	if (!entry.val)
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 8798b2e0ac59..39a2a105c968 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -884,7 +884,7 @@ int reuse_swap_page(struct page *page)
 {
 	int count;
 
-	VM_BUG_ON_PAGE(!PageLocked(page), page);
+	VM_BUG_ON(!PageLocked(page), page);
 	if (unlikely(PageKsm(page)))
 		return 0;
 	count = page_mapcount(page);
@@ -904,7 +904,7 @@ int reuse_swap_page(struct page *page)
  */
 int try_to_free_swap(struct page *page)
 {
-	VM_BUG_ON_PAGE(!PageLocked(page), page);
+	VM_BUG_ON(!PageLocked(page), page);
 
 	if (!PageSwapCache(page))
 		return 0;
@@ -2710,7 +2710,7 @@ struct swap_info_struct *page_swap_info(struct page *page)
  */
 struct address_space *__page_file_mapping(struct page *page)
 {
-	VM_BUG_ON_PAGE(!PageSwapCache(page), page);
+	VM_BUG_ON(!PageSwapCache(page), page);
 	return page_swap_info(page)->swap_file->f_mapping;
 }
 EXPORT_SYMBOL_GPL(__page_file_mapping);
@@ -2718,7 +2718,7 @@ EXPORT_SYMBOL_GPL(__page_file_mapping);
 pgoff_t __page_file_index(struct page *page)
 {
 	swp_entry_t swap = { .val = page_private(page) };
-	VM_BUG_ON_PAGE(!PageSwapCache(page), page);
+	VM_BUG_ON(!PageSwapCache(page), page);
 	return swp_offset(swap);
 }
 EXPORT_SYMBOL_GPL(__page_file_index);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index dcb47074ae03..c6b1b97d9408 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -647,7 +647,7 @@ void putback_lru_page(struct page *page)
 	bool is_unevictable;
 	int was_unevictable = PageUnevictable(page);
 
-	VM_BUG_ON_PAGE(PageLRU(page), page);
+	VM_BUG_ON(PageLRU(page), page);
 
 redo:
 	ClearPageUnevictable(page);
@@ -837,8 +837,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		if (!trylock_page(page))
 			goto keep;
 
-		VM_BUG_ON_PAGE(PageActive(page), page);
-		VM_BUG_ON_PAGE(page_zone(page) != zone, page);
+		VM_BUG_ON(PageActive(page), page);
+		VM_BUG_ON(page_zone(page) != zone, page);
 
 		sc->nr_scanned++;
 
@@ -1122,14 +1122,14 @@ activate_locked:
 		/* Not a candidate for swapping, so reclaim swap space. */
 		if (PageSwapCache(page) && vm_swap_full())
 			try_to_free_swap(page);
-		VM_BUG_ON_PAGE(PageActive(page), page);
+		VM_BUG_ON(PageActive(page), page);
 		SetPageActive(page);
 		pgactivate++;
 keep_locked:
 		unlock_page(page);
 keep:
 		list_add(&page->lru, &ret_pages);
-		VM_BUG_ON_PAGE(PageLRU(page) || PageUnevictable(page), page);
+		VM_BUG_ON(PageLRU(page) || PageUnevictable(page), page);
 	}
 
 	mem_cgroup_uncharge_list(&free_pages);
@@ -1284,7 +1284,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 		page = lru_to_page(src);
 		prefetchw_prev_lru_page(page, src, flags);
 
-		VM_BUG_ON_PAGE(!PageLRU(page), page);
+		VM_BUG_ON(!PageLRU(page), page);
 
 		switch (__isolate_lru_page(page, mode)) {
 		case 0:
@@ -1339,7 +1339,7 @@ int isolate_lru_page(struct page *page)
 {
 	int ret = -EBUSY;
 
-	VM_BUG_ON_PAGE(!page_count(page), page);
+	VM_BUG_ON(!page_count(page), page);
 
 	if (PageLRU(page)) {
 		struct zone *zone = page_zone(page);
@@ -1410,7 +1410,7 @@ putback_inactive_pages(struct lruvec *lruvec, struct list_head *page_list)
 		struct page *page = lru_to_page(page_list);
 		int lru;
 
-		VM_BUG_ON_PAGE(PageLRU(page), page);
+		VM_BUG_ON(PageLRU(page), page);
 		list_del(&page->lru);
 		if (unlikely(!page_evictable(page))) {
 			spin_unlock_irq(&zone->lru_lock);
@@ -1645,7 +1645,7 @@ static void move_active_pages_to_lru(struct lruvec *lruvec,
 		page = lru_to_page(list);
 		lruvec = mem_cgroup_page_lruvec(page, zone);
 
-		VM_BUG_ON_PAGE(PageLRU(page), page);
+		VM_BUG_ON(PageLRU(page), page);
 		SetPageLRU(page);
 
 		nr_pages = hpage_nr_pages(page);
@@ -3783,7 +3783,7 @@ void check_move_unevictable_pages(struct page **pages, int nr_pages)
 		if (page_evictable(page)) {
 			enum lru_list lru = page_lru_base_type(page);
 
-			VM_BUG_ON_PAGE(PageActive(page), page);
+			VM_BUG_ON(PageActive(page), page);
 			ClearPageUnevictable(page);
 			del_page_from_lru_list(page, lruvec, LRU_UNEVICTABLE);
 			add_page_to_lru_list(page, lruvec, lru);
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
