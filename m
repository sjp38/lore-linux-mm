Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 078EC6B0038
	for <linux-mm@kvack.org>; Tue, 28 Apr 2015 03:43:35 -0400 (EDT)
Received: by pacwv17 with SMTP id wv17so134431865pac.0
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 00:43:34 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id aj1si33404711pbc.23.2015.04.28.00.43.32
        for <linux-mm@kvack.org>;
        Tue, 28 Apr 2015 00:43:33 -0700 (PDT)
Date: Tue, 28 Apr 2015 16:45:40 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC PATCH 3/3] mm: support active anti-fragmentation algorithm
Message-ID: <20150428074540.GA18647@js1304-P5Q-DELUXE>
References: <1430119421-13536-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1430119421-13536-3-git-send-email-iamjoonsoo.kim@lge.com>
 <20150427082923.GG2449@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150427082923.GG2449@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>

On Mon, Apr 27, 2015 at 09:29:23AM +0100, Mel Gorman wrote:
> On Mon, Apr 27, 2015 at 04:23:41PM +0900, Joonsoo Kim wrote:
> > We already have antifragmentation policy in page allocator. It works well
> > when system memory is sufficient, but, it doesn't works well when system
> > memory isn't sufficient because memory is already highly fragmented and
> > fallback/steal mechanism cannot get whole pageblock. If there is severe
> > unmovable allocation requestor like zram, problem could get worse.
> > 
> > CPU: 8
> > RAM: 512 MB with zram swap
> > WORKLOAD: kernel build with -j12
> > OPTION: page owner is enabled to measure fragmentation
> > After finishing the build, check fragmentation by 'cat /proc/pagetypeinfo'
> > 
> > * Before
> > Number of blocks type (movable)
> > DMA32: 207
> > 
> > Number of mixed blocks (movable)
> > DMA32: 111.2
> > 
> > Mixed blocks means that there is one or more allocated page for
> > unmovable/reclaimable allocation in movable pageblock. Results shows that
> > more than half of movable pageblock is tainted by other migratetype
> > allocation.
> > 
> > To mitigate this fragmentation, this patch implements active
> > anti-fragmentation algorithm. Idea is really simple. When some
> > unmovable/reclaimable steal happens from movable pageblock, we try to
> > migrate out other pages that can be migratable in this pageblock are and
> > use these generated freepage for further allocation request of
> > corresponding migratetype.
> > 
> > Once unmovable allocation taints movable pageblock, it cannot easily
> > recover. Instead of praying that it gets restored, making it unmovable
> > pageblock as much as possible and using it further unmovable request
> > would be more reasonable approach.
> > 
> > Below is result of this idea.
> > 
> > * After
> > Number of blocks type (movable)
> > DMA32: 208.2
> > 
> > Number of mixed blocks (movable)
> > DMA32: 55.8
> > 
> > Result shows that non-mixed block increase by 59% in this case.
> > 
> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> I haven't read the patch in detail but there were a few reasons why
> active avoidance was not implemented originally.

Thanks for really good comment. I can understand why it is in current
form from your comment and what I should consider.

> 
> 1. If pages in the target block were reclaimed then it potentially
>    increased stall latency in the future when they had to be refaulted
>    again. A prototype that used lumpy reclaim originally suffered extreme
>    stalls and was ultimately abandoned. The alternative at the time was
>    to increase min_free_kbytes by default as it had a similar effect with
>    much less disruption

Reclaim is not used by this patchset.

> 2. If the pages in the target block were migrated then there was
>    compaction overhead with no guarantee of success. Again, there were
>    concerns about stalls. This was not deferred to an external thread
>    because if the fragmenting process did not stall then it could simply
>    cause more fragmentation-related damage while the thread executes. It

Yes, this patch uses migration for active fragmentation avoidance.
But, I'm not sure why external thread approach could simply cause more
fragmentation-related damage. It cannot possibly follow-up allocation
speed of fragmenting process, but, even in this case, fragmentation
would be lower compared to do nothing approach.

>    becomes very unpredictable. While migration is in progress, processes
>    also potentially stall if they reference the targetted pages.

I should admit that if processes reference the targetted pages, they
would stall and there is compaction overhead with no guarantee of
success. But, this fragmentation avoidance is really needed for low
memory system, because, in that system, fragmentation could be really high
so even order 2 allocation suffers from fragmentation. File pages are
excessively reclaimed to make order 2 page. I think that this reclaim
overhead is worse than above overhead causing by this fragmentation
avoidance algorithm.

> 3. Further on 2, the migration itself potentially triggers more fallback
>    events while pages are isolated for the migration.
> 
> 4. Migrating pages to another node is a bad idea. It requires a NUMA
>    machine at the very least but more importantly it could violate memory
>    policies. If the page was mapped then the VMA could be checked but if the
>    pages were unmapped then the kernel potentially violates memory policies

I agree. Migrating pages to another node is not intended behaviour.
I will fix it.

> At the time it was implemented, fragmentation avoidance was primarily
> concerned about allocating hugetlbfs pages and later THP. Failing either
> was not a functional failure that users would care about but large stalls
> due to active fragmentation avoidance would disrupt workloads badly.

I see. But, my attempt of this patchset is kind of functional failure.
If unmovable pages are mixed to movable pages in movable pageblock,
even small order allocation isn't processed easily in highly
fragmented low memory system.

> Just be sure to take the stalling and memory policy problems into
> account.

Okay. This versioned patch doesn't consider stalling so it isolates whole
migratable pages in pageblock all at once. :)
I will fix it in next spin.

And, ditto for memory policy.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
