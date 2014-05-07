Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id E04DD6B0038
	for <linux-mm@kvack.org>; Tue,  6 May 2014 22:22:49 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id lj1so401716pab.0
        for <linux-mm@kvack.org>; Tue, 06 May 2014 19:22:49 -0700 (PDT)
Received: from mail-pd0-x233.google.com (mail-pd0-x233.google.com [2607:f8b0:400e:c02::233])
        by mx.google.com with ESMTPS id xx4si12958517pac.68.2014.05.06.19.22.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 May 2014 19:22:49 -0700 (PDT)
Received: by mail-pd0-f179.google.com with SMTP id g10so364542pdj.10
        for <linux-mm@kvack.org>; Tue, 06 May 2014 19:22:48 -0700 (PDT)
Date: Tue, 6 May 2014 19:22:45 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch v3 3/6] mm, compaction: add per-zone migration pfn cache for
 async compaction
In-Reply-To: <alpine.DEB.2.02.1405061920470.18635@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.02.1405061921220.18635@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1404301744110.8415@chino.kir.corp.google.com> <alpine.DEB.2.02.1405011434140.23898@chino.kir.corp.google.com> <alpine.DEB.2.02.1405061920470.18635@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Each zone has a cached migration scanner pfn for memory compaction so that 
subsequent calls to memory compaction can start where the previous call left 
off.

Currently, the compaction migration scanner only updates the per-zone cached pfn 
when pageblocks were not skipped for async compaction.  This creates a 
dependency on calling sync compaction to avoid having subsequent calls to async 
compaction from scanning an enormous amount of non-MOVABLE pageblocks each time 
it is called.  On large machines, this could be potentially very expensive.

