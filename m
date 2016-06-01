Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5C32F6B0264
	for <linux-mm@kvack.org>; Wed,  1 Jun 2016 10:08:04 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id 85so34260619ioq.3
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 07:08:04 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id ip4si1030309wjb.126.2016.06.01.07.08.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Jun 2016 07:08:03 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id q62so7146962wmg.3
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 07:08:03 -0700 (PDT)
Date: Wed, 1 Jun 2016 16:08:01 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 16/18] mm, compaction: require only min watermarks for
 non-costly orders
Message-ID: <20160601140801.GV26601@dhcp22.suse.cz>
References: <20160531130818.28724-1-vbabka@suse.cz>
 <20160531130818.28724-17-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160531130818.28724-17-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>

On Tue 31-05-16 15:08:16, Vlastimil Babka wrote:
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

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/compaction.c | 6 +++++-
>  mm/page_alloc.c | 2 +-
>  2 files changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 4ffa0870192b..d854519a5302 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1345,10 +1345,14 @@ static enum compact_result __compaction_suitable(struct zone *zone, int order,
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
> index 09dc9db8a7e9..5b4c9e567fc1 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2489,7 +2489,7 @@ int __isolate_free_page(struct page *page, unsigned int order)
>  
>  	if (!is_migrate_isolate(mt)) {
>  		/* Obey watermarks as if the page was being allocated */
> -		watermark = low_wmark_pages(zone) + (1 << order);
> +		watermark = min_wmark_pages(zone) + (1UL << order);
>  		if (!zone_watermark_ok(zone, 0, watermark, 0, ALLOC_CMA))
>  			return 0;
>  
> -- 
> 2.8.3

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
