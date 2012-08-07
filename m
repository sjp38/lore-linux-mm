Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id 76BA16B006E
	for <linux-mm@kvack.org>; Tue,  7 Aug 2012 08:31:25 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 5/6] mm: have order > 0 compaction start off where it left
Date: Tue,  7 Aug 2012 13:31:16 +0100
Message-Id: <1344342677-5845-6-git-send-email-mgorman@suse.de>
In-Reply-To: <1344342677-5845-1-git-send-email-mgorman@suse.de>
References: <1344342677-5845-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Jim Schutt <jaschut@sandia.gov>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: Rik van Riel <riel@redhat.com>

This commit is already upstream as [7db8889a: mm: have order > 0 compaction
start off where it left]. It's included in this series to provide context
to the next patch as the series is based on 3.5.

Order > 0 compaction stops when enough free pages of the correct page
order have been coalesced.  When doing subsequent higher order
allocations, it is possible for compaction to be invoked many times.

However, the compaction code always starts out looking for things to
compact at the start of the zone, and for free pages to compact things to
at the end of the zone.

This can cause quadratic behaviour, with isolate_freepages starting at the
end of the zone each time, even though previous invocations of the
compaction code already filled up all free memory on that end of the zone.

This can cause isolate_freepages to take enormous amounts of CPU with
certain workloads on larger memory systems.

The obvious solution is to have isolate_freepages remember where it left
off last time, and continue at that point the next time it gets invoked
for an order > 0 compaction.  This could cause compaction to fail if
cc->free_pfn and cc->migrate_pfn are close together initially, in that
case we restart from the end of the zone and try once more.

Forced full (order == -1) compactions are left alone.

