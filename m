Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id B475F6B0038
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 05:12:13 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id d186so44507299lfg.7
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 02:12:13 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r1si16482673wjt.38.2016.10.13.02.12.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 13 Oct 2016 02:12:12 -0700 (PDT)
Subject: Re: [RFC PATCH 2/5] mm/page_alloc: use smallest fallback page first
 in movable allocation
References: <1476346102-26928-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1476346102-26928-3-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <2567dd30-89c7-b9d2-c327-5dec8c536040@suse.cz>
Date: Thu, 13 Oct 2016 11:12:10 +0200
MIME-Version: 1.0
In-Reply-To: <1476346102-26928-3-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 10/13/2016 10:08 AM, js1304@gmail.com wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
> When we try to find freepage in fallback buddy list, we always serach
> the largest one. This would help for fragmentation if we process
> unmovable/reclaimable allocation request because it could cause permanent
> fragmentation on movable pageblock and spread out such allocations would
> cause more fragmentation. But, movable allocation request is
> rather different. It would be simply freed or migrated so it doesn't
> contribute to fragmentation on the other pageblock. In this case, it would
> be better not to break the precious highest order freepage so we need to
> search the smallest freepage first.

I've also pondered this, but then found a lower hanging fruit that 
should be hopefully clear win and mitigate most cases of breaking 
high-order pages unnecessarily:

http://marc.info/?l=linux-mm&m=147582914330198&w=2

So I would try that first, and then test your patch on top? In your 
patch there's a risk that we make it harder for unmovable/reclaimable 
pageblocks to become movable again (we start with the smallest page 
which means there's lower chance that move_freepages_block() will 
convert more than half of the block). And Johannes's report seems to be 
about a regression in exactly this aspect of the heuristics.

> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>  mm/page_alloc.c | 26 +++++++++++++++++++++-----
>  1 file changed, 21 insertions(+), 5 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index c4f7d05..70427bf 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2121,15 +2121,31 @@ static void unreserve_highatomic_pageblock(const struct alloc_context *ac)
>  	int fallback_mt;
>  	bool can_steal;
>
> -	/* Find the largest possible block of pages in the other list */
> -	for (current_order = MAX_ORDER-1;
> -				current_order >= order && current_order <= MAX_ORDER-1;
> -				--current_order) {
> +	if (start_migratetype == MIGRATE_MOVABLE)
> +		current_order = order;
> +	else
> +		current_order = MAX_ORDER - 1;
> +
> +	/*
> +	 * Find the appropriate block of pages in the other list.
> +	 * If start_migratetype is MIGRATE_UNMOVABLE/MIGRATE_RECLAIMABLE,
> +	 * it would be better to find largest pageblock since it could cause
> +	 * fragmentation. However, in case of MIGRATE_MOVABLE, there is no
> +	 * risk about fragmentation so it would be better to use smallest one.
> +	 */
> +	while (current_order >= order && current_order <= MAX_ORDER - 1) {
> +
>  		area = &(zone->free_area[current_order]);
>  		fallback_mt = find_suitable_fallback(area, current_order,
>  				start_migratetype, false, &can_steal);
> -		if (fallback_mt == -1)
> +		if (fallback_mt == -1) {
> +			if (start_migratetype == MIGRATE_MOVABLE)
> +				current_order++;
> +			else
> +				current_order--;
> +
>  			continue;
> +		}
>
>  		page = list_first_entry(&area->free_list[fallback_mt],
>  						struct page, lru);
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
