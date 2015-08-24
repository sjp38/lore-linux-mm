Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6E23F82F5F
	for <linux-mm@kvack.org>; Sun, 23 Aug 2015 22:20:26 -0400 (EDT)
Received: by pacti10 with SMTP id ti10so11684066pac.0
        for <linux-mm@kvack.org>; Sun, 23 Aug 2015 19:20:26 -0700 (PDT)
Received: from mail-pd0-x236.google.com (mail-pd0-x236.google.com. [2607:f8b0:400e:c02::236])
        by mx.google.com with ESMTPS id a5si24972194pdg.236.2015.08.23.19.20.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 23 Aug 2015 19:20:25 -0700 (PDT)
Received: by pdbfa8 with SMTP id fa8so47425267pdb.1
        for <linux-mm@kvack.org>; Sun, 23 Aug 2015 19:20:25 -0700 (PDT)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH v2 7/9] mm/compaction: redesign compaction
Date: Mon, 24 Aug 2015 11:19:31 +0900
Message-Id: <1440382773-16070-8-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1440382773-16070-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1440382773-16070-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Currently, compaction works as following.
1) migration scanner scans from zone_start_pfn to zone_end_pfn
to find migratable pages
2) free scanner scans from zone_end_pfn to zone_start_pfn to
find free pages
3) If both scanner crossed, compaction is finished.

This algorithm has some drawbacks. 1) Back of the zone cannot be
scanned by migration scanner because migration scanner can't pass
over freepage scanner. So, although there are some high order page
candidates at back of the zone, we can't utilize it.
Another weakness is 2) compaction's success highly depends on amount
of freepage. Compaction can migrate used pages by amount of freepage
at maximum. If we can't make high order page by this effort, both
scanner should meet and compaction will fail.

We can easily observe problem 1) by following test.

Memory is artificially fragmented to make order 3 allocation hard. And,
most of pageblocks are changed to movable migratetype.

  System: 512 MB with 32 MB Zram
  Memory: 25% memory is allocated to make fragmentation and 200 MB is
  	occupied by memory hogger. Most pageblocks are movable
  	migratetype.
  Fragmentation: Successful order 3 allocation candidates may be around
  	1500 roughly.
  Allocation attempts: Roughly 3000 order 3 allocation attempts
  	with GFP_NORETRY. This value is determined to saturate allocation
  	success.

Test: hogger-frag-movable

Success(N)                    70
compact_stall                307
compact_success               64
compact_fail                 243
pgmigrate_success          34592
compact_isolated           73977
compact_migrate_scanned  2280770
compact_free_scanned     4710313

Column 'Success(N) are calculated by following equations.

Success(N) = successful allocation * 100 /
		number of successful order-3 candidates

As mentioned above, there are roughly 1500 high order page candidates,
but, compaction just returns 70% of them, because migration scanner
can't pass over freepage scanner. With new compaction approach, it can
be increased to 94% by this patch.

To check 2), hogger-frag-movable benchmark is used again, but, with some
tweaks. Amount of allocated memory by memory hogger varys.

Test: hogger-frag-movable with free memory variation

Kernel:	Base

200MB-Success(N)	70
250MB-Success(N)	38
300MB-Success(N)	29

As background knowledge, up to 250MB, there is enough
memory to succeed all order-3 allocation attempts. In 300MB case,
available memory before starting allocation attempt is just 57MB,
so all of attempts cannot succeed.

Anyway, as free memory decreases, compaction success rate also decreases.
It is better to remove this dependency to get stable compaction result
in any case.

This patch solves these problems mentioned in above.
Freepage scanner is largely changed to scan zone from zone_start_pfn
to zone_end_pfn. And, by this change, compaction finish condition is also
changed that migration scanner reach zone_end_pfn. With these changes,
migration scanner can traverse anywhere in the zone.

To prevent back and forth migration within one compaction iteration,
freepage scanner marks skip-bit when scanning pageblock. migration scanner
checks it and will skip this marked pageblock so back and forth migration
cannot be possible in one compaction iteration.

If freepage scanner reachs the end of zone, it restarts at zone_start_pfn.
In this time, freepage scanner would scan the pageblock where migration
scanner has migrated some pages but fail to make high order page. This
leaved freepages means that they can't become high order page due to
the fragmentation so it is good source for freepage scanner.

