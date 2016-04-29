Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 490496B0263
	for <linux-mm@kvack.org>; Fri, 29 Apr 2016 05:29:07 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r12so14792489wme.0
        for <linux-mm@kvack.org>; Fri, 29 Apr 2016 02:29:07 -0700 (PDT)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id h64si3025168wmf.112.2016.04.29.02.29.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 29 Apr 2016 02:29:05 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id 498B098913
	for <linux-mm@kvack.org>; Fri, 29 Apr 2016 09:29:05 +0000 (UTC)
Date: Fri, 29 Apr 2016 10:29:02 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH v2 0/6] Introduce ZONE_CMA
Message-ID: <20160429092902.GQ2858@techsingularity.net>
References: <1461561670-28012-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20160425053653.GA25662@js1304-P5Q-DELUXE>
 <20160428103927.GM2858@techsingularity.net>
 <20160429065145.GA19896@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160429065145.GA19896@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Apr 29, 2016 at 03:51:45PM +0900, Joonsoo Kim wrote:
> Hello, Mel.
> 
> IIUC, you may miss that alloc_contig_range() currently does linear
> reclaim/migration. Your comment is largely based on this
> misunderstanding so please keep it in your mind when reading the
> reply.
> 

Ok, you're right but if anything this moves heavier *against* the zone.
If linear reclaim is not able to work at the moment due to pinned pages
then how is a zone going to help in the slightest?

If pages cannot be directly reclaimed then no amount of moving the pages
into a separate zone and teaching kswapd new tricks is going to change
whether those pages can be reclaimed or not. At best, it alters the
timing of when problems occur.

If this is partially about kswapd waking up to reclaim pages suitable for
atomic allocations then the classzone_idx handling of kswapd needs to be
improved. It was very haphazard although improved slightly recently. The
node-lru series attempts to improve it further.

