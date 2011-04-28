Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B5CB36B0011
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 20:23:31 -0400 (EDT)
Date: Thu, 28 Apr 2011 10:22:44 +1000
From: NeilBrown <neilb@suse.de>
Subject: Re: [PATCH 12/13] mm: Throttle direct reclaimers if PF_MEMALLOC
 reserves are low and swap is backed by network storage
Message-ID: <20110428102244.6e1113e9@notabene.brown>
In-Reply-To: <1303920491-25302-13-git-send-email-mgorman@suse.de>
References: <1303920491-25302-1-git-send-email-mgorman@suse.de>
	<1303920491-25302-13-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Wed, 27 Apr 2011 17:08:10 +0100 Mel Gorman <mgorman@suse.de> wrote:


> +/*
> + * Throttle direct reclaimers if backing storage is backed by the network
> + * and the PFMEMALLOC reserve for the preferred node is getting dangerously
> + * depleted. kswapd will continue to make progress and wake the processes
> + * when the low watermark is reached
> + */
> +static void throttle_direct_reclaim(gfp_t gfp_mask, struct zonelist *zonelist,
> +					nodemask_t *nodemask)
> +{
> +	struct zone *zone;
> +	int high_zoneidx = gfp_zone(gfp_mask);
> +	DEFINE_WAIT(wait);
> +
> +	/* Check if the pfmemalloc reserves are ok */
> +	first_zones_zonelist(zonelist, high_zoneidx, NULL, &zone);
> +	if (pfmemalloc_watermark_ok(zone->zone_pgdat, high_zoneidx))
> +		return;

As the first thing that 'wait_event_interruptible" does is test the condition
and return if it is true, this "if () return;" is pointless.
 
> +
> +	/* Throttle */
> +	wait_event_interruptible(zone->zone_pgdat->pfmemalloc_wait,
> +		pfmemalloc_watermark_ok(zone->zone_pgdat, high_zoneidx));
> +}

I was surprised that you chose wait_event_interruptible as your previous code
was almost exactly "wait_event_killable".

Is there some justification for not throttling processes which happen to have
a (non-fatal) signal pending?

Thanks,
NeilBrown



> +
>  unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
>  				gfp_t gfp_mask, nodemask_t *nodemask)
>  {
> @@ -2133,6 +2172,15 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
>  		.nodemask = nodemask,
>  	};
>  
> +	throttle_direct_reclaim(gfp_mask, zonelist, nodemask);
> +
> +	/*
> +	 * Do not enter reclaim if fatal signal is pending. 1 is returned so
> +	 * that the page allocator does not consider triggering OOM
> +	 */
> +	if (fatal_signal_pending(current))
> +		return 1;
> +
>  	trace_mm_vmscan_direct_reclaim_begin(order,
>  				sc.may_writepage,
>  				gfp_mask);
> @@ -2488,6 +2536,12 @@ loop_again:
>  			}
>  
>  		}
> +
> +		/* Wake throttled direct reclaimers if low watermark is met */
> +		if (waitqueue_active(&pgdat->pfmemalloc_wait) &&
> +				pfmemalloc_watermark_ok(pgdat, MAX_NR_ZONES - 1))
> +			wake_up_interruptible(&pgdat->pfmemalloc_wait);
> +
>  		if (all_zones_ok || (order && pgdat_balanced(pgdat, balanced, *classzone_idx)))
>  			break;		/* kswapd: all done */
>  		/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
