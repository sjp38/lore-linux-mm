Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 181436B0005
	for <linux-mm@kvack.org>; Tue, 31 May 2016 13:17:52 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id di3so214641707pab.0
        for <linux-mm@kvack.org>; Tue, 31 May 2016 10:17:52 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id cd1si58755215pad.130.2016.05.31.10.17.48
        for <linux-mm@kvack.org>;
        Tue, 31 May 2016 10:17:50 -0700 (PDT)
Date: Tue, 31 May 2016 10:17:23 -0700
From: Tim Chen <tim.c.chen@linux.intel.com>
Subject: Re: [PATCH] mm: Cleanup - Reorganize the shrink_page_list code into
 smaller functions
Message-ID: <20160531171722.GA5763@linux.intel.com>
Reply-To: tim.c.chen@linux.intel.com
References: <1463779979.22178.142.camel@linux.intel.com>
 <20160531091550.GA19976@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20160531091550.GA19976@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, "Kirill A.Shutemov" <kirill.shutemov@linux.intel.com>, Andi Kleen <andi@firstfloor.org>, Aaron Lu <aaron.lu@intel.com>, Huang Ying <ying.huang@intel.com>, linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, tim.c.chen@linux.intel.com

On Tue, May 31, 2016 at 06:15:50PM +0900, Minchan Kim wrote:
> Hello Tim,
> 
> checking file mm/vmscan.c
> patch: **** malformed patch at line 89:                 mapping->a_ops->is_dirty_writeback(page, dirty, writeback);
> 
> Could you resend formal patch?
> 
> Thanks.

My mail client is misbehaving after a system upgrade.
Here's the patch again.


Subject: [PATCH] mm: Cleanup - Reorganize the shrink_page_list code into smaller functions

This patch consolidates the page out and the varous cleanup operations
within shrink_page_list function into handle_pgout and pg_finish
functions.

This makes the shrink_page_list function more concise and allows for
the separation of page out and page scan operations at a later time.
This is desirable if we want to group similar pages together and batch
process them in the page out path.

After we have scanned a page shrink_page_list and completed any paging,
the final disposition and clean up of the page is conslidated into
pg_finish.  The designated disposition of the page from page scanning
in shrink_page_list is marked with one of the designation in pg_result.

