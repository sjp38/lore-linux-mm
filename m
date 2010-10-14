Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 705316B0132
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 23:07:34 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9E37VM6029467
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 14 Oct 2010 12:07:31 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 52D1445DE54
	for <linux-mm@kvack.org>; Thu, 14 Oct 2010 12:07:31 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 04B4745DE50
	for <linux-mm@kvack.org>; Thu, 14 Oct 2010 12:07:31 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A967FE38003
	for <linux-mm@kvack.org>; Thu, 14 Oct 2010 12:07:30 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 37F411DB8042
	for <linux-mm@kvack.org>; Thu, 14 Oct 2010 12:07:30 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: zone state overhead
In-Reply-To: <20101013112430.GI30667@csn.ul.ie>
References: <20101013121913.ADB4.A69D9226@jp.fujitsu.com> <20101013112430.GI30667@csn.ul.ie>
Message-Id: <20101014120804.8B8F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 14 Oct 2010 12:07:29 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Shaohua Li <shaohua.li@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cl@linux.com" <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Hi

> > > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > > index c5dfabf..47ba29e 100644
> > > --- a/mm/vmscan.c
> > > +++ b/mm/vmscan.c
> > > @@ -2378,7 +2378,9 @@ static int kswapd(void *p)
> > >  				 */
> > >  				if (!sleeping_prematurely(pgdat, order, remaining)) {
> > >  					trace_mm_vmscan_kswapd_sleep(pgdat->node_id);
> > > +					enable_pgdat_percpu_threshold(pgdat);
> > >  					schedule();
> > > +					disable_pgdat_percpu_threshold(pgdat);
> > 
> > If we have 4096 cpus, max drift = 125x4096x4096 ~= 2GB. It is higher than zone watermark.
> > Then, such sysmtem can makes memory exshost before kswap call disable_pgdat_percpu_threshold().
> > 
> 
> I don't *think* so but lets explore that possibility. For this to occur, all
> CPUs would have to be allocating all of their memory from the one node (4096
> CPUs is not going to be UMA) which is not going to happen. But allocations
> from one node could be falling over to others of course.
> 
> Lets take an early condition that has to occur for a 4096 CPU machine to
> get into trouble - node 0 exhausted and moving to node 1 and counter drift
> makes us think everything is fine.
> 
> __alloc_pages_nodemask
>   -> get_page_from_freelist
>     -> zone_watermark_ok == true (because we are drifting)
>     -> buffered_rmqueue
>       -> __rmqueue (fails eventually, no pages despite watermark_ok)
>   -> __alloc_pages_slowpath
>     -> wake_all_kswapd()
> ...
>
> kswapd wakes
>   -> disable_pgdat_percpu_threshold()
> 
> i.e. as each node becomes exhausted in reality, kswapd will wake up, disable
> the thresholds until the high watermark is back and go back to sleep. I'm
> not seeing how we'd get into a situation where all kswapds are asleep at the
> same time while each allocator allocates all of memory without managing to
> wake kswapd. Even GFP_ATOMIC allocations will wakeup kswapd.
> 
> Hence, I think the current patch of disabling thresholds while kswapd is
> awake to be sufficient to avoid livelock due to memory exhaustion and
> counter drift.
> 

In this case, wakeup_kswapd() don't wake kswapd because

---------------------------------------------------------------------------------
void wakeup_kswapd(struct zone *zone, int order)
{
        pg_data_t *pgdat;

        if (!populated_zone(zone))
                return;

        pgdat = zone->zone_pgdat;
        if (zone_watermark_ok(zone, order, low_wmark_pages(zone), 0, 0))
                return;                          // HERE
---------------------------------------------------------------------------------

So, if we take your approach, we need to know exact free pages in this.
But, zone_page_state_snapshot() is slow. that's dilemma.



> > Hmmm....
> > This seems fundamental problem. current our zone watermark and per-cpu stat threshold have completely
> > unbalanced definition.
> > 
> > zone watermak:             very few (few mega bytes)
> >                                        propotional sqrt(mem)
> >                                        no propotional nr-cpus
> > 
> > per-cpu stat threshold:  relatively large (desktop: few mega bytes, server ~50MB, SGI 2GB ;-)
> >                                        propotional log(mem)
> >                                        propotional log(nr-cpus)
> > 
> > It mean, much cpus break watermark assumption.....
> > 
> 
> They are for different things. watermarks are meant to prevent livelock
> due to memory exhaustion. per-cpu thresholds are so that counters have
> acceptable performance. The assumptions of watermarks remain the same
> but we have to correctly handle when counter drift can break watermarks.

ok.



> > > +void enable_pgdat_percpu_threshold(pg_data_t *pgdat)
> > > +{
> > > +	struct zone *zone;
> > > +	int cpu;
> > > +	int threshold;
> > > +
> > > +	for_each_populated_zone(zone) {
> > > +		if (!zone->percpu_drift_mark || zone->zone_pgdat != pgdat)
> > > +			continue;
> > > +
> > > +		threshold = calculate_threshold(zone);
> > > +		for_each_online_cpu(cpu)
> > > +			per_cpu_ptr(zone->pageset, cpu)->stat_threshold
> > > +							= threshold;
> > > +	}
> > > +}
> > 
> > disable_pgdat_percpu_threshold() and enable_pgdat_percpu_threshold() are
> > almostly same. can you merge them?
> > 
> 
> I wondered the same but as thresholds are calculated per-zone, I didn't see
> how that could be handled in a unified function without using a callback
> function pointer. If I used callback functions and an additional boolean, I
> could merge refresh_zone_stat_thresholds(), disable_pgdat_percpu_threshold()
> and enable_pgdat_percpu_threshold() but I worried the end-result would be
> a bit unreadable and hinder review. I could roll a standalone patch that
> merges the three if we end up agreeing on this patches general approach
> to counter drift.

ok, I think you are right.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
