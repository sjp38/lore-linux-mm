Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 887986B00B8
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 06:39:59 -0400 (EDT)
Date: Mon, 18 Oct 2010 11:39:41 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: zone state overhead
Message-ID: <20101018103941.GX30667@csn.ul.ie>
References: <20101013121913.ADB4.A69D9226@jp.fujitsu.com> <20101013112430.GI30667@csn.ul.ie> <20101014120804.8B8F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20101014120804.8B8F.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Shaohua Li <shaohua.li@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cl@linux.com" <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, Oct 14, 2010 at 12:07:29PM +0900, KOSAKI Motohiro wrote:
> Hi
> 
> > > > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > > > index c5dfabf..47ba29e 100644
> > > > --- a/mm/vmscan.c
> > > > +++ b/mm/vmscan.c
> > > > @@ -2378,7 +2378,9 @@ static int kswapd(void *p)
> > > >  				 */
> > > >  				if (!sleeping_prematurely(pgdat, order, remaining)) {
> > > >  					trace_mm_vmscan_kswapd_sleep(pgdat->node_id);
> > > > +					enable_pgdat_percpu_threshold(pgdat);
> > > >  					schedule();
> > > > +					disable_pgdat_percpu_threshold(pgdat);
> > > 
> > > If we have 4096 cpus, max drift = 125x4096x4096 ~= 2GB. It is higher than zone watermark.
> > > Then, such sysmtem can makes memory exshost before kswap call disable_pgdat_percpu_threshold().
> > > 
> > 
> > I don't *think* so but lets explore that possibility. For this to occur, all
> > CPUs would have to be allocating all of their memory from the one node (4096
> > CPUs is not going to be UMA) which is not going to happen. But allocations
> > from one node could be falling over to others of course.
> > 
> > Lets take an early condition that has to occur for a 4096 CPU machine to
> > get into trouble - node 0 exhausted and moving to node 1 and counter drift
> > makes us think everything is fine.
> > 
> > __alloc_pages_nodemask
> >   -> get_page_from_freelist
> >     -> zone_watermark_ok == true (because we are drifting)
> >     -> buffered_rmqueue
> >       -> __rmqueue (fails eventually, no pages despite watermark_ok)
> >   -> __alloc_pages_slowpath
> >     -> wake_all_kswapd()
> > ...
> >
> > kswapd wakes
> >   -> disable_pgdat_percpu_threshold()
> > 
> > i.e. as each node becomes exhausted in reality, kswapd will wake up, disable
> > the thresholds until the high watermark is back and go back to sleep. I'm
> > not seeing how we'd get into a situation where all kswapds are asleep at the
> > same time while each allocator allocates all of memory without managing to
> > wake kswapd. Even GFP_ATOMIC allocations will wakeup kswapd.
> > 
> > Hence, I think the current patch of disabling thresholds while kswapd is
> > awake to be sufficient to avoid livelock due to memory exhaustion and
> > counter drift.
> > 
> 
> In this case, wakeup_kswapd() don't wake kswapd because
> 
> ---------------------------------------------------------------------------------
> void wakeup_kswapd(struct zone *zone, int order)
> {
>         pg_data_t *pgdat;
> 
>         if (!populated_zone(zone))
>                 return;
> 
>         pgdat = zone->zone_pgdat;
>         if (zone_watermark_ok(zone, order, low_wmark_pages(zone), 0, 0))
>                 return;                          // HERE
> ---------------------------------------------------------------------------------
> 
> So, if we take your approach, we need to know exact free pages in this.

Good point!

> But, zone_page_state_snapshot() is slow. that's dilemma.
> 

Very true. I'm prototyping a version of the patch that keeps
zone_page_state_snapshot but only uses is in wakeup_kswapd and
sleeping_prematurely.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
