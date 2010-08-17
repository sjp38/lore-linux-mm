Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id BEA676B01F0
	for <linux-mm@kvack.org>; Tue, 17 Aug 2010 06:43:02 -0400 (EDT)
Date: Tue, 17 Aug 2010 11:42:46 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/3] mm: page allocator: Calculate a better estimate of
	NR_FREE_PAGES when memory is low and kswapd is awake
Message-ID: <20100817104246.GO19797@csn.ul.ie>
References: <1281951733-29466-1-git-send-email-mel@csn.ul.ie> <1281951733-29466-3-git-send-email-mel@csn.ul.ie> <20100816094350.GH19797@csn.ul.ie> <20100816160623.GB15103@cmpxchg.org> <AANLkTikWzkUkkghJcPBcuPsquyw-CodbH5z1DLbOiWP9@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AANLkTikWzkUkkghJcPBcuPsquyw-CodbH5z1DLbOiWP9@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 17, 2010 at 11:26:05AM +0900, Minchan Kim wrote:
> On Tue, Aug 17, 2010 at 1:06 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> > [npiggin@suse.de bounces, switched to yahoo address]
> >
> > On Mon, Aug 16, 2010 at 10:43:50AM +0100, Mel Gorman wrote:
> 
> <snip>
> 
> >> +      * potentially causing a live-lock. While kswapd is awake and
> >> +      * free pages are low, get a better estimate for free pages
> >> +      */
> >> +     if (nr_free_pages < zone->percpu_drift_mark &&
> >> +                     !waitqueue_active(&zone->zone_pgdat->kswapd_wait)) {
> >> +             int cpu;
> >> +
> >> +             for_each_online_cpu(cpu) {
> >> +                     struct per_cpu_pageset *pset;
> >> +
> >> +                     pset = per_cpu_ptr(zone->pageset, cpu);
> >> +                     nr_free_pages += pset->vm_stat_diff[NR_FREE_PAGES];
> 
> We need to consider CONFIG_SMP.
> 

We do.

#ifdef CONFIG_SMP
unsigned long zone_nr_free_pages(struct zone *zone);
#else
#define zone_nr_free_pages(zone) zone_page_state(zone, NR_FREE_PAGES)
#endif /* CONFIG_SMP */

and a wrapping of CONFIG_SMP around the function in mmzone.c .

> >> +             }
> >> +     }
> >> +
> >> +     return nr_free_pages;
> >> +}
> >> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> >> index c2407a4..67a2ed0 100644
> >> --- a/mm/page_alloc.c
> >> +++ b/mm/page_alloc.c
> >> @@ -1462,7 +1462,7 @@ int zone_watermark_ok(struct zone *z, int order, unsigned long mark,
> >>  {
> >>       /* free_pages my go negative - that's OK */
> >>       long min = mark;
> >> -     long free_pages = zone_page_state(z, NR_FREE_PAGES) - (1 << order) + 1;
> >> +     long free_pages = zone_nr_free_pages(z) - (1 << order) + 1;
> >>       int o;
> >>
> >>       if (alloc_flags & ALLOC_HIGH)
> >> @@ -2413,7 +2413,7 @@ void show_free_areas(void)
> >>                       " all_unreclaimable? %s"
> >>                       "\n",
> >>                       zone->name,
> >> -                     K(zone_page_state(zone, NR_FREE_PAGES)),
> >> +                     K(zone_nr_free_pages(zone)),
> >>                       K(min_wmark_pages(zone)),
> >>                       K(low_wmark_pages(zone)),
> >>                       K(high_wmark_pages(zone)),
> >> diff --git a/mm/vmstat.c b/mm/vmstat.c
> >> index 7759941..c95a159 100644
> >> --- a/mm/vmstat.c
> >> +++ b/mm/vmstat.c
> >> @@ -143,6 +143,9 @@ static void refresh_zone_stat_thresholds(void)
> >>               for_each_online_cpu(cpu)
> >>                       per_cpu_ptr(zone->pageset, cpu)->stat_threshold
> >>                                                       = threshold;
> >> +
> >> +             zone->percpu_drift_mark = high_wmark_pages(zone) +
> >> +                                     num_online_cpus() * threshold;
> >>       }
> >>  }
> >
> > Hm, this one I don't quite get (might be the jetlag, though): we have
> > _at least_ NR_FREE_PAGES free pages, there may just be more lurking in
> 
> We can't make sure it.
> As I said previous mail, current allocation path decreases
> NR_FREE_PAGES after it removes pages from buddy list.
> 
> > the pcp counters.
> >
> > So shouldn't we only collect the pcp deltas in case the high watermark
> > is breached?  Above this point, we should be fine or better, no?
> 
> If we don't consider allocation path, I agree on Hannes's opinion.
> At least, we need to listen why Mel determine the threshold. :)
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
