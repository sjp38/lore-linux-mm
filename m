Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f45.google.com (mail-vk0-f45.google.com [209.85.213.45])
	by kanga.kvack.org (Postfix) with ESMTP id 6D4506B0255
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 08:01:00 -0500 (EST)
Received: by vkfr145 with SMTP id r145so15908122vkf.1
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 05:01:00 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a128si3877849vke.28.2015.11.19.05.00.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Nov 2015 05:00:57 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 1/2] mm: thp: introduce thp_mmu_gather to pin tail pages during MMU gather
Date: Thu, 19 Nov 2015 14:00:51 +0100
Message-Id: <1447938052-22165-2-git-send-email-aarcange@redhat.com>
In-Reply-To: <1447938052-22165-1-git-send-email-aarcange@redhat.com>
References: <1447938052-22165-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: "\\\"Kirill A. Shutemov\\\"" <kirill@shutemov.name>, Mel Gorman <mgorman@techsingularity.net>, Hugh Dickins <hughd@google.com>, Johannes Weiner <jweiner@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>

This theoretical SMP race condition was found with source review. No
real life app could be affected as the result of freeing memory while
accessing it is either undefined or it's a workload the produces no
information.

For something to go wrong because the SMP race condition triggered,
it'd require a further tiny window within the SMP race condition
window. So nothing bad is happening in practice even if the SMP race
condition triggers. It's still better to apply the fix to have the
math guarantee.

The fix just adds a thp_mmu_gather atomic_t counter to the THP pages,
so split_huge_page can elevate the tail page count accordingly and
leave the tail page freeing task to whoever elevated thp_mmu_gather.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 Documentation/vm/transhuge.txt |  60 +++++++++++++++++++
 include/linux/huge_mm.h        |  72 +++++++++++++++++++++++
 include/linux/mm_types.h       |   1 +
 mm/huge_memory.c               |  33 ++++++++++-
 mm/page_alloc.c                |  14 +++++
 mm/swap.c                      | 130 ++++++++++++++++++++++++++++++++++-------
 mm/swap_state.c                |  17 ++++--
 7 files changed, 300 insertions(+), 27 deletions(-)

diff --git a/Documentation/vm/transhuge.txt b/Documentation/vm/transhuge.txt
index 8a28268..8851d28 100644
--- a/Documentation/vm/transhuge.txt
+++ b/Documentation/vm/transhuge.txt
@@ -395,3 +395,63 @@ tail page refcount. To obtain a head page reliably and to decrease its
 refcount without race conditions, put_page has to serialize against
 __split_huge_page_refcount using a special per-page lock called
 compound_lock.
