Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f172.google.com (mail-we0-f172.google.com [74.125.82.172])
	by kanga.kvack.org (Postfix) with ESMTP id 04E406B0031
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 04:21:02 -0500 (EST)
Received: by mail-we0-f172.google.com with SMTP id p61so2130088wes.17
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 01:21:02 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fq5si1127389wic.50.2014.02.07.01.21.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 07 Feb 2014 01:21:01 -0800 (PST)
Message-ID: <52F4A579.7040009@suse.cz>
Date: Fri, 07 Feb 2014 10:20:57 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 1/5] mm/compaction: disallow high-order page for migration
 target
References: <1391749726-28910-1-git-send-email-iamjoonsoo.kim@lge.com> <1391749726-28910-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1391749726-28910-2-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Joonsoo Kim <js1304@gmail.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 02/07/2014 06:08 AM, Joonsoo Kim wrote:
> Purpose of compaction is to get a high order page. Currently, if we find
> high-order page while searching migration target page, we break it to
> order-0 pages and use them as migration target. It is contrary to purpose
> of compaction, so disallow high-order page to be used for
> migration target.

I guess this actually didn't trigger often because with large free blocks available,
compaction shouldn't even be running (unless started manually). But the change makes sense.

> Additionally, clean-up logic in suitable_migration_target() to simply.

simply -> simplify the code.

> There is no functional changes from this clean-up.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

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
> -	if (is_migrate_isolate(migratetype))
> -		return false;
> -
> -	/* If the page is a large free page, then allow migration */
> +	/* If the page is a large free page, then disallow migration */
>  	if (PageBuddy(page) && page_order(page) >= pageblock_order)
> -		return true;
> +		return false;
>  
>  	/* If the block is MIGRATE_MOVABLE or MIGRATE_CMA, allow migration */
> -	if (migrate_async_suitable(migratetype))
> +	if (migrate_async_suitable(get_pageblock_migratetype(page)))
>  		return true;
>  
>  	/* Otherwise skip the block */
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
