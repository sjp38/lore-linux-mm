Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0D5866B0253
	for <linux-mm@kvack.org>; Wed,  6 Jul 2016 21:39:57 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id x68so21303191ioi.0
        for <linux-mm@kvack.org>; Wed, 06 Jul 2016 18:39:57 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id i1si995881ith.118.2016.07.06.18.39.55
        for <linux-mm@kvack.org>;
        Wed, 06 Jul 2016 18:39:56 -0700 (PDT)
Date: Thu, 7 Jul 2016 10:43:22 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 09/31] mm, vmscan: by default have direct reclaim only
 shrink once per node
Message-ID: <20160707014321.GD27987@js1304-P5Q-DELUXE>
References: <1467403299-25786-1-git-send-email-mgorman@techsingularity.net>
 <1467403299-25786-10-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1467403299-25786-10-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jul 01, 2016 at 09:01:17PM +0100, Mel Gorman wrote:
> Direct reclaim iterates over all zones in the zonelist and shrinking them
> but this is in conflict with node-based reclaim.  In the default case,
> only shrink once per node.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> ---
>  mm/vmscan.c | 19 +++++++++++--------
>  1 file changed, 11 insertions(+), 8 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index b524d3b72527..34656173a670 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2552,14 +2552,6 @@ static inline bool compaction_ready(struct zone *zone, int order, int classzone_
>   * try to reclaim pages from zones which will satisfy the caller's allocation
>   * request.
>   *
> - * We reclaim from a zone even if that zone is over high_wmark_pages(zone).
> - * Because:
> - * a) The caller may be trying to free *extra* pages to satisfy a higher-order
> - *    allocation or
> - * b) The target zone may be at high_wmark_pages(zone) but the lower zones
> - *    must go *over* high_wmark_pages(zone) to satisfy the `incremental min'
> - *    zone defense algorithm.
> - *
>   * If a zone is deemed to be full of pinned pages then just give it a light
>   * scan then give up on it.
>   */
> @@ -2571,6 +2563,7 @@ static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
>  	unsigned long nr_soft_scanned;
>  	gfp_t orig_mask;
>  	enum zone_type classzone_idx;
> +	pg_data_t *last_pgdat = NULL;
>  
>  	/*
>  	 * If the number of buffer_heads in the machine exceeds the maximum
> @@ -2600,6 +2593,16 @@ static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
>  			classzone_idx--;
>  
>  		/*
> +		 * Shrink each node in the zonelist once. If the zonelist is
> +		 * ordered by zone (not the default) then a node may be
> +		 * shrunk multiple times but in that case the user prefers
> +		 * lower zones being preserved
> +		 */
> +		if (zone->zone_pgdat == last_pgdat)
> +			continue;
> +		last_pgdat = zone->zone_pgdat;
> +
> +		/*

After this change, compaction_ready() which uses zone information
would be called with highest zone in node. So, if some lower zone in
that node is compaction-ready, we cannot stop the reclaim.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
