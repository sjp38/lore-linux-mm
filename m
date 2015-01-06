Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f51.google.com (mail-la0-f51.google.com [209.85.215.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4917B6B00DC
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 12:21:26 -0500 (EST)
Received: by mail-la0-f51.google.com with SMTP id ms9so20120124lab.24
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 09:21:24 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j2si30502909wiz.3.2015.01.06.09.21.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 Jan 2015 09:21:23 -0800 (PST)
Message-ID: <54AC1991.9060908@suse.cz>
Date: Tue, 06 Jan 2015 18:21:21 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 1/1 linux-next] mm,compaction: move suitable_migration_target()
 under CONFIG_COMPACTION
References: <1420301068-19447-1-git-send-email-fabf@skynet.be>
In-Reply-To: <1420301068-19447-1-git-send-email-fabf@skynet.be>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fabian Frederick <fabf@skynet.be>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org

On 01/03/2015 05:04 PM, Fabian Frederick wrote:
> suitable_migration_target() is only used by isolate_freepages()
> Define it under CONFIG_COMPACTION || CONFIG_CMA is not needed.
> 
> Fix the following warning:
> mm/compaction.c:311:13: warning: 'suitable_migration_target' defined
> but not used [-Wunused-function]
> 
> Signed-off-by: Fabian Frederick <fabf@skynet.be>

I agree, I would just move it to the section where isolation_suitable() and
related others are, maybe at the end of this section below update_pageblock_skip()?

Vlastimil

> ---
>  mm/compaction.c | 44 ++++++++++++++++++++++----------------------
>  1 file changed, 22 insertions(+), 22 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 546e571..38b151c 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -307,28 +307,6 @@ static inline bool compact_should_abort(struct compact_control *cc)
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
> @@ -802,6 +780,28 @@ isolate_migratepages_range(struct compact_control *cc, unsigned long start_pfn,
>  
>  #endif /* CONFIG_COMPACTION || CONFIG_CMA */
>  #ifdef CONFIG_COMPACTION
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
> +
>  /*
>   * Based on information in the current compact_control, find blocks
>   * suitable for isolating free pages from and then isolate them.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
