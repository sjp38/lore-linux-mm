Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 3BE4D6B0078
	for <linux-mm@kvack.org>; Thu, 14 May 2015 13:10:48 -0400 (EDT)
Received: by pdea3 with SMTP id a3so92968684pde.3
        for <linux-mm@kvack.org>; Thu, 14 May 2015 10:10:48 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id kl10si33243460pbd.112.2015.05.14.10.10.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 May 2015 10:10:43 -0700 (PDT)
From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH 08/11] mm: debug: kill VM_BUG_ON_PAGE
Date: Thu, 14 May 2015 13:10:11 -0400
Message-Id: <1431623414-1905-9-git-send-email-sasha.levin@oracle.com>
In-Reply-To: <1431623414-1905-1-git-send-email-sasha.levin@oracle.com>
References: <1431623414-1905-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, kirill@shutemov.name, Sasha Levin <sasha.levin@oracle.com>

Just use VM_BUG() instead.

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 arch/x86/mm/gup.c              |    8 +++----
 include/linux/hugetlb.h        |    2 +-
 include/linux/hugetlb_cgroup.h |    4 ++--
 include/linux/mm.h             |   22 +++++++++---------
 include/linux/mmdebug.h        |    8 -------
 include/linux/page-flags.h     |   26 +++++++++++-----------
 include/linux/pagemap.h        |   11 ++++-----
 mm/cleancache.c                |    6 ++---
 mm/compaction.c                |    2 +-
 mm/filemap.c                   |   18 +++++++--------
 mm/gup.c                       |    6 ++---
 mm/huge_memory.c               |   38 +++++++++++++++----------------
 mm/hugetlb.c                   |   14 ++++++------
 mm/hugetlb_cgroup.c            |    2 +-
 mm/internal.h                  |    8 +++----
 mm/ksm.c                       |   13 ++++++-----
 mm/memcontrol.c                |   48 ++++++++++++++++++++--------------------
 mm/memory.c                    |    8 +++----
 mm/migrate.c                   |    6 ++---
 mm/mlock.c                     |    4 ++--
 mm/page_alloc.c                |   26 +++++++++++-----------
 mm/page_io.c                   |    4 ++--
 mm/rmap.c                      |   14 ++++++------
 mm/shmem.c                     |   10 +++++----
 mm/slub.c                      |    4 ++--
 mm/swap.c                      |   39 ++++++++++++++++----------------
 mm/swap_state.c                |   16 +++++++-------
 mm/swapfile.c                  |    8 +++----
 mm/vmscan.c                    |   24 ++++++++++----------
 29 files changed, 198 insertions(+), 201 deletions(-)

