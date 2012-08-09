Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id BD20B6B0069
	for <linux-mm@kvack.org>; Thu,  9 Aug 2012 09:49:32 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 5/5] mm: have order > 0 compaction start near a pageblock with free pages
Date: Thu,  9 Aug 2012 14:49:25 +0100
Message-Id: <1344520165-24419-6-git-send-email-mgorman@suse.de>
In-Reply-To: <1344520165-24419-1-git-send-email-mgorman@suse.de>
References: <1344520165-24419-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Jim Schutt <jaschut@sandia.gov>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

commit [7db8889a: mm: have order > 0 compaction start off where it left]
introduced a caching mechanism to reduce the amount work the free page
scanner does in compaction. However, it has a problem. Consider two process
simultaneously scanning free pages

				    			C
Process A		M     S     			F
		|---------------------------------------|
Process B		M 	FS

C is zone->compact_cached_free_pfn
S is cc->start_pfree_pfn
M is cc->migrate_pfn
F is cc->free_pfn

In this diagram, Process A has just reached its migrate scanner, wrapped
around and updated compact_cached_free_pfn accordingly.

Simultaneously, Process B finishes isolating in a block and updates
compact_cached_free_pfn again to the location of its free scanner.

Process A moves to "end_of_zone - one_pageblock" and runs this check

                if (cc->order > 0 && (!cc->wrapped ||
                                      zone->compact_cached_free_pfn >
                                      cc->start_free_pfn))
                        pfn = min(pfn, zone->compact_cached_free_pfn);

compact_cached_free_pfn is above where it started so the free scanner skips
almost the entire space it should have scanned. When there are multiple
processes compacting it can end in a situation where the entire zone is
not being scanned at all.  Further, it is possible for two processes to
ping-pong update to compact_cached_free_pfn which is just random.

Overall, the end result wrecks allocation success rates.

There is not an obvious way around this problem without introducing new
locking and state so this patch takes a different approach.

First, it gets rid of the skip logic because it's not clear that it matters
if two free scanners happen to be in the same block but with racing updates
it's too easy for it to skip over blocks it should not.

Second, it updates compact_cached_free_pfn in a more limited set of
circumstances.

If a scanner has wrapped, it updates compact_cached_free_pfn to the end
	of the zone. When a wrapped scanner isolates a page, it updates
	compact_cached_free_pfn to point to the highest pageblock it
	can isolate pages from.

If a scanner has not wrapped when it has finished isolated pages it
	checks if compact_cached_free_pfn is pointing to the end of the
	zone. If so, the value is updated to point to the highest
	pageblock that pages were isolated from. This value will not
	be updated again until a free page scanner wraps and resets
	compact_cached_free_pfn.

This is not optimal and it can still race but the compact_cached_free_pfn
will be pointing to or very near a pageblock with free pages.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Rik van Riel <riel@redhat.com>
Reviewed-by: Minchan Kim <minchan@kernel.org>
---
 mm/compaction.c |   54 ++++++++++++++++++++++++++++--------------------------
 1 file changed, 28 insertions(+), 26 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index a806a9c..c2d0958 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -437,6 +437,20 @@ static bool suitable_migration_target(struct page *page)
 }
 
 /*
+ * Returns the start pfn of the last page block in a zone.  This is the starting
+ * point for full compaction of a zone.  Compaction searches for free pages from
+ * the end of each zone, while isolate_freepages_block scans forward inside each
+ * page block.
+ */
+static unsigned long start_free_pfn(struct zone *zone)
+{
+	unsigned long free_pfn;
+	free_pfn = zone->zone_start_pfn + zone->spanned_pages;
+	free_pfn &= ~(pageblock_nr_pages-1);
+	return free_pfn;
+}
+
+/*
  * Based on information in the current compact_control, find blocks
  * suitable for isolating free pages from and then isolate them.
  */
@@ -475,17 +489,6 @@ static void isolate_freepages(struct zone *zone,
 					pfn -= pageblock_nr_pages) {
 		unsigned long isolated;
 
-		/*
-		 * Skip ahead if another thread is compacting in the area
-		 * simultaneously. If we wrapped around, we can only skip
-		 * ahead if zone->compact_cached_free_pfn also wrapped to
-		 * above our starting point.
-		 */
-		if (cc->order > 0 && (!cc->wrapped ||
-				      zone->compact_cached_free_pfn >
-				      cc->start_free_pfn))
-			pfn = min(pfn, zone->compact_cached_free_pfn);
-
 		if (!pfn_valid(pfn))
 			continue;
 
@@ -528,7 +531,15 @@ static void isolate_freepages(struct zone *zone,
 		 */
 		if (isolated) {
 			high_pfn = max(high_pfn, pfn);
-			if (cc->order > 0)
+
+			/*
+			 * If the free scanner has wrapped, update
+			 * compact_cached_free_pfn to point to the highest
+			 * pageblock with free pages. This reduces excessive
+			 * scanning of full pageblocks near the end of the
+			 * zone
+			 */
+			if (cc->order > 0 && cc->wrapped)
 				zone->compact_cached_free_pfn = high_pfn;
 		}
 	}
@@ -538,6 +549,11 @@ static void isolate_freepages(struct zone *zone,
 
 	cc->free_pfn = high_pfn;
 	cc->nr_freepages = nr_freepages;
+
+	/* If compact_cached_free_pfn is reset then set it now */
+	if (cc->order > 0 && !cc->wrapped &&
+			zone->compact_cached_free_pfn == start_free_pfn(zone))
+		zone->compact_cached_free_pfn = high_pfn;
 }
 
 /*
@@ -625,20 +641,6 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 	return ISOLATE_SUCCESS;
 }
 
-/*
- * Returns the start pfn of the last page block in a zone.  This is the starting
- * point for full compaction of a zone.  Compaction searches for free pages from
- * the end of each zone, while isolate_freepages_block scans forward inside each
- * page block.
- */
-static unsigned long start_free_pfn(struct zone *zone)
-{
-	unsigned long free_pfn;
-	free_pfn = zone->zone_start_pfn + zone->spanned_pages;
-	free_pfn &= ~(pageblock_nr_pages-1);
-	return free_pfn;
-}
-
 static int compact_finished(struct zone *zone,
 			    struct compact_control *cc)
 {
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
