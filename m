Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id EEC1A44060D
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 11:21:23 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id 67so9083644wrb.5
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 08:21:23 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i124si2243087wmi.54.2017.02.17.08.21.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 17 Feb 2017 08:21:22 -0800 (PST)
Subject: Re: [PATCH v2 04/10] mm, page_alloc: count movable pages when
 stealing from pageblock
References: <20170210172343.30283-1-vbabka@suse.cz>
 <20170210172343.30283-5-vbabka@suse.cz> <58A2D6F9.6030400@huawei.com>
 <810cd21a-070b-c6ed-68f7-1b065b270568@suse.cz> <58A441F8.9060909@huawei.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <d1427480-12ee-d848-5ac4-f76a5090e75b@suse.cz>
Date: Fri, 17 Feb 2017 17:21:19 +0100
MIME-Version: 1.0
In-Reply-To: <58A441F8.9060909@huawei.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, kernel-team@fb.com

On 02/15/2017 12:56 PM, Xishi Qiu wrote:
> On 2017/2/15 18:47, Vlastimil Babka wrote:
> 
>> On 02/14/2017 11:07 AM, Xishi Qiu wrote:
>>> On 2017/2/11 1:23, Vlastimil Babka wrote:
>>>
>>>> When stealing pages from pageblock of a different migratetype, we count how
>>>> many free pages were stolen, and change the pageblock's migratetype if more
>>>> than half of the pageblock was free. This might be too conservative, as there
>>>> might be other pages that are not free, but were allocated with the same
>>>> migratetype as our allocation requested.
>>>>
>>>> While we cannot determine the migratetype of allocated pages precisely (at
>>>> least without the page_owner functionality enabled), we can count pages that
>>>> compaction would try to isolate for migration - those are either on LRU or
>>>> __PageMovable(). The rest can be assumed to be MIGRATE_RECLAIMABLE or
>>>> MIGRATE_UNMOVABLE, which we cannot easily distinguish. This counting can be
>>>> done as part of free page stealing with little additional overhead.
>>>>
>>>> The page stealing code is changed so that it considers free pages plus pages
>>>> of the "good" migratetype for the decision whether to change pageblock's
>>>> migratetype.
>>>>
>>>> The result should be more accurate migratetype of pageblocks wrt the actual
>>>> pages in the pageblocks, when stealing from semi-occupied pageblocks. This
>>>> should help the efficiency of page grouping by mobility.
>>>>
>>>> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
>>>
>>> Hi Vlastimil,
>>>
>>> How about these two changes?
>>>
>>> 1. If we steal some free pages, we will add these page at the head of start_migratetype
>>> list, it will cause more fixed, because these pages will be allocated more easily.
>> 
>> What do you mean by "more fixed" here?
>> 
>>> So how about use list_move_tail instead of list_move?
>> 
>> Hmm, not sure if it can make any difference. We steal because the lists
>> are currently empty (at least for the order we want), so it shouldn't
>> matter if we add to head or tail.
>> 
> 
> Hi Vlastimil,
> 
> Please see the following case, I am not sure if it is right.
> 
> MIGRATE_MOVABLE
> order:    0 1 2 3 4 5 6 7 8 9 10
> free num: 1 1 1 1 1 1 1 1 1 1 0  // one page(e.g. page A) was allocated before
>
> MIGRATE_UNMOVABLE
> order:    0 1 2 3 4 5 6 7 8 9 10
> free num: x x x x 0 0 0 0 0 0 0 // we want order=4, so steal from MIGRATE_MOVABLE
> 
> We alloc order=4 in MIGRATE_UNMOVABLE, then it will fallback to steal pages from
> MIGRATE_MOVABLE, and we will move free pages form MIGRATE_MOVABLE list to 
> MIGRATE_UNMOVABLE list.
> 
> List of order 4-9 in MIGRATE_UNMOVABLE is empty, so add head or tail is the same.
> But order 0-3 is not empty, so if we add to the head, we will allocate pages which
> stolen from MIGRATE_MOVABLE first later. So we will have less chance to make a large
> block(order=10) when the one page(page A) free again.

I see. But do we know that page A, and the order-4 page we just allocated, are
both going to be freed soon? It's not a clear win to me, so maybe you can try
implementing it and see if it makes any difference?

> Also we will split order=9 which from MIGRATE_MOVABLE to alloc order=4 in expand(),

Yes, for pageblock order == 9.

> so if we add to the head, we will allocate pages which split from order=9 first later.
> So we will have less chance to make a large block(order=9) when the order=4 page
> free again.

Again that assumes our order-4 allocation is temporary. Is there a significant
chance of this?

>>> __rmqueue_fallback
>>> 	steal_suitable_fallback
>>> 		move_freepages_block
>>> 			move_freepages
>>> 				list_move
>>>
>>> 2. When doing expand() - list_add(), usually the list is empty, but in the
>>> following case, the list is not empty, because we did move_freepages_block()
>>> before.
>>>
>>> __rmqueue_fallback
>>> 	steal_suitable_fallback
>>> 		move_freepages_block  // move to the list of start_migratetype
>>> 	expand  // split the largest order
>>> 		list_add  // add to the list of start_migratetype
>>>
>>> So how about use list_add_tail instead of list_add? Then we can merge the large
>>> block again as soon as the page freed.
>> 
>> Same here. The lists are not empty, but contain probably just the pages
>> from our stolen pageblock. It shouldn't matter how we order them within
>> the same block.
>> 
>> So maybe it could make some difference for higher-order allocations, but
>> it's unclear to me. Making e.g. expand() more complex with a flag to
>> tell it the head vs tail add could mean extra overhead in allocator fast
>> path that would offset any gains.
>> 
>>> Thanks,
>>> Xishi Qiu
>>>
>> 
>> 
>> .
>> 
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
