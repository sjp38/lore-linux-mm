Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id EE9826B0005
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 05:29:03 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id c82so24030016wme.2
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 02:29:03 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id za4si4294873wjb.174.2016.06.16.02.29.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Jun 2016 02:29:02 -0700 (PDT)
Subject: Re: [PATCH 10/27] mm, vmscan: Clear congestion, dirty and need for
 compaction on a per-node basis
References: <1465495483-11855-1-git-send-email-mgorman@techsingularity.net>
 <1465495483-11855-11-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <510d374a-074e-cd32-bdbe-61754052b21b@suse.cz>
Date: Thu, 16 Jun 2016 11:29:00 +0200
MIME-Version: 1.0
In-Reply-To: <1465495483-11855-11-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On 06/09/2016 08:04 PM, Mel Gorman wrote:
> Congested and dirty tracking of a node and whether reclaim should stall
> is still based on zone activity. This patch considers whether the kernel
> should stall based on node-based reclaim activity.

I'm a bit confused about the description vs actual code.
It appears to move some duplicated code to a related function, which is 
fine. The rest of callsites that didn't perform the clearing before 
(prepare_kswapd_sleep() and wakeup_kswapd()) might be a bit overkill, 
but won't hurt. But I don't see the part "considers whether the kernel
should stall based on node-based reclaim activity". Is something missing?

> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> ---
>  mm/vmscan.c | 24 ++++++++++++------------
>  1 file changed, 12 insertions(+), 12 deletions(-)
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index dd68e3154732..e4f3e068b7a0 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2966,7 +2966,17 @@ static bool zone_balanced(struct zone *zone, int order, int classzone_idx)
>  {
>  	unsigned long mark = high_wmark_pages(zone);
>
> -	return zone_watermark_ok_safe(zone, order, mark, classzone_idx);
> +	if (!zone_watermark_ok_safe(zone, order, mark, classzone_idx))
> +		return false;
> +
> +	/*
> +	 * If any eligible zone is balanced then the node is not considered
> +	 * to be congested or dirty
> +	 */
> +	clear_bit(PGDAT_CONGESTED, &zone->zone_pgdat->flags);
> +	clear_bit(PGDAT_DIRTY, &zone->zone_pgdat->flags);
> +
> +	return true;
>  }
>
>  /*
> @@ -3112,13 +3122,6 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
>  			if (!zone_balanced(zone, order, 0)) {
>  				classzone_idx = i;
>  				break;
> -			} else {
> -				/*
> -				 * If any eligible zone is balanced then the
> -				 * node is not considered congested or dirty.
> -				 */
> -				clear_bit(PGDAT_CONGESTED, &zone->zone_pgdat->flags);
> -				clear_bit(PGDAT_DIRTY, &zone->zone_pgdat->flags);
>  			}
>  		}
>
> @@ -3177,11 +3180,8 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
>  			if (!populated_zone(zone))
>  				continue;
>
> -			if (zone_balanced(zone, sc.order, classzone_idx)) {
> -				clear_bit(PGDAT_CONGESTED, &pgdat->flags);
> -				clear_bit(PGDAT_DIRTY, &pgdat->flags);
> +			if (zone_balanced(zone, sc.order, classzone_idx))
>  				goto out;
> -			}
>  		}
>
>  		/*
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
