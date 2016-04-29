Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f197.google.com (mail-ig0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id D2A596B0005
	for <linux-mm@kvack.org>; Fri, 29 Apr 2016 02:51:39 -0400 (EDT)
Received: by mail-ig0-f197.google.com with SMTP id u5so26287894igk.2
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 23:51:39 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id d10si2911696igg.81.2016.04.28.23.51.37
        for <linux-mm@kvack.org>;
        Thu, 28 Apr 2016 23:51:38 -0700 (PDT)
Date: Fri, 29 Apr 2016 15:51:45 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 0/6] Introduce ZONE_CMA
Message-ID: <20160429065145.GA19896@js1304-P5Q-DELUXE>
References: <1461561670-28012-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20160425053653.GA25662@js1304-P5Q-DELUXE>
 <20160428103927.GM2858@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160428103927.GM2858@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello, Mel.

IIUC, you may miss that alloc_contig_range() currently does linear
reclaim/migration. Your comment is largely based on this
misunderstanding so please keep it in your mind when reading the
reply.

On Thu, Apr 28, 2016 at 11:39:27AM +0100, Mel Gorman wrote:
> On Mon, Apr 25, 2016 at 02:36:54PM +0900, Joonsoo Kim wrote:
> > > Hello,
> > > 
> > > Changes from v1
> > > o Separate some patches which deserve to submit independently
> > > o Modify description to reflect current kernel state
> > > (e.g. high-order watermark problem disappeared by Mel's work)
> > > o Don't increase SECTION_SIZE_BITS to make a room in page flags
> > > (detailed reason is on the patch that adds ZONE_CMA)
> > > o Adjust ZONE_CMA population code
> > > 
> > > This series try to solve problems of current CMA implementation.
> > > 
> > > CMA is introduced to provide physically contiguous pages at runtime
> > > without exclusive reserved memory area. But, current implementation
> > > works like as previous reserved memory approach, because freepages
> > > on CMA region are used only if there is no movable freepage. In other
> > > words, freepages on CMA region are only used as fallback. In that
> > > situation where freepages on CMA region are used as fallback, kswapd
> > > would be woken up easily since there is no unmovable and reclaimable
> > > freepage, too. If kswapd starts to reclaim memory, fallback allocation
> > > to MIGRATE_CMA doesn't occur any more since movable freepages are
> > > already refilled by kswapd and then most of freepage on CMA are left
> > > to be in free. This situation looks like exclusive reserved memory case.
> > > 
> 
> My understanding is that this was intentional. One of the original design
> requirements was that CMA have a high likelihood of allocation success for
> devices if it was necessary as an allocation failure was very visible to
> the user. It does not *have* to be treated as a reserve because Movable
> allocations could try CMA first but it increases allocation latency for
> devices that require it and it gets worse if those pages are pinned.

I know that it was design decision at that time when CMA isn't
actively used. It is due to lack of experience and now situation is
quite different. Most of embedded systems uses CMA with their own
adaptation because utilization is too low. It makes system much
slower and this is more likely than the case that device memory is
required. Given the fact that they adapt their logic to utilize CMA
much more and sacrifice latency, I think that previous design
decision is wrong and we should go another way.

> 
> > > In my experiment, I found that if system memory has 1024 MB memory and
> > > 512 MB is reserved for CMA, kswapd is mostly woken up when roughly 512 MB
> > > free memory is left. Detailed reason is that for keeping enough free
> > > memory for unmovable and reclaimable allocation, kswapd uses below
> > > equation when calculating free memory and it easily go under the watermark.
> > > 
> > > Free memory for unmovable and reclaimable = Free total - Free CMA pages
> > > 
> > > This is derivated from the property of CMA freepage that CMA freepage
> > > can't be used for unmovable and reclaimable allocation.
> > > 
> 
> Yes and also keeping it lightly utilised to reduce CMA allocation
> latency and probability of failure.

As my experience about CMA, most of unacceptable failure (takes more
than 3 sec) comes from blockdev pagecache. Even, it's not simple to
check what is going on there when failure happen. ZONE_CMA uses
different approach that it only takes the request with
GFP_HIGHUSER_MOVABLE so blockdev pagecache cannot get in and
probability of failure is much reduced.

> > > Anyway, in this case, kswapd are woken up when (FreeTotal - FreeCMA)
> > > is lower than low watermark and tries to make free memory until
> > > (FreeTotal - FreeCMA) is higher than high watermark. That results
> > > in that FreeTotal is moving around 512MB boundary consistently. It
> > > then means that we can't utilize full memory capacity.
> > > 
> > > To fix this problem, I submitted some patches [1] about 10 months ago,
> > > but, found some more problems to be fixed before solving this problem.
> > > It requires many hooks in allocator hotpath so some developers doesn't
> > > like it. Instead, some of them suggest different approach [2] to fix
> > > all the problems related to CMA, that is, introducing a new zone to deal
> > > with free CMA pages. I agree that it is the best way to go so implement
> > > here. Although properties of ZONE_MOVABLE and ZONE_CMA is similar,
> 
> One of the issues I mentioned at LSF/MM is that I consider ZONE_MOVABLE
> to be a mistake. Zones are meant to be about addressing limitations and
> both ZONE_MOVABLE and ZONE_CMA violate that. When ZONE_MOVABLE was
> introduced, it was intended for use with dynamically resizing the
> hugetlbfs pool. It was competing with fragmentation avoidance at the
> time and the community could not decide which approach was better so
> both ended up being merged as they had different advantages and
> disadvantages.
> 
> Now, ZONE_MOVABLE is being abused -- memory hotplug was a particular mistake
> and I don't want to see CMA fall down the same hole. Both CMA and memory
> hotplug would benefit from the notion of having "sticky" MIGRATE_MOVABLE
> pageblocks that are never used for UNMOVABLE and RECLAIMABLE fallbacks.
> It costs to detect that in the slow path but zones cause their own problems.

Please elaborate more concrete reasons that you think why ZONE_MOVABLE
is a mistake. Simply saying that zones are meant to be about address
limitations doesn't make sense. Moreover, I think that this original
purpose of zone could be changed if needed. It was introduced for that
purpose but time goes by a lot. We have different requirement now and
zone is suitable to handle this new requirement. And, if we think
address limitation more generally, it can be considered as different
characteristic memory problem. Zone is introduced to handle this
situation and that's what new CMA implementation needs.

> > > I
> > > decide to add a new zone rather than piggyback on ZONE_MOVABLE since
> > > they have some differences. First, reserved CMA pages should not be
> > > offlined. If freepage for CMA is managed by ZONE_MOVABLE, we need to keep
> > > MIGRATE_CMA migratetype and insert many hooks on memory hotplug code
> > > to distiguish hotpluggable memory and reserved memory for CMA in the same
> > > zone.
> 
> Or treat both as "sticky" MIGRATE_MOVABLE.
> 
> > > It would make memory hotplug code which is already complicated
> > > more complicated. Second, cma_alloc() can be called more frequently
> > > than memory hotplug operation and possibly we need to control
> > > allocation rate of ZONE_CMA to optimize latency in the future.
> > > In this case, separate zone approach is easy to modify. Third, I'd
> > > like to see statistics for CMA, separately. Sometimes, we need to debug
> > > why cma_alloc() is failed and separate statistics would be more helpful
> > > in this situtaion.
> > > 
> > > Anyway, this patchset solves four problems related to CMA implementation.
> > > 
> > > 1) Utilization problem
> > > As mentioned above, we can't utilize full memory capacity due to the
> > > limitation of CMA freepage and fallback policy. This patchset implements
> > > a new zone for CMA and uses it for GFP_HIGHUSER_MOVABLE request. This
> > > typed allocation is used for page cache and anonymous pages which
> > > occupies most of memory usage in normal case so we can utilize full
> > > memory capacity. Below is the experiment result about this problem.
> > > 
> 
> A zone is not necessary for that. Currently a zone would have a side-benefit