With this change, above test result is:

Kernel:	Base vs Redesign

Test: hogger-frag-movable

Success(N)                    70              94
compact_stall                307            3642
compact_success               64             144
compact_fail                 243            3498
pgmigrate_success          34592        15897219
compact_isolated           73977        31899553
compact_migrate_scanned  2280770        59146745
compact_free_scanned     4710313        49566134

Test: hogger-frag-movable with free memory variation

200MB-Success(N)	70	94
250MB-Success(N)	38	93
300MB-Success(N)	29	89

Compaction gives us almost all possible high order page. Overhead is
highly increased, but, further patch will reduce it greatly
by adjusting depletion check with this new algorithm.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/compaction.c | 145 ++++++++++++++++++++++++++++++--------------------------
 1 file changed, 77 insertions(+), 68 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index a259608..ca4d6d1 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -53,17 +53,17 @@ static const char *const compaction_status_string[] = {
 static unsigned long release_freepages(struct list_head *freelist)
 {
 	struct page *page, *next;
-	unsigned long high_pfn = 0;
+	unsigned long low_pfn = ULONG_MAX;
 
 	list_for_each_entry_safe(page, next, freelist, lru) {
 		unsigned long pfn = page_to_pfn(page);
 		list_del(&page->lru);
 		__free_page(page);
-		if (pfn > high_pfn)
-			high_pfn = pfn;
+		if (pfn < low_pfn)
+			low_pfn = pfn;
 	}
 
-	return high_pfn;
+	return low_pfn;
 }
 
 static void map_pages(struct list_head *list)
@@ -243,7 +243,7 @@ static void __reset_isolation_suitable(struct zone *zone)
 
 	zone->compact_cached_migrate_pfn[0] = start_pfn;
 	zone->compact_cached_migrate_pfn[1] = start_pfn;
-	zone->compact_cached_free_pfn = end_pfn;
+	zone->compact_cached_free_pfn = start_pfn;
 	zone->compact_blockskip_flush = false;
 
 	clear_bit(ZONE_COMPACTION_SCANALLFREE, &zone->flags);
@@ -335,7 +335,7 @@ static void update_pageblock_skip(struct compact_control *cc,
 		if (!nr_isolated)
 			set_pageblock_skip_freescan(page);
 
-		if (pfn < zone->compact_cached_free_pfn)
+		if (pfn > zone->compact_cached_free_pfn)
 			zone->compact_cached_free_pfn = pfn;
 	}
 }
@@ -869,8 +869,11 @@ isolate_success:
 						nr_scanned, nr_isolated);
 
 	count_compact_events(COMPACTMIGRATE_SCANNED, nr_scanned);
-	if (nr_isolated)
+	if (nr_isolated) {
 		count_compact_events(COMPACTISOLATED, nr_isolated);
+		if (valid_page)
+			clear_pageblock_skip_freescan(valid_page);
+	}
 
 	return low_pfn;
 }
