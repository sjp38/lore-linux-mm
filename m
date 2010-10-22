Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 73CED6B0071
	for <linux-mm@kvack.org>; Fri, 22 Oct 2010 10:12:40 -0400 (EDT)
Date: Fri, 22 Oct 2010 15:12:23 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: zone state overhead
Message-ID: <20101022141223.GF2160@csn.ul.ie>
References: <20101014120804.8B8F.A69D9226@jp.fujitsu.com> <20101018103941.GX30667@csn.ul.ie> <20101019100658.A1B3.A69D9226@jp.fujitsu.com> <20101019090803.GF30667@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20101019090803.GF30667@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Shaohua Li <shaohua.li@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cl@linux.com" <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, Oct 19, 2010 at 10:08:03AM +0100, Mel Gorman wrote:
> On Tue, Oct 19, 2010 at 10:16:42AM +0900, KOSAKI Motohiro wrote:
> > > > In this case, wakeup_kswapd() don't wake kswapd because
> > > > 
> > > > ---------------------------------------------------------------------------------
> > > > void wakeup_kswapd(struct zone *zone, int order)
> > > > {
> > > >         pg_data_t *pgdat;
> > > > 
> > > >         if (!populated_zone(zone))
> > > >                 return;
> > > > 
> > > >         pgdat = zone->zone_pgdat;
> > > >         if (zone_watermark_ok(zone, order, low_wmark_pages(zone), 0, 0))
> > > >                 return;                          // HERE
> > > > ---------------------------------------------------------------------------------
> > > > 
> > > > So, if we take your approach, we need to know exact free pages in this.
> > > 
> > > Good point!
> > > 
> > > > But, zone_page_state_snapshot() is slow. that's dilemma.
> > > > 
> > > 
> > > Very true. I'm prototyping a version of the patch that keeps
> > > zone_page_state_snapshot but only uses is in wakeup_kswapd and
> > > sleeping_prematurely.
> > 
> > Ok, this might works. but note, if we are running IO intensive workload, wakeup_kswapd()
> > is called very frequently.
> 
> This is true. It is also necessary to alter wakeup_kswapd to minimise
> the number of times it calls zone_watermark_ok_safe(). It'll need
> careful review to be sure the new function is equivalent.
> 
> > because it is called even though allocation is succeed. we need to
> > request Shaohua run and mesure his problem workload. and can you please cc me
> > when you post next version? I hope to review it too.
> > 
> 
> Of course. I have the prototype ready but am waiting on tests at the
> moment. Unfortunately the necessary infrastructure has been unavailable for
> the last 18 hours to run the test but I'm hoping it gets fixed soon.
> 

The test machine finally came available again and the patch works as
expected. Here is the latest version. The main thing to look how for is
how wakeup_kswapd() is altered.

==== CUT HERE ====
mm: page allocator: Adjust the per-cpu counter threshold when memory is low

Commit [aa45484: calculate a better estimate of NR_FREE_PAGES when
memory is low] noted that watermarks were based on the vmstat
NR_FREE_PAGES. To avoid synchronization overhead, these counters are
maintained on a per-cpu basis and drained both periodically and when a
threshold is above a threshold. On large CPU systems, the difference
between the estimate and real value of NR_FREE_PAGES can be very high.
The system can get into a case where pages are allocated far below the
min watermark potentially causing livelock issues. The commit solved the
problem by taking a better reading of NR_FREE_PAGES when memory was low.

Unfortately, as reported by Shaohua Li this accurate reading can consume
a large amount of CPU time on systems with many sockets due to cache
line bouncing. This patch takes a different approach. For large machines
where counter drift might be unsafe and while kswapd is awake, the per-cpu
thresholds for the target pgdat are reduced to limit the level of drift
to what should be a safe level. This incurs a performance penalty in heavy
memory pressure by a factor that depends on the workload and the machine but
the machine should function correctly without accidentally exhausting all
memory on a node. There is an additional cost when kswapd wakes and sleeps
but the event is not expected to be frequent - in Shaohua's test case,
there was one recorded sleep and wake event at least.

To ensure that kswapd wakes up, a safe version of zone_watermark_ok() is
introduced that takes a more accurate reading of NR_FREE_PAGES when called
from wakeup_kswapd and when deciding whether it is really safe to go back
to sleep in sleeping_prematurely(). We are still using an expensive function
but limiting how often it is called.

When the test case is reproduced, the time spent in the watermark functions
is reduced. The following report is on the percentage of time spent
cumulatively spent in the functions zone_nr_free_pages(), zone_watermark_ok(),
__zone_watermark_ok(), zone_watermark_ok_safe(), zone_page_state_snapshot(),
zone_page_state().

vanilla                     10.6834%
disable-thresold             0.9153%

Reported-by: Shaohua Li <shaohua.li@intel.com>
Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 include/linux/mmzone.h |   10 +++-------
 include/linux/vmstat.h |    2 ++
 mm/mmzone.c            |   21 ---------------------
 mm/page_alloc.c        |   35 +++++++++++++++++++++++++++--------
 mm/vmscan.c            |   15 +++++++++------
 mm/vmstat.c            |   46 +++++++++++++++++++++++++++++++++++++++++++++-
 6 files changed, 86 insertions(+), 43 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 3984c4e..8d789d7 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -448,12 +448,6 @@ static inline int zone_is_oom_locked(const struct zone *zone)
 	return test_bit(ZONE_OOM_LOCKED, &zone->flags);
 }
 
