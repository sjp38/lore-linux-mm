Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E5DD76B00B8
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 06:43:45 -0400 (EDT)
Date: Mon, 18 Oct 2010 11:43:31 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC][PATCH 3/3] mm: reserve max drift pages at boot time
	instead using zone_page_state_snapshot()
Message-ID: <20101018104330.GY30667@csn.ul.ie>
References: <20101013152922.ADC6.A69D9226@jp.fujitsu.com> <20101013131916.GN30667@csn.ul.ie> <20101014113426.8B83.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20101014113426.8B83.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Shaohua Li <shaohua.li@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cl@linux.com" <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, Oct 14, 2010 at 11:39:34AM +0900, KOSAKI Motohiro wrote:
> > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > index 53627fa..194bdaa 100644
> > > --- a/mm/page_alloc.c
> > > +++ b/mm/page_alloc.c
> > > @@ -4897,6 +4897,15 @@ static void setup_per_zone_wmarks(void)
> > >  	for_each_zone(zone) {
> > >  		u64 tmp;
> > >  
> > > +		/*
> > > +		 * If max drift are less than 1%, reserve max drift pages
> > > +		 * instead costly runtime calculation.
> > > +		 */
> > > +		if (zone->percpu_drift_mark < (zone->present_pages/100)) {
> > > +			pages_min += zone->percpu_drift_mark;
> > > +			zone->percpu_drift_mark = 0;
> > > +		}
> > > +
> > 
> > I don't see how this solves Shaohua's problem as such. Large systems will
> > still suffer a bug performance penalty from zone_page_state_snapshot(). I
> > do see the logic of adjusting min for larger systems to limit the amount of
> > time per-cpu thresholds are lowered but that would be as a follow-on to my
> > patch rather than a replacement.
> 
> My patch rescue 256cpus or more smaller systems.

True, and it would be nice to limit how many machines any of this logic
applies to.

> and I assumed 4096cpus system don't
> run IO intensive workload such as Shaohua's case.

Also true, but they still suffer the drift problem. The reproduction
case would change but otherwise the drift must still be handled.

> they always use cpusets and run hpc
> workload.
> 
> If you know another >1024cpus system, please let me know.
> And again, my patch works on 4096cpus sysmtem although slow, but your don't.
> 
> Am I missing something?
> 

I think both are ultimately needed. For my patch, I need to make sure that
wakeup_kswapd() actually wakes up kswapd by using
zone_page_state_snapshot() when necessary. Your patch avoids the problem
differently but in a way that is nice for "smaller" machines.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
