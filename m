Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 334136B0071
	for <linux-mm@kvack.org>; Mon, 19 Jan 2015 05:05:56 -0500 (EST)
Received: by mail-wi0-f171.google.com with SMTP id l15so5967956wiw.4
        for <linux-mm@kvack.org>; Mon, 19 Jan 2015 02:05:55 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ei1si20297233wib.40.2015.01.19.02.05.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 19 Jan 2015 02:05:42 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC PATCH 4/5] mm, compaction: allow scanners to start at any pfn within the zone
Date: Mon, 19 Jan 2015 11:05:19 +0100
Message-Id: <1421661920-4114-5-git-send-email-vbabka@suse.cz>
In-Reply-To: <1421661920-4114-1-git-send-email-vbabka@suse.cz>
References: <1421661920-4114-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>

Compaction employs two page scanners - migration scanner isolates pages to be
the source of migration, free page scanner isolates pages to be the target of
migration. Currently, migration scanner starts at the zone's first pageblock
and progresses towards the last one. Free scanner starts at the last pageblock
and progresses towards the first one. Within a pageblock, each scanner scans
pages from the first to the last one. When the scanners meet within the same
pageblock, compaction terminates.

One consequence of the current scheme, that turns out to be unfortunate, is
that the migration scanner does not encounter the pageblocks which were
scanned by the free scanner. In a test with stress-highalloc from mmtests,
the scanners were observed to meet around the middle of the zone in first two
phases (with background memory pressure) of the test when executed after fresh
reboot. On further executions without reboot, the meeting point shifts to
roughly third of the zone, and compaction activity as well as allocation
success rates deteriorates compared to the run after fresh reboot.

It turns out that the deterioration is indeed due to the migration scanner
processing only a small part of the zone. Compaction also keeps making this
bias worse by its activity - by moving all migratable pages towards end of the
zone, the free scanner has to scan a lot of full pageblocks to find more free
pages. The beginning of the zone contains pageblocks that have been compacted
as much as possible, but the free pages there cannot be further merged into
larger orders due to unmovable pages. The rest of the zone might contain more
suitable pageblocks, but the migration scanner will not reach them. It also
isn't be able to move movable pages out of unmovable pageblocks there, which
affects fragmentation.

This patch is the first step to remove this bias. It allows the compaction
scanners to start at arbitrary pfn (aligned to pageblock for practical
purposes), called pivot, within the zone. The migration scanner starts at the
exact pfn, the free scanner starts at the pageblock preceding the pivot. The
direction of scanning is unaffected, but when the migration scanner reaches
the last pageblock of the zone, or the free scanner reaches the first
pageblock, they wrap and continue with the first or last pageblock,
respectively. Compaction terminates when any of the scanners wrap and both
meet within the same pageblock.

