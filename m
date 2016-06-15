Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id CF0916B025F
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 09:13:15 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id a2so7245104lfe.0
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 06:13:15 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r3si41480179wjo.192.2016.06.15.06.13.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 15 Jun 2016 06:13:14 -0700 (PDT)
Subject: Re: [PATCH 05/27] mm, vmscan: Have kswapd only scan based on the
 highest requested zone
References: <1465495483-11855-1-git-send-email-mgorman@techsingularity.net>
 <1465495483-11855-6-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <dea59a5e-eaf4-58d7-412b-b543ceb8709a@suse.cz>
Date: Wed, 15 Jun 2016 15:13:13 +0200
MIME-Version: 1.0
In-Reply-To: <1465495483-11855-6-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On 06/09/2016 08:04 PM, Mel Gorman wrote:
> kswapd checks all eligible zones to see if they need balancing even if it was
> woken for a lower zone. This made sense when we reclaimed on a per-zone basis
> because we wanted to shrink zones fairly so avoid age-inversion problems.

Now we reclaim a single lru, but still will skip over pages from the 
higher zones than reclaim_idx, so this is not much different from 
per-zone basis wrt age-inversion?

> Ideally this is completely unnecessary when reclaiming on a per-node basis.
> In theory, there may still be anomalies when all requests are for lower
> zones and very old pages are preserved in higher zones but this should be
> the exceptional case.
>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

I don't see the argument, but agree it should be exceptional in any 
case, and if there's such a case, it's better to focus on pages from the 
zone(s) where a pending (potentially atomic) allocation is restricted 
to. Or rather, this is the only way we can focus reclaim on such pages 
now that there's a single lru list.

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/vmscan.c | 7 ++-----
>  1 file changed, 2 insertions(+), 5 deletions(-)
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index ab1b28e7e20a..0a619241c576 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -3171,11 +3171,8 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
>
>  		sc.nr_reclaimed = 0;
>
> -		/*
> -		 * Scan in the highmem->dma direction for the highest
> -		 * zone which needs scanning
> -		 */
> -		for (i = pgdat->nr_zones - 1; i >= 0; i--) {
> +		/* Scan from the highest requested zone to dma */
> +		for (i = classzone_idx; i >= 0; i--) {
>  			struct zone *zone = pgdat->node_zones + i;
>
>  			if (!populated_zone(zone))
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
