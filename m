Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 933F36B025F
	for <linux-mm@kvack.org>; Wed, 10 Aug 2016 05:12:43 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id l4so52864419wml.0
        for <linux-mm@kvack.org>; Wed, 10 Aug 2016 02:12:43 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b126si7129879wmg.72.2016.08.10.02.12.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 10 Aug 2016 02:12:42 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v6 01/11] mm, compaction: make whole_zone flag ignore cached scanner positions
Date: Wed, 10 Aug 2016 11:12:16 +0200
Message-Id: <20160810091226.6709-2-vbabka@suse.cz>
In-Reply-To: <20160810091226.6709-1-vbabka@suse.cz>
References: <20160810091226.6709-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>

A recent patch has added whole_zone flag that compaction sets when scanning
starts from the zone boundary, in order to report that zone has been fully
scanned in one attempt. For allocations that want to try really hard or cannot
fail, we will want to introduce a mode where scanning whole zone is guaranteed
regardless of the cached positions.

This patch reuses the whole_zone flag in a way that if it's already passed true
to compaction, the cached scanner positions are ignored. Employing this flag
during reclaim/compaction loop will be done in the next patch. This patch
however converts compaction invoked from userspace via procfs to use this flag.
Before this patch, the cached positions were first reset to zone boundaries and
then read back from struct zone, so there was a window where a parallel
compaction could replace the reset values, making the manual compaction less
effective. Using the flag instead of performing reset is more robust.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 mm/compaction.c | 43 +++++++++++++++++++++----------------------
 mm/internal.h   |  2 +-
 2 files changed, 22 insertions(+), 23 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 9affb2908304..5b0483ce6cb1 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1492,23 +1492,29 @@ static enum compact_result compact_zone(struct zone *zone, struct compact_contro
 
 	/*
 	 * Setup to move all movable pages to the end of the zone. Used cached
-	 * information on where the scanners should start but check that it
-	 * is initialised by ensuring the values are within zone boundaries.
+	 * information on where the scanners should start (unless we explictly
+	 * want to compact the whole zone), but check that it is initialised
+	 * by ensuring the values are within zone boundaries.
 	 */
-	cc->migrate_pfn = zone->compact_cached_migrate_pfn[sync];
-	cc->free_pfn = zone->compact_cached_free_pfn;
-	if (cc->free_pfn < start_pfn || cc->free_pfn >= end_pfn) {
-		cc->free_pfn = pageblock_start_pfn(end_pfn - 1);
-		zone->compact_cached_free_pfn = cc->free_pfn;
-	}
-	if (cc->migrate_pfn < start_pfn || cc->migrate_pfn >= end_pfn) {
+	if (cc->whole_zone) {
 		cc->migrate_pfn = start_pfn;
-		zone->compact_cached_migrate_pfn[0] = cc->migrate_pfn;
-		zone->compact_cached_migrate_pfn[1] = cc->migrate_pfn;
-	}
+		cc->free_pfn = pageblock_start_pfn(end_pfn - 1);
+	} else {
+		cc->migrate_pfn = zone->compact_cached_migrate_pfn[sync];
+		cc->free_pfn = zone->compact_cached_free_pfn;
+		if (cc->free_pfn < start_pfn || cc->free_pfn >= end_pfn) {
+			cc->free_pfn = pageblock_start_pfn(end_pfn - 1);
+			zone->compact_cached_free_pfn = cc->free_pfn;
+		}
+		if (cc->migrate_pfn < start_pfn || cc->migrate_pfn >= end_pfn) {
+			cc->migrate_pfn = start_pfn;
+			zone->compact_cached_migrate_pfn[0] = cc->migrate_pfn;
+			zone->compact_cached_migrate_pfn[1] = cc->migrate_pfn;
+		}
 
-	if (cc->migrate_pfn == start_pfn)
-		cc->whole_zone = true;
+		if (cc->migrate_pfn == start_pfn)
+			cc->whole_zone = true;
+	}
 
 	cc->last_migrated_pfn = 0;
 
@@ -1747,14 +1753,6 @@ static void __compact_pgdat(pg_data_t *pgdat, struct compact_control *cc)
 		INIT_LIST_HEAD(&cc->freepages);
 		INIT_LIST_HEAD(&cc->migratepages);
 
-		/*
-		 * When called via /proc/sys/vm/compact_memory
-		 * this makes sure we compact the whole zone regardless of
-		 * cached scanner positions.
-		 */
-		if (is_via_compact_memory(cc->order))
-			__reset_isolation_suitable(zone);
-
 		if (is_via_compact_memory(cc->order) ||
 				!compaction_deferred(zone, cc->order))
 			compact_zone(zone, cc);
@@ -1790,6 +1788,7 @@ static void compact_node(int nid)
 		.order = -1,
 		.mode = MIGRATE_SYNC,
 		.ignore_skip_hint = true,
+		.whole_zone = true,
 	};
 
 	__compact_pgdat(NODE_DATA(nid), &cc);
diff --git a/mm/internal.h b/mm/internal.h
index 1501304f87a4..5214bf8e3171 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -179,7 +179,7 @@ struct compact_control {
 	enum migrate_mode mode;		/* Async or sync migration mode */
 	bool ignore_skip_hint;		/* Scan blocks even if marked skip */
 	bool direct_compaction;		/* False from kcompactd or /proc/... */
-	bool whole_zone;		/* Whole zone has been scanned */
+	bool whole_zone;		/* Whole zone should/has been scanned */
 	int order;			/* order a direct compactor needs */
 	const gfp_t gfp_mask;		/* gfp mask of a direct compactor */
 	const unsigned int alloc_flags;	/* alloc flags of a direct compactor */
-- 
2.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