> On Thu, Apr 28, 2016 at 11:39:27AM +0100, Mel Gorman wrote:
> > On Mon, Apr 25, 2016 at 02:36:54PM +0900, Joonsoo Kim wrote:
> > > > Hello,
> > > > 
> > > > Changes from v1
> > > > o Separate some patches which deserve to submit independently
> > > > o Modify description to reflect current kernel state
> > > > (e.g. high-order watermark problem disappeared by Mel's work)
> > > > o Don't increase SECTION_SIZE_BITS to make a room in page flags
> > > > (detailed reason is on the patch that adds ZONE_CMA)
> > > > o Adjust ZONE_CMA population code
> > > > 
> > > > This series try to solve problems of current CMA implementation.
> > > > 
> > > > CMA is introduced to provide physically contiguous pages at runtime
> > > > without exclusive reserved memory area. But, current implementation
> > > > works like as previous reserved memory approach, because freepages
> > > > on CMA region are used only if there is no movable freepage. In other
> > > > words, freepages on CMA region are only used as fallback. In that
> > > > situation where freepages on CMA region are used as fallback, kswapd
> > > > would be woken up easily since there is no unmovable and reclaimable
> > > > freepage, too. If kswapd starts to reclaim memory, fallback allocation
> > > > to MIGRATE_CMA doesn't occur any more since movable freepages are
> > > > already refilled by kswapd and then most of freepage on CMA are left
> > > > to be in free. This situation looks like exclusive reserved memory case.
> > > > 
> > 
> > My understanding is that this was intentional. One of the original design
> > requirements was that CMA have a high likelihood of allocation success for
> > devices if it was necessary as an allocation failure was very visible to
> > the user. It does not *have* to be treated as a reserve because Movable
> > allocations could try CMA first but it increases allocation latency for
> > devices that require it and it gets worse if those pages are pinned.
> 
> I know that it was design decision at that time when CMA isn't
> actively used. It is due to lack of experience and now situation is
> quite different. Most of embedded systems uses CMA with their own
> adaptation because utilization is too low. It makes system much
> slower and this is more likely than the case that device memory is
> required. Given the fact that they adapt their logic to utilize CMA
> much more and sacrifice latency, I think that previous design
> decision is wrong and we should go another way.
> 

Then slow path interleave between CMA and !CMA regions for movable
allocations. Moving to a zone now will temporarily work and fail again
when the fair zone allocation policy is removed.

> > 
> > > > In my experiment, I found that if system memory has 1024 MB memory and
> > > > 512 MB is reserved for CMA, kswapd is mostly woken up when roughly 512 MB
> > > > free memory is left. Detailed reason is that for keeping enough free
> > > > memory for unmovable and reclaimable allocation, kswapd uses below
> > > > equation when calculating free memory and it easily go under the watermark.
> > > > 
> > > > Free memory for unmovable and reclaimable = Free total - Free CMA pages
> > > > 
> > > > This is derivated from the property of CMA freepage that CMA freepage
> > > > can't be used for unmovable and reclaimable allocation.
> > > > 
> > 
> > Yes and also keeping it lightly utilised to reduce CMA allocation
> > latency and probability of failure.
> 
> As my experience about CMA, most of unacceptable failure (takes more
> than 3 sec) comes from blockdev pagecache. Even, it's not simple to
> check what is going on there when failure happen. ZONE_CMA uses
> different approach that it only takes the request with
> GFP_HIGHUSER_MOVABLE so blockdev pagecache cannot get in and
> probability of failure is much reduced.
> 

If ZONE_CMA is protected from blockdev allocations then it's altering the
problem in a different way. The utilisation of ZONE_CMA for such allocations
will be lower and while this may side-step some pinning issues it may be
the case that ZONE_CMA is underutilised depending on what the workload is.

> > > > Anyway, in this case, kswapd are woken up when (FreeTotal - FreeCMA)
> > > > is lower than low watermark and tries to make free memory until
> > > > (FreeTotal - FreeCMA) is higher than high watermark. That results
> > > > in that FreeTotal is moving around 512MB boundary consistently. It
> > > > then means that we can't utilize full memory capacity.
> > > > 
> > > > To fix this problem, I submitted some patches [1] about 10 months ago,
> > > > but, found some more problems to be fixed before solving this problem.
> > > > It requires many hooks in allocator hotpath so some developers doesn't
> > > > like it. Instead, some of them suggest different approach [2] to fix
> > > > all the problems related to CMA, that is, introducing a new zone to deal
> > > > with free CMA pages. I agree that it is the best way to go so implement
> > > > here. Although properties of ZONE_MOVABLE and ZONE_CMA is similar,
> > 
> > One of the issues I mentioned at LSF/MM is that I consider ZONE_MOVABLE
> > to be a mistake. Zones are meant to be about addressing limitations and
> > both ZONE_MOVABLE and ZONE_CMA violate that. When ZONE_MOVABLE was
> > introduced, it was intended for use with dynamically resizing the
> > hugetlbfs pool. It was competing with fragmentation avoidance at the
> > time and the community could not decide which approach was better so
> > both ended up being merged as they had different advantages and
> > disadvantages.
> > 
> > Now, ZONE_MOVABLE is being abused -- memory hotplug was a particular mistake
> > and I don't want to see CMA fall down the same hole. Both CMA and memory
> > hotplug would benefit from the notion of having "sticky" MIGRATE_MOVABLE
> > pageblocks that are never used for UNMOVABLE and RECLAIMABLE fallbacks.
> > It costs to detect that in the slow path but zones cause their own problems.
> 
> Please elaborate more concrete reasons that you think why ZONE_MOVABLE
> is a mistake. Simply saying that zones are meant to be about address
> limitations doesn't make sense. Moreover, I think that this original
> purpose of zone could be changed if needed. It was introduced for that
> purpose but time goes by a lot. We have different requirement now and
> zone is suitable to handle this new requirement. And, if we think
> address limitation more generally, it can be considered as different
> characteristic memory problem. Zone is introduced to handle this
> situation and that's what new CMA implementation needs.
> 

ZONE_MOVABLE is a mistake because it reintroduces a variation of
lowmem/highmem problems when aggressively used. Memory hotplug is a good
example when memory is only added to the movable zone. All kernel allocations
and page tables then use a limited amount of memory triggering premature
reclaim. In extreme cases, the allocations simply fail as no !ZONE_MOVABLE is
available or can be reclaimed even though plenty of memory is free overall.

A slightly different problem is page age inversion. Movable allocations
in ZONE_MOVABLE get artifical protection versus pages in lower zones
when zones are imbalanced. kswapd reclaims from lowest to highest zones
where allocations use higher zones to lower zones. Under memory pressure,
newer pages from lower zones are potentially reclaimed before old pages
in higher zones. This is highly workload-dependant and it's mitigated
somewhat by fair zone interleaving but it's an issue.

> > > > 1) Utilization problem
> > > > As mentioned above, we can't utilize full memory capacity due to the
> > > > limitation of CMA freepage and fallback policy. This patchset implements
> > > > a new zone for CMA and uses it for GFP_HIGHUSER_MOVABLE request. This
> > > > typed allocation is used for page cache and anonymous pages which
> > > > occupies most of memory usage in normal case so we can utilize full
> > > > memory capacity. Below is the experiment result about this problem.
> > > > 
> > 
> > A zone is not necessary for that. Currently a zone would have a side-benefit
> 
> Agreed that a zone isn't necessary for it. I also tried the approach
> interleaving within a normal zone about two years ago, and, because
> there are more remaining problems and it needs more hook in many
> placees, people doesn't like it. You can see implementation in below link.
> 
> https://lkml.org/lkml/2014/5/28/64
> 
> 
> > from the fair zone allocation policy because it would interleave between
> > ZONE_CMA and ZONE_MOVABLE. However, the intention is to remove that policy
> > by moving LRUs to the node. Once that happens, the interleaving benefit
> > is lost and you're back to square one.
> > 
> > There may be some justification for interleaving *only* between MOVABLE and
> > MOVABLE_STICKY for CMA allocations and hiding that behind both a CONFIG_CMA
> > guard *and* a check if there a CMA region exists. It'd still need
> > something like the BATCH vmstat but it would only be updated when CMA is
> > active and hide it from the fast paths.
> 
> And, please don't focus on interleaving allocation problem. Main
> problem I'd like to solve is the utilization problem and interleaving
> is optional benefit from fair zone policy.

