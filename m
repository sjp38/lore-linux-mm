Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 85A866B0255
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 04:28:58 -0400 (EDT)
Received: by wicgj17 with SMTP id gj17so7222774wic.1
        for <linux-mm@kvack.org>; Fri, 31 Jul 2015 01:28:58 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id pu2si6719128wjc.109.2015.07.31.01.28.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 31 Jul 2015 01:28:56 -0700 (PDT)
Subject: Re: [PATCH 09/10] mm, page_alloc: Reserve pageblocks for high-order
 atomic allocations on demand
References: <1437379219-9160-1-git-send-email-mgorman@suse.com>
 <1437379219-9160-10-git-send-email-mgorman@suse.com>
 <55B8BA75.9090903@suse.cz> <20150729125334.GC19352@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55BB31C4.3000107@suse.cz>
Date: Fri, 31 Jul 2015 10:28:52 +0200
MIME-Version: 1.0
In-Reply-To: <20150729125334.GC19352@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Mel Gorman <mgorman@suse.com>, Linux-MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Pintu Kumar <pintu.k@samsung.com>, Xishi Qiu <qiuxishi@huawei.com>, Gioh Kim <gioh.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>

On 07/29/2015 02:53 PM, Mel Gorman wrote:
> On Wed, Jul 29, 2015 at 01:35:17PM +0200, Vlastimil Babka wrote:
>> On 07/20/2015 10:00 AM, Mel Gorman wrote:
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
>>
>> This fixed order might bias some zones over others wrt unreserving. Is it OK?
>
> I could not think of a situation where it mattered. It'll always be
> preferring highest zone over lower zones. Allocation requests that can
> use any zone that do not care. Allocation requests that are limited to
> lower zones are protected as long as possible.

Hmm... allocation requests will follow fair zone policy and thus the 
highatomic reservations will be spread fairly among all zones? Unless 
the allocations require lower zones of course.

But for unreservations, normal/high allocations failing under memory 
pressure will lead to unreserving highatomic pageblocks first in the 
higher zones and only then the lower zones, and that was my concern. But 
it's true that failing allocations that require lower zones will lead to 
unreserving the lower zones, so it might be ok in the end.

