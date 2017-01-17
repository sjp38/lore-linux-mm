Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5E9336B0253
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 04:29:57 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id jz4so15775248wjb.5
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 01:29:57 -0800 (PST)
Received: from outbound-smtp06.blacknight.com (outbound-smtp06.blacknight.com. [81.17.249.39])
        by mx.google.com with ESMTPS id k3si24406532wrk.55.2017.01.17.01.29.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 Jan 2017 01:29:56 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp06.blacknight.com (Postfix) with ESMTPS id B507998863
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 09:29:55 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 2/4] mm, page_alloc: Split alloc_pages_nodemask
Date: Tue, 17 Jan 2017 09:29:52 +0000
Message-Id: <20170117092954.15413-3-mgorman@techsingularity.net>
In-Reply-To: <20170117092954.15413-1-mgorman@techsingularity.net>
References: <20170117092954.15413-1-mgorman@techsingularity.net>
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
 mm/page_alloc.c | 81 ++++++++++++++++++++++++++++++++++-----------------------
 1 file changed, 49 insertions(+), 32 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0e8404e546f5..d15527a20dce 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3756,64 +3756,81 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
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
-	unsigned int cpuset_mems_cookie;
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
 
-retry_cpuset:
-	cpuset_mems_cookie = read_mems_allowed_begin();
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
+	unsigned int cpuset_mems_cookie;
+	unsigned int alloc_flags = ALLOC_WMARK_LOW;
+	gfp_t alloc_mask = gfp_mask; /* The gfp_t that was actually used for allocation */
+	struct alloc_context ac = { };
+
+	gfp_mask &= gfp_allowed_mask;
+	if (!prepare_alloc_pages(gfp_mask, order, zonelist, nodemask, &ac, &alloc_mask, &alloc_flags))
+		return NULL;
+
+retry_cpuset:
+	cpuset_mems_cookie = read_mems_allowed_begin();
+
+	finalise_ac(gfp_mask, order, &ac);
 	if (!ac.preferred_zoneref) {
 		page = NULL;
 		goto no_zone;
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
