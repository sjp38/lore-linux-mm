Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 30BBE280259
	for <linux-mm@kvack.org>; Thu, 16 Nov 2017 02:55:19 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id 11so14199527wrb.10
        for <linux-mm@kvack.org>; Wed, 15 Nov 2017 23:55:19 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b44si588046eda.69.2017.11.15.23.55.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 15 Nov 2017 23:55:17 -0800 (PST)
Subject: Re: reducing fragmentation of unmovable pages
References: <alpine.DEB.2.10.1711061431420.24485@chino.kir.corp.google.com>
 <20171107115356.32gly4je5nh4a4fm@suse.de>
 <alpine.DEB.2.10.1711141635310.139637@chino.kir.corp.google.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <d1610144-8928-83e2-cabd-18cbc6ab26a9@suse.cz>
Date: Thu, 16 Nov 2017 08:55:15 +0100
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1711141635310.139637@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>
Cc: Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm <linux-mm@kvack.org>

CC linux-mm

On 11/15/2017 01:52 AM, David Rientjes wrote:
> On Tue, 7 Nov 2017, Mel Gorman wrote:
> 
>>>  - Do not steal entire MIGRATE_MOVABLE pageblocks during fallback the 
>>>    vast majority of the time.  The page allocator prefers to fallback to
>>>    larger page orders first to prevent the need for subsequent fallback.
>>>    As a result, move_freepages_block() typically converts the fallback
>>>    pageblock, MIGRATE_RECLAIMABLE or MIGRATE_MOVABLE, to 
>>>    MIGRATE_UNMOVABLE increasing fragmentation and making it difficult to
>>>    convert back to MIGRATE_MOVABLE due to long-lived slab allocations.
>>>
>>
>> The thinking behind it was that once a fallback occurs, the change
>> is potentially permanent. Hence, once the pageblock is unusable for
>> hugepage-sized allocations, the damage should be confined there as much
>> as possible.
>>
> 
> Ok, sounds reasonable, thanks.  I'm wondering if we should do two things 
> when falling back to a MIGRATE_UNMOVABLE pageblock:
> 
>  - trigger kcompactd compaction to migrate all movable memory to
>    MIGRATE_MOVABLE, then
> 
>  - unconditionally convert to MIGRATE_UNMOVABLE to use the entire 
>    pageblock.
> 
> Or is there some perceived benefit to not doing the conversion when less 
> than 1/2 of the pageblock is free?  We lack insight to how short-lived or 
> temporary the allocation is, so it may sit there forever in a 
> MIGRATE_MOVABLE pageblock that just puts more stress on compaction and 
> will never allow the full pageblock to become free.
> 
> This could also be done for MIGRATE_RECLAIMABLE pageblocks:
> 
>  - trigger shrink_slab() in the background to free all reclaimable
>    memory possible, then
> 
>  - unconditionally convert to MIGRATE_UNMOVABLE.
> 
> Subsequent fallback to MIGRATE_RECLAIMABLE may occur, but that should 
> still be preferred over falling back to MIGRATE_MOVABLE.
> 
>>>  - Trigger kcompactd in the background to migrate eligible memory only
>>>    from MIGRATE_UNMOVABLE pageblocks when the allocator falls back to
>>>    pageblocks of different migratetype.
>>>
>>
>> That is potentially worthwhile as long as the cost is willing to be
>> paid. I never kept a list of issues that were encountered when
>> attempting to reduce fallbacks but some of the concerns were;
>>
>> 1. During the migration, minor fault stalls due to migration may increase.
>>
>> 2. It's inherently race-prone if kcompactd or any sort of parallel work
>>    does the work given a list of pageblocks that recently were used
>>    as fallback as a further fallback can occur before the migration is
>>    complete. If the work is done synchronously, the cost is too high
>>    and the calling context may not even allow it.
>>
> 
> Yeah, all the work being proposed here in asynchronous.  What exactly is 
> the concern about additional fallbacks being done while 
> compacting/reclaiming?  If it's a burst of unmovable allocations, I still 
> see a benefit to migrating MIGRATE_MOVABLE pages away from 
> MIGRATE_UNMOVABLE pageblocks and converting the entire fallback to 
> MIGRATE_UNMOVABLE in the hope of consolidating future allocations there.  
> I don't have data that would suggest this would improve the situation, 
> however, but I could collect it if that would be interesting.
> 
>> 3. There is no guarantee that the pages can be migrated due to memory
>>    pressure.
>>
> 
> Right, I think all of this is considered best effort.
> 
>> 4. You also have to take into account that if the movable pages are
>>    migrated out then a future movable allocation request may attempt to
>>    steal it right back. i.e. by reducing potential fallbacks from unmovable
>>    and reclaimable requests, you increase the changes of a future fallback
>>    of a movable one unless you are willing to reclaim in some instances
>>
> 
> Interesting, I hadn't considered that.  I was working under the assumption 
> that MIGRATE_MOVABLE memory wasn't low, which matches the systems that I 
> am trying to optimize this for (some with ~40% of memory free on the 
> system).  I hadn't thought of MIGRATE_MOVABLE allocations doing the same 
> thing to other migrate types.

I don't think this is a big issue, because the criteria for movable
allocation stealing all pages from pageblock are more strict than
unmovable allocation stealing. Also if we are in the situation that
unmovable allocation has to fallback, we are still above at least the
min watermark, which means there is free memory, which thus has to be of
another migratetype - MOVABLE or RECLAIMABLE. The amount of it will be
higher than the single pageblock we are stealing, and movable allocation
will prefer that before trying to steal back. The low/min watermark
would be hit first before exhausting that, so reclaim would then create
more. But yeah this might not be so simple if it's a fallback due to
unmovable high-order allocation and most free memory being in unmovable
pageblocks, but fragmented...

>> 5. If you try partitioning the system and never allowing fallbacks, it
>>    hits into weird OOM issues. If you try and limit it, you need
>>    per-miigrate-type counters for each pageblock in the system. The former
>>    turns into a functional failure. The latter costs too much.
>>
> 
> Ah, this came up before when I proposed a patch for tracking the number of 
> movable pages per zone and limiting synchronous compaction when that 
> number was deemed to be too low.  I remember per-migratetype counters 
> being too costly.
> 
>>>  - Trigger shrink_slab() in the background to free reclaimable slab even
>>>    when per-zone watermarks have not been met when falling back to
>>>    pageblocks of different migratetype to hopefully make pages eligible
>>>    from MIGRATE_UNMOVABLE pageblocks for subsequent allocations.
>>>
>>
>> Worth prototyping but people may claim that you are disrupting the
>> system now by reclaiming slab in case a high-order allocation is needed
>> in the future. This is similar to, but not as bad, as lumpy reclaim was.
>>
> 
> Would it be more palatable if this shrink_slab() when falling back to 
> different migratetypes only occurred if zone_watermark_ok() failed for 
> pageblock_order at high_wmark_pages()?
> 
> Are there any other ideas that you or others may have that reduces kmem 
> fragmentation over pageblocks?
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
