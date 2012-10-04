Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 772956B0114
	for <linux-mm@kvack.org>; Thu,  4 Oct 2012 10:03:19 -0400 (EDT)
Date: Thu, 4 Oct 2012 15:03:14 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH] mm: compaction: Cache if a pageblock was scanned and no
 pages were isolated -fix3
Message-ID: <20121004140314.GX29125@suse.de>
References: <20120927112911.GA25959@avionic-0098.mockup.avionic-design.de>
 <20120927151159.4427fc8f.akpm@linux-foundation.org>
 <20120928054330.GA27594@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120928054330.GA27594@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, Thierry Reding <thierry.reding@avionic-design.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Mark Brown <broonie@opensource.wolfsonmicro.com>, Peter Ujfalusi <peter.ujfalusi@ti.com>

The following patch still has not been tested but I'm reposting it
anyway. I've sent a rebased patch on top of next-20121004 that includes
this patch privately to Thierry for testing.


CMA requires that the PG_migrate_skip hint be skipped but it was only
skipping it when isolating pages for migration, not for free. Ensure
cc->isolate_skip_hint gets passed in both cases.

This is a fix for
mm-compaction-cache-if-a-pageblock-was-scanned-and-no-pages-were-isolated-fix.patch
but is based on top of linux-next/akpm as of 20121004. It will cause
minor conflicts when it is slotted into place but the resolutions should
be straight-forward.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/compaction.c |   16 ++++------------
 mm/internal.h   |    3 ++-
 mm/page_alloc.c |   43 ++++++++++++++++++++++---------------------
 3 files changed, 28 insertions(+), 34 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index ed3b8f1..2c4ce17 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -373,22 +373,14 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
  * a free page).
  */
 unsigned long
-isolate_freepages_range(unsigned long start_pfn, unsigned long end_pfn)
+isolate_freepages_range(struct compact_control *cc,
+			unsigned long start_pfn, unsigned long end_pfn)
 {
 	unsigned long isolated, pfn, block_end_pfn;
-	struct zone *zone = NULL;
 	LIST_HEAD(freelist);
 
-	/* cc needed for isolate_freepages_block to acquire zone->lock */
-	struct compact_control cc = {
-		.sync = true,
-	};
-
-	if (pfn_valid(start_pfn))
-		cc.zone = zone = page_zone(pfn_to_page(start_pfn));
-
 	for (pfn = start_pfn; pfn < end_pfn; pfn += isolated) {
-		if (!pfn_valid(pfn) || zone != page_zone(pfn_to_page(pfn)))
+		if (!pfn_valid(pfn) || cc->zone != page_zone(pfn_to_page(pfn)))
 			break;
 
 		/*
@@ -398,7 +390,7 @@ isolate_freepages_range(unsigned long start_pfn, unsigned long end_pfn)
 		block_end_pfn = ALIGN(pfn + 1, pageblock_nr_pages);
 		block_end_pfn = min(block_end_pfn, end_pfn);
 
-		isolated = isolate_freepages_block(&cc, pfn, block_end_pfn,
+		isolated = isolate_freepages_block(cc, pfn, block_end_pfn,
 						   &freelist, true);
 
 		/*
diff --git a/mm/internal.h b/mm/internal.h
index 9d5d276..a3ce781 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -135,7 +135,8 @@ struct compact_control {
 };
 
 unsigned long
-isolate_freepages_range(unsigned long start_pfn, unsigned long end_pfn);
+isolate_freepages_range(struct compact_control *cc,
+			unsigned long start_pfn, unsigned long end_pfn);
 unsigned long
 isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 	unsigned long low_pfn, unsigned long end_pfn, bool unevictable);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8e1be1c..d66efcb 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5669,7 +5669,8 @@ static unsigned long pfn_max_align_up(unsigned long pfn)
 }
 
 /* [start, end) must belong to a single zone. */
-static int __alloc_contig_migrate_range(unsigned long start, unsigned long end)
+static int __alloc_contig_migrate_range(struct compact_control *cc,
+					unsigned long start, unsigned long end)
 {
 	/* This function is based on compact_zone() from compaction.c. */
 	unsigned long nr_reclaimed;
@@ -5677,26 +5678,17 @@ static int __alloc_contig_migrate_range(unsigned long start, unsigned long end)
 	unsigned int tries = 0;
 	int ret = 0;
 
-	struct compact_control cc = {
-		.nr_migratepages = 0,
-		.order = -1,
-		.zone = page_zone(pfn_to_page(start)),
-		.sync = true,
-		.ignore_skip_hint = true,
-	};
-	INIT_LIST_HEAD(&cc.migratepages);
-
 	migrate_prep_local();
 
-	while (pfn < end || !list_empty(&cc.migratepages)) {
+	while (pfn < end || !list_empty(&cc->migratepages)) {
 		if (fatal_signal_pending(current)) {
 			ret = -EINTR;
 			break;
 		}
 
-		if (list_empty(&cc.migratepages)) {
-			cc.nr_migratepages = 0;
-			pfn = isolate_migratepages_range(cc.zone, &cc,
+		if (list_empty(&cc->migratepages)) {
+			cc->nr_migratepages = 0;
+			pfn = isolate_migratepages_range(cc->zone, cc,
 							 pfn, end, true);
 			if (!pfn) {
 				ret = -EINTR;
@@ -5708,16 +5700,16 @@ static int __alloc_contig_migrate_range(unsigned long start, unsigned long end)
 			break;
 		}
 
-		nr_reclaimed = reclaim_clean_pages_from_list(cc.zone,
-							&cc.migratepages);
-		cc.nr_migratepages -= nr_reclaimed;
+		nr_reclaimed = reclaim_clean_pages_from_list(cc->zone,
+							&cc->migratepages);
+		cc->nr_migratepages -= nr_reclaimed;
 
-		ret = migrate_pages(&cc.migratepages,
+		ret = migrate_pages(&cc->migratepages,
 				    alloc_migrate_target,
 				    0, false, MIGRATE_SYNC);
 	}
 
-	putback_lru_pages(&cc.migratepages);
+	putback_lru_pages(&cc->migratepages);
 	return ret > 0 ? 0 : ret;
 }
 
@@ -5796,6 +5788,15 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 	unsigned long outer_start, outer_end;
 	int ret = 0, order;
 
+	struct compact_control cc = {
+		.nr_migratepages = 0,
+		.order = -1,
+		.zone = page_zone(pfn_to_page(start)),
+		.sync = true,
+		.ignore_skip_hint = true,
+	};
+	INIT_LIST_HEAD(&cc.migratepages);
+
 	/*
 	 * What we do here is we mark all pageblocks in range as
 	 * MIGRATE_ISOLATE.  Because pageblock and max order pages may
@@ -5825,7 +5826,7 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 	if (ret)
 		goto done;
 
-	ret = __alloc_contig_migrate_range(start, end);
+	ret = __alloc_contig_migrate_range(&cc, start, end);
 	if (ret)
 		goto done;
 
@@ -5874,7 +5875,7 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 	__reclaim_pages(zone, GFP_HIGHUSER_MOVABLE, end-start);
 
 	/* Grab isolated pages from freelists. */
-	outer_end = isolate_freepages_range(outer_start, end);
+	outer_end = isolate_freepages_range(&cc, outer_start, end);
 	if (!outer_end) {
 		ret = -EBUSY;
 		goto done;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
