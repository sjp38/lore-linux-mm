Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id B7C416B039F
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 13:10:39 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id c85so9548754wmi.6
        for <linux-mm@kvack.org>; Tue, 14 Feb 2017 10:10:39 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id w22si2116161wmd.66.2017.02.14.10.10.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Feb 2017 10:10:38 -0800 (PST)
Date: Tue, 14 Feb 2017 13:10:30 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2 04/10] mm, page_alloc: count movable pages when
 stealing from pageblock
Message-ID: <20170214181030.GE2450@cmpxchg.org>
References: <20170210172343.30283-1-vbabka@suse.cz>
 <20170210172343.30283-5-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170210172343.30283-5-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Fri, Feb 10, 2017 at 06:23:37PM +0100, Vlastimil Babka wrote:
> When stealing pages from pageblock of a different migratetype, we count how
> many free pages were stolen, and change the pageblock's migratetype if more
> than half of the pageblock was free. This might be too conservative, as there
> might be other pages that are not free, but were allocated with the same
> migratetype as our allocation requested.
> 
> While we cannot determine the migratetype of allocated pages precisely (at
> least without the page_owner functionality enabled), we can count pages that
> compaction would try to isolate for migration - those are either on LRU or
> __PageMovable(). The rest can be assumed to be MIGRATE_RECLAIMABLE or
> MIGRATE_UNMOVABLE, which we cannot easily distinguish. This counting can be
> done as part of free page stealing with little additional overhead.
> 
> The page stealing code is changed so that it considers free pages plus pages
> of the "good" migratetype for the decision whether to change pageblock's
> migratetype.
> 
> The result should be more accurate migratetype of pageblocks wrt the actual
> pages in the pageblocks, when stealing from semi-occupied pageblocks. This
> should help the efficiency of page grouping by mobility.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

That makes sense to me. I have just one nit about the patch:

> @@ -1981,10 +1994,29 @@ static void steal_suitable_fallback(struct zone *zone, struct page *page,
>  		return;
>  	}
>  
> -	pages = move_freepages_block(zone, page, start_type);
> +	free_pages = move_freepages_block(zone, page, start_type,
> +						&good_pages);
> +	/*
> +	 * good_pages is now the number of movable pages, but if we
> +	 * want UNMOVABLE or RECLAIMABLE allocation, it's more tricky
> +	 */
> +	if (start_type != MIGRATE_MOVABLE) {
> +		/*
> +		 * If we are falling back to MIGRATE_MOVABLE pageblock,
> +		 * treat all non-movable pages as good. If it's UNMOVABLE
> +		 * falling back to RECLAIMABLE or vice versa, be conservative
> +		 * as we can't distinguish the exact migratetype.
> +		 */
> +		old_block_type = get_pageblock_migratetype(page);
> +		if (old_block_type == MIGRATE_MOVABLE)
> +			good_pages = pageblock_nr_pages
> +						- free_pages - good_pages;

This line had me scratch my head for a while, and I think it's mostly
because of the variable naming and the way the comments are phrased.

Could you use a variable called movable_pages to pass to and be filled
in by move_freepages_block?

And instead of good_pages something like starttype_pages or
alike_pages or st_pages or mt_pages or something, to indicate the
number of pages that are comparable to the allocation's migratetype?

> -	/* Claim the whole block if over half of it is free */
> -	if (pages >= (1 << (pageblock_order-1)) ||
> +	/* Claim the whole block if over half of it is free or good type */
> +	if (free_pages + good_pages >= (1 << (pageblock_order-1)) ||
>  			page_group_by_mobility_disabled)
>  		set_pageblock_migratetype(page, start_type);

This would then read

	if (free_pages + alike_pages ...)

which I think would be more descriptive.

The comment leading the entire section following move_freepages_block
could then say something like "If a sufficient number of pages in the
block are either free or of comparable migratability as our
allocation, claim the whole block." Followed by the caveats of how we
determine this migratibility.

Or maybe even the function. The comment above the function seems out
of date after this patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
