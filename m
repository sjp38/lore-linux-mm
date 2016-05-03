Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 682B96B0269
	for <linux-mm@kvack.org>; Tue,  3 May 2016 17:03:38 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id gw7so43556484pac.0
        for <linux-mm@kvack.org>; Tue, 03 May 2016 14:03:38 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id zu17si284223pab.174.2016.05.03.14.03.37
        for <linux-mm@kvack.org>;
        Tue, 03 May 2016 14:03:37 -0700 (PDT)
Message-ID: <1462309416.21143.14.camel@linux.intel.com>
Subject: [PATCH 7/7] mm: Batch unmapping of pages that are in swap cache
From: Tim Chen <tim.c.chen@linux.intel.com>
Date: Tue, 03 May 2016 14:03:36 -0700
In-Reply-To: <cover.1462306228.git.tim.c.chen@linux.intel.com>
References: <cover.1462306228.git.tim.c.chen@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>
Cc: "Kirill A.Shutemov" <kirill.shutemov@linux.intel.com>, Andi Kleen <andi@firstfloor.org>, Aaron Lu <aaron.lu@intel.com>, Huang Ying <ying.huang@intel.com>, linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

We created a new function __remove_swap_mapping_batch that
allows all pages under the same swap partition to be removed
from the swap cache's mapping in a single acquisition
of the mapping's tree lock.A A This reduces the contention
on the lock when multiple threads are reclaiming
memory by swapping to the same swap partition.