+
+== THP MMU gather vs split_huge_page ==
+
+After page_remove_rmap() runs (inside a PT/pmd lock protected critical
+section) the page_mapcount() of the transparent hugepage is
+decreased. After the PT/pmd lock is released, the page_count()
+refcount left on the PageTransHuge(page) pins the entire THP page if
+__split_huge_page_refcount() didn't run yet, but it only pins the head
+page if it already run.
+
+If watching the problem purely in terms of refcounts this is correct:
+if put_page() runs on a PageTransHuge() after the PT/pmd lock has been
+dropped, it still won't need to serialize against
+__split_huge_page_refcount() and it will get the refcounting right no
+matter if __split_huge_page_refcount() is running under it or not,
+this is because the head page "page_count" refcount stays local to the
+head page even during __split_huge_page_refcount(). Only tail pages,
+have to go through the trouble of using the compound_lock to serialize
+inside put_page().
+
+However special care is needed if the TLB isn't flushed before
+dropping the PT/pmd lock, because after page_remove_rmap() and
+immediately after the PT/pmd lock is released,
+__split_huge_page_refcount could run and free all the tail pages.
+
+To keep the tail pages temporarily pinned if we didn't flush the TLB
+in the aforementioned case, we use a page[1].thp_mmu_gather atomic
+counter that is increased before releasing the PT/pmd lock (PT/pmd
+lock serializes against __split_huge_page_refcount()) and decreased by
+the actual page freeing while holding the lru_lock (which also
+serializes against __split_huge_page_refcount()). This thp_mmu_gather
+counter has the effect of pinning all tail pages, until after the TLB
+has been flushed. Then just before freeing the page the thp_mmu_gather
+counter is decreased if we detected that __split_huge_page_refcount()
+didn't run yet.
+
+__split_huge_page_refcount() will threat the thp_mmu_gather more or
+less like the mapcount: the thp_mmu_gather taken on the PageTransHuge
+is transferred as an addition to the "page_count" to all the tail
+pages (but not to the mapcount because the tails aren't mapped
+anymore).
+
+If the actual page freeing during MMU gather processing (so always
+happening after the TLB flush) finds that __split_huge_page_refcount()
+already run on the PageTransHuge, before it could atomic decrease the
+thp_mmu_gather for the current MMU gather, it will simply put_page all
+the HPAGE_PMD_NR pages (the head and all the tails). If the
+thp_mmu_gather wouldn't have been increased, the tails wouldn't have
+needed to be freed.
+
+The page[1].thp_mmu_gather field must be initialized whenever a THP is
+first established before dropping the PT/pmd lock, so generally in the
+same critical section with page_add_new_anon_rmap() and on the same
+page passed as argument to page_add_new_anon_rmap(). It can only be
+initialized on PageTransHuge() pages as it is aliased to the
+page[1].index.
+
+The page[1].thp_mmu_gather has to be increased before dropping the
+PT/pmd lock if the critical section run page_remove_rmap() and the TLB
+hasn't been flushed before dropping the PT/pmd lock.
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index ecb080d..0d8ef7d 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -164,6 +164,61 @@ static inline bool is_huge_zero_pmd(pmd_t pmd)
 
 struct page *get_huge_zero_page(void);
 
+static inline bool is_trans_huge_page_release(struct page *page)
+{
+	return (unsigned long) page & 1;
+}
+
+static inline struct page *trans_huge_page_release_decode(struct page *page)
+{
+	return (struct page *) ((unsigned long)page & ~1UL);
+}
+
+static inline struct page *trans_huge_page_release_encode(struct page *page)
+{
+	return (struct page *) ((unsigned long)page | 1UL);
+}
+
+static inline atomic_t *__trans_huge_mmu_gather_count(struct page *page)
+{
+	return &(page + 1)->thp_mmu_gather;
+}
+
+static inline void init_trans_huge_mmu_gather_count(struct page *page)
+{
+	atomic_t *thp_mmu_gather = __trans_huge_mmu_gather_count(page);
+	atomic_set(thp_mmu_gather, 0);
+}
+
+static inline void inc_trans_huge_mmu_gather_count(struct page *page)
+{
+	atomic_t *thp_mmu_gather = __trans_huge_mmu_gather_count(page);
+	VM_BUG_ON(atomic_read(thp_mmu_gather) < 0);
+	atomic_inc(thp_mmu_gather);
+}
+
+static inline void dec_trans_huge_mmu_gather_count(struct page *page)
+{
+	atomic_t *thp_mmu_gather = __trans_huge_mmu_gather_count(page);
+	VM_BUG_ON(atomic_read(thp_mmu_gather) <= 0);
+	atomic_dec(thp_mmu_gather);
+}
+
+static inline int trans_huge_mmu_gather_count(struct page *page)
+{
+	atomic_t *thp_mmu_gather = __trans_huge_mmu_gather_count(page);
+	int ret = atomic_read(thp_mmu_gather);
+	VM_BUG_ON(ret < 0);
+	return ret;
+}
+
+/*
+ * free_trans_huge_page_list() is used to free the pages returned by
+ * trans_huge_page_release() (if still PageTransHuge()) in
+ * release_pages().
+ */
+extern void free_trans_huge_page_list(struct list_head *list);
+
 #else /* CONFIG_TRANSPARENT_HUGEPAGE */
 #define HPAGE_PMD_SHIFT ({ BUILD_BUG(); 0; })
 #define HPAGE_PMD_MASK ({ BUILD_BUG(); 0; })
@@ -218,6 +273,23 @@ static inline bool is_huge_zero_page(struct page *page)
 	return false;
 }
 
