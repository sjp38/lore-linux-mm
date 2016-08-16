Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 757976B025E
	for <linux-mm@kvack.org>; Tue, 16 Aug 2016 02:10:47 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id m130so205419104ioa.1
        for <linux-mm@kvack.org>; Mon, 15 Aug 2016 23:10:47 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id n138si20035509ita.22.2016.08.15.23.10.46
        for <linux-mm@kvack.org>;
        Mon, 15 Aug 2016 23:10:46 -0700 (PDT)
Date: Tue, 16 Aug 2016 15:16:36 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v6 10/11] mm, compaction: require only min watermarks for
 non-costly orders
Message-ID: <20160816061636.GF17448@js1304-P5Q-DELUXE>
References: <20160810091226.6709-1-vbabka@suse.cz>
 <20160810091226.6709-11-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160810091226.6709-11-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Aug 10, 2016 at 11:12:25AM +0200, Vlastimil Babka wrote:
> The __compaction_suitable() function checks the low watermark plus a
> compact_gap() gap to decide if there's enough free memory to perform
> compaction. Then __isolate_free_page uses low watermark check to decide if
> particular free page can be isolated. In the latter case, using low watermark
> is needlessly pessimistic, as the free page isolations are only temporary. For
> __compaction_suitable() the higher watermark makes sense for high-order
> allocations where more freepages increase the chance of success, and we can
> typically fail with some order-0 fallback when the system is struggling to
> reach that watermark. But for low-order allocation, forming the page should not
> be that hard. So using low watermark here might just prevent compaction from
> even trying, and eventually lead to OOM killer even if we are above min
> watermarks.
> 
> So after this patch, we use min watermark for non-costly orders in
> __compaction_suitable(), and for all orders in __isolate_free_page().
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Acked-by: Michal Hocko <mhocko@suse.com>
> ---
>  mm/compaction.c | 6 +++++-
>  mm/page_alloc.c | 2 +-
>  2 files changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 80eaf9fff114..0bba270f97ad 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1399,10 +1399,14 @@ static enum compact_result __compaction_suitable(struct zone *zone, int order,
>  	 * isolation. We however do use the direct compactor's classzone_idx to
>  	 * skip over zones where lowmem reserves would prevent allocation even
>  	 * if compaction succeeds.
> +	 * For costly orders, we require low watermark instead of min for
> +	 * compaction to proceed to increase its chances.
>  	 * ALLOC_CMA is used, as pages in CMA pageblocks are considered
>  	 * suitable migration targets
>  	 */
> -	watermark = low_wmark_pages(zone) + compact_gap(order);
> +	watermark = (order > PAGE_ALLOC_COSTLY_ORDER) ?
> +				low_wmark_pages(zone) : min_wmark_pages(zone);
> +	watermark += compact_gap(order);
>  	if (!__zone_watermark_ok(zone, 0, watermark, classzone_idx,
>  						ALLOC_CMA, wmark_target))
>  		return COMPACT_SKIPPED;
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 621e4211ce16..a5c0f914ec00 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2492,7 +2492,7 @@ int __isolate_free_page(struct page *page, unsigned int order)
>  
>  	if (!is_migrate_isolate(mt)) {
>  		/* Obey watermarks as if the page was being allocated */
> -		watermark = low_wmark_pages(zone) + (1 << order);
> +		watermark = min_wmark_pages(zone) + (1UL << order);

This '1 << order' also needs some comment. Why can't we use
compact_gap() in this case?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
