Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3C6576B00D3
	for <linux-mm@kvack.org>; Tue, 12 Oct 2010 12:25:43 -0400 (EDT)
Date: Tue, 12 Oct 2010 17:25:26 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: zone state overhead
Message-ID: <20101012162526.GG30667@csn.ul.ie>
References: <20100928050801.GA29021@sli10-conroe.sh.intel.com> <20101008152953.GB3315@csn.ul.ie> <20101009005807.GA28793@sli10-conroe.sh.intel.com> <20101011085647.GA30667@csn.ul.ie> <20101012010514.GA20065@sli10-conroe.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20101012010514.GA20065@sli10-conroe.sh.intel.com>
Sender: owner-linux-mm@kvack.org
To: Shaohua Li <shaohua.li@intel.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "cl@linux.com" <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

> > > > > In a 4 socket 64 CPU system, zone_nr_free_pages() takes about 5% ~ 10% cpu time
> > > > > according to perf when memory pressure is high. The workload does something
> > > > > like:
> > > > > for i in `seq 1 $nr_cpu`
> > > > > do
> > > > >         create_sparse_file $SPARSE_FILE-$i $((10 * mem / nr_cpu))
> > > > >         $USEMEM -f $SPARSE_FILE-$i -j 4096 --readonly $((10 * mem / nr_cpu)) &
> > > > > done
> > > > > this simply reads a sparse file for each CPU. Apparently the
> > > > > zone->percpu_drift_mark is too big, and guess zone_page_state_snapshot() makes
> > > > > a lot of cache bounce for ->vm_stat_diff[]. below is the zoneinfo for reference.
> > > > 
> > > > Would it be possible for you to post the oprofile report? I'm in the
> > > > early stages of trying to reproduce this locally based on your test
> > > > description. The first machine I tried showed that zone_nr_page_state
> > > > was consuming 0.26% of profile time with the vast bulk occupied by
> > > > do_mpage_readahead. See as follows
> > > > 
> > > > 1599339  53.3463  vmlinux-2.6.36-rc7-pcpudrift do_mpage_readpage
> > > > 131713    4.3933  vmlinux-2.6.36-rc7-pcpudrift __isolate_lru_page
> > > > 103958    3.4675  vmlinux-2.6.36-rc7-pcpudrift free_pcppages_bulk
> > > > 85024     2.8360  vmlinux-2.6.36-rc7-pcpudrift __rmqueue
> > > > 78697     2.6250  vmlinux-2.6.36-rc7-pcpudrift native_flush_tlb_others
> > > > 75678     2.5243  vmlinux-2.6.36-rc7-pcpudrift unlock_page
> > > > 68741     2.2929  vmlinux-2.6.36-rc7-pcpudrift get_page_from_freelist
> > > > 56043     1.8693  vmlinux-2.6.36-rc7-pcpudrift __alloc_pages_nodemask
> > > > 55863     1.8633  vmlinux-2.6.36-rc7-pcpudrift ____pagevec_lru_add
> > > > 46044     1.5358  vmlinux-2.6.36-rc7-pcpudrift radix_tree_delete
> > > > 44543     1.4857  vmlinux-2.6.36-rc7-pcpudrift shrink_page_list
> > > > 33636     1.1219  vmlinux-2.6.36-rc7-pcpudrift zone_watermark_ok
> > > > .....
> > > > 7855      0.2620  vmlinux-2.6.36-rc7-pcpudrift zone_nr_free_pages
> > > > 
> > > > The machine I am testing on is non-NUMA 4-core single socket and totally
> > > > different characteristics but I want to be sure I'm going more or less the
> > > > right direction with the reproduction case before trying to find a larger
> > > > machine.
> > > 
> > > Here it is. this is a 4 socket nahalem machine.
> > >            268160.00 57.2% _raw_spin_lock                      /lib/modules/2.6.36-rc5-shli+/build/vmlinux
> > >             40302.00  8.6% zone_nr_free_pages                  /lib/modules/2.6.36-rc5-shli+/build/vmlinux
> > >             36827.00  7.9% do_mpage_readpage                   /lib/modules/2.6.36-rc5-shli+/build/vmlinux
> > >             28011.00  6.0% _raw_spin_lock_irq                  /lib/modules/2.6.36-rc5-shli+/build/vmlinux
> > >             22973.00  4.9% flush_tlb_others_ipi                /lib/modules/2.6.36-rc5-shli+/build/vmlinux
> > >             10713.00  2.3% smp_invalidate_interrupt            /lib/modules/2.6.36-rc5-shli+/build/vmlinux
> > 
> > <SNIP>
> >
> Basically the similar test. I'm using Fengguang's test, please check attached
> file. I didn't enable lock stat or debug. The difference is my test is under a
> 4 socket system. In a 1 socket system, I don't see the issue too.
> 

