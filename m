Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 08BA96B0047
	for <linux-mm@kvack.org>; Wed, 29 Sep 2010 06:03:22 -0400 (EDT)
Date: Wed, 29 Sep 2010 11:03:07 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: zone state overhead
Message-ID: <20100929100307.GA14204@csn.ul.ie>
References: <20100928050801.GA29021@sli10-conroe.sh.intel.com> <alpine.DEB.2.00.1009280736020.4144@router.home> <20100928133059.GL8187@csn.ul.ie> <alpine.DEB.2.00.1009282024570.31551@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1009282024570.31551@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Christoph Lameter <cl@linux.com>, Shaohua Li <shaohua.li@intel.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 28, 2010 at 09:02:59PM -0700, David Rientjes wrote:
> On Tue, 28 Sep 2010, Mel Gorman wrote:
> 
> > This is true. It's helpful to remember why this patch exists. Under heavy
> > memory pressure, large machines run the risk of live-locking because the
> > NR_FREE_PAGES gets out of sync. The test case mentioned above is under
> > memory pressure so it is potentially at risk. Ordinarily, we would be less
> > concerned with performance under heavy memory pressure and more concerned with
> > correctness of behaviour. The percpu_drift_mark is set at a point where the
> > risk is "real".  Lowering it will help performance but increase risk. Reducing
> > stat_threshold shifts the cost elsewhere by increasing the frequency the
> > vmstat counters are updated which I considered to be worse overall.
> > 
> > Which of these is better or is there an alternative suggestion on how
> > this livelock can be avoided?
> > 
> 
> I don't think the risk is quite real based on the calculation of 
> percpu_drift_mark using the high watermark instead of the min watermark.  
> For Shaohua's 64 cpu system:
> 
> Node 3, zone   Normal
> pages free     2055926
>         min      1441
>         low      1801
>         high     2161
>         scanned  0
>         spanned  2097152
>         present  2068480
>   vm stats threshold: 98
> 
> It's possible that we'll be 98 pages/cpu * 64 cpus = 6272 pages off in the 
> NR_FREE_PAGES accounting at any given time. 

Right.

> So to avoid depleting memory 
> reserves at the min watermark, which is livelock, and unnecessarily 
> spending time doing reclaim, percpu_drift_mark should be
> 1801 + 6272 = 8073 pages.  Instead, we're currently using the high 
> watermark, so percpu_drift_mark is 8433 pages.
> 

The point of calculating from the high watermark was to prevent kswapd
going to sleep prematurely but if it can be shown the problem goes away
using just the low watermark, I'd go with it. I'm skeptical though for
reasons I outline below.

> It's plausible that we never reclaim sufficient memory that we ever get 
> above the high watermark since we only trigger reclaim when we can't 
> allocate above low, so we may be stuck calling zone_page_state_snapshot() 
> constantly.
> 

Except that zone_page_state_snapshot() is only called while kswapd is
awake which is the proxy indicator of pressure. Just being below
percpu_drift_mark is not enough to call zone_page_state_snapshot.

> I'd be interested to see if this patch helps.
> ---
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -154,7 +154,7 @@ static void refresh_zone_stat_thresholds(void)
>  		tolerate_drift = low_wmark_pages(zone) - min_wmark_pages(zone);
>  		max_drift = num_online_cpus() * threshold;
>  		if (max_drift > tolerate_drift)
> -			zone->percpu_drift_mark = high_wmark_pages(zone) +
> +			zone->percpu_drift_mark = low_wmark_pages(zone) +
>  					max_drift;
>  	}

Well, this in itself would not fix one problem you highlight - kswapd does
not reclaim enough to keep a zone above the percpu_drift_mark meaning that
the instant it wakes, zone_page_state_snapshot() is in use and continually
in use while kswapd is awake. These are the marks of interest at the moment;

min		1441
low		1801
high		2161
driftdanger	8433

kswapd can be mostly awake, keeping ahead of the allocators by
maintaining a free level somewhere between low and high while
zone_page_state_snapshot() is continually in use.

Maybe when percpu_drift_mark is set due to large machines, the
watermarks need to change so that high = percpu_drift_mark + low? That
would make the marks

min		1441
low		1801
driftdanger	8073
high		9874

That would improve the situation slightly by widening the window between
kswapd going to sleep and waking up due to memory pressure while also having
a window where kswapd is awake but zone_page_state_snapshot() is not in
use. It doesn't help if the pressure is enough to keep kswapd awake and at
a level between low and driftdanger.

Alternatively we could revisit Christoph's suggestion of modifying
stat_threshold when under pressure instead of zone_page_state_snapshot. Maybe
by temporarily stat_threshold when kswapd is awake to a per-zone value
such that

zone->low + threshold*nr_online_cpus < high

?

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
