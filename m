Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id D70BD6B007E
	for <linux-mm@kvack.org>; Mon,  2 May 2016 02:14:05 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id u185so337306214oie.3
        for <linux-mm@kvack.org>; Sun, 01 May 2016 23:14:05 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id j27si5806119ioo.204.2016.05.01.23.14.03
        for <linux-mm@kvack.org>;
        Sun, 01 May 2016 23:14:04 -0700 (PDT)
Date: Mon, 2 May 2016 15:14:23 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 0/6] Introduce ZONE_CMA
Message-ID: <20160502061423.GA31646@js1304-P5Q-DELUXE>
References: <1461561670-28012-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20160425053653.GA25662@js1304-P5Q-DELUXE>
 <20160428103927.GM2858@techsingularity.net>
 <20160429065145.GA19896@js1304-P5Q-DELUXE>
 <20160429092902.GQ2858@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160429092902.GQ2858@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello, Mel.

Before answering other questions, I'd like to say something first.
ZONE_CMA isn't necessarily to fix the issues. We can fix with other
approaches. The reason I like the ZONE_CMA is that it doesn't need
to handle corner cases. MM already deal with different types of memory
such as highmem by using a zone. ZONE_CMA is the same case so I'd like
to utilized exsting infrastructure that works well currently. At least,
ZONE_CMA approach can share corner case handling with highmem handling
code so it would be less error-prone and can be widely tested. Please
refer patch 4 and 5. It removes a lot of corner case handling. If we
don't use ZONE_CMA, we need more corner case handling code and it's
not desirable and error-prone.

Unique strong point of ZONE_CMA is accurate statistics. Given that
current various problem comes from incorrect statistics, it seems
to be enough merit to go this way. Anyway, I will answer your comment
inline.


On Fri, Apr 29, 2016 at 10:29:02AM +0100, Mel Gorman wrote:
> On Fri, Apr 29, 2016 at 03:51:45PM +0900, Joonsoo Kim wrote:
> > Hello, Mel.
> > 
> > IIUC, you may miss that alloc_contig_range() currently does linear
> > reclaim/migration. Your comment is largely based on this
> > misunderstanding so please keep it in your mind when reading the
> > reply.
> > 
> 
> Ok, you're right but if anything this moves heavier *against* the zone.
> If linear reclaim is not able to work at the moment due to pinned pages
> then how is a zone going to help in the slightest?

Introducing a zone isn't aimed at helping device memory allocation
through alloc_contig_range(). It's purpose is to help MM
(allocation/reclaim) when these memory are not used by device.

> If pages cannot be directly reclaimed then no amount of moving the pages
> into a separate zone and teaching kswapd new tricks is going to change
> whether those pages can be reclaimed or not. At best, it alters the
> timing of when problems occur.

I'm not sure that I understand what you mean here. If I misunderstand,
please elaborate more. alloc_contig_range() uses
alloc_migrate_target() and it then calls alloc_page(). If we can get
the freepages from it, we can move the pages into a separate zone.
There is no need to teach kswapd new trick.