For easier bisection of potential regressions, this patch always uses the
first zone's pfn as the pivot. That means the free scanner immediately wraps
to the last pageblock and the operation of scanners is thus unchanged. The
actual pivot changing is done by the next patch.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Michal Nazarewicz <mina86@mina86.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: David Rientjes <rientjes@google.com>
---
 include/linux/mmzone.h |   2 +
 mm/compaction.c        | 204 +++++++++++++++++++++++++++++++++++++++++++------
 mm/internal.h          |   1 +
 3 files changed, 182 insertions(+), 25 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 2f0856d..47aa181 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -503,6 +503,8 @@ struct zone {
 	unsigned long percpu_drift_mark;
 
 #if defined CONFIG_COMPACTION || defined CONFIG_CMA
+	/* pfn where compaction scanners have initially started last time */
+	unsigned long		compact_cached_pivot_pfn;
 	/* pfn where compaction free scanner should start */
 	unsigned long		compact_cached_free_pfn;
 	/* pfn where async and sync compaction migration scanner should start */
diff --git a/mm/compaction.c b/mm/compaction.c
index 5626220..abae89a 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -123,11 +123,16 @@ static inline bool isolation_suitable(struct compact_control *cc,
 	return !get_pageblock_skip(page);
 }
 
+/*
+ * Invalidate cached compaction scanner positions, so that compact_zone()
+ * will reinitialize them on the next compaction.
+ */
 static void reset_cached_positions(struct zone *zone)
 {
-	zone->compact_cached_migrate_pfn[0] = zone->zone_start_pfn;
-	zone->compact_cached_migrate_pfn[1] = zone->zone_start_pfn;
-	zone->compact_cached_free_pfn = zone_end_pfn(zone);
+	/* Invalid values are re-initialized in compact_zone */
+	zone->compact_cached_migrate_pfn[0] = 0;
+	zone->compact_cached_migrate_pfn[1] = 0;
+	zone->compact_cached_free_pfn = 0;
 }
 
 /*
@@ -172,11 +177,35 @@ void reset_isolation_suitable(pg_data_t *pgdat)
 		/* Only flush if a full compaction finished recently */
 		if (zone->compact_blockskip_flush) {
 			__reset_isolation_suitable(zone);
-			reset_cached_positions(zone);
+			reset_cached_positions(zone, false);
 		}
 	}
 }
 
+static void update_cached_migrate_pfn(unsigned long pfn,
+		unsigned long pivot_pfn, unsigned long *old_pfn)
+{
+	/* Both old and new pfn either wrapped or not, and new is higher */
+	if (((*old_pfn >= pivot_pfn) == (pfn >= pivot_pfn))
+	    && (pfn > *old_pfn))
+		*old_pfn = pfn;
+	/* New pfn has wrapped and the old didn't yet */
+	else if ((*old_pfn >= pivot_pfn) && (pfn < pivot_pfn))
+		*old_pfn = pfn;
+}
+
+static void update_cached_free_pfn(unsigned long pfn,
+		unsigned long pivot_pfn, unsigned long *old_pfn)
+{
+	/* Both old and new either pfn wrapped or not, and new is lower */
+	if (((*old_pfn < pivot_pfn) == (pfn < pivot_pfn))
+	    && (pfn < *old_pfn))
+		*old_pfn = pfn;
+	/* New pfn has wrapped and the old didn't yet */
+	else if ((*old_pfn < pivot_pfn) && (pfn >= pivot_pfn))
+		*old_pfn = pfn;
+}
+
 /*
  * If no pages were isolated then mark this pageblock to be skipped in the
  * future. The information is later cleared by __reset_isolation_suitable().
@@ -186,6 +215,7 @@ static void update_pageblock_skip(struct compact_control *cc,
 			bool migrate_scanner)
 {
 	struct zone *zone = cc->zone;
+	unsigned long pivot_pfn = cc->pivot_pfn;
 	unsigned long pfn;
 
 	if (cc->ignore_skip_hint)
@@ -203,14 +233,14 @@ static void update_pageblock_skip(struct compact_control *cc,
 
 	/* Update where async and sync compaction should restart */
 	if (migrate_scanner) {
-		if (pfn > zone->compact_cached_migrate_pfn[0])
-			zone->compact_cached_migrate_pfn[0] = pfn;
-		if (cc->mode != MIGRATE_ASYNC &&
-		    pfn > zone->compact_cached_migrate_pfn[1])
-			zone->compact_cached_migrate_pfn[1] = pfn;
+		update_cached_migrate_pfn(pfn, pivot_pfn,
+					&zone->compact_cached_migrate_pfn[0]);
+		if (cc->mode != MIGRATE_ASYNC)
+			update_cached_migrate_pfn(pfn, pivot_pfn,
+					&zone->compact_cached_migrate_pfn[1]);
 	} else {
-		if (pfn < zone->compact_cached_free_pfn)
-			zone->compact_cached_free_pfn = pfn;
+		update_cached_free_pfn(pfn, pivot_pfn,
+					&zone->compact_cached_free_pfn);
 	}
 }
 #else
