Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6ED996B004A
	for <linux-mm@kvack.org>; Tue, 21 Sep 2010 10:23:25 -0400 (EDT)
Date: Tue, 21 Sep 2010 15:23:09 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [stable] [PATCH 0/3] Reduce watermark-related problems with
	the per-cpu allocator V4
Message-ID: <20100921142309.GA31813@csn.ul.ie>
References: <1283504926-2120-1-git-send-email-mel@csn.ul.ie> <20100903160551.05db4a92.akpm@linux-foundation.org> <20100921111741.GB11439@csn.ul.ie> <20100921125814.GF1205@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100921125814.GF1205@kroah.com>
Sender: owner-linux-mm@kvack.org
To: Greg KH <greg@kroah.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Linux Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, stable@kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, Sep 21, 2010 at 05:58:14AM -0700, Greg KH wrote:
> On Tue, Sep 21, 2010 at 12:17:41PM +0100, Mel Gorman wrote:
> > On Fri, Sep 03, 2010 at 04:05:51PM -0700, Andrew Morton wrote:
> > > On Fri,  3 Sep 2010 10:08:43 +0100
> > > Mel Gorman <mel@csn.ul.ie> wrote:
> > > 
> > > > The noteworthy change is to patch 2 which now uses the generic
> > > > zone_page_state_snapshot() in zone_nr_free_pages(). Similar logic still
> > > > applies for *when* zone_page_state_snapshot() to avoid ovedhead.
> > > > 
> > > > Changelog since V3
> > > >   o Use generic helper for NR_FREE_PAGES estimate when necessary
> > > > 
> > > > Changelog since V2
> > > >   o Minor clarifications
> > > >   o Rebase to 2.6.36-rc3
> > > > 
> > > > Changelog since V1
> > > >   o Fix for !CONFIG_SMP
> > > >   o Correct spelling mistakes
> > > >   o Clarify a ChangeLog
> > > >   o Only check for counter drift on machines large enough for the counter
> > > >     drift to breach the min watermark when NR_FREE_PAGES report the low
> > > >     watermark is fine
> > > > 
> > > > Internal IBM test teams beta testing distribution kernels have reported
> > > > problems on machines with a large number of CPUs whereby page allocator
> > > > failure messages show huge differences between the nr_free_pages vmstat
> > > > counter and what is available on the buddy lists. In an extreme example,
> > > > nr_free_pages was above the min watermark but zero pages were on the buddy
> > > > lists allowing the system to potentially livelock unable to make forward
> > > > progress unless an allocation succeeds. There is no reason why the problems
> > > > would not affect mainline so the following series mitigates the problems
> > > > in the page allocator related to to per-cpu counter drift and lists.
> > > > 
> > > > The first patch ensures that counters are updated after pages are added to
> > > > free lists.
> > > > 
> > > > The second patch notes that the counter drift between nr_free_pages and what
> > > > is on the per-cpu lists can be very high. When memory is low and kswapd
> > > > is awake, the per-cpu counters are checked as well as reading the value
> > > > of NR_FREE_PAGES. This will slow the page allocator when memory is low and
> > > > kswapd is awake but it will be much harder to breach the min watermark and
> > > > potentially livelock the system.
> > > > 
> > > > The third patch notes that after direct-reclaim an allocation can
> > > > fail because the necessary pages are on the per-cpu lists. After a
> > > > direct-reclaim-and-allocation-failure, the per-cpu lists are drained and
> > > > a second attempt is made.
> > > > 
> > > > Performance tests against 2.6.36-rc3 did not show up anything interesting. A
> > > > version of this series that continually called vmstat_update() when
> > > > memory was low was tested internally and found to help the counter drift
> > > > problem. I described this during LSF/MM Summit and the potential for IPI
> > > > storms was frowned upon. An alternative fix is in patch two which uses
> > > > for_each_online_cpu() to read the vmstat deltas while memory is low and
> > > > kswapd is awake. This should be functionally similar.
> > > > 
> > > > This patch should be merged after the patch "vmstat : update
> > > > zone stat threshold at onlining a cpu" which is in mmotm as
> > > > vmstat-update-zone-stat-threshold-when-onlining-a-cpu.patch .
> > > > 
> > > > If we can agree on it, this series is a stable candidate.
> > > 
> > > (cc stable@kernel.org)
> > > 
> > > >  include/linux/mmzone.h |   13 +++++++++++++
> > > >  include/linux/vmstat.h |   22 ++++++++++++++++++++++
> > > >  mm/mmzone.c            |   21 +++++++++++++++++++++
> > > >  mm/page_alloc.c        |   29 +++++++++++++++++++++--------
> > > >  mm/vmstat.c            |   15 ++++++++++++++-
> > > >  5 files changed, 91 insertions(+), 9 deletions(-)
> > > 
> > > For the entire patch series I get
> > > 
> > >  include/linux/mmzone.h |   13 +++++++++++++
> > >  include/linux/vmstat.h |   22 ++++++++++++++++++++++
> > >  mm/mmzone.c            |   21 +++++++++++++++++++++
> > >  mm/page_alloc.c        |   33 +++++++++++++++++++++++----------
> > >  mm/vmstat.c            |   16 +++++++++++++++-
> > >  5 files changed, 94 insertions(+), 11 deletions(-)
> > > 
> > > The patches do apply OK to 2.6.35.
> > > 
> > > Give the extent and the coreness of it all, it's a bit more than I'd
> > > usually push at the -stable guys.  But I guess that if the patches fix
> > > all the issues you've noted, as well as David's "minute-long livelocks
> > > in memory reclaim" then yup, it's worth backporting it all.
> > > 
> > 
> > These patches have made it to mainline as the following commits.
> > 
> > 9ee493c mm: page allocator: drain per-cpu lists after direct reclaim allocation fails
> > aa45484 mm: page allocator: calculate a better estimate of NR_FREE_PAGES when memory is low and kswapd is awake
> > 72853e2 mm: page allocator: update free page counters after pages are placed on the free list
> > 
> > I have not heard from the -stable guys, is there a reasonable
> > expectation that they'll be picked up?
> 
> If you ask me, then I'll know to give a response :)
> 