> If this is partially about kswapd waking up to reclaim pages suitable for
> atomic allocations then the classzone_idx handling of kswapd needs to be
> improved. It was very haphazard although improved slightly recently. The
> node-lru series attempts to improve it further.
> 
> > On Thu, Apr 28, 2016 at 11:39:27AM +0100, Mel Gorman wrote:
> > > On Mon, Apr 25, 2016 at 02:36:54PM +0900, Joonsoo Kim wrote:
> > > > > Hello,
> > > > > 
> > > > > Changes from v1
> > > > > o Separate some patches which deserve to submit independently
> > > > > o Modify description to reflect current kernel state
> > > > > (e.g. high-order watermark problem disappeared by Mel's work)
> > > > > o Don't increase SECTION_SIZE_BITS to make a room in page flags
> > > > > (detailed reason is on the patch that adds ZONE_CMA)
> > > > > o Adjust ZONE_CMA population code
> > > > > 
> > > > > This series try to solve problems of current CMA implementation.
> > > > > 
> > > > > CMA is introduced to provide physically contiguous pages at runtime
> > > > > without exclusive reserved memory area. But, current implementation
> > > > > works like as previous reserved memory approach, because freepages
> > > > > on CMA region are used only if there is no movable freepage. In other
> > > > > words, freepages on CMA region are only used as fallback. In that
> > > > > situation where freepages on CMA region are used as fallback, kswapd
> > > > > would be woken up easily since there is no unmovable and reclaimable
> > > > > freepage, too. If kswapd starts to reclaim memory, fallback allocation
> > > > > to MIGRATE_CMA doesn't occur any more since movable freepages are
> > > > > already refilled by kswapd and then most of freepage on CMA are left
> > > > > to be in free. This situation looks like exclusive reserved memory case.
> > > > > 
> > > 
> > > My understanding is that this was intentional. One of the original design
> > > requirements was that CMA have a high likelihood of allocation success for
> > > devices if it was necessary as an allocation failure was very visible to
> > > the user. It does not *have* to be treated as a reserve because Movable
> > > allocations could try CMA first but it increases allocation latency for
> > > devices that require it and it gets worse if those pages are pinned.
> > 
> > I know that it was design decision at that time when CMA isn't
> > actively used. It is due to lack of experience and now situation is
> > quite different. Most of embedded systems uses CMA with their own
> > adaptation because utilization is too low. It makes system much
> > slower and this is more likely than the case that device memory is
> > required. Given the fact that they adapt their logic to utilize CMA
> > much more and sacrifice latency, I think that previous design
> > decision is wrong and we should go another way.
> > 
> 
> Then slow path interleave between CMA and !CMA regions for movable
> allocations. Moving to a zone now will temporarily work and fail again
> when the fair zone allocation policy is removed.

It can be, but, we need to think that what is better and maintainable.
If fair zone policy is removed, we would lose this interleaving
benefit, but, even in this case, both approach is on the same line.
Until your node lru work, ZONE_CMA is better than migratetype approach.

> > > 
> > > > > In my experiment, I found that if system memory has 1024 MB memory and
> > > > > 512 MB is reserved for CMA, kswapd is mostly woken up when roughly 512 MB
> > > > > free memory is left. Detailed reason is that for keeping enough free
> > > > > memory for unmovable and reclaimable allocation, kswapd uses below
> > > > > equation when calculating free memory and it easily go under the watermark.
> > > > > 
> > > > > Free memory for unmovable and reclaimable = Free total - Free CMA pages
> > > > > 
> > > > > This is derivated from the property of CMA freepage that CMA freepage
> > > > > can't be used for unmovable and reclaimable allocation.
> > > > > 
> > > 
> > > Yes and also keeping it lightly utilised to reduce CMA allocation
> > > latency and probability of failure.
> > 
> > As my experience about CMA, most of unacceptable failure (takes more
> > than 3 sec) comes from blockdev pagecache. Even, it's not simple to
> > check what is going on there when failure happen. ZONE_CMA uses
> > different approach that it only takes the request with
> > GFP_HIGHUSER_MOVABLE so blockdev pagecache cannot get in and
> > probability of failure is much reduced.
> > 
> 
> If ZONE_CMA is protected from blockdev allocations then it's altering the
> problem in a different way. The utilisation of ZONE_CMA for such allocations
> will be lower and while this may side-step some pinning issues it may be
> the case that ZONE_CMA is underutilised depending on what the workload is.

Yes. It is a trade-off of ZONE_CMA implementation. Given that file
cache pages and anon pages are used a lot in usual cases, this
trade-off that reducing failure probability makes sense.

> > > > > Anyway, in this case, kswapd are woken up when (FreeTotal - FreeCMA)
> > > > > is lower than low watermark and tries to make free memory until
> > > > > (FreeTotal - FreeCMA) is higher than high watermark. That results
> > > > > in that FreeTotal is moving around 512MB boundary consistently. It
> > > > > then means that we can't utilize full memory capacity.
> > > > > 
> > > > > To fix this problem, I submitted some patches [1] about 10 months ago,
> > > > > but, found some more problems to be fixed before solving this problem.
> > > > > It requires many hooks in allocator hotpath so some developers doesn't
> > > > > like it. Instead, some of them suggest different approach [2] to fix
> > > > > all the problems related to CMA, that is, introducing a new zone to deal
> > > > > with free CMA pages. I agree that it is the best way to go so implement
> > > > > here. Although properties of ZONE_MOVABLE and ZONE_CMA is similar,
> > > 
> > > One of the issues I mentioned at LSF/MM is that I consider ZONE_MOVABLE
> > > to be a mistake. Zones are meant to be about addressing limitations and
> > > both ZONE_MOVABLE and ZONE_CMA violate that. When ZONE_MOVABLE was
> > > introduced, it was intended for use with dynamically resizing the
> > > hugetlbfs pool. It was competing with fragmentation avoidance at the
> > > time and the community could not decide which approach was better so
> > > both ended up being merged as they had different advantages and
> > > disadvantages.
> > > 
> > > Now, ZONE_MOVABLE is being abused -- memory hotplug was a particular mistake
> > > and I don't want to see CMA fall down the same hole. Both CMA and memory
> > > hotplug would benefit from the notion of having "sticky" MIGRATE_MOVABLE
> > > pageblocks that are never used for UNMOVABLE and RECLAIMABLE fallbacks.
> > > It costs to detect that in the slow path but zones cause their own problems.
> > 
> > Please elaborate more concrete reasons that you think why ZONE_MOVABLE
> > is a mistake. Simply saying that zones are meant to be about address
> > limitations doesn't make sense. Moreover, I think that this original
> > purpose of zone could be changed if needed. It was introduced for that
> > purpose but time goes by a lot. We have different requirement now and
> > zone is suitable to handle this new requirement. And, if we think
> > address limitation more generally, it can be considered as different
> > characteristic memory problem. Zone is introduced to handle this
> > situation and that's what new CMA implementation needs.
> > 
> 
> ZONE_MOVABLE is a mistake because it reintroduces a variation of
> lowmem/highmem problems when aggressively used. Memory hotplug is a good
> example when memory is only added to the movable zone. All kernel allocations
> and page tables then use a limited amount of memory triggering premature
> reclaim. In extreme cases, the allocations simply fail as no !ZONE_MOVABLE is
> available or can be reclaimed even though plenty of memory is free overall.

This problem also happens even if we choose *sticky* MIGRATETYPE
approach. This problem doesn't come from implementation detail. It
comes from fundamental difference of attribute of the memory that we
can't use such memory for unmovable allocation.

> A slightly different problem is page age inversion. Movable allocations
> in ZONE_MOVABLE get artifical protection versus pages in lower zones
> when zones are imbalanced. kswapd reclaims from lowest to highest zones
> where allocations use higher zones to lower zones. Under memory pressure,
> newer pages from lower zones are potentially reclaimed before old pages
> in higher zones. This is highly workload-dependant and it's mitigated
> somewhat by fair zone interleaving but it's an issue.

Okay. But, it would be solved by you node lru work so would be no
problem?

> > > > > 1) Utilization problem
> > > > > As mentioned above, we can't utilize full memory capacity due to the
> > > > > limitation of CMA freepage and fallback policy. This patchset implements
> > > > > a new zone for CMA and uses it for GFP_HIGHUSER_MOVABLE request. This
> > > > > typed allocation is used for page cache and anonymous pages which
> > > > > occupies most of memory usage in normal case so we can utilize full
> > > > > memory capacity. Below is the experiment result about this problem.
> > > > > 
> > > 
> > > A zone is not necessary for that. Currently a zone would have a side-benefit
> > 
> > Agreed that a zone isn't necessary for it. I also tried the approach
> > interleaving within a normal zone about two years ago, and, because
> > there are more remaining problems and it needs more hook in many
> > placees, people doesn't like it. You can see implementation in below link.
> > 
> > https://lkml.org/lkml/2014/5/28/64
> > 
> > 
> > > from the fair zone allocation policy because it would interleave between
> > > ZONE_CMA and ZONE_MOVABLE. However, the intention is to remove that policy
> > > by moving LRUs to the node. Once that happens, the interleaving benefit
> > > is lost and you're back to square one.
> > > 
> > > There may be some justification for interleaving *only* between MOVABLE and
> > > MOVABLE_STICKY for CMA allocations and hiding that behind both a CONFIG_CMA
> > > guard *and* a check if there a CMA region exists. It'd still need
> > > something like the BATCH vmstat but it would only be updated when CMA is
> > > active and hide it from the fast paths.
> > 
> > And, please don't focus on interleaving allocation problem. Main
> > problem I'd like to solve is the utilization problem and interleaving
> > is optional benefit from fair zone policy.
> 
> The stated  issue is that "we can't utilize full memory capacity due to
> the limitation of CMA freepage and fallback policy.". Adding a zone still
> has a fallback policy that forbids UNMOVABLE and RECLAIMABLE allocations
> (or if it doesn't, it completely breaks the concept of CMA). If you intend
> to restrict what MOVABLE allocations use ZONE_CMA then the utilisation
> problem still exists.

What fallback policy in the stated issue means is that page allocator
provides  freepages on movable pageblock first and then provides
freepages on CMA pageblock. ZONE_CMA still forbids unmovable and reclaimable
allocations. It should be, because it is to satisfy the concept of
CMA. There is no change here. As I mentioned before, ZONE_CMA
implementation changes what MOVABLE allocation can be serviced by CMA
areas but it is reasonable trade-off and it doesn't matter at all.

> > > > > 2) Reclaim problem
> > > > > Currently, there is no logic to distinguish CMA pages in reclaim path.
> > > > > If reclaim is initiated for unmovable and reclaimable allocation,
> > > > > reclaiming CMA pages doesn't help to satisfy the request and reclaiming
> > > > > CMA page is just waste. By managing CMA pages in the new zone, we can
> > > > > skip to reclaim ZONE_CMA completely if it is unnecessary.
> > > > > 
> > > 
> > > This problem will recur with node-lru. However, that said CMA reclaim is
> > 
> > Yes, it will. But, it will also happen on ZONE_HIGHMEM if we use
> > node-lru. What's your plan to handle this issue? Because you cannot
> > remove ZONE_HIGHMEM, you need to handle it properly and that way would
> > naturally work well for ZONE_CMA as well.
> > 
> 
> For highmem configurations, allocation requests that require lower zones skip
> the highmem pages. This means that configurations with a large highmem/lowmem
> ratio will have to scan more pages for skipping with higher CPU usage. The
> thinking behind it is that configurations with large configurations are
> already sub-optimal. It made some sense when 32-bit CPUs dominated in
> large memory configurations but not 10+ years later.

