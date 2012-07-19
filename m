Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 17C4D6B009B
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 10:37:05 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 28/34] mm/vmscan.c: consider swap space when deciding whether to continue reclaim
Date: Thu, 19 Jul 2012 15:36:38 +0100
Message-Id: <1342708604-26540-29-git-send-email-mgorman@suse.de>
In-Reply-To: <1342708604-26540-1-git-send-email-mgorman@suse.de>
References: <1342708604-26540-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stable <stable@vger.kernel.org>
Cc: "Linux-MM <linux-mm"@kvack.org, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: Minchan Kim <minchan@kernel.org>

commit 86cfd3a45042ab242d47f3935a02811a402beab6 upstream.

Stable note: Not tracked in Bugzilla. This patch reduces kswapd CPU
	usage on swapless systems with high anonymous memory usage.

It's pointless to continue reclaiming when we have no swap space and lots
of anon pages in the inactive list.

Without this patch, it is possible when swap is disabled to continue
trying to reclaim when there are only anonymous pages in the system even
though that will not make any progress.

Signed-off-by: Minchan Kim <minchan@kernel.org>
Acked-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Rik van Riel <riel@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Johannes Weiner <jweiner@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/vmscan.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 8b98a75..da195c2 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2008,8 +2008,9 @@ static inline bool should_continue_reclaim(struct zone *zone,
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
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
