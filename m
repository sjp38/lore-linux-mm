Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6E1CB6B006E
	for <linux-mm@kvack.org>; Tue,  9 Dec 2014 04:12:18 -0500 (EST)
Received: by mail-wg0-f51.google.com with SMTP id x12so235011wgg.10
        for <linux-mm@kvack.org>; Tue, 09 Dec 2014 01:12:18 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z5si13817777wiw.94.2014.12.09.01.12.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 09 Dec 2014 01:12:17 -0800 (PST)
Message-ID: <5486BCEF.5080007@suse.cz>
Date: Tue, 09 Dec 2014 10:12:15 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 2/3] mm: more aggressive page stealing for UNMOVABLE
 allocations
References: <1417713178-10256-1-git-send-email-vbabka@suse.cz> <1417713178-10256-3-git-send-email-vbabka@suse.cz> <20141208071140.GB3904@js1304-P5Q-DELUXE> <54857D0F.3080601@suse.cz> <20141209082821.GB7714@js1304-P5Q-DELUXE>
In-Reply-To: <20141209082821.GB7714@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>

On 12/09/2014 09:28 AM, Joonsoo Kim wrote:
> On Mon, Dec 08, 2014 at 11:27:27AM +0100, Vlastimil Babka wrote:
>> On 12/08/2014 08:11 AM, Joonsoo Kim wrote:
>>>
>>> I'm not sure that this change is good. If we steal order 0 pages,
>>> this may be good. But, sometimes, we try to steal high order page
>>> and, in this case, there would be many order 0 freepages and blindly
>>> stealing freepages in that pageblock make the system more fragmented.
>>
>> I don't understand. If we try to steal high order page
>> (current_order >= pageblock_order / 2), then nothing changes, the
>> condition for extra stealing is the same.
>
> More accureately, I means mid order page (current_order <
> pageblock_order / 2), but, not order 0, such as order 2,3,4(?).
> In this case, perhaps, the system has enough unmovable order 0 freepages,
> so we don't need to worry about second kind of fragmentation you
> mentioned below. Stealing one mid order freepage is enough to satify
> request.

OK.

>>
>>> MIGRATE_RECLAIMABLE is different case than MIGRATE_UNMOVABLE, because
>>> it can be reclaimed so excessive migratetype movement doesn't result
>>> in permanent fragmentation.
>>
>> There's two kinds of "fragmentation" IMHO. First, inside a
>> pageblock, unmovable allocations can prevent merging of lower
>> orders. This can get worse if we steal multiple pages from a single
>> pageblock, but the pageblock itself is not marked as unmovable.
>
> So, what's the intention pageblock itself not marked as unmovable?
> I guess that if many pages are moved to unmovable, they can't be easily
> back and this pageblock is highly fragmented. So, processing more unmovable
> requests from this pageblock by changing pageblock migratetype makes more
> sense to me.

There's the danger that we mark too much pageblocks as unmovable in some 
unmovable allocation spike and even if the number of unmovable allocated 
pages later decreases, they will keep being allocated from many 
unmovable-marked pageblocks, and neither will become empty enough to be 
remarked back. If we don't mark pageblocks unmovable as aggressively, 
it's possible that the unmovable allocations in a partially-stolen 
pageblock will be eventually freed, and no more unmovable allocations 
will occur in that pageblock if it's not marked as unmovable.

>> Second kind of fragmentation is when unmovable allocations spread
>> over multiple pageblocks. Lower order allocations within each such
>> pageblock might be still possible, but less pageblocks are able to
>> compact to have whole pageblock free.
>>
>> I think the second kind is worse, so when do have to pollute a
>> movable pageblock with unmovable allocation, we better take as much
>> as possible, so we prevent polluting other pageblocks.
>
> I agree.
>
>>
>>> What I'd like to do to prevent fragmentation is
>>> 1) check whether we can steal all or almost freepages and change
>>> migratetype of pageblock.
>>> 2) If above condition isn't met, deny allocation and invoke compaction.
>>
>> Could work to some extend, but we need also to prevent excessive compaction.
>
> So, I suggest knob to control behaviour. In small memory system,
> fragmentation occurs frequently so the system can't handle just order 2
> request. In that system, excessive compaction is acceptable because
> it it better than system down.

So you say that in these systems, order 2 requests fail because of page 
stealing?

>>
>> We could also introduce a new pageblock migratetype, something like
>> MIGRATE_MIXED. The idea is that once pageblock isn't used purely by
>> MOVABLE allocations, it's marked as MIXED, until it either becomes
>> marked UNMOVABLE or RECLAIMABLE by the existing mechanisms, or is
>> fully freed. In more detail:
>>
>> - MIXED is preferred for fallback before any other migratetypes
>> - if RECLAIMABLE/UNMOVABLE page allocation is stealing from MOVABLE
>> pageblock and cannot mark pageblock as RECLAIMABLE/UNMOVABLE (by
>> current rules), it marks it as MIXED instead.
>> - if MOVABLE allocation is stealing from UNMOVABLE/RECLAIMABLE
>> pageblocks, it will only mark it as MOVABLE if it was fully free.
>> Otherwise, if current rules would result in marking it as MOVABLE
>> (i.e. most of it was stolen, but not all) it will mark it as MIXED
>> instead.
>>
>> This could in theory leave more MOVABLE pageblocks unspoiled by
>> UNMOVABLE allocations.
>
> I guess that we can do it without introducing new migratetype pageblock.
> Just always marking it as RECLAIMABLE/UNMOVABLE when
> RECLAIMABLE/UNMOVABLE page allocation is stealing from MOVABLE would
> have same effect.

See the argument above. The difference with MIXED marking is that new 
unmovable allocations would take from these pageblocks only as a 
fallback. Primarily it would try to reuse a more limited number of 
unmovable-marked pageblocks.

But this is just an idea not related to the series at hand. Yes, it 
could be better, these are all heuristics and any change is a potential 
tradeoff.

Also we need to keep in mind that ultimately, anything we devise cannot 
prevent fragmentation 100%. We cannot predict the future, so we don't 
know which unmovable allocations will be freed soon, and which will stay 
for longer time. To minimize fragmentation, we would need to recognize 
those longer-lived unmovable allocations, so we could put them together 
in as few pageblocks as possible.

> Thanks.
>
>>> Maybe knob to control behaviour would be needed.
>>> How about it?
>>
>> Adding new knobs is not a good solution.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
