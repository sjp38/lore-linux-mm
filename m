Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 780596B0069
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 03:19:46 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id o81so4201790wma.7
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 00:19:46 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 196si1336893wmf.30.2016.10.12.00.19.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 12 Oct 2016 00:19:45 -0700 (PDT)
Subject: Re: [PATCH v2 4/4] mm: make unreserve highatomic functions reliable
References: <1476250416-22733-1-git-send-email-minchan@kernel.org>
 <1476250416-22733-5-git-send-email-minchan@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <77a189db-1ca6-05cc-9b79-c9b5d598ec1d@suse.cz>
Date: Wed, 12 Oct 2016 09:19:42 +0200
MIME-Version: 1.0
In-Reply-To: <1476250416-22733-5-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sangseok Lee <sangseok.lee@lge.com>, Michal Hocko <mhocko@suse.com>

On 10/12/2016 07:33 AM, Minchan Kim wrote:
> Currently, unreserve_highatomic_pageblock bails out if it found
> highatomic pageblock regardless of really moving free pages
> from the one so that it could mitigate unreserve logic's goal
> which saves OOM of a process.
>
> This patch makes unreserve functions bail out only if it moves
> some pages out of !highatomic free list to avoid such false
> positive.
>
> Another potential problem is that by race between page freeing and
> reserve highatomic function, pages could be in highatomic free list
> even though the pageblock is !high atomic migratetype. In that case,
> unreserve_highatomic_pageblock can be void if count of highatomic
> reserve is less than pageblock_nr_pages. We could solve it simply
> via draining all of reserved pages before the OOM. It would have
> a safeguard role to exhuast reserved pages before converging to OOM.
>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Ah, I think that the first S-o-b has to match "From:" to be valid chain (also 
for 3/4).

> Signed-off-by: Minchan Kim <minchan@kernel.org>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/page_alloc.c | 24 +++++++++++++++++-------
>  1 file changed, 17 insertions(+), 7 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index a7472426663f..565589eae6a2 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2079,8 +2079,12 @@ static void reserve_highatomic_pageblock(struct page *page, struct zone *zone,
>   * potentially hurts the reliability of high-order allocations when under
>   * intense memory pressure but failed atomic allocations should be easier
>   * to recover from than an OOM.
> + *
> + * If @drain is true, try to move all of reserved pages out of highatomic
> + * free list.
>   */
> -static bool unreserve_highatomic_pageblock(const struct alloc_context *ac)
> +static bool unreserve_highatomic_pageblock(const struct alloc_context *ac,
> +						bool drain)
>  {
>  	struct zonelist *zonelist = ac->zonelist;
>  	unsigned long flags;
> @@ -2092,8 +2096,12 @@ static bool unreserve_highatomic_pageblock(const struct alloc_context *ac)
>
>  	for_each_zone_zonelist_nodemask(zone, z, zonelist, ac->high_zoneidx,
>  								ac->nodemask) {
> -		/* Preserve at least one pageblock */
> -		if (zone->nr_reserved_highatomic <= pageblock_nr_pages)
> +		/*
> +		 * Preserve at least one pageblock unless memory pressure
> +		 * is really high.
> +		 */
> +		if (!drain && zone->nr_reserved_highatomic <=
> +					pageblock_nr_pages)
>  			continue;
>
>  		spin_lock_irqsave(&zone->lock, flags);
> @@ -2138,8 +2146,10 @@ static bool unreserve_highatomic_pageblock(const struct alloc_context *ac)
>  			 */
>  			set_pageblock_migratetype(page, ac->migratetype);
>  			ret = move_freepages_block(zone, page, ac->migratetype);
> -			spin_unlock_irqrestore(&zone->lock, flags);
> -			return ret;
> +			if (!drain && ret) {
> +				spin_unlock_irqrestore(&zone->lock, flags);
> +				return ret;
> +			}
>  		}
>  		spin_unlock_irqrestore(&zone->lock, flags);
>  	}
> @@ -3343,7 +3353,7 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
>  	 * Shrink them them and try again
>  	 */
>  	if (!page && !drained) {
> -		unreserve_highatomic_pageblock(ac);
> +		unreserve_highatomic_pageblock(ac, false);
>  		drain_all_pages(NULL);
>  		drained = true;
>  		goto retry;
> @@ -3462,7 +3472,7 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
>  	 */
>  	if (*no_progress_loops > MAX_RECLAIM_RETRIES) {
>  		/* Before OOM, exhaust highatomic_reserve */
> -		if (unreserve_highatomic_pageblock(ac))
> +		if (unreserve_highatomic_pageblock(ac, true))
>  			return true;
>  		return false;
>  	}
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
