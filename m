Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 388FD6B0253
	for <linux-mm@kvack.org>; Fri, 28 Aug 2015 08:10:56 -0400 (EDT)
Received: by wicne3 with SMTP id ne3so18010018wic.0
        for <linux-mm@kvack.org>; Fri, 28 Aug 2015 05:10:55 -0700 (PDT)
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com. [209.85.212.174])
        by mx.google.com with ESMTPS id p12si4952846wie.55.2015.08.28.05.10.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Aug 2015 05:10:54 -0700 (PDT)
Received: by wibcx1 with SMTP id cx1so12494609wib.1
        for <linux-mm@kvack.org>; Fri, 28 Aug 2015 05:10:53 -0700 (PDT)
Date: Fri, 28 Aug 2015 14:10:51 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 12/12] mm, page_alloc: Only enforce watermarks for
 order-0 allocations
Message-ID: <20150828121051.GC5301@dhcp22.suse.cz>
References: <1440418191-10894-1-git-send-email-mgorman@techsingularity.net>
 <20150824123015.GJ12432@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150824123015.GJ12432@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon 24-08-15 13:30:15, Mel Gorman wrote:
> The primary purpose of watermarks is to ensure that reclaim can always
> make forward progress in PF_MEMALLOC context (kswapd and direct reclaim).
> These assume that order-0 allocations are all that is necessary for
> forward progress.
> 
> High-order watermarks serve a different purpose. Kswapd had no high-order
> awareness before they were introduced (https://lkml.org/lkml/2004/9/5/9).

lkml.org sucks. Could you plase replace it by something else e.g.
https://lkml.kernel.org/r/413AA7B2.4000907@yahoo.com.au?

> This was particularly important when there were high-order atomic requests.
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
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Michal Hocko <mhocko@suse.com>

[...]
> @@ -2289,7 +2291,7 @@ static bool __zone_watermark_ok(struct zone *z, unsigned int order,
>  {
>  	long min = mark;
>  	int o;
> -	long free_cma = 0;
> +	const bool atomic = (alloc_flags & ALLOC_HARDER);

I just find the naming a bit confusing. ALLOC_HARDER != __GFP_ATOMIC. RT tasks
might get access to this reserve as well.

[...]
> +	/* Check at least one high-order page is free */
> +	for (o = order; o < MAX_ORDER; o++) {
> +		struct free_area *area = &z->free_area[o];
> +		int mt;
> +
> +		if (atomic && area->nr_free)
> +			return true;

Didn't you want
		if (atomic) {
			if (area->nr_free)
				return true;
			continue;
		}

>  
> -		if (free_pages <= min)
> -			return false;
> +		for (mt = 0; mt < MIGRATE_PCPTYPES; mt++) {
> +			if (!list_empty(&area->free_list[mt]))
> +				return true;
> +		}
>  	}
> -	return true;
> +	return false;
>  }
>  
>  bool zone_watermark_ok(struct zone *z, unsigned int order, unsigned long mark,
> -- 
> 2.4.6

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