Agreed that a zone isn't necessary for it. I also tried the approach
interleaving within a normal zone about two years ago, and, because
there are more remaining problems and it needs more hook in many
placees, people doesn't like it. You can see implementation in below link.

https://lkml.org/lkml/2014/5/28/64


> from the fair zone allocation policy because it would interleave between
> ZONE_CMA and ZONE_MOVABLE. However, the intention is to remove that policy
> by moving LRUs to the node. Once that happens, the interleaving benefit
> is lost and you're back to square one.
> 
> There may be some justification for interleaving *only* between MOVABLE and
> MOVABLE_STICKY for CMA allocations and hiding that behind both a CONFIG_CMA
> guard *and* a check if there a CMA region exists. It'd still need
> something like the BATCH vmstat but it would only be updated when CMA is
> active and hide it from the fast paths.

And, please don't focus on interleaving allocation problem. Main
problem I'd like to solve is the utilization problem and interleaving
is optional benefit from fair zone policy. Some CMA adaptation I know
doesn't use interleaving at all. So, even if your node LRU work remove
fair zone policy, it would not be a critical problem of ZONE_CMA.
We can implement it if desired.

> 
> > > 2) Reclaim problem
> > > Currently, there is no logic to distinguish CMA pages in reclaim path.
> > > If reclaim is initiated for unmovable and reclaimable allocation,
> > > reclaiming CMA pages doesn't help to satisfy the request and reclaiming
> > > CMA page is just waste. By managing CMA pages in the new zone, we can
> > > skip to reclaim ZONE_CMA completely if it is unnecessary.
> > > 
> 
> This problem will recur with node-lru. However, that said CMA reclaim is

