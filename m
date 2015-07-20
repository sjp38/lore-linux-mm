Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id C038B9003C7
	for <linux-mm@kvack.org>; Mon, 20 Jul 2015 04:00:30 -0400 (EDT)
Received: by wgmn9 with SMTP id n9so124042844wgm.0
        for <linux-mm@kvack.org>; Mon, 20 Jul 2015 01:00:30 -0700 (PDT)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id h2si33778629wjx.174.2015.07.20.01.00.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 20 Jul 2015 01:00:23 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id 3176C98B8F
	for <linux-mm@kvack.org>; Mon, 20 Jul 2015 08:00:22 +0000 (UTC)
From: Mel Gorman <mgorman@suse.com>
Subject: [PATCH 03/10] mm, page_alloc: Remove unnecessary recalculations for dirty zone balancing
Date: Mon, 20 Jul 2015 09:00:12 +0100
Message-Id: <1437379219-9160-4-git-send-email-mgorman@suse.com>
In-Reply-To: <1437379219-9160-1-git-send-email-mgorman@suse.com>
References: <1437379219-9160-1-git-send-email-mgorman@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Pintu Kumar <pintu.k@samsung.com>, Xishi Qiu <qiuxishi@huawei.com>, Gioh Kim <gioh.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

From: Mel Gorman <mgorman@suse.de>

File-backed pages that will be immediately dirtied are balanced between
zones but it's unnecessarily expensive. Move consider_zone_balanced into
the alloc_context instead of checking bitmaps multiple times.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/internal.h   | 1 +
 mm/page_alloc.c | 9 ++++++---
 2 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index 36b23f1e2ca6..8977348fbeec 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -129,6 +129,7 @@ struct alloc_context {
 	int classzone_idx;
 	int migratetype;
 	enum zone_type high_zoneidx;
+	bool consider_zone_dirty;
 };
 
 /*
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4b35b196aeda..7c2dc022f4ba 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2295,8 +2295,6 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 	struct zoneref *z;
 	struct page *page = NULL;
 	struct zone *zone;
-	bool consider_zone_dirty = (alloc_flags & ALLOC_WMARK_LOW) &&
-				(gfp_mask & __GFP_WRITE);
 	int nr_fair_skipped = 0;
 	bool zonelist_rescan;
 
@@ -2355,7 +2353,7 @@ zonelist_scan:
 		 * will require awareness of zones in the
 		 * dirty-throttling and the flusher threads.
 		 */
-		if (consider_zone_dirty && !zone_dirty_ok(zone))
+		if (ac->consider_zone_dirty && !zone_dirty_ok(zone))
 			continue;
 
 		mark = zone->watermark[alloc_flags & ALLOC_WMARK_MASK];
@@ -2995,6 +2993,10 @@ retry_cpuset:
 
 	/* We set it here, as __alloc_pages_slowpath might have changed it */
 	ac.zonelist = zonelist;
+
+	/* Dirty zone balancing only done in the fast path */
+	ac.consider_zone_dirty = (gfp_mask & __GFP_WRITE);
+
 	/* The preferred zone is used for statistics later */
 	preferred_zoneref = first_zones_zonelist(ac.zonelist, ac.high_zoneidx,
 				ac.nodemask, &ac.preferred_zone);
@@ -3012,6 +3014,7 @@ retry_cpuset:
 		 * complete.
 		 */
 		alloc_mask = memalloc_noio_flags(gfp_mask);
+		ac.consider_zone_dirty = false;
 
 		page = __alloc_pages_slowpath(alloc_mask, order, &ac);
 	}
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
