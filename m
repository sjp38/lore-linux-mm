Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 4CD39900016
	for <linux-mm@kvack.org>; Wed,  3 Jun 2015 02:15:56 -0400 (EDT)
Received: by pdbnf5 with SMTP id nf5so141034pdb.2
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 23:15:56 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id z1si30030696pda.165.2015.06.02.23.15.52
        for <linux-mm@kvack.org>;
        Tue, 02 Jun 2015 23:15:53 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC 6/6] mm: MADV_FREE refactoring
Date: Wed,  3 Jun 2015 15:15:45 +0900
Message-Id: <1433312145-19386-7-git-send-email-minchan@kernel.org>
In-Reply-To: <1433312145-19386-1-git-send-email-minchan@kernel.org>
References: <1433312145-19386-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>

This patch does some clean up.

Firstly, it removes unnecessary PageSwapCache and ClearPageDirty
in madvise_fre_pte_range. The reason I did in there is to prevent
wrong discarding by non-dirty marked page table entries of
anonymous pages.
However, eariler patches in this patchset removed dependency
between MADV_FREE and PG_dirty and took care of anonymous page's
dirty bit in page table so there is no reason to add such logics
in fast path now.

Secondly, this patch removes freeable check in page_referenced.
It was pointess because we could decide freeable in try_to_unmap_one
with just pte_dirty. If it is judged by freeable page(ie, page table
doesn't have dirty bit), just doesn't store swap location of the pte
(ie, nuke the page table entry ). Otherwise, we could store swap
location on pte so that the page should be swapped-out.

This patch introduces SWAP_DISCARD which represents the passed page
should be discarded instead of swapping.
It is set if page is no mapped at any page table and there is
no swap slot for the page. If so, shrink_page_list does ClearPageDirty
for skipping pageout and then VM reclaims it.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/rmap.h |  9 ++----
 mm/madvise.c         | 13 ---------
 mm/rmap.c            | 78 +++++++++++++++++++++++++---------------------------
 mm/vmscan.c          | 62 ++++++++++++++---------------------------
 4 files changed, 62 insertions(+), 100 deletions(-)

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index bf36b6e644c4..352c72074e69 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -184,8 +184,7 @@ static inline void page_dup_rmap(struct page *page)
  * Called from mm/vmscan.c to handle paging out
  */
 int page_referenced(struct page *, int is_locked,
-			struct mem_cgroup *memcg, unsigned long *vm_flags,
-			int *is_pte_dirty);
+			struct mem_cgroup *memcg, unsigned long *vm_flags);
 
 #define TTU_ACTION(x) ((x) & TTU_ACTION_MASK)
 
@@ -262,12 +261,9 @@ int rmap_walk(struct page *page, struct rmap_walk_control *rwc);
 
 static inline int page_referenced(struct page *page, int is_locked,
 				  struct mem_cgroup *memcg,
-				  unsigned long *vm_flags,
-				  int *is_pte_dirty)
+				  unsigned long *vm_flags)
 {
 	*vm_flags = 0;
-	if (is_pte_dirty)
-		*is_pte_dirty = 0;
 	return 0;
 }
 
@@ -288,5 +284,6 @@ static inline int page_mkclean(struct page *page)
 #define SWAP_AGAIN	1
 #define SWAP_FAIL	2
 #define SWAP_MLOCK	3
+#define SWAP_DISCARD	4
 
 #endif	/* _LINUX_RMAP_H */
diff --git a/mm/madvise.c b/mm/madvise.c
index d215ea949630..68446e8ea6f6 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -317,19 +317,6 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
 		if (!page)
 			continue;
 
-		if (PageSwapCache(page)) {
-			if (!trylock_page(page))
-				continue;
-
-			if (!try_to_free_swap(page)) {
-				unlock_page(page);
-				continue;
-			}
-
-			ClearPageDirty(page);
-			unlock_page(page);
-		}
-
 		/*
 		 * Some of architecture(ex, PPC) don't update TLB
 		 * with set_pte_at and tlb_remove_tlb_entry so for
diff --git a/mm/rmap.c b/mm/rmap.c
index a2e4f64c392e..aa4a5174bc69 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -712,7 +712,6 @@ int page_mapped_in_vma(struct page *page, struct vm_area_struct *vma)
 }
 
 struct page_referenced_arg {
-	int dirtied;
 	int mapcount;
 	int referenced;
 	unsigned long vm_flags;
@@ -727,7 +726,6 @@ static int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 	struct mm_struct *mm = vma->vm_mm;
 	spinlock_t *ptl;
 	int referenced = 0;
-	int dirty = 0;
 	struct page_referenced_arg *pra = arg;
 
 	if (unlikely(PageTransHuge(page))) {
@@ -752,14 +750,6 @@ static int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 		if (pmdp_clear_flush_young_notify(vma, address, pmd))
 			referenced++;
 
-		/*
-		 * Use pmd_freeable instead of raw pmd_dirty because in some
-		 * of architecture, pmd_dirty is not defined unless
-		 * CONFIG_TRANSPARENT_HUGEPAGE is enabled
-		 */
-		if (!pmd_freeable(*pmd))
-			dirty++;
-
 		spin_unlock(ptl);
 	} else {
 		pte_t *pte;
@@ -790,9 +780,6 @@ static int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 				referenced++;
 		}
 