Hi Greg,

I would ask you directly but I didn't want anyone else on stable@ to
feel left out :)

> None of these were tagged as going to the stable tree, should I include
> them? 

Yes please unless there is a late objection. The patches were first developed
as a result of a distro bug whose kernel was based on 2.6.32.  There was
every indication this affected mainline as well. The details of the testing
are above.

Dave Chinner had also reported problems with livelocks in reclaim that
looked like IPI storms. There were two major factors at play and these
patches addressed one of them. It works out as both a bug and a
performance fix.

> If so, for which -stable tree?  .27, .32, and .35 are all
> currently active.
> 

2.6.35 for certain.

I would have a strong preference for 2.6.32 as well as it's a baseline for
a number of distros. The second commit will conflict with per-cpu changes
but the resolution is straight-forward.

In mm/vmstat.c, the correct per-cpu related line that conflicts should
look like

	zone_pcp(zone, cpu)->stat_threshold = threshold;

vmstat.h will fail to build again due to per-cpu changes. A rebased
version looks like

static inline unsigned long zone_page_state_snapshot(struct zone *zone,
                                        enum zone_stat_item item)
{
        long x = atomic_long_read(&zone->vm_stat[item]);

#ifdef CONFIG_SMP
        int cpu;
        for_each_online_cpu(cpu)
                x += zone_pcp(zone, cpu)->vm_stat_diff[item];

        if (x < 0)
                x = 0;
#endif
        return x;
}

A rebased version of patch 2 against 2.6.32.21 is below.

I do not know who the users of 2.6.27.x are so I have no strong opinions
on whether they need these patches or not.

Thanks Greg.

==== CUT HERE ====
mm: page allocator: calculate a better estimate of NR_FREE_PAGES when memory is low and kswapd is awake

Ordinarily watermark checks are based on the vmstat NR_FREE_PAGES as it is
cheaper than scanning a number of lists.  To avoid synchronization
overhead, counter deltas are maintained on a per-cpu basis and drained
both periodically and when the delta is above a threshold.  On large CPU
systems, the difference between the estimated and real value of
NR_FREE_PAGES can be very high.  If NR_FREE_PAGES is much higher than
number of real free page in buddy, the VM can allocate pages below min
watermark, at worst reducing the real number of pages to zero.  Even if
the OOM killer kills some victim for freeing memory, it may not free
memory if the exit path requires a new page resulting in livelock.

