Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 97DEF6B007E
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 05:09:39 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id a125so13153908wmd.0
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 02:09:39 -0700 (PDT)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id gg4si49500775wjb.79.2016.04.15.02.09.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 15 Apr 2016 02:09:38 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id 16704F42DC
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 09:09:38 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 22/28] mm, page_alloc: Remove field from alloc_context
Date: Fri, 15 Apr 2016 10:07:49 +0100
Message-Id: <1460711275-1130-10-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1460711275-1130-1-git-send-email-mgorman@techsingularity.net>
References: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
 <1460711275-1130-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

The classzone_idx can be inferred from preferred_zoneref so remove the
unnecessary field and save stack space.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/compaction.c | 4 ++--
 mm/internal.h   | 3 ++-
 mm/page_alloc.c | 7 +++----
 3 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 244bb669b5a6..c2fb3c61f1b6 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1536,7 +1536,7 @@ unsigned long try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
 
 		status = compact_zone_order(zone, order, gfp_mask, mode,
 				&zone_contended, alloc_flags,
-				ac->classzone_idx);
+				ac_classzone_idx(ac));
 		rc = max(status, rc);
 		/*
 		 * It takes at least one zone that wasn't lock contended
@@ -1546,7 +1546,7 @@ unsigned long try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
 
 		/* If a normal allocation would succeed, stop compacting */
 		if (zone_watermark_ok(zone, order, low_wmark_pages(zone),
-					ac->classzone_idx, alloc_flags)) {
+					ac_classzone_idx(ac), alloc_flags)) {
 			/*
 			 * We think the allocation will succeed in this zone,
 			 * but it is not certain, hence the false. The caller
diff --git a/mm/internal.h b/mm/internal.h
index 4c2396cd514c..3bf62e085b16 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -103,12 +103,13 @@ struct alloc_context {
 	struct zonelist *zonelist;
 	nodemask_t *nodemask;
 	struct zoneref *preferred_zoneref;
-	int classzone_idx;
 	int migratetype;
 	enum zone_type high_zoneidx;
 	bool spread_dirty_pages;
 };
 
+#define ac_classzone_idx(ac) zonelist_zone_idx(ac->preferred_zoneref)
+
 /*
  * Locate the struct page for both the matching buddy in our
  * pair (buddy1) and the combined O(n+1) page they form (page).
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 897e9d2a8500..bc754d32aed6 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2767,7 +2767,7 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 
 		mark = zone->watermark[alloc_flags & ALLOC_WMARK_MASK];
 		if (!zone_watermark_fast(zone, order, mark,
-				       ac->classzone_idx, alloc_flags)) {
+				       ac_classzone_idx(ac), alloc_flags)) {
 			int ret;
 
 			/* Checked here to keep the fast path fast */
@@ -2790,7 +2790,7 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 			default:
 				/* did we reclaim enough */
 				if (zone_watermark_ok(zone, order, mark,
-						ac->classzone_idx, alloc_flags))
+						ac_classzone_idx(ac), alloc_flags))
 					goto try_this_zone;
 
 				continue;
@@ -3114,7 +3114,7 @@ static void wake_all_kswapds(unsigned int order, const struct alloc_context *ac)
 
 	for_each_zone_zonelist_nodemask(zone, z, ac->zonelist,
 						ac->high_zoneidx, ac->nodemask)
-		wakeup_kswapd(zone, order, zonelist_zone_idx(ac->preferred_zoneref));
+		wakeup_kswapd(zone, order, ac_classzone_idx(ac));
 }
 
 static inline unsigned int
@@ -3409,7 +3409,6 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	/* The preferred zone is used for statistics later */
 	ac.preferred_zoneref = first_zones_zonelist(ac.zonelist, ac.high_zoneidx,
 				ac.nodemask);
-	ac.classzone_idx = zonelist_zone_idx(ac.preferred_zoneref);
 
 	/* First allocation attempt */
 	page = get_page_from_freelist(alloc_mask, order, alloc_flags, &ac);
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
