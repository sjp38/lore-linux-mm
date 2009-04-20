Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 004FD5F0001
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 16:25:49 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 3/3][rfc] vmscan: batched swap slot allocation
Date: Mon, 20 Apr 2009 22:24:45 +0200
Message-Id: <1240259085-25872-3-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1240259085-25872-1-git-send-email-hannes@cmpxchg.org>
References: <1240259085-25872-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Every swap slot allocation tries to be subsequent to the previous one
to help keeping the LRU order of anon pages intact when they are
swapped out.

With an increasing number of concurrent reclaimers, the average
distance between two subsequent slot allocations of one reclaimer
increases as well.  The contiguous LRU list chunks each reclaimer
swaps out get 'multiplexed' on the swap space as they allocate the
slots concurrently.

	2 processes isolating 15 pages each and allocating swap slots
	concurrently:

	#0			#1

	page 0 slot 0		page 15 slot 1
	page 1 slot 2		page 16 slot 3
	page 2 slot 4		page 17 slot 5
	...

	-> average slot distance of 2

All reclaimers being equally fast, this becomes a problem when the
total number of concurrent reclaimers gets so high that even equal
distribution makes the average distance between the slots of one
reclaimer too wide for optimistic swap-in to compensate.

But right now, one reclaimer can take much longer than another one
because its pages are mapped into more page tables and it has thus
more work to do and the faster reclaimer will allocate multiple swap
slots between two slot allocations of the slower one.

This patch makes shrink_page_list() allocate swap slots in batches,
collecting all the anonymous memory pages in a list without
rescheduling and actual reclaim in between.  And only after all anon
pages are swap cached, unmap and write-out starts for them.

While this does not fix the fundamental issue of slot distribution
increasing with reclaimers, it mitigates the problem by balancing the
resulting fragmentation equally between the allocators.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Hugh Dickins <hugh@veritas.com>
---
 mm/vmscan.c |   49 +++++++++++++++++++++++++++++++++++++++++--------
 1 files changed, 41 insertions(+), 8 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 70092fa..b3823fe 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -592,24 +592,42 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 					enum pageout_io sync_writeback)
 {
 	LIST_HEAD(ret_pages);
+	LIST_HEAD(swap_pages);
 	struct pagevec freed_pvec;
-	int pgactivate = 0;
+	int pgactivate = 0, restart = 0;
 	unsigned long nr_reclaimed = 0;
 
 	cond_resched();
 
 	pagevec_init(&freed_pvec, 1);
+restart:
 	while (!list_empty(page_list)) {
 		struct address_space *mapping;
 		struct page *page;
 		int may_enter_fs;
 		int referenced;
 
-		cond_resched();
+		if (list_empty(&swap_pages))
+			cond_resched();
 
 		page = lru_to_page(page_list);
 		list_del(&page->lru);
 
+		if (restart) {
+			/*
+			 * We are allowed to do IO when we restart for
+			 * swap pages.
+			 */
+			may_enter_fs = 1;
+			/*
+			 * Referenced pages will be sorted out by
+			 * try_to_unmap() and unmapped (anon!) pages
+			 * are not to be referenced anymore.
+			 */
+			referenced = 0;
+			goto reclaim;
+		}
+
 		if (!trylock_page(page))
 			goto keep;
 
@@ -655,14 +673,24 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		 * Anonymous process memory has backing store?
 		 * Try to allocate it some swap space here.
 		 */
-		if (PageAnon(page) && !PageSwapCache(page)) {
-			if (!(sc->gfp_mask & __GFP_IO))
-				goto keep_locked;
-			if (!add_to_swap(page))
-				goto activate_locked;
-			may_enter_fs = 1;
+		if (PageAnon(page)) {
+			if (!PageSwapCache(page)) {
+				if (!(sc->gfp_mask & __GFP_IO))
+					goto keep_locked;
+				if (!add_to_swap(page))
+					goto activate_locked;
+			} else if (!may_enter_fs)
+				/*
+				 * It's no use to batch when we are
+				 * not allocating swap for this GFP
+				 * mask.
+				 */
+				goto reclaim;
+			list_add(&page->lru, &swap_pages);
+			continue;
 		}
 
+	reclaim:
 		mapping = page_mapping(page);
 
 		/*
@@ -794,6 +822,11 @@ keep:
 		list_add(&page->lru, &ret_pages);
 		VM_BUG_ON(PageLRU(page) || PageUnevictable(page));
 	}
+	if (!list_empty(&swap_pages)) {
+		list_splice_init(&swap_pages, page_list);
+		restart = 1;
+		goto restart;
+	}
 	list_splice(&ret_pages, page_list);
 	if (pagevec_count(&freed_pvec))
 		__pagevec_free(&freed_pvec);
-- 
1.6.2.1.135.gde769

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