Ok, finding a large enough machine was key here true enough. I don't
have access to Nehalem boxes but the same problem showed up on a large
ppc64 machine (8 socket, interestingly enough a 3 socket did not have any
significant problem).  Based on that, I reproduced the problem and came up
with the patch below.

Christoph, can you look at this please? I know you had concerns about adjusting
thresholds as being an expensive operation but the patch limits how often it
occurs and it seems better than reducing thresholds for the full lifetime of
the system just to avoid counter drift. What I did find with the patch that
the overhead of __mod_zone_page_state() increases because of the temporarily
reduced threshold. It goes from 0.0403% of profile time to 0.0967% on one
machine and from 0.0677% to 0.43% on another. As this is just while kswapd
is awake, it seems withiin an acceptable margin but it is a caution against
simply reducing the existing thresholds. What is more relevant is the time
to complete the benchmark is increased due to the reduction of the thresholds.
This is a tradeoff between being fast and safe but I'm open to
suggestions on how high a safe threshold might be.

Shaohua, can you test keeping an eye out for any additional function
that is now taking a lot more CPU time?

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

Reported-by: Shaohua Li <shaohua.li@intel.com>
Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 include/linux/mmzone.h |    6 ------
 include/linux/vmstat.h |    2 ++
 mm/mmzone.c            |   21 ---------------------
 mm/page_alloc.c        |    4 ++--
 mm/vmscan.c            |    2 ++
 mm/vmstat.c            |   42 +++++++++++++++++++++++++++++++++++++++++-
 6 files changed, 47 insertions(+), 30 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 3984c4e..343fd5c 100644
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
index a8cfa9c..a9b4542 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1462,7 +1462,7 @@ int zone_watermark_ok(struct zone *z, int order, unsigned long mark,
 {
 	/* free_pages my go negative - that's OK */
 	long min = mark;
-	long free_pages = zone_nr_free_pages(z) - (1 << order) + 1;
+	long free_pages = zone_page_state(z, NR_FREE_PAGES) - (1 << order) + 1;
 	int o;
 
 	if (alloc_flags & ALLOC_HIGH)
@@ -2436,7 +2436,7 @@ void show_free_areas(void)
 			" all_unreclaimable? %s"
 			"\n",
 			zone->name,
-			K(zone_nr_free_pages(zone)),
+			K(zone_page_state(zone, NR_FREE_PAGES)),
 			K(min_wmark_pages(zone)),
 			K(low_wmark_pages(zone)),
 			K(high_wmark_pages(zone)),
diff --git a/mm/vmscan.c b/mm/vmscan.c
index c5dfabf..47ba29e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
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
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 355a9e6..19bd4a1 100644
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
@@ -159,6 +165,40 @@ static void refresh_zone_stat_thresholds(void)
 	}
 }
 
+void disable_pgdat_percpu_threshold(pg_data_t *pgdat)
+{
+	struct zone *zone;
+	int cpu;
+	int threshold;
+
+	for_each_populated_zone(zone) {
+		if (!zone->percpu_drift_mark || zone->zone_pgdat != pgdat)
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
+
+	for_each_populated_zone(zone) {
+		if (!zone->percpu_drift_mark || zone->zone_pgdat != pgdat)
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
@@ -826,7 +866,7 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
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