This patch adds a per-zone cached migration scanner pfn only for async 
compaction.  It is updated everytime a pageblock has been scanned in its 
entirety and when no pages from it were successfully isolated.  The cached 
migration scanner pfn for sync compaction is updated only when called for sync 
compaction.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 v3: do not update pageblock skip metadata when skipped due to async per
     Vlastimil.

 include/linux/mmzone.h |  5 ++--
 mm/compaction.c        | 66 ++++++++++++++++++++++++++++++--------------------
 2 files changed, 43 insertions(+), 28 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -360,9 +360,10 @@ struct zone {
 	/* Set to true when the PG_migrate_skip bits should be cleared */
 	bool			compact_blockskip_flush;
 
-	/* pfns where compaction scanners should start */
+	/* pfn where compaction free scanner should start */
 	unsigned long		compact_cached_free_pfn;
-	unsigned long		compact_cached_migrate_pfn;
+	/* pfn where async and sync compaction migration scanner should start */
+	unsigned long		compact_cached_migrate_pfn[2];
 #endif
 #ifdef CONFIG_MEMORY_HOTPLUG
 	/* see spanned/present_pages for more description */
diff --git a/mm/compaction.c b/mm/compaction.c
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -89,7 +89,8 @@ static void __reset_isolation_suitable(struct zone *zone)
 	unsigned long end_pfn = zone_end_pfn(zone);
 	unsigned long pfn;
 
-	zone->compact_cached_migrate_pfn = start_pfn;
+	zone->compact_cached_migrate_pfn[0] = start_pfn;
+	zone->compact_cached_migrate_pfn[1] = start_pfn;
 	zone->compact_cached_free_pfn = end_pfn;
 	zone->compact_blockskip_flush = false;
 
@@ -131,9 +132,10 @@ void reset_isolation_suitable(pg_data_t *pgdat)
  */
 static void update_pageblock_skip(struct compact_control *cc,
 			struct page *page, unsigned long nr_isolated,
-			bool migrate_scanner)
+			bool set_unsuitable, bool migrate_scanner)
 {
 	struct zone *zone = cc->zone;
+	unsigned long pfn;
 
 	if (cc->ignore_skip_hint)
 		return;
@@ -141,20 +143,31 @@ static void update_pageblock_skip(struct compact_control *cc,
 	if (!page)
 		return;
 
-	if (!nr_isolated) {
-		unsigned long pfn = page_to_pfn(page);
+	if (nr_isolated)
+		return;
+
+	/*
+	 * Only skip pageblocks when all forms of compaction will be known to
+	 * fail in the near future.
+	 */
+	if (set_unsuitable)
 		set_pageblock_skip(page);
 
-		/* Update where compaction should restart */
-		if (migrate_scanner) {
-			if (!cc->finished_update_migrate &&
-			    pfn > zone->compact_cached_migrate_pfn)
-				zone->compact_cached_migrate_pfn = pfn;
-		} else {
-			if (!cc->finished_update_free &&
-			    pfn < zone->compact_cached_free_pfn)
-				zone->compact_cached_free_pfn = pfn;
-		}
+	pfn = page_to_pfn(page);
+
+	/* Update where async and sync compaction should restart */
+	if (migrate_scanner) {
+		if (cc->finished_update_migrate)
+			return;
+		if (pfn > zone->compact_cached_migrate_pfn[0])
+			zone->compact_cached_migrate_pfn[0] = pfn;
+		if (cc->sync && pfn > zone->compact_cached_migrate_pfn[1])
+			zone->compact_cached_migrate_pfn[1] = pfn;
+	} else {
+		if (cc->finished_update_free)
+			return;
+		if (pfn < zone->compact_cached_free_pfn)
+			zone->compact_cached_free_pfn = pfn;
 	}
 }
 #else
@@ -166,7 +179,7 @@ static inline bool isolation_suitable(struct compact_control *cc,
 
 static void update_pageblock_skip(struct compact_control *cc,
 			struct page *page, unsigned long nr_isolated,
-			bool migrate_scanner)
+			bool set_unsuitable, bool migrate_scanner)
 {
 }
 #endif /* CONFIG_COMPACTION */
@@ -329,7 +342,8 @@ isolate_fail:
 
 	/* Update the pageblock-skip if the whole pageblock was scanned */
 	if (blockpfn == end_pfn)
-		update_pageblock_skip(cc, valid_page, total_isolated, false);
+		update_pageblock_skip(cc, valid_page, total_isolated, true,
+				      false);
 
 	count_compact_events(COMPACTFREE_SCANNED, nr_scanned);
 	if (total_isolated)
@@ -464,7 +478,7 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 	unsigned long flags;
 	bool locked = false;
 	struct page *page = NULL, *valid_page = NULL;
-	bool skipped_async_unsuitable = false;
+	bool set_unsuitable = true;
 	const isolate_mode_t mode = (!cc->sync ? ISOLATE_ASYNC_MIGRATE : 0) |
 				    (unevictable ? ISOLATE_UNEVICTABLE : 0);
 
@@ -541,8 +555,7 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 			 */
 			mt = get_pageblock_migratetype(page);
 			if (!cc->sync && !migrate_async_suitable(mt)) {
-				cc->finished_update_migrate = true;
-				skipped_async_unsuitable = true;
+				set_unsuitable = false;
 				goto next_pageblock;
 			}
 		}
@@ -646,11 +659,10 @@ next_pageblock:
 	/*
 	 * Update the pageblock-skip information and cached scanner pfn,
 	 * if the whole pageblock was scanned without isolating any page.
-	 * This is not done when pageblock was skipped due to being unsuitable
-	 * for async compaction, so that eventual sync compaction can try.
 	 */
-	if (low_pfn == end_pfn && !skipped_async_unsuitable)
-		update_pageblock_skip(cc, valid_page, nr_isolated, true);
+	if (low_pfn == end_pfn)
+		update_pageblock_skip(cc, valid_page, nr_isolated,
+				      set_unsuitable, true);
 
 	trace_mm_compaction_isolate_migratepages(nr_scanned, nr_isolated);
 
@@ -877,7 +889,8 @@ static int compact_finished(struct zone *zone,
 	/* Compaction run completes if the migrate and free scanner meet */
 	if (cc->free_pfn <= cc->migrate_pfn) {
 		/* Let the next compaction start anew. */
-		zone->compact_cached_migrate_pfn = zone->zone_start_pfn;
+		zone->compact_cached_migrate_pfn[0] = zone->zone_start_pfn;
+		zone->compact_cached_migrate_pfn[1] = zone->zone_start_pfn;
 		zone->compact_cached_free_pfn = zone_end_pfn(zone);
 
 		/*
@@ -1002,7 +1015,7 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 	 * information on where the scanners should start but check that it
 	 * is initialised by ensuring the values are within zone boundaries.
 	 */
-	cc->migrate_pfn = zone->compact_cached_migrate_pfn;
+	cc->migrate_pfn = zone->compact_cached_migrate_pfn[cc->sync];
 	cc->free_pfn = zone->compact_cached_free_pfn;
 	if (cc->free_pfn < start_pfn || cc->free_pfn > end_pfn) {
 		cc->free_pfn = end_pfn & ~(pageblock_nr_pages-1);
@@ -1010,7 +1023,8 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 	}
 	if (cc->migrate_pfn < start_pfn || cc->migrate_pfn > end_pfn) {
 		cc->migrate_pfn = start_pfn;
-		zone->compact_cached_migrate_pfn = cc->migrate_pfn;
+		zone->compact_cached_migrate_pfn[0] = cc->migrate_pfn;
+		zone->compact_cached_migrate_pfn[1] = cc->migrate_pfn;
 	}
 
 	trace_mm_compaction_begin(start_pfn, cc->migrate_pfn, cc->free_pfn, end_pfn);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