Yes, it will. But, it will also happen on ZONE_HIGHMEM if we use
node-lru. What's your plan to handle this issue? Because you cannot
remove ZONE_HIGHMEM, you need to handle it properly and that way would
naturally work well for ZONE_CMA as well.

> currently depending on randomly reclaiming followed by compaction. This is
> both slow and inefficient. CMA and alloc_contig_range() should strongly
> consider isolation pages with a PFN walk of the CMA regions and directly
> reclaiming those pages. Those pages may need to be refaulted in but the
> priority is for the allocation to succeed. That would side-step the issues
> with kswapd scanning the wrong zones.

I think that you are confused now. alloc_contig_range() already uses
PFN walk on the CMA regions and directly reclaim/migration those
pages. There is no randomly reclaim/migration here.

> > > 3) Atomic allocation failure problem
> > > Kswapd isn't started to reclaim pages when allocation request is movable
> > > type and there is enough free page in the CMA region. After bunch of
> > > consecutive movable allocation requests, free pages in ordinary region
> > > (not CMA region) would be exhausted without waking up kswapd. At that time,
> > > if atomic unmovable allocation comes, it can't be successful since there
> > > is not enough page in ordinary region. This problem is reported
> > > by Aneesh [4] and can be solved by this patchset.
> > > 
> 
> Not necessarily as kswapd curently would still reclaim from the lower
> zones unnecessarily. Again, targetting the pages required for the CMA
> allocation would side-step the issue. The actual core code of lumpy reclaim
> was quite small.

You may be confused here, too.  Maybe, I misunderstand what you say
here so please correct me if I'm missing something. First, let me
clarify the problem.

It's not the issue when calling alloc_contig_range(). It is the issue
when MM manages (allocate/reclaim) pages on CMA area when they are not
used by device now.

The problem is that kswapd isn't woken up properly due to non-accurate
watermark check. When we do watermark check, number of freepage is
varied depending on allocation type. Non-movable allocation subtracts
number of CMA freepages from total freepages. In other words, we adds
number of CMA freepages to number of normal freepages when movable
allocation is requested. Problem comes from here. While we handle
bunch of movable allocation, we can't notice that there is not enough
freepage in normal area because we adds up number of CMA freepages and
watermark looks safe. In this case, kswapd would not be woken up. If
atomic allocation suddenly comes in this situation, freepage in normal
area could be low and atomic allocation can fail.

This is a really good example that comes from the fact that different
types of pages are in a single zone. As I mentioned in other places,
it's really error-prone design and handling it case by case is very fragile.
Current long lasting problems about CMA is caused by this design
decision and we need to change it.

> > > 4) Inefficiently work of compaction
> > > Usual high-order allocation request is unmovable type and it cannot
> > > be serviced from CMA area. In compaction, migration scanner doesn't
> > > distinguish migratable pages on the CMA area and do migration.
> > > In this case, even if we make high-order page on that region, it
> > > cannot be used due to type mismatch. This patch will solve this problem
> > > by separating CMA pages from ordinary zones.
> > > 
> 
> Compaction problems are actually compounded by introducing ZONE_CMA as
> it only compacts within the zone. Compaction would need to know how to
> compact within a node to address the introduction of ZONE_CMA.
> 

I'm not sure what you'd like to say here. What I meant is following
situation. Capital letter means pageblock type. (C:MIGRATE_CMA,
M:MIGRATE_MOVABLE). F means freed pageblock due to compaction.

CCCCCMMMM

If compaction is invoked to make unmovable high order freepage,
compaction would start to work. It empties front part of the zone and
migrate them to rear part of the zone. High order freepages are made
on front part of the zone and it may look like as following.

FFFCCMMMM

But, they are on CMA pageblock so it cannot be used to satisfy unmovable
high order allocation. Freepages on CMA pageblock isn't allocated for
unmovable allocation request. That is what I'd like to say here.
We can fix it by adding corner case handling at some place but
this kind of corner case handling is not what I want. It's not
maintainable. It comes from current design decision (MIGRATE_CMA) and
we need to change the situation.

