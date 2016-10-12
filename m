Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 328F36B0069
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 03:24:14 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id f193so4344699wmg.2
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 00:24:14 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id fg1si8813794wjc.27.2016.10.12.00.24.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Oct 2016 00:24:12 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id o81so998862wma.0
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 00:24:11 -0700 (PDT)
Date: Wed, 12 Oct 2016 09:24:09 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 3/4] mm: try to exhaust highatomic reserve before the
 OOM
Message-ID: <20161012072409.GB9504@dhcp22.suse.cz>
References: <1476250416-22733-1-git-send-email-minchan@kernel.org>
 <1476250416-22733-4-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1476250416-22733-4-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sangseok Lee <sangseok.lee@lge.com>

On Wed 12-10-16 14:33:35, Minchan Kim wrote:
> It's weird to show that zone has enough free memory above min
> watermark but OOMed with 4K GFP_KERNEL allocation due to
> reserved highatomic pages. As last resort, try to unreserve
> highatomic pages again and if it has moved pages to
> non-highatmoc free list, retry reclaim once more.

Agreed with Vlastimil on the OOM report in the changelog. The above will
not tell the reader much to understand how does the situation look like
and whether the patch is really needed in his particular situation.

Few nits below but in general looks good to me

> Signed-off-by: Michal Hocko <mhocko@suse.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  mm/page_alloc.c | 15 +++++++++++----
>  1 file changed, 11 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 18808f392718..a7472426663f 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2080,7 +2080,7 @@ static void reserve_highatomic_pageblock(struct page *page, struct zone *zone,
>   * intense memory pressure but failed atomic allocations should be easier
>   * to recover from than an OOM.
>   */
> -static void unreserve_highatomic_pageblock(const struct alloc_context *ac)
> +static bool unreserve_highatomic_pageblock(const struct alloc_context *ac)
>  {
>  	struct zonelist *zonelist = ac->zonelist;
>  	unsigned long flags;
> @@ -2088,6 +2088,7 @@ static void unreserve_highatomic_pageblock(const struct alloc_context *ac)
>  	struct zone *zone;
>  	struct page *page;
>  	int order;
> +	bool ret = false;

no need to initialization, see below
>  
>  	for_each_zone_zonelist_nodemask(zone, z, zonelist, ac->high_zoneidx,
>  								ac->nodemask) {
> @@ -2136,12 +2137,14 @@ static void unreserve_highatomic_pageblock(const struct alloc_context *ac)
>  			 * may increase.
>  			 */
>  			set_pageblock_migratetype(page, ac->migratetype);
> -			move_freepages_block(zone, page, ac->migratetype);
> +			ret = move_freepages_block(zone, page, ac->migratetype);
>  			spin_unlock_irqrestore(&zone->lock, flags);
> -			return;
> +			return ret;
>  		}
>  		spin_unlock_irqrestore(&zone->lock, flags);
>  	}
> +
> +	return ret;

	return false;
>  }
>  
>  /* Remove an element from the buddy allocator from the fallback list */
> @@ -3457,8 +3460,12 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
>  	 * Make sure we converge to OOM if we cannot make any progress
>  	 * several times in the row.
>  	 */
> -	if (*no_progress_loops > MAX_RECLAIM_RETRIES)
> +	if (*no_progress_loops > MAX_RECLAIM_RETRIES) {
> +		/* Before OOM, exhaust highatomic_reserve */
> +		if (unreserve_highatomic_pageblock(ac))
> +			return true;

		return unreserve_highatomic_pageblock(ac);

>  		return false;
> +	}
>  
>  	/*
>  	 * Keep reclaiming pages while there is a chance this will lead
> -- 
> 2.7.4
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