+static inline bool is_trans_huge_page_release(struct page *page)
+{
+	return false;
+}
+
+static inline struct page *trans_huge_page_release_encode(struct page *page)
+{
+	return page;
+}
+
+static inline struct page *trans_huge_page_release_decode(struct page *page)
+{
+	return page;
+}
+
+extern void dec_trans_huge_mmu_gather_count(struct page *page);
+
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
 #endif /* _LINUX_HUGE_MM_H */
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index f8d1492..baedb35 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -61,6 +61,7 @@ struct page {
 		union {
 			pgoff_t index;		/* Our offset within mapping. */
 			void *freelist;		/* sl[aou]b first free object */
+			atomic_t thp_mmu_gather; /* in first tailpage of THP */
 		};
 
 		union {
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 4ca884e..e85027c 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -768,6 +768,7 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 			return ret;
 		}
 
+		init_trans_huge_mmu_gather_count(page);
 		entry = mk_huge_pmd(page, vma->vm_page_prot);
 		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
 		page_add_new_anon_rmap(page, vma, haddr);
@@ -1241,6 +1242,7 @@ alloc:
 		goto out_mn;
 	} else {
 		pmd_t entry;
+		init_trans_huge_mmu_gather_count(new_page);
 		entry = mk_huge_pmd(new_page, vma->vm_page_prot);
 		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
 		pmdp_huge_clear_flush_notify(vma, haddr, pmd);
@@ -1488,8 +1490,20 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		VM_BUG_ON_PAGE(!PageHead(page), page);
 		pte_free(tlb->mm, pgtable_trans_huge_withdraw(tlb->mm, pmd));
 		atomic_long_dec(&tlb->mm->nr_ptes);
+		/*
+		 * page_remove_rmap() already decreased the
+		 * page_mapcount(), so tail pages can be instantly
+		 * freed after we release the pmd lock. Increase the
+		 * mmu_gather_count to prevent the tail pages to be
+		 * freed, even if the THP page get splitted.
+		 * __split_huge_page_refcount() will then see that
+		 * we're in the middle of a mmu gather and it'll add
+		 * the compound mmu_gather_count to every tail
+		 * page page_count().
+		 */
+		inc_trans_huge_mmu_gather_count(page);
 		spin_unlock(ptl);
-		tlb_remove_page(tlb, page);
+		tlb_remove_page(tlb, trans_huge_page_release_encode(page));
 	}
 	return 1;
 }