This issue will not disappear even with *sticky* MIGRATETYPE approach.
There is no need to reclaim pages on CMA area in order to satisfy
allocation request that require unmovable (lower zones) memory.

And, in node lru implementation, I think that applying same solution
for highmem to ZONE_CMA would be okay because there would be no large
CMAmem/lowmem ratio system. CMAmem is originally introduced for device
memory and it's size would be much lower than system memory.

> > > currently depending on randomly reclaiming followed by compaction. This is
> > > both slow and inefficient. CMA and alloc_contig_range() should strongly
> > > consider isolation pages with a PFN walk of the CMA regions and directly
> > > reclaiming those pages. Those pages may need to be refaulted in but the
> > > priority is for the allocation to succeed. That would side-step the issues
> > > with kswapd scanning the wrong zones.
> > 
> > I think that you are confused now. alloc_contig_range() already uses
> > PFN walk on the CMA regions and directly reclaim/migration those
> > pages. There is no randomly reclaim/migration here.
> > 
> 
> Fine, then what exactly does a zone solve? Because if you linearly scan
> a CMA region and that fails then how does putting those pages into a
> separate zone fix the scanning?

Looks like that you are still confused. Linearly scan is used in
alloc_contig_range() which is only for device allocation. It's not
related to direct/kswapd reclaim and stated issue is the problem
during direct/kswapd reclaim.