diff --git a/arch/x86/mm/gup.c b/arch/x86/mm/gup.c
index 81bf3d2..b04ea9e 100644
--- a/arch/x86/mm/gup.c
+++ b/arch/x86/mm/gup.c
@@ -108,8 +108,8 @@ static noinline int gup_pte_range(pmd_t pmd, unsigned long addr,
 
 static inline void get_head_page_multiple(struct page *page, int nr)
 {
-	VM_BUG_ON_PAGE(page != compound_head(page), page);
-	VM_BUG_ON_PAGE(page_count(page) == 0, page);
+	VM_BUG(page != compound_head(page), "%pZp", page);
+	VM_BUG(page_count(page) == 0, "%pZp", page);
 	atomic_add(nr, &page->_count);
 	SetPageReferenced(page);
 }
@@ -135,7 +135,7 @@ static noinline int gup_huge_pmd(pmd_t pmd, unsigned long addr,
 	head = pte_page(pte);
 	page = head + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
 	do {
-		VM_BUG_ON_PAGE(compound_head(page) != head, page);
+		VM_BUG(compound_head(page) != head, "%pZp", page);
 		pages[*nr] = page;
 		if (PageTail(page))
 			get_huge_page_tail(page);
@@ -212,7 +212,7 @@ static noinline int gup_huge_pud(pud_t pud, unsigned long addr,
 	head = pte_page(pte);
 	page = head + ((addr & ~PUD_MASK) >> PAGE_SHIFT);
 	do {
-		VM_BUG_ON_PAGE(compound_head(page) != head, page);
+		VM_BUG(compound_head(page) != head, "%pZp", page);
 		pages[*nr] = page;
 		if (PageTail(page))
 			get_huge_page_tail(page);
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 2050261..0da5cc4 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -415,7 +415,7 @@ static inline pte_t arch_make_huge_pte(pte_t entry, struct vm_area_struct *vma,
 
 static inline struct hstate *page_hstate(struct page *page)
 {
-	VM_BUG_ON_PAGE(!PageHuge(page), page);
+	VM_BUG(!PageHuge(page), "%pZp", page);
 	return size_to_hstate(PAGE_SIZE << compound_order(page));
 }
 
diff --git a/include/linux/hugetlb_cgroup.h b/include/linux/hugetlb_cgroup.h
index bcc853e..7cca841 100644
--- a/include/linux/hugetlb_cgroup.h
+++ b/include/linux/hugetlb_cgroup.h
@@ -28,7 +28,7 @@ struct hugetlb_cgroup;
 
 static inline struct hugetlb_cgroup *hugetlb_cgroup_from_page(struct page *page)
 {
-	VM_BUG_ON_PAGE(!PageHuge(page), page);
+	VM_BUG(!PageHuge(page), "%pZp", page);
 
 	if (compound_order(page) < HUGETLB_CGROUP_MIN_ORDER)
 		return NULL;
@@ -38,7 +38,7 @@ static inline struct hugetlb_cgroup *hugetlb_cgroup_from_page(struct page *page)
 static inline
 int set_hugetlb_cgroup(struct page *page, struct hugetlb_cgroup *h_cg)
 {
-	VM_BUG_ON_PAGE(!PageHuge(page), page);
+	VM_BUG(!PageHuge(page), "%pZp", page);
 
 	if (compound_order(page) < HUGETLB_CGROUP_MIN_ORDER)
 		return -1;
diff --git a/include/linux/mm.h b/include/linux/mm.h
index be9247c..3affbc8 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -340,7 +340,7 @@ static inline int get_freepage_migratetype(struct page *page)
  */
 static inline int put_page_testzero(struct page *page)
 {
-	VM_BUG_ON_PAGE(atomic_read(&page->_count) == 0, page);
+	VM_BUG(atomic_read(&page->_count) == 0, "%pZp", page);
 	return atomic_dec_and_test(&page->_count);
 }
 
@@ -404,7 +404,7 @@ extern void kvfree(const void *addr);
 static inline void compound_lock(struct page *page)
 {
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
-	VM_BUG_ON_PAGE(PageSlab(page), page);
+	VM_BUG(PageSlab(page), "%pZp", page);
 	bit_spin_lock(PG_compound_lock, &page->flags);
 #endif
 }
@@ -412,7 +412,7 @@ static inline void compound_lock(struct page *page)
 static inline void compound_unlock(struct page *page)
 {
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
-	VM_BUG_ON_PAGE(PageSlab(page), page);
+	VM_BUG(PageSlab(page), "%pZp", page);
 	bit_spin_unlock(PG_compound_lock, &page->flags);
 #endif
 }
@@ -448,7 +448,7 @@ static inline void page_mapcount_reset(struct page *page)
 
 static inline int page_mapcount(struct page *page)
 {
-	VM_BUG_ON_PAGE(PageSlab(page), page);
+	VM_BUG(PageSlab(page), "%pZp", page);
 	return atomic_read(&page->_mapcount) + 1;
 }
 
@@ -472,7 +472,7 @@ static inline bool __compound_tail_refcounted(struct page *page)
  */
 static inline bool compound_tail_refcounted(struct page *page)
 {
-	VM_BUG_ON_PAGE(!PageHead(page), page);
+	VM_BUG(!PageHead(page), "%pZp", page);
 	return __compound_tail_refcounted(page);
 }
 
@@ -481,9 +481,9 @@ static inline void get_huge_page_tail(struct page *page)
 	/*
 	 * __split_huge_page_refcount() cannot run from under us.
 	 */
-	VM_BUG_ON_PAGE(!PageTail(page), page);
-	VM_BUG_ON_PAGE(page_mapcount(page) < 0, page);
-	VM_BUG_ON_PAGE(atomic_read(&page->_count) != 0, page);
+	VM_BUG(!PageTail(page), "%pZp", page);
+	VM_BUG(page_mapcount(page) < 0, "%pZp", page);
+	VM_BUG(atomic_read(&page->_count) != 0, "%pZp", page);
 	if (compound_tail_refcounted(page->first_page))
 		atomic_inc(&page->_mapcount);
 }
@@ -499,7 +499,7 @@ static inline void get_page(struct page *page)
 	 * Getting a normal page or the head of a compound page
 	 * requires to already have an elevated page->_count.
 	 */
-	VM_BUG_ON_PAGE(atomic_read(&page->_count) <= 0, page);
+	VM_BUG(atomic_read(&page->_count) <= 0, "%pZp", page);
 	atomic_inc(&page->_count);
 }
 
@@ -1441,7 +1441,7 @@ static inline bool ptlock_init(struct page *page)
 	 * slab code uses page->slab_cache and page->first_page (for tail
 	 * pages), which share storage with page->ptl.
 	 */
-	VM_BUG_ON_PAGE(*(unsigned long *)&page->ptl, page);
+	VM_BUG(*(unsigned long *)&page->ptl, "%pZp", page);
 	if (!ptlock_alloc(page))
 		return false;
 	spin_lock_init(ptlock_ptr(page));
@@ -1538,7 +1538,7 @@ static inline bool pgtable_pmd_page_ctor(struct page *page)
 static inline void pgtable_pmd_page_dtor(struct page *page)
 {
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
-	VM_BUG_ON_PAGE(page->pmd_huge_pte, page);
+	VM_BUG(page->pmd_huge_pte, "%pZp", page);
 #endif
 	ptlock_free(page);
 }
diff --git a/include/linux/mmdebug.h b/include/linux/mmdebug.h
index 42f41e3..f43f868 100644
--- a/include/linux/mmdebug.h
+++ b/include/linux/mmdebug.h
@@ -20,13 +20,6 @@ char *format_mm(const struct mm_struct *mm, char *buf, char *end);
 		}							\
 	} while (0)
 #define VM_BUG_ON(cond) VM_BUG(cond, "%s\n", __stringify(cond))
-#define VM_BUG_ON_PAGE(cond, page)					\
-	do {								\
-		if (unlikely(cond)) {					\
-			pr_emerg("%pZp", page);				\
-			BUG();						\
-		}							\
-	} while (0)
 #define VM_BUG_ON_VMA(cond, vma)					\
 	do {								\
 		if (unlikely(cond)) {					\
@@ -55,7 +48,6 @@ static char *format_mm(const struct mm_struct *mm, char *buf, char *end)
 }
 #define VM_BUG(cond, fmt...) BUILD_BUG_ON_INVALID(cond)
 #define VM_BUG_ON(cond) BUILD_BUG_ON_INVALID(cond)
-#define VM_BUG_ON_PAGE(cond, page) VM_BUG_ON(cond)
 #define VM_BUG_ON_VMA(cond, vma) VM_BUG_ON(cond)
 #define VM_BUG_ON_MM(cond, mm) VM_BUG_ON(cond)
 #define VM_WARN_ON(cond) BUILD_BUG_ON_INVALID(cond)
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 91b7f9b..f1a18ad 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -139,13 +139,13 @@ enum pageflags {
 #define PF_HEAD(page, enforce)	compound_head(page)
 #define PF_NO_TAIL(page, enforce) ({					\
 		if (enforce)						\
-			VM_BUG_ON_PAGE(PageTail(page), page);		\
+			VM_BUG(PageTail(page), "%pZp", page);		\
 		else							\
 			page = compound_head(page);			\
 		page;})
 #define PF_NO_COMPOUND(page, enforce) ({					\
 		if (enforce)						\
-			VM_BUG_ON_PAGE(PageCompound(page), page);	\
+			VM_BUG(PageCompound(page), "%pZp", page);	\
 		page;})
 
 /*
@@ -429,14 +429,14 @@ static inline int PageUptodate(struct page *page)
 
 static inline void __SetPageUptodate(struct page *page)
 {
-	VM_BUG_ON_PAGE(PageTail(page), page);
+	VM_BUG(PageTail(page), "%pZp", page);
 	smp_wmb();
 	__set_bit(PG_uptodate, &page->flags);
 }
 
 static inline void SetPageUptodate(struct page *page)
 {
-	VM_BUG_ON_PAGE(PageTail(page), page);
+	VM_BUG(PageTail(page), "%pZp", page);
 	/*
 	 * Memory barrier must be issued before setting the PG_uptodate bit,
 	 * so that all previous stores issued in order to bring the page
@@ -572,7 +572,7 @@ static inline bool page_huge_active(struct page *page)
  */
 static inline int PageTransHuge(struct page *page)
 {
-	VM_BUG_ON_PAGE(PageTail(page), page);
+	VM_BUG(PageTail(page), "%pZp", page);
 	return PageHead(page);
 }
 
@@ -620,13 +620,13 @@ static inline int PageBuddy(struct page *page)
 
 static inline void __SetPageBuddy(struct page *page)
 {
-	VM_BUG_ON_PAGE(atomic_read(&page->_mapcount) != -1, page);
+	VM_BUG(atomic_read(&page->_mapcount) != -1, "%pZp", page);
 	atomic_set(&page->_mapcount, PAGE_BUDDY_MAPCOUNT_VALUE);
 }
 
 static inline void __ClearPageBuddy(struct page *page)
 {
-	VM_BUG_ON_PAGE(!PageBuddy(page), page);
+	VM_BUG(!PageBuddy(page), "%pZp", page);
 	atomic_set(&page->_mapcount, -1);
 }
 
@@ -639,13 +639,13 @@ static inline int PageBalloon(struct page *page)
 
 static inline void __SetPageBalloon(struct page *page)
 {
-	VM_BUG_ON_PAGE(atomic_read(&page->_mapcount) != -1, page);
+	VM_BUG(atomic_read(&page->_mapcount) != -1, "%pZp", page);
 	atomic_set(&page->_mapcount, PAGE_BALLOON_MAPCOUNT_VALUE);
 }
 
 static inline void __ClearPageBalloon(struct page *page)
 {
-	VM_BUG_ON_PAGE(!PageBalloon(page), page);
+	VM_BUG(!PageBalloon(page), "%pZp", page);
 	atomic_set(&page->_mapcount, -1);
 }
 
@@ -655,25 +655,25 @@ static inline void __ClearPageBalloon(struct page *page)
  */
 static inline int PageSlabPfmemalloc(struct page *page)
 {
-	VM_BUG_ON_PAGE(!PageSlab(page), page);
+	VM_BUG(!PageSlab(page), "%pZp", page);
 	return PageActive(page);
 }
 
 static inline void SetPageSlabPfmemalloc(struct page *page)
 {
-	VM_BUG_ON_PAGE(!PageSlab(page), page);
+	VM_BUG(!PageSlab(page), "%pZp", page);
 	SetPageActive(page);
 }
 
 static inline void __ClearPageSlabPfmemalloc(struct page *page)
 {
-	VM_BUG_ON_PAGE(!PageSlab(page), page);
+	VM_BUG(!PageSlab(page), "%pZp", page);
 	__ClearPageActive(page);
 }
 
 static inline void ClearPageSlabPfmemalloc(struct page *page)
 {
-	VM_BUG_ON_PAGE(!PageSlab(page), page);
+	VM_BUG(!PageSlab(page), "%pZp", page);
 	ClearPageActive(page);
 }
 
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 7c37907..fa9ba8b 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -157,7 +157,7 @@ static inline int page_cache_get_speculative(struct page *page)
 	 * disabling preempt, and hence no need for the "speculative get" that
 	 * SMP requires.
 	 */
-	VM_BUG_ON_PAGE(page_count(page) == 0, page);
+	VM_BUG(page_count(page) == 0, "%pZp", page);
 	atomic_inc(&page->_count);
 
 #else
@@ -170,7 +170,7 @@ static inline int page_cache_get_speculative(struct page *page)
 		return 0;
 	}
 #endif
-	VM_BUG_ON_PAGE(PageTail(page), page);
+	VM_BUG(PageTail(page), "%pZp", page);
 
 	return 1;
 }
@@ -186,14 +186,15 @@ static inline int page_cache_add_speculative(struct page *page, int count)
 # ifdef CONFIG_PREEMPT_COUNT
 	VM_BUG_ON(!in_atomic());
 # endif
-	VM_BUG_ON_PAGE(page_count(page) == 0, page);
+	VM_BUG(page_count(page) == 0, "%pZp", page);
 	atomic_add(count, &page->_count);
 
 #else
 	if (unlikely(!atomic_add_unless(&page->_count, count, 0)))
 		return 0;
 #endif
-	VM_BUG_ON_PAGE(PageCompound(page) && page != compound_head(page), page);
+	VM_BUG(PageCompound(page) && page != compound_head(page), "%pZp",
+	       page);
 
 	return 1;
 }
@@ -205,7 +206,7 @@ static inline int page_freeze_refs(struct page *page, int count)
 
 static inline void page_unfreeze_refs(struct page *page, int count)
 {
-	VM_BUG_ON_PAGE(page_count(page) != 0, page);
+	VM_BUG(page_count(page) != 0, "%pZp", page);
 	VM_BUG_ON(count == 0);
 
 	atomic_set(&page->_count, count);
diff --git a/mm/cleancache.c b/mm/cleancache.c
index 8fc5081..d4d5ce0 100644
--- a/mm/cleancache.c
+++ b/mm/cleancache.c
@@ -185,7 +185,7 @@ int __cleancache_get_page(struct page *page)
 		goto out;
 	}
 
-	VM_BUG_ON_PAGE(!PageLocked(page), page);
+	VM_BUG(!PageLocked(page), "%pZp", page);
 	pool_id = page->mapping->host->i_sb->cleancache_poolid;
 	if (pool_id < 0)
 		goto out;
@@ -223,7 +223,7 @@ void __cleancache_put_page(struct page *page)
 		return;
 	}
 