@@ -1709,11 +1723,22 @@ static void __split_huge_page_refcount(struct page *page,
 	struct zone *zone = page_zone(page);
 	struct lruvec *lruvec;
 	int tail_count = 0;
+	int mmu_gather_count;
 
 	/* prevent PageLRU to go away from under us, and freeze lru stats */
 	spin_lock_irq(&zone->lru_lock);
 	lruvec = mem_cgroup_page_lruvec(page, zone);
 
+	/*
+	 * No mmu_gather_count increase can happen anymore because
+	 * here all pmds are already pmd_trans_splitting(). No
+	 * decrease can happen either because it's only decreased
+	 * while holding the lru_lock. So here the mmu_gather_count is
+	 * already stable so store it on the stack. Then it'll be
+	 * overwritten when the page_tail->index is initialized.
+	 */
+	mmu_gather_count = trans_huge_mmu_gather_count(page);
+
 	compound_lock(page);
 	/* complete memcg works before add pages to LRU */
 	mem_cgroup_split_huge_fixup(page);
@@ -1740,8 +1765,8 @@ static void __split_huge_page_refcount(struct page *page,
 		 * atomic_set() here would be safe on all archs (and
 		 * not only on x86), it's safer to use atomic_add().
 		 */
-		atomic_add(page_mapcount(page) + page_mapcount(page_tail) + 1,
-			   &page_tail->_count);
+		atomic_add(page_mapcount(page) + page_mapcount(page_tail) +
+			   mmu_gather_count + 1, &page_tail->_count);
 
 		/* after clearing PageTail the gup refcount can be released */
 		smp_mb__after_atomic();
@@ -2617,6 +2642,8 @@ static void collapse_huge_page(struct mm_struct *mm,
 	 */
 	smp_wmb();
 
+	init_trans_huge_mmu_gather_count(new_page);
+
 	spin_lock(pmd_ptl);
 	BUG_ON(!pmd_none(*pmd));
 	page_add_new_anon_rmap(new_page, vma, address);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4272d95..aeef65f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2087,6 +2087,20 @@ void free_hot_cold_page_list(struct list_head *list, bool cold)
 	}
 }
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+void free_trans_huge_page_list(struct list_head *list)
+{
+	struct page *page, *next;
+
+	/*
+	 * THP pages always use the default destructor so call it
+	 * directly and skip the pointer to function.
+	 */
+	list_for_each_entry_safe(page, next, list, lru)
+		__free_pages_ok(page, HPAGE_PMD_ORDER);
+}
+#endif
+
 /*
  * split_page takes a non-compound higher-order page, and splits it into
  * n (1<<order) sub-pages: page[0..n]
diff --git a/mm/swap.c b/mm/swap.c
index 39395fb..16d01a1 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -897,6 +897,38 @@ void lru_add_drain_all(void)
 	mutex_unlock(&lock);
 }
 
+static inline struct zone *zone_lru_lock(struct zone *zone,
+					 struct page *page,
+					 unsigned int *lock_batch,
+					 unsigned long *_flags)
+{
+	struct zone *pagezone = page_zone(page);
+
+	if (pagezone != zone) {
+		unsigned long flags = *_flags;
+
+		if (zone)
+			spin_unlock_irqrestore(&zone->lru_lock, flags);
+		*lock_batch = 0;
+		zone = pagezone;
+		spin_lock_irqsave(&zone->lru_lock, flags);
+
+		*_flags = flags;
+	}
+
+	return zone;
+}
+
+static inline struct zone *zone_lru_unlock(struct zone *zone,
+					   unsigned long flags)
+{
+	if (zone) {
+		spin_unlock_irqrestore(&zone->lru_lock, flags);
+		zone = NULL;
+	}
+	return zone;
+}
+
 /**
  * release_pages - batched page_cache_release()
  * @pages: array of pages to release
@@ -910,6 +942,7 @@ void release_pages(struct page **pages, int nr, bool cold)
 {
 	int i;
 	LIST_HEAD(pages_to_free);
+	LIST_HEAD(trans_huge_pages_to_free);
 	struct zone *zone = NULL;
 	struct lruvec *lruvec;
 	unsigned long uninitialized_var(flags);
@@ -917,12 +950,10 @@ void release_pages(struct page **pages, int nr, bool cold)
 
 	for (i = 0; i < nr; i++) {
 		struct page *page = pages[i];
+		const bool was_thp = is_trans_huge_page_release(page);
 
-		if (unlikely(PageCompound(page))) {
-			if (zone) {
-				spin_unlock_irqrestore(&zone->lru_lock, flags);
-				zone = NULL;
-			}
+		if (unlikely(!was_thp && PageCompound(page))) {
+			zone = zone_lru_unlock(zone, flags);
 			put_compound_page(page);
 			continue;
 		}
@@ -937,20 +968,65 @@ void release_pages(struct page **pages, int nr, bool cold)
 			zone = NULL;
 		}
 
+		if (was_thp) {
+			page = trans_huge_page_release_decode(page);
+			zone = zone_lru_lock(zone, page, &lock_batch, &flags);
+			/*
+			 * Here, after taking the lru_lock,
+			 * __split_huge_page_refcount() can't run
+			 * anymore from under us and in turn
+			 * PageTransHuge() retval is stable and can't
+			 * change anymore.
+			 *
+			 * PageTransHuge() has an helpful
+			 * VM_BUG_ON_PAGE() internally to enforce that
+			 * the page cannot be a tail here.
+			 */
+			if (unlikely(!PageTransHuge(page))) {
+				int idx;
+
+				/*
+				 * The THP page was splitted before we
+				 * could free it, in turn its tails
+				 * kept an elevated count because the
+				 * mmu_gather_count was transferred to
+				 * the tail page count during the
+				 * split.
+				 *
+				 * This is a very unlikely slow path,
+				 * performance is irrelevant here,
+				 * just keep it to the simplest.
+				 */
+				zone = zone_lru_unlock(zone, flags);
+
+				for (idx = 0; idx < HPAGE_PMD_NR;
+				     idx++, page++) {
+					VM_BUG_ON(PageTransCompound(page));
+					put_page(page);
+				}
+				continue;
+			} else
+				/*
+				 * __split_huge_page_refcount() cannot
+				 * run from under us, so we can
+				 * release the refence we had on the
+				 * mmu_gather_count as we don't care
+				 * anymore if the page gets splitted
+				 * or not. By now the TLB flush
+				 * already happened for this mapping,
+				 * so we don't need to prevent the
+				 * tails to be freed anymore.
+				 */
+				dec_trans_huge_mmu_gather_count(page);
+		}
+
 		if (!put_page_testzero(page))
 			continue;
 
 		if (PageLRU(page)) {
-			struct zone *pagezone = page_zone(page);
-
-			if (pagezone != zone) {
-				if (zone)
-					spin_unlock_irqrestore(&zone->lru_lock,
-									flags);
-				lock_batch = 0;
-				zone = pagezone;
-				spin_lock_irqsave(&zone->lru_lock, flags);
-			}
+			if (!was_thp)
+				zone = zone_lru_lock(zone, page, &lock_batch,
+						     &flags);
 
 			lruvec = mem_cgroup_page_lruvec(page, zone);
 			VM_BUG_ON_PAGE(!PageLRU(page), page);
@@ -958,16 +1034,30 @@ void release_pages(struct page **pages, int nr, bool cold)
 			del_page_from_lru_list(page, lruvec, page_off_lru(page));
 		}
 
