Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id AA26B280259
	for <linux-mm@kvack.org>; Thu, 16 Nov 2017 02:42:20 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id 107so14021288wra.7
        for <linux-mm@kvack.org>; Wed, 15 Nov 2017 23:42:20 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l3si601396edd.186.2017.11.15.23.42.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 15 Nov 2017 23:42:18 -0800 (PST)
Subject: Re: reducing fragmentation of unmovable pages
References: <alpine.DEB.2.10.1711061431420.24485@chino.kir.corp.google.com>
 <ba4ddd97-7f9f-c53a-dcd4-a269b2e164f6@suse.cz>
 <alpine.DEB.2.10.1711141559590.135872@chino.kir.corp.google.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <0168732b-d53f-a1b8-6623-4e4e26b85c5d@suse.cz>
Date: Thu, 16 Nov 2017 08:42:16 +0100
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1711141559590.135872@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm <linux-mm@kvack.org>

(since you say off-list was by mistake at the end of the mail, CC the list)

On 11/15/2017 01:21 AM, David Rientjes wrote:
> On Tue, 7 Nov 2017, Vlastimil Babka wrote:
> 
>>> I'm looking at ways to improve unmovable page fragmentation, specifically
>>> unreclaimable slab, but extendable to all non __GFP_RECLAIMABLE and non
>>> __GFP_MOVABLE allocations.  The big idea is to reduce the amount of fall
>>> back to other migratetypes when trying to allocate non-movable pages.
>>
>> Ultimately, fall back to other migratetype is the only thing that can be
>> done, if existing MIGRATE_UNMOVABLE pageblocks are full. The key goal
>> should then be to fully use existing pageblocks with unmovable pages by
>> further unmovable allocations, instead of scattering them among other
>> pageblocks.
>>
> 
> Yes, MIGRATE_UNMOVABLE pageblocks are already fully utilized with the 
> exception of draining pcp lists.  The goal is to reduce the amount of 
> fallback for unmovable pages to other migrate types by trying to increase 
> the amount of memory available on MIGRATE_UNMOVABLE pageblocks using 
> various means.

OK

>>> Specifically:
>>>
>>>  - Do not steal entire MIGRATE_MOVABLE pageblocks during fallback the 
>>>    vast majority of the time.  The page allocator prefers to fallback to
>>>    larger page orders first to prevent the need for subsequent fallback.
>>
>> Which is consistent with what I said above. If it steals a small part,
>> it would pollute the pageblock with few unmovable pages, likely without
>> marking the pageblock itself as unmovable. The following unmovable
>> allocations would then pollute another pageblock... If they are short
>> lived ones, it's no big deal, but we don't know that.
>>
>>>    As a result, move_freepages_block() typically converts the fallback
>>>    pageblock, MIGRATE_RECLAIMABLE or MIGRATE_MOVABLE, to 
>>>    MIGRATE_UNMOVABLE increasing fragmentation and making it difficult to
>>
>> What exactly does "increasing fragmentation" mean here?
>>
> 
> Sorry, increasing the number of pageblocks that are MIGRATE_UNMOVABLE and 
> not available for various modes of compaction.  I see this as two 
> different problems:
> 
>  - without memory pressure, no reclaimable slab is freed from unmovable
>    pageblocks that could make memory for subsequent MIGRATE_UNMOVABLE
>    allocations available, and

Well, slab reclaim is a story of its own. Due to its internal
fragmentation there cannot guarantee freeing whole pages.

>  - existing movable memory gets stranded on MIGRATE_UNMOVABLE pageblocks
>    due to the conversion and it is hard to switch back to MIGRATE_MOVABLE
>    later.

Yeah the switching back might be a problem in the "theoretical worst
case" scenario quoted below.

>>>    convert back to MIGRATE_MOVABLE due to long-lived slab allocations.
>>
>> Having the long-lived slab allocations spread in multiple pageblocks
>> would be worse. They could be marked MIGRATE_MOVABLE, but in fact
>> contain some unmovable pages, thus still not available for huge pages.
>> Ultimately we don't know which unmovable allocations are long-lived and
>> which aren't. We can only strive to limit the number of pageblocks they
>> pollute. The theoretical worst case is a large burst of unmovable
>> allocations mixing short and long lived ones, where we eventually fill
>> most pageblocks with them, and then the short lived ones are freed and
>> we are left with each pageblock containing few long lived ones. IMHO no
>> scheme can prevent that unless it can predict the allocation age or have
>> truly useful hints, in order to keep the short and long lived ones in
>> separate pageblocks.
>>
> 
> Absent some kind of annotation where we group various types of kmem 
> together, I'm wondering the reverse of what I wrote would actually be 
> better?  In other words, when falling back to MIGRATE_MOVABLE pageblocks, 
> always convert the entire pageblock to MIGRATE_UNMOVABLE with the 
> rationale that we want to exhaust that particular pageblock before falling 
> back again, regardless of whether half of it is free or not.

