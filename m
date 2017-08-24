Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id D88122806E4
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 02:24:35 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id y129so31510569pgy.1
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 23:24:35 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id m1si2282724pgc.178.2017.08.23.23.24.33
        for <linux-mm@kvack.org>;
        Wed, 23 Aug 2017 23:24:34 -0700 (PDT)
Date: Thu, 24 Aug 2017 15:24:57 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC PATCH 0/6] proactive kcompactd
Message-ID: <20170824062457.GA24656@js1304-P5Q-DELUXE>
References: <20170727160701.9245-1-vbabka@suse.cz>
 <alpine.DEB.2.10.1708091353500.1218@chino.kir.corp.google.com>
 <20170821141014.GC1371@cmpxchg.org>
 <20170823053612.GA19689@js1304-P5Q-DELUXE>
 <502d438b-7167-5b78-c66c-0e1b47ba2434@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <502d438b-7167-5b78-c66c-0e1b47ba2434@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>

On Wed, Aug 23, 2017 at 10:12:14AM +0200, Vlastimil Babka wrote:
> On 08/23/2017 07:36 AM, Joonsoo Kim wrote:
> > On Mon, Aug 21, 2017 at 10:10:14AM -0400, Johannes Weiner wrote:
> >> On Wed, Aug 09, 2017 at 01:58:42PM -0700, David Rientjes wrote:
> >>> On Thu, 27 Jul 2017, Vlastimil Babka wrote:
> >>>
> >>>> As we discussed at last LSF/MM [1], the goal here is to shift more compaction
> >>>> work to kcompactd, which currently just makes a single high-order page
> >>>> available and then goes to sleep. The last patch, evolved from the initial RFC
> >>>> [2] does this by recording for each order > 0 how many allocations would have
> >>>> potentially be able to skip direct compaction, if the memory wasn't fragmented.
> >>>> Kcompactd then tries to compact as long as it takes to make that many
> >>>> allocations satisfiable. This approach avoids any hooks in allocator fast
> >>>> paths. There are more details to this, see the last patch.
> >>>>
> >>>
> >>> I think I would have liked to have seen "less proactive" :)
> >>>
> >>> Kcompactd currently has the problem that it is MIGRATE_SYNC_LIGHT so it 
> >>> continues until it can defragment memory.  On a host with 128GB of memory 
> >>> and 100GB of it sitting in a hugetlb pool, we constantly get kcompactd 
> >>> wakeups for order-2 memory allocation.  The stats are pretty bad:
> >>>
> >>> compact_migrate_scanned 2931254031294 
> >>> compact_free_scanned    102707804816705 
> >>> compact_isolated        1309145254 
> >>>
> >>> 0.0012% of memory scanned is ever actually isolated.  We constantly see 
> >>> very high cpu for compaction_alloc() because kcompactd is almost always 
> >>> running in the background and iterating most memory completely needlessly 
> >>> (define needless as 0.0012% of memory scanned being isolated).
> >>
> >> The free page scanner will inevitably wade through mostly used memory,
> >> but 0.0012% is lower than what systems usually have free. I'm guessing
> >> this is because of concurrent allocation & free cycles racing with the
> >> scanner? There could also be an issue with how we do partial scans.
> >>
> >> Anyway, we've also noticed scalability issues with the current scanner
> >> on 128G and 256G machines. Even with a better efficiency - finding the
> >> 1% of free memory, that's still a ton of linear search space.
> >>
> >> I've been toying around with the below patch. It adds a free page
> >> bitmap, allowing the free scanner to quickly skip over the vast areas
> >> of used memory. I don't have good data on skip-efficiency at higher
> >> uptimes and the resulting fragmentation yet. The overhead added to the
> >> page allocator is concerning, but I cannot think of a better way to
> >> make the search more efficient. What do you guys think?
> > 
> > Hello, Johannes.
> > 
> > I think that the best solution is that the compaction doesn't do linear
> > scan completely. Vlastimil already have suggested that idea.
> 
> I was going to bring this up here, thanks :)
> 
> > mm, compaction: direct freepage allocation for async direct
> > compaction
> > 
> > lkml.kernel.org/r/<1459414236-9219-5-git-send-email-vbabka@suse.cz>
> > 
> > It uses the buddy allocator to get a freepage so there is no linear
> > scan. It would completely remove scalability issue.
> 
> Another big advantage is that migration scanner would get to see the
> whole zone, and not be biased towards the first 1/3 until it meets the
> free scanner. And another advantage is that we wouldn't be splitting
> free pages needlessly.
> 
> > Unfortunately, he applied this idea only to async compaction since
> > changing the other compaction mode will probably cause long term
> > fragmentation. And, I disagreed with that idea at that time since
> > different compaction logic for different compaction mode would make
> > the system more unpredicatable.
> > 
> > I doubt long term fragmentation is a real issue in practice. We loses
> > too much things to prevent long term fragmentation. I think that it's
> > the time to fix up the real issue (yours and David's) by giving up the
> > solution for long term fragmentation.
> 
> I'm now also more convinced that this direction should be pursued, and
> wanted to get to it after the proactive kcompactd part. My biggest
> concern is that freelists can give us the pages from the same block that
> we (or somebody else) is trying to compact (migrate away). Isolating
> (i.e. MIGRATE_ISOLATE) the block first would work, but the overhead of
> the isolation could be significant. But I have some alternative ideas
> that could be tried.
> 
> > If someone doesn't agree with above solution, your approach looks the
> > second best to me. Though, there is something to optimize.
> > 
> > I think that we don't need to be precise to track the pageblock's
> > freepage state. Compaction is a far rare event compared to page
> > allocation so compaction could be tolerate with false positive.
> > 
> > So, my suggestion is:
> > 
> > 1) Use 1 bit for the pageblock. Reusing PB_migrate_skip looks the best
> > to me.
> 
> Wouldn't the reusing cripple the original use for the migration scanner?

I think that there is no serious problem. Problem happens if we set
PB_migrate_skip wrongly. Consider following two cases that set
PB_migrate_skip.

1) migration scanner find that whole pages in the pageblock is pinned.
-> set skip -> it is cleared after one of the page is freed. No
problem.

There is a possibility that temporary pinned page is unpinned and we
miss this pageblock but it would be minor case.

2) migration scanner find that whole pages in the pageblock are free.
-> set skip -> we can miss the pageblock for a long time.

We need to fix 2) case in order to reuse PB_migrate_skip. I guess that
just counting the number of freepage in isolate_migratepages_block()
and considering it to not set PB_migrate_skip will work.

> 
> > 2) Mark PB_migrate_skip only in free path and only when needed.
> > Unmark it in compaction if freepage scan fails in that pageblock.
> > In compaction, skip the pageblock if PB_migrate_skip is set. It means
> > that there is no freepage in the pageblock.
> > 
> > Following is some code about my suggestion.
> 
> Otherwise is sounds like it could work until the direct allocation
> approach is fully developed (or turns out to be infeasible).

Agreed.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
