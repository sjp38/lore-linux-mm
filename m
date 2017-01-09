Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 353DB6B0261
	for <linux-mm@kvack.org>; Mon,  9 Jan 2017 11:35:21 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id p192so9953358wme.1
        for <linux-mm@kvack.org>; Mon, 09 Jan 2017 08:35:21 -0800 (PST)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id q9si96896045wjl.255.2017.01.09.08.35.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jan 2017 08:35:19 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id 495CE1C18A7
	for <linux-mm@kvack.org>; Mon,  9 Jan 2017 16:35:19 +0000 (GMT)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 2/4] mm, page_alloc: Split alloc_pages_nodemask
Date: Mon,  9 Jan 2017 16:35:16 +0000
Message-Id: <20170109163518.6001-3-mgorman@techsingularity.net>
In-Reply-To: <20170109163518.6001-1-mgorman@techsingularity.net>
References: <20170109163518.6001-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Mel Gorman <mgorman@techsingularity.net>

alloc_pages_nodemask does a number of preperation steps that determine
what zones can be used for the allocation depending on a variety of
factors. This is fine but a hypothetical caller that wanted multiple
order-0 pages has to do the preparation steps multiple times. This patch
structures __alloc_pages_nodemask such that it's relatively easy to build
a bulk order-0 page allocator. There is no functional change.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/page_alloc.c | 81 ++++++++++++++++++++++++++++++++++-----------------------
 1 file changed, 49 insertions(+), 32 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d8798583eaf8..4a602b7f258d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3762,64 +3762,81 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
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