The stated  issue is that "we can't utilize full memory capacity due to
the limitation of CMA freepage and fallback policy.". Adding a zone still
has a fallback policy that forbids UNMOVABLE and RECLAIMABLE allocations
(or if it doesn't, it completely breaks the concept of CMA). If you intend
to restrict what MOVABLE allocations use ZONE_CMA then the utilisation
problem still exists.

> > > > 2) Reclaim problem
> > > > Currently, there is no logic to distinguish CMA pages in reclaim path.
> > > > If reclaim is initiated for unmovable and reclaimable allocation,
> > > > reclaiming CMA pages doesn't help to satisfy the request and reclaiming
> > > > CMA page is just waste. By managing CMA pages in the new zone, we can
> > > > skip to reclaim ZONE_CMA completely if it is unnecessary.
> > > > 
> > 
> > This problem will recur with node-lru. However, that said CMA reclaim is
> 
> Yes, it will. But, it will also happen on ZONE_HIGHMEM if we use
> node-lru. What's your plan to handle this issue? Because you cannot
> remove ZONE_HIGHMEM, you need to handle it properly and that way would
> naturally work well for ZONE_CMA as well.
> 

For highmem configurations, allocation requests that require lower zones skip
the highmem pages. This means that configurations with a large highmem/lowmem
ratio will have to scan more pages for skipping with higher CPU usage. The
thinking behind it is that configurations with large configurations are
already sub-optimal. It made some sense when 32-bit CPUs dominated in
large memory configurations but not 10+ years later.

> > currently depending on randomly reclaiming followed by compaction. This is
> > both slow and inefficient. CMA and alloc_contig_range() should strongly
> > consider isolation pages with a PFN walk of the CMA regions and directly
> > reclaiming those pages. Those pages may need to be refaulted in but the
> > priority is for the allocation to succeed. That would side-step the issues
> > with kswapd scanning the wrong zones.
> 
> I think that you are confused now. alloc_contig_range() already uses
> PFN walk on the CMA regions and directly reclaim/migration those
> pages. There is no randomly reclaim/migration here.
> 

