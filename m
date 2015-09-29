Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	by kanga.kvack.org (Postfix) with ESMTP id E76326B0038
	for <linux-mm@kvack.org>; Tue, 29 Sep 2015 17:05:09 -0400 (EDT)
Received: by qgt47 with SMTP id 47so18257878qgt.2
        for <linux-mm@kvack.org>; Tue, 29 Sep 2015 14:05:09 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id s9si10286232qkl.0.2015.09.29.14.05.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Sep 2015 14:05:09 -0700 (PDT)
Date: Tue, 29 Sep 2015 14:05:07 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 10/10] mm, page_alloc: Only enforce watermarks for
 order-0 allocations
Message-Id: <20150929140507.82b5e02f300038e4bb5b2493@linux-foundation.org>
In-Reply-To: <20150921120317.GC3068@techsingularity.net>
References: <1442832762-7247-1-git-send-email-mgorman@techsingularity.net>
	<20150921120317.GC3068@techsingularity.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, 21 Sep 2015 13:03:17 +0100 Mel Gorman <mgorman@techsingularity.net> wrote:

> The primary purpose of watermarks is to ensure that reclaim can always
> make forward progress in PF_MEMALLOC context (kswapd and direct reclaim).
> These assume that order-0 allocations are all that is necessary for
> forward progress.
> 
> High-order watermarks serve a different purpose. Kswapd
> had no high-order awareness before they were introduced
> (https://lkml.kernel.org/r/413AA7B2.4000907@yahoo.com.au).  This was
> particularly important when there were high-order atomic requests.
> The watermarks both gave kswapd awareness and made a reserve for those
> atomic requests.
> 
> There are two important side-effects of this. The most important is that
> a non-atomic high-order request can fail even though free pages are available
> and the order-0 watermarks are ok. The second is that high-order watermark
> checks are expensive as the free list counts up to the requested order must
> be examined.
> 
> With the introduction of MIGRATE_HIGHATOMIC it is no longer necessary to
> have high-order watermarks. Kswapd and compaction still need high-order
> awareness which is handled by checking that at least one suitable high-order
> page is free.
> 
> With the patch applied, there was little difference in the allocation
> failure rates as the atomic reserves are small relative to the number of
> allocation attempts. The expected impact is that there will never be an
> allocation failure report that shows suitable pages on the free lists.
> 
> The one potential side-effect of this is that in a vanilla kernel, the
> watermark checks may have kept a free page for an atomic allocation. Now,
> we are 100% relying on the HighAtomic reserves and an early allocation to
> have allocated them.  If the first high-order atomic allocation is after
> the system is already heavily fragmented then it'll fail.
> 
> ...
>
>  static bool __zone_watermark_ok(struct zone *z, unsigned int order,
>  			unsigned long mark, int classzone_idx, int alloc_flags,
> @@ -2317,7 +2319,7 @@ static bool __zone_watermark_ok(struct zone *z, unsigned int order,
>  {
>  	long min = mark;
>  	int o;
> -	long free_cma = 0;
> +	const bool alloc_harder = (alloc_flags & ALLOC_HARDER);

hmpf.  Setting a bool to 0x10 is a bit grubby.
  
>  	/* free_pages may go negative - that's OK */
>  	free_pages -= (1 << order) - 1;
> @@ -2330,7 +2332,7 @@ static bool __zone_watermark_ok(struct zone *z, unsigned int order,
>  	 * the high-atomic reserves. This will over-estimate the size of the
>  	 * atomic reserve but it avoids a search.
>  	 */
> -	if (likely(!(alloc_flags & ALLOC_HARDER)))
> +	if (likely(!alloc_harder))
>  		free_pages -= z->nr_reserved_highatomic;
>  	else
>  		min -= min / 4;
> @@ -2338,22 +2340,43 @@ static bool __zone_watermark_ok(struct zone *z, unsigned int order,
>  #ifdef CONFIG_CMA
>  	/* If allocation can't use CMA areas don't use free CMA pages */
>  	if (!(alloc_flags & ALLOC_CMA))
> -		free_cma = zone_page_state(z, NR_FREE_CMA_PAGES);
> +		free_pages -= zone_page_state(z, NR_FREE_CMA_PAGES);
>  #endif
>  
> -	if (free_pages - free_cma <= min + z->lowmem_reserve[classzone_idx])
> +	if (free_pages <= min + z->lowmem_reserve[classzone_idx])
>  		return false;
> -	for (o = 0; o < order; o++) {
> -		/* At the next order, this order's pages become unavailable */
> -		free_pages -= z->free_area[o].nr_free << o;
>  
> -		/* Require fewer higher order pages to be free */
> -		min >>= 1;
> +	/* order-0 watermarks are ok */

because?

> +	if (!order)
> +		return true;
> +
> +	/* Check at least one high-order page is free */
> +	for (o = order; o < MAX_ORDER; o++) {
> +		struct free_area *area = &z->free_area[o];
> +		int mt;
> +
> +		if (!area->nr_free)
> +			continue;
> +
> +		if (alloc_harder) {
> +			if (area->nr_free)
> +				return true;
> +			continue;
> +		}
>  
> -		if (free_pages <= min)
> -			return false;
> +		for (mt = 0; mt < MIGRATE_PCPTYPES; mt++) {
> +			if (!list_empty(&area->free_list[mt]))
> +				return true;
> +		}
> +
> +#ifdef CONFIG_CMA
> +		if ((alloc_flags & ALLOC_CMA) &&
> +		    !list_empty(&area->free_list[MIGRATE_CMA])) {
> +			return true;
> +		}
> +#endif
>  	}
> -	return true;
> +	return false;
>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
