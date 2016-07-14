Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6B05B6B0005
	for <linux-mm@kvack.org>; Thu, 14 Jul 2016 05:19:58 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id x83so51458035wma.2
        for <linux-mm@kvack.org>; Thu, 14 Jul 2016 02:19:58 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q11si813579lfq.398.2016.07.14.02.19.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 14 Jul 2016 02:19:57 -0700 (PDT)
Subject: Re: [PATCH 05/34] mm, vmscan: begin reclaiming pages on a per-node
 basis
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
 <1467970510-21195-6-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <b3983893-0b96-25f9-60a8-d4b40052285c@suse.cz>
Date: Thu, 14 Jul 2016 11:19:24 +0200
MIME-Version: 1.0
In-Reply-To: <1467970510-21195-6-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>

On 07/08/2016 11:34 AM, Mel Gorman wrote:
> This patch makes reclaim decisions on a per-node basis.  A reclaimer knows
> what zone is required by the allocation request and skips pages from
> higher zones.  In many cases this will be ok because it's a GFP_HIGHMEM
> request of some description.  On 64-bit, ZONE_DMA32 requests will cause
> some problems but 32-bit devices on 64-bit platforms are increasingly
> rare.  Historically it would have been a major problem on 32-bit with big
> Highmem:Lowmem ratios but such configurations are also now rare and even
> where they exist, they are not encouraged.  If it really becomes a
> problem, it'll manifest as very low reclaim efficiencies.
>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

I think my previous complaints are fixed.

Acked-by: Vlastimil Babka <vbabka@suse.cz>

[...]

> @@ -2553,7 +2572,7 @@ static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
>  	unsigned long nr_soft_reclaimed;
>  	unsigned long nr_soft_scanned;
>  	gfp_t orig_mask;
> -	enum zone_type requested_highidx = gfp_zone(sc->gfp_mask);
> +	enum zone_type classzone_idx;
>
>  	/*
>  	 * If the number of buffer_heads in the machine exceeds the maximum
> @@ -2561,17 +2580,23 @@ static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
>  	 * highmem pages could be pinning lowmem pages storing buffer_heads
>  	 */
>  	orig_mask = sc->gfp_mask;
> -	if (buffer_heads_over_limit)
> +	if (buffer_heads_over_limit) {
>  		sc->gfp_mask |= __GFP_HIGHMEM;
> +		sc->reclaim_idx = classzone_idx = gfp_zone(sc->gfp_mask);

Setting classzone_idx seems pointless here as it will be overwritten in 
the for loop. Unless that changes with some later patch. Anyway it 
doesn't hurt anything.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
