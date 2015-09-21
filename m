Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 064296B0257
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 06:52:48 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so105573400wic.1
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 03:52:47 -0700 (PDT)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id wb9si16273962wic.53.2015.09.21.03.52.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 21 Sep 2015 03:52:44 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id 9D1772F804C
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 10:52:43 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 02/10] mm, page_alloc: Remove unnecessary recalculations for dirty zone balancing
Date: Mon, 21 Sep 2015 11:52:34 +0100
Message-Id: <1442832762-7247-3-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1442832762-7247-1-git-send-email-mgorman@techsingularity.net>
References: <1442832762-7247-1-git-send-email-mgorman@techsingularity.net>
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
index bc0fa9a69e46..83fb0bfffc13 100644
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
index 7a3199313622..4793bddb6b2a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2478,8 +2478,6 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 	nodemask_t *allowednodes = NULL;/* zonelist_cache approximation */
 	int zlc_active = 0;		/* set if using zonelist_cache */
 	int did_zlc_setup = 0;		/* just call zlc_setup() one time */
-	bool consider_zone_dirty = (alloc_flags & ALLOC_WMARK_LOW) &&
-				(gfp_mask & __GFP_WRITE);
 	int nr_fair_skipped = 0;
 	bool zonelist_rescan;
 
@@ -2534,14 +2532,14 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
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
@@ -3232,6 +3230,10 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 
 	/* We set it here, as __alloc_pages_slowpath might have changed it */
 	ac.zonelist = zonelist;
+
+	/* Dirty zone balancing only done in the fast path */
+	ac.spread_dirty_pages = (gfp_mask & __GFP_WRITE);
+
 	/* The preferred zone is used for statistics later */
 	preferred_zoneref = first_zones_zonelist(ac.zonelist, ac.high_zoneidx,
 				ac.nodemask ? : &cpuset_current_mems_allowed,
@@ -3250,6 +3252,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
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
