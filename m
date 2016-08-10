Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3B08F828F3
	for <linux-mm@kvack.org>; Wed, 10 Aug 2016 05:12:46 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 1so53009617wmz.2
        for <linux-mm@kvack.org>; Wed, 10 Aug 2016 02:12:46 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id jo1si29850273wjb.272.2016.08.10.02.12.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 10 Aug 2016 02:12:42 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v6 03/11] mm, compaction: rename COMPACT_PARTIAL to COMPACT_SUCCESS
Date: Wed, 10 Aug 2016 11:12:18 +0200
Message-Id: <20160810091226.6709-4-vbabka@suse.cz>
In-Reply-To: <20160810091226.6709-1-vbabka@suse.cz>
References: <20160810091226.6709-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>

COMPACT_PARTIAL has historically meant that compaction returned after doing
some work without fully compacting a zone. It however didn't distinguish if
compaction terminated because it succeeded in creating the requested high-order
page. This has changed recently and now we only return COMPACT_PARTIAL when
compaction thinks it succeeded, or the high-order watermark check in
compaction_suitable() passes and no compaction needs to be done.

So at this point we can make the return value clearer by renaming it to
COMPACT_SUCCESS. The next patch will remove some redundant tests for success
where compaction just returned COMPACT_SUCCESS.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/compaction.h        |  8 ++++----
 include/trace/events/compaction.h |  2 +-
 mm/compaction.c                   | 12 ++++++------
 mm/vmscan.c                       |  2 +-
 4 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index 1bb58581301c..e88c037afe47 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -49,10 +49,10 @@ enum compact_result {
 	COMPACT_CONTENDED,
 
 	/*
-	 * direct compaction partially compacted a zone and there might be
-	 * suitable pages
+	 * direct compaction terminated after concluding that the allocation
+	 * should now succeed
 	 */
-	COMPACT_PARTIAL,
+	COMPACT_SUCCESS,
 };
 
 struct alloc_context; /* in mm/internal.h */
@@ -88,7 +88,7 @@ static inline bool compaction_made_progress(enum compact_result result)
 	 * that the compaction successfully isolated and migrated some
 	 * pageblocks.
 	 */
-	if (result == COMPACT_PARTIAL)
+	if (result == COMPACT_SUCCESS)
 		return true;
 
 	return false;
diff --git a/include/trace/events/compaction.h b/include/trace/events/compaction.h
index c2ba402ab256..cbdb90b6b308 100644
--- a/include/trace/events/compaction.h
+++ b/include/trace/events/compaction.h
@@ -13,7 +13,7 @@
 	EM( COMPACT_SKIPPED,		"skipped")		\
 	EM( COMPACT_DEFERRED,		"deferred")		\
 	EM( COMPACT_CONTINUE,		"continue")		\
-	EM( COMPACT_PARTIAL,		"partial")		\
+	EM( COMPACT_SUCCESS,		"success")		\
 	EM( COMPACT_PARTIAL_SKIPPED,	"partial_skipped")	\
 	EM( COMPACT_COMPLETE,		"complete")		\
 	EM( COMPACT_NO_SUITABLE_PAGE,	"no_suitable_page")	\
diff --git a/mm/compaction.c b/mm/compaction.c
index 328bdfeece2d..c355bf0d8599 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1329,13 +1329,13 @@ static enum compact_result __compact_finished(struct zone *zone, struct compact_
 
 		/* Job done if page is free of the right migratetype */
 		if (!list_empty(&area->free_list[migratetype]))
-			return COMPACT_PARTIAL;
+			return COMPACT_SUCCESS;
 
 #ifdef CONFIG_CMA
 		/* MIGRATE_MOVABLE can fallback on MIGRATE_CMA */
 		if (migratetype == MIGRATE_MOVABLE &&
 			!list_empty(&area->free_list[MIGRATE_CMA]))
-			return COMPACT_PARTIAL;
+			return COMPACT_SUCCESS;
 #endif
 		/*
 		 * Job done if allocation would steal freepages from
@@ -1343,7 +1343,7 @@ static enum compact_result __compact_finished(struct zone *zone, struct compact_
 		 */
 		if (find_suitable_fallback(area, order, migratetype,
 						true, &can_steal) != -1)
-			return COMPACT_PARTIAL;
+			return COMPACT_SUCCESS;
 	}
 
 	return COMPACT_NO_SUITABLE_PAGE;
@@ -1367,7 +1367,7 @@ static enum compact_result compact_finished(struct zone *zone,
  * compaction_suitable: Is this suitable to run compaction on this zone now?
  * Returns
  *   COMPACT_SKIPPED  - If there are too few free pages for compaction
- *   COMPACT_PARTIAL  - If the allocation would succeed without compaction
+ *   COMPACT_SUCCESS  - If the allocation would succeed without compaction
  *   COMPACT_CONTINUE - If compaction should run now
  */
 static enum compact_result __compaction_suitable(struct zone *zone, int order,
@@ -1388,7 +1388,7 @@ static enum compact_result __compaction_suitable(struct zone *zone, int order,
 	 */
 	if (zone_watermark_ok(zone, order, watermark, classzone_idx,
 								alloc_flags))
-		return COMPACT_PARTIAL;
+		return COMPACT_SUCCESS;
 
 	/*
 	 * Watermarks for order-0 must be met for compaction. Note the 2UL.
@@ -1477,7 +1477,7 @@ static enum compact_result compact_zone(struct zone *zone, struct compact_contro
 	ret = compaction_suitable(zone, cc->order, cc->alloc_flags,
 							cc->classzone_idx);
 	/* Compaction is likely to fail */
-	if (ret == COMPACT_PARTIAL || ret == COMPACT_SKIPPED)
+	if (ret == COMPACT_SUCCESS || ret == COMPACT_SKIPPED)
 		return ret;
 
 	/* huh, compaction_suitable is returning something unexpected */
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 374d95d04178..c84784765d3a 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2514,7 +2514,7 @@ static inline bool should_continue_reclaim(struct pglist_data *pgdat,
 			continue;
 
 		switch (compaction_suitable(zone, sc->order, 0, sc->reclaim_idx)) {
-		case COMPACT_PARTIAL:
+		case COMPACT_SUCCESS:
 		case COMPACT_CONTINUE:
 			return false;
 		default:
-- 
2.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
