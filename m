Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id EB9136B0294
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 00:51:28 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id c85so65242931wmi.6
        for <linux-mm@kvack.org>; Sun, 29 Jan 2017 21:51:28 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id i128si12037710wmi.52.2017.01.29.21.51.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 29 Jan 2017 21:51:27 -0800 (PST)
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.20/8.16.0.20) with SMTP id v0U5kZV8024732
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 21:51:26 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0001303.ppops.net with ESMTP id 288qugw7xc-2
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 21:51:26 -0800
Received: from facebook.com (2401:db00:21:603d:face:0:19:0)	by
 mx-out.facebook.com (10.102.107.99) with ESMTP	id
 21c4de84e6b011e6ac470002c99293a0-721f6a50 for <linux-mm@kvack.org>;	Sun, 29
 Jan 2017 21:51:23 -0800
From: Shaohua Li <shli@fb.com>
Subject: [RFC 5/6] mm: reclaim lazyfree pages
Date: Sun, 29 Jan 2017 21:51:22 -0800
Message-ID: <11c611e9a6e50be1b5961b266c48cc14b725a74b.1485748619.git.shli@fb.com>
In-Reply-To: <cover.1485748619.git.shli@fb.com>
References: <cover.1485748619.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Kernel-team@fb.com, mhocko@suse.com, minchan@kernel.org, hughd@google.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@techsingularity.net

When memory pressure is high, we must free lazyfree pages. If we free
lazyfree pages, the cost reaccessing the pages is a page fault and page
allocation. The cost is much lower than swapin a page or refill a file
page cache because refilling anon/file page includes the same cost plus
extra IO cost, which is very high.

The policy to determine when to free lazyfree pages is controversial.
Some think lazyfree pages should be reclaimed first before any other
anon/file pages, because userspace already indicates the pages are not
important at all and the cost to refill lazyfree pages is much lower
than refilling anon/file page cache. Others think userspace could still
use the MADV_FREE pages otherwise userspace will directly use
MADV_DISCARD to free the pages. If page cache won't be used again, there
is no refill cost for page cache and thus in this case reclaiming
MADV_FREE pages doesn't make sense because refill MADV_FREE pages still
has cost.

This patch doesn't choose the latter. It's possible released page cache
never gets refilled, but the opposite case could happen very likely too.
Considering the refill cost of file/anon pages is much higher than
refill cost of MADV_FREE pages, it doesn't make sense to retain lazyfree
pages.

For the implementation, this is targeted for swapless system, so we
don't allocate a swap entry for lazyfree pages. If the pages can't be
reclaimed directly, they are put back into anon lru list and reclaimed
in normal way.

Cc: Michal Hocko <mhocko@suse.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Signed-off-by: Shaohua Li <shli@fb.com>
---
 mm/rmap.c   |  7 ++++++-
 mm/vmscan.c | 56 ++++++++++++++++++++++++++++++++++++++++++++++++--------
 2 files changed, 54 insertions(+), 9 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index c48e9c1..f9b1023 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1546,13 +1546,18 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 		 * Store the swap location in the pte.
 		 * See handle_pte_fault() ...
 		 */
-		VM_BUG_ON_PAGE(!PageSwapCache(page), page);
+		VM_BUG_ON_PAGE(!PageSwapCache(page) && !PageLazyFree(page),
+			page);
 
 		if (!PageDirty(page) && (flags & TTU_LZFREE)) {
 			/* It's a freeable page by MADV_FREE */
 			dec_mm_counter(mm, MM_ANONPAGES);
 			rp->lazyfreed++;
 			goto discard;
+		} else if (flags & TTU_LZFREE) {
+			set_pte_at(mm, address, pte, pteval);
+			ret = SWAP_FAIL;
+			goto out_unmap;
 		}
 
 		if (swap_duplicate(entry) < 0) {
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 3a0d05b..f809f04 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -974,7 +974,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		int may_enter_fs;
 		enum page_references references = PAGEREF_RECLAIM_CLEAN;
 		bool dirty, writeback;
-		bool lazyfree = false;
+		bool lazyfree;
 		int ret = SWAP_SUCCESS;
 
 		cond_resched();
@@ -989,6 +989,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 
 		sc->nr_scanned++;
 
+		lazyfree = page_is_lazyfree(page);
+
 		if (unlikely(!page_evictable(page)))
 			goto cull_mlocked;
 
@@ -996,7 +998,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			goto keep_locked;
 
 		/* Double the slab pressure for mapped and swapcache pages */
-		if (page_mapped(page) || PageSwapCache(page))
+		if ((page_mapped(page) || PageSwapCache(page)) && !lazyfree)
 			sc->nr_scanned++;
 
 		may_enter_fs = (sc->gfp_mask & __GFP_FS) ||
@@ -1110,6 +1112,14 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			; /* try to reclaim the page below */
 		}
 