Fine, then what exactly does a zone solve? Because if you linearly scan
a CMA region and that fails then how does putting those pages into a
separate zone fix the scanning?

> > > > 3) Atomic allocation failure problem
> > > > Kswapd isn't started to reclaim pages when allocation request is movable
> > > > type and there is enough free page in the CMA region. After bunch of
> > > > consecutive movable allocation requests, free pages in ordinary region
> > > > (not CMA region) would be exhausted without waking up kswapd. At that time,
> > > > if atomic unmovable allocation comes, it can't be successful since there
> > > > is not enough page in ordinary region. This problem is reported
> > > > by Aneesh [4] and can be solved by this patchset.
> > > > 
> > 
> > Not necessarily as kswapd curently would still reclaim from the lower
> > zones unnecessarily. Again, targetting the pages required for the CMA
> > allocation would side-step the issue. The actual core code of lumpy reclaim
> > was quite small.
> 
> You may be confused here, too.  Maybe, I misunderstand what you say
> here so please correct me if I'm missing something. First, let me
> clarify the problem.
> 
> It's not the issue when calling alloc_contig_range(). It is the issue
> when MM manages (allocate/reclaim) pages on CMA area when they are not
> used by device now.
> 
> The problem is that kswapd isn't woken up properly due to non-accurate
> watermark check.

Then fix the classzone idx handling in kswapd and in the watermark check so
that it wakes up and reclaims. The handling of classzone_idx in kswapd is
hap-hazard. It has improved a little recently, the node-lru series tries
to clean it up a bit more.

> When we do watermark check, number of freepage is
> varied depending on allocation type. Non-movable allocation subtracts
> number of CMA freepages from total freepages. In other words, we adds
> number of CMA freepages to number of normal freepages when movable
> allocation is requested. Problem comes from here. While we handle
> bunch of movable allocation, we can't notice that there is not enough
> freepage in normal area because we adds up number of CMA freepages and
> watermark looks safe. In this case, kswapd would not be woken up. If
> atomic allocation suddenly comes in this situation, freepage in normal
> area could be low and atomic allocation can fail.
> 

And moving to a zone doesn't necessarily fix that. If the CMA zone is
preserved as long as possible, the requests fill the lower zone and the
atomic allocation fails. If the policy is to use the CMA region first then
it does not matter if it's in a separate zone or not as the region used
for atomic allocations is untouched as long as possible.

> This is a really good example that comes from the fact that different
> types of pages are in a single zone. As I mentioned in other places,
> it's really error-prone design and handling it case by case is very fragile.
> Current long lasting problems about CMA is caused by this design
> decision and we need to change it.
> 
> > > > 4) Inefficiently work of compaction
> > > > Usual high-order allocation request is unmovable type and it cannot
> > > > be serviced from CMA area. In compaction, migration scanner doesn't
> > > > distinguish migratable pages on the CMA area and do migration.
> > > > In this case, even if we make high-order page on that region, it
> > > > cannot be used due to type mismatch. This patch will solve this problem
> > > > by separating CMA pages from ordinary zones.
> > > > 
> > 
> > Compaction problems are actually compounded by introducing ZONE_CMA as
> > it only compacts within the zone. Compaction would need to know how to
> > compact within a node to address the introduction of ZONE_CMA.
> > 
> 
> I'm not sure what you'd like to say here. What I meant is following
> situation. Capital letter means pageblock type. (C:MIGRATE_CMA,
> M:MIGRATE_MOVABLE). F means freed pageblock due to compaction.
> 
> CCCCCMMMM
> 
> If compaction is invoked to make unmovable high order freepage,
> compaction would start to work. It empties front part of the zone and
> migrate them to rear part of the zone. High order freepages are made
> on front part of the zone and it may look like as following.
> 
> FFFCCMMMM
> 
> But, they are on CMA pageblock so it cannot be used to satisfy unmovable
> high order allocation. Freepages on CMA pageblock isn't allocated for
> unmovable allocation request. That is what I'd like to say here.
> We can fix it by adding corner case handling at some place but
> this kind of corner case handling is not what I want. It's not
> maintainable. It comes from current design decision (MIGRATE_CMA) and
> we need to change the situation.
> 

