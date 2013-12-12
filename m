Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f178.google.com (mail-ea0-f178.google.com [209.85.215.178])
	by kanga.kvack.org (Postfix) with ESMTP id E86426B0037
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 08:18:26 -0500 (EST)
Received: by mail-ea0-f178.google.com with SMTP id d10so234699eaj.9
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 05:18:26 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id h45si23655815eeo.25.2013.12.12.05.18.25
        for <linux-mm@kvack.org>;
        Thu, 12 Dec 2013 05:18:25 -0800 (PST)
Date: Thu, 12 Dec 2013 13:18:21 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch] mm: page_alloc: exclude unreclaimable allocations from
 zone fairness policy
Message-ID: <20131212131821.GF11295@suse.de>
References: <1386785356-19911-1-git-send-email-hannes@cmpxchg.org>
 <20131211224719.GE11295@suse.de>
 <20131212010903.GP21724@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20131212010903.GP21724@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Dec 11, 2013 at 08:09:03PM -0500, Johannes Weiner wrote:
> On Wed, Dec 11, 2013 at 10:47:19PM +0000, Mel Gorman wrote:
> > On Wed, Dec 11, 2013 at 01:09:16PM -0500, Johannes Weiner wrote:
> > > Dave Hansen noted a regression in a microbenchmark that loops around
> > > open() and close() on an 8-node NUMA machine and bisected it down to
> > > 81c0a2bb515f ("mm: page_alloc: fair zone allocator policy").  That
> > > change forces the slab allocations of the file descriptor to spread
> > > out to all 8 nodes, causing remote references in the page allocator
> > > and slab.
> > > 
> > 
> > The original patch was primarily concerned with the fair aging of LRU pages
> > of zones within a node. This patch uses GFP_MOVABLE_MASK which includes
> > __GFP_RECLAIMABLE meaning any slab created with SLAB_RECLAIM_ACCOUNT is still
> > getting the round-robin treatment. Those pages have a different lifecycle
> > to LRU pages and the shrinkers are only node aware, not zone aware.
> > While I get this patch probably helps this specific benchmark, was the
> > use of GFP_MOVABLE_MASK intentional or did you mean to use __GFP_MOVABLE?
> 
> It was intentional to spread SLAB_RECLAIM_ACCOUNT pages across all
> allowed nodes evenly for the same aging fairness reason.
> 

That could be argued either way and ultimately it'll come down to being
workload dependant.

> > Looking at the original patch again I think I made a major mistake when
> > reviewing it. Considering the effect of the following for NUMA machines
> > 
> >         for_each_zone_zonelist_nodemask(zone, z, zonelist,
> >                                                 high_zoneidx, nodemask) {
> > 		....
> >                 if (alloc_flags & ALLOC_WMARK_LOW) {
> >                         if (zone_page_state(zone, NR_ALLOC_BATCH) <= 0)
> > 				continue;
> >                         if (zone_reclaim_mode &&
> >                             !zone_local(preferred_zone, zone))
> >                                 continue;
> > 		}
> > 
> > 
> > Enabling zone_reclaim_mode sucks badly for workloads that are not paritioned
> > to fit within NUMA nodes. Consequently, I expect the common case it that
> > it's disabled by default due to small NUMA distances or manually disabled.
> > 
> > However, the effect of that block is that we allocate NR_ALLOC_BATCH
> > from local zones then fallback to batch allocating remote nodes! I bet
> > the numa_hit stats in /proc/vmstat have sucked recently. The original
> > problem was because the page allocator would try allocating from the
> > highest zone while kswapd reclaimed from it causing LRU-aging problems.
> > The problem is not the same between nodes. How do you feel about dropping
> > the zone_reclaim_mode check above and only round-robin in batches between
> > zones on the local node?
> 
> It might not be for anon but it's the same problem for cache.  The
> page allocator will fill all the nodes in the system before waking up
> the kswapds.  It will utilize all nodes, just not evenly.
> 

Which is a definite remote allocation penalty now versus a potential page
aging inversion problem later. That's a shitty tradeoff.

> I know that on the node-level staying local is often preferrable over
> full memory utilization but I was under the assumption that
> zone_reclaim_mode is there to express this preference.
> 

It's the expected behaviour of MPOL_LOCAL and the original patch significant
altered default behaviour that should have been flagged. The zone_relaim_mode
tunable has nasty side effects for workloads that are not partitioned to
fit within a NUMA node. I blame myself here because that patch should have
sent off klaxons but I was blinded by those lovely performance figures.

> My patch certainly makes this preference more aggressive in the sense
> that there is no grayzone anymore.  There is no try to stay local.

Which automatic NUMA balancing then comes in and stomps all over.

> There is either not using a block of memory at all, or using it to the
> same extent as any other block of the same size; that's the
> requirement for fair aging.
> 
> That being said, the fairness concerns are primarily about file pages.
> Should we exclude anon and slab pages entirely? 

File pages would certainly be the most noticeable. We may not want to
prematurely discard clean pages because of the IO costs of brining them
back in and the other penalties for example. Unfortunately, there is not
a reliable way to distinguish between these type of pages from allocator
context, we'd need another GFP flag. At least, an obvious method did not
immediately print to mind.

Without or without that flag, deciding how to treat them would lead to a
lot of hand waving and bullshit. I'll put together a small series that
makes this configurable and set what I think are sensible defaults and
we can figure out the way forward on that basis.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