+		/* lazyfree page could be freed directly */
+		if (lazyfree) {
+			if (unlikely(PageTransHuge(page)) &&
+			    split_huge_page_to_list(page, page_list))
+				goto keep_locked;
+			goto unmap_page;
+		}
+
 		/*
 		 * Anonymous process memory has backing store?
 		 * Try to allocate it some swap space here.
@@ -1119,7 +1129,6 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				goto keep_locked;
 			if (!add_to_swap(page, page_list))
 				goto activate_locked;
-			lazyfree = true;
 			may_enter_fs = 1;
 
 			/* Adding to swap updated mapping */
@@ -1130,13 +1139,14 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				goto keep_locked;
 		}
 
+unmap_page:
 		VM_BUG_ON_PAGE(PageTransHuge(page), page);
 
 		/*
 		 * The page is mapped into the page tables of one or more
 		 * processes. Try to unmap it here.
 		 */
-		if (page_mapped(page) && mapping) {
+		if (page_mapped(page) && (mapping || lazyfree)) {
 			switch (ret = try_to_unmap(page, lazyfree ?
 				(ttu_flags | TTU_BATCH_FLUSH | TTU_LZFREE) :
 				(ttu_flags | TTU_BATCH_FLUSH))) {
@@ -1148,7 +1158,13 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			case SWAP_MLOCK:
 				goto cull_mlocked;
 			case SWAP_LZFREE:
-				goto lazyfree;
+				if (page_ref_freeze(page, 1)) {
+					if (!PageDirty(page))
+						goto lazyfree;
+					else
+						page_ref_unfreeze(page, 1);
+				}
+				goto keep_locked;
 			case SWAP_SUCCESS:
 				; /* try to free the page below */
 			}
@@ -1260,10 +1276,10 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			}
 		}
 
-lazyfree:
 		if (!mapping || !__remove_mapping(mapping, page, true))
 			goto keep_locked;
 
+lazyfree:
 		/*
 		 * At this point, we have no other references and there is
 		 * no way to pick any more up (removed from LRU, removed
@@ -1288,6 +1304,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 cull_mlocked:
 		if (PageSwapCache(page))
 			try_to_free_swap(page);
+		if (lazyfree)
+			ClearPageLazyFree(page);
 		unlock_page(page);
 		list_add(&page->lru, &ret_pages);
 		continue;
@@ -1297,6 +1315,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		if (PageSwapCache(page) && mem_cgroup_swap_full(page))
 			try_to_free_swap(page);
 		VM_BUG_ON_PAGE(PageActive(page), page);
+		if (lazyfree)
+			ClearPageLazyFree(page);
 		SetPageActive(page);
 		pgactivate++;
 keep_locked:
@@ -1743,6 +1763,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 				     &nr_scanned, sc, isolate_mode, lru);
 
 	__mod_node_page_state(pgdat, lru_isolate_index(lru), nr_taken);
+	/* LAZYFREE pages will be charged into anon recent_scanned */
 	reclaim_stat->recent_scanned[file] += nr_taken;
 
 	if (global_reclaim(sc)) {
@@ -1830,7 +1851,8 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 		 * that pages are cycling through the LRU faster than
 		 * they are written so also forcibly stall.
 		 */
-		if (stat.nr_immediate && current_may_throttle())
+		if (stat.nr_immediate && current_may_throttle() &&
+		    lru != LRU_LAZYFREE)
 			congestion_wait(BLK_RW_ASYNC, HZ/10);
 	}
 
@@ -1840,7 +1862,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	 * unqueued dirty pages or cycling through the LRU too quickly.
 	 */
 	if (!sc->hibernation_mode && !current_is_kswapd() &&
-	    current_may_throttle())
+	    current_may_throttle() && lru != LRU_LAZYFREE)
 		wait_iff_congested(pgdat, BLK_RW_ASYNC, HZ/10);
 
 	trace_mm_vmscan_lru_shrink_inactive(pgdat->node_id,
@@ -2342,6 +2364,24 @@ static void shrink_node_memcg(struct pglist_data *pgdat, struct mem_cgroup *memc
 	struct blk_plug plug;
 	bool scan_adjusted;
 
+	/* reclaim all lazyfree pages so don't apply priority  */
+	nr[LRU_LAZYFREE] = lruvec_lru_size(lruvec, LRU_LAZYFREE, sc->reclaim_idx);
+	while (nr[LRU_LAZYFREE]) {
+		nr_to_scan = min(nr[LRU_LAZYFREE], SWAP_CLUSTER_MAX);
+		nr[LRU_LAZYFREE] -= nr_to_scan;
+		nr_reclaimed += shrink_inactive_list(nr_to_scan, lruvec, sc,
+			LRU_LAZYFREE);
+
+		if (nr_reclaimed >= nr_to_reclaim)
+			break;
+		cond_resched();
+	}
+
+	if (nr_reclaimed >= nr_to_reclaim) {
+		sc->nr_reclaimed += nr_reclaimed;
+		return;
+	}
+
 	get_scan_count(lruvec, memcg, sc, nr, lru_pages);
 
 	/* Record the original scan target for proportional adjustments later */
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