-		if (pte_dirty(*pte))
-			dirty++;
-
 		pte_unmap_unlock(pte, ptl);
 	}
 
@@ -801,9 +788,6 @@ static int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 		pra->vm_flags |= vma->vm_flags;
 	}
 
-	if (dirty)
-		pra->dirtied++;
-
 	pra->mapcount--;
 	if (!pra->mapcount)
 		return SWAP_SUCCESS; /* To break the loop */
@@ -828,7 +812,6 @@ static bool invalid_page_referenced_vma(struct vm_area_struct *vma, void *arg)
  * @is_locked: caller holds lock on the page
  * @memcg: target memory cgroup
  * @vm_flags: collect encountered vma->vm_flags who actually referenced the page
- * @is_pte_dirty: ptes which have marked dirty bit - used for lazyfree page
  *
  * Quick test_and_clear_referenced for all mappings to a page,
  * returns the number of ptes which referenced the page.
@@ -836,8 +819,7 @@ static bool invalid_page_referenced_vma(struct vm_area_struct *vma, void *arg)
 int page_referenced(struct page *page,
 		    int is_locked,
 		    struct mem_cgroup *memcg,
-		    unsigned long *vm_flags,
-		    int *is_pte_dirty)
+		    unsigned long *vm_flags)
 {
 	int ret;
 	int we_locked = 0;
@@ -852,8 +834,6 @@ int page_referenced(struct page *page,
 	};
 
 	*vm_flags = 0;
-	if (is_pte_dirty)
-		*is_pte_dirty = 0;
 
 	if (!page_mapped(page))
 		return 0;
@@ -882,9 +862,6 @@ int page_referenced(struct page *page,
 	if (we_locked)
 		unlock_page(page);
 
-	if (is_pte_dirty)
-		*is_pte_dirty = pra.dirtied;
-
 	return pra.referenced;
 }
 
@@ -1206,8 +1183,13 @@ void page_remove_rmap(struct page *page)
 	 */
 }
 
+struct rmap_arg {
+	enum ttu_flags flags;
+	int discard;
+};
+
 /*
- * @arg: enum ttu_flags will be passed to this argument
+ * @arg: struct rmap_arg will be passed to this argument
  */
 static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 		     unsigned long address, void *arg)
@@ -1217,7 +1199,8 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	pte_t pteval;
 	spinlock_t *ptl;
 	int ret = SWAP_AGAIN;
-	enum ttu_flags flags = (enum ttu_flags)arg;
+	struct rmap_arg *rmap_arg = (struct rmap_arg *)arg;
+	enum ttu_flags flags = rmap_arg->flags;
 	int dirty = 0;
 
 	pte = page_check_address(page, mm, address, &ptl, 0);
@@ -1278,17 +1261,11 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 		swp_entry_t entry = { .val = page_private(page) };
 		pte_t swp_pte;
 
-		if (flags & TTU_FREE) {
-			VM_BUG_ON_PAGE(PageSwapCache(page), page);
-			if (!dirty) {
-				/* It's a freeable page by MADV_FREE */
-				dec_mm_counter(mm, MM_ANONPAGES);
-				goto discard;
-			} else {
-				set_pte_at(mm, address, pte, pteval);
-				ret = SWAP_FAIL;
-				goto out_unmap;
-			}
+		if (flags & TTU_FREE && !dirty) {
+			/* It's a freeable page by MADV_FREE */
+			dec_mm_counter(mm, MM_ANONPAGES);
+			rmap_arg->discard++;
+			goto discard;
 		}
 
 		if (PageSwapCache(page)) {
@@ -1405,15 +1382,23 @@ static int page_not_mapped(struct page *page)
 int try_to_unmap(struct page *page, enum ttu_flags flags)
 {
 	int ret;
+	int mapcount;
+	struct rmap_arg rmap_arg = {
+		.flags = flags,
+	};
+
 	struct rmap_walk_control rwc = {
 		.rmap_one = try_to_unmap_one,
-		.arg = (void *)flags,
+		.arg = (void *)&rmap_arg,
 		.done = page_not_mapped,
 		.anon_lock = page_lock_anon_vma_read,
 	};
 
 	VM_BUG_ON_PAGE(!PageHuge(page) && PageTransHuge(page), page);
 
+	if (flags & TTU_FREE)
+		mapcount = page_mapcount(page);
+
 	/*
 	 * During exec, a temporary VMA is setup and later moved.
 	 * The VMA is moved under the anon_vma lock but not the
@@ -1427,8 +1412,21 @@ int try_to_unmap(struct page *page, enum ttu_flags flags)
 
 	ret = rmap_walk(page, &rwc);
 
-	if (ret != SWAP_MLOCK && !page_mapped(page))
-		ret = SWAP_SUCCESS;
+	/*
+	 * The mapcount would be zero if some process frees @page in parallel.
+	 * In this case, we shouldn't count it as SWAP_DISCARD. Otherwise,
+	 * people can see increased pglazyfreed via vmstat even though there
+	 * is no process called MADV_FREE.
+	 */
+	if (ret != SWAP_MLOCK && !page_mapped(page)) {
+		if ((flags & TTU_FREE) && mapcount &&
+			mapcount == rmap_arg.discard &&
+				!page_swapcount(page))
+			ret = SWAP_DISCARD;
+		else
+			ret = SWAP_SUCCESS;
+	}
+
 	return ret;
 }
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index c5fbb7c64deb..4ab599810c8d 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -754,17 +754,15 @@ enum page_references {
 };
 
 static enum page_references page_check_references(struct page *page,
-						  struct scan_control *sc,
-						  bool *freeable)
+						  struct scan_control *sc)
 {
 	int referenced_ptes, referenced_page;
 	unsigned long vm_flags;
-	int pte_dirty;
 
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 
 	referenced_ptes = page_referenced(page, 1, sc->target_mem_cgroup,
-					  &vm_flags, &pte_dirty);
+					  &vm_flags);
 	referenced_page = TestClearPageReferenced(page);
 
 	/*
@@ -805,9 +803,6 @@ static enum page_references page_check_references(struct page *page,
 		return PAGEREF_KEEP;
 	}
 
-	if (PageAnon(page) && !pte_dirty && !PageSwapCache(page))
-		*freeable = true;
-
 	/* Reclaim if clean, defer dirty pages to writeback */
 	if (referenced_page && !PageSwapBacked(page))
 		return PAGEREF_RECLAIM_CLEAN;
@@ -876,7 +871,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		int may_enter_fs;
 		enum page_references references = PAGEREF_RECLAIM_CLEAN;
 		bool dirty, writeback;
-		bool freeable = false;
+		int unmap_ret = SWAP_AGAIN;
+		enum ttu_flags tmp_ttu_flags = ttu_flags;
 
 		cond_resched();
 
@@ -1000,8 +996,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		}
 
 		if (!force_reclaim)
