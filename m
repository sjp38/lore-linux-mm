Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3B0FE6B0260
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 10:39:10 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id gt1so27276805wjc.0
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 07:39:10 -0800 (PST)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id p53si19228386wrc.200.2017.01.23.07.39.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jan 2017 07:39:08 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id 779EA1C17E7
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 15:39:07 +0000 (GMT)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 2/4] mm, page_alloc: Split alloc_pages_nodemask
Date: Mon, 23 Jan 2017 15:39:04 +0000
Message-Id: <20170123153906.3122-3-mgorman@techsingularity.net>
In-Reply-To: <20170123153906.3122-1-mgorman@techsingularity.net>
References: <20170123153906.3122-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Vlastimil Babka <vbabka@suse.cz>, Hillf Danton <hillf.zj@alibaba-inc.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Mel Gorman <mgorman@techsingularity.net>

alloc_pages_nodemask does a number of preperation steps that determine
what zones can be used for the allocation depending on a variety of
factors. This is fine but a hypothetical caller that wanted multiple
order-0 pages has to do the preparation steps multiple times. This patch
structures __alloc_pages_nodemask such that it's relatively easy to build
a bulk order-0 page allocator. There is no functional change.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>
---
 mm/page_alloc.c | 75 +++++++++++++++++++++++++++++++++++----------------------
 1 file changed, 46 insertions(+), 29 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c075831c3a1a..dd2ded8b416f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3854,60 +3854,77 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	return page;
 }
 
-/*
- * This is the 'heart' of the zoned buddy allocator.
- */
-struct page *
-__alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
-			struct zonelist *zonelist, nodemask_t *nodemask)
+static inline bool prepare_alloc_pages(gfp_t gfp_mask, unsigned int order,
+		struct zonelist *zonelist, nodemask_t *nodemask,
+		struct alloc_context *ac, gfp_t *alloc_mask,
+		unsigned int *alloc_flags)
 {
-	struct page *page;
-	unsigned int alloc_flags = ALLOC_WMARK_LOW;
-	gfp_t alloc_mask = gfp_mask; /* The gfp_t that was actually used for allocation */
-	struct alloc_context ac = {
-		.high_zoneidx = gfp_zone(gfp_mask),
-		.zonelist = zonelist,
-		.nodemask = nodemask,
-		.migratetype = gfpflags_to_migratetype(gfp_mask),
-	};
+	ac->high_zoneidx = gfp_zone(gfp_mask);
+	ac->zonelist = zonelist;
+	ac->nodemask = nodemask;
+	ac->migratetype = gfpflags_to_migratetype(gfp_mask);
 
 	if (cpusets_enabled()) {
-		alloc_mask |= __GFP_HARDWALL;
-		alloc_flags |= ALLOC_CPUSET;
-		if (!ac.nodemask)
-			ac.nodemask = &cpuset_current_mems_allowed;
+		*alloc_mask |= __GFP_HARDWALL;
+		*alloc_flags |= ALLOC_CPUSET;
+		if (!ac->nodemask)
+			ac->nodemask = &cpuset_current_mems_allowed;
 	}
 
-	gfp_mask &= gfp_allowed_mask;
-
 	lockdep_trace_alloc(gfp_mask);
 
 	might_sleep_if(gfp_mask & __GFP_DIRECT_RECLAIM);
 
 	if (should_fail_alloc_page(gfp_mask, order))
-		return NULL;
+		return false;
 
 	/*
 	 * Check the zones suitable for the gfp_mask contain at least one
 	 * valid zone. It's possible to have an empty zonelist as a result
 	 * of __GFP_THISNODE and a memoryless node
 	 */
-	if (unlikely(!zonelist->_zonerefs->zone))
-		return NULL;
+	if (unlikely(!ac->zonelist->_zonerefs->zone))
+		return false;
 
-	if (IS_ENABLED(CONFIG_CMA) && ac.migratetype == MIGRATE_MOVABLE)
-		alloc_flags |= ALLOC_CMA;
+	if (IS_ENABLED(CONFIG_CMA) && ac->migratetype == MIGRATE_MOVABLE)
+		*alloc_flags |= ALLOC_CMA;
+
+	return true;
+}
 
+/* Determine whether to spread dirty pages and what the first usable zone */
+static inline void finalise_ac(gfp_t gfp_mask,
+		unsigned int order, struct alloc_context *ac)
+{
 	/* Dirty zone balancing only done in the fast path */
-	ac.spread_dirty_pages = (gfp_mask & __GFP_WRITE);
+	ac->spread_dirty_pages = (gfp_mask & __GFP_WRITE);
 
 	/*
 	 * The preferred zone is used for statistics but crucially it is
 	 * also used as the starting point for the zonelist iterator. It
 	 * may get reset for allocations that ignore memory policies.
 	 */
-	ac.preferred_zoneref = first_zones_zonelist(ac.zonelist,
-					ac.high_zoneidx, ac.nodemask);
+	ac->preferred_zoneref = first_zones_zonelist(ac->zonelist,
+					ac->high_zoneidx, ac->nodemask);
+}
+
+/*
+ * This is the 'heart' of the zoned buddy allocator.
+ */
+struct page *
+__alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
+			struct zonelist *zonelist, nodemask_t *nodemask)
+{
+	struct page *page;
+	unsigned int alloc_flags = ALLOC_WMARK_LOW;
+	gfp_t alloc_mask = gfp_mask; /* The gfp_t that was actually used for allocation */
+	struct alloc_context ac = { };
+
+	gfp_mask &= gfp_allowed_mask;
+	if (!prepare_alloc_pages(gfp_mask, order, zonelist, nodemask, &ac, &alloc_mask, &alloc_flags))
+		return NULL;
+
+	finalise_ac(gfp_mask, order, &ac);
 	if (!ac.preferred_zoneref->zone) {
 		page = NULL;
 		/*
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
