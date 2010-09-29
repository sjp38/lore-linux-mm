Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id D29CB6B0047
	for <linux-mm@kvack.org>; Wed, 29 Sep 2010 00:47:41 -0400 (EDT)
Subject: Re: zone state overhead
From: Shaohua Li <shaohua.li@intel.com>
In-Reply-To: <alpine.DEB.2.00.1009282024570.31551@chino.kir.corp.google.com>
References: <20100928050801.GA29021@sli10-conroe.sh.intel.com>
	 <alpine.DEB.2.00.1009280736020.4144@router.home>
	 <20100928133059.GL8187@csn.ul.ie>
	 <alpine.DEB.2.00.1009282024570.31551@chino.kir.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 29 Sep 2010 12:47:18 +0800
Message-ID: <1285735638.27440.23.camel@sli10-conroe.sh.intel.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2010-09-29 at 12:02 +0800, David Rientjes wrote:
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
> NR_FREE_PAGES accounting at any given time.  So to avoid depleting memory 
> reserves at the min watermark, which is livelock, and unnecessarily 
> spending time doing reclaim, percpu_drift_mark should be
> 1801 + 6272 = 8073 pages.  Instead, we're currently using the high 
> watermark, so percpu_drift_mark is 8433 pages.
> 
> It's plausible that we never reclaim sufficient memory that we ever get 
> above the high watermark since we only trigger reclaim when we can't 
> allocate above low, so we may be stuck calling zone_page_state_snapshot() 
> constantly.
> 
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
>  }
I'm afraid not. I tried Christoph's patch, which doesn't help.
in that patch, the threshold = 6272/2 = 3136. and the percpu_drift_mark
is 3136 + 2161 < 8073

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