Anyway, I try to explain how putting those pages into a separate zone
works for the problem. In shrink_zones() which is used for direct
reclaim, we only scan the zones that can met allocation request. If we
would be here for unmovable allocation, ZONE_CMA will not be scanned
since it cannot met unmovable allocation request.

kswapd also can benefit from this separation. Since kswapd doesn't use
any alloc_flag when checking the watermark, it will not count
freepages on CMA area so it would work to reclaim too much memory.
With a new zone, we don't need to provide precise alloc_flag,
ALLOC_CMA, to each watermark check because ZONE_CMA  has only one type
of memory and other zones has no CMA type memory.

> > > > > 3) Atomic allocation failure problem
> > > > > Kswapd isn't started to reclaim pages when allocation request is movable
> > > > > type and there is enough free page in the CMA region. After bunch of
> > > > > consecutive movable allocation requests, free pages in ordinary region
> > > > > (not CMA region) would be exhausted without waking up kswapd. At that time,
> > > > > if atomic unmovable allocation comes, it can't be successful since there
> > > > > is not enough page in ordinary region. This problem is reported
> > > > > by Aneesh [4] and can be solved by this patchset.
> > > > > 
> > > 
> > > Not necessarily as kswapd curently would still reclaim from the lower
> > > zones unnecessarily. Again, targetting the pages required for the CMA
> > > allocation would side-step the issue. The actual core code of lumpy reclaim
> > > was quite small.
> > 
> > You may be confused here, too.  Maybe, I misunderstand what you say
> > here so please correct me if I'm missing something. First, let me
> > clarify the problem.
> > 
> > It's not the issue when calling alloc_contig_range(). It is the issue
> > when MM manages (allocate/reclaim) pages on CMA area when they are not
> > used by device now.
> > 
> > The problem is that kswapd isn't woken up properly due to non-accurate
> > watermark check.
> 
> Then fix the classzone idx handling in kswapd and in the watermark check so
> that it wakes up and reclaims. The handling of classzone_idx in kswapd is
> hap-hazard. It has improved a little recently, the node-lru series tries
> to clean it up a bit more.

