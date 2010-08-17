Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 401C56B01F0
	for <linux-mm@kvack.org>; Tue, 17 Aug 2010 06:17:11 -0400 (EDT)
Date: Tue, 17 Aug 2010 11:16:55 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/3] mm: page allocator: Calculate a better estimate of
	NR_FREE_PAGES when memory is low and kswapd is awake
Message-ID: <20100817101655.GN19797@csn.ul.ie>
References: <1281951733-29466-1-git-send-email-mel@csn.ul.ie> <1281951733-29466-3-git-send-email-mel@csn.ul.ie> <20100816094350.GH19797@csn.ul.ie> <20100816160623.GB15103@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100816160623.GB15103@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, Aug 16, 2010 at 06:06:23PM +0200, Johannes Weiner wrote:
> [npiggin@suse.de bounces, switched to yahoo address]
> 
> On Mon, Aug 16, 2010 at 10:43:50AM +0100, Mel Gorman wrote:
> > On Mon, Aug 16, 2010 at 10:42:12AM +0100, Mel Gorman wrote:
> > > Ordinarily watermark checks are made based on the vmstat NR_FREE_PAGES as
> > > it is cheaper than scanning a number of lists. To avoid synchronization
> > > overhead, counter deltas are maintained on a per-cpu basis and drained both
> > > periodically and when the delta is above a threshold. On large CPU systems,
> > > the difference between the estimated and real value of NR_FREE_PAGES can be
> > > very high. If the system is under both load and low memory, it's possible
> > > for watermarks to be breached. In extreme cases, the number of free pages
> > > can drop to 0 leading to the possibility of system livelock.
> > > 
> > > This patch introduces zone_nr_free_pages() to take a slightly more accurate
> > > estimate of NR_FREE_PAGES while kswapd is awake.  The estimate is not perfect
> > > and may result in cache line bounces but is expected to be lighter than the
> > > IPI calls necessary to continually drain the per-cpu counters while kswapd
> > > is awake.
> > > 
> > > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > 
> > And the second I sent this, I realised I had sent a slightly old version
> > that missed a compile-fix :(
> > 
> > ==== CUT HERE ====
> > mm: page allocator: Calculate a better estimate of NR_FREE_PAGES when memory is low and kswapd is awake
> > 
> > Ordinarily watermark checks are made based on the vmstat NR_FREE_PAGES as
> > it is cheaper than scanning a number of lists. To avoid synchronization
> > overhead, counter deltas are maintained on a per-cpu basis and drained both
> > periodically and when the delta is above a threshold. On large CPU systems,
> > the difference between the estimated and real value of NR_FREE_PAGES can be
> > very high. If the system is under both load and low memory, it's possible
> > for watermarks to be breached. In extreme cases, the number of free pages
> > can drop to 0 leading to the possibility of system livelock.
> > 
> > This patch introduces zone_nr_free_pages() to take a slightly more accurate
> > estimate of NR_FREE_PAGES while kswapd is awake.  The estimate is not perfect
> > and may result in cache line bounces but is expected to be lighter than the
> > IPI calls necessary to continually drain the per-cpu counters while kswapd
> > is awake.
> > 
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> 
> [...]
> 
> > --- a/mm/mmzone.c
> > +++ b/mm/mmzone.c
> > @@ -87,3 +87,30 @@ int memmap_valid_within(unsigned long pfn,
> >  	return 1;
> >  }
> >  #endif /* CONFIG_ARCH_HAS_HOLES_MEMORYMODEL */
> > +
> > +/* Called when a more accurate view of NR_FREE_PAGES is needed */
> > +unsigned long zone_nr_free_pages(struct zone *zone)
> > +{
> > +	unsigned long nr_free_pages = zone_page_state(zone, NR_FREE_PAGES);
> > +
> > +	/*
> > +	 * While kswapd is awake, it is considered the zone is under some
> > +	 * memory pressure. Under pressure, there is a risk that
> > +	 * er-cpu-counter-drift will allow the min watermark to be breached
> 
> Missing `p'.
> 

D'oh. Fixed

> > +	 * potentially causing a live-lock. While kswapd is awake and
> > +	 * free pages are low, get a better estimate for free pages
> > +	 */
> > +	if (nr_free_pages < zone->percpu_drift_mark &&
> > +			!waitqueue_active(&zone->zone_pgdat->kswapd_wait)) {
> > +		int cpu;
> > +
> > +		for_each_online_cpu(cpu) {
> > +			struct per_cpu_pageset *pset;
> > +
> > +			pset = per_cpu_ptr(zone->pageset, cpu);
> > +			nr_free_pages += pset->vm_stat_diff[NR_FREE_PAGES];
> > +		}
> > +	}
> > +
> > +	return nr_free_pages;
> > +}
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index c2407a4..67a2ed0 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1462,7 +1462,7 @@ int zone_watermark_ok(struct zone *z, int order, unsigned long mark,
> >  {
> >  	/* free_pages my go negative - that's OK */
> >  	long min = mark;
> > -	long free_pages = zone_page_state(z, NR_FREE_PAGES) - (1 << order) + 1;
> > +	long free_pages = zone_nr_free_pages(z) - (1 << order) + 1;
> >  	int o;
> >  
> >  	if (alloc_flags & ALLOC_HIGH)
> > @@ -2413,7 +2413,7 @@ void show_free_areas(void)
> >  			" all_unreclaimable? %s"
> >  			"\n",
> >  			zone->name,
> > -			K(zone_page_state(zone, NR_FREE_PAGES)),
> > +			K(zone_nr_free_pages(zone)),
> >  			K(min_wmark_pages(zone)),
> >  			K(low_wmark_pages(zone)),
> >  			K(high_wmark_pages(zone)),
> > diff --git a/mm/vmstat.c b/mm/vmstat.c
> > index 7759941..c95a159 100644
> > --- a/mm/vmstat.c
> > +++ b/mm/vmstat.c
> > @@ -143,6 +143,9 @@ static void refresh_zone_stat_thresholds(void)
> >  		for_each_online_cpu(cpu)
> >  			per_cpu_ptr(zone->pageset, cpu)->stat_threshold
> >  							= threshold;
> > +
> > +		zone->percpu_drift_mark = high_wmark_pages(zone) +
> > +					num_online_cpus() * threshold;
> >  	}
> >  }
> 
> Hm, this one I don't quite get (might be the jetlag, though): we have
> _at least_ NR_FREE_PAGES free pages, there may just be more lurking in
> the pcp counters.
> 

Well, the drift can be either direction because drift can be due to pages
being either freed or allocated. e.g. it could be something like

NR_FREE_PAGES		CPU 0			CPU 1		Actual Free
128			-32			 +64		   160

Because CPU 0 was allocating pages while CPU 1 was freeing them but that
is not what is important here. At any given time, the NR_FREE_PAGES can be
wrong by as much as

num_online_cpus * (threshold - 1)

As kswapd goes back to sleep when the high watermark is reached, it's important
that it has actually reached the watermark before sleeping.  Similarly,
if an allocator is checking the low watermark, it needs an accurate count.
Hence a more careful accounting for NR_FREE_PAGES should happen when the
number of free pages is within

high_watermark + (num_online_cpus * (threshold - 1))

Only checking when kswapd is awake still leaves a window between the low
and min watermark when we could breach the watermark but I'm expecting it
can only happen for at worst one allocation. After that, kswapd wakes
and the count becomes accurate again.

> So shouldn't we only collect the pcp deltas in case the high watermark
> is breached?  Above this point, we should be fine or better, no?
> 

Is that not what is happening in zone_nr_free_pages with this check?

        /*
         * While kswapd is awake, it is considered the zone is under some
         * memory pressure. Under pressure, there is a risk that
         * per-cpu-counter-drift will allow the min watermark to be breached
         * potentially causing a live-lock. While kswapd is awake and
         * free pages are low, get a better estimate for free pages
         */
        if (nr_free_pages < zone->percpu_drift_mark &&
                        !waitqueue_active(&zone->zone_pgdat->kswapd_wait)) {

Maybe I'm misunderstanding your question.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
