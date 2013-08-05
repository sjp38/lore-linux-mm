Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 92E216B0031
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 00:48:18 -0400 (EDT)
Date: Mon, 5 Aug 2013 13:48:58 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [patch v2 3/3] mm: page_alloc: fair zone allocator policy
Message-ID: <20130805044858.GN32486@bbox>
References: <1375457846-21521-1-git-send-email-hannes@cmpxchg.org>
 <1375457846-21521-4-git-send-email-hannes@cmpxchg.org>
 <20130805011546.GI32486@bbox>
 <20130805034304.GC23319@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130805034304.GC23319@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@surriel.com>, Andrea Arcangeli <aarcange@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, Aug 04, 2013 at 11:43:04PM -0400, Johannes Weiner wrote:
> On Mon, Aug 05, 2013 at 10:15:46AM +0900, Minchan Kim wrote:
> > Hello Hannes,
> > 
> > On Fri, Aug 02, 2013 at 11:37:26AM -0400, Johannes Weiner wrote:
> > > Each zone that holds userspace pages of one workload must be aged at a
> > > speed proportional to the zone size.  Otherwise, the time an
> > > individual page gets to stay in memory depends on the zone it happened
> > > to be allocated in.  Asymmetry in the zone aging creates rather
> > > unpredictable aging behavior and results in the wrong pages being
> > > reclaimed, activated etc.
> > > 
> > > But exactly this happens right now because of the way the page
> > > allocator and kswapd interact.  The page allocator uses per-node lists
> > > of all zones in the system, ordered by preference, when allocating a
> > > new page.  When the first iteration does not yield any results, kswapd
> > > is woken up and the allocator retries.  Due to the way kswapd reclaims
> > > zones below the high watermark while a zone can be allocated from when
> > > it is above the low watermark, the allocator may keep kswapd running
> > > while kswapd reclaim ensures that the page allocator can keep
> > > allocating from the first zone in the zonelist for extended periods of
> > > time.  Meanwhile the other zones rarely see new allocations and thus
> > > get aged much slower in comparison.
> > > 
> > > The result is that the occasional page placed in lower zones gets
> > > relatively more time in memory, even gets promoted to the active list
> > > after its peers have long been evicted.  Meanwhile, the bulk of the
> > > working set may be thrashing on the preferred zone even though there
> > > may be significant amounts of memory available in the lower zones.
> > > 
> > > Even the most basic test -- repeatedly reading a file slightly bigger
> > > than memory -- shows how broken the zone aging is.  In this scenario,
> > > no single page should be able stay in memory long enough to get
> > > referenced twice and activated, but activation happens in spades:
> > > 
> > >   $ grep active_file /proc/zoneinfo
> > >       nr_inactive_file 0
> > >       nr_active_file 0
> > >       nr_inactive_file 0
> > >       nr_active_file 8
> > >       nr_inactive_file 1582
> > >       nr_active_file 11994
> > >   $ cat data data data data >/dev/null
> > >   $ grep active_file /proc/zoneinfo
> > >       nr_inactive_file 0
> > >       nr_active_file 70
> > >       nr_inactive_file 258753
> > >       nr_active_file 443214
> > >       nr_inactive_file 149793
> > >       nr_active_file 12021
> > > 
> > > Fix this with a very simple round robin allocator.  Each zone is
> > > allowed a batch of allocations that is proportional to the zone's
> > > size, after which it is treated as full.  The batch counters are reset
> > > when all zones have been tried and the allocator enters the slowpath
> > > and kicks off kswapd reclaim.  Allocation and reclaim is now fairly
> > > spread out to all available/allowable zones:
> > > 
> > >   $ grep active_file /proc/zoneinfo
> > >       nr_inactive_file 0
> > >       nr_active_file 0
> > >       nr_inactive_file 174
> > >       nr_active_file 4865
> > >       nr_inactive_file 53
> > >       nr_active_file 860
> > >   $ cat data data data data >/dev/null
> > >   $ grep active_file /proc/zoneinfo
> > >       nr_inactive_file 0
> > >       nr_active_file 0
> > >       nr_inactive_file 666622
> > >       nr_active_file 4988
> > >       nr_inactive_file 190969
> > >       nr_active_file 937
> > > 
> > > When zone_reclaim_mode is enabled, allocations will now spread out to
> > > all zones on the local node, not just the first preferred zone (which
> > > on a 4G node might be a tiny Normal zone).
> > 
> > I really want to give Reviewed-by but before that, I'd like to clear out
> > my concern which didn't handle enoughly in previous iteration.
> > 
> > Let's assume system has normal zone : 800M High zone : 800M
> > and there are two parallel workloads.
> > 
> > 1. alloc_pages(GFP_KERNEL) : 800M
> > 2. alloc_pages(GFP_MOVABLE) + mlocked : 800M
> > 
> > With old behavior, allocation from both workloads is fulfilled happily
> > because most of allocation from GFP_KERNEL would be done in normal zone
> > while most of allocation from GFP_MOVABLE would be done in high zone.
> > There is no OOM kill in this scenario.
> 
> If you have used ANY cache before, the movable pages will spill into
> lowmem.

