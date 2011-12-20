Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 8DD176B004D
	for <linux-mm@kvack.org>; Tue, 20 Dec 2011 01:47:49 -0500 (EST)
Received: by qcsd17 with SMTP id d17so4391017qcs.14
        for <linux-mm@kvack.org>; Mon, 19 Dec 2011 22:47:48 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH] consider swap space when we decide compaction goes or not
Date: Tue, 20 Dec 2011 15:47:33 +0900
Message-Id: <1324363653-18220-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan@kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>

It's pointless to go reclaiming when we have no swap space
and lots of anon pages in inactive list.

Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Johannes Weiner <jweiner@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/vmscan.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 23256e8..cd5400c 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2015,8 +2015,9 @@ static inline bool should_continue_reclaim(struct zone *zone,
 	 * inactive lists are large enough, continue reclaiming
 	 */
 	pages_for_compaction = (2UL << sc->order);
-	inactive_lru_pages = zone_nr_lru_pages(zone, sc, LRU_INACTIVE_ANON) +
-				zone_nr_lru_pages(zone, sc, LRU_INACTIVE_FILE);
+	inactive_lru_pages = zone_nr_lru_pages(zone, sc, LRU_INACTIVE_FILE);
+	if (nr_swap_pages > 0)
+		inactive_lru_pages += zone_nr_lru_pages(zone, sc, LRU_INACTIVE_ANON);
 	if (sc->nr_reclaimed < pages_for_compaction &&
 			inactive_lru_pages > pages_for_compaction)
 		return true;
-- 
1.7.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