-	VM_BUG_ON_PAGE(!PageLocked(page), page);
+	VM_BUG(!PageLocked(page), "%pZp", page);
 	pool_id = page->mapping->host->i_sb->cleancache_poolid;
 	if (pool_id >= 0 &&
 		cleancache_get_key(page->mapping->host, &key) >= 0) {
@@ -252,7 +252,7 @@ void __cleancache_invalidate_page(struct address_space *mapping,
 		return;
 
 	if (pool_id >= 0) {
-		VM_BUG_ON_PAGE(!PageLocked(page), page);
+		VM_BUG(!PageLocked(page), "%pZp", page);
 		if (cleancache_get_key(mapping->host, &key) >= 0) {
 			cleancache_ops->invalidate_page(pool_id,
 					key, page->index);
diff --git a/mm/compaction.c b/mm/compaction.c
index 6ef2fdf..170bf6c 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -779,7 +779,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 		if (__isolate_lru_page(page, isolate_mode) != 0)
 			continue;
 
-		VM_BUG_ON_PAGE(PageCompound(page), page);
+		VM_BUG(PageCompound(page), "%pZp", page);
 
 		/* Successfully isolated */
 		del_page_from_lru_list(page, lruvec, page_lru(page));
diff --git a/mm/filemap.c b/mm/filemap.c
index 6ad0a80..ec1ab0aa 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -462,9 +462,9 @@ int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
 {
 	int error;
 
-	VM_BUG_ON_PAGE(!PageLocked(old), old);
-	VM_BUG_ON_PAGE(!PageLocked(new), new);
-	VM_BUG_ON_PAGE(new->mapping, new);
+	VM_BUG(!PageLocked(old), "%pZp", old);
+	VM_BUG(!PageLocked(new), "%pZp", new);
+	VM_BUG(new->mapping, "%pZp", new);
 
 	error = radix_tree_preload(gfp_mask & ~__GFP_HIGHMEM);
 	if (!error) {
@@ -549,8 +549,8 @@ static int __add_to_page_cache_locked(struct page *page,
 	struct mem_cgroup *memcg;
 	int error;
 
-	VM_BUG_ON_PAGE(!PageLocked(page), page);
-	VM_BUG_ON_PAGE(PageSwapBacked(page), page);
+	VM_BUG(!PageLocked(page), "%pZp", page);
+	VM_BUG(PageSwapBacked(page), "%pZp", page);
 
 	if (!huge) {
 		error = mem_cgroup_try_charge(page, current->mm,
@@ -743,7 +743,7 @@ EXPORT_SYMBOL_GPL(add_page_wait_queue);
 void unlock_page(struct page *page)
 {
 	page = compound_head(page);
-	VM_BUG_ON_PAGE(!PageLocked(page), page);
+	VM_BUG(!PageLocked(page), "%pZp", page);
 	clear_bit_unlock(PG_locked, &page->flags);
 	smp_mb__after_atomic();
 	wake_up_page(page, PG_locked);
@@ -1036,7 +1036,7 @@ repeat:
 			page_cache_release(page);
 			goto repeat;
 		}
-		VM_BUG_ON_PAGE(page->index != offset, page);
+		VM_BUG(page->index != offset, "%pZp", page);
 	}
 	return page;
 }
@@ -1093,7 +1093,7 @@ repeat:
 			page_cache_release(page);
 			goto repeat;
 		}
-		VM_BUG_ON_PAGE(page->index != offset, page);
+		VM_BUG(page->index != offset, "%pZp", page);
 	}
 
 	if (page && (fgp_flags & FGP_ACCESSED))
@@ -1914,7 +1914,7 @@ retry_find:
 		put_page(page);
 		goto retry_find;
 	}
-	VM_BUG_ON_PAGE(page->index != offset, page);
+	VM_BUG(page->index != offset, "%pZp", page);
 
 	/*
 	 * We have a locked page in the page cache, now we need to check
diff --git a/mm/gup.c b/mm/gup.c
index 6297f6b..743648e 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1084,7 +1084,7 @@ static int gup_huge_pmd(pmd_t orig, pmd_t *pmdp, unsigned long addr,
 	page = head + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
 	tail = page;
 	do {
-		VM_BUG_ON_PAGE(compound_head(page) != head, page);
+		VM_BUG(compound_head(page) != head, "%pZp", page);
 		pages[*nr] = page;
 		(*nr)++;
 		page++;
@@ -1131,7 +1131,7 @@ static int gup_huge_pud(pud_t orig, pud_t *pudp, unsigned long addr,
 	page = head + ((addr & ~PUD_MASK) >> PAGE_SHIFT);
 	tail = page;
 	do {
-		VM_BUG_ON_PAGE(compound_head(page) != head, page);
+		VM_BUG(compound_head(page) != head, "%pZp", page);
 		pages[*nr] = page;
 		(*nr)++;
 		page++;
@@ -1174,7 +1174,7 @@ static int gup_huge_pgd(pgd_t orig, pgd_t *pgdp, unsigned long addr,
 	page = head + ((addr & ~PGDIR_MASK) >> PAGE_SHIFT);
 	tail = page;
 	do {
-		VM_BUG_ON_PAGE(compound_head(page) != head, page);
+		VM_BUG(compound_head(page) != head, "%pZp", page);
 		pages[*nr] = page;
 		(*nr)++;
 		page++;
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index e103a9a..82ccd2c 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -723,7 +723,7 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 	pgtable_t pgtable;
 	spinlock_t *ptl;
 
-	VM_BUG_ON_PAGE(!PageCompound(page), page);
+	VM_BUG(!PageCompound(page), "%pZp", page);
 
 	if (mem_cgroup_try_charge(page, mm, gfp, &memcg))
 		return VM_FAULT_OOM;
@@ -897,7 +897,7 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		goto out;
 	}
 	src_page = pmd_page(pmd);
-	VM_BUG_ON_PAGE(!PageHead(src_page), src_page);
+	VM_BUG(!PageHead(src_page), "%pZp", src_page);
 	get_page(src_page);
 	page_dup_rmap(src_page);
 	add_mm_counter(dst_mm, MM_ANONPAGES, HPAGE_PMD_NR);
@@ -1029,7 +1029,7 @@ static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
 	ptl = pmd_lock(mm, pmd);
 	if (unlikely(!pmd_same(*pmd, orig_pmd)))
 		goto out_free_pages;
-	VM_BUG_ON_PAGE(!PageHead(page), page);
+	VM_BUG(!PageHead(page), "%pZp", page);
 
 	pmdp_clear_flush_notify(vma, haddr, pmd);
 	/* leave pmd empty until pte is filled */
@@ -1101,7 +1101,7 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		goto out_unlock;
 
 	page = pmd_page(orig_pmd);
-	VM_BUG_ON_PAGE(!PageCompound(page) || !PageHead(page), page);
+	VM_BUG(!PageCompound(page) || !PageHead(page), "%pZp", page);
 	if (page_mapcount(page) == 1) {
 		pmd_t entry;
 		entry = pmd_mkyoung(orig_pmd);
@@ -1184,7 +1184,7 @@ alloc:
 			add_mm_counter(mm, MM_ANONPAGES, HPAGE_PMD_NR);
 			put_huge_zero_page();
 		} else {
-			VM_BUG_ON_PAGE(!PageHead(page), page);
+			VM_BUG(!PageHead(page), "%pZp", page);
 			page_remove_rmap(page);
 			put_page(page);
 		}
@@ -1222,7 +1222,7 @@ struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
 		goto out;
 
 	page = pmd_page(*pmd);
-	VM_BUG_ON_PAGE(!PageHead(page), page);
+	VM_BUG(!PageHead(page), "%pZp", page);
 	if (flags & FOLL_TOUCH) {
 		pmd_t _pmd;
 		/*
@@ -1247,7 +1247,7 @@ struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
 		}
 	}
 	page += (addr & ~HPAGE_PMD_MASK) >> PAGE_SHIFT;
-	VM_BUG_ON_PAGE(!PageCompound(page), page);
+	VM_BUG(!PageCompound(page), "%pZp", page);
 	if (flags & FOLL_GET)
 		get_page_foll(page);
 
@@ -1400,7 +1400,7 @@ int madvise_free_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 
 		/* No hugepage in swapcache */
 		page = pmd_page(orig_pmd);
-		VM_BUG_ON_PAGE(PageSwapCache(page), page);
+		VM_BUG(PageSwapCache(page), "%pZp", page);
 
 		orig_pmd = pmd_mkold(orig_pmd);
 		orig_pmd = pmd_mkclean(orig_pmd);
@@ -1441,9 +1441,9 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		} else {
 			page = pmd_page(orig_pmd);
 			page_remove_rmap(page);
-			VM_BUG_ON_PAGE(page_mapcount(page) < 0, page);
+			VM_BUG(page_mapcount(page) < 0, "%pZp", page);
 			add_mm_counter(tlb->mm, MM_ANONPAGES, -HPAGE_PMD_NR);
-			VM_BUG_ON_PAGE(!PageHead(page), page);
+			VM_BUG(!PageHead(page), "%pZp", page);
 			atomic_long_dec(&tlb->mm->nr_ptes);
 			spin_unlock(ptl);
 			tlb_remove_page(tlb, page);
@@ -2189,9 +2189,9 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
 		if (unlikely(!page))
 			goto out;
 
-		VM_BUG_ON_PAGE(PageCompound(page), page);
-		VM_BUG_ON_PAGE(!PageAnon(page), page);
-		VM_BUG_ON_PAGE(!PageSwapBacked(page), page);
+		VM_BUG(PageCompound(page), "%pZp", page);
+		VM_BUG(!PageAnon(page), "%pZp", page);
+		VM_BUG(!PageSwapBacked(page), "%pZp", page);
 
 		/*
 		 * We can do it before isolate_lru_page because the
@@ -2234,8 +2234,8 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
 		}
 		/* 0 stands for page_is_file_cache(page) == false */
 		inc_zone_page_state(page, NR_ISOLATED_ANON + 0);
-		VM_BUG_ON_PAGE(!PageLocked(page), page);
-		VM_BUG_ON_PAGE(PageLRU(page), page);
+		VM_BUG(!PageLocked(page), "%pZp", page);
+		VM_BUG(PageLRU(page), "%pZp", page);
 
 		/* If there is no mapped pte young don't collapse the page */
 		if (pte_young(pteval) || PageReferenced(page) ||
@@ -2277,7 +2277,7 @@ static void __collapse_huge_page_copy(pte_t *pte, struct page *page,
 		} else {
 			src_page = pte_page(pteval);
 			copy_user_highpage(page, src_page, address, vma);
-			VM_BUG_ON_PAGE(page_mapcount(src_page) != 1, src_page);
+			VM_BUG(page_mapcount(src_page) != 1, "%pZp", src_page);
 			release_pte_page(src_page);
 			/*
 			 * ptl mostly unnecessary, but preempt has to
@@ -2380,7 +2380,7 @@ khugepaged_alloc_page(struct page **hpage, gfp_t gfp, struct mm_struct *mm,
 		       struct vm_area_struct *vma, unsigned long address,
 		       int node)
 {
-	VM_BUG_ON_PAGE(*hpage, *hpage);
+	VM_BUG(*hpage, "%pZp", *hpage);
 
 	/*
 	 * Before allocating the hugepage, release the mmap_sem read lock.
@@ -2654,7 +2654,7 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
 		if (khugepaged_scan_abort(node))
 			goto out_unmap;
 		khugepaged_node_load[node]++;
-		VM_BUG_ON_PAGE(PageCompound(page), page);
+		VM_BUG(PageCompound(page), "%pZp", page);
 		if (!PageLRU(page) || PageLocked(page) || !PageAnon(page))
 			goto out_unmap;
 		/*
@@ -2952,7 +2952,7 @@ again:
 		return;
 	}
 	page = pmd_page(*pmd);
-	VM_BUG_ON_PAGE(!page_count(page), page);
+	VM_BUG(!page_count(page), "%pZp", page);
 	get_page(page);
 	spin_unlock(ptl);
 	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 716465a..55c75da 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -901,7 +901,7 @@ static void update_and_free_page(struct hstate *h, struct page *page)
 				1 << PG_active | 1 << PG_private |
 				1 << PG_writeback);
 	}
-	VM_BUG_ON_PAGE(hugetlb_cgroup_from_page(page), page);
+	VM_BUG(hugetlb_cgroup_from_page(page), "%pZp", page);
 	set_compound_page_dtor(page, NULL);
 	set_page_refcounted(page);
 	if (hstate_is_gigantic(h)) {
@@ -932,20 +932,20 @@ struct hstate *size_to_hstate(unsigned long size)
  */
 bool page_huge_active(struct page *page)
 {
-	VM_BUG_ON_PAGE(!PageHuge(page), page);
+	VM_BUG(!PageHuge(page), "%pZp", page);
 	return PageHead(page) && PagePrivate(&page[1]);
 }
 
 /* never called for tail page */
 static void set_page_huge_active(struct page *page)
 {
-	VM_BUG_ON_PAGE(!PageHeadHuge(page), page);
+	VM_BUG(!PageHeadHuge(page), "%pZp", page);
 	SetPagePrivate(&page[1]);
 }
 
 static void clear_page_huge_active(struct page *page)
 {
-	VM_BUG_ON_PAGE(!PageHeadHuge(page), page);
+	VM_BUG(!PageHeadHuge(page), "%pZp", page);
 	ClearPagePrivate(&page[1]);
 }
 
@@ -1373,7 +1373,7 @@ retry:
 		 * no users -- drop the buddy allocator's reference.
 		 */
 		put_page_testzero(page);
-		VM_BUG_ON_PAGE(page_count(page), page);
+		VM_BUG(page_count(page), "%pZp", page);
 		enqueue_huge_page(h, page);
 	}
 free:
@@ -3938,7 +3938,7 @@ bool isolate_huge_page(struct page *page, struct list_head *list)
 {
 	bool ret = true;
 
-	VM_BUG_ON_PAGE(!PageHead(page), page);
+	VM_BUG(!PageHead(page), "%pZp", page);
 	spin_lock(&hugetlb_lock);
 	if (!page_huge_active(page) || !get_page_unless_zero(page)) {
 		ret = false;
@@ -3953,7 +3953,7 @@ unlock:
 
 void putback_active_hugepage(struct page *page)
 {
-	VM_BUG_ON_PAGE(!PageHead(page), page);
+	VM_BUG(!PageHead(page), "%pZp", page);
 	spin_lock(&hugetlb_lock);
 	set_page_huge_active(page);
 	list_move_tail(&page->lru, &(page_hstate(page))->hugepage_activelist);
diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
index 6e00574..9df90f5 100644
--- a/mm/hugetlb_cgroup.c
+++ b/mm/hugetlb_cgroup.c
@@ -403,7 +403,7 @@ void hugetlb_cgroup_migrate(struct page *oldhpage, struct page *newhpage)
 	if (hugetlb_cgroup_disabled())
 		return;
 
-	VM_BUG_ON_PAGE(!PageHuge(oldhpage), oldhpage);
+	VM_BUG(!PageHuge(oldhpage), "%pZp", oldhpage);
 	spin_lock(&hugetlb_lock);
 	h_cg = hugetlb_cgroup_from_page(oldhpage);
 	set_hugetlb_cgroup(oldhpage, NULL);
diff --git a/mm/internal.h b/mm/internal.h
index a48cbef..b7d9a96 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -42,8 +42,8 @@ static inline unsigned long ra_submit(struct file_ra_state *ra,
  */
 static inline void set_page_refcounted(struct page *page)
 {
-	VM_BUG_ON_PAGE(PageTail(page), page);
-	VM_BUG_ON_PAGE(atomic_read(&page->_count), page);
+	VM_BUG(PageTail(page), "%pZp", page);
+	VM_BUG(atomic_read(&page->_count), "%pZp", page);
 	set_page_count(page, 1);
 }
 
@@ -61,7 +61,7 @@ static inline void __get_page_tail_foll(struct page *page,
 	 * speculative page access (like in
 	 * page_cache_get_speculative()) on tail pages.
 	 */
-	VM_BUG_ON_PAGE(atomic_read(&page->first_page->_count) <= 0, page);
+	VM_BUG(atomic_read(&page->first_page->_count) <= 0, "%pZp", page);
 	if (get_page_head)
 		atomic_inc(&page->first_page->_count);
 	get_huge_page_tail(page);
@@ -86,7 +86,7 @@ static inline void get_page_foll(struct page *page)
 		 * Getting a normal page or the head of a compound page
 		 * requires to already have an elevated page->_count.
 		 */
-		VM_BUG_ON_PAGE(atomic_read(&page->_count) <= 0, page);
+		VM_BUG(atomic_read(&page->_count) <= 0, "%pZp", page);
 		atomic_inc(&page->_count);
 	}
 }
diff --git a/mm/ksm.c b/mm/ksm.c
index bc7be0e..040185f 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1897,13 +1897,13 @@ int rmap_walk_ksm(struct page *page, struct rmap_walk_control *rwc)
 	int ret = SWAP_AGAIN;
 	int search_new_forks = 0;
 
-	VM_BUG_ON_PAGE(!PageKsm(page), page);
+	VM_BUG(!PageKsm(page), "%pZp", page);
 
 	/*
 	 * Rely on the page lock to protect against concurrent modifications
 	 * to that page's node of the stable tree.
 	 */
-	VM_BUG_ON_PAGE(!PageLocked(page), page);
+	VM_BUG(!PageLocked(page), "%pZp", page);
 
 	stable_node = page_stable_node(page);
 	if (!stable_node)
@@ -1957,13 +1957,14 @@ void ksm_migrate_page(struct page *newpage, struct page *oldpage)
 {
 	struct stable_node *stable_node;
 
-	VM_BUG_ON_PAGE(!PageLocked(oldpage), oldpage);
-	VM_BUG_ON_PAGE(!PageLocked(newpage), newpage);
-	VM_BUG_ON_PAGE(newpage->mapping != oldpage->mapping, newpage);
+	VM_BUG(!PageLocked(oldpage), "%pZp", oldpage);
+	VM_BUG(!PageLocked(newpage), "%pZp", newpage);
+	VM_BUG(newpage->mapping != oldpage->mapping, "%pZp", newpage);
 
 	stable_node = page_stable_node(newpage);
 	if (stable_node) {
-		VM_BUG_ON_PAGE(stable_node->kpfn != page_to_pfn(oldpage), oldpage);
+		VM_BUG(stable_node->kpfn != page_to_pfn(oldpage), "%pZp",
+		       oldpage);
 		stable_node->kpfn = page_to_pfn(newpage);
 		/*
 		 * newpage->mapping was set in advance; now we need smp_wmb()
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 14c2f20..6ae7c39 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2365,7 +2365,7 @@ struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
 	unsigned short id;
 	swp_entry_t ent;
 
-	VM_BUG_ON_PAGE(!PageLocked(page), page);
+	VM_BUG(!PageLocked(page), "%pZp", page);
 
 	memcg = page->mem_cgroup;
 	if (memcg) {
@@ -2407,7 +2407,7 @@ static void unlock_page_lru(struct page *page, int isolated)
 		struct lruvec *lruvec;
 
 		lruvec = mem_cgroup_page_lruvec(page, zone);
-		VM_BUG_ON_PAGE(PageLRU(page), page);
+		VM_BUG(PageLRU(page), "%pZp", page);
 		SetPageLRU(page);
 		add_page_to_lru_list(page, lruvec, page_lru(page));
 	}
@@ -2419,7 +2419,7 @@ static void commit_charge(struct page *page, struct mem_cgroup *memcg,
 {
 	int isolated;
 
-	VM_BUG_ON_PAGE(page->mem_cgroup, page);
+	VM_BUG(page->mem_cgroup, "%pZp", page);
 
 	/*
 	 * In some cases, SwapCache and FUSE(splice_buf->radixtree), the page
@@ -2726,7 +2726,7 @@ void __memcg_kmem_uncharge_pages(struct page *page, int order)
 	if (!memcg)
 		return;
 
-	VM_BUG_ON_PAGE(mem_cgroup_is_root(memcg), page);
+	VM_BUG(mem_cgroup_is_root(memcg), "%pZp", page);
 
 	memcg_uncharge_kmem(memcg, 1 << order);
 	page->mem_cgroup = NULL;
@@ -4748,7 +4748,7 @@ static int mem_cgroup_move_account(struct page *page,
 	int ret;
 
 	VM_BUG_ON(from == to);
-	VM_BUG_ON_PAGE(PageLRU(page), page);
+	VM_BUG(PageLRU(page), "%pZp", page);
 	/*
 	 * The page is isolated from LRU. So, collapse function
 	 * will not handle this page. But page splitting can happen.
@@ -4864,7 +4864,7 @@ static enum mc_target_type get_mctgt_type_thp(struct vm_area_struct *vma,
 	enum mc_target_type ret = MC_TARGET_NONE;
 
 	page = pmd_page(pmd);
-	VM_BUG_ON_PAGE(!page || !PageHead(page), page);
+	VM_BUG(!page || !PageHead(page), "%pZp", page);
 	if (!(mc.flags & MOVE_ANON))
 		return ret;
 	if (page->mem_cgroup == mc.from) {
@@ -5479,7 +5479,7 @@ int mem_cgroup_try_charge(struct page *page, struct mm_struct *mm,
 
 	if (PageTransHuge(page)) {
 		nr_pages <<= compound_order(page);
-		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
+		VM_BUG(!PageTransHuge(page), "%pZp", page);
 	}
 
 	if (do_swap_account && PageSwapCache(page))
@@ -5521,8 +5521,8 @@ void mem_cgroup_commit_charge(struct page *page, struct mem_cgroup *memcg,
 {
 	unsigned int nr_pages = 1;
 
-	VM_BUG_ON_PAGE(!page->mapping, page);
-	VM_BUG_ON_PAGE(PageLRU(page) && !lrucare, page);
+	VM_BUG(!page->mapping, "%pZp", page);
+	VM_BUG(PageLRU(page) && !lrucare, "%pZp", page);
 
 	if (mem_cgroup_disabled())
 		return;
@@ -5538,7 +5538,7 @@ void mem_cgroup_commit_charge(struct page *page, struct mem_cgroup *memcg,
 
 	if (PageTransHuge(page)) {
 		nr_pages <<= compound_order(page);
-		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
+		VM_BUG(!PageTransHuge(page), "%pZp", page);
 	}
 
 	local_irq_disable();
@@ -5580,7 +5580,7 @@ void mem_cgroup_cancel_charge(struct page *page, struct mem_cgroup *memcg)
 
 	if (PageTransHuge(page)) {
 		nr_pages <<= compound_order(page);
-		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
+		VM_BUG(!PageTransHuge(page), "%pZp", page);
 	}
 
 	cancel_charge(memcg, nr_pages);
@@ -5630,8 +5630,8 @@ static void uncharge_list(struct list_head *page_list)
 		page = list_entry(next, struct page, lru);
 		next = page->lru.next;
 
-		VM_BUG_ON_PAGE(PageLRU(page), page);
-		VM_BUG_ON_PAGE(page_count(page), page);
+		VM_BUG(PageLRU(page), "%pZp", page);
+		VM_BUG(page_count(page), "%pZp", page);
 
 		if (!page->mem_cgroup)
 			continue;
@@ -5653,7 +5653,7 @@ static void uncharge_list(struct list_head *page_list)
 
 		if (PageTransHuge(page)) {
 			nr_pages <<= compound_order(page);
-			VM_BUG_ON_PAGE(!PageTransHuge(page), page);
+			VM_BUG(!PageTransHuge(page), "%pZp", page);
 			nr_huge += nr_pages;
 		}
 
@@ -5724,13 +5724,13 @@ void mem_cgroup_migrate(struct page *oldpage, struct page *newpage,
 	struct mem_cgroup *memcg;
 	int isolated;
 
-	VM_BUG_ON_PAGE(!PageLocked(oldpage), oldpage);
-	VM_BUG_ON_PAGE(!PageLocked(newpage), newpage);
-	VM_BUG_ON_PAGE(!lrucare && PageLRU(oldpage), oldpage);
-	VM_BUG_ON_PAGE(!lrucare && PageLRU(newpage), newpage);
-	VM_BUG_ON_PAGE(PageAnon(oldpage) != PageAnon(newpage), newpage);
-	VM_BUG_ON_PAGE(PageTransHuge(oldpage) != PageTransHuge(newpage),
-		       newpage);
+	VM_BUG(!PageLocked(oldpage), "%pZp", oldpage);
+	VM_BUG(!PageLocked(newpage), "%pZp", newpage);
+	VM_BUG(!lrucare && PageLRU(oldpage), "%pZp", oldpage);
+	VM_BUG(!lrucare && PageLRU(newpage), "%pZp", newpage);
+	VM_BUG(PageAnon(oldpage) != PageAnon(newpage), "%pZp", newpage);
+	VM_BUG(PageTransHuge(oldpage) != PageTransHuge(newpage), "%pZp",
+	       newpage);
 
 	if (mem_cgroup_disabled())
 		return;
@@ -5812,8 +5812,8 @@ void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
 	struct mem_cgroup *memcg;
 	unsigned short oldid;
 
-	VM_BUG_ON_PAGE(PageLRU(page), page);
-	VM_BUG_ON_PAGE(page_count(page), page);
+	VM_BUG(PageLRU(page), "%pZp", page);
+	VM_BUG(page_count(page), "%pZp", page);
 
 	if (!do_swap_account)
 		return;
@@ -5825,7 +5825,7 @@ void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
 		return;
 
 	oldid = swap_cgroup_record(entry, mem_cgroup_id(memcg));
-	VM_BUG_ON_PAGE(oldid, page);
+	VM_BUG(oldid, "%pZp", page);
 	mem_cgroup_swap_statistics(memcg, true);
 
 	page->mem_cgroup = NULL;
diff --git a/mm/memory.c b/mm/memory.c
index 6e5d4bd..dd509d9 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -302,7 +302,7 @@ int __tlb_remove_page(struct mmu_gather *tlb, struct page *page)
 			return 0;
 		batch = tlb->active;
 	}
-	VM_BUG_ON_PAGE(batch->nr > batch->max, page);
+	VM_BUG(batch->nr > batch->max, "%pZp", page);
 
 	return batch->max - batch->nr;
 }
@@ -1977,7 +1977,7 @@ static int do_page_mkwrite(struct vm_area_struct *vma, struct page *page,
 		}
 		ret |= VM_FAULT_LOCKED;
 	} else
-		VM_BUG_ON_PAGE(!PageLocked(page), page);
+		VM_BUG(!PageLocked(page), "%pZp", page);
 	return ret;
 }
 
@@ -2020,7 +2020,7 @@ static inline int wp_page_reuse(struct mm_struct *mm,
 			lock_page(page);
 
 		dirtied = set_page_dirty(page);
-		VM_BUG_ON_PAGE(PageAnon(page), page);
+		VM_BUG(PageAnon(page), "%pZp", page);
 		mapping = page->mapping;
 		unlock_page(page);
 		page_cache_release(page);
@@ -2763,7 +2763,7 @@ static int __do_fault(struct vm_area_struct *vma, unsigned long address,
 	if (unlikely(!(ret & VM_FAULT_LOCKED)))
 		lock_page(vmf.page);
 	else
-		VM_BUG_ON_PAGE(!PageLocked(vmf.page), vmf.page);
+		VM_BUG(!PageLocked(vmf.page), "%pZp", vmf.page);
 
  out:
 	*page = vmf.page;
diff --git a/mm/migrate.c b/mm/migrate.c
index 022adc2..2693888 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -500,7 +500,7 @@ void migrate_page_copy(struct page *newpage, struct page *page)
 	if (PageUptodate(page))
 		SetPageUptodate(newpage);
 	if (TestClearPageActive(page)) {
-		VM_BUG_ON_PAGE(PageUnevictable(page), page);
+		VM_BUG(PageUnevictable(page), "%pZp", page);
 		SetPageActive(newpage);
 	} else if (TestClearPageUnevictable(page))
 		SetPageUnevictable(newpage);
@@ -869,7 +869,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 	 * free the metadata, so the page can be freed.
 	 */
 	if (!page->mapping) {
-		VM_BUG_ON_PAGE(PageAnon(page), page);
+		VM_BUG(PageAnon(page), "%pZp", page);
 		if (page_has_private(page)) {
 			try_to_free_buffers(page);
 			goto out_unlock;
@@ -1606,7 +1606,7 @@ static int numamigrate_isolate_page(pg_data_t *pgdat, struct page *page)
 {
 	int page_lru;
 
-	VM_BUG_ON_PAGE(compound_order(page) && !PageTransHuge(page), page);
+	VM_BUG(compound_order(page) && !PageTransHuge(page), "%pZp", page);
 
 	/* Avoid migrating to a node that is nearly full */
 	if (!migrate_balanced_pgdat(pgdat, 1UL << compound_order(page)))
diff --git a/mm/mlock.c b/mm/mlock.c
index 6fd2cf1..54269cd 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -232,8 +232,8 @@ static int __mlock_posix_error_return(long retval)
 static bool __putback_lru_fast_prepare(struct page *page, struct pagevec *pvec,
 		int *pgrescued)
 {
-	VM_BUG_ON_PAGE(PageLRU(page), page);
-	VM_BUG_ON_PAGE(!PageLocked(page), page);
+	VM_BUG(PageLRU(page), "%pZp", page);
+	VM_BUG(!PageLocked(page), "%pZp", page);
 
 	if (page_mapcount(page) <= 1 && page_evictable(page)) {
 		pagevec_add(pvec, page);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 06577ec..4d3668f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -596,7 +596,7 @@ static inline int page_is_buddy(struct page *page, struct page *buddy,
 		if (page_zone_id(page) != page_zone_id(buddy))
 			return 0;
 
-		VM_BUG_ON_PAGE(page_count(buddy) != 0, buddy);
+		VM_BUG(page_count(buddy) != 0, "%pZp", buddy);
 
 		return 1;
 	}
@@ -610,7 +610,7 @@ static inline int page_is_buddy(struct page *page, struct page *buddy,
 		if (page_zone_id(page) != page_zone_id(buddy))
 			return 0;
 
-		VM_BUG_ON_PAGE(page_count(buddy) != 0, buddy);
+		VM_BUG(page_count(buddy) != 0, "%pZp", buddy);
 
 		return 1;
 	}
@@ -654,7 +654,7 @@ static inline void __free_one_page(struct page *page,
 	int max_order = MAX_ORDER;
 
 	VM_BUG_ON(!zone_is_initialized(zone));
-	VM_BUG_ON_PAGE(page->flags & PAGE_FLAGS_CHECK_AT_PREP, page);
+	VM_BUG(page->flags & PAGE_FLAGS_CHECK_AT_PREP, "%pZp", page);
 
 	VM_BUG_ON(migratetype == -1);
 	if (is_migrate_isolate(migratetype)) {
@@ -671,8 +671,8 @@ static inline void __free_one_page(struct page *page,
 
 	page_idx = pfn & ((1 << max_order) - 1);
 
-	VM_BUG_ON_PAGE(page_idx & ((1 << order) - 1), page);
-	VM_BUG_ON_PAGE(bad_range(zone, page), page);
+	VM_BUG(page_idx & ((1 << order) - 1), "%pZp", page);
+	VM_BUG(bad_range(zone, page), "%pZp", page);
 
 	while (order < max_order - 1) {
 		buddy_idx = __find_buddy_index(page_idx, order);
@@ -930,8 +930,8 @@ static bool free_pages_prepare(struct page *page, unsigned int order)
 	bool compound = PageCompound(page);
 	int i, bad = 0;
 
-	VM_BUG_ON_PAGE(PageTail(page), page);
-	VM_BUG_ON_PAGE(compound && compound_order(page) != order, page);
+	VM_BUG(PageTail(page), "%pZp", page);
+	VM_BUG(compound && compound_order(page) != order, "%pZp", page);
 
 	trace_mm_page_free(page, order);
 	kmemcheck_free_shadow(page, order);
@@ -1246,7 +1246,7 @@ static inline void expand(struct zone *zone, struct page *page,
 		area--;
 		high--;
 		size >>= 1;
-		VM_BUG_ON_PAGE(bad_range(zone, &page[size]), &page[size]);
+		VM_BUG(bad_range(zone, &page[size]), "%pZp", &page[size]);
 
 		if (IS_ENABLED(CONFIG_DEBUG_PAGEALLOC) &&
 			debug_guardpage_enabled() &&
@@ -1418,7 +1418,7 @@ int move_freepages(struct zone *zone,
 
 	for (page = start_page; page <= end_page;) {
 		/* Make sure we are not inadvertently changing nodes */
-		VM_BUG_ON_PAGE(page_to_nid(page) != zone_to_nid(zone), page);
+		VM_BUG(page_to_nid(page) != zone_to_nid(zone), "%pZp", page);
 
 		if (!pfn_valid_within(page_to_pfn(page))) {
 			page++;
@@ -1943,8 +1943,8 @@ void split_page(struct page *page, unsigned int order)
 {
 	int i;
 
-	VM_BUG_ON_PAGE(PageCompound(page), page);
-	VM_BUG_ON_PAGE(!page_count(page), page);
+	VM_BUG(PageCompound(page), "%pZp", page);
+	VM_BUG(!page_count(page), "%pZp", page);
 
 #ifdef CONFIG_KMEMCHECK
 	/*
@@ -2096,7 +2096,7 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
 	zone_statistics(preferred_zone, zone, gfp_flags);
 	local_irq_restore(flags);
 
-	VM_BUG_ON_PAGE(bad_range(zone, page), page);
+	VM_BUG(bad_range(zone, page), "%pZp", page);
 	return page;
 
 failed:
@@ -6514,7 +6514,7 @@ void set_pfnblock_flags_mask(struct page *page, unsigned long flags,
 	word_bitidx = bitidx / BITS_PER_LONG;
 	bitidx &= (BITS_PER_LONG-1);
 
-	VM_BUG_ON_PAGE(!zone_spans_pfn(zone, pfn), page);
+	VM_BUG(!zone_spans_pfn(zone, pfn), "%pZp", page);
 
 	bitidx += end_bitidx;
 	mask <<= (BITS_PER_LONG - bitidx - 1);
diff --git a/mm/page_io.c b/mm/page_io.c
index 6424869..deea5be 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -331,8 +331,8 @@ int swap_readpage(struct page *page)
 	int ret = 0;
 	struct swap_info_struct *sis = page_swap_info(page);
 
-	VM_BUG_ON_PAGE(!PageLocked(page), page);
-	VM_BUG_ON_PAGE(PageUptodate(page), page);
+	VM_BUG(!PageLocked(page), "%pZp", page);
+	VM_BUG(PageUptodate(page), "%pZp", page);
 	if (frontswap_load(page) == 0) {
 		SetPageUptodate(page);
 		unlock_page(page);
diff --git a/mm/rmap.c b/mm/rmap.c
index dad23a4..f8a6bca 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -971,9 +971,9 @@ void page_move_anon_rmap(struct page *page,
 {
 	struct anon_vma *anon_vma = vma->anon_vma;
 
-	VM_BUG_ON_PAGE(!PageLocked(page), page);
+	VM_BUG(!PageLocked(page), "%pZp", page);
 	VM_BUG_ON_VMA(!anon_vma, vma);
-	VM_BUG_ON_PAGE(page->index != linear_page_index(vma, address), page);
+	VM_BUG(page->index != linear_page_index(vma, address), "%pZp", page);
 
 	anon_vma = (void *) anon_vma + PAGE_MAPPING_ANON;
 	page->mapping = (struct address_space *) anon_vma;
@@ -1078,7 +1078,7 @@ void do_page_add_anon_rmap(struct page *page,
 	if (unlikely(PageKsm(page)))
 		return;
 
-	VM_BUG_ON_PAGE(!PageLocked(page), page);
+	VM_BUG(!PageLocked(page), "%pZp", page);
 	/* address might be in next vma when migration races vma_adjust */
 	if (first)
 		__page_set_anon_rmap(page, vma, address, exclusive);
@@ -1274,7 +1274,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 		pte_t swp_pte;
 
 		if (flags & TTU_FREE) {
-			VM_BUG_ON_PAGE(PageSwapCache(page), page);
+			VM_BUG(PageSwapCache(page), "%pZp", page);
 			if (!dirty && !PageDirty(page)) {
 				/* It's a freeable page by MADV_FREE */
 				dec_mm_counter(mm, MM_ANONPAGES);
@@ -1407,7 +1407,7 @@ int try_to_unmap(struct page *page, enum ttu_flags flags)
 		.anon_lock = page_lock_anon_vma_read,
 	};
 
-	VM_BUG_ON_PAGE(!PageHuge(page) && PageTransHuge(page), page);
+	VM_BUG(!PageHuge(page) && PageTransHuge(page), "%pZp", page);
 
 	/*
 	 * During exec, a temporary VMA is setup and later moved.
@@ -1453,7 +1453,7 @@ int try_to_munlock(struct page *page)
 
 	};
 
-	VM_BUG_ON_PAGE(!PageLocked(page) || PageLRU(page), page);
+	VM_BUG(!PageLocked(page) || PageLRU(page), "%pZp", page);
 
 	ret = rmap_walk(page, &rwc);
 	return ret;
@@ -1559,7 +1559,7 @@ static int rmap_walk_file(struct page *page, struct rmap_walk_control *rwc)
 	 * structure at mapping cannot be freed and reused yet,
 	 * so we can safely take mapping->i_mmap_rwsem.
 	 */
-	VM_BUG_ON_PAGE(!PageLocked(page), page);
+	VM_BUG(!PageLocked(page), "%pZp", page);
 
 	if (!mapping)
 		return ret;
diff --git a/mm/shmem.c b/mm/shmem.c
index 3f974a1..888dfb0 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -295,8 +295,8 @@ static int shmem_add_to_page_cache(struct page *page,
 {
 	int error;
 
-	VM_BUG_ON_PAGE(!PageLocked(page), page);
-	VM_BUG_ON_PAGE(!PageSwapBacked(page), page);
+	VM_BUG(!PageLocked(page), "%pZp", page);
+	VM_BUG(!PageSwapBacked(page), "%pZp", page);
 
 	page_cache_get(page);
 	page->mapping = mapping;
@@ -436,7 +436,8 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 				continue;
 			if (!unfalloc || !PageUptodate(page)) {
 				if (page->mapping == mapping) {
-					VM_BUG_ON_PAGE(PageWriteback(page), page);
+					VM_BUG(PageWriteback(page), "%pZp",
+					       page);
 					truncate_inode_page(mapping, page);
 				}
 			}
@@ -513,7 +514,8 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 			lock_page(page);
 			if (!unfalloc || !PageUptodate(page)) {
 				if (page->mapping == mapping) {
-					VM_BUG_ON_PAGE(PageWriteback(page), page);
+					VM_BUG(PageWriteback(page), "%pZp",
+					       page);
 					truncate_inode_page(mapping, page);
 				} else {
 					/* Page was replaced by swap: retry */
diff --git a/mm/slub.c b/mm/slub.c
index f920dc5..f516e0c 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -338,13 +338,13 @@ static inline int oo_objects(struct kmem_cache_order_objects x)
  */
 static __always_inline void slab_lock(struct page *page)
 {
-	VM_BUG_ON_PAGE(PageTail(page), page);
+	VM_BUG(PageTail(page), "%pZp", page);
 	bit_spin_lock(PG_locked, &page->flags);
 }
 
 static __always_inline void slab_unlock(struct page *page)
 {
-	VM_BUG_ON_PAGE(PageTail(page), page);
+	VM_BUG(PageTail(page), "%pZp", page);
 	__bit_spin_unlock(PG_locked, &page->flags);
 }
 
diff --git a/mm/swap.c b/mm/swap.c
index 8773de0..47af078 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -59,7 +59,7 @@ static void __page_cache_release(struct page *page)
 
 		spin_lock_irqsave(&zone->lru_lock, flags);
 		lruvec = mem_cgroup_page_lruvec(page, zone);
-		VM_BUG_ON_PAGE(!PageLRU(page), page);
+		VM_BUG(!PageLRU(page), "%pZp", page);
 		__ClearPageLRU(page);
 		del_page_from_lru_list(page, lruvec, page_off_lru(page));
 		spin_unlock_irqrestore(&zone->lru_lock, flags);
@@ -131,8 +131,8 @@ void put_unrefcounted_compound_page(struct page *page_head, struct page *page)
 		 * __split_huge_page_refcount cannot race
 		 * here, see the comment above this function.
 		 */
-		VM_BUG_ON_PAGE(!PageHead(page_head), page_head);
-		VM_BUG_ON_PAGE(page_mapcount(page) != 0, page);
+		VM_BUG(!PageHead(page_head), "%pZp", page_head);
+		VM_BUG(page_mapcount(page) != 0, "%pZp", page);
 		if (put_page_testzero(page_head)) {
 			/*
 			 * If this is the tail of a slab THP page,
@@ -148,7 +148,7 @@ void put_unrefcounted_compound_page(struct page *page_head, struct page *page)
 			 * not go away until the compound page enters
 			 * the buddy allocator.
 			 */
-			VM_BUG_ON_PAGE(PageSlab(page_head), page_head);
+			VM_BUG(PageSlab(page_head), "%pZp", page_head);
 			__put_compound_page(page_head);
 		}
 	} else
@@ -202,7 +202,7 @@ out_put_single:
 				__put_single_page(page);
 			return;
 		}
-		VM_BUG_ON_PAGE(page_head != page->first_page, page);
+		VM_BUG(page_head != page->first_page, "%pZp", page);
 		/*
 		 * We can release the refcount taken by
 		 * get_page_unless_zero() now that
@@ -210,12 +210,13 @@ out_put_single:
 		 * compound_lock.
 		 */
 		if (put_page_testzero(page_head))
-			VM_BUG_ON_PAGE(1, page_head);
+			VM_BUG(1, "%pZp", page_head);
 		/* __split_huge_page_refcount will wait now */
-		VM_BUG_ON_PAGE(page_mapcount(page) <= 0, page);
+		VM_BUG(page_mapcount(page) <= 0, "%pZp", page);
 		atomic_dec(&page->_mapcount);
-		VM_BUG_ON_PAGE(atomic_read(&page_head->_count) <= 0, page_head);
-		VM_BUG_ON_PAGE(atomic_read(&page->_count) != 0, page);
+		VM_BUG(atomic_read(&page_head->_count) <= 0, "%pZp",
+		       page_head);
+		VM_BUG(atomic_read(&page->_count) != 0, "%pZp", page);
 		compound_unlock_irqrestore(page_head, flags);
 
 		if (put_page_testzero(page_head)) {
@@ -226,7 +227,7 @@ out_put_single:
 		}
 	} else {
 		/* @page_head is a dangling pointer */
-		VM_BUG_ON_PAGE(PageTail(page), page);
+		VM_BUG(PageTail(page), "%pZp", page);
 		goto out_put_single;
 	}
 }
@@ -306,7 +307,7 @@ bool __get_page_tail(struct page *page)
 			 * page. __split_huge_page_refcount
 			 * cannot race here.
 			 */
-			VM_BUG_ON_PAGE(!PageHead(page_head), page_head);
+			VM_BUG(!PageHead(page_head), "%pZp", page_head);
 			__get_page_tail_foll(page, true);
 			return true;
 		} else {
@@ -668,8 +669,8 @@ EXPORT_SYMBOL(lru_cache_add_file);
  */
 void lru_cache_add(struct page *page)
 {
-	VM_BUG_ON_PAGE(PageActive(page) && PageUnevictable(page), page);
-	VM_BUG_ON_PAGE(PageLRU(page), page);
+	VM_BUG(PageActive(page) && PageUnevictable(page), "%pZp", page);
+	VM_BUG(PageLRU(page), "%pZp", page);
 	__lru_cache_add(page);
 }
 
@@ -710,7 +711,7 @@ void add_page_to_unevictable_list(struct page *page)
 void lru_cache_add_active_or_unevictable(struct page *page,
 					 struct vm_area_struct *vma)
 {
-	VM_BUG_ON_PAGE(PageLRU(page), page);
+	VM_BUG(PageLRU(page), "%pZp", page);
 
 	if (likely((vma->vm_flags & (VM_LOCKED | VM_SPECIAL)) != VM_LOCKED)) {
 		SetPageActive(page);
@@ -995,7 +996,7 @@ void release_pages(struct page **pages, int nr, bool cold)
 			}
 
 			lruvec = mem_cgroup_page_lruvec(page, zone);
-			VM_BUG_ON_PAGE(!PageLRU(page), page);
+			VM_BUG(!PageLRU(page), "%pZp", page);
 			__ClearPageLRU(page);
 			del_page_from_lru_list(page, lruvec, page_off_lru(page));
 		}
@@ -1038,9 +1039,9 @@ void lru_add_page_tail(struct page *page, struct page *page_tail,
 {
 	const int file = 0;
 
-	VM_BUG_ON_PAGE(!PageHead(page), page);
-	VM_BUG_ON_PAGE(PageCompound(page_tail), page);
-	VM_BUG_ON_PAGE(PageLRU(page_tail), page);
+	VM_BUG(!PageHead(page), "%pZp", page);
+	VM_BUG(PageCompound(page_tail), "%pZp", page);
+	VM_BUG(PageLRU(page_tail), "%pZp", page);
 	VM_BUG_ON(NR_CPUS != 1 &&
 		  !spin_is_locked(&lruvec_zone(lruvec)->lru_lock));
 
@@ -1079,7 +1080,7 @@ static void __pagevec_lru_add_fn(struct page *page, struct lruvec *lruvec,
 	int active = PageActive(page);
 	enum lru_list lru = page_lru(page);
 
-	VM_BUG_ON_PAGE(PageLRU(page), page);
+	VM_BUG(PageLRU(page), "%pZp", page);
 
 	SetPageLRU(page);
 	add_page_to_lru_list(page, lruvec, lru);
diff --git a/mm/swap_state.c b/mm/swap_state.c
index a2611ce..0609662 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -81,9 +81,9 @@ int __add_to_swap_cache(struct page *page, swp_entry_t entry)
 	int error;
 	struct address_space *address_space;
 
-	VM_BUG_ON_PAGE(!PageLocked(page), page);
-	VM_BUG_ON_PAGE(PageSwapCache(page), page);
-	VM_BUG_ON_PAGE(!PageSwapBacked(page), page);
+	VM_BUG(!PageLocked(page), "%pZp", page);
+	VM_BUG(PageSwapCache(page), "%pZp", page);
+	VM_BUG(!PageSwapBacked(page), "%pZp", page);
 
 	page_cache_get(page);
 	SetPageSwapCache(page);
@@ -137,9 +137,9 @@ void __delete_from_swap_cache(struct page *page)
 	swp_entry_t entry;
 	struct address_space *address_space;
 
-	VM_BUG_ON_PAGE(!PageLocked(page), page);
-	VM_BUG_ON_PAGE(!PageSwapCache(page), page);
-	VM_BUG_ON_PAGE(PageWriteback(page), page);
+	VM_BUG(!PageLocked(page), "%pZp", page);
+	VM_BUG(!PageSwapCache(page), "%pZp", page);
+	VM_BUG(PageWriteback(page), "%pZp", page);
 
 	entry.val = page_private(page);
 	address_space = swap_address_space(entry);
@@ -163,8 +163,8 @@ int add_to_swap(struct page *page, struct list_head *list)
 	swp_entry_t entry;
 	int err;
 
-	VM_BUG_ON_PAGE(!PageLocked(page), page);
-	VM_BUG_ON_PAGE(!PageUptodate(page), page);
+	VM_BUG(!PageLocked(page), "%pZp", page);
+	VM_BUG(!PageUptodate(page), "%pZp", page);
 
 	entry = get_swap_page();
 	if (!entry.val)
diff --git a/mm/swapfile.c b/mm/swapfile.c
index a7e7210..d71dcd6 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -884,7 +884,7 @@ int reuse_swap_page(struct page *page)
 {
 	int count;
 
-	VM_BUG_ON_PAGE(!PageLocked(page), page);
+	VM_BUG(!PageLocked(page), "%pZp", page);
 	if (unlikely(PageKsm(page)))
 		return 0;
 	count = page_mapcount(page);
@@ -904,7 +904,7 @@ int reuse_swap_page(struct page *page)
  */
 int try_to_free_swap(struct page *page)
 {
-	VM_BUG_ON_PAGE(!PageLocked(page), page);
+	VM_BUG(!PageLocked(page), "%pZp", page);
 
 	if (!PageSwapCache(page))
 		return 0;
@@ -2710,7 +2710,7 @@ struct swap_info_struct *page_swap_info(struct page *page)
  */
 struct address_space *__page_file_mapping(struct page *page)
 {
-	VM_BUG_ON_PAGE(!PageSwapCache(page), page);
+	VM_BUG(!PageSwapCache(page), "%pZp", page);
 	return page_swap_info(page)->swap_file->f_mapping;
 }
 EXPORT_SYMBOL_GPL(__page_file_mapping);
@@ -2718,7 +2718,7 @@ EXPORT_SYMBOL_GPL(__page_file_mapping);
 pgoff_t __page_file_index(struct page *page)
 {
 	swp_entry_t swap = { .val = page_private(page) };
-	VM_BUG_ON_PAGE(!PageSwapCache(page), page);
+	VM_BUG(!PageSwapCache(page), "%pZp", page);
 	return swp_offset(swap);
 }
 EXPORT_SYMBOL_GPL(__page_file_index);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 7d20d36..d63586f 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -688,7 +688,7 @@ void putback_lru_page(struct page *page)
 	bool is_unevictable;
 	int was_unevictable = PageUnevictable(page);
 
-	VM_BUG_ON_PAGE(PageLRU(page), page);
+	VM_BUG(PageLRU(page), "%pZp", page);
 
 redo:
 	ClearPageUnevictable(page);
@@ -761,7 +761,7 @@ static enum page_references page_check_references(struct page *page,
 	unsigned long vm_flags;
 	int pte_dirty;
 
-	VM_BUG_ON_PAGE(!PageLocked(page), page);
+	VM_BUG(!PageLocked(page), "%pZp", page);
 
 	referenced_ptes = page_referenced(page, 1, sc->target_mem_cgroup,
 					  &vm_flags, &pte_dirty);
@@ -887,8 +887,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		if (!trylock_page(page))
 			goto keep;
 
-		VM_BUG_ON_PAGE(PageActive(page), page);
-		VM_BUG_ON_PAGE(page_zone(page) != zone, page);
+		VM_BUG(PageActive(page), "%pZp", page);
+		VM_BUG(page_zone(page) != zone, "%pZp", page);
 
 		sc->nr_scanned++;
 
@@ -1059,7 +1059,7 @@ unmap:
 				 * due to skipping of swapcache so we free
 				 * page in here rather than __remove_mapping.
 				 */
-				VM_BUG_ON_PAGE(PageSwapCache(page), page);
+				VM_BUG(PageSwapCache(page), "%pZp", page);
 				if (!page_freeze_refs(page, 1))
 					goto keep_locked;
 				__ClearPageLocked(page);
@@ -1196,14 +1196,14 @@ activate_locked:
 		/* Not a candidate for swapping, so reclaim swap space. */
 		if (PageSwapCache(page) && vm_swap_full())
 			try_to_free_swap(page);
-		VM_BUG_ON_PAGE(PageActive(page), page);
+		VM_BUG(PageActive(page), "%pZp", page);
 		SetPageActive(page);
 		pgactivate++;
 keep_locked:
 		unlock_page(page);
 keep:
 		list_add(&page->lru, &ret_pages);
-		VM_BUG_ON_PAGE(PageLRU(page) || PageUnevictable(page), page);
+		VM_BUG(PageLRU(page) || PageUnevictable(page), "%pZp", page);
 	}
 
 	mem_cgroup_uncharge_list(&free_pages);
@@ -1358,7 +1358,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 		page = lru_to_page(src);
 		prefetchw_prev_lru_page(page, src, flags);
 
-		VM_BUG_ON_PAGE(!PageLRU(page), page);
+		VM_BUG(!PageLRU(page), "%pZp", page);
 
 		switch (__isolate_lru_page(page, mode)) {
 		case 0:
@@ -1413,7 +1413,7 @@ int isolate_lru_page(struct page *page)
 {
 	int ret = -EBUSY;
 
-	VM_BUG_ON_PAGE(!page_count(page), page);
+	VM_BUG(!page_count(page), "%pZp", page);
 
 	if (PageLRU(page)) {
 		struct zone *zone = page_zone(page);
@@ -1501,7 +1501,7 @@ putback_inactive_pages(struct lruvec *lruvec, struct list_head *page_list)
 		struct page *page = lru_to_page(page_list);
 		int lru;
 
-		VM_BUG_ON_PAGE(PageLRU(page), page);
+		VM_BUG(PageLRU(page), "%pZp", page);
 		list_del(&page->lru);
 		if (unlikely(!page_evictable(page))) {
 			spin_unlock_irq(&zone->lru_lock);
@@ -1736,7 +1736,7 @@ static void move_active_pages_to_lru(struct lruvec *lruvec,
 		page = lru_to_page(list);
 		lruvec = mem_cgroup_page_lruvec(page, zone);
 
-		VM_BUG_ON_PAGE(PageLRU(page), page);
+		VM_BUG(PageLRU(page), "%pZp", page);
 		SetPageLRU(page);
 
 		nr_pages = hpage_nr_pages(page);
@@ -3863,7 +3863,7 @@ void check_move_unevictable_pages(struct page **pages, int nr_pages)
 		if (page_evictable(page)) {
 			enum lru_list lru = page_lru_base_type(page);
 
-			VM_BUG_ON_PAGE(PageActive(page), page);
+			VM_BUG(PageActive(page), "%pZp", page);
 			ClearPageUnevictable(page);
 			del_page_from_lru_list(page, lruvec, LRU_UNEVICTABLE);
 			add_page_to_lru_list(page, lruvec, lru);
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
