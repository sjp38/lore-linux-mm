Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id E4C286B0265
	for <linux-mm@kvack.org>; Wed, 30 Sep 2015 10:02:21 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so196829692wic.1
        for <linux-mm@kvack.org>; Wed, 30 Sep 2015 07:02:21 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y3si939413wju.91.2015.09.30.07.02.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 30 Sep 2015 07:02:20 -0700 (PDT)
Subject: Re: [PATCH 09/10] mm, page_alloc: Reserve pageblocks for high-order
 atomic allocations on demand
References: <1442832762-7247-1-git-send-email-mgorman@techsingularity.net>
 <1442832762-7247-10-git-send-email-mgorman@techsingularity.net>
 <20150929140141.6a52407aa75934a08a3f864d@linux-foundation.org>
 <20150930082725.GL3068@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <560BEB6B.7050004@suse.cz>
Date: Wed, 30 Sep 2015 16:02:19 +0200
MIME-Version: 1.0
In-Reply-To: <20150930082725.GL3068@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 09/30/2015 10:27 AM, Mel Gorman wrote:
> On Tue, Sep 29, 2015 at 02:01:41PM -0700, Andrew Morton wrote:
>>> ...
>>>
>>> +/*
>>> + * Reserve a pageblock for exclusive use of high-order atomic allocations if
>>> + * there are no empty page blocks that contain a page with a suitable order
>>> + */
>>> +static void reserve_highatomic_pageblock(struct page *page, struct zone *zone,
>>> +				unsigned int alloc_order)
>>> +{
>>> +	int mt;
>>> +	unsigned long max_managed, flags;
>>> +
>>> +	/*
>>> +	 * Limit the number reserved to 1 pageblock or roughly 1% of a zone.
>>> +	 * Check is race-prone but harmless.
>>> +	 */
>>> +	max_managed = (zone->managed_pages / 100) + pageblock_nr_pages;
>>> +	if (zone->nr_reserved_highatomic >= max_managed)
>>> +		return;
>>> +
>>> +	/* Yoink! */
>>> +	spin_lock_irqsave(&zone->lock, flags);
>>> +
>>> +	mt = get_pageblock_migratetype(page);
>>> +	if (mt != MIGRATE_HIGHATOMIC &&
>>> +			!is_migrate_isolate(mt) && !is_migrate_cma(mt)) {
>>
>> Do the above checks really need to be inside zone->lock?  I don't think
>> get_pageblock_migratetype() needs zone->lock?  (Actually I suspect it
>> does, but we don't...)
>>
>
> The get_pageblock_migratetype does not require zone->lock but it's race-prone
> without it and there have been cases (CMA, isolation) that cared. In this
> case, without the lock two parallel allocations may try to reserve the same
> block so we'd have to recheck the type under the lock to avoid corrupting
> nr_reserved_highatomic. As the move between free lists absolutely requires
> the zone->lock, it's best to just do the full operation under the lock.
>
>>> +		zone->nr_reserved_highatomic += pageblock_nr_pages;
>>
>> And I don't think it would hurt to recheck
>> nr_reserved_highatomic>=max_managed after taking zone->lock, to plug
>> that race.  We've had VM we-dont-care races in the past which ended up
>> causing problems in rare circumstances...
>>
>
> That makes sense, patch is below.
>
>>> +		set_pageblock_migratetype(page, MIGRATE_HIGHATOMIC);
>>> +		move_freepages_block(zone, page, MIGRATE_HIGHATOMIC);
>>> +	}
>>> +	spin_unlock_irqrestore(&zone->lock, flags);
>>> +}
>>> +
>>> +/*
>>> + * Used when an allocation is about to fail under memory pressure. This
>>> + * potentially hurts the reliability of high-order allocations when under
>>> + * intense memory pressure but failed atomic allocations should be easier
>>> + * to recover from than an OOM.
>>> + */
>>> +static void unreserve_highatomic_pageblock(const struct alloc_context *ac)
>>> +{
>>> +	struct zonelist *zonelist = ac->zonelist;
>>> +	unsigned long flags;
>>> +	struct zoneref *z;
>>> +	struct zone *zone;
>>> +	struct page *page;
>>> +	int order;
>>> +
>>> +	for_each_zone_zonelist_nodemask(zone, z, zonelist, ac->high_zoneidx,
>>> +								ac->nodemask) {
>>> +		/* Preserve at least one pageblock */
>>> +		if (zone->nr_reserved_highatomic <= pageblock_nr_pages)
>>> +			continue;
>>> +
>>> +		spin_lock_irqsave(&zone->lock, flags);
>>> +		for (order = 0; order < MAX_ORDER; order++) {
>>> +			struct free_area *area = &(zone->free_area[order]);
>>> +
>>> +			if (list_empty(&area->free_list[MIGRATE_HIGHATOMIC]))
>>> +				continue;
>>> +
>>> +			page = list_entry(area->free_list[MIGRATE_HIGHATOMIC].next,
>>> +						struct page, lru);
>>> +
>>> +			zone->nr_reserved_highatomic -= pageblock_nr_pages;
>>
>> So if the race happened here, zone->nr_reserved_highatomic underflows?
>>
>
> It shouldn't. If there are entries on the MIGRATE_HIGHATOMIC list then
> it should be accounted for in nr_reserved_highatomic. However, I see your
> point as a spill from per-cpu lists has caused us problems in the past.
>
> ---8<---
> From: Mel Gorman <mgorman@techsingularity.net>
> Subject: [PATCH] mm, page_alloc: Reserve pageblocks for high-order atomic
>   allocations on demand -fix
>
> nr_reserved_highatomic is checked outside the zone lock so there is a race
> whereby the reserve is larger than the limit allows. This patch rechecks
> the count under the zone lock.
>
> During unreserving, there is a possibility we could underflow if there
> ever was a race between per-cpu drains, reserve and unreserving. This
> patch adds a comment about the potential race and protects against it.
>
> These are two fixes to the mmotm patch
> mm-page_alloc-reserve-pageblocks-for-high-order-atomic-allocations-on-demand.patch .
> They are not separate patches and they should all be folded together.
>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Ack.

> ---
>   mm/page_alloc.c | 17 +++++++++++++++--
>   1 file changed, 15 insertions(+), 2 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 811d6fc4ad5d..b1892dc51b55 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1633,9 +1633,13 @@ static void reserve_highatomic_pageblock(struct page *page, struct zone *zone,
>   	if (zone->nr_reserved_highatomic >= max_managed)
>   		return;
>
> -	/* Yoink! */
>   	spin_lock_irqsave(&zone->lock, flags);
>
> +	/* Recheck the nr_reserved_highatomic limit under the lock */
> +	if (zone->nr_reserved_highatomic >= max_managed)
> +		goto out_unlock;
> +
> +	/* Yoink! */
>   	mt = get_pageblock_migratetype(page);
>   	if (mt != MIGRATE_HIGHATOMIC &&
>   			!is_migrate_isolate(mt) && !is_migrate_cma(mt)) {
> @@ -1643,6 +1647,8 @@ static void reserve_highatomic_pageblock(struct page *page, struct zone *zone,
>   		set_pageblock_migratetype(page, MIGRATE_HIGHATOMIC);
>   		move_freepages_block(zone, page, MIGRATE_HIGHATOMIC);
>   	}
> +
> +out_unlock:
>   	spin_unlock_irqrestore(&zone->lock, flags);
>   }
>
> @@ -1677,7 +1683,14 @@ static void unreserve_highatomic_pageblock(const struct alloc_context *ac)
>   			page = list_entry(area->free_list[MIGRATE_HIGHATOMIC].next,
>   						struct page, lru);
>
> -			zone->nr_reserved_highatomic -= pageblock_nr_pages;
> +			/*
> +			 * It should never happen but changes to locking could
> +			 * inadvertently allow a per-cpu drain to add pages
> +			 * to MIGRATE_HIGHATOMIC while unreserving so be safe
> +			 * and watch for underflows.
> +			 */
> +			zone->nr_reserved_highatomic -= min(pageblock_nr_pages,
> +				zone->nr_reserved_highatomic);
>
>   			/*
>   			 * Convert to ac->migratetype and avoid the normal
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
