Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 793E06B0260
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 01:33:42 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 190so33210981pfv.0
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 22:33:42 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id qp8si6192715pac.89.2016.10.11.22.33.40
        for <linux-mm@kvack.org>;
        Tue, 11 Oct 2016 22:33:41 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v2 3/4] mm: try to exhaust highatomic reserve before the OOM
Date: Wed, 12 Oct 2016 14:33:35 +0900
Message-Id: <1476250416-22733-4-git-send-email-minchan@kernel.org>
In-Reply-To: <1476250416-22733-1-git-send-email-minchan@kernel.org>
References: <1476250416-22733-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sangseok Lee <sangseok.lee@lge.com>, Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan@kernel.org>

It's weird to show that zone has enough free memory above min
watermark but OOMed with 4K GFP_KERNEL allocation due to
reserved highatomic pages. As last resort, try to unreserve
highatomic pages again and if it has moved pages to
non-highatmoc free list, retry reclaim once more.

Signed-off-by: Michal Hocko <mhocko@suse.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/page_alloc.c | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 18808f392718..a7472426663f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2080,7 +2080,7 @@ static void reserve_highatomic_pageblock(struct page *page, struct zone *zone,
  * intense memory pressure but failed atomic allocations should be easier
  * to recover from than an OOM.
  */
-static void unreserve_highatomic_pageblock(const struct alloc_context *ac)
+static bool unreserve_highatomic_pageblock(const struct alloc_context *ac)
 {
 	struct zonelist *zonelist = ac->zonelist;
 	unsigned long flags;
@@ -2088,6 +2088,7 @@ static void unreserve_highatomic_pageblock(const struct alloc_context *ac)
 	struct zone *zone;
 	struct page *page;
 	int order;
+	bool ret = false;
 
 	for_each_zone_zonelist_nodemask(zone, z, zonelist, ac->high_zoneidx,
 								ac->nodemask) {
@@ -2136,12 +2137,14 @@ static void unreserve_highatomic_pageblock(const struct alloc_context *ac)
 			 * may increase.
 			 */
 			set_pageblock_migratetype(page, ac->migratetype);
-			move_freepages_block(zone, page, ac->migratetype);
+			ret = move_freepages_block(zone, page, ac->migratetype);
 			spin_unlock_irqrestore(&zone->lock, flags);
-			return;
+			return ret;
 		}
 		spin_unlock_irqrestore(&zone->lock, flags);
 	}
+
+	return ret;
 }
 
 /* Remove an element from the buddy allocator from the fallback list */
@@ -3457,8 +3460,12 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
 	 * Make sure we converge to OOM if we cannot make any progress
 	 * several times in the row.
 	 */
-	if (*no_progress_loops > MAX_RECLAIM_RETRIES)
+	if (*no_progress_loops > MAX_RECLAIM_RETRIES) {
+		/* Before OOM, exhaust highatomic_reserve */
+		if (unreserve_highatomic_pageblock(ac))
+			return true;
 		return false;
+	}
 
 	/*
 	 * Keep reclaiming pages while there is a chance this will lead
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