@@ -969,12 +972,14 @@ static void isolate_freepages(struct compact_control *cc)
 {
 	struct zone *zone = cc->zone;
 	struct page *page;
+	unsigned long pfn;
 	unsigned long block_start_pfn;	/* start of current pageblock */
-	unsigned long isolate_start_pfn; /* exact pfn we start at */
 	unsigned long block_end_pfn;	/* end of current pageblock */
-	unsigned long low_pfn;	     /* lowest pfn scanner is able to scan */
 	struct list_head *freelist = &cc->freepages;
+	unsigned long nr_isolated;
+	bool rotated = false;
 
+retry:
 	/*
 	 * Initialise the free scanner. The starting point is where we last
 	 * successfully isolated from, zone-cached value, or the end of the
@@ -986,22 +991,21 @@ static void isolate_freepages(struct compact_control *cc)
 	 * The low boundary is the end of the pageblock the migration scanner
 	 * is using.
 	 */
-	isolate_start_pfn = cc->free_pfn;
-	block_start_pfn = cc->free_pfn & ~(pageblock_nr_pages-1);
-	block_end_pfn = min(block_start_pfn + pageblock_nr_pages,
-						zone_end_pfn(zone));
-	low_pfn = ALIGN(cc->migrate_pfn + 1, pageblock_nr_pages);
+	pfn = cc->free_pfn;
 
-	/*
-	 * Isolate free pages until enough are available to migrate the
-	 * pages on cc->migratepages. We stop searching if the migrate
-	 * and free page scanners meet or enough free pages are isolated.
-	 */
-	for (; block_start_pfn >= low_pfn &&
-			cc->nr_migratepages > cc->nr_freepages;
-				block_end_pfn = block_start_pfn,
-				block_start_pfn -= pageblock_nr_pages,
-				isolate_start_pfn = block_start_pfn) {
+	for (; pfn < zone_end_pfn(zone) &&
+		cc->nr_migratepages > cc->nr_freepages;) {
+
+		block_start_pfn = pfn & ~(pageblock_nr_pages-1);
+		block_end_pfn = ALIGN(pfn + 1, pageblock_nr_pages);
+		block_end_pfn = min(block_end_pfn, zone_end_pfn(zone));
+
+		/* Skip the pageblock where migration scan is */
+		if (block_start_pfn ==
+			(cc->migrate_pfn & ~(pageblock_nr_pages-1))) {
+			pfn = block_end_pfn;
+			continue;
+		}
 
 		/*
 		 * This can iterate a massively long zone without finding any
@@ -1012,35 +1016,31 @@ static void isolate_freepages(struct compact_control *cc)
 						&& compact_should_abort(cc))
 			break;
 
-		page = pageblock_pfn_to_page(block_start_pfn, block_end_pfn,
-									zone);
-		if (!page)
+		page = pageblock_pfn_to_page(pfn, block_end_pfn, zone);
+		if (!page) {
+			pfn = block_end_pfn;
 			continue;
+		}
 
 		/* Check the block is suitable for migration */
-		if (!suitable_migration_target(cc, page))
+		if (!suitable_migration_target(cc, page)) {
+			pfn = block_end_pfn;
 			continue;
+		}
 
 		/* If isolation recently failed, do not retry */
-		if (!isolation_suitable(cc, page, false))
+		if (!isolation_suitable(cc, page, false)) {
+			pfn = block_end_pfn;
 			continue;
+		}
 
 		/* Found a block suitable for isolating free pages from. */
-		isolate_freepages_block(cc, &isolate_start_pfn,
+		nr_isolated = isolate_freepages_block(cc, &pfn,
 					block_end_pfn, freelist, false);
 
-		/*
-		 * Remember where the free scanner should restart next time,
-		 * which is where isolate_freepages_block() left off.
-		 * But if it scanned the whole pageblock, isolate_start_pfn
-		 * now points at block_end_pfn, which is the start of the next
-		 * pageblock.
-		 * In that case we will however want to restart at the start
-		 * of the previous pageblock.
-		 */
-		cc->free_pfn = (isolate_start_pfn < block_end_pfn) ?
-				isolate_start_pfn :
-				block_start_pfn - pageblock_nr_pages;
+		/* To prevent back and forth migration */
+		if (nr_isolated)
+			set_pageblock_skip_migratescan(page);
 
 		/*
 		 * isolate_freepages_block() might have aborted due to async
@@ -1053,12 +1053,15 @@ static void isolate_freepages(struct compact_control *cc)
 	/* split_free_page does not map the pages */
 	map_pages(freelist);
 
-	/*
-	 * If we crossed the migrate scanner, we want to keep it that way
-	 * so that compact_finished() may detect this
-	 */
-	if (block_start_pfn < low_pfn)
-		cc->free_pfn = cc->migrate_pfn;
+	cc->free_pfn = pfn;
+	if (cc->free_pfn >= zone_end_pfn(zone)) {
+		cc->free_pfn = zone->zone_start_pfn;
+		zone->compact_cached_free_pfn = cc->free_pfn;
+		if (cc->nr_freepages == 0 && !rotated) {
+			rotated = true;
+			goto retry;
+		}
+	}
 }
 
 /*
@@ -1144,8 +1147,9 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 	 * Iterate over whole pageblocks until we find the first suitable.
 	 * Do not cross the free scanner.
 	 */
-	for (; end_pfn <= cc->free_pfn;
-			low_pfn = end_pfn, end_pfn += pageblock_nr_pages) {
+	for (; low_pfn < zone_end_pfn(zone); low_pfn = end_pfn) {
+		end_pfn = ALIGN(low_pfn + 1, pageblock_nr_pages);
+		end_pfn = min(end_pfn, zone_end_pfn(zone));
 
 		/*
 		 * This can potentially iterate a massively long zone with
@@ -1191,12 +1195,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 	}
 
 	acct_isolated(zone, cc);
-	/*
-	 * Record where migration scanner will be restarted. If we end up in
-	 * the same pageblock as the free scanner, make the scanners fully
-	 * meet so that compact_finished() terminates compaction.
-	 */
-	cc->migrate_pfn = (end_pfn <= cc->free_pfn) ? low_pfn : cc->free_pfn;
+	cc->migrate_pfn = low_pfn;
 
 	return cc->nr_migratepages ? ISOLATE_SUCCESS : ISOLATE_NONE;
 }
@@ -1211,11 +1210,15 @@ static int __compact_finished(struct zone *zone, struct compact_control *cc,
 		return COMPACT_PARTIAL;
 
 	/* Compaction run completes if the migrate and free scanner meet */
-	if (cc->free_pfn <= cc->migrate_pfn) {
+	if (cc->migrate_pfn >= zone_end_pfn(zone)) {
+		/* Stop the async compaction */
+		zone->compact_cached_migrate_pfn[0] = zone_end_pfn(zone);
+		if (cc->mode == MIGRATE_ASYNC)
+			return COMPACT_PARTIAL;
+
 		/* Let the next compaction start anew. */
 		zone->compact_cached_migrate_pfn[0] = zone->zone_start_pfn;
 		zone->compact_cached_migrate_pfn[1] = zone->zone_start_pfn;
-		zone->compact_cached_free_pfn = zone_end_pfn(zone);
 
 		/*
 		 * Mark that the PG_migrate_skip information should be cleared
@@ -1397,11 +1400,14 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 	 */
 	cc->migrate_pfn = zone->compact_cached_migrate_pfn[sync];
 	cc->free_pfn = zone->compact_cached_free_pfn;
-	if (cc->free_pfn < start_pfn || cc->free_pfn > end_pfn) {
-		cc->free_pfn = end_pfn & ~(pageblock_nr_pages-1);
+	if (cc->mode == MIGRATE_ASYNC && cc->migrate_pfn >= end_pfn)
+		return COMPACT_SKIPPED;
+
+	if (cc->free_pfn < start_pfn || cc->free_pfn >= end_pfn) {
+		cc->free_pfn = start_pfn;
 		zone->compact_cached_free_pfn = cc->free_pfn;
 	}
-	if (cc->migrate_pfn < start_pfn || cc->migrate_pfn > end_pfn) {
+	if (cc->migrate_pfn < start_pfn || cc->migrate_pfn >= end_pfn) {
 		cc->migrate_pfn = start_pfn;
 		zone->compact_cached_migrate_pfn[0] = cc->migrate_pfn;
 		zone->compact_cached_migrate_pfn[1] = cc->migrate_pfn;
@@ -1450,11 +1456,16 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 		if (err) {
 			putback_movable_pages(&cc->migratepages);
 			/*
-			 * migrate_pages() may return -ENOMEM when scanners meet
-			 * and we want compact_finished() to detect it
+			 * migrate_pages() may return -ENOMEM when free scanner
+			 * doesn't find any freepage, and, in this case, more
+			 * compaction attempt is useless because it cannot
+			 * be successful due to no free memory. We'd like to
+			 * consider this state as COMPACT_COMPLETE although
+			 * migration scanner doesn't reach end_pfn of zone and
+			 * fail to compaction.
 			 */
-			if (err == -ENOMEM && cc->free_pfn > cc->migrate_pfn) {
-				ret = COMPACT_PARTIAL;
+			if (err == -ENOMEM) {
+				ret = COMPACT_COMPLETE;
 				goto out;
 			}
 		}
@@ -1504,13 +1515,11 @@ out:
 
 		cc->nr_freepages = 0;
 		VM_BUG_ON(free_pfn == 0);
-		/* The cached pfn is always the first in a pageblock */
-		free_pfn &= ~(pageblock_nr_pages-1);
 		/*
 		 * Only go back, not forward. The cached pfn might have been
 		 * already reset to zone end in compact_finished()
 		 */
-		if (free_pfn > zone->compact_cached_free_pfn)
+		if (free_pfn < zone->compact_cached_free_pfn)
 			zone->compact_cached_free_pfn = free_pfn;
 	}
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
