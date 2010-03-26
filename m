Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id C62BA6B01C9
	for <linux-mm@kvack.org>; Fri, 26 Mar 2010 17:09:45 -0400 (EDT)
Date: Fri, 26 Mar 2010 21:09:23 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #15
Message-ID: <20100326210923.GD2024@csn.ul.ie>
References: <patchbomb.1269622804@v2.random> <20100326173655.GC2024@csn.ul.ie> <20100326180701.GC5825@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100326180701.GC5825@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Fri, Mar 26, 2010 at 07:07:01PM +0100, Andrea Arcangeli wrote:
> On Fri, Mar 26, 2010 at 05:36:55PM +0000, Mel Gorman wrote:
> > Correct, slab pages currently cannot migrate. Framentation within slab
> > is minimised by anti-fragmentation by distinguishing between reclaimable
> > and unreclaimable slab and grouping them appropriately. The objective is
> > to put all the unmovable pages in as few 2M (or 4M or 16M) pages as
> > possible. If min_free_kbytes is tuned as hugeadm
> > --recommended-min_free_kbytes suggests, this works pretty well.
> 
> Awesome. So this feature is already part of your memory compaction
> code?

No, anti-fragmentation has been in a long time. hugeadm (part of
libhugetlbfs) has supported --recommended-min_free_kbytes for some time
as well.

> As you may have noticed I didn't start looking deep on your code
> yet.
> 
> > Again, if min_free_kbytes is tuned appropriately, anti-frag should
> > mitigate most of the fragmentation-related damage.
> 
> I don't see the relation of why this logic should be connected to
> min_free_kbytes. Maybe I'll get it if I read the code. But
> min_free_kbytes is about the PF_MEMALLOC pool and GFP_ATOMIC memory. I
> can't see any connection with min_free_kbytes setting, and in to
> trying to keep all non relocatable entries in the same HPAGE_PMD_SIZEd
> pages.
> 

Anti-fragmentation groups within pageblocks that are the size of the
default huge page size. Blocks can have different migratetypes and the
free lists are also based on types. If there isn't a free page of the
appropriate type, rmqueue_fallback() selects an alternative list to use
from. Each one of these "fallback" events potentially increases the
badness of the level of fragmentation.

Using --recommended-min_free_kbytes keeps a number of pages free such that
these "fallback" events are severely reduced because there is typically a
page free of the appropriate type located in the correct pageblock.

If you were very curious, you use the mm_page_alloc_extfrag trace event to
monitor fragmentation-related events. Part of the event reports "fragmenting="
which indicates whether the fallback is severe in terms of fragmentation
or not.

> > On the notion of having a 2M front slab allocator, SLUB is not far off
> > being capable of such a thing but there are risks. If a 2M page is
> > dedicated to a slab, then other slabs will need their own 2M pages.
> > Overall memory usage grows and you end up worse off.
> >
> > If you suggest that slab uses 2M pages and breaks them up for slabs, you
> > are very close to what anti-frag already does. The difference might be
> 
> That's exactly what I meant yes. Doing it per-slab would be useless.
> 
> The idea was for slub to simply call alloc_page_not_relocatable(order)

If you don't specify migratetype-related GFP flags, it's assumed to be
UNMOVABLE.

> instead of alloc_page() every time it allocates an order <=
> HPAGE_PMD_ORDER. That means this 2M page would be shared for _all_
> slabs, otherwise it wouldn't work.
> 

I still think anti-frag is already doing most of what you suggest. Slab
should already be using UNMOVABLE blocks (See /proc/pagetypeinfo for how
the pageblocks are being used).

> The page freeing could even go back in the buddy initially. So the max
> waste would be 2M per cpu of ram (the front page has to be per-cpu to
> perform).
> 
> > that slab would guarantee that the 2M page is only use for slab. Again,
> > you could force this situation with anti-frag but the decision was made
> > to allow a certain amount of fragmentation to avoid the memory overhead
> > of such a thing. Again, tuning min_free_kbytes + anti-fragmentation gets
> > much of what you need.
> 
> Well if this 2M page is shared by other not relocatable entities
> that might be even better in some scenario (maybe worse in others)

The 2M page is today being shared with other unmovable (what you call
not relocatable) pages. The scenario where it potentially gets worse is
where there is a weird mix of pagetable and slab allocations. This will
push up the number of blocks used for unmovable pages to some extent.

> but
> I'm totally fine with a more elaborate approach. Clearly some driver
> could also start to call alloc_pages_not_relocatable() and then it'd
> also share the same memory as slab. I think it has to be an
> universally available feature, just like you implemented. Except right
> now the main problem is slab so that's the first user for sure ;).
> 

Right now, allocations are assumed to be unmovable unless otherwise specified.

> > Arguably, min_free_kbytes should be tuned appropriately once it's detected
> > that huge pages are in use. It would not be hard at all, we just don't do it.
> > 
> > Stronger guarantees on layout are possible but not done today because of
> > the cost.
> 
> Could you elaborate what "guarantees of layout" means?
> 

The ideal would be the fewest number of pageblocks are in use and
each pageblock only contains the pages of a specific migratetype.

One "guaranteed layout" would be that pageblocks only ever contain pages
of a given type but this would potentially require a full 2M of data to
be relocated or reclaimed to satisfy a new allocation. It would also
cause problems with atomics. It would be great from a fragmentation
perspective but suck otherwise.

> > 
> > >    Basically the buddy allocator will guarantee the slab will
> > >    generate as much fragement as possible because it does its best to keep the
> > >    high order pages for who asks for them.
> > 
> > Again, already does this up to a point. rmqueue_fallback() could refuse to
> > break up small contiguous pages for slab to force better layout in terms of
> > fragmentation but it costs heavily when memory is low because you now have to
> > reclaim (or relocate) more pages than necessary to satisfy anti-fragmentation.
> 
> I guess this will require a sysfs control.

It would also be a new feature. With memory compaction, the page
allocator will compact memory to satisfy a high-order allocation but it
doesn't compact memory to avoid mixing pageblocks.

> Do you have a
> /sys/kernel/mm/defrag directory or something?> If hugepages are
> absolutely mandatory (like with hypervisor-only usage) it is worth
> invoking memory compaction to satisfy what i call "front allocator"
> and give a full 2M page to slab instead of using the already available
> fragment. And to rmqueue-fallback only if defrag fails.
> 

There is a proc entry and sysfs entry that allow to compact either all
of memory or on a per-node basis but I'd be surprised if it was
required. When a new machine starts up, it should start
direct-compacting memory to get the huge pages it needs.

> > Sounds very similar to anti-frag again.
> 
> Indeed.
> 
> > You could force such a situation by always having X number of lower blocks
> > MIGRATE_UNMOVABLE and forcing a situation where fallback never happens to those
> > areas. You'd need to do some juggling with counters and watermarks. It's not
> > impossible and I considered doing it when anti-fragmentation was introduced
> > but again, there was insufficient data to support such a move.
> 
> Agreed. I also like a more dynamic approach, the whole idea of
> transparent hugepage is that the admin does nothing, no reservation,
> and in this case no decision of how much memory to be
> MIGRATE_UNMOVABLE.
> 
> Looking forward to see transparent hugepage taking full advantage of
> your patchset!
> 

Same here.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
