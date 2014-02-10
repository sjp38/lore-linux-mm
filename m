Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id AA48F6B0031
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 08:26:40 -0500 (EST)
Received: by mail-wg0-f42.google.com with SMTP id l18so2538811wgh.5
        for <linux-mm@kvack.org>; Mon, 10 Feb 2014 05:26:39 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k1si7624420wjz.126.2014.02.10.05.26.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 10 Feb 2014 05:26:38 -0800 (PST)
Date: Mon, 10 Feb 2014 13:26:34 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 1/5] mm/compaction: disallow high-order page for
 migration target
Message-ID: <20140210132634.GE6732@suse.de>
References: <1391749726-28910-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1391749726-28910-2-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1391749726-28910-2-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <js1304@gmail.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Feb 07, 2014 at 02:08:42PM +0900, Joonsoo Kim wrote:
> Purpose of compaction is to get a high order page. Currently, if we find
> high-order page while searching migration target page, we break it to
> order-0 pages and use them as migration target. It is contrary to purpose
> of compaction, so disallow high-order page to be used for
> migration target.
> 
> Additionally, clean-up logic in suitable_migration_target() to simply.
> There is no functional changes from this clean-up.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 3a91a2e..bbe1260 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -217,21 +217,12 @@ static inline bool compact_trylock_irqsave(spinlock_t *lock,
>  /* Returns true if the page is within a block suitable for migration to */
>  static bool suitable_migration_target(struct page *page)
>  {
> -	int migratetype = get_pageblock_migratetype(page);
> -
> -	/* Don't interfere with memory hot-remove or the min_free_kbytes blocks */
> -	if (migratetype == MIGRATE_RESERVE)
> -		return false;
> -

Why is this check removed? The reservation blocks are preserved as
short-lived high-order atomic allocations depend on them.

> -	if (is_migrate_isolate(migratetype))
> -		return false;
> -

Why is this check removed?

> -	/* If the page is a large free page, then allow migration */
> +	/* If the page is a large free page, then disallow migration */
>  	if (PageBuddy(page) && page_order(page) >= pageblock_order)
> -		return true;
> +		return false;
>  

The reason why this was originally allowed was to allow pageblocks that were
marked MIGRATE_UNMOVABLE or MIGRATE_RECLAIMABLE to be used as compaction
targets. However, compaction should not even be running if this is the
case so the change makes sense.

>  	/* If the block is MIGRATE_MOVABLE or MIGRATE_CMA, allow migration */
> -	if (migrate_async_suitable(migratetype))
> +	if (migrate_async_suitable(get_pageblock_migratetype(page)))
>  		return true;
>  
>  	/* Otherwise skip the block */
> -- 
> 1.7.9.5
> 

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