And, there is no compaction problem on ZONE_CMA because we can
compact it as like as the others. Any new problem isn't added due to
ZONE_CMA. If you'd like to say about problem of migration destination
page when calling alloc_contig_range(), there is no problem, too.
alloc_contig_range() uses alloc_nugrate_target() that is used by
memory-hotplug and it doesn't limit allocation's target zone. No
problem is introduced by ZONE_CMA.

> > I read the summary of the LSF/MM in LWN.net and Rik's summary e-mail
> > and it looks like there is a disagreement on ZONE_CMA approach and
> > I'd like to talk about it in this mail.
> > 
> > I'd like to object Aneesh's statement that using ZONE_CMA just replaces
> > one set of problems with another (mentioned in LWN.net).
> 
> These are the problems I have as well. Even with current code, reclaim
> is balanced between zones and introducing a new one compounds the
> problem. With node-lru, it is similarly complicated.

I believe your node-lru work will solve balancing problem for
ZONE_HIGHMEM. ZONE_CMA can be piggyback on this design decision since
it has similar limitation with ZONE_HIGHMEM so I think that there is
no problem at all.

And, I guess that using another design like as your sticky MOVABLE
types needs similar exception handling eventually and it would be more
complex than adding a new zone because zone is originally for handling
different characteristic memory but migratetype isn't. At least
currently, different migratetype doesn't mean that it isn't compatible
with others except MIGRATE_CMA. It is the root of the problem.

> > The fact
> > that pages under I/O cannot be moved is also the problem of all CMA
> > approaches. It is just separate issue and should not affect the decision
> > on ZONE_CMA.
> 
> While it's a separate issue, it's also an important one. A linear reclaim
> of a CMA region would at least be able to clearly identify pages that are
> pinned in that region. Introducing the zone does not help the problem.

I know that it's important. ZONE_CMA may not help the problem but
it is also true for other approaches. They also doesn't help the
problem. It's why I said it is a separate issue. I'm not sure what you
mean as linear reclaim here but separate zone will make easy to adapt
different reclaim algorithm if needed.

Although it's separate issue, I should mentioned one thing. Related to
I/O pinning issue, ZONE_CMA don't get blockdev allocation request so
I/O pinning problem is much reduced.

> > What we should consider is what is the best approach to solve other issues
> > that comes from the fact that pages with different characteristic are
> > in the same zone. One of the problem is a watermark check. Many MM logic
> > based on watermark check to decide something. If there are free pages with
> > different characteristic that is not compatible with other migratetypes,
> > output of watermark check would cause the problem. We distinguished
> > allocation type and adjusted watermark check through ALLOC_CMA flag but
> > using it is not so simple and is fragile. Consider about the compaction
> > code. There is a checks that there are enough order-0 freepage in the zone
> > to check that compaction could work, before entering the compaction.
> 
> Which would be addressed by linear reclaiming instead as the contiguous
> region is what CMA requires. Compaction was intended to be best effort for
> THP. Potentially right now, CMA has to loop constantly reclaiming pages
> and hoping compaction works and that can over-reclaim if there are pinned
> pages and *still* fail.

I don't get it here. What I'd like to say here is the difficulty of
corner case handling with current MIGRATE_CMA approach. These corner
case comes from the design decision of MIGRATE_CMA. It doesn't work
well and causes many problems until now.

> > In this case, we could add up CMA freepages even if alloc_flags doesn't
> > have ALLOC_CMA because we can utilize CMA freepages as a freepage.
> > But, in reality, we missed it. We might fix those cases one by one but
> > it's seems to be really error-prone to me. Until recent date, high order
> > freepage counting problem was there, too. It partially disappeared
> > by Mel's MIGRATE_HIGHATOMIC work, but still remain for ALLOC_HARDER
> > request. (We cannot know how many high order freepages are on normal area
> > and CMA area.) That problem also shows that it's very fragile design
> > that non-compatible types of pages are in the same zone.
> > 
> > ZONE_CMA separates those pages to a new zone so there is no problem
> > mentioned in the above. There are other issues about freepage utilization
> > and reclaim efficiency in current kernel code and those also could be solved
> > by ZONE_CMA approach. Without a new zone, it need more hooks on core MM code
> > and it is uncomfortable to the developers who doesn't use the CMA.
> > New zone would be a necessary evil in this situation.
> > 
> > I don't think another migratetype, sticky MIGRATE_MOVABLE,
> > is the right solution here. We already uses MIGRATE_CMA for that purpose
> > and it is proved that it doesn't work well.
> > 
> 
> Partially because the watermark checks do not always do the best thing,
> kswapd does not always reclaim the correct pages and compaction does not
> always work. A zone alleviates the watermark check but not the reclaim or
> compaction problems while introducing issues with balancing zone reclaim,
> having additional free lists and getting impacted later when the fair zone
> allocation policy is removed. It would be very difficult to convince me
> that ZONE_CMA is the way forward when I already think that ZONE_MOVABLE
> was a mistake.