The handle_pgout_batch function is updated so all the
pages under the same swap partition are unmapped together
when the have been paged out.

Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
---
A mm/vmscan.c | 426 ++++++++++++++++++++++++++++++++++++++++--------------------
A 1 file changed, 286 insertions(+), 140 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 9fc04e1..5e4b8ce 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -690,6 +690,103 @@ cannot_free:
A 	return 0;
A }
A 
+/* use this only for swap mapped pages */
+static void __remove_swap_mapping_batch(struct page *pages[],
+			A A A A bool reclaimed, short ret[], int nr)
+{
+	unsigned long flags;
+	struct page *page;
+	swp_entry_t swap[SWAP_BATCH];
+	struct address_space *mapping;
+
+	int i, batch_size;
+
+	if (nr <= 0)
+		return;
+
+	while (nr) {
+		mapping = page_mapping(pages[0]);
+		BUG_ON(!mapping);
+
+		batch_size = min(nr, SWAP_BATCH);
+
+		spin_lock_irqsave(&mapping->tree_lock, flags);
+		for (i = 0; i < batch_size; ++i) {
+			page = pages[i];
+
+			BUG_ON(!PageLocked(page));
+			BUG_ON(!PageSwapCache(page));
+			BUG_ON(mapping != page_mapping(page));
+
+			/* stop batching if mapping changes */
+			if (mapping != page_mapping(page)) {
+				batch_size = i;
+				break;
+			}
+			/*
+			A * The non racy check for a busy page.
+			A *
+			A * Must be careful with the order of the tests. When someone has
+			A * a ref to the page, it may be possible that they dirty it then
+			A * drop the reference. So if PageDirty is tested before page_count
+			A * here, then the following race may occur:
+			A *
+			A * get_user_pages(&page);
+			A * [user mapping goes away]
+			A * write_to(page);
+			A *				!PageDirty(page)A A A A [good]
+			A * SetPageDirty(page);
+			A * put_page(page);
+			A *				!page_count(page)A A A [good, discard it]
+			A *
+			A * [oops, our write_to data is lost]
+			A *
+			A * Reversing the order of the tests ensures such a situation cannot
+			A * escape unnoticed. The smp_rmb is needed to ensure the page->flags
+			A * load is not satisfied before that of page->_count.
+			A *
+			A * Note that if SetPageDirty is always performed via set_page_dirty,
+			A * and thus under tree_lock, then this ordering is not required.
+			A */
+			if (!page_ref_freeze(page, 2))
+				goto cannot_free;
+			/* note: atomic_cmpxchg in page_freeze_refs provides the smp_rmb */
+			if (unlikely(PageDirty(page))) {
+				page_ref_unfreeze(page, 2);
+				goto cannot_free;
+			}
+
+			swap[i].val = page_private(page);
+			__delete_from_swap_cache(page);
+
+			ret[i] = 1;
+			continue;
+
+cannot_free:
+			ret[i] = 0;
+		}
+		spin_unlock_irqrestore(&mapping->tree_lock, flags);
+
+		/* need to keep irq off for mem_cgroup accounting, don't restore flags yetA A */
+		local_irq_disable();
+		for (i = 0; i < batch_size; ++i) {
+			if (ret[i]) {
+				page = pages[i];
+				mem_cgroup_swapout(page, swap[i]);
+			}
+		}
+		local_irq_enable();
+
+		for (i = 0; i < batch_size; ++i) {
+			if (ret[i])
+				swapcache_free(swap[i]);
+		}
+		/* advance to next batch */
+		pages += batch_size;
+		ret += batch_size;
+		nr -= batch_size;
+	}
+}
A /*
A  * Attempt to detach a locked page from its ->mapping.A A If it is dirty or if
A  * someone else has a ref on the page, abort and return 0.A A If it was
@@ -897,177 +994,226 @@ static void handle_pgout_batch(struct list_head *page_list,
A 	int nr)
A {
A 	struct address_space *mapping;
+	struct page *umap_pages[SWAP_BATCH];
A 	struct page *page;
-	int i;
-
-	for (i = 0; i < nr; ++i) {
-		page = pages[i];
-		mapping =A A page_mapping(page);
+	int i, j, batch_size;
+	short umap_ret[SWAP_BATCH], idx[SWAP_BATCH];
+
+	while (nr) {
+		j = 0;
+		batch_size = min(nr, SWAP_BATCH);
+		mapping = NULL;
+
+		for (i = 0; i < batch_size; ++i) {
+			page = pages[i];
+
+			if (mapping) {
+				if (mapping != page_mapping(page)) {
+					/* mapping change, stop batch here */
+					batch_size = i;
+					break;
+				}
+			} else
+				mapping =A A page_mapping(page);
A 
-		/* check outcome of cache addition */
-		if (!ret[i]) {
-			ret[i] = PG_ACTIVATE_LOCKED;
-			continue;
-		}
-		/*
-		A * The page is mapped into the page tables of one or more
-		A * processes. Try to unmap it here.
-		A */
-		if (page_mapped(page) && mapping) {
-			switch (swap_ret[i] = try_to_unmap(page, lazyfree ?
-				(ttu_flags | TTU_BATCH_FLUSH | TTU_LZFREE) :
-				(ttu_flags | TTU_BATCH_FLUSH))) {
-			case SWAP_FAIL:
+			/* check outcome of cache addition */
+			if (!ret[i]) {
A 				ret[i] = PG_ACTIVATE_LOCKED;
A 				continue;
-			case SWAP_AGAIN:
-				ret[i] = PG_KEEP_LOCKED;
-				continue;
-			case SWAP_MLOCK:
-				ret[i] = PG_MLOCKED;
-				continue;
-			case SWAP_LZFREE:
-				goto lazyfree;
-			case SWAP_SUCCESS:
-				; /* try to free the page below */
A 			}
-		}
-
-		if (PageDirty(page)) {
A 			/*
-			A * Only kswapd can writeback filesystem pages to
-			A * avoid risk of stack overflow but only writeback
-			A * if many dirty pages have been encountered.
+			A * The page is mapped into the page tables of one or more
+			A * processes. Try to unmap it here.
A 			A */
-			if (page_is_file_cache(page) &&
-					(!current_is_kswapd() ||
-					A !test_bit(ZONE_DIRTY, &zone->flags))) {
+			if (page_mapped(page) && mapping) {
+				switch (swap_ret[i] = try_to_unmap(page, lazyfree ?
+					(ttu_flags | TTU_BATCH_FLUSH | TTU_LZFREE) :
+					(ttu_flags | TTU_BATCH_FLUSH))) {
+				case SWAP_FAIL:
+					ret[i] = PG_ACTIVATE_LOCKED;
+					continue;
+				case SWAP_AGAIN:
+					ret[i] = PG_KEEP_LOCKED;
+					continue;
+				case SWAP_MLOCK:
+					ret[i] = PG_MLOCKED;
+					continue;
+				case SWAP_LZFREE:
+					goto lazyfree;
+				case SWAP_SUCCESS:
+					; /* try to free the page below */
+				}
+			}
+
+			if (PageDirty(page)) {
A 				/*
-				A * Immediately reclaim when written back.
-				A * Similar in principal to deactivate_page()
-				A * except we already have the page isolated
-				A * and know it's dirty
+				A * Only kswapd can writeback filesystem pages to
+				A * avoid risk of stack overflow but only writeback
+				A * if many dirty pages have been encountered.
A 				A */
-				inc_zone_page_state(page, NR_VMSCAN_IMMEDIATE);
-				SetPageReclaim(page);
-
-				ret[i] = PG_KEEP_LOCKED;
-				continue;
-			}
+				if (page_is_file_cache(page) &&
+						(!current_is_kswapd() ||
+						A !test_bit(ZONE_DIRTY, &zone->flags))) {
+					/*
+					A * Immediately reclaim when written back.
+					A * Similar in principal to deactivate_page()
+					A * except we already have the page isolated
+					A * and know it's dirty
+					A */
+					inc_zone_page_state(page, NR_VMSCAN_IMMEDIATE);
+					SetPageReclaim(page);
A 
-			if (references == PAGEREF_RECLAIM_CLEAN) {
-				ret[i] = PG_KEEP_LOCKED;
-				continue;
-			}
-			if (!may_enter_fs) {
-				ret[i] = PG_KEEP_LOCKED;
-				continue;
-			}
-			if (!sc->may_writepage) {
-				ret[i] = PG_KEEP_LOCKED;
-				continue;
-			}
+					ret[i] = PG_KEEP_LOCKED;
+					continue;
+				}
A 
-			/*
-			A * Page is dirty. Flush the TLB if a writable entry
-			A * potentially exists to avoid CPU writes after IO
-			A * starts and then write it out here.
-			A */
-			try_to_unmap_flush_dirty();
-			switch (pageout(page, mapping, sc)) {
-			case PAGE_KEEP:
-				ret[i] = PG_KEEP_LOCKED;
-				continue;
-			case PAGE_ACTIVATE:
-				ret[i] = PG_ACTIVATE_LOCKED;
-				continue;
-			case PAGE_SUCCESS:
-				if (PageWriteback(page)) {
-					ret[i] = PG_KEEP;
+				if (references == PAGEREF_RECLAIM_CLEAN) {
+					ret[i] = PG_KEEP_LOCKED;
+					continue;
+				}
+				if (!may_enter_fs) {
+					ret[i] = PG_KEEP_LOCKED;
A 					continue;
A 				}
-				if (PageDirty(page)) {
-					ret[i] = PG_KEEP;
+				if (!sc->may_writepage) {
+					ret[i] = PG_KEEP_LOCKED;
A 					continue;
A 				}
A 
A 				/*
-				A * A synchronous write - probably a ramdisk.A A Go
-				A * ahead and try to reclaim the page.
+				A * Page is dirty. Flush the TLB if a writable entry
+				A * potentially exists to avoid CPU writes after IO
+				A * starts and then write it out here.
A 				A */
-				if (!trylock_page(page)) {
-					ret[i] = PG_KEEP;
-					continue;
-				}
-				if (PageDirty(page) || PageWriteback(page)) {
+				try_to_unmap_flush_dirty();
+				switch (pageout(page, mapping, sc)) {
+				case PAGE_KEEP:
A 					ret[i] = PG_KEEP_LOCKED;
A 					continue;
+				case PAGE_ACTIVATE:
+					ret[i] = PG_ACTIVATE_LOCKED;
+					continue;
+				case PAGE_SUCCESS:
+					if (PageWriteback(page)) {
+						ret[i] = PG_KEEP;
+						continue;
+					}
+					if (PageDirty(page)) {
+						ret[i] = PG_KEEP;
+						continue;
+					}
+
+					/*
+					A * A synchronous write - probably a ramdisk.A A Go
+					A * ahead and try to reclaim the page.
+					A */
+					if (!trylock_page(page)) {
+						ret[i] = PG_KEEP;
+						continue;
+					}
+					if (PageDirty(page) || PageWriteback(page)) {
+						ret[i] = PG_KEEP_LOCKED;
+						continue;
+					}
+					mapping = page_mapping(page);
+				case PAGE_CLEAN:
+					; /* try to free the page below */
A 				}
-				mapping = page_mapping(page);
-			case PAGE_CLEAN:
-				; /* try to free the page below */
A 			}
-		}
A 
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
-			if (!try_to_release_page(page, sc->gfp_mask)) {
-				ret[i] = PG_ACTIVATE_LOCKED;
+			/*
+			A * If the page has buffers, try to free the buffer mappings
+			A * associated with this page. If we succeed we try to free
+			A * the page as well.
+			A *
+			A * We do this even if the page is PageDirty().
+			A * try_to_release_page() does not perform I/O, but it is
+			A * possible for a page to have PageDirty set, but it is actually
+			A * clean (all its buffers are clean).A A This happens if the
+			A * buffers were written out directly, with submit_bh(). ext3
+			A * will do this, as well as the blockdev mapping.
+			A * try_to_release_page() will discover that cleanness and will
+			A * drop the buffers and mark the page clean - it can be freed.
+			A *
+			A * Rarely, pages can have buffers and no ->mapping.A A These are
+			A * the pages which were not successfully invalidated in
+			A * truncate_complete_page().A A We try to drop those buffers here
+			A * and if that worked, and the page is no longer mapped into
+			A * process address space (page_count == 1) it can be freed.
+			A * Otherwise, leave the page on the LRU so it is swappable.
+			A */
+			if (page_has_private(page)) {
+				if (!try_to_release_page(page, sc->gfp_mask)) {
+					ret[i] = PG_ACTIVATE_LOCKED;
+					continue;
+				}
+				if (!mapping && page_count(page) == 1) {
+					unlock_page(page);
+					if (put_page_testzero(page)) {
+						ret[i] = PG_FREE;
+						continue;
+					} else {
+						/*
+						A * rare race with speculative reference.
+						A * the speculative reference will free
+						A * this page shortly, so we may
+						A * increment nr_reclaimed (and
+						A * leave it off the LRU).
+						A */
+						ret[i] = PG_SPECULATIVE_REF;
+						continue;
+					}
+				}
+			}
+lazyfree:
+			if (!mapping) {
+				ret[i] = PG_KEEP_LOCKED;
A 				continue;
A 			}
-			if (!mapping && page_count(page) == 1) {
-				unlock_page(page);
-				if (put_page_testzero(page)) {
-					ret[i] = PG_FREE;
-					continue;
-				} else {
-					/*
-					A * rare race with speculative reference.
-					A * the speculative reference will free
-					A * this page shortly, so we may
-					A * increment nr_reclaimed (and
-					A * leave it off the LRU).
-					A */
-					ret[i] = PG_SPECULATIVE_REF;
+			if (!PageSwapCache(page)) {
+				if (!__remove_mapping(mapping, page, true)) {
+					ret[i] = PG_KEEP_LOCKED;
A 					continue;
A 				}
+				__ClearPageLocked(page);
+				ret[i] = PG_FREE;
+				continue;
A 			}
+
+			/* note pages to be unmapped */
+			ret[i] = PG_UNKNOWN;
+			idx[j] = i;
+			umap_pages[j] = page;
+			++j;
A 		}
-lazyfree:
-		if (!mapping || !__remove_mapping(mapping, page, true)) {
-			ret[i] = PG_KEEP_LOCKED;
-			continue;
+
+		/* handle remaining pages that need to be unmapped */
+		__remove_swap_mapping_batch(umap_pages, true, umap_ret, j);
+
+		for (i = 0; i < j; ++i) {
+			if (!umap_ret[i]) {
+				/* unmap failed */
+				ret[idx[i]] = PG_KEEP_LOCKED;
+				continue;
+			}
+
+			page = umap_pages[i];
+			/*
+			A * At this point, we have no other references and there is
+			A * no way to pick any more up (removed from LRU, removed
+			A * from pagecache). Can use non-atomic bitops now (and
+			A * we obviously don't have to worry about waking up a process
+			A * waiting on the page lock, because there are no references.
+			A */
+			__ClearPageLocked(page);
+			ret[idx[i]] = PG_FREE;
A 		}
A 
-		/*
-		A * At this point, we have no other references and there is
-		A * no way to pick any more up (removed from LRU, removed
-		A * from pagecache). Can use non-atomic bitops now (and
-		A * we obviously don't have to worry about waking up a process
-		A * waiting on the page lock, because there are no references.
-		A */
-		__ClearPageLocked(page);
-		ret[i] = PG_FREE;
+		/* advance pointers to next batch and remaining page count */
+		nr = nr - batch_size;
+		pages += batch_size;
+		ret += batch_size;
+		swap_ret += batch_size;
A 	}
A }
A 
--A 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