It can be fixed in this way but it's not desirable. It is error-prone
and we would easy to miss it in the future. Better solution would be
ZONE_CMA and discard root causes of this problem by correcting
statistics in any cases. In this way, we don't need to handle corner
cases, case by case, in various places.

> > When we do watermark check, number of freepage is
> > varied depending on allocation type. Non-movable allocation subtracts
> > number of CMA freepages from total freepages. In other words, we adds
> > number of CMA freepages to number of normal freepages when movable
> > allocation is requested. Problem comes from here. While we handle
> > bunch of movable allocation, we can't notice that there is not enough
> > freepage in normal area because we adds up number of CMA freepages and
> > watermark looks safe. In this case, kswapd would not be woken up. If
> > atomic allocation suddenly comes in this situation, freepage in normal
> > area could be low and atomic allocation can fail.
> > 
> 
> And moving to a zone doesn't necessarily fix that. If the CMA zone is
> preserved as long as possible, the requests fill the lower zone and the
> atomic allocation fails. If the policy is to use the CMA region first then
> it does not matter if it's in a separate zone or not as the region used
> for atomic allocations is untouched as long as possible.

With any policy, ZONE_CMA would work fine. If lower zone is
filled, kswapd is woken up at appropriate moment and it would make
room for atomic allocation. It is not necessarily fixed by a new zone
but other approach lead to insert one or more hooks at some places and
it's error-prone like as current situation.

