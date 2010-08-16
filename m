Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id EBD8B6B01F1
	for <linux-mm@kvack.org>; Mon, 16 Aug 2010 05:42:16 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 2/3] mm: page allocator: Calculate a better estimate of NR_FREE_PAGES when memory is low and kswapd is awake
Date: Mon, 16 Aug 2010 10:42:12 +0100
Message-Id: <1281951733-29466-3-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1281951733-29466-1-git-send-email-mel@csn.ul.ie>
References: <1281951733-29466-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Ordinarily watermark checks are made based on the vmstat NR_FREE_PAGES as
it is cheaper than scanning a number of lists. To avoid synchronization
overhead, counter deltas are maintained on a per-cpu basis and drained both
periodically and when the delta is above a threshold. On large CPU systems,
the difference between the estimated and real value of NR_FREE_PAGES can be
very high. If the system is under both load and low memory, it's possible
for watermarks to be breached. In extreme cases, the number of free pages
can drop to 0 leading to the possibility of system livelock.

This patch introduces zone_nr_free_pages() to take a slightly more accurate
estimate of NR_FREE_PAGES while kswapd is awake.  The estimate is not perfect
and may result in cache line bounces but is expected to be lighter than the
IPI calls necessary to continually drain the per-cpu counters while kswapd
is awake.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 include/linux/mmzone.h |    9 +++++++++
 mm/mmzone.c            |   27 +++++++++++++++++++++++++++
 mm/page_alloc.c        |    4 ++--
 mm/vmstat.c            |    5 ++++-
 4 files changed, 42 insertions(+), 3 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index b4d109e..1df3c43 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -284,6 +284,13 @@ struct zone {
 	unsigned long watermark[NR_WMARK];
 
 	/*
+	 * When free pages are below this point, additional steps are taken
+	 * when reading the number of free pages to avoid per-cpu counter
+	 * drift allowing watermarks to be breached
+	 */
+	unsigned long percpu_drift_mark;
+
+	/*
 	 * We don't know if the memory that we're going to allocate will be freeable
 	 * or/and it will be released eventually, so to avoid totally wasting several
 	 * GB of ram we must reserve some of the lower zone memory (otherwise we risk
@@ -456,6 +463,8 @@ static inline int zone_is_oom_locked(const struct zone *zone)
 	return test_bit(ZONE_OOM_LOCKED, &zone->flags);
 }
 
+unsigned long zone_nr_free_pages(struct zone *zone);
+
 /*
  * The "priority" of VM scanning is how much of the queues we will scan in one
  * go. A value of 12 for DEF_PRIORITY implies that we will scan 1/4096th of the
diff --git a/mm/mmzone.c b/mm/mmzone.c
index f5b7d17..89842ec 100644
--- a/mm/mmzone.c
+++ b/mm/mmzone.c
@@ -87,3 +87,30 @@ int memmap_valid_within(unsigned long pfn,
 	return 1;
 }
 #endif /* CONFIG_ARCH_HAS_HOLES_MEMORYMODEL */
+
+/* Called when a more accurate view of NR_FREE_PAGES is needed */
+unsigned long zone_nr_free_pages(struct zone *zone)
+{
+	unsigned long nr_free_pages = zone_page_state(zone, NR_FREE_PAGES);
+
+	/*
+	 * While kswapd is awake, it is considered the zone is under some
+	 * memory pressure. Under pressure, there is a risk that
+	 * er-cpu-counter-drift will allow the min watermark to be breached
+	 * potentially causing a live-lock. While kswapd is awake and
+	 * free pages are low, get a better estimate for free pages
+	 */
+	if (free < zone->percpu_drift_mark &&
+			!waitqueue_active(&zone->zone_pgdat->kswapd_wait)) {
+		int cpu;
+
+		for_each_online_cpu(cpu) {
+			struct per_cpu_pageset *pset;
+
+			pset = per_cpu_ptr(zone->pageset, cpu);
+			nr_free_pages += pset->vm_stat_diff[NR_FREE_PAGES];
+		}
+	}
+
+	return nr_free_pages;
+}
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c2407a4..67a2ed0 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1462,7 +1462,7 @@ int zone_watermark_ok(struct zone *z, int order, unsigned long mark,
 {
 	/* free_pages my go negative - that's OK */
 	long min = mark;
-	long free_pages = zone_page_state(z, NR_FREE_PAGES) - (1 << order) + 1;
+	long free_pages = zone_nr_free_pages(z) - (1 << order) + 1;
 	int o;
 
 	if (alloc_flags & ALLOC_HIGH)
@@ -2413,7 +2413,7 @@ void show_free_areas(void)
 			" all_unreclaimable? %s"
 			"\n",
 			zone->name,
-			K(zone_page_state(zone, NR_FREE_PAGES)),
+			K(zone_nr_free_pages(zone)),
 			K(min_wmark_pages(zone)),
 			K(low_wmark_pages(zone)),
 			K(high_wmark_pages(zone)),
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 7759941..c95a159 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -143,6 +143,9 @@ static void refresh_zone_stat_thresholds(void)
 		for_each_online_cpu(cpu)
 			per_cpu_ptr(zone->pageset, cpu)->stat_threshold
 							= threshold;
+
+		zone->percpu_drift_mark = high_wmark_pages(zone) +
+					num_online_cpus() * threshold;
 	}
 }
 
@@ -813,7 +816,7 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
 		   "\n        scanned  %lu"
 		   "\n        spanned  %lu"
 		   "\n        present  %lu",
-		   zone_page_state(zone, NR_FREE_PAGES),
+		   zone_nr_free_pages(zone),
 		   min_wmark_pages(zone),
 		   low_wmark_pages(zone),
 		   high_wmark_pages(zone),
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
