Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 400E26B025F
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 06:09:01 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 4so24301386wmz.1
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 03:09:01 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e188si3553437wmd.53.2016.06.16.03.08.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Jun 2016 03:08:59 -0700 (PDT)
Subject: Re: [PATCH 11/27] mm: vmscan: Do not reclaim from kswapd if there is
 any eligible zone
References: <1465495483-11855-1-git-send-email-mgorman@techsingularity.net>
 <1465495483-11855-12-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <a2be0855-c923-7338-ee37-941a6770f221@suse.cz>
Date: Thu, 16 Jun 2016 12:08:58 +0200
MIME-Version: 1.0
In-Reply-To: <1465495483-11855-12-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On 06/09/2016 08:04 PM, Mel Gorman wrote:
> kswapd scans from highest to lowest for a zone that requires balancing.
> This was necessary when reclaim was per-zone to fairly age pages on
> lower zones. Now that we are reclaiming on a per-node basis, any eligible
> zone can be used and pages will still be aged fairly. This patch avoids
> reclaiming excessively unless buffer_heads are over the limit and it's
> necessary to reclaim from a higher zone than requested by the waker of
> kswapd to relieve low memory pressure.

Looks like the code was even wrong before... if classzone_idx wasn't 
already set to the highmem zone in the first place, it wouldn't look at it.

> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

After fixing the bug below,

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/vmscan.c | 32 +++++++++++++++++++-------------
>  1 file changed, 19 insertions(+), 13 deletions(-)
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index e4f3e068b7a0..6663fc75c3bc 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -3102,24 +3102,30 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
>
>  		sc.nr_reclaimed = 0;
>
> -		/* Scan from the highest requested zone to dma */
> +		/*
> +		 * If the number of buffer_heads in the machine exceeds the
> +		 * maximum allowed level and this node has a highmem zone,
> +		 * force kswapd to reclaim from it to relieve lowmem pressure.
> +		 */
> +		if (buffer_heads_over_limit) {
> +			for (i = MAX_NR_ZONES - 1; i >= 0; i++) {

                                                            i--

> +				zone = pgdat->node_zones + i;
> +				if (!populated_zone(zone))
> +					continue;
> +
> +				if (is_highmem_idx(i))
> +					classzone_idx = i;
> +				break;
> +			}
> +		}
> +
> +		/* Only reclaim if there are no eligible zones */
>  		for (i = classzone_idx; i >= 0; i--) {
>  			zone = pgdat->node_zones + i;
>  			if (!populated_zone(zone))
>  				continue;
>
> -			/*
> -			 * If the number of buffer_heads in the machine
> -			 * exceeds the maximum allowed level and this node
> -			 * has a highmem zone, force kswapd to reclaim from
> -			 * it to relieve lowmem pressure.
> -			 */
> -			if (buffer_heads_over_limit && is_highmem_idx(i)) {
> -				classzone_idx = i;
> -				break;
> -			}
> -
> -			if (!zone_balanced(zone, order, 0)) {
> +			if (!zone_balanced(zone, sc.order, classzone_idx)) {
>  				classzone_idx = i;
>  				break;
>  			}
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
