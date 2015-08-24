Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id F32FC6B0254
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 08:09:54 -0400 (EDT)
Received: by wicja10 with SMTP id ja10so69951297wic.1
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 05:09:54 -0700 (PDT)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id pm7si31650303wjb.185.2015.08.24.05.09.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=RC4-SHA bits=128/128);
        Mon, 24 Aug 2015 05:09:53 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id 6E95798ED5
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 12:09:52 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 02/12] mm, page_alloc: Remove unnecessary recalculations for dirty zone balancing
Date: Mon, 24 Aug 2015 13:09:41 +0100
Message-Id: <1440418191-10894-3-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1440418191-10894-1-git-send-email-mgorman@techsingularity.net>
References: <1440418191-10894-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

File-backed pages that will be immediately written are balanced between
zones.  This heuristic tries to avoid having a single zone filled with
recently dirtied pages but the checks are unnecessarily expensive. Move
consider_zone_balanced into the alloc_context instead of checking bitmaps
multiple times. The patch also gives the parameter a more meaningful name.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: David Rientjes <rientjes@google.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/internal.h   |  1 +
 mm/page_alloc.c | 11 +++++++----
 2 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index 36b23f1e2ca6..9331f802a067 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -129,6 +129,7 @@ struct alloc_context {
 	int classzone_idx;
 	int migratetype;
 	enum zone_type high_zoneidx;
+	bool spread_dirty_pages;
 };
 
 /*
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 9b6bae688db8..62ae28d8ae8d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2453,8 +2453,6 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 	nodemask_t *allowednodes = NULL;/* zonelist_cache approximation */
 	int zlc_active = 0;		/* set if using zonelist_cache */
 	int did_zlc_setup = 0;		/* just call zlc_setup() one time */
-	bool consider_zone_dirty = (alloc_flags & ALLOC_WMARK_LOW) &&
-				(gfp_mask & __GFP_WRITE);
 	int nr_fair_skipped = 0;
 	bool zonelist_rescan;
 
@@ -2509,14 +2507,14 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 		 *
 		 * XXX: For now, allow allocations to potentially
 		 * exceed the per-zone dirty limit in the slowpath
-		 * (ALLOC_WMARK_LOW unset) before going into reclaim,
+		 * (spread_dirty_pages unset) before going into reclaim,
 		 * which is important when on a NUMA setup the allowed
 		 * zones are together not big enough to reach the
 		 * global limit.  The proper fix for these situations
 		 * will require awareness of zones in the
 		 * dirty-throttling and the flusher threads.
 		 */
-		if (consider_zone_dirty && !zone_dirty_ok(zone))
+		if (ac->spread_dirty_pages && !zone_dirty_ok(zone))
 			continue;
 
 		mark = zone->watermark[alloc_flags & ALLOC_WMARK_MASK];
@@ -3202,6 +3200,10 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 
 	/* We set it here, as __alloc_pages_slowpath might have changed it */
 	ac.zonelist = zonelist;
+
+	/* Dirty zone balancing only done in the fast path */
+	ac.spread_dirty_pages = (gfp_mask & __GFP_WRITE);
+
 	/* The preferred zone is used for statistics later */
 	preferred_zoneref = first_zones_zonelist(ac.zonelist, ac.high_zoneidx,
 				ac.nodemask ? : &cpuset_current_mems_allowed,
@@ -3220,6 +3222,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 		 * complete.
 		 */
 		alloc_mask = memalloc_noio_flags(gfp_mask);
+		ac.spread_dirty_pages = false;
 
 		page = __alloc_pages_slowpath(alloc_mask, order, &ac);
 	}
-- 
2.4.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
