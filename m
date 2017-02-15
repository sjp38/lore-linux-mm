Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id A4F5D44059E
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 05:47:28 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id x4so14413062wme.3
        for <linux-mm@kvack.org>; Wed, 15 Feb 2017 02:47:28 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e68si7238913wmd.118.2017.02.15.02.47.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 15 Feb 2017 02:47:27 -0800 (PST)
Subject: Re: [PATCH v2 04/10] mm, page_alloc: count movable pages when
 stealing from pageblock
References: <20170210172343.30283-1-vbabka@suse.cz>
 <20170210172343.30283-5-vbabka@suse.cz> <58A2D6F9.6030400@huawei.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <810cd21a-070b-c6ed-68f7-1b065b270568@suse.cz>
Date: Wed, 15 Feb 2017 11:47:21 +0100
MIME-Version: 1.0
In-Reply-To: <58A2D6F9.6030400@huawei.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, kernel-team@fb.com

On 02/14/2017 11:07 AM, Xishi Qiu wrote:
> On 2017/2/11 1:23, Vlastimil Babka wrote:
> 
>> When stealing pages from pageblock of a different migratetype, we count how
>> many free pages were stolen, and change the pageblock's migratetype if more
>> than half of the pageblock was free. This might be too conservative, as there
>> might be other pages that are not free, but were allocated with the same
>> migratetype as our allocation requested.
>>
>> While we cannot determine the migratetype of allocated pages precisely (at
>> least without the page_owner functionality enabled), we can count pages that
>> compaction would try to isolate for migration - those are either on LRU or
>> __PageMovable(). The rest can be assumed to be MIGRATE_RECLAIMABLE or
>> MIGRATE_UNMOVABLE, which we cannot easily distinguish. This counting can be
>> done as part of free page stealing with little additional overhead.
>>
>> The page stealing code is changed so that it considers free pages plus pages
>> of the "good" migratetype for the decision whether to change pageblock's
>> migratetype.
>>
>> The result should be more accurate migratetype of pageblocks wrt the actual
>> pages in the pageblocks, when stealing from semi-occupied pageblocks. This
>> should help the efficiency of page grouping by mobility.
>>
>> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> 
> Hi Vlastimil,
> 
> How about these two changes?
> 
> 1. If we steal some free pages, we will add these page at the head of start_migratetype
> list, it will cause more fixed, because these pages will be allocated more easily.

What do you mean by "more fixed" here?

> So how about use list_move_tail instead of list_move?

Hmm, not sure if it can make any difference. We steal because the lists
are currently empty (at least for the order we want), so it shouldn't
matter if we add to head or tail.

> __rmqueue_fallback
> 	steal_suitable_fallback
> 		move_freepages_block
> 			move_freepages
> 				list_move
> 
> 2. When doing expand() - list_add(), usually the list is empty, but in the
> following case, the list is not empty, because we did move_freepages_block()
> before.
> 
> __rmqueue_fallback
> 	steal_suitable_fallback
> 		move_freepages_block  // move to the list of start_migratetype
> 	expand  // split the largest order
> 		list_add  // add to the list of start_migratetype
> 
> So how about use list_add_tail instead of list_add? Then we can merge the large
> block again as soon as the page freed.

Same here. The lists are not empty, but contain probably just the pages
from our stolen pageblock. It shouldn't matter how we order them within
the same block.

So maybe it could make some difference for higher-order allocations, but
it's unclear to me. Making e.g. expand() more complex with a flag to
tell it the head vs tail add could mean extra overhead in allocator fast
path that would offset any gains.

> Thanks,
> Xishi Qiu
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
