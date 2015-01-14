Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 87DA16B0032
	for <linux-mm@kvack.org>; Wed, 14 Jan 2015 09:55:41 -0500 (EST)
Received: by mail-wg0-f51.google.com with SMTP id x12so9349937wgg.10
        for <linux-mm@kvack.org>; Wed, 14 Jan 2015 06:55:41 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m10si48354730wjx.45.2015.01.14.06.55.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 14 Jan 2015 06:55:40 -0800 (PST)
Message-ID: <54B6836B.5030603@suse.cz>
Date: Wed, 14 Jan 2015 15:55:39 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH V2 linux-next] mm,compaction: move suitable_migration_target()
 under CONFIG_COMPACTION
References: <1421173304-11514-1-git-send-email-fabf@skynet.be>
In-Reply-To: <1421173304-11514-1-git-send-email-fabf@skynet.be>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fabian Frederick <fabf@skynet.be>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org

On 01/13/2015 07:21 PM, Fabian Frederick wrote:
> suitable_migration_target() is only used by isolate_freepages()
> Define it under CONFIG_COMPACTION || CONFIG_CMA is not needed.
> 
> Fix the following warning:
> mm/compaction.c:311:13: warning: 'suitable_migration_target' defined
> but not used [-Wunused-function]
> 
> Signed-off-by: Fabian Frederick <fabf@skynet.be>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

Thanks.

> ---
> v2: move function below update_pageblock_skip() instead of above 
> isolate_freepages() (suggested by Vlastimil Babka)
> 
> 
>  mm/compaction.c | 44 ++++++++++++++++++++++----------------------
>  1 file changed, 22 insertions(+), 22 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 546e571..580790d 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -207,6 +207,28 @@ static void update_pageblock_skip(struct compact_control *cc,
>  			zone->compact_cached_free_pfn = pfn;
>  	}
>  }
> +
> +/* Returns true if the page is within a block suitable for migration to */
> +static bool suitable_migration_target(struct page *page)
> +{
> +	/* If the page is a large free page, then disallow migration */
> +	if (PageBuddy(page)) {
> +		/*
> +		 * We are checking page_order without zone->lock taken. But
> +		 * the only small danger is that we skip a potentially suitable
> +		 * pageblock, so it's not worth to check order for valid range.
> +		 */
> +		if (page_order_unsafe(page) >= pageblock_order)
> +			return false;
> +	}
> +
> +	/* If the block is MIGRATE_MOVABLE or MIGRATE_CMA, allow migration */
> +	if (migrate_async_suitable(get_pageblock_migratetype(page)))
> +		return true;
> +
> +	/* Otherwise skip the block */
> +	return false;
> +}
>  #else
>  static inline bool isolation_suitable(struct compact_control *cc,
>  					struct page *page)
> @@ -307,28 +329,6 @@ static inline bool compact_should_abort(struct compact_control *cc)
>  	return false;
>  }
>  
> -/* Returns true if the page is within a block suitable for migration to */
> -static bool suitable_migration_target(struct page *page)
> -{
> -	/* If the page is a large free page, then disallow migration */
> -	if (PageBuddy(page)) {
> -		/*
> -		 * We are checking page_order without zone->lock taken. But
> -		 * the only small danger is that we skip a potentially suitable
> -		 * pageblock, so it's not worth to check order for valid range.
> -		 */
> -		if (page_order_unsafe(page) >= pageblock_order)
> -			return false;
> -	}
> -
> -	/* If the block is MIGRATE_MOVABLE or MIGRATE_CMA, allow migration */
> -	if (migrate_async_suitable(get_pageblock_migratetype(page)))
> -		return true;
> -
> -	/* Otherwise skip the block */
> -	return false;
> -}
> -
>  /*
>   * Isolate free pages onto a private freelist. If @strict is true, will abort
>   * returning 0 on any invalid PFNs or non-free pages inside of the pageblock
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
