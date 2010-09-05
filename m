Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 29B0B6B0047
	for <linux-mm@kvack.org>; Sun,  5 Sep 2010 14:13:00 -0400 (EDT)
Date: Sun, 5 Sep 2010 19:12:47 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/3] mm: page allocator: Calculate a better estimate of
	NR_FREE_PAGES when memory is low and kswapd is awake
Message-ID: <20100905181246.GF8384@csn.ul.ie>
References: <1283504926-2120-1-git-send-email-mel@csn.ul.ie> <1283504926-2120-3-git-send-email-mel@csn.ul.ie> <20100903155537.41f1a3a7.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100903155537.41f1a3a7.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, Sep 03, 2010 at 03:55:37PM -0700, Andrew Morton wrote:
> On Fri,  3 Sep 2010 10:08:45 +0100
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > From: Christoph Lameter <cl@linux.com>
> > 
> > Ordinarily watermark checks are based on the vmstat NR_FREE_PAGES as
> > it is cheaper than scanning a number of lists. To avoid synchronization
> > overhead, counter deltas are maintained on a per-cpu basis and drained both
> > periodically and when the delta is above a threshold. On large CPU systems,
> > the difference between the estimated and real value of NR_FREE_PAGES can
> > be very high. If NR_FREE_PAGES is much higher than number of real free page
> > in buddy, the VM can allocate pages below min watermark, at worst reducing
> > the real number of pages to zero. Even if the OOM killer kills some victim
> > for freeing memory, it may not free memory if the exit path requires a new
> > page resulting in livelock.
> > 
> > This patch introduces a zone_page_state_snapshot() function (courtesy of
> > Christoph) that takes a slightly more accurate of an arbitrary vmstat counter.
> > It is used to read NR_FREE_PAGES while kswapd is awake to avoid the watermark
> > being accidentally broken.  The estimate is not perfect and may result
> > in cache line bounces but is expected to be lighter than the IPI calls
> > necessary to continually drain the per-cpu counters while kswapd is awake.
> > 
> 
> The "is kswapd awake" heuristic seems fairly hacky.  Can it be
> improved, made more deterministic? 

It could be removed but the problem is that the snap version of the
function could be continually used on large systems that are using
almost all physical memory but not under any memory pressure. kswapd
being awake seemed a reasonable proxy indicator that the system is under
pressure.

> Exactly what state are we looking
> for here?
> 

We want to know when the system is in a state where it is both under
pressure and in danger of breaching the watermark due to per-cpu counter
drift.

> 
> > +/*
> > + * More accurate version that also considers the currently pending
> > + * deltas. For that we need to loop over all cpus to find the current
> > + * deltas. There is no synchronization so the result cannot be
> > + * exactly accurate either.
> > + */
> > +static inline unsigned long zone_page_state_snapshot(struct zone *zone,
> > +					enum zone_stat_item item)
> > +{
> > +	long x = atomic_long_read(&zone->vm_stat[item]);
> > +
> > +#ifdef CONFIG_SMP
> > +	int cpu;
> > +	for_each_online_cpu(cpu)
> > +		x += per_cpu_ptr(zone->pageset, cpu)->vm_stat_diff[item];
> > +
> > +	if (x < 0)
> > +		x = 0;
> > +#endif
> > +	return x;
> > +}
> 
> aka percpu_counter_sum()!
> 
> Can someone remind me why per_cpu_pageset went and reimplemented
> percpu_counters rather than just using them?
> 

It's not an exact fit. Christoph answered this and I do not have
anything additional to say.

> >  extern unsigned long global_reclaimable_pages(void);
> >  extern unsigned long zone_reclaimable_pages(struct zone *zone);
> >  
> > diff --git a/mm/mmzone.c b/mm/mmzone.c
> > index f5b7d17..e35bfb8 100644
> > --- a/mm/mmzone.c
> > +++ b/mm/mmzone.c
> > @@ -87,3 +87,24 @@ int memmap_valid_within(unsigned long pfn,
> >  	return 1;
> >  }
> >  #endif /* CONFIG_ARCH_HAS_HOLES_MEMORYMODEL */
> > +
> > +#ifdef CONFIG_SMP
> > +/* Called when a more accurate view of NR_FREE_PAGES is needed */
> > +unsigned long zone_nr_free_pages(struct zone *zone)
> > +{
> > +	unsigned long nr_free_pages = zone_page_state(zone, NR_FREE_PAGES);
> > +
> > +	/*
> > +	 * While kswapd is awake, it is considered the zone is under some
> > +	 * memory pressure. Under pressure, there is a risk that
> > +	 * per-cpu-counter-drift will allow the min watermark to be breached
> > +	 * potentially causing a live-lock. While kswapd is awake and
> > +	 * free pages are low, get a better estimate for free pages
> > +	 */
> > +	if (nr_free_pages < zone->percpu_drift_mark &&
> > +			!waitqueue_active(&zone->zone_pgdat->kswapd_wait))
> > +		return zone_page_state_snapshot(zone, NR_FREE_PAGES);
> > +
> > +	return nr_free_pages;
> > +}
> 
> Is this really the best way of doing it?  The way we usually solve
> this problem (and boy, was this bug a newbie mistake!) is:
> 
> 	foo = percpu_counter_read(x);
> 
> 	if (foo says something bad) {
> 		/* Bad stuff: let's get a more accurate foo */
> 		foo = percpu_counter_sum(x);
> 	}
> 
> 	if (foo still says something bad)
> 		do_bad_thing();
> 
> In other words, don't do all this stuff with percpu_drift_mark and the
> kswapd heuristic.

The percpu_drift_mark and the kswapd heuristic correspond to your "foo
says something bad" above. The drift mark is detecting we're in
potential danger and the kswapd check is telling us we are both in
danger and there is memory pressure. Even if we were using the percpu
counters, it wouldn't eliminate the need for percpu_drift_mark and the
kswapd heuristic, right?

> Just change zone_watermark_ok() to use the more
> accurate read if it's about to return "no".
> 

It could be too late by then. By the tiome zone_watermark_ok() is about
to return no, we could have already breached the watermark by a
significant amount due to the per-cpu counter drift.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
