Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 438E76B0069
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 03:14:16 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id o81so4126000wma.7
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 00:14:16 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d41si1303302wma.65.2016.10.12.00.14.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 12 Oct 2016 00:14:15 -0700 (PDT)
Subject: Re: [PATCH v2 3/4] mm: try to exhaust highatomic reserve before the
 OOM
References: <1476250416-22733-1-git-send-email-minchan@kernel.org>
 <1476250416-22733-4-git-send-email-minchan@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <820f4364-9a3f-b076-d235-04b40b1ee20f@suse.cz>
Date: Wed, 12 Oct 2016 09:14:06 +0200
MIME-Version: 1.0
In-Reply-To: <1476250416-22733-4-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sangseok Lee <sangseok.lee@lge.com>, Michal Hocko <mhocko@suse.com>

On 10/12/2016 07:33 AM, Minchan Kim wrote:
> It's weird to show that zone has enough free memory above min
> watermark but OOMed with 4K GFP_KERNEL allocation due to
> reserved highatomic pages. As last resort, try to unreserve
> highatomic pages again and if it has moved pages to
> non-highatmoc free list, retry reclaim once more.

I would move the details (OOM report etc) from the cover letter here, otherwise 
they end up in Patch 1's changelog, which is less helpful.

> Signed-off-by: Michal Hocko <mhocko@suse.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

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
>  		return false;
> +	}
>
>  	/*
>  	 * Keep reclaiming pages while there is a chance this will lead
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
