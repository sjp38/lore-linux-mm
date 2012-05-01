Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id C22486B004D
	for <linux-mm@kvack.org>; Tue,  1 May 2012 18:24:40 -0400 (EDT)
Date: Tue, 1 May 2012 15:24:37 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 15/16] mm: Throttle direct reclaimers if PF_MEMALLOC
 reserves are low and swap is backed by network storage
Message-Id: <20120501152437.194f0fc2.akpm@linux-foundation.org>
In-Reply-To: <1334578624-23257-16-git-send-email-mgorman@suse.de>
References: <1334578624-23257-1-git-send-email-mgorman@suse.de>
	<1334578624-23257-16-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>

On Mon, 16 Apr 2012 13:17:02 +0100
Mel Gorman <mgorman@suse.de> wrote:

> If swap is backed by network storage such as NBD, there is a risk
> that a large number of reclaimers can hang the system by consuming
> all PF_MEMALLOC reserves. To avoid these hangs, the administrator
> must tune min_free_kbytes in advance which is a bit fragile.
> 
> This patch throttles direct reclaimers if half the PF_MEMALLOC reserves
> are in use. If the system is routinely getting throttled the system
> administrator can increase min_free_kbytes so degradation is smoother
> but the system will keep running.
> 
>
> ...
>
> +static bool pfmemalloc_watermark_ok(pg_data_t *pgdat)
> +{
> +	struct zone *zone;
> +	unsigned long pfmemalloc_reserve = 0;
> +	unsigned long free_pages = 0;
> +	int i;
> +	bool wmark_ok;
> +
> +	for (i = 0; i <= ZONE_NORMAL; i++) {
> +		zone = &pgdat->node_zones[i];
> +		pfmemalloc_reserve += min_wmark_pages(zone);
> +		free_pages += zone_page_state(zone, NR_FREE_PAGES);
> +	}
> +
> +	wmark_ok = (free_pages > pfmemalloc_reserve / 2) ? true : false;

	wmark_ok = free_pages > pfmemalloc_reserve / 2;

> +
> +	/* kswapd must be awake if processes are being throttled */
> +	if (!wmark_ok && waitqueue_active(&pgdat->kswapd_wait)) {
> +		pgdat->classzone_idx = min(pgdat->classzone_idx,
> +						(enum zone_type)ZONE_NORMAL);
> +		wake_up_interruptible(&pgdat->kswapd_wait);
> +	}
> +
> +	return wmark_ok;
> +}
> +
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
> +	pg_data_t *pgdat;
> +
> +	/* Kernel threads such as kjournald should not be throttled */

The comment should explain "why", not "what".  Particularly when the
"what" was bleedin obvious ;)

Also...   why?

> +	if (current->flags & PF_KTHREAD)
> +		return;
> +
> +	/* Check if the pfmemalloc reserves are ok */
> +	first_zones_zonelist(zonelist, high_zoneidx, NULL, &zone);
> +	pgdat = zone->zone_pgdat;
> +	if (pfmemalloc_watermark_ok(pgdat))
> +		return;
> +
> +	/*
> +	 * If the caller cannot enter the filesystem, it's possible that it
> +	 * is processing a journal transaction. In this case, it is not safe
> +	 * to block on pfmemalloc_wait as kswapd could also be blocked waiting
> +	 * to start a transaction. Instead, throttle for up to a second before
> +	 * the reclaim must continue.
> +	 */

I suppose this applies to fs locks in general, not just to
journal_start()?

> +	if (!(gfp_mask & __GFP_FS)) {
> +		wait_event_interruptible_timeout(pgdat->pfmemalloc_wait,
> +			pfmemalloc_watermark_ok(pgdat), HZ);
> +		return;
> +	}
> +
> +	/* Throttle until kswapd wakes the process */
> +	wait_event_killable(zone->zone_pgdat->pfmemalloc_wait,
> +		pfmemalloc_watermark_ok(pgdat));
> +}
> +
>  unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
>  				gfp_t gfp_mask, nodemask_t *nodemask)
>  {
>
> ...
>
> @@ -2610,6 +2686,20 @@ static bool sleeping_prematurely(pg_data_t *pgdat, int order, long remaining,
>  	if (remaining)
>  		return true;
>  
> +	/*
> +	 * There is a potential race between when kswapd checks it watermarks

"its"

> +	 * and a process gets throttled. There is also a potential race if
> +	 * processes get throttled, kswapd wakes, a large process exits therby
> +	 * balancing the zones that causes kswapd to miss a wakeup. If kswapd
> +	 * is going to sleep, no process should be sleeping on pfmemalloc_wait
> +	 * so wake them now if necessary. If necessary, processes will wake
> +	 * kswapd and get throttled again
> +	 */

Yes, the possibility for missed wakeups here worried me.  There's no
synchronization and it would be easy to leave holes.

It's good that there is no timeout on the throttling - a timeout would
cover up rare races most nastily.

> +	if (waitqueue_active(&pgdat->pfmemalloc_wait)) {
> +		wake_up(&pgdat->pfmemalloc_wait);
> +		return true;
> +	}

A bool-returning function called "sleeping_prematurely" should have no
side-effects.  But it now performs wakeups.  Wanna see if there is a
way of making this nicer?

>  	/* Check the watermark levels */
>  	for (i = 0; i <= classzone_idx; i++) {
>  		struct zone *zone = pgdat->node_zones + i;
> @@ -2871,6 +2961,12 @@ loop_again:
>  			}
>  
>  		}
> +
> +		/* Wake throttled direct reclaimers if low watermark is met */

s/"what"/"why"/ !

> +		if (waitqueue_active(&pgdat->pfmemalloc_wait) &&
> +				pfmemalloc_watermark_ok(pgdat))
> +			wake_up(&pgdat->pfmemalloc_wait);
> +
>  		if (all_zones_ok || (order && pgdat_balanced(pgdat, balanced, *classzone_idx)))
>  			break;		/* kswapd: all done */
>  		/*
>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
