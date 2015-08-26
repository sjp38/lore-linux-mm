Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 821E16B0254
	for <linux-mm@kvack.org>; Wed, 26 Aug 2015 10:53:56 -0400 (EDT)
Received: by widdq5 with SMTP id dq5so17890395wid.0
        for <linux-mm@kvack.org>; Wed, 26 Aug 2015 07:53:56 -0700 (PDT)
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com. [209.85.212.172])
        by mx.google.com with ESMTPS id db8si5610332wjc.63.2015.08.26.07.53.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Aug 2015 07:53:55 -0700 (PDT)
Received: by widdq5 with SMTP id dq5so49633314wid.1
        for <linux-mm@kvack.org>; Wed, 26 Aug 2015 07:53:54 -0700 (PDT)
Date: Wed, 26 Aug 2015 16:53:52 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 11/12] mm, page_alloc: Reserve pageblocks for high-order
 atomic allocations on demand
Message-ID: <20150826145352.GJ25196@dhcp22.suse.cz>
References: <1440418191-10894-1-git-send-email-mgorman@techsingularity.net>
 <20150824122957.GI12432@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150824122957.GI12432@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon 24-08-15 13:29:57, Mel Gorman wrote:
> High-order watermark checking exists for two reasons --  kswapd high-order
> awareness and protection for high-order atomic requests. Historically the
> kernel depended on MIGRATE_RESERVE to preserve min_free_kbytes as high-order
> free pages for as long as possible. This patch introduces MIGRATE_HIGHATOMIC
> that reserves pageblocks for high-order atomic allocations on demand and
> avoids using those blocks for order-0 allocations. This is more flexible
> and reliable than MIGRATE_RESERVE was.
> 
> A MIGRATE_HIGHORDER pageblock is created when a high-order allocation
> request steals a pageblock but limits the total number to 1% of the zone.
> Callers that speculatively abuse atomic allocations for long-lived
> high-order allocations to access the reserve will quickly fail. Note that
> SLUB is currently not such an abuser as it reclaims at least once.  It is
> possible that the pageblock stolen has few suitable high-order pages and
> will need to steal again in the near future but there would need to be
> strong justification to search all pageblocks for an ideal candidate.
> 
> The pageblocks are unreserved if an allocation fails after a direct
> reclaim attempt.
> 
> The watermark checks account for the reserved pageblocks when the allocation
> request is not a high-order atomic allocation.
> 
> The reserved pageblocks can not be used for order-0 allocations. This may
> allow temporary wastage until a failed reclaim reassigns the pageblock. This
> is deliberate as the intent of the reservation is to satisfy a limited
> number of atomic high-order short-lived requests if the system requires them.
> 
> The stutter benchmark was used to evaluate this but while it was running
> there was a systemtap script that randomly allocated between 1 high-order
> page and 12.5% of memory's worth of order-3 pages using GFP_ATOMIC. This
> is much larger than the potential reserve and it does not attempt to be
> realistic.  It is intended to stress random high-order allocations from
> an unknown source, show that there is a reduction in failures without
> introducing an anomaly where atomic allocations are more reliable than
> regular allocations.  The amount of memory reserved varied throughout the
> workload as reserves were created and reclaimed under memory pressure. The
> allocation failures once the workload warmed up were as follows;
> 
> 4.2-rc5-vanilla		70%
> 4.2-rc5-atomic-reserve	56%
> 
> The failure rate was also measured while building multiple kernels. The
> failure rate was 14% but is 6% with this patch applied.
> 
> Overall, this is a small reduction but the reserves are small relative to the
> number of allocation requests. In early versions of the patch, the failure
> rate reduced by a much larger amount but that required much larger reserves
> and perversely made atomic allocations seem more reliable than regular allocations.

Have you considered a counter for vmstat/zoneinfo so that we have an overview
about the memory consumed for this reserve?

> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Michal Hocko <mhocko@suse.com>

[...]
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index d5ce050ebe4f..2415f882b89c 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
[...]
> @@ -1645,10 +1725,16 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
>   * Call me with the zone->lock already held.
>   */
>  static struct page *__rmqueue(struct zone *zone, unsigned int order,
> -						int migratetype)
> +				int migratetype, gfp_t gfp_flags)
>  {
>  	struct page *page;
>  
> +	if (unlikely(order && (gfp_flags & __GFP_ATOMIC))) {
> +		page = __rmqueue_smallest(zone, order, MIGRATE_HIGHATOMIC);
> +		if (page)
> +			goto out;

I guess you want to change migratetype to MIGRATE_HIGHATOMIC in the
successful case so the tracepoint reports this properly.

> +	}
> +
>  	page = __rmqueue_smallest(zone, order, migratetype);
>  	if (unlikely(!page)) {
>  		if (migratetype == MIGRATE_MOVABLE)
> @@ -1658,6 +1744,7 @@ static struct page *__rmqueue(struct zone *zone, unsigned int order,
>  			page = __rmqueue_fallback(zone, order, migratetype);
>  	}
>  
> +out:
>  	trace_mm_page_alloc_zone_locked(page, order, migratetype);
>  	return page;

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
