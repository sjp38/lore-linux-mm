Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id ED25B6B025F
	for <linux-mm@kvack.org>; Tue,  3 May 2016 17:01:50 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 4so63271494pfw.0
        for <linux-mm@kvack.org>; Tue, 03 May 2016 14:01:50 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id p3si332495pfp.130.2016.05.03.14.01.49
        for <linux-mm@kvack.org>;
        Tue, 03 May 2016 14:01:49 -0700 (PDT)
Message-ID: <1462309280.21143.8.camel@linux.intel.com>
Subject: [PATCH 1/7] mm: Cleanup - Reorganize the shrink_page_list code into
 smaller functions
From: Tim Chen <tim.c.chen@linux.intel.com>
Date: Tue, 03 May 2016 14:01:20 -0700
In-Reply-To: <cover.1462306228.git.tim.c.chen@linux.intel.com>
References: <cover.1462306228.git.tim.c.chen@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>
Cc: "Kirill A.Shutemov" <kirill.shutemov@linux.intel.com>, Andi Kleen <andi@firstfloor.org>, Aaron Lu <aaron.lu@intel.com>, Huang Ying <ying.huang@intel.com>, linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

This patch prepares the code for being able to batch the anonymous pages
to be swapped out.A A It reorganizes shrink_page_list function with
2 new functions: handle_pgout and pg_finish.

The paging operation in shrink_page_list is consolidated into
handle_pgout function.

After we have scanned a page shrink_page_list and completed any paging,
the final disposition and clean up of the page is conslidated into
pg_finish.A A The designated disposition of the page from page scanning
in shrink_page_list is marked with one of the designation in pg_result.