-			references = page_check_references(page, sc,
-							&freeable);
+			references = page_check_references(page, sc);
 
 		switch (references) {
 		case PAGEREF_ACTIVATE:
@@ -1013,12 +1008,13 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			; /* try to reclaim the page below */
 		}
 
-		/*
-		 * Anonymous process memory has backing store?
-		 * Try to allocate it some swap space here.
-		 */
-		if (PageAnon(page) && !PageSwapCache(page)) {
-			if (!freeable) {
+		if (PageAnon(page)) {
+			tmp_ttu_flags |= TTU_FREE;
+			/*
+			 * Anonymous process memory has backing store?
+			 * Try to allocate it some swap space here.
+			 */
+			if (!PageSwapCache(page)) {
 				if (!(sc->gfp_mask & __GFP_IO))
 					goto keep_locked;
 				if (!add_to_swap(page, page_list))
@@ -1026,44 +1022,26 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				may_enter_fs = 1;
 				/* Adding to swap updated mapping */
 				mapping = page_mapping(page);
-			} else {
-				if (likely(!PageTransHuge(page)))
-					goto unmap;
-				/* try_to_unmap isn't aware of THP page */
-				if (unlikely(split_huge_page_to_list(page,
-								page_list)))
-					goto keep_locked;
 			}
 		}
-unmap:
+
 		/*
 		 * The page is mapped into the page tables of one or more
 		 * processes. Try to unmap it here.
 		 */
-		if (page_mapped(page) && (mapping || freeable)) {
-			switch (try_to_unmap(page,
-				freeable ? TTU_FREE : ttu_flags)) {
+		if (page_mapped(page) && mapping) {
+			switch (unmap_ret = try_to_unmap(page, tmp_ttu_flags)) {
 			case SWAP_FAIL:
 				goto activate_locked;
 			case SWAP_AGAIN:
 				goto keep_locked;
 			case SWAP_MLOCK:
 				goto cull_mlocked;
+			case SWAP_DISCARD:
+				ClearPageDirty(page);
 			case SWAP_SUCCESS:
+				break;
 				/* try to free the page below */
-				if (!freeable)
-					break;
-				/*
-				 * Freeable anon page doesn't have mapping
-				 * due to skipping of swapcache so we free
-				 * page in here rather than __remove_mapping.
-				 */
-				VM_BUG_ON_PAGE(PageSwapCache(page), page);
-				if (!page_freeze_refs(page, 1))
-					goto keep_locked;
-				__ClearPageLocked(page);
-				count_vm_event(PGLAZYFREED);
-				goto free_it;
 			}
 		}
 
@@ -1175,6 +1153,8 @@ unmap:
 		 */
 		__ClearPageLocked(page);
 free_it:
+		if (unmap_ret == SWAP_DISCARD)
+			count_vm_event(PGLAZYFREED);
 		nr_reclaimed++;
 
 		/*
@@ -1820,7 +1800,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
 		}
 
 		if (page_referenced(page, 0, sc->target_mem_cgroup,
-				    &vm_flags, NULL)) {
+				    &vm_flags)) {
 			nr_rotated += hpage_nr_pages(page);
 			/*
 			 * Identify referenced, file-backed active pages and
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
