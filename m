Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 519B86B0118
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 09:19:31 -0400 (EDT)
Date: Wed, 13 Oct 2010 14:19:16 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC][PATCH 3/3] mm: reserve max drift pages at boot time
	instead using zone_page_state_snapshot()
Message-ID: <20101013131916.GN30667@csn.ul.ie>
References: <20101013121913.ADB4.A69D9226@jp.fujitsu.com> <20101013151723.ADBD.A69D9226@jp.fujitsu.com> <20101013152922.ADC6.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20101013152922.ADC6.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Shaohua Li <shaohua.li@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cl@linux.com" <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, Oct 13, 2010 at 03:32:08PM +0900, KOSAKI Motohiro wrote:
> Shaohua Li reported commit aa45484031(mm: page allocator: calculate a
> better estimate of NR_FREE_PAGES when memory is low and kswapd is awake)
> made performance regression.
> 
> | In a 4 socket 64 CPU system, zone_nr_free_pages() takes about 5% ~ 10%
> | cpu time
> | according to perf when memory pressure is high. The workload does
> | something like:
> | for i in `seq 1 $nr_cpu`
> | do
> |        create_sparse_file $SPARSE_FILE-$i $((10 * mem / nr_cpu))
> |        $USEMEM -f $SPARSE_FILE-$i -j 4096 --readonly $((10 * mem / nr_cpu)) &
> | done
> | this simply reads a sparse file for each CPU. Apparently the
> | zone->percpu_drift_mark is too big, and guess zone_page_state_snapshot()
> | makes a lot of cache bounce for ->vm_stat_diff[]. below is the zoneinfo for
> | reference.
> | Is there any way to reduce the overhead?
> |
> | Node 3, zone   Normal
> | pages free     2055926
> |         min      1441
> |         low      1801
> |         high     2161
> |         scanned  0
> |         spanned  2097152
> |         present  2068480
> |   vm stats threshold: 98
> 
> It mean zone_page_state_snapshot() is costly than we expected.

Yes although remember *why* it's expensive. It's not the iteration of
the loop per-se. It's the bouncing of cache lines between cores on
different sockets because it's heavily dirtied data. That's why my patch
took the approach of reducing the thresholds so that local CPUs would
sync more frequently but it wouldn't be bouncing as much dirty data
between sockets.

> This
> patch introduced very different approach. we are reserving max-drift pages
> at first instead runtime free page calculation.
> 
> But, this technique can't be used on much cpus and few memory systems.
> On such system, we still need to use zone_page_state_snapshot().
> 
> Example1: typical desktop
>   CPU: 2
>   MEM: 2GB
> 
>   old) zone->min = sqrt(2x1024x1024x16) = 5792 KB = 1448 pages
>   new) max-drift = 2 x log2(2) x log2(2x1024/128) x 2 = 40
>        zone->min = 1448 + 40 = 1488 pages
> 
> Example2: relatively large server
>   CPU: 64
>   MEM: 8GBx4 (=32GB)
> 
>   old) zone->min = sqrt(32x1024x1024x16)/4 = 5792 KB = 1448 pages
>   new) max-drift = 2 x log2(64) x log2(8x1024/128) x 64 = 6272 pages
>        zone->min = 1448 + 6272 = 7720 pages
> 
>   Hmm, zone->min became almost 5x times. Is it acceptable? I think yes.

Yes, I think that's acceptable. The level needed for the best fragmentation
avoidance is higher than that for systems that have varying requirements
for the number of huge pages.

>   Today, we can buy 8GB DRAM for $20. So, 6272 pages (=24.5MB) waste
>   mean about 6 cent waste. It's good deal for getting good performance.
> 
> Example3: ultimately big server
>   CPU: 2048
>   MEM: 64GBx256 (=16TB)
> 
>   old) zone->min = sqrt(16x1024x1024x1024x16)/256 = 2048 KB = 512 pages
>                                       (Wow!, it's smaller than desktop)
>   new) max-drift = 125 x 2048 = 256000 pages = 1000MB (greater than 64GB/100)
>        zone->min = 512 pages
> 
> Reported-by: Shaohua Li <shaohua.li@intel.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> ---
>  mm/page_alloc.c |    9 +++++++++
>  1 files changed, 9 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 53627fa..194bdaa 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4897,6 +4897,15 @@ static void setup_per_zone_wmarks(void)
>  	for_each_zone(zone) {
>  		u64 tmp;
>  
> +		/*
> +		 * If max drift are less than 1%, reserve max drift pages
> +		 * instead costly runtime calculation.
> +		 */
> +		if (zone->percpu_drift_mark < (zone->present_pages/100)) {
> +			pages_min += zone->percpu_drift_mark;
> +			zone->percpu_drift_mark = 0;
> +		}
> +

I don't see how this solves Shaohua's problem as such. Large systems will
still suffer a bug performance penalty from zone_page_state_snapshot(). I
do see the logic of adjusting min for larger systems to limit the amount of
time per-cpu thresholds are lowered but that would be as a follow-on to my
patch rather than a replacement.

>  		spin_lock_irqsave(&zone->lock, flags);
>  		tmp = (u64)pages_min * zone->present_pages;
>  		do_div(tmp, lowmem_pages);
> -- 
> 1.6.5.2
> 
> 
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
