Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A37D96B02BB
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 04:00:42 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 2/3] mm: page allocator: Calculate a better estimate of NR_FREE_PAGES when memory is low and kswapd is awake
Date: Mon, 23 Aug 2010 09:00:41 +0100
Message-Id: <1282550442-15193-3-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1282550442-15193-1-git-send-email-mel@csn.ul.ie>
References: <1282550442-15193-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Ordinarily watermark checks are based on the vmstat NR_FREE_PAGES as
it is cheaper than scanning a number of lists. To avoid synchronization
overhead, counter deltas are maintained on a per-cpu basis and drained both
periodically and when the delta is above a threshold. On large CPU systems,
the difference between the estimated and real value of NR_FREE_PAGES can be
very high.  If NR_FREE_PAGES is much higher than number of real free page
in buddy, the VM can allocate pages below min watermark, at worst reducing
the real number of pages to zero.  Even if the OOM killer kills some victim
for freeing memory, it may not free memory if the exit path requires a new
page resulting in livelock.

This patch introduces zone_nr_free_pages() to take a slightly more accurate
estimate of NR_FREE_PAGES while kswapd is awake. The estimate is not perfect
and may result in cache line bounces but is expected to be lighter than the
IPI calls necessary to continually drain the per-cpu counters while kswapd
is awake.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/mmzone.h |   13 +++++++++++++
 mm/mmzone.c            |   29 +++++++++++++++++++++++++++++
 mm/page_alloc.c        |    4 ++--
 mm/vmstat.c            |   15 ++++++++++++++-
 4 files changed, 58 insertions(+), 3 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 6e6e626..3984c4e 100644
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
@@ -441,6 +448,12 @@ static inline int zone_is_oom_locked(const struct zone *zone)
 	return test_bit(ZONE_OOM_LOCKED, &zone->flags);
 }
 
+#ifdef CONFIG_SMP
+unsigned long zone_nr_free_pages(struct zone *zone);
+#else
+#define zone_nr_free_pages(zone) zone_page_state(zone, NR_FREE_PAGES)
+#endif /* CONFIG_SMP */
+
 /*
  * The "priority" of VM scanning is how much of the queues we will scan in one
  * go. A value of 12 for DEF_PRIORITY implies that we will scan 1/4096th of the
diff --git a/mm/mmzone.c b/mm/mmzone.c
index f5b7d17..69ecbe9 100644
--- a/mm/mmzone.c
+++ b/mm/mmzone.c
@@ -87,3 +87,32 @@ int memmap_valid_within(unsigned long pfn,
 	return 1;
 }
 #endif /* CONFIG_ARCH_HAS_HOLES_MEMORYMODEL */
+
+#ifdef CONFIG_SMP
+/* Called when a more accurate view of NR_FREE_PAGES is needed */
+unsigned long zone_nr_free_pages(struct zone *zone)
+{
+	unsigned long nr_free_pages = zone_page_state(zone, NR_FREE_PAGES);
+
+	/*
+	 * While kswapd is awake, it is considered the zone is under some
+	 * memory pressure. Under pressure, there is a risk that
+	 * per-cpu-counter-drift will allow the min watermark to be breached
+	 * potentially causing a live-lock. While kswapd is awake and
+	 * free pages are low, get a better estimate for free pages
+	 */
+	if (nr_free_pages < zone->percpu_drift_mark &&
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
+#endif /* CONFIG_SMP */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 97d74a0..bbaa959 100644
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
@@ -2424,7 +2424,7 @@ void show_free_areas(void)
 			" all_unreclaimable? %s"
 			"\n",
 			zone->name,
-			K(zone_page_state(zone, NR_FREE_PAGES)),
+			K(zone_nr_free_pages(zone)),
 			K(min_wmark_pages(zone)),
 			K(low_wmark_pages(zone)),
 			K(high_wmark_pages(zone)),
diff --git a/mm/vmstat.c b/mm/vmstat.c
index f389168..696cab2 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -138,11 +138,24 @@ static void refresh_zone_stat_thresholds(void)
 	int threshold;
 
 	for_each_populated_zone(zone) {
+		unsigned long max_drift, tolerate_drift;
+
 		threshold = calculate_threshold(zone);
 
 		for_each_online_cpu(cpu)
 			per_cpu_ptr(zone->pageset, cpu)->stat_threshold
 							= threshold;
+
+		/*
+		 * Only set percpu_drift_mark if there is a danger that
+		 * NR_FREE_PAGES reports the low watermark is ok when in fact
+		 * the min watermark could be breached by an allocation
+		 */
+		tolerate_drift = low_wmark_pages(zone) - min_wmark_pages(zone);
+		max_drift = num_online_cpus() * threshold;
+		if (max_drift > tolerate_drift)
+			zone->percpu_drift_mark = high_wmark_pages(zone) +
+					max_drift;
 	}
 }
 
@@ -813,7 +826,7 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
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
