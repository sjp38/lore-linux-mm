Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 735C26B0073
	for <linux-mm@kvack.org>; Mon,  8 Dec 2014 05:31:00 -0500 (EST)
Received: by mail-wg0-f54.google.com with SMTP id l2so5839469wgh.27
        for <linux-mm@kvack.org>; Mon, 08 Dec 2014 02:30:59 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id yv4si60821969wjc.120.2014.12.08.02.30.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Dec 2014 02:30:59 -0800 (PST)
Message-ID: <54857DE2.1000802@suse.cz>
Date: Mon, 08 Dec 2014 11:30:58 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 3/3] mm: always steal split buddies in fallback allocations
References: <1417713178-10256-1-git-send-email-vbabka@suse.cz> <1417713178-10256-4-git-send-email-vbabka@suse.cz> <20141208073637.GA4757@js1304-P5Q-DELUXE>
In-Reply-To: <20141208073637.GA4757@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>

On 12/08/2014 08:36 AM, Joonsoo Kim wrote:
> On Thu, Dec 04, 2014 at 06:12:58PM +0100, Vlastimil Babka wrote:
>> When allocation falls back to another migratetype, it will steal a page with
>> highest available order, and (depending on this order and desired migratetype),
>> it might also steal the rest of free pages from the same pageblock.
>>
>> Given the preference of highest available order, it is likely that it will be
>> higher than the desired order, and result in the stolen buddy page being split.
>> The remaining pages after split are currently stolen only when the rest of the
>> free pages are stolen. This can however lead to situations where for MOVABLE
>> allocations we split e.g. order-4 fallback UNMOVABLE page, but steal only
>> order-0 page. Then on the next MOVABLE allocation (which may be batched to
>> fill the pcplists) we split another order-3 or higher page, etc. By stealing
>> all pages that we have split, we can avoid further stealing.
>>
>> This patch therefore adjust the page stealing so that buddy pages created by
>> split are always stolen. This has effect only on MOVABLE allocations, as
>> RECLAIMABLE and UNMOVABLE allocations already always do that in addition to
>> stealing the rest of free pages from the pageblock.
>
> In fact, CMA also has same problem and this patch skips to fix it.
> If movable allocation steals the page on CMA reserved area, remained split
> freepages are always linked to original CMA buddy list. And then, next
> fallback allocation repeately selects most highorder freepage on CMA
> area and split it.

Hm yeah, for CMA it would make more sense to steal page of the lowest 
available order, not highest.

> IMO, It'd be better to re-consider whole fragmentation avoidance logic.
>
> Thanks.
>
>>
>> Note that commit 7118af076f6 ("mm: mmzone: MIGRATE_CMA migration type added")
>> has already performed this change (unintentinally), but was reverted by commit
>> 0cbef29a7821 ("mm: __rmqueue_fallback() should respect pageblock type").
>> Neither included evaluation. My evaluation with stress-highalloc from mmtests
>> shows about 2.5x reduction of page stealing events for MOVABLE allocations,
>> without affecting the page stealing events for other allocation migratetypes.
>>
>> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
>> ---
>>   mm/page_alloc.c | 4 +---
>>   1 file changed, 1 insertion(+), 3 deletions(-)
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index a14249c..82096a6 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -1108,11 +1108,9 @@ static int try_to_steal_freepages(struct zone *zone, struct page *page,
>>   		if (pages >= (1 << (pageblock_order-1)) ||
>>   				page_group_by_mobility_disabled)
>>   			set_pageblock_migratetype(page, start_type);
>> -
>> -		return start_type;
>>   	}
>>
>> -	return fallback_type;
>> +	return start_type;
>>   }
>>
>>   /* Remove an element from the buddy allocator from the fallback list */
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