I don't get what you mean reclaim and compaction problem here.
ZONE_CMA will solve many problems above mentioned and provides robust
implementation to us. I admit that reclaim balancing problem is added
if your node-lru work is merged but it is not a new issue.
ZONE_HIGHMEM also has same problem and you need to consider
and solve it. ZONE_CMA can be benefit from that solution so it
would not be show stopper for ZONE_CMA design.

Moreover, in the worst case, you just manages pages on ZONE_CMA
with global node lru. It is the same case that CMA pages are
on the other zone such as ZONE_NORMAL. It's not worse than current
implementation in terms of reclaim efficiency.

> What I was proposing at LSF/MM was the following;
> 
> 1. Create the notion of a sticky MIGRATE_MOVABLE type.
>    UNMOVABLE and RECLAIMABLE cannot fallback to these regions. If a sticky
>    region exists then the fallback code will need additional checks
>    in the slow path. This is slow but it's the cost of protection

First of all, I can't understand what is different between ZONE_CMA
and sticky MIGRATE_MOVABLE. We already did it for MIGRATE_CMA and it
is proved as error-prone design. #1 seems to be core concept of sticky
MIGRATE_MOVABLE and I cannot understand difference between them.
Please elaborate more on difference between them.

> 2. Express MIGRATE_CMA in terms of sticky MIGRATE_MOVABLE
> 
> 3. Use linear reclaim instead of reclaim/compaction in alloc_contig_range
>    Reclaim/compaction was intended for THP which does not care about zones,
>    only node locality. It potentially over-reclaims in the CMA-allocation
>    case. If reclaim/aggression is increased then it could potentially
>    reclaim the entire system before failing. By using linear reclaim, a
>    failure pass will scan just CMA, reclaim everything there and fail. On
>    success, it may still over-reclaim if it finds pinned pages but in the
>    ideal case, it reclaims exactly what is required for the allocation to
>    succeed. Some pages may need to be refaulted but that is likely cheaper
>    than multiple reclaim/compaction cycles that eventually fail anyway
> 
>    The core of how linear reclaim used to work is still visible in commit
>    c53919adc045bf803252e912f23028a68525753d  in the isolate_lru_pages
>    function although I would not suggest reintroducing it there and instead
>    do something similar in alloc_contig_range.
> 
>    Potentially, over-reclaim could be avoided by isolating the full range
>    first and if one isolation fails then putback all the pages and restart
>    the scan after the pinned page.

alloc_contig_range() already uses linear reclaim/migration.

> 4. Interleave MOVABLE and sticky MOVABLE if desired
>    This would be in the fallback paths only and be specific to CMA. This
>    would alleviate the utilisation problems while not impacting the fast
>    paths for everyone else. Functionally it would be similar to the fair
>    zone allocation policy which is currently in the fast path and scheduled
>    for removal.

Interleaving can be implement in any case if desired. At least now, thanks
to zone fair policy, ZONE_CMA would get benefit of interleaving. If your node
lru work removes zone fair policy, it would become a problem but it also the
problem on other approach. We can solve it with some hook on
allocation path so it's not bad point of ZONE_CMA.

> 5. For kernelcore=, create stick MIGRATE_MOVABLE blocks instead of
>    ZONE_MOVABLE
> 
> 6. For memory hot-add, create sticky MIGRATE_MOVABLE blocks instead of
>    adding pages to ZONE_MOVABLE
> 
> 7. Delete ZONE_MOVABLE
> 
> 8. Optionally migrate pages about to be pinned from sticky MIGRATE_MOVABLE
> 
>    This would benefit both CMA and memory hot-remove. It would be a policy
>    choice on whether a failed migration allows the allocation to succeed
>    or not.

Separate issue. It can be implemented regardless of CMA design decision.

Overall, I do not see any advantage of sticky MIGRATE_MOVABLE design
at least now. Main reason is that ZONE_CMA is introduced to replace
MIGRATE_CMA which is conceptually same with your sticky
MIGRATE_MOVABLE proposal. It doesn't solve any issues mentioned here
and we should not repeat same mistake again.

If I'm missing something, please let me know.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