-		/* Clear Active bit in case of parallel mark_page_accessed */
-		__ClearPageActive(page);
+		if (!was_thp) {
+			/*
+			 * Clear Active bit in case of parallel
+			 * mark_page_accessed.
+			 */
+			__ClearPageActive(page);
 
-		list_add(&page->lru, &pages_to_free);
+			list_add(&page->lru, &pages_to_free);
+		} else
+			list_add(&page->lru, &trans_huge_pages_to_free);
 	}
 	if (zone)
 		spin_unlock_irqrestore(&zone->lru_lock, flags);
 
-	mem_cgroup_uncharge_list(&pages_to_free);
-	free_hot_cold_page_list(&pages_to_free, cold);
+	if (!list_empty(&pages_to_free)) {
+		mem_cgroup_uncharge_list(&pages_to_free);
+		free_hot_cold_page_list(&pages_to_free, cold);
+	}
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	if (!list_empty(&trans_huge_pages_to_free)) {
+		mem_cgroup_uncharge_list(&trans_huge_pages_to_free);
+		free_trans_huge_page_list(&trans_huge_pages_to_free);
+	}
+#endif
 }
 EXPORT_SYMBOL(release_pages);
 
diff --git a/mm/swap_state.c b/mm/swap_state.c
index d504adb..386b69f 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -247,8 +247,13 @@ static inline void free_swap_cache(struct page *page)
  */
 void free_page_and_swap_cache(struct page *page)
 {
-	free_swap_cache(page);
-	page_cache_release(page);
+	if (!is_trans_huge_page_release(page)) {
+		free_swap_cache(page);
+		page_cache_release(page);
+	} else {
+		/* page might have to be decoded */
+		release_pages(&page, 1, false);
+	}
 }
 
 /*
@@ -261,8 +266,12 @@ void free_pages_and_swap_cache(struct page **pages, int nr)
 	int i;
 
 	lru_add_drain();
-	for (i = 0; i < nr; i++)
-		free_swap_cache(pagep[i]);
+	for (i = 0; i < nr; i++) {
+		struct page *page = pagep[i];
+		/* THP cannot be in swapcache and is also still encoded */
+		if (!is_trans_huge_page_release(page))
+			free_swap_cache(page);
+	}
 	release_pages(pagep, nr, false);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
