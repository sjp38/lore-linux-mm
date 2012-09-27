Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id A9EAB6B005A
	for <linux-mm@kvack.org>; Thu, 27 Sep 2012 08:15:02 -0400 (EDT)
Date: Thu, 27 Sep 2012 13:14:57 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 8/9] mm: compaction: Cache if a pageblock was scanned and
 no pages were isolated
Message-ID: <20120927121457.GC3429@suse.de>
References: <1348224383-1499-1-git-send-email-mgorman@suse.de>
 <1348224383-1499-9-git-send-email-mgorman@suse.de>
 <20120921143656.60a9a6cd.akpm@linux-foundation.org>
 <20120924093938.GZ11266@suse.de>
 <20120924142644.06c38b80.akpm@linux-foundation.org>
 <20120925091207.GD11266@suse.de>
 <20120926004930.GA10229@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120926004930.GA10229@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Avi Kivity <avi@redhat.com>, QEMU-devel <qemu-devel@nongnu.org>, KVM <kvm@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Sep 26, 2012 at 09:49:30AM +0900, Minchan Kim wrote:
> On Tue, Sep 25, 2012 at 10:12:07AM +0100, Mel Gorman wrote:
> > On Mon, Sep 24, 2012 at 02:26:44PM -0700, Andrew Morton wrote:
> > > On Mon, 24 Sep 2012 10:39:38 +0100
> > > Mel Gorman <mgorman@suse.de> wrote:
> > > 
> > > > On Fri, Sep 21, 2012 at 02:36:56PM -0700, Andrew Morton wrote:
> > > > 
> > > > > Also, what has to be done to avoid the polling altogether?  eg/ie, zap
> > > > > a pageblock's PB_migrate_skip synchronously, when something was done to
> > > > > that pageblock which justifies repolling it?
> > > > > 
> > > > 
> > > > The "something" event you are looking for is pages being freed or
> > > > allocated in the page allocator. A movable page being allocated in block
> > > > or a page being freed should clear the PB_migrate_skip bit if it's set.
> > > > Unfortunately this would impact the fast path of the alloc and free paths
> > > > of the page allocator. I felt that that was too high a price to pay.
> > > 
> > > We already do a similar thing in the page allocator: clearing of
> > > ->all_unreclaimable and ->pages_scanned. 
> > 
> > That is true but that is a simple write (shared cache line but still) to
> > a struct zone. Worse, now that you point it out, that's pretty stupid. It
> > should be checking if the value is non-zero before writing to it to avoid
> > a cache line bounce.
> > 
> > Clearing the PG_migrate_skip in this path to avoid the need to ever pool is
> > not as cheap as it needs to
> > 
> > set_pageblock_skip
> >   -> set_pageblock_flags_group
> >     -> page_zone
> >     -> page_to_pfn
> >     -> get_pageblock_bitmap
> >     -> pfn_to_bitidx
> >     -> __set_bit
> > 
> > > But that isn't on the "fast
> > > path" really - it happens once per pcp unload. 
> > 
> > That's still an important enough path that I'm wary of making it fatter
> > and that only covers the free path. To avoid the polling, the allocation
> > side needs to be handled too. It could be shoved down into rmqueue() to
> > put it into a slightly colder path but still, it's a price to pay to keep
> > compaction happy.
> > 
> > > Can we do something
> > > like that?  Drop some hint into the zone without having to visit each
> > > page?
> > > 
> > 
> > Not without incurring a cost, but yes, t is possible to give a hint on when
> > PG_migrate_skip should be cleared and move away from that time-based hammer.
> > 
> > First, we'd introduce a variant of get_pageblock_migratetype() that returns
> > all the bits for the pageblock flags and then helpers to extract either the
> > migratetype or the PG_migrate_skip. We already are incurring the cost of
> > get_pageblock_migratetype() so it will not be much more expensive than what
> > is already there. If there is an allocation or free within a pageblock that
> > as the PG_migrate_skip bit set then we increment a counter. When the counter
> > reaches some to-be-decided "threshold" then compaction may clear all the
> > bits. This would match the criteria of the clearing being based on activity.
> > 
> > There are four potential problems with this
> > 
> > 1. The logic to retrieve all the bits and split them up will be a little
> >    convulated but maybe it would not be that bad.
> > 
> > 2. The counter is a shared-writable cache line but obviously it could
> >    be moved to vmstat and incremented with inc_zone_page_state to offset
> >    the cost a little.
> > 
> > 3. The biggested weakness is that there is not way to know if the
> >    counter is incremented based on activity in a small subset of blocks.
> > 
> > 4. What should the threshold be?
> > 
> > The first problem is minor but the other three are potentially a mess.
> > Adding another vmstat counter is bad enough in itself but if the counter
> > is incremented based on a small subsets of pageblocks, the hint becomes
> > is potentially useless.
> 
> Another idea is that we can add two bits(PG_check_migrate/PG_check_free)
> in pageblock_flags_group.
> In allocation path, we can set PG_check_migrate in a pageblock
> In free path, we can set PG_check_free in a pageblock.
> And they are cleared by compaction's scan like now.
> So we can discard 3 and 4 at least.
> 

Adding a second bit does not fix problem 3 or problem 4 at all. With two
bits, all activity could be concentrated on two blocks - one migrate and
one free. The threshold still has to be selected.

> Another idea is that let's cure it by fixing fundamental problem.
> Make zone's locks more fine-grained.

Far easier said than done and only covers the contention problem. It
does nothing for the scanning problem.

> As time goes by, system uses bigger memory but our lock of zone
> isn't scalable. Recently, lru_lock and zone->lock contention report
> isn't rare so i think it's good time that we move next step.
> 

Lock contention on both those locks recently were due to compaction
rather than something more fundamental.

> How about defining struct sub_zone per 2G or 4G?
> so a zone can have several sub_zone as size and subzone can replace
> current zone's role and zone is just container of subzones.
> Of course, it's not easy to implement but I think someday we should
> go that way. Is it a really overkill?
> 

One one side that greatly increases the cost of the page allocator and
the size of the zonelist it must walk as it'll need additional walks for
each of these lists. The interaction with fragmentation avoidance and
how it handles fallbacks would be particularly problematic. On the other
side, multiple sub-zones will also introduce multiple LRUs making the
existing balancing problem considerably worse.

And again, all this would be aimed at contention and do nothing for the
scanning problem at hand.

That introduces a multiple LRUs that must be balanced problem. 

I'm work on a patch that removes the time heuristic that I think might
work. Will hopefully post it today.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