>
>>
>>> +		/* Preserve at least one pageblock */
>>> +		if (zone->nr_reserved_highatomic <= pageblock_nr_pages)
>>> +			continue;
>>> +
>>> +		spin_lock_irqsave(&zone->lock, flags);
>>> +		for (order = 0; order < MAX_ORDER; order++) {
>>
>> Would it make more sense to look in descending order for a higher chance of
>> unreserving a pageblock that's mostly free? Like the traditional page stealing does?
>>
>
> I don't think it's worth the search cost. Traditional page stealing is
> searching because it's trying to minimise events that cause external
> fragmentation. Here we'd gain very little. We are under some memory
> pressure here, if enough pages are not free then another one will get
> freed shortly. Either way, I doubt the difference is measurable.

Hmm, I guess...

>
>>> +			struct free_area *area = &(zone->free_area[order]);
>>> +
>>> +			if (list_empty(&area->free_list[MIGRATE_HIGHATOMIC]))
>>> +				continue;
>>> +
>>> +			page = list_entry(area->free_list[MIGRATE_HIGHATOMIC].next,
>>> +						struct page, lru);
>>> +
>>> +			zone->nr_reserved_highatomic -= pageblock_nr_pages;
>>> +			set_pageblock_migratetype(page, ac->migratetype);
>>
>> Would it make more sense to assume MIGRATE_UNMOVABLE, as high-order allocations
>> present in the pageblock typically would be, and apply the traditional page
>> stealing heuristics to decide if it should be changed to ac->migratetype (if
>> that differs)?
>>
>
> Superb spot, I had to think about this for a while and initially I was
> thinking your suggestion was a no-brainer and obviously the right thing
> to do.
>
> On the pro side, it preserves the fragmentation logic because it'll force
> the normal page stealing logic to be applied.
>
> On the con side, we may reassign the pageblock twice -- once to
> MIGRATE_UNMOVABLE and once to ac->migratetype. That one does not matter
> but the second con is that we inadvertly increase the number of unmovable
> blocks in some cases.
>
> Lets say we default to MIGRATE_UNMOVABLE, ac->migratetype is MIGRATE_MOVABLE
> and there are enough free pages to satisfy the allocation but not steal
> the whole pageblock. The end result is that we have a new unmovable
> pageblock that may not be necessary. The next unmovable allocation
> potentially is forever. They key observation is that previously the
> pageblock could have been short-lived high-order allocations that could
> be completely free soon if it was assigned MIGRATE_MOVABLE. This may not
> apply when SLUB is using high-order allocations but the point still
> holds.

Yeah, I see the point. The obvious counterexample is a pageblock that we 
design as MOVABLE and yet it contains some long-lived unmovable 
allocation. More unmovable allocations could lead to choosing another 
movable block as a fallback, while if we marked this pageblock as 
unmovable, they could go here and not increase fragmentation.

The problem is, we can't known which one is the case. I've toyed with an 
idea of MIGRATE_MIXED blocks that would be for cases where the 
heuristics decide that e.g. an UNMOVABLE block is empty enough to change 
it to MOVABLE, but still it may contain some unmovable allocations. Such 
pageblocks should be preferred fallbacks for future unmovable 
allocations before truly pristine movable pageblocks.

The scenario here could be another where MIGRATE_MIXED would make sense.

> Grouping pages by mobility really needs to strive to keep the number of
> unmovable blocks as low as possible.

More precisely, the number of blocks with unmovable allocations in them. 
Which is much harder objective.

> If ac->migratetype is
> MIGRATE_UNMOVABLE then we lose nothing. If it's any other type then the
> current code keeps the number of unmovable blocks as low as possible.
>
> On that basis I think the current code is fine but it needs a comment to
> record why it's like this.
>
>>> @@ -2175,15 +2257,23 @@ static bool __zone_watermark_ok(struct zone *z, unsigned int order,
>>>   			unsigned long mark, int classzone_idx, int alloc_flags,
>>>   			long free_pages)
>>>   {
>>> -	/* free_pages may go negative - that's OK */
>>>   	long min = mark;
>>>   	int o;
>>>   	long free_cma = 0;
>>>
>>> +	/* free_pages may go negative - that's OK */
>>>   	free_pages -= (1 << order) - 1;
>>> +
>>>   	if (alloc_flags & ALLOC_HIGH)
>>>   		min -= min / 2;
>>> -	if (alloc_flags & ALLOC_HARDER)
>>> +
>>> +	/*
>>> +	 * If the caller is not atomic then discount the reserves. This will
>>> +	 * over-estimate how the atomic reserve but it avoids a search
>>> +	 */
>>> +	if (likely(!(alloc_flags & ALLOC_HARDER)))
>>> +		free_pages -= z->nr_reserved_highatomic;
>>
>> Hm, so in the case the maximum of 10% reserved blocks is already full, we deny
>> the allocation access to another 10% of the memory and push it to reclaim. This
>> seems rather excessive.
>
> It's necessary. If normal callers can use it then the reserve fills with
> normal pages, the memory gets fragmented and high-order atomic allocations
> fail due to fragmentation. Similarly, the number of MIGRATE_HIGHORDER
> pageblocks cannot be unbound or everything else will be continually pushed
> into reclaim even if there is plenty of memory free.

I understand denying normal allocations access to highatomic reserves 
via watermarks is necessary. But my concern is that for each reserved 
pageblock we effectively deny up to two pageblocks-worth-of-pages to 
normal allocations. One pageblock that is marked as MIGRATE_HIGHATOMIC, 
and once it becomes full, free_pages above are decreased twice - once by 
the pageblock becoming full, and then again by subtracting 
z->nr_reserved_highatomic. This extra gap is still usable by highatomic 
allocations, but they will also potentially mark more pageblocks 
highatomic and further increase the gap. In the worst case we have 10% 
of pageblocks marked highatomic and full, and another 10% that is only 
usable by highatomic allocations (but won't be marked as such), and if 
no more highatomic allocations come then the 10% is wasted.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
