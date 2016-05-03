Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id D24656B0268
	for <linux-mm@kvack.org>; Tue,  3 May 2016 17:03:21 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b203so63397438pfb.1
        for <linux-mm@kvack.org>; Tue, 03 May 2016 14:03:21 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id k4si351779pan.85.2016.05.03.14.03.20
        for <linux-mm@kvack.org>;
        Tue, 03 May 2016 14:03:20 -0700 (PDT)
Message-ID: <1462309397.21143.13.camel@linux.intel.com>
Subject: [PATCH 6/7] mm: Cleanup - Reorganize code to group handling of page
From: Tim Chen <tim.c.chen@linux.intel.com>
Date: Tue, 03 May 2016 14:03:17 -0700
In-Reply-To: <cover.1462306228.git.tim.c.chen@linux.intel.com>
References: <cover.1462306228.git.tim.c.chen@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>
Cc: "Kirill A.Shutemov" <kirill.shutemov@linux.intel.com>, Andi Kleen <andi@firstfloor.org>, Aaron Lu <aaron.lu@intel.com>, Huang Ying <ying.huang@intel.com>, linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

In this patch, we reorganize the paging operations so the paging
operations of pages to the same swap device can be grouped together.
This prepares for the next patch that remove multiple pages from
the same swap cache together once they have been paged out.

