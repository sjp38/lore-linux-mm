Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7A8DE6B007B
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 08:27:58 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 3/8] vmscan: Synchronous lumpy reclaim should not call congestion_wait()
Date: Wed, 15 Sep 2010 13:27:46 +0100
Message-Id: <1284553671-31574-4-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1284553671-31574-1-git-send-email-mel@csn.ul.ie>
References: <1284553671-31574-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Linux Kernel List <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

congestion_wait() mean "waiting queue congestion is cleared".  However,
synchronous lumpy reclaim does not need this congestion_wait() as
shrink_page_list(PAGEOUT_IO_SYNC) uses wait_on_page_writeback()
and it provides the necessary waiting.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>
Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/vmscan.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 652650f..e8b5224 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1341,8 +1341,6 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 
 	/* Check if we should syncronously wait for writeback */
 	if (should_reclaim_stall(nr_taken, nr_reclaimed, priority, sc)) {
-		congestion_wait(BLK_RW_ASYNC, HZ/10);
-
 		/*
 		 * The attempt at page out may have made some
 		 * of the pages active, mark them inactive again.
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