-#ifdef CONFIG_SMP
-unsigned long zone_nr_free_pages(struct zone *zone);
-#else
-#define zone_nr_free_pages(zone) zone_page_state(zone, NR_FREE_PAGES)
-#endif /* CONFIG_SMP */
-
 /*
  * The "priority" of VM scanning is how much of the queues we will scan in one
  * go. A value of 12 for DEF_PRIORITY implies that we will scan 1/4096th of the
@@ -651,7 +645,9 @@ typedef struct pglist_data {
 extern struct mutex zonelists_mutex;
 void build_all_zonelists(void *data);
 void wakeup_kswapd(struct zone *zone, int order);
-int zone_watermark_ok(struct zone *z, int order, unsigned long mark,
+bool zone_watermark_ok(struct zone *z, int order, unsigned long mark,
+		int classzone_idx, int alloc_flags);
+bool zone_watermark_ok_safe(struct zone *z, int order, unsigned long mark,
 		int classzone_idx, int alloc_flags);
 enum memmap_context {
 	MEMMAP_EARLY,
diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index eaaea37..c67d333 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -254,6 +254,8 @@ extern void dec_zone_state(struct zone *, enum zone_stat_item);
 extern void __dec_zone_state(struct zone *, enum zone_stat_item);
 
 void refresh_cpu_vm_stats(int);
+void disable_pgdat_percpu_threshold(pg_data_t *pgdat);
+void enable_pgdat_percpu_threshold(pg_data_t *pgdat);
 #else /* CONFIG_SMP */
 
 /*
diff --git a/mm/mmzone.c b/mm/mmzone.c
index e35bfb8..f5b7d17 100644
--- a/mm/mmzone.c
+++ b/mm/mmzone.c
@@ -87,24 +87,3 @@ int memmap_valid_within(unsigned long pfn,
 	return 1;
 }
 #endif /* CONFIG_ARCH_HAS_HOLES_MEMORYMODEL */
-
-#ifdef CONFIG_SMP
-/* Called when a more accurate view of NR_FREE_PAGES is needed */
-unsigned long zone_nr_free_pages(struct zone *zone)
-{
-	unsigned long nr_free_pages = zone_page_state(zone, NR_FREE_PAGES);
-
-	/*
-	 * While kswapd is awake, it is considered the zone is under some
-	 * memory pressure. Under pressure, there is a risk that
-	 * per-cpu-counter-drift will allow the min watermark to be breached
-	 * potentially causing a live-lock. While kswapd is awake and
-	 * free pages are low, get a better estimate for free pages
-	 */
-	if (nr_free_pages < zone->percpu_drift_mark &&
-			!waitqueue_active(&zone->zone_pgdat->kswapd_wait))
-		return zone_page_state_snapshot(zone, NR_FREE_PAGES);
-
-	return nr_free_pages;
-}
-#endif /* CONFIG_SMP */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a8cfa9c..acffde3 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1454,24 +1454,24 @@ static inline int should_fail_alloc_page(gfp_t gfp_mask, unsigned int order)
 #endif /* CONFIG_FAIL_PAGE_ALLOC */
 
 /*
- * Return 1 if free pages are above 'mark'. This takes into account the order
+ * Return true if free pages are above 'mark'. This takes into account the order
  * of the allocation.
  */