Yes that's what I was trying to say. We already steal all free pages
from the pageblock in that case, although we don't necessarily mark is
MIGRATE_UNMOVABLE.

So one idea I also tried to develop at some point (IIRC even posted some
version, and maybe Joonsoo did as well?) is to introduce a new
MIGRATE_MIXED migratetype for marking blocks that were used as a
fragmenting fallback, but didn't steal enough to mark them UNMOVABLE or
RECLAIMABLE. Then they are used first in the fallback preference order.

Theoretically this should help the heuristics, because a) we prevent
unmovable allocations falling back to more more MOVABLE pageblocks by
first reusing those already lightly "polluted", because now they are
marked as MIXED and preferred, while previously they would be marked as
MOVABLE and chosen at random. And b) if a burst of unmovable allocations
subsides and short-lived ones are freed, we might now have less
UNMOVABLE pageblocks, where further unmovable allocations will be
contained, while in MIXED pageblocks the existing unmovable allocations
would be only freed, so eventually they might get converted to pure
MOVABLE again.

But for this to fully work, we might need to have more mechanisms for
converting the pageblock marking according to current number of
movable/unmovable pages in the pageblock, than just the fallback events
(which used to only care about free pages, but since commit
02aa0cdd72483 they also count movable ones), or fully freeing pageblock.
Compaction scanner would be a natural fit for that.

>>>  - Trigger kcompactd in the background to migrate eligible memory only
>>>    from MIGRATE_UNMOVABLE pageblocks when the allocator falls back to
>>>    pageblocks of different migratetype.
>>
>> Yeah, there were such suggestions in the past, we could trigger the
>> migration specifically from the pageblock which was used as the fall back.
>>
> 
> Yeah, a MIGRATE_ASYNC-ish type of compaction that migrates from the 
> fallback pageblock to MIGRATE_MOVABLE pageblocks in an attempt to free as 
> much of the fallback pageblock as possible.
> 
>>>  - Trigger shrink_slab() in the background to free reclaimable slab even
>>>    when per-zone watermarks have not been met when falling back to
>>>    pageblocks of different migratetype to hopefully make pages eligible
>>>    from MIGRATE_UNMOVABLE pageblocks for subsequent allocations.
>>
>> That would free MIGRATE_RECLAIMABLE pages, not unmovable. But perhaps
>> still an improvement, because fallback to reclaimable is preferred to
>> movable.
>>
> 
> s/MIGRATE_UNMOVABLE/MIGRATE_RECLAIMABLE/ in mine

Right.

> ,s/preferred to 
> movable/preferred to unmovable/ in yours?

Yes.

> Yeah, so what I was thinking was to trigger shrink_slab() from 
> MIGRATE_RECLAIMABLE pageblocks anytime there is fallback for 
> MIGRATE_UNMOVABLE pages, regardless of whether it falls back to 
> MIGRATE_RECLAIMABLE or MIGRATE_UNMOVABLE.

Could be worth trying, but note the internal fragmentation problem. Also
we wouldn't want to harm performance by shrinking the caches too much.
Maybe the workload would have a natural working set of both reclaimable
and unmovable allocations and we might be thrashing it prematurely.

>>> The goal is to make more MIGRATE_UNMOVABLE memory available for kmem
>>> allocations to avoid falling back to MIGRATE_RECLAIMABLE and 
>>> MIGRATE_MOVABLE pageblocks.  This results in a higher amount of memory
>>> available for hugepage allocation and less work needed to be done by
>>> compaction to constantly try to make MIGRATE_MOVABLE entirely free for
>>> hugepage allocation.
>>>
>>> Thoughts?  More ideas?
>>
>> Well, I don't see why keep such discussions off-list :)
>>
> 
> Unintentional, sorry.  Do you have any other ideas beyond this that might 
> help reduce kmem fragmentation, which makes compaction harder and less 
> memory available for high-order allocations?
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