@@ -808,14 +838,41 @@ isolate_migratepages_range(struct compact_control *cc, unsigned long start_pfn,
 
 #endif /* CONFIG_COMPACTION || CONFIG_CMA */
 #ifdef CONFIG_COMPACTION
+static inline bool migrate_scanner_wrapped(struct compact_control *cc)
+{
+	return cc->migrate_pfn < cc->pivot_pfn;
+}
+
+static inline bool free_scanner_wrapped(struct compact_control *cc)
+{
+	return cc->free_pfn >= cc->pivot_pfn;
+}
+
 /*
  * Test whether the free scanner has reached the same or lower pageblock than
  * the migration scanner, and compaction should thus terminate.
  */
 static inline bool compact_scanners_met(struct compact_control *cc)
 {
-	return (cc->free_pfn >> pageblock_order)
-		<= (cc->migrate_pfn >> pageblock_order);
+	bool free_below_migrate = (cc->free_pfn >> pageblock_order)
+		                <= (cc->migrate_pfn >> pageblock_order);
+
+	if (migrate_scanner_wrapped(cc) != free_scanner_wrapped(cc))
+		/*
+		 * Only one of the scanners have wrapped. Terminate if free
+		 * scanner is in the same or lower pageblock than migration
+		 * scanner.
+		*/
+		return free_below_migrate;
+	else
+		/*
+		 * If neither scanner has wrapped, then free < start <=
+		 * migration and we return false by definition.
+		 * It shouldn't happen that both have wrapped, but even if it
+		 * does due to e.g. reading mismatched zone cached pfn's, then
+		 * migration < start <= free, so we return true and terminate.
+		 */
+		return !free_below_migrate;
 }
 
 /*
@@ -832,7 +889,10 @@ static void isolate_freepages(struct compact_control *cc)
 	unsigned long low_pfn;	     /* lowest pfn scanner is able to scan */
 	int nr_freepages = cc->nr_freepages;
 	struct list_head *freelist = &cc->freepages;
+	bool wrapping; /* set to true in the first pageblock of the zone */
+	bool wrapped; /* set to true when either scanner has wrapped */
 
+wrap:
 	/*
 	 * Initialise the free scanner. The starting point is where we last
 	 * successfully isolated from, zone-cached value, or the end of the
@@ -848,14 +908,25 @@ static void isolate_freepages(struct compact_control *cc)
 	block_start_pfn = cc->free_pfn & ~(pageblock_nr_pages-1);
 	block_end_pfn = min(block_start_pfn + pageblock_nr_pages,
 						zone_end_pfn(zone));
-	low_pfn = ALIGN(cc->migrate_pfn + 1, pageblock_nr_pages);
+
+	wrapping = false;
+	wrapped = free_scanner_wrapped(cc) || migrate_scanner_wrapped(cc);
+	if (!wrapped)
+		/* 
+		 * If neither scanner wrapped yet, we are limited by zone's
+		 * beginning. Here we pretend that the zone starts pageblock
+		 * aligned to make the for-loop condition simpler.
+		 */
+		low_pfn = zone->zone_start_pfn & ~(pageblock_nr_pages-1);
+	else
+		low_pfn = ALIGN(cc->migrate_pfn + 1, pageblock_nr_pages);
 
 	/*
 	 * Isolate free pages until enough are available to migrate the
 	 * pages on cc->migratepages. We stop searching if the migrate
 	 * and free page scanners meet or enough free pages are isolated.
 	 */
-	for (; block_start_pfn >= low_pfn;
+	for (; !wrapping && block_start_pfn >= low_pfn;
 				block_end_pfn = block_start_pfn,
 				block_start_pfn -= pageblock_nr_pages,
 				isolate_start_pfn = block_start_pfn) {
@@ -870,6 +941,24 @@ static void isolate_freepages(struct compact_control *cc)
 						&& compact_should_abort(cc))
 			break;
 
+		/*
+		 * When we are limited by zone boundary, this means we have
+		 * reached its first pageblock.
+		 */
+		if (!wrapped && block_start_pfn <= zone->zone_start_pfn) {
+			/* The zone might start in the middle of the pageblock */
+			block_start_pfn = zone->zone_start_pfn;
+			if (isolate_start_pfn <= zone->zone_start_pfn)
+				isolate_start_pfn = zone->zone_start_pfn;
+			/*
+			 * For e.g. DMA zone with zone_start_pfn == 1, we will
+			 * underflow block_start_pfn in the next loop
+			 * iteration. We have to terminate the loop with other
+			 * means.
+			 */
+			wrapping = true;
+		}
+
 		page = pageblock_pfn_to_page(block_start_pfn, block_end_pfn,
 									zone);
 		if (!page)
@@ -903,6 +992,12 @@ static void isolate_freepages(struct compact_control *cc)
 			if (isolate_start_pfn >= block_end_pfn)
 				isolate_start_pfn =
 					block_start_pfn - pageblock_nr_pages;
+			else if (wrapping)
+				/*
+				 * We have been in the first pageblock of the
+				 * zone, but have not finished it yet.
+				 */
+				wrapping = false;
 			break;
 		} else {
 			/*
@@ -913,6 +1008,20 @@ static void isolate_freepages(struct compact_control *cc)
 		}
 	}
 
+	/* Did we reach the beginning of the zone? Wrap to the end. */
+	if (!wrapped && wrapping) {
+		isolate_start_pfn = (zone_end_pfn(zone)-1) &
+						~(pageblock_nr_pages-1);
+		/*
+		 * If we haven't isolated anything, we have to continue
+		 * immediately, otherwise page migration will fail.
+		 */
+		if (!nr_freepages && !cc->contended) {
+			cc->free_pfn = isolate_start_pfn;
+			goto wrap;
+		}
+	}
+
 	/* split_free_page does not map the pages */
 	map_pages(freelist);
 
@@ -984,10 +1093,11 @@ typedef enum {
 static isolate_migrate_t isolate_migratepages(struct zone *zone,
 					struct compact_control *cc)
 {
-	unsigned long low_pfn, end_pfn;
+	unsigned long low_pfn, end_pfn, max_pfn;
 	struct page *page;
 	const isolate_mode_t isolate_mode =
 		(cc->mode == MIGRATE_ASYNC ? ISOLATE_ASYNC_MIGRATE : 0);
+	bool wrapped = migrate_scanner_wrapped(cc) || free_scanner_wrapped(cc);
 
 	/*
 	 * Start at where we last stopped, or beginning of the zone as
@@ -998,13 +1108,27 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 	/* Only scan within a pageblock boundary */
 	end_pfn = ALIGN(low_pfn + 1, pageblock_nr_pages);
 
+	if (!wrapped) {
+		/* 
+		 * Neither of the scanners has wrapped yet, we are limited by
+		 * zone end. Here we pretend it's aligned to pageblock
+		 * boundary to make the for-loop condition simpler
+		 */
+		max_pfn = ALIGN(zone_end_pfn(zone), pageblock_nr_pages);
+	} else {
+		/* If any of the scanners wrapped, we will meet free scanner */
+		max_pfn = cc->free_pfn;
+	}
+
 	/*
 	 * Iterate over whole pageblocks until we find the first suitable.
-	 * Do not cross the free scanner.
+	 * Do not cross the free scanner or the end of the zone.
 	 */
-	for (; end_pfn <= cc->free_pfn;
+	for (; end_pfn <= max_pfn;
 			low_pfn = end_pfn, end_pfn += pageblock_nr_pages) {
 
+		if (!wrapped && end_pfn > zone_end_pfn(zone))
+			end_pfn = zone_end_pfn(zone);
 		/*
 		 * This can potentially iterate a massively long zone with
 		 * many pageblocks unsuitable, so periodically check if we
@@ -1047,6 +1171,10 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 	}
 
 	acct_isolated(zone, cc);
+	/* Did we reach the end of the zone? Wrap to the beginning */
+	if (!wrapped && low_pfn >= zone_end_pfn(zone))
+		low_pfn = zone->zone_start_pfn;
+
 	/* Record where migration scanner will be restarted. */
 	cc->migrate_pfn = low_pfn;
 
@@ -1197,22 +1325,48 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 	}
 
 	/*
-	 * Setup to move all movable pages to the end of the zone. Used cached
+	 * Setup the scanner positions according to pivot pfn. Use cached
 	 * information on where the scanners should start but check that it
 	 * is initialised by ensuring the values are within zone boundaries.
 	 */
-	cc->migrate_pfn = zone->compact_cached_migrate_pfn[sync];
-	cc->free_pfn = zone->compact_cached_free_pfn;
-	if (cc->free_pfn < start_pfn || cc->free_pfn > end_pfn) {
-		cc->free_pfn = end_pfn & ~(pageblock_nr_pages-1);
-		zone->compact_cached_free_pfn = cc->free_pfn;
+	cc->pivot_pfn = zone->compact_cached_pivot_pfn;
+	if (cc->pivot_pfn < start_pfn || cc->pivot_pfn > end_pfn) {
+		cc->pivot_pfn = start_pfn;
+		zone->compact_cached_pivot_pfn = cc->pivot_pfn;
+		/* When starting position was invalid, reset the rest */
+		reset_cached_positions(zone);
 	}
+
+	cc->migrate_pfn = zone->compact_cached_migrate_pfn[sync];
 	if (cc->migrate_pfn < start_pfn || cc->migrate_pfn > end_pfn) {
-		cc->migrate_pfn = start_pfn;
+		cc->migrate_pfn = cc->pivot_pfn;
 		zone->compact_cached_migrate_pfn[0] = cc->migrate_pfn;
 		zone->compact_cached_migrate_pfn[1] = cc->migrate_pfn;
 	}
 
+	cc->free_pfn = zone->compact_cached_free_pfn;
+	if (cc->free_pfn < start_pfn || cc->free_pfn > end_pfn)
+		cc->free_pfn = cc->pivot_pfn;
+
+	/*
+	 * Free scanner should start on the beginning of the pageblock below
+	 * the cc->pivot_pfn. If that's below the zone boundary, wrap to the
+	 * last pageblock of the zone.
+	 */
+	if (cc->free_pfn == cc->pivot_pfn) {
+		/* Don't underflow in zones starting with e.g. pfn 1 */
+		if (cc->pivot_pfn < pageblock_nr_pages) {
+			cc->free_pfn = (end_pfn-1) & ~(pageblock_nr_pages-1);
+		} else {
+			cc->free_pfn = (cc->pivot_pfn - pageblock_nr_pages);
+			cc->free_pfn &= ~(pageblock_nr_pages-1);
+			if (cc->free_pfn < start_pfn)
+				cc->free_pfn = (end_pfn-1) &
+					~(pageblock_nr_pages-1);
+		}
+		zone->compact_cached_free_pfn = cc->free_pfn;
+	}
+
 	trace_mm_compaction_begin(start_pfn, cc->migrate_pfn, cc->free_pfn, end_pfn);
 
 	migrate_prep_local();
diff --git a/mm/internal.h b/mm/internal.h
index efad241..cb7b297 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -157,6 +157,7 @@ struct compact_control {
 	struct list_head migratepages;	/* List of pages being migrated */
 	unsigned long nr_freepages;	/* Number of isolated free pages */
 	unsigned long nr_migratepages;	/* Number of pages to migrate */
+	unsigned long pivot_pfn;	/* Where the scanners initially start */
 	unsigned long free_pfn;		/* isolate_freepages search base */
 	unsigned long migrate_pfn;	/* isolate_migratepages search base */
 	enum migrate_mode mode;		/* Async or sync migration mode */
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
