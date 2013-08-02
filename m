Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 247E46B0032
	for <linux-mm@kvack.org>; Fri,  2 Aug 2013 11:37:52 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch v2 2/3] mm: page_alloc: rearrange watermark checking in get_page_from_freelist
Date: Fri,  2 Aug 2013 11:37:25 -0400
Message-Id: <1375457846-21521-3-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1375457846-21521-1-git-send-email-hannes@cmpxchg.org>
References: <1375457846-21521-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@surriel.com>, Andrea Arcangeli <aarcange@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Allocations that do not have to respect the watermarks are rare
high-priority events.  Reorder the code such that per-zone dirty
limits and future checks important only to regular page allocations
are ignored in these extraordinary situations.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Reviewed-by: Rik van Riel <riel@redhat.com>
---
 mm/page_alloc.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index bf9d7c1..3b27d3e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1889,12 +1889,17 @@ zonelist_scan:
 	 */
 	for_each_zone_zonelist_nodemask(zone, z, zonelist,
 						high_zoneidx, nodemask) {
+		unsigned long mark;
+
 		if (IS_ENABLED(CONFIG_NUMA) && zlc_active &&
 			!zlc_zone_worth_trying(zonelist, z, allowednodes))
 				continue;
 		if ((alloc_flags & ALLOC_CPUSET) &&
 			!cpuset_zone_allowed_softwall(zone, gfp_mask))
 				continue;
+		BUILD_BUG_ON(ALLOC_NO_WATERMARKS < NR_WMARK);
+		if (alloc_flags & ALLOC_NO_WATERMARKS)
+			goto try_this_zone;
 		/*
 		 * When allocating a page cache page for writing, we
 		 * want to get it from a zone that is within its dirty
@@ -1925,16 +1930,11 @@ zonelist_scan:
 		    (gfp_mask & __GFP_WRITE) && !zone_dirty_ok(zone))
 			goto this_zone_full;
 
-		BUILD_BUG_ON(ALLOC_NO_WATERMARKS < NR_WMARK);
-		if (!(alloc_flags & ALLOC_NO_WATERMARKS)) {
-			unsigned long mark;
+		mark = zone->watermark[alloc_flags & ALLOC_WMARK_MASK];
+		if (!zone_watermark_ok(zone, order, mark,
+				       classzone_idx, alloc_flags)) {
 			int ret;
 
-			mark = zone->watermark[alloc_flags & ALLOC_WMARK_MASK];
-			if (zone_watermark_ok(zone, order, mark,
-				    classzone_idx, alloc_flags))
-				goto try_this_zone;
-
 			if (IS_ENABLED(CONFIG_NUMA) &&
 					!did_zlc_setup && nr_online_nodes > 1) {
 				/*
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
