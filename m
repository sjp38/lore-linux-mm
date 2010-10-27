Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id EB1E06B0085
	for <linux-mm@kvack.org>; Wed, 27 Oct 2010 04:19:26 -0400 (EDT)
Date: Wed, 27 Oct 2010 09:19:11 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: zone state overhead
Message-ID: <20101027081910.GI5383@csn.ul.ie>
References: <20101019090803.GF30667@csn.ul.ie> <20101022141223.GF2160@csn.ul.ie> <20101025132824.9176.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20101025132824.9176.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Shaohua Li <shaohua.li@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cl@linux.com" <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, Oct 25, 2010 at 01:46:19PM +0900, KOSAKI Motohiro wrote:
> > - * Return 1 if free pages are above 'mark'. This takes into account the order
> > + * Return true if free pages are above 'mark'. This takes into account the order
> >   * of the allocation.
> >   */
> > -int zone_watermark_ok(struct zone *z, int order, unsigned long mark,
> > -		      int classzone_idx, int alloc_flags)
> > +bool __zone_watermark_ok(struct zone *z, int order, unsigned long mark,
> > +		      int classzone_idx, int alloc_flags, long free_pages)
> 
> static?
> 

Yes, it should be.

> 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index c5dfabf..ba0c70a 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -2082,7 +2082,7 @@ static int sleeping_prematurely(pg_data_t *pgdat, int order, long remaining)
> >  		if (zone->all_unreclaimable)
> >  			continue;
> >  
> > -		if (!zone_watermark_ok(zone, order, high_wmark_pages(zone),
> > +		if (!zone_watermark_ok_safe(zone, order, high_wmark_pages(zone),
> >  								0, 0))
> >  			return 1;
> >  	}
> 
> Do we need to change balance_pgdat() too?
> Otherwise, balance_pgdat() return immediately and can make semi-infinite busy loop.
> 

While balance_pgdat is calling zone_watermark_ok() the thresholds are
very low and the expected level of drift is minimal.  I considered the
semi-infinite busy loop to have a worst-case situation of 2 seconds until
the vmstat counters were synced and zone_watermark_ok* values matched.
There is an reasonable expectation that normal allocate/free activity would
sync the values for zone_watermark_ok* before that timeout.

To my surprise though, using zone_watermark_ok_safe() in balance_pgdat()
does not significantly increase the amount of time spent in the _safe()
function so it'll be called in the next version.

> 
> > diff --git a/mm/vmstat.c b/mm/vmstat.c
> > index 355a9e6..ddee139 100644
> > --- a/mm/vmstat.c
> > +++ b/mm/vmstat.c
> > @@ -81,6 +81,12 @@ EXPORT_SYMBOL(vm_stat);
> >  
> >  #ifdef CONFIG_SMP
> >  
> > +static int calculate_pressure_threshold(struct zone *zone)
> > +{
> > +	return max(1, (int)((high_wmark_pages(zone) - low_wmark_pages(zone) /
> > +				num_online_cpus())));
> > +}
> 
> On Shaohua's machine,
> 
> 	CPU: 64
> 	MEM: 8GBx4 (=32GB)
> 	per-cpu vm-stat threashold: 98
> 
> 	zone->min = sqrt(32x1024x1024x16)/4 = 5792 KB = 1448 pages
> 	zone->high - zone->low = zone->min/4 = 362pages
> 	pressure-vm-threshold = 362/64 ~= 5
> 
> Hrm, this reduction seems slightly dramatically (98->5). 

Yes, but consider the maximum possible drift;

	percpu-maximum-drift = 5*64 = 320

The value is massively reduced and the cost goes up but this is the value
necessary to avoid a situation where the high watermark is "ok" when in fact
the min watermark can be breached.

> Shaohua, can you please rerun your problem workload on your 64cpus machine with
> applying this patch?
> Of cource, If there is no performance degression, I'm not against this one.
> 

Your patches that adjusted min and high may allow this threshold to grow again.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
