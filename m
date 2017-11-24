Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id AD0116B025F
	for <linux-mm@kvack.org>; Fri, 24 Nov 2017 08:51:03 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id q187so5647521pga.6
        for <linux-mm@kvack.org>; Fri, 24 Nov 2017 05:51:03 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y29si19224149pff.367.2017.11.24.05.51.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 24 Nov 2017 05:51:02 -0800 (PST)
Subject: Re: [PATCH] mm, compaction: direct freepage allocation for async
 direct compaction
References: <20171122143321.29501-1-hannes@cmpxchg.org>
 <20171123140843.is7cqatrdijkjqql@suse.de>
 <1d1ec1f2-d7aa-ee56-b18b-7d5efc172a50@suse.cz>
 <20171124105750.pwixg6wg3ifkldil@suse.de>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <fa70766d-9251-21e7-d6be-868347523f4e@suse.cz>
Date: Fri, 24 Nov 2017 14:49:34 +0100
MIME-Version: 1.0
In-Reply-To: <20171124105750.pwixg6wg3ifkldil@suse.de>
Content-Type: text/plain; charset=iso-8859-15
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On 11/24/2017 11:57 AM, Mel Gorman wrote:
> On Thu, Nov 23, 2017 at 10:15:17PM +0100, Vlastimil Babka wrote:
>> Hmm this really reads like about the migration scanner. That one is
>> unchanged by this patch, there is still a linear scanner. In fact, it
>> gets better, because now it can see the whole zone, not just the first
>> 1/3 - 1/2 until it meets the free scanner (my past observations). And
>> some time ago the async direct compaction was adjusted so that it only
>> scans the migratetype matching the allocation (see
>> suitable_migration_source()). So to some extent, the cleaning already
>> happens.
>>
> 
> It is true that the migration scanner may see a subset of the zone but
> it was important to avoid a previous migration source becoming a
> migration target. The problem is completely different when using the
> freelist as a hint.

I think fundamentally the problems are the same when using freelist
exclusively, or just as a hint, as there's no longer the natural
exclusivity where some pageblocks are used as migration source and
others as migration target, no?

>>> 3. Another reason a linear scanner was used was because we wanted to
>>>    clear entire pageblocks we were migrating from and pack the target
>>>    pageblocks as much as possible. This was to reduce the amount of
>>>    migration required overall even though the scanning hurts. This patch
>>>    takes MIGRATE_MOVABLE pages from anywhere that is "not this pageblock".
>>>    Those potentially have to be moved again and again trying to randomly
>>>    fill a MIGRATE_MOVABLE block. Have you considered using the freelists
>>>    as a hint? i.e. take a page from the freelist, then isolate all free
>>>    pages in the same pageblock as migration targets? That would preserve
>>>    the "packing property" of the linear scanner.
>>>
>>>    This would increase the amount of scanning but that *might* be offset by
>>>    the number of migrations the workload does overall. Note that migrations
>>>    potentially are minor faults so if we do too many migrations, your
>>>    workload may suffer.
>>
>> I have considered the "freelist as a hint", but I'm kinda sceptical
>> about it, because with increasing uptime reclaim should be freeing
>> rather random pages, so finding some free page in a pageblock doesn't
>> mean there would be more free pages there than in the other pageblocks?
>>
> 
> True, but randomly selecting pageblocks based on the contents of the
> freelist is not better.

One theoretical benefit (besides no scanning overhead) is that we prefer
the smallest blocks from the freelist, where in the hint approach we
might pick order-0 as a hint but then split larger free pages in the
same pageblock.

> If a pageblock has limited free pages then it'll
> be filled quickly and not used as a hint in the future.
> 
>> Instead my plan is to make the migration scanner smarter by expanding
>> the "skip_on_failure" feature in isolate_migratepages_block(). The
>> scanner should not even start isolating if the block ahead contains a
>> page that's not free or lru-isolatable/PageMovable. The current
>> "look-ahead" is effectively limited by COMPACT_CLUSTER_MAX (32) isolated
>> pages followed by a migration, after which the scanner might immediately
>> find a non-migratable page, so if it was called for a THP, that work has
>> been wasted.
>>
> 
> That's also not necessarily true because there is a benefit to moving
> pages from unmovable blocks to avoid fragmentation later.

Yeah, I didn't describe it fully, but for unmovable blocks, this would
not apply and we would clear them. Then, avoiding fallback to unmovable
blocks when allocating migration target would prevent the ping-pong.

>>> 5. Consider two processes A and B compacting at the same time with A_s
>>>    and A_t being the source pageblock and target pageblock that process
>>>    A is using and B_s/B_t being B's pageblocks. Nothing prevents A_s ==
>>>    B_t and B_s == A_t. Maybe it rarely happens in practice but it was one
>>>    problem the linear scanner was meant to avoid.
>>
>> I hope that ultimately this problem is not worse than the existing
>> problem where B would not be compacting, but simply allocating the pages
>> that A just created... Maybe if the "look-ahead" idea turns out to have
>> high enough success rate of really creating the high-order page where it
>> decides to isolate and migrate (which probably depends mostly on the
>> migration failure rate?) we could resurrect the old idea of doing a
>> pageblock isolation (MIGRATE_ISOLATE) beforehand. That would block all
>> interference.
>>
> 
> Pageblock bits similar to the skip bit could also be used to limit the
> problem.

Right, if we can afford changing the current 4 bits per pageblock to a
full byte.

>>> I can't shake the feeling I had another concern when I started this
>>> email but then forgot it before I got to the end so it can't be that
>>> important :(.
>>
>> Thanks a lot for the feedback. I totally see how the approach of two
>> linear scanners makes many things simpler, but seems we are now really
>> paying too high a price for the free page scanning. So hopefully there
>> is a way out, although not a simple one.
> 
> 
> While the linear scanner solved some problems, I do agree that the overhead
> is too high today. However, I think it can be fixed by using the freelist
> as a hint, possibly combined with a pageblock bit to avoid hitting some
> problems the linear scanner avoids. I do think there is a way out even
> though I also think that the complexity would not have been justified
> when compaction was first introduced -- partially because it was not clear
> the time that the overhead was an issue but mostly because compaction was
> initially a huge-page-only thing.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
