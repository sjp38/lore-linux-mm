Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id DF2D16B025F
	for <linux-mm@kvack.org>; Fri, 24 Nov 2017 10:12:00 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id z14so9640550wrb.12
        for <linux-mm@kvack.org>; Fri, 24 Nov 2017 07:12:00 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w38si1254100edd.51.2017.11.24.07.11.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 24 Nov 2017 07:11:53 -0800 (PST)
Date: Fri, 24 Nov 2017 15:11:50 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm, compaction: direct freepage allocation for async
 direct compaction
Message-ID: <20171124151150.gryhgb32ttgficmi@suse.de>
References: <20171122143321.29501-1-hannes@cmpxchg.org>
 <20171123140843.is7cqatrdijkjqql@suse.de>
 <1d1ec1f2-d7aa-ee56-b18b-7d5efc172a50@suse.cz>
 <20171124105750.pwixg6wg3ifkldil@suse.de>
 <fa70766d-9251-21e7-d6be-868347523f4e@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <fa70766d-9251-21e7-d6be-868347523f4e@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Fri, Nov 24, 2017 at 02:49:34PM +0100, Vlastimil Babka wrote:
> On 11/24/2017 11:57 AM, Mel Gorman wrote:
> > On Thu, Nov 23, 2017 at 10:15:17PM +0100, Vlastimil Babka wrote:
> >> Hmm this really reads like about the migration scanner. That one is
> >> unchanged by this patch, there is still a linear scanner. In fact, it
> >> gets better, because now it can see the whole zone, not just the first
> >> 1/3 - 1/2 until it meets the free scanner (my past observations). And
> >> some time ago the async direct compaction was adjusted so that it only
> >> scans the migratetype matching the allocation (see
> >> suitable_migration_source()). So to some extent, the cleaning already
> >> happens.
> >>
> > 
> > It is true that the migration scanner may see a subset of the zone but
> > it was important to avoid a previous migration source becoming a
> > migration target. The problem is completely different when using the
> > freelist as a hint.
> 
> I think fundamentally the problems are the same when using freelist
> exclusively, or just as a hint, as there's no longer the natural
> exclusivity where some pageblocks are used as migration source and
> others as migration target, no?
> 

They are similar only in that the linear scanner only suffers from the
same problem at that boundary where the migration and free scanner meet.
At the boundary where they meet, the problem occurs if that boundary moves
towards the end of the zone.

> >>> 3. Another reason a linear scanner was used was because we wanted to
> >>>    clear entire pageblocks we were migrating from and pack the target
> >>>    pageblocks as much as possible. This was to reduce the amount of
> >>>    migration required overall even though the scanning hurts. This patch
> >>>    takes MIGRATE_MOVABLE pages from anywhere that is "not this pageblock".
> >>>    Those potentially have to be moved again and again trying to randomly
> >>>    fill a MIGRATE_MOVABLE block. Have you considered using the freelists
> >>>    as a hint? i.e. take a page from the freelist, then isolate all free
> >>>    pages in the same pageblock as migration targets? That would preserve
> >>>    the "packing property" of the linear scanner.
> >>>
> >>>    This would increase the amount of scanning but that *might* be offset by
> >>>    the number of migrations the workload does overall. Note that migrations
> >>>    potentially are minor faults so if we do too many migrations, your
> >>>    workload may suffer.
> >>
> >> I have considered the "freelist as a hint", but I'm kinda sceptical
> >> about it, because with increasing uptime reclaim should be freeing
> >> rather random pages, so finding some free page in a pageblock doesn't
> >> mean there would be more free pages there than in the other pageblocks?
> >>
> > 
> > True, but randomly selecting pageblocks based on the contents of the
> > freelist is not better.
> 
> One theoretical benefit (besides no scanning overhead) is that we prefer
> the smallest blocks from the freelist, where in the hint approach we
> might pick order-0 as a hint but then split larger free pages in the
> same pageblock.
> 

While you're right, I think it's more than offset by the possibility
that we migrate the same page multiple times and the packing is worse.
The benefit also is not that great if you consider that we're migrating to
a MIGRATE_MOVABLE block because for movable allocations, we only care about
being able to free the entire pageblock for a hugepage allocation. Splitting
a large contiguous range within a movable block so that an unmovable
allocation can use the space is not a great outcome from a fragmentation
perspective.

> > If a pageblock has limited free pages then it'll
> > be filled quickly and not used as a hint in the future.
> > 
> >> Instead my plan is to make the migration scanner smarter by expanding
> >> the "skip_on_failure" feature in isolate_migratepages_block(). The
> >> scanner should not even start isolating if the block ahead contains a
> >> page that's not free or lru-isolatable/PageMovable. The current
> >> "look-ahead" is effectively limited by COMPACT_CLUSTER_MAX (32) isolated
> >> pages followed by a migration, after which the scanner might immediately
> >> find a non-migratable page, so if it was called for a THP, that work has
> >> been wasted.
> >>
> > 
> > That's also not necessarily true because there is a benefit to moving
> > pages from unmovable blocks to avoid fragmentation later.
> 
> Yeah, I didn't describe it fully, but for unmovable blocks, this would
> not apply and we would clear them. Then, avoiding fallback to unmovable
> blocks when allocating migration target would prevent the ping-pong.
> 

While it would be nice to clear them, I don't think it would be the
responsibility of this particular patch. I think it would be better to do
that clearing from kcompactd context.

> >>> 5. Consider two processes A and B compacting at the same time with A_s
> >>>    and A_t being the source pageblock and target pageblock that process
> >>>    A is using and B_s/B_t being B's pageblocks. Nothing prevents A_s ==
> >>>    B_t and B_s == A_t. Maybe it rarely happens in practice but it was one
> >>>    problem the linear scanner was meant to avoid.
> >>
> >> I hope that ultimately this problem is not worse than the existing
> >> problem where B would not be compacting, but simply allocating the pages
> >> that A just created... Maybe if the "look-ahead" idea turns out to have
> >> high enough success rate of really creating the high-order page where it
> >> decides to isolate and migrate (which probably depends mostly on the
> >> migration failure rate?) we could resurrect the old idea of doing a
> >> pageblock isolation (MIGRATE_ISOLATE) beforehand. That would block all
> >> interference.
> >>
> > 
> > Pageblock bits similar to the skip bit could also be used to limit the
> > problem.
> 
> Right, if we can afford changing the current 4 bits per pageblock to a
> full byte.
> 

Potentially yes although maybe initially just do nothing at all with this
problem and look into whether it occurs at all later. If nothing else,
the larger the machine, the less likely it is to occur. It was more of a
concern when compaction was first implemented as machines with less than
1G of memory were still common.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