This is a clean up patch and there is no change in functionality or
logic of the code.

Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
---
A mm/vmscan.c | 429 ++++++++++++++++++++++++++++++++++--------------------------
A 1 file changed, 246 insertions(+), 183 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index b934223e..5542005 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -873,6 +873,216 @@ static void page_check_dirty_writeback(struct page *page,
A 		mapping->a_ops->is_dirty_writeback(page, dirty, writeback);
A }
A 
+enum pg_result {
+	PG_SPECULATIVE_REF,
+	PG_FREE,
+	PG_MLOCKED,
+	PG_ACTIVATE_LOCKED,
+	PG_KEEP_LOCKED,
+	PG_KEEP,
+	PG_NEXT,
+	PG_UNKNOWN,
+};
+
+static enum pg_result handle_pgout(struct list_head *page_list,
+	struct zone *zone,
+	struct scan_control *sc,
+	enum ttu_flags ttu_flags,
+	enum page_references references,
+	bool may_enter_fs,
+	bool lazyfree,
+	intA A *swap_ret,
+	struct page *page)
+{
+	struct address_space *mapping;
+
+	mapping =A A page_mapping(page);
+
+	/*
+	A * The page is mapped into the page tables of one or more
+	A * processes. Try to unmap it here.
+	A */
+	if (page_mapped(page) && mapping) {
+		switch (*swap_ret = try_to_unmap(page, lazyfree ?
+			(ttu_flags | TTU_BATCH_FLUSH | TTU_LZFREE) :
+			(ttu_flags | TTU_BATCH_FLUSH))) {
+		case SWAP_FAIL:
+			return PG_ACTIVATE_LOCKED;
+		case SWAP_AGAIN:
+			return PG_KEEP_LOCKED;
+		case SWAP_MLOCK:
+			return PG_MLOCKED;
+		case SWAP_LZFREE:
+			goto lazyfree;
+		case SWAP_SUCCESS:
+			; /* try to free the page below */
+		}
+	}
+
+	if (PageDirty(page)) {
+		/*
+		A * Only kswapd can writeback filesystem pages to
+		A * avoid risk of stack overflow but only writeback
+		A * if many dirty pages have been encountered.
+		A */
+		if (page_is_file_cache(page) &&
+				(!current_is_kswapd() ||
+				A !test_bit(ZONE_DIRTY, &zone->flags))) {
+			/*
+			A * Immediately reclaim when written back.
+			A * Similar in principal to deactivate_page()
+			A * except we already have the page isolated
+			A * and know it's dirty
+			A */
+			inc_zone_page_state(page, NR_VMSCAN_IMMEDIATE);
+			SetPageReclaim(page);
+
+			return PG_KEEP_LOCKED;
+		}
+
+		if (references == PAGEREF_RECLAIM_CLEAN)
+			return PG_KEEP_LOCKED;
+		if (!may_enter_fs)
+			return PG_KEEP_LOCKED;
+		if (!sc->may_writepage)
+			return PG_KEEP_LOCKED;
+
+		/*
+		A * Page is dirty. Flush the TLB if a writable entry
+		A * potentially exists to avoid CPU writes after IO
+		A * starts and then write it out here.
+		A */
+		try_to_unmap_flush_dirty();
+		switch (pageout(page, mapping, sc)) {
+		case PAGE_KEEP:
+			return PG_KEEP_LOCKED;
+		case PAGE_ACTIVATE:
+			return PG_ACTIVATE_LOCKED;
+		case PAGE_SUCCESS:
+			if (PageWriteback(page))
+				return PG_KEEP;
+			if (PageDirty(page))
+				return PG_KEEP;
+
+			/*
+			A * A synchronous write - probably a ramdisk.A A Go
+			A * ahead and try to reclaim the page.
+			A */
+			if (!trylock_page(page))
+				return PG_KEEP;
+			if (PageDirty(page) || PageWriteback(page))
+				return PG_KEEP_LOCKED;
+			mapping = page_mapping(page);
+		case PAGE_CLEAN:
+			; /* try to free the page below */
+		}
+	}
+
+	/*
+	A * If the page has buffers, try to free the buffer mappings
+	A * associated with this page. If we succeed we try to free
+	A * the page as well.
+	A *
+	A * We do this even if the page is PageDirty().
+	A * try_to_release_page() does not perform I/O, but it is
+	A * possible for a page to have PageDirty set, but it is actually
+	A * clean (all its buffers are clean).A A This happens if the
+	A * buffers were written out directly, with submit_bh(). ext3
+	A * will do this, as well as the blockdev mapping.
+	A * try_to_release_page() will discover that cleanness and will
+	A * drop the buffers and mark the page clean - it can be freed.
+	A *
+	A * Rarely, pages can have buffers and no ->mapping.A A These are
+	A * the pages which were not successfully invalidated in
+	A * truncate_complete_page().A A We try to drop those buffers here
+	A * and if that worked, and the page is no longer mapped into
+	A * process address space (page_count == 1) it can be freed.
+	A * Otherwise, leave the page on the LRU so it is swappable.
+	A */
+	if (page_has_private(page)) {
+		if (!try_to_release_page(page, sc->gfp_mask))
+			return PG_ACTIVATE_LOCKED;
+		if (!mapping && page_count(page) == 1) {
+			unlock_page(page);
+			if (put_page_testzero(page))
+				return PG_FREE;
+			else {
+				/*
+				A * rare race with speculative reference.
+				A * the speculative reference will free
+				A * this page shortly, so we may
+				A * increment nr_reclaimed (and
+				A * leave it off the LRU).
+				A */
+				return PG_SPECULATIVE_REF;
+			}
+		}
+	}
+
+lazyfree:
+	if (!mapping || !__remove_mapping(mapping, page, true))
+		return PG_KEEP_LOCKED;
+
+	/*
+	A * At this point, we have no other references and there is
+	A * no way to pick any more up (removed from LRU, removed
+	A * from pagecache). Can use non-atomic bitops now (and
+	A * we obviously don't have to worry about waking up a process
+	A * waiting on the page lock, because there are no references.
+	A */
+	__ClearPageLocked(page);
+	return PG_FREE;
+}
+
+static void pg_finish(struct page *page,
+	enum pg_result pg_dispose,
+	int swap_ret,
+	unsigned long *nr_reclaimed,
+	int *pgactivate,
+	struct list_head *ret_pages,
+	struct list_head *free_pages)
+{
+	switch (pg_dispose) {
+	case PG_SPECULATIVE_REF:
+		++*nr_reclaimed;
+		return;
+	case PG_FREE:
+		if (swap_ret == SWAP_LZFREE)
+			count_vm_event(PGLAZYFREED);
+
+		++*nr_reclaimed;
+		/*
+		A * Is there need to periodically free_page_list? It would
+		A * appear not as the counts should be low
+		A */
+		list_add(&page->lru, free_pages);
+		return;
+	case PG_MLOCKED:
+		if (PageSwapCache(page))
+			try_to_free_swap(page);
+		unlock_page(page);
+		list_add(&page->lru, ret_pages);
+		return;
+	case PG_ACTIVATE_LOCKED:
+		/* Not a candidate for swapping, so reclaim swap space. */
+		if (PageSwapCache(page) && mem_cgroup_swap_full(page))
+			try_to_free_swap(page);
+		VM_BUG_ON_PAGE(PageActive(page), page);
+		SetPageActive(page);
+		++*pgactivate;
+	case PG_KEEP_LOCKED:
+		unlock_page(page);
+	case PG_KEEP:
+		list_add(&page->lru, ret_pages);
+	case PG_NEXT:
+		VM_BUG_ON_PAGE(PageLRU(page) || PageUnevictable(page), page);
+		break;
+	case PG_UNKNOWN:
+		VM_BUG_ON_PAGE((pg_dispose == PG_UNKNOWN), page);
+		break;
+	}
+}
+
A /*
A  * shrink_page_list() returns the number of reclaimed pages
A  */
@@ -904,28 +1114,35 @@ static unsigned long shrink_page_list(struct list_head *page_list,
A 		struct page *page;
A 		int may_enter_fs;
A 		enum page_references references = PAGEREF_RECLAIM_CLEAN;
+		enum pg_result pg_dispose = PG_UNKNOWN;
A 		bool dirty, writeback;
A 		bool lazyfree = false;
-		int ret = SWAP_SUCCESS;
+		int swap_ret = SWAP_SUCCESS;
A 
A 		cond_resched();
A 
A 		page = lru_to_page(page_list);
A 		list_del(&page->lru);
A 
-		if (!trylock_page(page))
-			goto keep;
+		if (!trylock_page(page)) {
+			pg_dispose = PG_KEEP;
+			goto finish;
+		}
A 
A 		VM_BUG_ON_PAGE(PageActive(page), page);
A 		VM_BUG_ON_PAGE(page_zone(page) != zone, page);
A 
A 		sc->nr_scanned++;
A 
-		if (unlikely(!page_evictable(page)))
-			goto cull_mlocked;
+		if (unlikely(!page_evictable(page))) {
+			pg_dispose = PG_MLOCKED;
+			goto finish;
+		}
A 
-		if (!sc->may_unmap && page_mapped(page))
-			goto keep_locked;
+		if (!sc->may_unmap && page_mapped(page)) {
+			pg_dispose = PG_KEEP_LOCKED;
+			goto finish;
+		}
A 
A 		/* Double the slab pressure for mapped and swapcache pages */
A 		if (page_mapped(page) || PageSwapCache(page))
@@ -998,7 +1215,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
A 			A A A A PageReclaim(page) &&
A 			A A A A test_bit(ZONE_WRITEBACK, &zone->flags)) {
A 				nr_immediate++;
-				goto keep_locked;
+				pg_dispose = PG_KEEP_LOCKED;
+				goto finish;
A 
A 			/* Case 2 above */
A 			} else if (sane_reclaim(sc) ||
@@ -1016,7 +1234,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
A 				A */
A 				SetPageReclaim(page);
A 				nr_writeback++;
-				goto keep_locked;
+				pg_dispose = PG_KEEP_LOCKED;
+				goto finish;
A 
A 			/* Case 3 above */
A 			} else {
@@ -1033,9 +1252,11 @@ static unsigned long shrink_page_list(struct list_head *page_list,
A 
A 		switch (references) {
A 		case PAGEREF_ACTIVATE:
-			goto activate_locked;
+			pg_dispose = PG_ACTIVATE_LOCKED;
+			goto finish;
A 		case PAGEREF_KEEP:
-			goto keep_locked;
+			pg_dispose = PG_KEEP_LOCKED;
+			goto finish;
A 		case PAGEREF_RECLAIM:
A 		case PAGEREF_RECLAIM_CLEAN:
A 			; /* try to reclaim the page below */
@@ -1046,183 +1267,25 @@ static unsigned long shrink_page_list(struct list_head *page_list,
A 		A * Try to allocate it some swap space here.
A 		A */
A 		if (PageAnon(page) && !PageSwapCache(page)) {
-			if (!(sc->gfp_mask & __GFP_IO))
-				goto keep_locked;
-			if (!add_to_swap(page, page_list))
-				goto activate_locked;
-			lazyfree = true;
-			may_enter_fs = 1;
-
-			/* Adding to swap updated mapping */
-			mapping = page_mapping(page);
-		}
-
-		/*
-		A * The page is mapped into the page tables of one or more
-		A * processes. Try to unmap it here.
-		A */
-		if (page_mapped(page) && mapping) {
-			switch (ret = try_to_unmap(page, lazyfree ?
-				(ttu_flags | TTU_BATCH_FLUSH | TTU_LZFREE) :
-				(ttu_flags | TTU_BATCH_FLUSH))) {
-			case SWAP_FAIL:
-				goto activate_locked;
-			case SWAP_AGAIN:
-				goto keep_locked;
-			case SWAP_MLOCK:
-				goto cull_mlocked;
-			case SWAP_LZFREE:
-				goto lazyfree;
-			case SWAP_SUCCESS:
-				; /* try to free the page below */
+			if (!(sc->gfp_mask & __GFP_IO)) {
+				pg_dispose = PG_KEEP_LOCKED;
+				goto finish;
A 			}
-		}
-
-		if (PageDirty(page)) {
-			/*
-			A * Only kswapd can writeback filesystem pages to
-			A * avoid risk of stack overflow but only writeback
-			A * if many dirty pages have been encountered.
-			A */
-			if (page_is_file_cache(page) &&
-					(!current_is_kswapd() ||
-					A !test_bit(ZONE_DIRTY, &zone->flags))) {
-				/*
-				A * Immediately reclaim when written back.
-				A * Similar in principal to deactivate_page()
-				A * except we already have the page isolated
-				A * and know it's dirty
-				A */
-				inc_zone_page_state(page, NR_VMSCAN_IMMEDIATE);
-				SetPageReclaim(page);
-
-				goto keep_locked;
-			}
-
-			if (references == PAGEREF_RECLAIM_CLEAN)
-				goto keep_locked;
-			if (!may_enter_fs)
-				goto keep_locked;
-			if (!sc->may_writepage)
-				goto keep_locked;
-
-			/*
-			A * Page is dirty. Flush the TLB if a writable entry
-			A * potentially exists to avoid CPU writes after IO
-			A * starts and then write it out here.
-			A */
-			try_to_unmap_flush_dirty();
-			switch (pageout(page, mapping, sc)) {
-			case PAGE_KEEP:
-				goto keep_locked;
-			case PAGE_ACTIVATE:
-				goto activate_locked;
-			case PAGE_SUCCESS:
-				if (PageWriteback(page))
-					goto keep;
-				if (PageDirty(page))
-					goto keep;
-
-				/*
-				A * A synchronous write - probably a ramdisk.A A Go
-				A * ahead and try to reclaim the page.
-				A */
-				if (!trylock_page(page))
-					goto keep;
-				if (PageDirty(page) || PageWriteback(page))
-					goto keep_locked;
-				mapping = page_mapping(page);
-			case PAGE_CLEAN:
-				; /* try to free the page below */
-			}
-		}
-
-		/*
-		A * If the page has buffers, try to free the buffer mappings
-		A * associated with this page. If we succeed we try to free
-		A * the page as well.
-		A *
-		A * We do this even if the page is PageDirty().
-		A * try_to_release_page() does not perform I/O, but it is
-		A * possible for a page to have PageDirty set, but it is actually
-		A * clean (all its buffers are clean).A A This happens if the
-		A * buffers were written out directly, with submit_bh(). ext3
-		A * will do this, as well as the blockdev mapping.
-		A * try_to_release_page() will discover that cleanness and will
-		A * drop the buffers and mark the page clean - it can be freed.
-		A *
-		A * Rarely, pages can have buffers and no ->mapping.A A These are
-		A * the pages which were not successfully invalidated in
-		A * truncate_complete_page().A A We try to drop those buffers here
-		A * and if that worked, and the page is no longer mapped into
-		A * process address space (page_count == 1) it can be freed.
-		A * Otherwise, leave the page on the LRU so it is swappable.
-		A */
-		if (page_has_private(page)) {
-			if (!try_to_release_page(page, sc->gfp_mask))
-				goto activate_locked;
-			if (!mapping && page_count(page) == 1) {
-				unlock_page(page);
-				if (put_page_testzero(page))
-					goto free_it;
-				else {
-					/*
-					A * rare race with speculative reference.
-					A * the speculative reference will free
-					A * this page shortly, so we may
-					A * increment nr_reclaimed here (and
-					A * leave it off the LRU).
-					A */
-					nr_reclaimed++;
-					continue;
-				}
+			if (!add_to_swap(page, page_list)) {
+				pg_dispose = PG_ACTIVATE_LOCKED;
+				goto finish;
A 			}
+			lazyfree = true;
+			may_enter_fs = 1;
A 		}
A 
-lazyfree:
-		if (!mapping || !__remove_mapping(mapping, page, true))
-			goto keep_locked;
-
-		/*
-		A * At this point, we have no other references and there is
-		A * no way to pick any more up (removed from LRU, removed
-		A * from pagecache). Can use non-atomic bitops now (and
-		A * we obviously don't have to worry about waking up a process
-		A * waiting on the page lock, because there are no references.
-		A */
-		__ClearPageLocked(page);
-free_it:
-		if (ret == SWAP_LZFREE)
-			count_vm_event(PGLAZYFREED);
-
-		nr_reclaimed++;
+		pg_dispose = handle_pgout(page_list, zone, sc, ttu_flags,
+				references, may_enter_fs, lazyfree,
+				&swap_ret, page);
+finish:
+		pg_finish(page, pg_dispose, swap_ret, &nr_reclaimed,
+				&pgactivate, &ret_pages, &free_pages);
A 
-		/*
-		A * Is there need to periodically free_page_list? It would
-		A * appear not as the counts should be low
-		A */
-		list_add(&page->lru, &free_pages);
-		continue;
-
-cull_mlocked:
-		if (PageSwapCache(page))
-			try_to_free_swap(page);
-		unlock_page(page);
-		list_add(&page->lru, &ret_pages);
-		continue;
-
-activate_locked:
-		/* Not a candidate for swapping, so reclaim swap space. */
-		if (PageSwapCache(page) && mem_cgroup_swap_full(page))
-			try_to_free_swap(page);
-		VM_BUG_ON_PAGE(PageActive(page), page);
-		SetPageActive(page);
-		pgactivate++;
-keep_locked:
-		unlock_page(page);
-keep:
-		list_add(&page->lru, &ret_pages);
-		VM_BUG_ON_PAGE(PageLRU(page) || PageUnevictable(page), page);
A 	}
A 
A 	mem_cgroup_uncharge_list(&free_pages);
--A 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