> > This is a really good example that comes from the fact that different
> > types of pages are in a single zone. As I mentioned in other places,
> > it's really error-prone design and handling it case by case is very fragile.
> > Current long lasting problems about CMA is caused by this design
> > decision and we need to change it.
> > 
> > > > > 4) Inefficiently work of compaction
> > > > > Usual high-order allocation request is unmovable type and it cannot
> > > > > be serviced from CMA area. In compaction, migration scanner doesn't
> > > > > distinguish migratable pages on the CMA area and do migration.
> > > > > In this case, even if we make high-order page on that region, it
> > > > > cannot be used due to type mismatch. This patch will solve this problem
> > > > > by separating CMA pages from ordinary zones.
> > > > > 
> > > 
> > > Compaction problems are actually compounded by introducing ZONE_CMA as
> > > it only compacts within the zone. Compaction would need to know how to
> > > compact within a node to address the introduction of ZONE_CMA.
> > > 
> > 
> > I'm not sure what you'd like to say here. What I meant is following
> > situation. Capital letter means pageblock type. (C:MIGRATE_CMA,
> > M:MIGRATE_MOVABLE). F means freed pageblock due to compaction.
> > 
> > CCCCCMMMM
> > 
> > If compaction is invoked to make unmovable high order freepage,
> > compaction would start to work. It empties front part of the zone and
> > migrate them to rear part of the zone. High order freepages are made
> > on front part of the zone and it may look like as following.
> > 
> > FFFCCMMMM
> > 
> > But, they are on CMA pageblock so it cannot be used to satisfy unmovable
> > high order allocation. Freepages on CMA pageblock isn't allocated for
> > unmovable allocation request. That is what I'd like to say here.
> > We can fix it by adding corner case handling at some place but
> > this kind of corner case handling is not what I want. It's not
> > maintainable. It comes from current design decision (MIGRATE_CMA) and
> > we need to change the situation.
> > 
> 
> The corner case may be necessary to skip MIGRATE_CMA pageblocks during
> compaction if the caller is !MOVABLE and !CMA. I know it's a corner case but
> it would alleviate this concern without creating new zones. Similar logic
> could then be used by memory hotplug so it can get away from ZONE_MOVABLE.

Yes. We can skip MIGRATE_CMA pageblock and fix this issue. But,
re-think all the problem above. It needs various corner case handling
and I'm not sure that I can find and fix all of them. It is really
error prone to fix them case by case.

> > > > The fact
> > > > that pages under I/O cannot be moved is also the problem of all CMA
> > > > approaches. It is just separate issue and should not affect the decision
> > > > on ZONE_CMA.
> > > 
> > > While it's a separate issue, it's also an important one. A linear reclaim
> > > of a CMA region would at least be able to clearly identify pages that are
> > > pinned in that region. Introducing the zone does not help the problem.
> > 
> > I know that it's important. ZONE_CMA may not help the problem but
> > it is also true for other approaches. They also doesn't help the
> > problem. It's why I said it is a separate issue. I'm not sure what you
> > mean as linear reclaim here but separate zone will make easy to adapt
> > different reclaim algorithm if needed.
> > 
> > Although it's separate issue, I should mentioned one thing. Related to
> > I/O pinning issue, ZONE_CMA don't get blockdev allocation request so
> > I/O pinning problem is much reduced.
> > 
> 
> This is not super-clear from the patch. blockdev is using GFP_USER so it
> already should not be classed as MOVABLE. I could easily be looking in
> the wrong place or missed which allocation path sets GFP_MOVABLE.

Okay. Please see sb_bread(), sb_getblk(), __getblk() and __bread() in
include/linux/buffer_head.h. These are main functions used by blockdev
and they uses GFP_MOVABLE. To fix permanent allocation case which is
used by mount and cannot be released until umount, Gioh introduces
sb_bread_unmovable() but there are many remaining issues that prevent
migration at the moment and avoid blockdev allocation from CMA area is
preferable approach.

