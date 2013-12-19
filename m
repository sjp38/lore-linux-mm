Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f46.google.com (mail-bk0-f46.google.com [209.85.214.46])
	by kanga.kvack.org (Postfix) with ESMTP id C2B9B6B0037
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 10:42:11 -0500 (EST)
Received: by mail-bk0-f46.google.com with SMTP id u15so767656bkz.33
        for <linux-mm@kvack.org>; Thu, 19 Dec 2013 07:42:11 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id xy9si1568114bkb.222.2013.12.19.07.42.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 19 Dec 2013 07:42:10 -0800 (PST)
Date: Thu, 19 Dec 2013 10:41:57 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 15/24] mm: page_alloc: exclude unreclaimable allocations
 from zone fairness policy
Message-ID: <20131219154157.GN21724@cmpxchg.org>
References: <20131219010847.E56B731C2B8@corp2gmr1-1.hot.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131219010847.E56B731C2B8@corp2gmr1-1.hot.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: torvalds@linux-foundation.org, dave.hansen@intel.com, mgorman@suse.de, riel@redhat.com, stable@kernel.org, mhocko@suse.cz, linux-mm@kvack.org

On Wed, Dec 18, 2013 at 05:08:47PM -0800, akpm@linux-foundation.org wrote:
> From: Johannes Weiner <hannes@cmpxchg.org>
> Subject: mm: page_alloc: exclude unreclaimable allocations from zone fairness policy
> 
> Dave Hansen noted a regression in a microbenchmark that loops around
> open() and close() on an 8-node NUMA machine and bisected it down to
> 81c0a2bb515f ("mm: page_alloc: fair zone allocator policy").  That change
> forces the slab allocations of the file descriptor to spread out to all 8
> nodes, causing remote references in the page allocator and slab.
> 
> The round-robin policy is only there to provide fairness among memory
> allocations that are reclaimed involuntarily based on pressure in each
> zone.  It does not make sense to apply it to unreclaimable kernel
> allocations that are freed manually, in this case instantly after the
> allocation, and incur the remote reference costs twice for no reason.
> 
> Only round-robin allocations that are usually freed through page reclaim
> or slab shrinking.
> 
> Bisected by Dave Hansen.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Dave Hansen <dave.hansen@intel.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Reviewed-by: Rik van Riel <riel@redhat.com>
> Cc: <stable@kernel.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Linus, I did not see this patch show up in your tree yet, so if it's
not too late, please consider merging the following patch instead to
disable NUMA aspects of the fairness allocator entirely until we can
agree on how it should behave, how it should be configurable etc.:

---
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] mm: page_alloc: revert NUMA aspect of fair allocation policy

81c0a2bb ("mm: page_alloc: fair zone allocator policy") meant to bring
aging fairness among zones in system, but it was overzealous and badly
regressed basic workloads on NUMA systems.

Due to the way kswapd and page allocator interacts, we still want to
make sure that all zones in any given node are used equally for all
allocations to maximize memory utilization and prevent thrashing on
the highest zone in the node.

While the same principle applies to NUMA nodes - memory utilization is
obviously improved by spreading allocations throughout all nodes -
remote references can be costly and so many workloads prefer locality
over memory utilization.  The original change assumed that
zone_reclaim_mode would be a good enough predictor for that, but it
turned out to be as indicative as a coin flip.

Revert the NUMA aspect of the fairness until we can find a proper way
to make it configurable and agree on a sane default.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Reviewed-by: Michal Hocko <mhocko@suse.cz>
Acked-by: Mel Gorman <mgorman@suse.de>
Cc: <stable@kernel.org> # 3.12
---
 mm/page_alloc.c | 19 +++++++++----------
 1 file changed, 9 insertions(+), 10 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 580a5f075ed0..5248fe070aa4 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1816,7 +1816,7 @@ static void zlc_clear_zones_full(struct zonelist *zonelist)
 
 static bool zone_local(struct zone *local_zone, struct zone *zone)
 {
-	return node_distance(local_zone->node, zone->node) == LOCAL_DISTANCE;
+	return local_zone->node == zone->node;
 }
 
 static bool zone_allows_reclaim(struct zone *local_zone, struct zone *zone)
@@ -1913,18 +1913,17 @@ zonelist_scan:
 		 * page was allocated in should have no effect on the
 		 * time the page has in memory before being reclaimed.
 		 *
-		 * When zone_reclaim_mode is enabled, try to stay in
-		 * local zones in the fastpath.  If that fails, the
-		 * slowpath is entered, which will do another pass
-		 * starting with the local zones, but ultimately fall
-		 * back to remote zones that do not partake in the
-		 * fairness round-robin cycle of this zonelist.
+		 * Try to stay in local zones in the fastpath.  If
+		 * that fails, the slowpath is entered, which will do
+		 * another pass starting with the local zones, but
+		 * ultimately fall back to remote zones that do not
+		 * partake in the fairness round-robin cycle of this
+		 * zonelist.
 		 */
 		if (alloc_flags & ALLOC_WMARK_LOW) {
 			if (zone_page_state(zone, NR_ALLOC_BATCH) <= 0)
 				continue;
-			if (zone_reclaim_mode &&
-			    !zone_local(preferred_zone, zone))
+			if (!zone_local(preferred_zone, zone))
 				continue;
 		}
 		/*
@@ -2390,7 +2389,7 @@ static void prepare_slowpath(gfp_t gfp_mask, unsigned int order,
 		 * thrash fairness information for zones that are not
 		 * actually part of this zonelist's round-robin cycle.
 		 */
-		if (zone_reclaim_mode && !zone_local(preferred_zone, zone))
+		if (!zone_local(preferred_zone, zone))
 			continue;
 		mod_zone_page_state(zone, NR_ALLOC_BATCH,
 				    high_wmark_pages(zone) -
-- 
1.8.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
