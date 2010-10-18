Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id D29876B00B8
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 05:27:56 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9I9Rsj7008288
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 18 Oct 2010 18:27:54 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 02BA445DE4F
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 18:27:54 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C963045DE54
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 18:27:53 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B1B451DB803C
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 18:27:53 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6369D1DB803B
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 18:27:53 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [experimental][PATCH] mm,vmstat: per cpu stat flush too when per cpu page cache flushed
In-Reply-To: <alpine.DEB.2.00.1010151224370.24683@router.home>
References: <20101014114541.8B89.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1010151224370.24683@router.home>
Message-Id: <20101018182035.3AFB.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 18 Oct 2010 18:27:52 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Mel Gorman <mel@csn.ul.ie>, Shaohua Li <shaohua.li@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> On Thu, 14 Oct 2010, KOSAKI Motohiro wrote:
> 
> > Initial variable ZVC commit (df9ecaba3f1) says
> >
> > >     [PATCH] ZVC: Scale thresholds depending on the size of the system
> > >
> > >     The ZVC counter update threshold is currently set to a fixed value of 32.
> > >     This patch sets up the threshold depending on the number of processors and
> > >     the sizes of the zones in the system.
> > >
> > >     With the current threshold of 32, I was able to observe slight contention
> > >     when more than 130-140 processors concurrently updated the counters.  The
> > >     contention vanished when I either increased the threshold to 64 or used
> > >     Andrew's idea of overstepping the interval (see ZVC overstep patch).
> > >
> > >     However, we saw contention again at 220-230 processors.  So we need higher
> > >     values for larger systems.
> >
> > So, I'm worry about your patch reintroduce old cache contention issue that Christoph
> > observed when run 128-256cpus system.  May I ask how do you think this issue?
> 
> The load that I ran with was a test that concurrently faulted pages on a
> large number of processors. This is a bit artificial and is only of
> performance concern during startup of a large HPC job. The frequency of
> counter updates during regular processing should pose a much lighter load
> on the system. The automatic adaption of the thresholds should
> 
> 1. Preserve the initial startup performance (since the threshold will be
> unmodified on a system just starting).
> 
> 2. Reduce the overhead of establish a more accurate zone state (because
> reclaim can then cause the thresholds to be adapted).

One of idea is, limit number of drift cpus. because

256cpus:  125 x 256 x 4096 = 125MB  (ok, enough acceptable)
4096cpus: 125 x 4096 x 4096 = 2GB   (Agh, too big)

and, I think we can assume 4096cpus machine are used on cpusets or
virtualization or something else isolation mechanism.
then, practically there is never happen that all cpus access same zone
at same time.




---
 include/linux/mmzone.h |   16 ++---------
 include/linux/vmstat.h |    6 ++++
 mm/mmzone.c            |   20 --------------
 mm/page_alloc.c        |   10 ++++---
 mm/vmstat.c            |   67 +++++++++++++++++++++++++++++++++---------------
 5 files changed, 61 insertions(+), 58 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 39c24eb..699cdea 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -185,6 +185,7 @@ struct per_cpu_pageset {
 #ifdef CONFIG_SMP
 	s8 stat_threshold;
 	s8 vm_stat_diff[NR_VM_ZONE_STAT_ITEMS];
+	s8 vm_stat_drifted[NR_VM_ZONE_STAT_ITEMS];
 #endif
 };
 
