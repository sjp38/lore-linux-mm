Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f197.google.com (mail-lb0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 89F556B025E
	for <linux-mm@kvack.org>; Tue, 21 Jun 2016 07:43:53 -0400 (EDT)
Received: by mail-lb0-f197.google.com with SMTP id js8so11360064lbc.2
        for <linux-mm@kvack.org>; Tue, 21 Jun 2016 04:43:53 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q10si33052434wjc.95.2016.06.21.04.43.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 21 Jun 2016 04:43:51 -0700 (PDT)
Subject: Re: [patch] mm, compaction: abort free scanner if split fails
References: <alpine.DEB.2.10.1606151530590.37360@chino.kir.corp.google.com>
 <4f5ba93e-8bf0-151e-57eb-cad1a4823b9e@suse.cz>
 <alpine.DEB.2.10.1606201443350.33055@chino.kir.corp.google.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5783072b-0341-dccb-8f07-c92230964d83@suse.cz>
Date: Tue, 21 Jun 2016 13:43:47 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1606201443350.33055@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Hugh Dickins <hughd@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>

On 06/21/2016 12:27 AM, David Rientjes wrote:
> If the memory compaction free scanner cannot successfully split a free
> page (only possible due to per-zone low watermark), terminate the free
> scanner rather than continuing to scan memory needlessly.
>
> If the per-zone watermark is insufficient for a free page of
> order <= cc->order, then terminate the scanner since future splits will
> also likely fail.
>
> This prevents the compaction freeing scanner from scanning all memory on
> very large zones (very noticeable for zones > 128GB, for instance) when
> all splits will likely fail.
>
> Signed-off-by: David Rientjes <rientjes@google.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

But some notes below.

> ---
>  mm/compaction.c | 49 +++++++++++++++++++++++++++++--------------------
>  1 file changed, 29 insertions(+), 20 deletions(-)
>
> diff --git a/mm/compaction.c b/mm/compaction.c
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -494,24 +494,22 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
>
>  		/* Found a free page, will break it into order-0 pages */
>  		order = page_order(page);
> -		isolated = __isolate_free_page(page, page_order(page));
> +		isolated = __isolate_free_page(page, order);
> +		if (!isolated)
> +			break;

This seems to fix as a side-effect a bug in Joonsoo's mmotm patch 
mm-compaction-split-freepages-without-holding-the-zone-lock.patch, that 
Minchan found: http://marc.info/?l=linux-mm&m=146607176528495&w=2

So it should be noted somewhere so they are merged together. Or Joonsoo 
posts an isolated fix and this patch has to rebase.

>  		set_page_private(page, order);
>  		total_isolated += isolated;
>  		list_add_tail(&page->lru, freelist);
>
> -		/* If a page was split, advance to the end of it */
> -		if (isolated) {
> -			cc->nr_freepages += isolated;
> -			if (!strict &&
> -				cc->nr_migratepages <= cc->nr_freepages) {
> -				blockpfn += isolated;
> -				break;
> -			}
> -
> -			blockpfn += isolated - 1;
> -			cursor += isolated - 1;
> -			continue;
> +		/* Advance to the end of split page */
> +		cc->nr_freepages += isolated;
> +		if (!strict && cc->nr_migratepages <= cc->nr_freepages) {
> +			blockpfn += isolated;
> +			break;
>  		}
> +		blockpfn += isolated - 1;
> +		cursor += isolated - 1;
> +		continue;
>
>  isolate_fail:
>  		if (strict)
> @@ -521,6 +519,9 @@ isolate_fail:
>
>  	}
>
> +	if (locked)
> +		spin_unlock_irqrestore(&cc->zone->lock, flags);
> +
>  	/*
>  	 * There is a tiny chance that we have read bogus compound_order(),
>  	 * so be careful to not go outside of the pageblock.
> @@ -542,9 +543,6 @@ isolate_fail:
>  	if (strict && blockpfn < end_pfn)
>  		total_isolated = 0;
>
> -	if (locked)
> -		spin_unlock_irqrestore(&cc->zone->lock, flags);
> -
>  	/* Update the pageblock-skip if the whole pageblock was scanned */
>  	if (blockpfn == end_pfn)
>  		update_pageblock_skip(cc, valid_page, total_isolated, false);
> @@ -622,7 +620,7 @@ isolate_freepages_range(struct compact_control *cc,
>  		 */
>  	}
>
> -	/* split_free_page does not map the pages */
> +	/* __isolate_free_page() does not map the pages */
>  	map_pages(&freelist);
>
>  	if (pfn < end_pfn) {
> @@ -1071,6 +1069,7 @@ static void isolate_freepages(struct compact_control *cc)
>  				block_end_pfn = block_start_pfn,
>  				block_start_pfn -= pageblock_nr_pages,
>  				isolate_start_pfn = block_start_pfn) {
> +		unsigned long isolated;
>
>  		/*
>  		 * This can iterate a massively long zone without finding any
> @@ -1095,8 +1094,12 @@ static void isolate_freepages(struct compact_control *cc)
>  			continue;
>
>  		/* Found a block suitable for isolating free pages from. */
> -		isolate_freepages_block(cc, &isolate_start_pfn,
> -					block_end_pfn, freelist, false);
> +		isolated = isolate_freepages_block(cc, &isolate_start_pfn,
> +						block_end_pfn, freelist, false);
> +		/* If free page split failed, do not continue needlessly */

More accurately, free page isolation failed?

> +		if (!isolated && isolate_start_pfn < block_end_pfn &&
> +		    cc->nr_freepages <= cc->nr_migratepages)
> +			break;
>
>  		/*
>  		 * If we isolated enough freepages, or aborted due to async
> @@ -1124,7 +1127,7 @@ static void isolate_freepages(struct compact_control *cc)
>  		}
>  	}
>
> -	/* split_free_page does not map the pages */
> +	/* __isolate_free_page() does not map the pages */
>  	map_pages(freelist);
>
>  	/*
> @@ -1703,6 +1706,12 @@ enum compact_result try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
>  			continue;
>  		}
>
> +		/* Don't attempt compaction if splitting free page will fail */
> +		if (!zone_watermark_ok(zone, 0,
> +				       low_wmark_pages(zone) + (1 << order),
> +				       0, 0))
> +			continue;
> +

Please don't add this, compact_zone already checks this via 
compaction_suitable() (and the usual 2 << order gap), so this is adding 
yet another watermark check with a different kind of gap.

Thanks.

>  		status = compact_zone_order(zone, order, gfp_mask, mode,
>  				&zone_contended, alloc_flags,
>  				ac_classzone_idx(ac));
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