There is no intention to change any functionality or logic in this patch.

Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
---
 mm/vmscan.c | 429 ++++++++++++++++++++++++++++++++++--------------------------
 1 file changed, 246 insertions(+), 183 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 142cb61..0eb3c67 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -873,6 +873,216 @@ static void page_check_dirty_writeback(struct page *page,
 		mapping->a_ops->is_dirty_writeback(page, dirty, writeback);
 }
 
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
+	int  *swap_ret,
+	struct page *page)
+{
+	struct address_space *mapping;
+
+	mapping =  page_mapping(page);
+
+	/*
+	 * The page is mapped into the page tables of one or more
+	 * processes. Try to unmap it here.
+	 */
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
+		 * Only kswapd can writeback filesystem pages to
+		 * avoid risk of stack overflow but only writeback
+		 * if many dirty pages have been encountered.
+		 */
+		if (page_is_file_cache(page) &&
+				(!current_is_kswapd() ||
+				 !test_bit(ZONE_DIRTY, &zone->flags))) {
+			/*
+			 * Immediately reclaim when written back.
+			 * Similar in principal to deactivate_page()
+			 * except we already have the page isolated
+			 * and know it's dirty
+			 */
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
+		 * Page is dirty. Flush the TLB if a writable entry
+		 * potentially exists to avoid CPU writes after IO
+		 * starts and then write it out here.
+		 */
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
+			 * A synchronous write - probably a ramdisk.  Go
+			 * ahead and try to reclaim the page.
+			 */
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
+	 * If the page has buffers, try to free the buffer mappings
+	 * associated with this page. If we succeed we try to free
+	 * the page as well.
+	 *
+	 * We do this even if the page is PageDirty().
+	 * try_to_release_page() does not perform I/O, but it is
+	 * possible for a page to have PageDirty set, but it is actually
+	 * clean (all its buffers are clean).  This happens if the
+	 * buffers were written out directly, with submit_bh(). ext3
+	 * will do this, as well as the blockdev mapping.
+	 * try_to_release_page() will discover that cleanness and will
+	 * drop the buffers and mark the page clean - it can be freed.
+	 *
+	 * Rarely, pages can have buffers and no ->mapping.  These are
+	 * the pages which were not successfully invalidated in
+	 * truncate_complete_page().  We try to drop those buffers here
+	 * and if that worked, and the page is no longer mapped into
+	 * process address space (page_count == 1) it can be freed.
+	 * Otherwise, leave the page on the LRU so it is swappable.
+	 */
+	if (page_has_private(page)) {
+		if (!try_to_release_page(page, sc->gfp_mask))
+			return PG_ACTIVATE_LOCKED;
+		if (!mapping && page_count(page) == 1) {
+			unlock_page(page);
+			if (put_page_testzero(page))
+				return PG_FREE;
+			else {
+				/*
+				 * rare race with speculative reference.
+				 * the speculative reference will free
+				 * this page shortly, so we may
+				 * increment nr_reclaimed (and
+				 * leave it off the LRU).
+				 */
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
+	 * At this point, we have no other references and there is
+	 * no way to pick any more up (removed from LRU, removed
+	 * from pagecache). Can use non-atomic bitops now (and
+	 * we obviously don't have to worry about waking up a process
+	 * waiting on the page lock, because there are no references.
+	 */
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
+		 * Is there need to periodically free_page_list? It would
+		 * appear not as the counts should be low
+		 */
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
+		return;
+	case PG_UNKNOWN:
+		VM_BUG_ON_PAGE((pg_dispose == PG_UNKNOWN), page);
+		return;
+	}
+}
+
 /*
  * shrink_page_list() returns the number of reclaimed pages
  */
@@ -904,28 +1114,35 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		struct page *page;
 		int may_enter_fs;
 		enum page_references references = PAGEREF_RECLAIM_CLEAN;
+		enum pg_result pg_dispose = PG_UNKNOWN;
 		bool dirty, writeback;
 		bool lazyfree = false;
-		int ret = SWAP_SUCCESS;
+		int swap_ret = SWAP_SUCCESS;
 
 		cond_resched();
 
 		page = lru_to_page(page_list);
 		list_del(&page->lru);
 
-		if (!trylock_page(page))
-			goto keep;
+		if (!trylock_page(page)) {
+			pg_dispose = PG_KEEP;
+			goto finish;
+		}
 
 		VM_BUG_ON_PAGE(PageActive(page), page);
 		VM_BUG_ON_PAGE(page_zone(page) != zone, page);
 
 		sc->nr_scanned++;
 
-		if (unlikely(!page_evictable(page)))
-			goto cull_mlocked;
+		if (unlikely(!page_evictable(page))) {
+			pg_dispose = PG_MLOCKED;
+			goto finish;
+		}
 
-		if (!sc->may_unmap && page_mapped(page))
-			goto keep_locked;
+		if (!sc->may_unmap && page_mapped(page)) {
+			pg_dispose = PG_KEEP_LOCKED;
+			goto finish;
+		}
 
 		/* Double the slab pressure for mapped and swapcache pages */
 		if (page_mapped(page) || PageSwapCache(page))
@@ -998,7 +1215,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			    PageReclaim(page) &&
 			    test_bit(ZONE_WRITEBACK, &zone->flags)) {
 				nr_immediate++;
-				goto keep_locked;
+				pg_dispose = PG_KEEP_LOCKED;
+				goto finish;
 
 			/* Case 2 above */
 			} else if (sane_reclaim(sc) ||
@@ -1016,7 +1234,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				 */
 				SetPageReclaim(page);
 				nr_writeback++;
-				goto keep_locked;
+				pg_dispose = PG_KEEP_LOCKED;
+				goto finish;
 
 			/* Case 3 above */
 			} else {
@@ -1033,9 +1252,11 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 
 		switch (references) {
 		case PAGEREF_ACTIVATE:
-			goto activate_locked;
+			pg_dispose = PG_ACTIVATE_LOCKED;
+			goto finish;
 		case PAGEREF_KEEP:
-			goto keep_locked;
+			pg_dispose = PG_KEEP_LOCKED;
+			goto finish;
 		case PAGEREF_RECLAIM:
 		case PAGEREF_RECLAIM_CLEAN:
 			; /* try to reclaim the page below */
@@ -1046,183 +1267,25 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		 * Try to allocate it some swap space here.
 		 */
 		if (PageAnon(page) && !PageSwapCache(page)) {
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
-		 * The page is mapped into the page tables of one or more
-		 * processes. Try to unmap it here.
-		 */
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
 			}
-		}
-
-		if (PageDirty(page)) {
-			/*
-			 * Only kswapd can writeback filesystem pages to
-			 * avoid risk of stack overflow but only writeback
-			 * if many dirty pages have been encountered.
-			 */
-			if (page_is_file_cache(page) &&
-					(!current_is_kswapd() ||
-					 !test_bit(ZONE_DIRTY, &zone->flags))) {
-				/*
-				 * Immediately reclaim when written back.
-				 * Similar in principal to deactivate_page()
-				 * except we already have the page isolated
-				 * and know it's dirty
-				 */
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
-			 * Page is dirty. Flush the TLB if a writable entry
-			 * potentially exists to avoid CPU writes after IO
-			 * starts and then write it out here.
-			 */
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
-				 * A synchronous write - probably a ramdisk.  Go
-				 * ahead and try to reclaim the page.
-				 */
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
-		 * If the page has buffers, try to free the buffer mappings
-		 * associated with this page. If we succeed we try to free
-		 * the page as well.
-		 *
-		 * We do this even if the page is PageDirty().
-		 * try_to_release_page() does not perform I/O, but it is
-		 * possible for a page to have PageDirty set, but it is actually
-		 * clean (all its buffers are clean).  This happens if the
-		 * buffers were written out directly, with submit_bh(). ext3
-		 * will do this, as well as the blockdev mapping.
-		 * try_to_release_page() will discover that cleanness and will
-		 * drop the buffers and mark the page clean - it can be freed.
-		 *
-		 * Rarely, pages can have buffers and no ->mapping.  These are
-		 * the pages which were not successfully invalidated in
-		 * truncate_complete_page().  We try to drop those buffers here
-		 * and if that worked, and the page is no longer mapped into
-		 * process address space (page_count == 1) it can be freed.
-		 * Otherwise, leave the page on the LRU so it is swappable.
-		 */
-		if (page_has_private(page)) {
-			if (!try_to_release_page(page, sc->gfp_mask))
-				goto activate_locked;
-			if (!mapping && page_count(page) == 1) {
-				unlock_page(page);
-				if (put_page_testzero(page))
-					goto free_it;
-				else {
-					/*
-					 * rare race with speculative reference.
-					 * the speculative reference will free
-					 * this page shortly, so we may
-					 * increment nr_reclaimed here (and
-					 * leave it off the LRU).
-					 */
-					nr_reclaimed++;
-					continue;
-				}
+			if (!add_to_swap(page, page_list)) {
+				pg_dispose = PG_ACTIVATE_LOCKED;
+				goto finish;
 			}
+			lazyfree = true;
+			may_enter_fs = 1;
 		}
 
-lazyfree:
-		if (!mapping || !__remove_mapping(mapping, page, true))
-			goto keep_locked;
-
-		/*
-		 * At this point, we have no other references and there is
-		 * no way to pick any more up (removed from LRU, removed
-		 * from pagecache). Can use non-atomic bitops now (and
-		 * we obviously don't have to worry about waking up a process
-		 * waiting on the page lock, because there are no references.
-		 */
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
 
-		/*
-		 * Is there need to periodically free_page_list? It would
-		 * appear not as the counts should be low
-		 */
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
 	}
 
 	mem_cgroup_uncharge_list(&free_pages);
-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
