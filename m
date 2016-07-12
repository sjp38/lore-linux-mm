Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 567626B025E
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 10:29:15 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id l89so12783173lfi.3
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 07:29:15 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id k135si20935542wmg.61.2016.07.12.07.29.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jul 2016 07:29:14 -0700 (PDT)
Date: Tue, 12 Jul 2016 10:29:09 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 12/34] mm: vmscan: do not reclaim from kswapd if there is
 any eligible zone
Message-ID: <20160712142909.GF5881@cmpxchg.org>
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
 <1467970510-21195-13-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1467970510-21195-13-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jul 08, 2016 at 10:34:48AM +0100, Mel Gorman wrote:
> kswapd scans from highest to lowest for a zone that requires balancing.
> This was necessary when reclaim was per-zone to fairly age pages on lower
> zones.  Now that we are reclaiming on a per-node basis, any eligible zone
> can be used and pages will still be aged fairly.  This patch avoids
> reclaiming excessively unless buffer_heads are over the limit and it's
> necessary to reclaim from a higher zone than requested by the waker of
> kswapd to relieve low memory pressure.
> 
> [hillf.zj@alibaba-inc.com: Force kswapd reclaim no more than needed]
> Link: http://lkml.kernel.org/r/1466518566-30034-12-git-send-email-mgorman@techsingularity.net
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Signed-off-by: Hillf Danton <hillf.zj@alibaba-inc.com>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

One and a half observations:

> @@ -3144,31 +3144,39 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
>  
>  		sc.nr_reclaimed = 0;
>  
> -		/* Scan from the highest requested zone to dma */
> -		for (i = classzone_idx; i >= 0; i--) {
> -			zone = pgdat->node_zones + i;
> -			if (!populated_zone(zone))
> -				continue;
> -
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
> +		/*
> +		 * If the number of buffer_heads in the machine exceeds the
> +		 * maximum allowed level then reclaim from all zones. This is
> +		 * not specific to highmem as highmem may not exist but it is
> +		 * it is expected that buffer_heads are stripped in writeback.

The mention of highmem in this comment make only sense within the
context of this diff; it'll be pretty confusing in the standalone
code.

Also, double "it is" :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
