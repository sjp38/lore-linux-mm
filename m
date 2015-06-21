Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 171B86B0032
	for <linux-mm@kvack.org>; Sun, 21 Jun 2015 10:04:39 -0400 (EDT)
Received: by wgwi7 with SMTP id i7so2438528wgw.0
        for <linux-mm@kvack.org>; Sun, 21 Jun 2015 07:04:38 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fp5si14847143wib.85.2015.06.21.07.04.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 21 Jun 2015 07:04:37 -0700 (PDT)
Date: Sun, 21 Jun 2015 15:04:33 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH 00/25] Move LRU page reclaim from zones to nodes
Message-ID: <20150621140433.GD11809@suse.de>
References: <1433771791-30567-1-git-send-email-mgorman@suse.de>
 <20150619170139.GA11316@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150619170139.GA11316@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jun 19, 2015 at 01:01:39PM -0400, Johannes Weiner wrote:
> Hi Mel,
> 
> these are cool patches, I very much like the direction this is headed.
> 
> On Mon, Jun 08, 2015 at 02:56:06PM +0100, Mel Gorman wrote:
> > This is an RFC series against 4.0 that moves LRUs from the zones to the
> > node. In concept, this is straight forward but there are a lot of details
> > so I'm posting it early to see what people think. The motivations are;
> > 
> > 1. Currently, reclaim on node 0 behaves differently to node 1 with subtly different
> >    aging rules. Workloads may exhibit different behaviour depending on what node
> >    it was scheduled on as a result.
> 
> How so?  Don't we ultimately age pages in proportion to node size,
> regardless of how many zones they are broken into?
> 

For example, direct reclaim scans in zonelist order (highest eligible zone
first) and stops when SWAP_CLUSTER_MAX pages are reclaimed which could be
entirely from one zone. The fair zone policy limits age inversion problems
but it's still different to what happens when direct reclaim starts on a
node with one populated zone.

kswapd will not reclaim from the highest zone if it's already balanced. If
the distribution of anon/file pages differs between zones due to when they
were allocated then it's slightly different.

I expect in most cases that it makes little difference but moving to
node-base reclaim gets rid of some of these differences.

> > 2. The residency of a page partially depends on what zone the page was
> >    allocated from.  This is partially combatted by the fair zone allocation
> >    policy but that is a partial solution that introduces overhead in the
> >    page allocator paths.
> 
> Yeah, it's ugly and I'm happy you're getting rid of this again.  That
> being said, in my tests it seemed like a complete solution to remove
> any influence from allocation placement on aging behavior.  Where do
> you still see aging artifacts?
> 

I actually have not created an artifical test case that games the fair
zone allocation policy and I expect in almost all cases that the fair zone
allocation policy is adequate. It's just not necessary if we reclaim on
a per-node basis.

> > 3. kswapd and the page allocator play special games with the order they scan zones
> >    to avoid interfering with each other but it's unpredictable.
> 
> It would be good to recall here these interference issues, how they
> are currently coped with, and how your patches address them.
> 

It is coped with by having kswapd reclaim in the opposite order that the
page allocator prefers. This prevents the allocator always reusing pages
reclaimed by kswapd recently. It's not handled at all with direct reclaim
as it reclaims in zonelist order. With the patches it should be simply
unnecessary to avoid this problem as pages are reclaimed in the order of
their age unless the caller requires a page from a low zone.

> > 4. The different scan activity and ordering for zone reclaim is very difficult
> >    to predict.
> 
> I'm not sure what this means.
> 

The order that pages get reclaimed in partially depends on when allocataions
push a zone below a watermark. The time that kswapd examines a zone versus
the page allocator matters more than it should.

> > 5. slab shrinkers are node-based which makes relating page reclaim to
> >    slab reclaim harder than it should be.
> 
> Agreed.  And I'm sure dchinner also much prefers moving the VM towards
> a node model over moving the shrinkers towards the zone model.
> 
> > The reason we have zone-based reclaim is that we used to have
> > large highmem zones in common configurations and it was necessary
> > to quickly find ZONE_NORMAL pages for reclaim. Today, this is much
> > less of a concern as machines with lots of memory will (or should) use
> > 64-bit kernels. Combinations of 32-bit hardware and 64-bit hardware are
> > rare. Machines that do use highmem should have relatively low highmem:lowmem
> > ratios than we worried about in the past.
> > 
> > Conceptually, moving to node LRUs should be easier to understand. The
> > page allocator plays fewer tricks to game reclaim and reclaim behaves
> > similarly on all nodes.
> 
> Do you think it's feasible to serve the occasional address-restricted
> request from CMA, or a similar mechanism based on PFN ranges?

I worried that it would get very expensive as we would have to search the
free lists to find a page of the correct address. If one is not found then we
have to reclaim based on PFN ranges and then retry. Each address-restricted
allocation would have to retry the search. Potentially we could use migrate
types to prevent a percentage of the lower zones being used for unmovable
allocations but we'd still have to do the search.

> In the
> longterm, it would be great to eradicate struct zone entirely, and
> have the page allocator and reclaim talk about the same thing again
> without having to translate back and forth between zones and nodes.
> 

I agree it would be great in the long term. I don't see how it could be
done now but that is partially because node-based reclaim alone is a big
set of changes.


> It would also be much better for DMA allocations that don't align with
> the zone model, such as 31-bit address requests, which currently have
> to play the lottery with GFP_DMA32 and fall back to GFP_DMA.
> 

Also true. Maybe it would be a reserve-based mechanism and subsystems
register their requirements and then use a mempool-like mechanism to limit
searching. It certainly would be worth examining if/when node-based reclaim
gets ironed out and we are confident that there are no regressions.

> > It was tested on a UMA (8 cores single socket) and a NUMA machine (48 cores,
> > 4 sockets). The page allocator tests showed marginal differences in aim9,
> > page fault microbenchmark, page allocator micro-benchmark and ebizzy. This
> > was expected as the affected paths are small in comparison to the overall
> > workloads.
> > 
> > I also tested using fstest on zero-length files to stress slab reclaim. It
> > showed no major differences in performance or stats.
> > 
> > A THP-based test case that stresses compaction was inconclusive. It showed
> > differences in the THP allocation success rate and both gains and losses in
> > the time it takes to allocate THP depending on the number of threads running.
> 
> It would useful to include a "reasonable" highmem test here as well.
> 

I think something IO-intensive with a large highmem zone would do the job.

> > Tests did show there were differences in the pages allocated from each zone.
> > This is due to the fact the fair zone allocation policy is removed as with
> > node-based LRU reclaim, it *should* not be necessary. It would be preferable
> > if the original database workload that motivated the introduction of that
> > policy was retested with this series though.
> 
> It's as simple as repeatedly reading a file that is ever-so-slightly
> bigger than the available memory.  The result should be a perfect
> tail-chasing scenario, with the entire file being served from disk
> every single time.  If parts of it get activated, that is a problem,
> because it means that some pages get aged differently than others.
> 

Ok, that is trivial to put together.

> When I worked on the fair zone allocator, I hacked mincore() to report
> PG_active, to be extra sure about where the pages of interest are, but
> monitoring pgactivate during the test, or comparing its deltas between
> kernels, should be good enough.

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