[akpm@linux-foundation.org: checkpatch fixes]
[akpm@linux-foundation.org: s/laste/last/, use 80 cols]
Signed-off-by: Rik van Riel <riel@redhat.com>
Reported-by: Jim Schutt <jaschut@sandia.gov>
Tested-by: Jim Schutt <jaschut@sandia.gov>
Cc: Minchan Kim <minchan.kim@gmail.com>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Acked-by: Mel Gorman <mel@csn.ul.ie>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 include/linux/mmzone.h |    4 +++
 mm/compaction.c        |   63 ++++++++++++++++++++++++++++++++++++++++++++----
 mm/internal.h          |    6 +++++
 mm/page_alloc.c        |    5 ++++
 4 files changed, 73 insertions(+), 5 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 68c569f..6340f38 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -369,6 +369,10 @@ struct zone {
 	 */
 	spinlock_t		lock;
 	int                     all_unreclaimable; /* All pages pinned */
+#if defined CONFIG_COMPACTION || defined CONFIG_CMA
+	/* pfn where the last incremental compaction isolated free pages */
+	unsigned long		compact_cached_free_pfn;
+#endif
 #ifdef CONFIG_MEMORY_HOTPLUG
 	/* see spanned/present_pages for more description */
 	seqlock_t		span_seqlock;
diff --git a/mm/compaction.c b/mm/compaction.c
index 63af8d2..be310f1 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -457,6 +457,17 @@ static void isolate_freepages(struct zone *zone,
 					pfn -= pageblock_nr_pages) {
 		unsigned long isolated;
 
+		/*
+		 * Skip ahead if another thread is compacting in the area
+		 * simultaneously. If we wrapped around, we can only skip
+		 * ahead if zone->compact_cached_free_pfn also wrapped to
+		 * above our starting point.
+		 */
+		if (cc->order > 0 && (!cc->wrapped ||
+				      zone->compact_cached_free_pfn >
+				      cc->start_free_pfn))
+			pfn = min(pfn, zone->compact_cached_free_pfn);
+
 		if (!pfn_valid(pfn))
 			continue;
 
@@ -497,8 +508,11 @@ static void isolate_freepages(struct zone *zone,
 		 * looking for free pages, the search will restart here as
 		 * page migration may have returned some pages to the allocator
 		 */
-		if (isolated)
+		if (isolated) {
 			high_pfn = max(high_pfn, pfn);
+			if (cc->order > 0)
+				zone->compact_cached_free_pfn = high_pfn;
+		}
 	}
 
 	/* split_free_page does not map the pages */
@@ -593,6 +607,20 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 	return ISOLATE_SUCCESS;
 }
 
+/*
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
 static int compact_finished(struct zone *zone,
 			    struct compact_control *cc)
 {
@@ -601,8 +629,26 @@ static int compact_finished(struct zone *zone,
 	if (fatal_signal_pending(current))
 		return COMPACT_PARTIAL;
 
-	/* Compaction run completes if the migrate and free scanner meet */
-	if (cc->free_pfn <= cc->migrate_pfn)
+	/*
+	 * A full (order == -1) compaction run starts at the beginning and
+	 * end of a zone; it completes when the migrate and free scanner meet.
+	 * A partial (order > 0) compaction can start with the free scanner
+	 * at a random point in the zone, and may have to restart.
+	 */
+	if (cc->free_pfn <= cc->migrate_pfn) {
+		if (cc->order > 0 && !cc->wrapped) {
+			/* We started partway through; restart at the end. */
+			unsigned long free_pfn = start_free_pfn(zone);
+			zone->compact_cached_free_pfn = free_pfn;
+			cc->free_pfn = free_pfn;
+			cc->wrapped = 1;
+			return COMPACT_CONTINUE;
+		}
+		return COMPACT_COMPLETE;
+	}
+
+	/* We wrapped around and ended up where we started. */
+	if (cc->wrapped && cc->free_pfn <= cc->start_free_pfn)
 		return COMPACT_COMPLETE;
 
 	/*
@@ -708,8 +754,15 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 
 	/* Setup to move all movable pages to the end of the zone */
 	cc->migrate_pfn = zone->zone_start_pfn;
-	cc->free_pfn = cc->migrate_pfn + zone->spanned_pages;
-	cc->free_pfn &= ~(pageblock_nr_pages-1);
+
+	if (cc->order > 0) {
+		/* Incremental compaction. Start where the last one stopped. */
+		cc->free_pfn = zone->compact_cached_free_pfn;
+		cc->start_free_pfn = cc->free_pfn;
+	} else {
+		/* Order == -1 starts at the end of the zone. */
+		cc->free_pfn = start_free_pfn(zone);
+	}
 
 	migrate_prep_local();
 
diff --git a/mm/internal.h b/mm/internal.h
index 9156714..064f6ef 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -118,8 +118,14 @@ struct compact_control {
 	unsigned long nr_freepages;	/* Number of isolated free pages */
 	unsigned long nr_migratepages;	/* Number of pages to migrate */
 	unsigned long free_pfn;		/* isolate_freepages search base */
+	unsigned long start_free_pfn;	/* where we started the search */
 	unsigned long migrate_pfn;	/* isolate_migratepages search base */
 	bool sync;			/* Synchronous migration */
+	bool wrapped;			/* Order > 0 compactions are
+					   incremental, once free_pfn
+					   and migrate_pfn meet, we restart
+					   from the top of the zone;
+					   remember we wrapped around. */
 
 	int order;			/* order a direct compactor needs */
 	int migratetype;		/* MOVABLE, RECLAIMABLE etc */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index adc3aa8..781d6e4 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4425,6 +4425,11 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 
 		zone->spanned_pages = size;
 		zone->present_pages = realsize;
+#if defined CONFIG_COMPACTION || defined CONFIG_CMA
+		zone->compact_cached_free_pfn = zone->zone_start_pfn +
+						zone->spanned_pages;
+		zone->compact_cached_free_pfn &= ~(pageblock_nr_pages-1);
+#endif
 #ifdef CONFIG_NUMA
 		zone->node = nid;
 		zone->min_unmapped_pages = (realsize*sysctl_min_unmapped_ratio)
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
