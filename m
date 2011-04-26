Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 2CB689000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 08:31:14 -0400 (EDT)
Date: Tue, 26 Apr 2011 22:30:59 +1000
From: NeilBrown <neilb@suse.de>
Subject: Re: [PATCH 12/13] mm: Throttle direct reclaimers if PF_MEMALLOC
 reserves are low and swap is backed by network storage
Message-ID: <20110426223059.10f3edda@notabene.brown>
In-Reply-To: <1303803414-5937-13-git-send-email-mgorman@suse.de>
References: <1303803414-5937-1-git-send-email-mgorman@suse.de>
	<1303803414-5937-13-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Tue, 26 Apr 2011 08:36:53 +0100 Mel Gorman <mgorman@suse.de> wrote:


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
> +	prepare_to_wait(&zone->zone_pgdat->pfmemalloc_wait, &wait,
> +							TASK_INTERRUPTIBLE);
> +	if (pfmemalloc_watermark_ok(zone->zone_pgdat, high_zoneidx))
> +		goto out;
> +
> +	/* Throttle */
> +	do {
> +		schedule();
> +		finish_wait(&zone->zone_pgdat->pfmemalloc_wait, &wait);
> +		prepare_to_wait(&zone->zone_pgdat->pfmemalloc_wait, &wait,
> +							TASK_INTERRUPTIBLE);
> +	} while (!pfmemalloc_watermark_ok(zone->zone_pgdat, high_zoneidx) &&
> +			!fatal_signal_pending(current));
> +
> +out:
> +	finish_wait(&zone->zone_pgdat->pfmemalloc_wait, &wait);
> +}

You are doing an interruptible wait, but only checking for fatal signals.
So if a non-fatal signal arrives, you will busy-wait.

So I suspect you want TASK_KILLABLE, so just use:

    wait_event_killable(zone->zone_pgdat->pfmemalloc_wait,
                        pgmemalloc_watermark_ok(zone->zone_pgdata,
                                                high_zoneidx));

(You also have an extraneous call to finish_wait)

NeilBrown


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
