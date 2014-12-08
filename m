Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 181636B006C
	for <linux-mm@kvack.org>; Mon,  8 Dec 2014 05:27:30 -0500 (EST)
Received: by mail-wg0-f44.google.com with SMTP id b13so5810626wgh.17
        for <linux-mm@kvack.org>; Mon, 08 Dec 2014 02:27:29 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id uw8si51874014wjc.112.2014.12.08.02.27.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Dec 2014 02:27:29 -0800 (PST)
Message-ID: <54857D0F.3080601@suse.cz>
Date: Mon, 08 Dec 2014 11:27:27 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 2/3] mm: more aggressive page stealing for UNMOVABLE
 allocations
References: <1417713178-10256-1-git-send-email-vbabka@suse.cz> <1417713178-10256-3-git-send-email-vbabka@suse.cz> <20141208071140.GB3904@js1304-P5Q-DELUXE>
In-Reply-To: <20141208071140.GB3904@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>

On 12/08/2014 08:11 AM, Joonsoo Kim wrote:
> On Thu, Dec 04, 2014 at 06:12:57PM +0100, Vlastimil Babka wrote:
>> When allocation falls back to stealing free pages of another migratetype,
>> it can decide to steal extra pages, or even the whole pageblock in order to
>> reduce fragmentation, which could happen if further allocation fallbacks
>> pick a different pageblock. In try_to_steal_freepages(), one of the situations
>> where extra pages are stolen happens when we are trying to allocate a
>> MIGRATE_RECLAIMABLE page.
>>
>> However, MIGRATE_UNMOVABLE allocations are not treated the same way, although
>> spreading such allocation over multiple fallback pageblocks is arguably even
>> worse than it is for RECLAIMABLE allocations. To minimize fragmentation, we
>> should minimize the number of such fallbacks, and thus steal as much as is
>> possible from each fallback pageblock.
>
> I'm not sure that this change is good. If we steal order 0 pages,
> this may be good. But, sometimes, we try to steal high order page
> and, in this case, there would be many order 0 freepages and blindly
> stealing freepages in that pageblock make the system more fragmented.

I don't understand. If we try to steal high order page (current_order >= 
pageblock_order / 2), then nothing changes, the condition for extra 
stealing is the same.

> MIGRATE_RECLAIMABLE is different case than MIGRATE_UNMOVABLE, because
> it can be reclaimed so excessive migratetype movement doesn't result
> in permanent fragmentation.

There's two kinds of "fragmentation" IMHO. First, inside a pageblock, 
unmovable allocations can prevent merging of lower orders. This can get 
worse if we steal multiple pages from a single pageblock, but the 
pageblock itself is not marked as unmovable.

Second kind of fragmentation is when unmovable allocations spread over 
multiple pageblocks. Lower order allocations within each such pageblock 
might be still possible, but less pageblocks are able to compact to have 
whole pageblock free.

I think the second kind is worse, so when do have to pollute a movable 
pageblock with unmovable allocation, we better take as much as possible, 
so we prevent polluting other pageblocks.


> What I'd like to do to prevent fragmentation is
> 1) check whether we can steal all or almost freepages and change
> migratetype of pageblock.
> 2) If above condition isn't met, deny allocation and invoke compaction.

Could work to some extend, but we need also to prevent excessive compaction.

We could also introduce a new pageblock migratetype, something like 
MIGRATE_MIXED. The idea is that once pageblock isn't used purely by 
MOVABLE allocations, it's marked as MIXED, until it either becomes 
marked UNMOVABLE or RECLAIMABLE by the existing mechanisms, or is fully 
freed. In more detail:

- MIXED is preferred for fallback before any other migratetypes
- if RECLAIMABLE/UNMOVABLE page allocation is stealing from MOVABLE 
pageblock and cannot mark pageblock as RECLAIMABLE/UNMOVABLE (by current 
rules), it marks it as MIXED instead.
- if MOVABLE allocation is stealing from UNMOVABLE/RECLAIMABLE 
pageblocks, it will only mark it as MOVABLE if it was fully free. 
Otherwise, if current rules would result in marking it as MOVABLE (i.e. 
most of it was stolen, but not all) it will mark it as MIXED instead.

This could in theory leave more MOVABLE pageblocks unspoiled by 
UNMOVABLE allocations.

> Maybe knob to control behaviour would be needed.
> How about it?

Adding new knobs is not a good solution.

> Thanks.
>
>>
>> This patch thus adds a check for MIGRATE_UNMOVABLE to the decision to steal
>> extra free pages. When evaluating with stress-highalloc from mmtests, this has
>> reduced the number of MIGRATE_UNMOVABLE fallbacks to roughly 1/6. The number
>> of these fallbacks stealing from MIGRATE_MOVABLE block is reduced to 1/3.
>>
>> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
>> ---
>>   mm/page_alloc.c | 1 +
>>   1 file changed, 1 insertion(+)
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 548b072..a14249c 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -1098,6 +1098,7 @@ static int try_to_steal_freepages(struct zone *zone, struct page *page,
>>
>>   	if (current_order >= pageblock_order / 2 ||
>>   	    start_type == MIGRATE_RECLAIMABLE ||
>> +	    start_type == MIGRATE_UNMOVABLE ||
>>   	    page_group_by_mobility_disabled) {
>>   		int pages;
>>
>> --
>> 2.1.2
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
