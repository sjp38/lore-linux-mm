Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 4AE006B005D
	for <linux-mm@kvack.org>; Fri, 23 Nov 2012 00:08:46 -0500 (EST)
Date: Fri, 23 Nov 2012 14:09:04 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: vmscan: Check for fatal signals iff the process was
 throttled
Message-ID: <20121123050904.GA13626@bbox>
References: <20121102223630.GA2070@barrios>
 <20121105144614.GJ8218@suse.de>
 <20121106002550.GA3530@barrios>
 <20121106085822.GN8218@suse.de>
 <20121106101719.GA2005@barrios>
 <20121109095024.GI8218@suse.de>
 <20121112133218.GA3156@barrios>
 <20121112140631.GV8218@suse.de>
 <20121113133109.GA5204@barrios>
 <20121121153824.GG8218@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121121153824.GG8218@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Luigi Semenzato <semenzato@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Sonny Rao <sonnyrao@google.com>

On Wed, Nov 21, 2012 at 03:38:24PM +0000, Mel Gorman wrote:
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
> throttle_direct_reclaim() where it belongs. If the process is killed
> while throttled, it will return immediately without direct reclaim
> except now it will have TIF_MEMDIE set and will use the PFMEMALLOC
> reserves.
> 
> Minchan pointed out that it may be better to direct reclaim before returning
> to avoid using the reserves because there may be pages that can easily
> reclaim that would avoid using the reserves. However, we do no such targetted
> reclaim and there is no guarantee that suitable pages are available. As it

I think we could mimic the target reclaim by checking the number of
(NR_FILE_PAGES - NR_SHMEM) and sc.may_swap = false but I am not strong now.
If some problem happens by this, we could consider this.
Now, just want to remain history in case of forgetting.

> is expected that this throttling happens when swap-over-NFS is used there
> is a possibility that the process will instead swap which may allocate
> network buffers from the PFMEMALLOC reserves. Hence, in the swap-over-nfs
> case where a process can be throtted and be killed it can use the reserves
> to exit or it can potentially use reserves to swap a few pages and then
> exit. This patch takes the option of using the reserves if necessary to
> allow the process exit quickly.
> 
> If this patch passes review it should be considered a -stable candidate
> for 3.6.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
Acked-by: Minchan Kim <minchan@kernel.org>

Thanks, Mel.

> ---
>  mm/vmscan.c |   37 +++++++++++++++++++++++++++----------
>  1 file changed, 27 insertions(+), 10 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 48550c6..cbf84e1 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2207,9 +2207,12 @@ static bool pfmemalloc_watermark_ok(pg_data_t *pgdat)
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
> @@ -2224,13 +2227,20 @@ static void throttle_direct_reclaim(gfp_t gfp_mask, struct zonelist *zonelist,
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
> @@ -2246,12 +2256,20 @@ static void throttle_direct_reclaim(gfp_t gfp_mask, struct zonelist *zonelist,
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
> @@ -2273,13 +2291,12 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
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