Indeed, my example was just depends on luck.
I just wanted to discuss such corner case issue to notice cons at least,
someone. 

> 
> > With you change, normal zone would be fullfilled with GFP_KERNEL:400M
> > and GFP_MOVABLE:400M while high zone will have GFP_MOVABLE:400 + free 400M.
> > Then, someone would be OOM killed.
> >
> > Of course, you can argue that if there is such workloads, he should make
> > sure it via lowmem_reseve but it's rather overkill if we consider more examples
> > because any movable pages couldn't be allocated from normal zone so memory
> > efficieny would be very bad.
> 
> That's exactly what lowmem reserves are for: protect low memory from
> data that can sit in high memory, so that you have enough for data
> that can only be in low memory.
> 
> If we find those reserves to be inadequate, we have to increase them.
> You can't assume you get more lowmem than the lowmem reserves, period.

Theoretically, true.

> 
> And while I don't mean to break highmem machines, I really can't find
> it in my heart to care about theoretical performance variations in
> highmem cornercases (which is already a redundancy).

Yes. as I said, I don't know such workload, even embedded world.
But, recent mobile phone start to use 3G DRAM and maybe 2G would be a high
memory in 32bit machine. That's why I had a concern about this patch.
I think It's likely to pin lowmem more than old.

> 
> > As I said, I like your approach because I have no idea to handle unbalanced
> > aging problem better and we can get more benefits rather than lost by above
> > corner case but at least, I'd like to confirm what you think about
> > above problem before further steps. Maybe we can introduce "mlock with
> > newly-allocation or already-mapped page could be migrated to high memory zone"
> > when someone reported out? (we thougt mlocked page migration would be problem
> > RT latency POV but Peter confirmed it's no problem.)
> 
> And you think increasing lowmem reserves would be overkill? ;-)

If possible, I would like to avoid. ;-)

Peak workload : 800M average workload : 100M 
int foo[800M] vs int *bar = malloc(800M);

> 
> These patches fix real page aging problems.  Making trade offs to work

Indeed!

> properly on as many setups as possible is one thing, but a highmem
> configuration where you need exactly 100% of lowmem and mlock 100% of
> highmem?

Nope. Apprently, I don't know.
I just wanted to record that we should already cover such claims
in review phase so that if such problem happens in future, we can answer
easily "Just rasise your lowmem reserve ratio because you have been
depends on the luck until now". And I don't want to argue with other mm
guys such solution in future again.

> 
> Come on, Minchan...

I think as reviewer, it's enough as it is.

All three patches,

Reviewed-by: Minchan Kim <minchan@kernel.org>

> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
