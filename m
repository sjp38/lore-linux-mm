Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id C292A6B0031
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 01:01:36 -0400 (EDT)
Date: Mon, 5 Aug 2013 01:01:19 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch v2 3/3] mm: page_alloc: fair zone allocator policy
Message-ID: <20130805050119.GA715@cmpxchg.org>
References: <1375457846-21521-1-git-send-email-hannes@cmpxchg.org>
 <1375457846-21521-4-git-send-email-hannes@cmpxchg.org>
 <20130805011546.GI32486@bbox>
 <20130805034304.GC23319@cmpxchg.org>
 <20130805044858.GN32486@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130805044858.GN32486@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@surriel.com>, Andrea Arcangeli <aarcange@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Aug 05, 2013 at 01:48:58PM +0900, Minchan Kim wrote:
> On Sun, Aug 04, 2013 at 11:43:04PM -0400, Johannes Weiner wrote:
> > On Mon, Aug 05, 2013 at 10:15:46AM +0900, Minchan Kim wrote:
> > > I really want to give Reviewed-by but before that, I'd like to clear out
> > > my concern which didn't handle enoughly in previous iteration.
> > > 
> > > Let's assume system has normal zone : 800M High zone : 800M
> > > and there are two parallel workloads.
> > > 
> > > 1. alloc_pages(GFP_KERNEL) : 800M
> > > 2. alloc_pages(GFP_MOVABLE) + mlocked : 800M
> > > 
> > > With old behavior, allocation from both workloads is fulfilled happily
> > > because most of allocation from GFP_KERNEL would be done in normal zone
> > > while most of allocation from GFP_MOVABLE would be done in high zone.
> > > There is no OOM kill in this scenario.
> > 
> > If you have used ANY cache before, the movable pages will spill into
> > lowmem.
> 
> Indeed, my example was just depends on luck.
> I just wanted to discuss such corner case issue to notice cons at least,
> someone. 
> 
> > 
> > > With you change, normal zone would be fullfilled with GFP_KERNEL:400M
> > > and GFP_MOVABLE:400M while high zone will have GFP_MOVABLE:400 + free 400M.
> > > Then, someone would be OOM killed.
> > >
> > > Of course, you can argue that if there is such workloads, he should make
> > > sure it via lowmem_reseve but it's rather overkill if we consider more examples
> > > because any movable pages couldn't be allocated from normal zone so memory
> > > efficieny would be very bad.
> > 
> > That's exactly what lowmem reserves are for: protect low memory from
> > data that can sit in high memory, so that you have enough for data
> > that can only be in low memory.
> > 
> > If we find those reserves to be inadequate, we have to increase them.
> > You can't assume you get more lowmem than the lowmem reserves, period.
> 
> Theoretically, true.
> 
> > 
> > And while I don't mean to break highmem machines, I really can't find
> > it in my heart to care about theoretical performance variations in
> > highmem cornercases (which is already a redundancy).
> 
> Yes. as I said, I don't know such workload, even embedded world.
> But, recent mobile phone start to use 3G DRAM and maybe 2G would be a high
> memory in 32bit machine. That's why I had a concern about this patch.
> I think It's likely to pin lowmem more than old.
>
> > > As I said, I like your approach because I have no idea to handle unbalanced
> > > aging problem better and we can get more benefits rather than lost by above
> > > corner case but at least, I'd like to confirm what you think about
> > > above problem before further steps. Maybe we can introduce "mlock with
> > > newly-allocation or already-mapped page could be migrated to high memory zone"
> > > when someone reported out? (we thougt mlocked page migration would be problem
> > > RT latency POV but Peter confirmed it's no problem.)
> > 
> > And you think increasing lowmem reserves would be overkill? ;-)
> 
> If possible, I would like to avoid. ;-)
> 
> Peak workload : 800M average workload : 100M 
> int foo[800M] vs int *bar = malloc(800M);
> 
> > 
> > These patches fix real page aging problems.  Making trade offs to work
> 
> Indeed!
> 
> > properly on as many setups as possible is one thing, but a highmem
> > configuration where you need exactly 100% of lowmem and mlock 100% of
> > highmem?
> 
> Nope. Apprently, I don't know.
> I just wanted to record that we should already cover such claims
> in review phase so that if such problem happens in future, we can answer
> easily "Just rasise your lowmem reserve ratio because you have been
> depends on the luck until now". And I don't want to argue with other mm
> guys such solution in future again.

That's fair enough.

I would definitely suggest increasing the lowmem reserves in that case
but I don't expect anybody to actually rely on the exact placement on
a pristine system.  Not for performance, much less for _correctness_.

> I think as reviewer, it's enough as it is.
> 
> All three patches,
> 
> Reviewed-by: Minchan Kim <minchan@kernel.org>

Thank you very much!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
