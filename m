Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7079A6B0033
	for <linux-mm@kvack.org>; Fri, 24 Nov 2017 05:57:55 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id o20so2428879wro.8
        for <linux-mm@kvack.org>; Fri, 24 Nov 2017 02:57:55 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i23si4989091edj.505.2017.11.24.02.57.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 24 Nov 2017 02:57:53 -0800 (PST)
Date: Fri, 24 Nov 2017 10:57:50 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm, compaction: direct freepage allocation for async
 direct compaction
Message-ID: <20171124105750.pwixg6wg3ifkldil@suse.de>
References: <20171122143321.29501-1-hannes@cmpxchg.org>
 <20171123140843.is7cqatrdijkjqql@suse.de>
 <1d1ec1f2-d7aa-ee56-b18b-7d5efc172a50@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1d1ec1f2-d7aa-ee56-b18b-7d5efc172a50@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu, Nov 23, 2017 at 10:15:17PM +0100, Vlastimil Babka wrote:
> On 11/23/2017 03:08 PM, Mel Gorman wrote:
> > 
> > 1. This indirectly uses __rmqueue to allocate a MIGRATE_MOVABLE page but
> >    that is allowed to fallback to other pageblocks and potentially even
> >    steal them. I think it's very bad that an attempt to defragment can
> >    itself indirectly cause more fragmentation events by altering pageblocks.
> >    Please consider using __rmqueue_fallback (within alloc_pages_zone of
> >    course)
> 
> Agree. That should be simpler to do in the new version of the patch and
> its __rmqueue_compact(). It might happen though that we deplete all free
> pages on movable lists. Then the only option is to fallback to others
> (aborting compaction in that case makes little sense IMHO) but perhaps
> without the usual fallback heuristics of trying to steal the largest
> page, whole pageblock etc.
> 

I also should have said __rmqueue_smallest. It was __rmqueue_fallback
that needed to be avoided :(

> > 2. One of the reasons a linear scanner was used was because I wanted the
> >    possibility that MIGRATE_UNMOVABLE and MIGRATE_RECLAIMABLE pageblocks
> >    would also be scanned and we would avoid future fragmentation events.
> 
> Hmm are you talking about the free scanner here, or the migration
> scanner? The free scanner generally avoids these pageblocks, by the way
> of suitable_migration_target() (and I think it used to be like this all
> the time). Only recently an override of cc->ignore_block_suitable was added.
> 

Migration scanner.

> >    This had a lot of overhead and was reduced since but it's still a
> >    relevant problem.  Granted, this patch is not the correct place to fix
> >    that issue and potential solutions have been discussed elsewhere. However,
> >    this patch potentially means that never happens. It doesn't necessarily
> >    kill the patch but the long-lived behaviour may be that no compaction
> >    occurs because all the MIGRATE_MOVABLE pageblocks are full and you'll
> >    either need to reclaim to fix it or we'll need kcompactd to migration
> >    MIGRATE_MOVABLE pages from UNMOVABLE and RECLAIMABLE pageblocks out
> >    of band.
> > 
> >    For THP, this point doesn't matter but if you need this patch for
> >    high-order allocations for network buffers then at some point, you
> >    really will have to clean out those pageblocks or it'll degrade.
> 
> Hmm this really reads like about the migration scanner. That one is
> unchanged by this patch, there is still a linear scanner. In fact, it
> gets better, because now it can see the whole zone, not just the first
> 1/3 - 1/2 until it meets the free scanner (my past observations). And
> some time ago the async direct compaction was adjusted so that it only
> scans the migratetype matching the allocation (see
> suitable_migration_source()). So to some extent, the cleaning already
> happens.
> 

It is true that the migration scanner may see a subset of the zone but
it was important to avoid a previous migration source becoming a
migration target. The problem is completely different when using the
freelist as a hint.

> > 3. Another reason a linear scanner was used was because we wanted to
> >    clear entire pageblocks we were migrating from and pack the target
> >    pageblocks as much as possible. This was to reduce the amount of
> >    migration required overall even though the scanning hurts. This patch
> >    takes MIGRATE_MOVABLE pages from anywhere that is "not this pageblock".
> >    Those potentially have to be moved again and again trying to randomly
> >    fill a MIGRATE_MOVABLE block. Have you considered using the freelists
> >    as a hint? i.e. take a page from the freelist, then isolate all free
> >    pages in the same pageblock as migration targets? That would preserve
> >    the "packing property" of the linear scanner.
> > 
> >    This would increase the amount of scanning but that *might* be offset by
> >    the number of migrations the workload does overall. Note that migrations
> >    potentially are minor faults so if we do too many migrations, your
> >    workload may suffer.
> 
> I have considered the "freelist as a hint", but I'm kinda sceptical
> about it, because with increasing uptime reclaim should be freeing
> rather random pages, so finding some free page in a pageblock doesn't
> mean there would be more free pages there than in the other pageblocks?
> 

True, but randomly selecting pageblocks based on the contents of the
freelist is not better. If a pageblock has limited free pages then it'll
be filled quickly and not used as a hint in the future.

> Instead my plan is to make the migration scanner smarter by expanding
> the "skip_on_failure" feature in isolate_migratepages_block(). The
> scanner should not even start isolating if the block ahead contains a
> page that's not free or lru-isolatable/PageMovable. The current
> "look-ahead" is effectively limited by COMPACT_CLUSTER_MAX (32) isolated
> pages followed by a migration, after which the scanner might immediately
> find a non-migratable page, so if it was called for a THP, that work has
> been wasted.
> 

That's also not necessarily true because there is a benefit to moving
pages from unmovable blocks to avoid fragmentation later.

> > 5. Consider two processes A and B compacting at the same time with A_s
> >    and A_t being the source pageblock and target pageblock that process
> >    A is using and B_s/B_t being B's pageblocks. Nothing prevents A_s ==
> >    B_t and B_s == A_t. Maybe it rarely happens in practice but it was one
> >    problem the linear scanner was meant to avoid.
> 
> I hope that ultimately this problem is not worse than the existing
> problem where B would not be compacting, but simply allocating the pages
> that A just created... Maybe if the "look-ahead" idea turns out to have
> high enough success rate of really creating the high-order page where it
> decides to isolate and migrate (which probably depends mostly on the
> migration failure rate?) we could resurrect the old idea of doing a
> pageblock isolation (MIGRATE_ISOLATE) beforehand. That would block all
> interference.
> 

Pageblock bits similar to the skip bit could also be used to limit the
problem.

> > I can't shake the feeling I had another concern when I started this
> > email but then forgot it before I got to the end so it can't be that
> > important :(.
> 
> Thanks a lot for the feedback. I totally see how the approach of two
> linear scanners makes many things simpler, but seems we are now really
> paying too high a price for the free page scanning. So hopefully there
> is a way out, although not a simple one.


While the linear scanner solved some problems, I do agree that the overhead
is too high today. However, I think it can be fixed by using the freelist
as a hint, possibly combined with a pageblock bit to avoid hitting some
problems the linear scanner avoids. I do think there is a way out even
though I also think that the complexity would not have been justified
when compaction was first introduced -- partially because it was not clear
the time that the overhead was an issue but mostly because compaction was
initially a huge-page-only thing.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