The patch creates a new function handle_pgout_batch that takes
the code of handle_pgout and put a loop around handle_pgout code for
multiple pages.

Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
---
A mm/vmscan.c | 338 +++++++++++++++++++++++++++++++++++-------------------------
A 1 file changed, 196 insertions(+), 142 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index fab61f1..9fc04e1 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -884,154 +884,218 @@ enum pg_result {
A 	PG_UNKNOWN,
A };
A 
-static enum pg_result handle_pgout(struct list_head *page_list,
+static void handle_pgout_batch(struct list_head *page_list,
A 	struct zone *zone,
A 	struct scan_control *sc,
A 	enum ttu_flags ttu_flags,
A 	enum page_references references,
A 	bool may_enter_fs,
A 	bool lazyfree,
-	intA A *swap_ret,
-	struct page *page)
+	struct page *pages[],
+	intA A swap_ret[],
+	int ret[],
+	int nr)
A {
A 	struct address_space *mapping;
+	struct page *page;
+	int i;
A 
-	mapping =A A page_mapping(page);
+	for (i = 0; i < nr; ++i) {
+		page = pages[i];
+		mapping =A A page_mapping(page);
A 
-	/*
-	A * The page is mapped into the page tables of one or more
-	A * processes. Try to unmap it here.
-	A */
-	if (page_mapped(page) && mapping) {
-		switch (*swap_ret = try_to_unmap(page, lazyfree ?
-			(ttu_flags | TTU_BATCH_FLUSH | TTU_LZFREE) :
-			(ttu_flags | TTU_BATCH_FLUSH))) {
-		case SWAP_FAIL:
-			return PG_ACTIVATE_LOCKED;
-		case SWAP_AGAIN:
-			return PG_KEEP_LOCKED;
-		case SWAP_MLOCK:
-			return PG_MLOCKED;
-		case SWAP_LZFREE:
-			goto lazyfree;
-		case SWAP_SUCCESS:
-			; /* try to free the page below */
+		/* check outcome of cache addition */
+		if (!ret[i]) {
+			ret[i] = PG_ACTIVATE_LOCKED;
+			continue;
A 		}
-	}
-
-	if (PageDirty(page)) {
A 		/*
-		A * Only kswapd can writeback filesystem pages to
-		A * avoid risk of stack overflow but only writeback
-		A * if many dirty pages have been encountered.
+		A * The page is mapped into the page tables of one or more
+		A * processes. Try to unmap it here.
A 		A */
-		if (page_is_file_cache(page) &&
-				(!current_is_kswapd() ||
-				A !test_bit(ZONE_DIRTY, &zone->flags))) {
+		if (page_mapped(page) && mapping) {
+			switch (swap_ret[i] = try_to_unmap(page, lazyfree ?
+				(ttu_flags | TTU_BATCH_FLUSH | TTU_LZFREE) :
+				(ttu_flags | TTU_BATCH_FLUSH))) {
+			case SWAP_FAIL:
+				ret[i] = PG_ACTIVATE_LOCKED;
+				continue;
+			case SWAP_AGAIN:
+				ret[i] = PG_KEEP_LOCKED;
+				continue;
+			case SWAP_MLOCK:
+				ret[i] = PG_MLOCKED;
+				continue;
+			case SWAP_LZFREE:
+				goto lazyfree;
+			case SWAP_SUCCESS:
+				; /* try to free the page below */
+			}
+		}
+
+		if (PageDirty(page)) {
A 			/*
-			A * Immediately reclaim when written back.
-			A * Similar in principal to deactivate_page()
-			A * except we already have the page isolated
-			A * and know it's dirty
+			A * Only kswapd can writeback filesystem pages to
+			A * avoid risk of stack overflow but only writeback
+			A * if many dirty pages have been encountered.
A 			A */
-			inc_zone_page_state(page, NR_VMSCAN_IMMEDIATE);
-			SetPageReclaim(page);
-
-			return PG_KEEP_LOCKED;
-		}
+			if (page_is_file_cache(page) &&
+					(!current_is_kswapd() ||
+					A !test_bit(ZONE_DIRTY, &zone->flags))) {
+				/*
+				A * Immediately reclaim when written back.
+				A * Similar in principal to deactivate_page()
+				A * except we already have the page isolated
+				A * and know it's dirty
+				A */
+				inc_zone_page_state(page, NR_VMSCAN_IMMEDIATE);
+				SetPageReclaim(page);
A 
-		if (references == PAGEREF_RECLAIM_CLEAN)
-			return PG_KEEP_LOCKED;
-		if (!may_enter_fs)
-			return PG_KEEP_LOCKED;
-		if (!sc->may_writepage)
-			return PG_KEEP_LOCKED;
+				ret[i] = PG_KEEP_LOCKED;
+				continue;
+			}
A 
-		/*
-		A * Page is dirty. Flush the TLB if a writable entry
-		A * potentially exists to avoid CPU writes after IO
-		A * starts and then write it out here.
-		A */
-		try_to_unmap_flush_dirty();
-		switch (pageout(page, mapping, sc)) {
-		case PAGE_KEEP:
-			return PG_KEEP_LOCKED;
-		case PAGE_ACTIVATE:
-			return PG_ACTIVATE_LOCKED;
-		case PAGE_SUCCESS:
-			if (PageWriteback(page))
-				return PG_KEEP;
-			if (PageDirty(page))
-				return PG_KEEP;
+			if (references == PAGEREF_RECLAIM_CLEAN) {
+				ret[i] = PG_KEEP_LOCKED;
+				continue;
+			}
+			if (!may_enter_fs) {
+				ret[i] = PG_KEEP_LOCKED;
+				continue;
+			}
+			if (!sc->may_writepage) {
+				ret[i] = PG_KEEP_LOCKED;
+				continue;
+			}
A 
A 			/*
-			A * A synchronous write - probably a ramdisk.A A Go
-			A * ahead and try to reclaim the page.
+			A * Page is dirty. Flush the TLB if a writable entry
+			A * potentially exists to avoid CPU writes after IO
+			A * starts and then write it out here.
A 			A */
-			if (!trylock_page(page))
-				return PG_KEEP;
-			if (PageDirty(page) || PageWriteback(page))
-				return PG_KEEP_LOCKED;
-			mapping = page_mapping(page);
-		case PAGE_CLEAN:
-			; /* try to free the page below */
-		}
-	}
+			try_to_unmap_flush_dirty();
+			switch (pageout(page, mapping, sc)) {
+			case PAGE_KEEP:
+				ret[i] = PG_KEEP_LOCKED;
+				continue;
+			case PAGE_ACTIVATE:
+				ret[i] = PG_ACTIVATE_LOCKED;
+				continue;
+			case PAGE_SUCCESS:
+				if (PageWriteback(page)) {
+					ret[i] = PG_KEEP;
+					continue;
+				}
+				if (PageDirty(page)) {
+					ret[i] = PG_KEEP;
+					continue;
+				}
A 
-	/*
-	A * If the page has buffers, try to free the buffer mappings
-	A * associated with this page. If we succeed we try to free
-	A * the page as well.
-	A *
-	A * We do this even if the page is PageDirty().
-	A * try_to_release_page() does not perform I/O, but it is
-	A * possible for a page to have PageDirty set, but it is actually
-	A * clean (all its buffers are clean).A A This happens if the
-	A * buffers were written out directly, with submit_bh(). ext3
-	A * will do this, as well as the blockdev mapping.
-	A * try_to_release_page() will discover that cleanness and will
-	A * drop the buffers and mark the page clean - it can be freed.
-	A *
-	A * Rarely, pages can have buffers and no ->mapping.A A These are
-	A * the pages which were not successfully invalidated in
-	A * truncate_complete_page().A A We try to drop those buffers here
-	A * and if that worked, and the page is no longer mapped into
-	A * process address space (page_count == 1) it can be freed.
-	A * Otherwise, leave the page on the LRU so it is swappable.
-	A */
-	if (page_has_private(page)) {
-		if (!try_to_release_page(page, sc->gfp_mask))
-			return PG_ACTIVATE_LOCKED;
-		if (!mapping && page_count(page) == 1) {
-			unlock_page(page);
-			if (put_page_testzero(page))
-				return PG_FREE;
-			else {
A 				/*
-				A * rare race with speculative reference.
-				A * the speculative reference will free
-				A * this page shortly, so we may
-				A * increment nr_reclaimed (and
-				A * leave it off the LRU).
+				A * A synchronous write - probably a ramdisk.A A Go
+				A * ahead and try to reclaim the page.
A 				A */
-				return PG_SPECULATIVE_REF;
+				if (!trylock_page(page)) {
+					ret[i] = PG_KEEP;
+					continue;
+				}
+				if (PageDirty(page) || PageWriteback(page)) {
+					ret[i] = PG_KEEP_LOCKED;
+					continue;
+				}
+				mapping = page_mapping(page);
+			case PAGE_CLEAN:
+				; /* try to free the page below */
A 			}
A 		}
-	}
A 
+		/*
+		A * If the page has buffers, try to free the buffer mappings
+		A * associated with this page. If we succeed we try to free
+		A * the page as well.
+		A *
+		A * We do this even if the page is PageDirty().
+		A * try_to_release_page() does not perform I/O, but it is
+		A * possible for a page to have PageDirty set, but it is actually
+		A * clean (all its buffers are clean).A A This happens if the
+		A * buffers were written out directly, with submit_bh(). ext3
+		A * will do this, as well as the blockdev mapping.
+		A * try_to_release_page() will discover that cleanness and will
+		A * drop the buffers and mark the page clean - it can be freed.
+		A *
+		A * Rarely, pages can have buffers and no ->mapping.A A These are
+		A * the pages which were not successfully invalidated in
+		A * truncate_complete_page().A A We try to drop those buffers here
+		A * and if that worked, and the page is no longer mapped into
+		A * process address space (page_count == 1) it can be freed.
+		A * Otherwise, leave the page on the LRU so it is swappable.
+		A */
+		if (page_has_private(page)) {
+			if (!try_to_release_page(page, sc->gfp_mask)) {
+				ret[i] = PG_ACTIVATE_LOCKED;
+				continue;
+			}
+			if (!mapping && page_count(page) == 1) {
+				unlock_page(page);
+				if (put_page_testzero(page)) {
+					ret[i] = PG_FREE;
+					continue;
+				} else {
+					/*
+					A * rare race with speculative reference.
+					A * the speculative reference will free
+					A * this page shortly, so we may
+					A * increment nr_reclaimed (and
+					A * leave it off the LRU).
+					A */
+					ret[i] = PG_SPECULATIVE_REF;
+					continue;
+				}
+			}
+		}
A lazyfree:
-	if (!mapping || !__remove_mapping(mapping, page, true))
-		return PG_KEEP_LOCKED;
+		if (!mapping || !__remove_mapping(mapping, page, true)) {
+			ret[i] = PG_KEEP_LOCKED;
+			continue;
+		}
+
+		/*
+		A * At this point, we have no other references and there is
+		A * no way to pick any more up (removed from LRU, removed
+		A * from pagecache). Can use non-atomic bitops now (and
+		A * we obviously don't have to worry about waking up a process
+		A * waiting on the page lock, because there are no references.
+		A */
+		__ClearPageLocked(page);
+		ret[i] = PG_FREE;
+	}
+}
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
+	struct page *pages[1];
+	int ret[1];
+	int sret[1];
+
+	pages[0] = page;
A 
A 	/*
-	A * At this point, we have no other references and there is
-	A * no way to pick any more up (removed from LRU, removed
-	A * from pagecache). Can use non-atomic bitops now (and
-	A * we obviously don't have to worry about waking up a process
-	A * waiting on the page lock, because there are no references.
+	A * page is in swap cache or page cache, indicate that
+	A * by setting ret[0] to 1
A 	A */
-	__ClearPageLocked(page);
-	return PG_FREE;
+	ret[0] = 1;
+	handle_pgout_batch(page_list, zone, sc, ttu_flags, references,
+		may_enter_fs, lazyfree, pages, sret, ret, 1);
+	*swap_ret = sret[0];
+	return ret[0];
A }
A 
A static void pg_finish(struct page *page,
@@ -1095,14 +1159,13 @@ static unsigned long shrink_anon_page_list(struct list_head *page_list,
A 	bool clean)
A {
A 	unsigned long nr_reclaimed = 0;
-	enum pg_result pg_dispose;
A 	swp_entry_t swp_entries[SWAP_BATCH];
A 	struct page *pages[SWAP_BATCH];
A 	int m, i, k, ret[SWAP_BATCH];
A 	struct page *page;
A 
A 	while (n > 0) {
-		int swap_ret = SWAP_SUCCESS;
+		int swap_ret[SWAP_BATCH];
A 
A 		m = get_swap_pages(n, swp_entries);
A 		if (!m)
@@ -1127,28 +1190,19 @@ static unsigned long shrink_anon_page_list(struct list_head *page_list,
A 		*/
A 		add_to_swap_batch(pages, page_list, swp_entries, ret, m);
A 
-		for (i = 0; i < m; ++i) {
-			page = pages[i];
-
-			if (!ret[i]) {
-				pg_finish(page, PG_ACTIVATE_LOCKED, swap_ret,
-						&nr_reclaimed, pgactivate,
-						ret_pages, free_pages);
-				continue;
-			}
-
-			if (clean)
-				pg_dispose = handle_pgout(page_list, zone, sc,
-						ttu_flags, PAGEREF_RECLAIM_CLEAN,
-						true, true, &swap_ret, page);
-			else
-				pg_dispose = handle_pgout(page_list, zone, sc,
-						ttu_flags, PAGEREF_RECLAIM,
-						true, true, &swap_ret, page);
-
-			pg_finish(page, pg_dispose, swap_ret, &nr_reclaimed,
-					pgactivate, ret_pages, free_pages);
-		}
+		if (clean)
+			handle_pgout_batch(page_list, zone, sc, ttu_flags,
+					PAGEREF_RECLAIM_CLEAN, true, true,
+					pages, swap_ret, ret, m);
+		else
+			handle_pgout_batch(page_list, zone, sc, ttu_flags,
+					PAGEREF_RECLAIM, true, true,
+					pages, swap_ret, ret, m);
+
+		for (i = 0; i < m; ++i)
+			pg_finish(pages[i], ret[i], swap_ret[i],
+					&nr_reclaimed, pgactivate,
+					ret_pages, free_pages);
A 	}
A 	return nr_reclaimed;
A 
--A 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
