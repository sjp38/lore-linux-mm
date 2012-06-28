Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 125766B005A
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 23:38:15 -0400 (EDT)
Date: Wed, 27 Jun 2012 23:37:42 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH -mm] mm: have order>0 compaction start off where it left
Message-ID: <20120627233742.53225fc7@annuminas.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, kamezawa.hiroyu@jp.fujitsu.com, minchan@kernel.org, linux-kernel@vger.kernel.org, jaschut@sandia.gov

Order > 0 compaction stops when enough free pages of the correct
page order have been coalesced. When doing subsequent higher order
allocations, it is possible for compaction to be invoked many times.

However, the compaction code always starts out looking for things to
compact at the start of the zone, and for free pages to compact things
to at the end of the zone.

This can cause quadratic behaviour, with isolate_freepages starting
at the end of the zone each time, even though previous invocations
of the compaction code already filled up all free memory on that end
of the zone.

This can cause isolate_freepages to take enormous amounts of CPU
with certain workloads on larger memory systems.

The obvious solution is to have isolate_freepages remember where
it left off last time, and continue at that point the next time
it gets invoked for an order > 0 compaction. This could cause
compaction to fail if cc->free_pfn and cc->migrate_pfn are close
together initially, in that case we restart from the end of the
zone and try once more.

Forced full (order == -1) compactions are left alone.

Reported-by: Jim Schutt <jaschut@sandia.gov>
Signed-off-by: Rik van Riel <riel@redhat.com>
---
CAUTION: due to the time of day, I have only COMPILE tested this code

 include/linux/mmzone.h |    4 ++++
 mm/compaction.c        |   25 +++++++++++++++++++++++--
 mm/internal.h          |    1 +
 mm/page_alloc.c        |    4 ++++
 4 files changed, 32 insertions(+), 2 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 2427706..b8a5c36 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -369,6 +369,10 @@ struct zone {
 	 */
 	spinlock_t		lock;
 	int                     all_unreclaimable; /* All pages pinned */
+#if defined CONFIG_COMPACTION || defined CONFIG_CMA
+	/* pfn where the last order > 0 compaction isolated free pages */
+	unsigned long		last_free_pfn;
+#endif
 #ifdef CONFIG_MEMORY_HOTPLUG
 	/* see spanned/present_pages for more description */
 	seqlock_t		span_seqlock;
diff --git a/mm/compaction.c b/mm/compaction.c
index 7ea259d..0e9e995 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -422,6 +422,10 @@ static void isolate_freepages(struct zone *zone,
 					pfn -= pageblock_nr_pages) {
 		unsigned long isolated;
 
+		/* Skip ahead if somebody else is compacting simultaneously. */
+		if (cc->order > 0)
+			pfn = min(pfn, zone->last_free_pfn);
+
 		if (!pfn_valid(pfn))
 			continue;
 
@@ -463,6 +467,8 @@ static void isolate_freepages(struct zone *zone,
 		 */
 		if (isolated)
 			high_pfn = max(high_pfn, pfn);
+		if (cc->order > 0)
+			zone->last_free_pfn = high_pfn;
 	}
 
 	/* split_free_page does not map the pages */
@@ -565,9 +571,24 @@ static int compact_finished(struct zone *zone,
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
+		if (cc->order > 0 && !cc->last_round) {
+			/* We started partway through; restart at the end. */
+			unsigned long free_pfn;
+			free_pfn = zone->zone_start_pfn + zone->spanned_pages;
+			free_pfn &= ~(pageblock_nr_pages-1);
+			zone->last_free_pfn = free_pfn;
+			cc->last_round = 1;
+			return COMPACT_CONTINUE;
+		}
 		return COMPACT_COMPLETE;
+	}
 
 	/*
 	 * order == -1 is expected when compacting via
diff --git a/mm/internal.h b/mm/internal.h
index 2ba87fb..b041874 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -120,6 +120,7 @@ struct compact_control {
 	unsigned long free_pfn;		/* isolate_freepages search base */
 	unsigned long migrate_pfn;	/* isolate_migratepages search base */
 	bool sync;			/* Synchronous migration */
+	bool last_round;		/* Last round for order>0 compaction */
 
 	int order;			/* order a direct compactor needs */
 	int migratetype;		/* MOVABLE, RECLAIMABLE etc */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4403009..86de652 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4394,6 +4394,10 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 
 		zone->spanned_pages = size;
 		zone->present_pages = realsize;
+#if defined CONFIG_COMPACTION || defined CONFIG_CMA
+		zone->last_free_pfn = zone->zone_start_pfn + zone->spanned_pages;
+		zone->last_free_pfn &= ~(pageblock_nr_pages-1);
+#endif
 #ifdef CONFIG_NUMA
 		zone->node = nid;
 		zone->min_unmapped_pages = (realsize*sysctl_min_unmapped_ratio)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
