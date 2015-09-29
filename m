Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f169.google.com (mail-qk0-f169.google.com [209.85.220.169])
	by kanga.kvack.org (Postfix) with ESMTP id 69ACD6B0038
	for <linux-mm@kvack.org>; Tue, 29 Sep 2015 17:01:44 -0400 (EDT)
Received: by qkcf65 with SMTP id f65so9131831qkc.3
        for <linux-mm@kvack.org>; Tue, 29 Sep 2015 14:01:44 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b66si12111409qkb.102.2015.09.29.14.01.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Sep 2015 14:01:43 -0700 (PDT)
Date: Tue, 29 Sep 2015 14:01:41 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 09/10] mm, page_alloc: Reserve pageblocks for high-order
 atomic allocations on demand
Message-Id: <20150929140141.6a52407aa75934a08a3f864d@linux-foundation.org>
In-Reply-To: <1442832762-7247-10-git-send-email-mgorman@techsingularity.net>
References: <1442832762-7247-1-git-send-email-mgorman@techsingularity.net>
	<1442832762-7247-10-git-send-email-mgorman@techsingularity.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, 21 Sep 2015 11:52:41 +0100 Mel Gorman <mgorman@techsingularity.net> wrote:

> High-order watermark checking exists for two reasons --  kswapd high-order
> awareness and protection for high-order atomic requests. Historically the
> kernel depended on MIGRATE_RESERVE to preserve min_free_kbytes as high-order
> free pages for as long as possible. This patch introduces MIGRATE_HIGHATOMIC
> that reserves pageblocks for high-order atomic allocations on demand and
> avoids using those blocks for order-0 allocations. This is more flexible
> and reliable than MIGRATE_RESERVE was.
> 
> A MIGRATE_HIGHORDER pageblock is created when an atomic high-order allocation
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
> Overall, this is a small reduction but the reserves are small relative
> to the number of allocation requests. In early versions of the patch,
> the failure rate reduced by a much larger amount but that required much
> larger reserves and perversely made atomic allocations seem more reliable
> than regular allocations.
> 
> ...
>
> +/*
> + * Reserve a pageblock for exclusive use of high-order atomic allocations if
> + * there are no empty page blocks that contain a page with a suitable order
> + */
> +static void reserve_highatomic_pageblock(struct page *page, struct zone *zone,
> +				unsigned int alloc_order)
> +{
> +	int mt;
> +	unsigned long max_managed, flags;
> +
> +	/*
> +	 * Limit the number reserved to 1 pageblock or roughly 1% of a zone.
> +	 * Check is race-prone but harmless.
> +	 */
> +	max_managed = (zone->managed_pages / 100) + pageblock_nr_pages;
> +	if (zone->nr_reserved_highatomic >= max_managed)
> +		return;
> +
> +	/* Yoink! */
> +	spin_lock_irqsave(&zone->lock, flags);
> +
> +	mt = get_pageblock_migratetype(page);
> +	if (mt != MIGRATE_HIGHATOMIC &&
> +			!is_migrate_isolate(mt) && !is_migrate_cma(mt)) {

Do the above checks really need to be inside zone->lock?  I don't think
get_pageblock_migratetype() needs zone->lock?  (Actually I suspect it
does, but we don't...)

> +		zone->nr_reserved_highatomic += pageblock_nr_pages;

And I don't think it would hurt to recheck
nr_reserved_highatomic>=max_managed after taking zone->lock, to plug
that race.  We've had VM we-dont-care races in the past which ended up
causing problems in rare circumstances...

> +		set_pageblock_migratetype(page, MIGRATE_HIGHATOMIC);
> +		move_freepages_block(zone, page, MIGRATE_HIGHATOMIC);
> +	}
> +	spin_unlock_irqrestore(&zone->lock, flags);
> +}
> +
> +/*
> + * Used when an allocation is about to fail under memory pressure. This
> + * potentially hurts the reliability of high-order allocations when under
> + * intense memory pressure but failed atomic allocations should be easier
> + * to recover from than an OOM.
> + */
> +static void unreserve_highatomic_pageblock(const struct alloc_context *ac)
> +{
> +	struct zonelist *zonelist = ac->zonelist;
> +	unsigned long flags;
> +	struct zoneref *z;
> +	struct zone *zone;
> +	struct page *page;
> +	int order;
> +
> +	for_each_zone_zonelist_nodemask(zone, z, zonelist, ac->high_zoneidx,
> +								ac->nodemask) {
> +		/* Preserve at least one pageblock */
> +		if (zone->nr_reserved_highatomic <= pageblock_nr_pages)
> +			continue;
> +
> +		spin_lock_irqsave(&zone->lock, flags);
> +		for (order = 0; order < MAX_ORDER; order++) {
> +			struct free_area *area = &(zone->free_area[order]);
> +
> +			if (list_empty(&area->free_list[MIGRATE_HIGHATOMIC]))
> +				continue;
> +
> +			page = list_entry(area->free_list[MIGRATE_HIGHATOMIC].next,
> +						struct page, lru);
> +
> +			zone->nr_reserved_highatomic -= pageblock_nr_pages;

So if the race happened here, zone->nr_reserved_highatomic underflows?

> +			/*
> +			 * Convert to ac->migratetype and avoid the normal
> +			 * pageblock stealing heuristics. Minimally, the caller
> +			 * is doing the work and needs the pages. More
> +			 * importantly, if the block was always converted to
> +			 * MIGRATE_UNMOVABLE or another type then the number
> +			 * of pageblocks that cannot be completely freed
> +			 * may increase.
> +			 */
> +			set_pageblock_migratetype(page, ac->migratetype);
> +			move_freepages_block(zone, page, ac->migratetype);
> +			spin_unlock_irqrestore(&zone->lock, flags);
> +			return;
> +		}
> +		spin_unlock_irqrestore(&zone->lock, flags);
> +	}
> +}
>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