> > > What I was proposing at LSF/MM was the following;
> > > 
> > > 1. Create the notion of a sticky MIGRATE_MOVABLE type.
> > >    UNMOVABLE and RECLAIMABLE cannot fallback to these regions. If a sticky
> > >    region exists then the fallback code will need additional checks
> > >    in the slow path. This is slow but it's the cost of protection
> > 
> > First of all, I can't understand what is different between ZONE_CMA
> > and sticky MIGRATE_MOVABLE. We already did it for MIGRATE_CMA and it
> > is proved as error-prone design. #1 seems to be core concept of sticky
> > MIGRATE_MOVABLE and I cannot understand difference between them.
> > Please elaborate more on difference between them.
> > 
> 
> Sticky MIGRATE_MOVABLE does not worry about potential zones overlapping

Zones overlapping doesn't matter since it can happen without ZONE_CMA.

> It does not further fuzzy what a zone is meant to be for -- address
> 	limtations which MIGRATE_MOVABLE also violates

As I said before, we can think what a zone is meant more generally
like as "zone exists to deal with different types of memory". In this
point of view, it doesn't violate anything. And, it's not desirable to
introduce new constraint on migratetype. Before MIGRATE_CMA is
introduced, all migratetype can be compatible so we don't need to
distinguish them perfectly. MIGRATE_CMA changes the situation and it
fuzzy what MIGRATE_TYPE means. It also doesn't look right thing.

> It does not require a separate zone with potential page age inversion issues

Page age inversion issues is reduced by fair zone policy and your node
lru series would solve this problem further so it doesn't matter. Given that
current reclaim also has another problem (useless reclaim) and it
would be solved soon, it doesn't seem to be a big problem.

> It does not require addiitonal memory footprint for per-cpu allocation,
> 	page lock waitqueues and accounting

Perhaps true. But, there is also pros and cons. For example, to
account CMA freepages, many hooks are added to allocation hot-path. In
the watermark check, we adds one atomic operation to subtract CMA
freepages. These can be removed with ZONE_CMA approach.

> In the current reclaim implementation, it does not require zone
> 	balancing tricks although that concern goes away with node-lru.

I'm not sure what balancing issue you mean here? Is it different with
page age inversion issue? Please elaborate more. Anyway, ZONE_CMA
implementation doesn't require any *additional* balancing tricks. In
any case, trick for highmem can be used for ZONE_CMA.

> Some of this overlaps with the problems ZONE_MOVABLE has.
> 
> > > 4. Interleave MOVABLE and sticky MOVABLE if desired
> > >    This would be in the fallback paths only and be specific to CMA. This
> > >    would alleviate the utilisation problems while not impacting the fast
> > >    paths for everyone else. Functionally it would be similar to the fair
> > >    zone allocation policy which is currently in the fast path and scheduled
> > >    for removal.
> > 
> > Interleaving can be implement in any case if desired. At least now, thanks
> > to zone fair policy, ZONE_CMA would get benefit of interleaving.
> 
> For maybe one release if things go according to plan.
> 
> > Overall, I do not see any advantage of sticky MIGRATE_MOVABLE design
> > at least now. Main reason is that ZONE_CMA is introduced to replace
> > MIGRATE_CMA which is conceptually same with your sticky
> > MIGRATE_MOVABLE proposal. It doesn't solve any issues mentioned here
> > and we should not repeat same mistake again.
> > 
> 
> ZONE_MOVABLE in itself was a mistake, particularly when it was used for
> memory hotplug "guaranteeing" that memory could be removed. I'm not going to
> outright NAK your series but I won't ACK it either. Zones come with their own
> class of problems and I suspect that CMA will still be having discussions on
> utilisation and reliability problems in the future even if the zone is added.

Okay. I hope that above answer make you convinced. Say again, it would
be helpful to see the patch 4 and 5 that they removes bunch of hooks in core
allocation path which is a merit of ZONE_CMA approach. We need more
hooks if we decide to go with sticky MIGRATE_MOVABLE approach. I hope that
these long lasting CMA issues are solved as soon as possible and I
think that ZONE_CMA is the most appropriate solution that fixes most
of the issues, at least for now.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