-int zone_watermark_ok(struct zone *z, int order, unsigned long mark,
-		      int classzone_idx, int alloc_flags)
+bool __zone_watermark_ok(struct zone *z, int order, unsigned long mark,
+		      int classzone_idx, int alloc_flags, long free_pages)
 {
 	/* free_pages my go negative - that's OK */
 	long min = mark;
-	long free_pages = zone_nr_free_pages(z) - (1 << order) + 1;
 	int o;
 
+ 	free_pages -= (1 << order) + 1;
 	if (alloc_flags & ALLOC_HIGH)
 		min -= min / 2;
 	if (alloc_flags & ALLOC_HARDER)
 		min -= min / 4;
 
 	if (free_pages <= min + z->lowmem_reserve[classzone_idx])
-		return 0;
+		return false;
 	for (o = 0; o < order; o++) {
 		/* At the next order, this order's pages become unavailable */
 		free_pages -= z->free_area[o].nr_free << o;
@@ -1480,9 +1480,28 @@ int zone_watermark_ok(struct zone *z, int order, unsigned long mark,
 		min >>= 1;
 
 		if (free_pages <= min)
-			return 0;
+			return false;
 	}
-	return 1;
+	return true;
+}
+
+bool zone_watermark_ok(struct zone *z, int order, unsigned long mark,
+		      int classzone_idx, int alloc_flags)
+{
+	return __zone_watermark_ok(z, order, mark, classzone_idx, alloc_flags,
+					zone_page_state(z, NR_FREE_PAGES));
+}
+
+bool zone_watermark_ok_safe(struct zone *z, int order, unsigned long mark,
+		      int classzone_idx, int alloc_flags)
+{
+	long free_pages = zone_page_state(z, NR_FREE_PAGES);
+
+	if (z->percpu_drift_mark && free_pages < z->percpu_drift_mark)
+		free_pages = zone_page_state_snapshot(z, NR_FREE_PAGES);
+
+	return __zone_watermark_ok(z, order, mark, classzone_idx, alloc_flags,
+								free_pages);
 }
 
 #ifdef CONFIG_NUMA
@@ -2436,7 +2455,7 @@ void show_free_areas(void)
 			" all_unreclaimable? %s"
 			"\n",
 			zone->name,
-			K(zone_nr_free_pages(zone)),
+			K(zone_page_state(zone, NR_FREE_PAGES)),
 			K(min_wmark_pages(zone)),
 			K(low_wmark_pages(zone)),
 			K(high_wmark_pages(zone)),
diff --git a/mm/vmscan.c b/mm/vmscan.c
index c5dfabf..ba0c70a 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2082,7 +2082,7 @@ static int sleeping_prematurely(pg_data_t *pgdat, int order, long remaining)
 		if (zone->all_unreclaimable)
 			continue;
 
-		if (!zone_watermark_ok(zone, order, high_wmark_pages(zone),
+		if (!zone_watermark_ok_safe(zone, order, high_wmark_pages(zone),
 								0, 0))
 			return 1;
 	}
@@ -2378,7 +2378,9 @@ static int kswapd(void *p)
 				 */
 				if (!sleeping_prematurely(pgdat, order, remaining)) {
 					trace_mm_vmscan_kswapd_sleep(pgdat->node_id);
+					enable_pgdat_percpu_threshold(pgdat);
 					schedule();
+					disable_pgdat_percpu_threshold(pgdat);
 				} else {
 					if (remaining)
 						count_vm_event(KSWAPD_LOW_WMARK_HIT_QUICKLY);
@@ -2417,16 +2419,17 @@ void wakeup_kswapd(struct zone *zone, int order)
 	if (!populated_zone(zone))
 		return;
 
-	pgdat = zone->zone_pgdat;
-	if (zone_watermark_ok(zone, order, low_wmark_pages(zone), 0, 0))
+	if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
 		return;
+	pgdat = zone->zone_pgdat;
 	if (pgdat->kswapd_max_order < order)
 		pgdat->kswapd_max_order = order;
-	trace_mm_vmscan_wakeup_kswapd(pgdat->node_id, zone_idx(zone), order);
-	if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
-		return;
 	if (!waitqueue_active(&pgdat->kswapd_wait))
 		return;
+	if (zone_watermark_ok_safe(zone, order, low_wmark_pages(zone), 0, 0))
+		return;
+
+	trace_mm_vmscan_wakeup_kswapd(pgdat->node_id, zone_idx(zone), order);
 	wake_up_interruptible(&pgdat->kswapd_wait);
 }
 
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 355a9e6..ddee139 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -81,6 +81,12 @@ EXPORT_SYMBOL(vm_stat);
 
 #ifdef CONFIG_SMP
 
+static int calculate_pressure_threshold(struct zone *zone)
+{
+	return max(1, (int)((high_wmark_pages(zone) - low_wmark_pages(zone) /
+				num_online_cpus())));
+}
+
 static int calculate_threshold(struct zone *zone)
 {
 	int threshold;
@@ -159,6 +165,44 @@ static void refresh_zone_stat_thresholds(void)
 	}
 }
 
+void disable_pgdat_percpu_threshold(pg_data_t *pgdat)
+{
+	struct zone *zone;
+	int cpu;
+	int threshold;
+	int i;
+
+	for (i = 0; i < pgdat->nr_zones; i++) {
+		zone = &pgdat->node_zones[i];
+		if (!zone->percpu_drift_mark)
+			continue;
+
+		threshold = calculate_pressure_threshold(zone);
+		for_each_online_cpu(cpu)
+			per_cpu_ptr(zone->pageset, cpu)->stat_threshold
+							= threshold;
+	}
+}
+
+void enable_pgdat_percpu_threshold(pg_data_t *pgdat)
+{
+	struct zone *zone;
+	int cpu;
+	int threshold;
+	int i;
+
+	for (i = 0; i < pgdat->nr_zones; i++) {
+		zone = &pgdat->node_zones[i];
+		if (!zone->percpu_drift_mark)
+			continue;
+
+		threshold = calculate_threshold(zone);
+		for_each_online_cpu(cpu)
+			per_cpu_ptr(zone->pageset, cpu)->stat_threshold
+							= threshold;
+	}
+}
+
 /*
  * For use when we know that interrupts are disabled.
  */
@@ -826,7 +870,7 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
 		   "\n        scanned  %lu"
 		   "\n        spanned  %lu"
 		   "\n        present  %lu",
-		   zone_nr_free_pages(zone),
+		   zone_page_state(zone, NR_FREE_PAGES),
 		   min_wmark_pages(zone),
 		   low_wmark_pages(zone),
 		   high_wmark_pages(zone),

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