The corner case may be necessary to skip MIGRATE_CMA pageblocks during
compaction if the caller is !MOVABLE and !CMA. I know it's a corner case but
it would alleviate this concern without creating new zones. Similar logic
could then be used by memory hotplug so it can get away from ZONE_MOVABLE.

> > > The fact
> > > that pages under I/O cannot be moved is also the problem of all CMA
> > > approaches. It is just separate issue and should not affect the decision
> > > on ZONE_CMA.
> > 
> > While it's a separate issue, it's also an important one. A linear reclaim
> > of a CMA region would at least be able to clearly identify pages that are
> > pinned in that region. Introducing the zone does not help the problem.
> 
> I know that it's important. ZONE_CMA may not help the problem but
> it is also true for other approaches. They also doesn't help the
> problem. It's why I said it is a separate issue. I'm not sure what you
> mean as linear reclaim here but separate zone will make easy to adapt
> different reclaim algorithm if needed.
> 
> Although it's separate issue, I should mentioned one thing. Related to
> I/O pinning issue, ZONE_CMA don't get blockdev allocation request so
> I/O pinning problem is much reduced.
> 

This is not super-clear from the patch. blockdev is using GFP_USER so it
already should not be classed as MOVABLE. I could easily be looking in
the wrong place or missed which allocation path sets GFP_MOVABLE.

> > What I was proposing at LSF/MM was the following;
> > 
> > 1. Create the notion of a sticky MIGRATE_MOVABLE type.
> >    UNMOVABLE and RECLAIMABLE cannot fallback to these regions. If a sticky
> >    region exists then the fallback code will need additional checks
> >    in the slow path. This is slow but it's the cost of protection
> 
> First of all, I can't understand what is different between ZONE_CMA
> and sticky MIGRATE_MOVABLE. We already did it for MIGRATE_CMA and it
> is proved as error-prone design. #1 seems to be core concept of sticky
> MIGRATE_MOVABLE and I cannot understand difference between them.
> Please elaborate more on difference between them.
> 

Sticky MIGRATE_MOVABLE does not worry about potential zones overlapping
It does not further fuzzy what a zone is meant to be for -- address
	limtations which MIGRATE_MOVABLE also violates
It does not require a separate zone with potential page age inversion issues
It does not require addiitonal memory footprint for per-cpu allocation,
	page lock waitqueues and accounting
In the current reclaim implementation, it does not require zone
	balancing tricks although that concern goes away with node-lru.

Some of this overlaps with the problems ZONE_MOVABLE has.

> > 4. Interleave MOVABLE and sticky MOVABLE if desired
> >    This would be in the fallback paths only and be specific to CMA. This
> >    would alleviate the utilisation problems while not impacting the fast
> >    paths for everyone else. Functionally it would be similar to the fair
> >    zone allocation policy which is currently in the fast path and scheduled
> >    for removal.
> 
> Interleaving can be implement in any case if desired. At least now, thanks
> to zone fair policy, ZONE_CMA would get benefit of interleaving.

For maybe one release if things go according to plan.

> Overall, I do not see any advantage of sticky MIGRATE_MOVABLE design
> at least now. Main reason is that ZONE_CMA is introduced to replace
> MIGRATE_CMA which is conceptually same with your sticky
> MIGRATE_MOVABLE proposal. It doesn't solve any issues mentioned here
> and we should not repeat same mistake again.
> 

ZONE_MOVABLE in itself was a mistake, particularly when it was used for
memory hotplug "guaranteeing" that memory could be removed. I'm not going to
outright NAK your series but I won't ACK it either. Zones come with their own
class of problems and I suspect that CMA will still be having discussions on
utilisation and reliability problems in the future even if the zone is added.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