@@ -286,13 +287,6 @@ struct zone {
 	unsigned long watermark[NR_WMARK];
 
 	/*
-	 * When free pages are below this point, additional steps are taken
-	 * when reading the number of free pages to avoid per-cpu counter
-	 * drift allowing watermarks to be breached
-	 */
-	unsigned long percpu_drift_mark;
-
-	/*
 	 * We don't know if the memory that we're going to allocate will be freeable
 	 * or/and it will be released eventually, so to avoid totally wasting several
 	 * GB of ram we must reserve some of the lower zone memory (otherwise we risk
@@ -355,6 +349,8 @@ struct zone {
 
 	/* Zone statistics */
 	atomic_long_t		vm_stat[NR_VM_ZONE_STAT_ITEMS];
+	atomic_t		drift_cpus_cur[NR_VM_ZONE_STAT_ITEMS];
+	int			drift_cpus_max;
 
 	/*
 	 * The target ratio of ACTIVE_ANON to INACTIVE_ANON pages on
@@ -458,12 +454,6 @@ static inline int zone_is_oom_locked(const struct zone *zone)
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
diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index 1997988..37f0917 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -28,6 +28,12 @@
 
 #define FOR_ALL_ZONES(xx) DMA_ZONE(xx) DMA32_ZONE(xx) xx##_NORMAL HIGHMEM_ZONE(xx) , xx##_MOVABLE
 
+#ifdef ARCH_MAX_DRIFT_CPUS
+#define MAX_DRIFT_CPUS ARCH_MAX_DRIFT_CPUS
+#else
+#define MAX_DRIFT_CPUS 256
+#endif
+
 enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		FOR_ALL_ZONES(PGALLOC),
 		PGFREE, PGACTIVATE, PGDEACTIVATE,
diff --git a/mm/mmzone.c b/mm/mmzone.c
index e35bfb8..54ce17b 100644
--- a/mm/mmzone.c
+++ b/mm/mmzone.c
@@ -88,23 +88,3 @@ int memmap_valid_within(unsigned long pfn,
 }
 #endif /* CONFIG_ARCH_HAS_HOLES_MEMORYMODEL */
 
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
index 222d8cc..f45aa19 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1464,7 +1464,7 @@ int zone_watermark_ok(struct zone *z, int order, unsigned long mark,
 {
 	/* free_pages my go negative - that's OK */
 	long min = mark;
-	long free_pages = zone_nr_free_pages(z) - (1 << order) + 1;
+	long free_pages = zone_page_state(z, NR_FREE_PAGES) - (1 << order) + 1;
 	int o;
 
 	if (alloc_flags & ALLOC_HIGH)
@@ -2438,7 +2438,7 @@ void show_free_areas(void)
 			" all_unreclaimable? %s"
 			"\n",
 			zone->name,
-			K(zone_nr_free_pages(zone)),
+			K(zone_page_state(zone, NR_FREE_PAGES)),
 			K(min_wmark_pages(zone)),
 			K(low_wmark_pages(zone)),
 			K(high_wmark_pages(zone)),
@@ -4895,10 +4895,12 @@ static void setup_per_zone_wmarks(void)
 	}
 
 	for_each_zone(zone) {
-		u64 tmp;
+		struct per_cpu_pageset *pcp = this_cpu_ptr(zone->pageset);
+		u64 maxdrift = zone->drift_cpus_max * pcp->stat_threshold;
+		u64 tmp = pages_min + maxdrift;
 
 		spin_lock_irqsave(&zone->lock, flags);
-		tmp = (u64)pages_min * zone->present_pages;
+		tmp *= zone->present_pages;
 		do_div(tmp, lowmem_pages);
 		if (is_highmem(zone)) {
 			/*
diff --git a/mm/vmstat.c b/mm/vmstat.c
index b6b7fed..673ca22 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -140,25 +140,32 @@ void refresh_zone_stat_thresholds(void)
 	int threshold;
 
 	for_each_populated_zone(zone) {
-		unsigned long max_drift, tolerate_drift;
-
+		zone->drift_cpus_max = min_t(int, num_online_cpus(),
+					     MAX_DRIFT_CPUS);
 		threshold = calculate_threshold(zone);
-
 		for_each_online_cpu(cpu)
 			per_cpu_ptr(zone->pageset, cpu)->stat_threshold
 							= threshold;
+	}
+}
 
-		/*
-		 * Only set percpu_drift_mark if there is a danger that
-		 * NR_FREE_PAGES reports the low watermark is ok when in fact
-		 * the min watermark could be breached by an allocation
-		 */
-		tolerate_drift = low_wmark_pages(zone) - min_wmark_pages(zone);
-		max_drift = num_online_cpus() * threshold;
-		if (max_drift > tolerate_drift)
-			zone->percpu_drift_mark = high_wmark_pages(zone) +
-					max_drift;
+static bool vm_stat_drift_take(struct zone *zone, enum zone_stat_item item)
+{
+	struct per_cpu_pageset *pcp = this_cpu_ptr(zone->pageset);
+	s8 *drifted = pcp->vm_stat_drifted + item;
+	atomic_t *cur = &zone->drift_cpus_cur[item];
+
+	if (likely(*drifted))
+		return true;
+
+	/* enter this slowpath only per sysctl_stat_interval. */
+
+	if (atomic_add_unless(cur, 1, zone->drift_cpus_max)) {
+		*drifted = 1;
+		return true;
 	}
+
+	return false;
 }
 
 /*
@@ -168,10 +175,14 @@ void __mod_zone_page_state(struct zone *zone, enum zone_stat_item item,
 				int delta)
 {
 	struct per_cpu_pageset *pcp = this_cpu_ptr(zone->pageset);
-
 	s8 *p = pcp->vm_stat_diff + item;
 	long x;
 
+	if (unlikely(!vm_stat_drift_take(zone, item))) {
+		zone_page_state_add(delta, zone, item);
+		return;
+	}
+
 	x = delta + *p;
 
 	if (unlikely(x > pcp->stat_threshold || x < -pcp->stat_threshold)) {
@@ -224,6 +235,11 @@ void __inc_zone_state(struct zone *zone, enum zone_stat_item item)
 	struct per_cpu_pageset *pcp = this_cpu_ptr(zone->pageset);
 	s8 *p = pcp->vm_stat_diff + item;
 
+	if (unlikely(!vm_stat_drift_take(zone, item))) {
+		zone_page_state_add(1, zone, item);
+		return;
+	}
+
 	(*p)++;
 
 	if (unlikely(*p > pcp->stat_threshold)) {
@@ -245,6 +261,11 @@ void __dec_zone_state(struct zone *zone, enum zone_stat_item item)
 	struct per_cpu_pageset *pcp = this_cpu_ptr(zone->pageset);
 	s8 *p = pcp->vm_stat_diff + item;
 
+	if (unlikely(!vm_stat_drift_take(zone, item))) {
+		zone_page_state_add(-1, zone, item);
+		return;
+	}
+
 	(*p)--;
 
 	if (unlikely(*p < - pcp->stat_threshold)) {
@@ -326,12 +347,16 @@ void refresh_cpu_vm_stats(int cpu)
 				unsigned long flags;
 				int v;
 
-				local_irq_save(flags);
-				v = p->vm_stat_diff[i];
-				p->vm_stat_diff[i] = 0;
-				local_irq_restore(flags);
-				atomic_long_add(v, &zone->vm_stat[i]);
-				global_diff[i] += v;
+				if (p->vm_stat_drifted[i]) {
+					local_irq_save(flags);
+					v = p->vm_stat_diff[i];
+					p->vm_stat_diff[i] = 0;
+					p->vm_stat_drifted[i] = 0;
+					local_irq_restore(flags);
+					atomic_long_add(v, &zone->vm_stat[i]);
+					global_diff[i] += v;
+				}
+
 #ifdef CONFIG_NUMA
 				/* 3 seconds idle till flush */
 				p->expire = 3;
@@ -834,7 +859,7 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
 		   "\n        scanned  %lu"
 		   "\n        spanned  %lu"
 		   "\n        present  %lu",
-		   zone_nr_free_pages(zone),
+		   zone_page_state(zone, NR_FREE_PAGES),
 		   min_wmark_pages(zone),
 		   low_wmark_pages(zone),
 		   high_wmark_pages(zone),
-- 
1.6.5.2




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
