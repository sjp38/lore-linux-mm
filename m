Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f180.google.com (mail-ea0-f180.google.com [209.85.215.180])
	by kanga.kvack.org (Postfix) with ESMTP id 06A7A6B0037
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 14:42:08 -0500 (EST)
Received: by mail-ea0-f180.google.com with SMTP id f15so44777eak.25
        for <linux-mm@kvack.org>; Wed, 18 Dec 2013 11:42:08 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j47si1409066eeo.179.2013.12.18.11.42.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 18 Dec 2013 11:42:08 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 3/6] mm: page_alloc: Break out zone page aging distribution into its own helper
Date: Wed, 18 Dec 2013 19:42:00 +0000
Message-Id: <1387395723-25391-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1387395723-25391-1-git-send-email-mgorman@suse.de>
References: <1387395723-25391-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

This patch moves the decision on whether to round-robin allocations between
zones and nodes into its own helper functions. It'll make some later patches
easier to understand and it will be automatically inlined.

Cc: <stable@kernel.org> # 3.12
Signed-off-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Rik van Riel <riel@redhat.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/page_alloc.c | 63 ++++++++++++++++++++++++++++++++++++++-------------------
 1 file changed, 42 insertions(+), 21 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 61e9e8c..2cd694c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1880,6 +1880,42 @@ static inline void init_zone_allows_reclaim(int nid)
 #endif	/* CONFIG_NUMA */
 
 /*
+ * Distribute pages in proportion to the individual zone size to ensure fair
+ * page aging.  The zone a page was allocated in should have no effect on the
+ * time the page has in memory before being reclaimed.
+ * 
+ * Returns true if this zone should be skipped to spread the page ages to
+ * other zones.
+ */
+static bool zone_distribute_age(gfp_t gfp_mask, struct zone *preferred_zone,
+				struct zone *zone, int alloc_flags)
+{
+	/* Only round robin in the allocator fast path */
+	if (!(alloc_flags & ALLOC_WMARK_LOW))
+		return false;
+
+	/* Only round robin pages likely to be LRU or reclaimable slab */
+	if (!(gfp_mask & GFP_MOVABLE_MASK))
+		return false;
+
+	/* Distribute to the next zone if this zone has exhausted its batch */
+	if (zone_page_state(zone, NR_ALLOC_BATCH) <= 0)
+		return true;
+
+	/*
+	 * When zone_reclaim_mode is enabled, try to stay in local zones in the
+	 * fastpath.  If that fails, the slowpath is entered, which will do
+	 * another pass starting with the local zones, but ultimately fall back
+	 * back to remote zones that do not partake in the fairness round-robin
+	 * cycle of this zonelist.
+	 */
+	if (zone_reclaim_mode && !zone_local(preferred_zone, zone))
+		return true;
+
+	return false;
+}
+
+/*
  * get_page_from_freelist goes through the zonelist trying to allocate
  * a page.
  */
@@ -1915,27 +1951,12 @@ zonelist_scan:
 		BUILD_BUG_ON(ALLOC_NO_WATERMARKS < NR_WMARK);
 		if (unlikely(alloc_flags & ALLOC_NO_WATERMARKS))
 			goto try_this_zone;
-		/*
-		 * Distribute pages in proportion to the individual
-		 * zone size to ensure fair page aging.  The zone a
-		 * page was allocated in should have no effect on the
-		 * time the page has in memory before being reclaimed.
-		 *
-		 * When zone_reclaim_mode is enabled, try to stay in
-		 * local zones in the fastpath.  If that fails, the
-		 * slowpath is entered, which will do another pass
-		 * starting with the local zones, but ultimately fall
-		 * back to remote zones that do not partake in the
-		 * fairness round-robin cycle of this zonelist.
-		 */
-		if ((alloc_flags & ALLOC_WMARK_LOW) &&
-		    (gfp_mask & GFP_MOVABLE_MASK)) {
-			if (zone_page_state(zone, NR_ALLOC_BATCH) <= 0)
-				continue;
-			if (zone_reclaim_mode &&
-			    !zone_local(preferred_zone, zone))
-				continue;
-		}
+
+		/* Distribute pages to ensure fair page aging */
+		if (zone_distribute_age(gfp_mask, preferred_zone, zone,
+					alloc_flags))
+			continue;
+
 		/*
 		 * When allocating a page cache page for writing, we
 		 * want to get it from a zone that is within its dirty
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
