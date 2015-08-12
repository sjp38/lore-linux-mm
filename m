Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 3E63082F5F
	for <linux-mm@kvack.org>; Wed, 12 Aug 2015 06:45:45 -0400 (EDT)
Received: by wicja10 with SMTP id ja10so22024067wic.1
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 03:45:44 -0700 (PDT)
Received: from outbound-smtp01.blacknight.com (outbound-smtp01.blacknight.com. [81.17.249.7])
        by mx.google.com with ESMTPS id wd10si9797891wjc.201.2015.08.12.03.45.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 12 Aug 2015 03:45:37 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp01.blacknight.com (Postfix) with ESMTPS id D28E198FFC
	for <linux-mm@kvack.org>; Wed, 12 Aug 2015 10:45:36 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 03/10] mm, page_alloc: Remove unnecessary recalculations for dirty zone balancing
Date: Wed, 12 Aug 2015 11:45:28 +0100
Message-Id: <1439376335-17895-4-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1439376335-17895-1-git-send-email-mgorman@techsingularity.net>
References: <1439376335-17895-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

File-backed pages that will be immediately are balanced between zones but
it's unnecessarily expensive. Move consider_zone_balanced into the alloc_context
instead of checking bitmaps multiple times. The patch also gives the parameter
a more meaningful name.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: David Rientjes <rientjes@google.com>
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
index 5e1f6f4370bc..94f2f6bdd6d5 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2297,8 +2297,6 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 	struct zoneref *z;
 	struct page *page = NULL;
 	struct zone *zone;
-	bool consider_zone_dirty = (alloc_flags & ALLOC_WMARK_LOW) &&
-				(gfp_mask & __GFP_WRITE);
 	int nr_fair_skipped = 0;
 	bool zonelist_rescan;
 
@@ -2350,14 +2348,14 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
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
@@ -2997,6 +2995,10 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 
 	/* We set it here, as __alloc_pages_slowpath might have changed it */
 	ac.zonelist = zonelist;
+
+	/* Dirty zone balancing only done in the fast path */
+	ac.spread_dirty_pages = (gfp_mask & __GFP_WRITE);
+
 	/* The preferred zone is used for statistics later */
 	preferred_zoneref = first_zones_zonelist(ac.zonelist, ac.high_zoneidx,
 				ac.nodemask, &ac.preferred_zone);
@@ -3014,6 +3016,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
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
