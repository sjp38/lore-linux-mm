Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 5903A6B004D
	for <linux-mm@kvack.org>; Fri,  2 Nov 2012 02:33:54 -0400 (EDT)
Date: Fri, 2 Nov 2012 15:39:58 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: zram OOM behavior
Message-ID: <20121102063958.GC3326@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: David Rientjes <rientjes@google.com>, Luigi Semenzato <semenzato@google.com>, linux-mm@kvack.org, Dan Magenheimer <dan.magenheimer@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Sonny Rao <sonnyrao@google.com>

Hi Mel,

On Thu, Nov 01, 2012 at 08:28:14AM +0000, Mel Gorman wrote:
> On Wed, Oct 31, 2012 at 09:48:57PM -0700, David Rientjes wrote:
> > On Thu, 1 Nov 2012, Minchan Kim wrote:
> > 
> > > It's not true any more.
> > > 3.6 includes following code in try_to_free_pages
> > > 
> > >         /*   
> > >          * Do not enter reclaim if fatal signal is pending. 1 is returned so
> > >          * that the page allocator does not consider triggering OOM
> > >          */
> > >         if (fatal_signal_pending(current))
> > >                 return 1;
> > > 
> > > So the hunged task never go to the OOM path and could be looping forever.
> > > 
> > 
> > Ah, interesting.  This is from commit 5515061d22f0 ("mm: throttle direct 
> > reclaimers if PF_MEMALLOC reserves are low and swap is backed by network 
> > storage").  Thanks for adding Mel to the cc.
> > 
> 
> Indeed, thanks.
> 
> > The oom killer specifically has logic for this condition: when calling 
> > out_of_memory() the first thing it does is
> > 
> > 	if (fatal_signal_pending(current))
> > 		set_thread_flag(TIF_MEMDIE);
> > 
> > to allow it access to memory reserves so that it may exit if it's having 
> > trouble.  But that ends up never happening because of the above code that 
> > Minchan has identified.
> > 
> > So we either need to do set_thread_flag(TIF_MEMDIE) in try_to_free_pages() 
> > as well or revert that early return entirely; there's no justification 
> > given for it in the comment nor in the commit log. 
> 
> The check for fatal signal is in the wrong place. The reason it was added
> is because a throttled process sleeps in an interruptible sleep.  If a user
> user forcibly kills a throttled process, it should not result in an OOM kill.
> 
> > I'd rather remove it 
> > and allow the oom killer to trigger and grant access to memory reserves 
> > itself if necessary.
> > 
> > Mel, how does commit 5515061d22f0 deal with threads looping forever if 
> > they need memory in the exit path since the oom killer never gets called?
> > 
> 
> It doesn't. How about this?
> 
> ---8<---
> mm: vmscan: Check for fatal signals iff the process was throttled
> 
> commit 5515061d22f0 ("mm: throttle direct reclaimers if PF_MEMALLOC reserves
> are low and swap is backed by network storage") introduced a check for
> fatal signals after a process gets throttled for network storage. The
> intention was that if a process was throttled and got killed that it
> should not trigger the OOM killer. As pointed out by Minchan Kim and
> David Rientjes, this check is in the wrong place and too broad. If a
> system is in am OOM situation and a process is exiting, it can loop in
> __alloc_pages_slowpath() and calling direct reclaim in a loop. As the
> fatal signal is pending it returns 1 as if it is making forward progress
> and can effectively deadlock.
> 
> This patch moves the fatal_signal_pending() check after throttling to
> throttle_direct_reclaim() where it belongs.

I'm not sure how below patch achieve your goal which is to prevent
unnecessary OOM kill if throttled process is killed by user during
throttling. If I misunderstood your goal, please correct me and
write down it in description for making it more clear.

If user kills throttled process, throttle_direct_reclaim returns true by
this patch so try_to_free_pages returns 1. It means it doesn't call OOM
in first path of reclaim but shortly it will try to reclaim again
by should_alloc_retry. And since this second path, throttle_direct_reclaim
will continue to return false so that it could end up calling OOM kill.

Is it a your intention? If so, what's different with old version?
This patch just delay OOM kill so what's benefit does it has?


> 
> If this patch passes review it should be considered a -stable candidate
> for 3.6.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
>  mm/vmscan.c |   37 +++++++++++++++++++++++++++----------
>  1 file changed, 27 insertions(+), 10 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 2b7edfa..ca9e37f 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2238,9 +2238,12 @@ static bool pfmemalloc_watermark_ok(pg_data_t *pgdat)
>   * Throttle direct reclaimers if backing storage is backed by the network
>   * and the PFMEMALLOC reserve for the preferred node is getting dangerously
>   * depleted. kswapd will continue to make progress and wake the processes
> - * when the low watermark is reached
> + * when the low watermark is reached.
> + *
> + * Returns true if a fatal signal was delivered during throttling. If this
> + * happens, the page allocator should not consider triggering the OOM killer.
>   */
> -static void throttle_direct_reclaim(gfp_t gfp_mask, struct zonelist *zonelist,
> +static bool throttle_direct_reclaim(gfp_t gfp_mask, struct zonelist *zonelist,
>  					nodemask_t *nodemask)
>  {
>  	struct zone *zone;
> @@ -2255,13 +2258,20 @@ static void throttle_direct_reclaim(gfp_t gfp_mask, struct zonelist *zonelist,
>  	 * processes to block on log_wait_commit().
>  	 */
>  	if (current->flags & PF_KTHREAD)
> -		return;
> +		goto out;
> +
> +	/*
> +	 * If a fatal signal is pending, this process should not throttle.
> +	 * It should return quickly so it can exit and free its memory
> +	 */
> +	if (fatal_signal_pending(current))
> +		goto out;
>  
>  	/* Check if the pfmemalloc reserves are ok */
>  	first_zones_zonelist(zonelist, high_zoneidx, NULL, &zone);
>  	pgdat = zone->zone_pgdat;
>  	if (pfmemalloc_watermark_ok(pgdat))
> -		return;
> +		goto out;
>  
>  	/* Account for the throttling */
>  	count_vm_event(PGSCAN_DIRECT_THROTTLE);
> @@ -2277,12 +2287,20 @@ static void throttle_direct_reclaim(gfp_t gfp_mask, struct zonelist *zonelist,
>  	if (!(gfp_mask & __GFP_FS)) {
>  		wait_event_interruptible_timeout(pgdat->pfmemalloc_wait,
>  			pfmemalloc_watermark_ok(pgdat), HZ);
> -		return;
> +
> +		goto check_pending;
>  	}
>  
>  	/* Throttle until kswapd wakes the process */
>  	wait_event_killable(zone->zone_pgdat->pfmemalloc_wait,
>  		pfmemalloc_watermark_ok(pgdat));
> +
> +check_pending:
> +	if (fatal_signal_pending(current))
> +		return true;
> +
> +out:
> +	return false;
>  }
>  
>  unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
> @@ -2304,13 +2322,12 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
>  		.gfp_mask = sc.gfp_mask,
>  	};
>  
> -	throttle_direct_reclaim(gfp_mask, zonelist, nodemask);
> -
>  	/*
> -	 * Do not enter reclaim if fatal signal is pending. 1 is returned so
> -	 * that the page allocator does not consider triggering OOM
> +	 * Do not enter reclaim if fatal signal was delivered while throttled.
> +	 * 1 is returned so that the page allocator does not OOM kill at this
> +	 * point.
>  	 */
> -	if (fatal_signal_pending(current))
> +	if (throttle_direct_reclaim(gfp_mask, zonelist, nodemask))
>  		return 1;
>  
>  	trace_mm_vmscan_direct_reclaim_begin(order,
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