This patch introduces a zone_page_state_snapshot() function (courtesy of
Christoph) that takes a slightly more accurate view of an arbitrary vmstat
counter.  It is used to read NR_FREE_PAGES while kswapd is awake to avoid
the watermark being accidentally broken.  The estimate is not perfect and
may result in cache line bounces but is expected to be lighter than the
IPI calls necessary to continually drain the per-cpu counters while kswapd
is awake.

Signed-off-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>

Conflicts:

	mm/vmstat.c
---
 include/linux/mmzone.h |   13 +++++++++++++
 include/linux/vmstat.h |   22 ++++++++++++++++++++++
 mm/mmzone.c            |   21 +++++++++++++++++++++
 mm/page_alloc.c        |    4 ++--
 mm/vmstat.c            |   15 ++++++++++++++-
 5 files changed, 72 insertions(+), 3 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 6f75617..6c31a2a 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -290,6 +290,13 @@ struct zone {
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
@@ -460,6 +467,12 @@ static inline int zone_is_oom_locked(const struct zone *zone)
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
diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index 2d0f222..13070d6 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -166,6 +166,28 @@ static inline unsigned long zone_page_state(struct zone *zone,
 	return x;
 }
 
+/*
+ * More accurate version that also considers the currently pending
+ * deltas. For that we need to loop over all cpus to find the current
+ * deltas. There is no synchronization so the result cannot be
+ * exactly accurate either.
+ */
+static inline unsigned long zone_page_state_snapshot(struct zone *zone,
+					enum zone_stat_item item)
+{
+	long x = atomic_long_read(&zone->vm_stat[item]);
+
+#ifdef CONFIG_SMP
+	int cpu;
+	for_each_online_cpu(cpu)
+		x += zone_pcp(zone, cpu)->vm_stat_diff[item];
+
+	if (x < 0)
+		x = 0;
+#endif
+	return x;
+}
+
 extern unsigned long global_reclaimable_pages(void);
 extern unsigned long zone_reclaimable_pages(struct zone *zone);
 
diff --git a/mm/mmzone.c b/mm/mmzone.c
index f5b7d17..e35bfb8 100644
--- a/mm/mmzone.c
+++ b/mm/mmzone.c
@@ -87,3 +87,24 @@ int memmap_valid_within(unsigned long pfn,
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
+			!waitqueue_active(&zone->zone_pgdat->kswapd_wait))
+		return zone_page_state_snapshot(zone, NR_FREE_PAGES);
+
+	return nr_free_pages;
+}
+#endif /* CONFIG_SMP */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 542fc4d..ed53cfd 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1366,7 +1366,7 @@ int zone_watermark_ok(struct zone *z, int order, unsigned long mark,
 {
 	/* free_pages my go negative - that's OK */
 	long min = mark;
-	long free_pages = zone_page_state(z, NR_FREE_PAGES) - (1 << order) + 1;
+	long free_pages = zone_nr_free_pages(z) - (1 << order) + 1;
 	int o;
 
 	if (alloc_flags & ALLOC_HIGH)
@@ -2239,7 +2239,7 @@ void show_free_areas(void)
 			" all_unreclaimable? %s"
 			"\n",
 			zone->name,
-			K(zone_page_state(zone, NR_FREE_PAGES)),
+			K(zone_nr_free_pages(zone)),
 			K(min_wmark_pages(zone)),
 			K(low_wmark_pages(zone)),
 			K(high_wmark_pages(zone)),
diff --git a/mm/vmstat.c b/mm/vmstat.c
index c81321f..42d76c6 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -136,10 +136,23 @@ static void refresh_zone_stat_thresholds(void)
 	int threshold;
 
 	for_each_populated_zone(zone) {
+		unsigned long max_drift, tolerate_drift;
+
 		threshold = calculate_threshold(zone);
 
 		for_each_online_cpu(cpu)
 			zone_pcp(zone, cpu)->stat_threshold = threshold;
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
 
@@ -715,7 +728,7 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
 		   "\n        scanned  %lu"
 		   "\n        spanned  %lu"
 		   "\n        present  %lu",
-		   zone_page_state(zone, NR_FREE_PAGES),
+		   zone_nr_free_pages(zone),
 		   min_wmark_pages(zone),
 		   low_wmark_pages(zone),
 		   high_wmark_pages(zone),

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
