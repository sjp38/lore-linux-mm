Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 1FCF06007F6
	for <linux-mm@kvack.org>; Mon, 19 Jul 2010 09:11:41 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 8/8] vmscan: Kick flusher threads to clean pages when reclaim is encountering dirty pages
Date: Mon, 19 Jul 2010 14:11:30 +0100
Message-Id: <1279545090-19169-9-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1279545090-19169-1-git-send-email-mel@csn.ul.ie>
References: <1279545090-19169-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

There are a number of cases where pages get cleaned but two of concern
to this patch are;
  o When dirtying pages, processes may be throttled to clean pages if
    dirty_ratio is not met.
  o Pages belonging to inodes dirtied longer than
    dirty_writeback_centisecs get cleaned.

The problem for reclaim is that dirty pages can reach the end of the LRU
if pages are being dirtied slowly so that neither the throttling cleans
them or a flusher thread waking periodically.

Background flush is already cleaning old or expired inodes first but the
expire time is too far in the future at the time of page reclaim. To mitigate
future problems, this patch wakes flusher threads to clean 1.5 times the
number of dirty pages encountered by reclaimers. The reasoning is that pages
were being dirtied at a roughly constant rate recently so if N dirty pages
were encountered in this scan block, we are likely to see roughly N dirty
pages again soon so try keep the flusher threads ahead of reclaim.

This is unfortunately very hand-wavy but there is not really a good way of
quantifying how bad it is when reclaim encounters dirty pages other than
"down with that sort of thing". Similarly, there is not an obvious way of
figuring how what percentage of dirty pages are old in terms of LRU-age and
should be cleaned. Ideally, the background flushers would only be cleaning
pages belonging to the zone being scanned but it's not clear if this would
be of benefit (less IO) or not (potentially less efficient IO if an inode
is scattered across multiple zones).

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/vmscan.c |   18 +++++++++++-------
 1 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index bc50937..5763719 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -806,6 +806,8 @@ restart_dirty:
 		}
 
 		if (PageDirty(page))  {
+			nr_dirty++;
+
 			/*
 			 * If the caller cannot writeback pages, dirty pages
 			 * are put on a separate list for cleaning by either
@@ -814,7 +816,6 @@ restart_dirty:
 			if (!reclaim_can_writeback(sc, page)) {
 				list_add(&page->lru, &dirty_pages);
 				unlock_page(page);
-				nr_dirty++;
 				goto keep_dirty;
 			}
 
@@ -933,13 +934,16 @@ keep_dirty:
 		VM_BUG_ON(PageLRU(page) || PageUnevictable(page));
 	}
 
+	/*
+	 * If reclaim is encountering dirty pages, it may be because
+	 * dirty pages are reaching the end of the LRU even though
+	 * the dirty_ratio may be satisified. In this case, wake
+	 * flusher threads to pro-actively clean some pages
+	 */
+	wakeup_flusher_threads(laptop_mode ? 0 : nr_dirty + nr_dirty / 2);
+
 	if (dirty_isolated < MAX_SWAP_CLEAN_WAIT && !list_empty(&dirty_pages)) {
-		/*
-		 * Wakeup a flusher thread to clean at least as many dirty
-		 * pages as encountered by direct reclaim. Wait on congestion
-		 * to throttle processes cleaning dirty pages
-		 */
-		wakeup_flusher_threads(nr_dirty);
+		/* Throttle direct reclaimers cleaning pages */
 		congestion_wait(BLK_RW_ASYNC, HZ/10);
 
 		/*
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
