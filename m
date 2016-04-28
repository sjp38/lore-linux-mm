Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6AF336B007E
	for <linux-mm@kvack.org>; Thu, 28 Apr 2016 06:39:32 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id k200so67156993lfg.1
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 03:39:32 -0700 (PDT)
Received: from outbound-smtp09.blacknight.com (outbound-smtp09.blacknight.com. [46.22.139.14])
        by mx.google.com with ESMTPS id i7si10041344wju.140.2016.04.28.03.39.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Apr 2016 03:39:30 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id E61611C1962
	for <linux-mm@kvack.org>; Thu, 28 Apr 2016 11:39:29 +0100 (IST)
Date: Thu, 28 Apr 2016 11:39:27 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH v2 0/6] Introduce ZONE_CMA
Message-ID: <20160428103927.GM2858@techsingularity.net>
References: <1461561670-28012-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20160425053653.GA25662@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160425053653.GA25662@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Apr 25, 2016 at 02:36:54PM +0900, Joonsoo Kim wrote:
> > Hello,
> > 
> > Changes from v1
> > o Separate some patches which deserve to submit independently
> > o Modify description to reflect current kernel state
> > (e.g. high-order watermark problem disappeared by Mel's work)
> > o Don't increase SECTION_SIZE_BITS to make a room in page flags
> > (detailed reason is on the patch that adds ZONE_CMA)
> > o Adjust ZONE_CMA population code
> > 
> > This series try to solve problems of current CMA implementation.
> > 
> > CMA is introduced to provide physically contiguous pages at runtime
> > without exclusive reserved memory area. But, current implementation
> > works like as previous reserved memory approach, because freepages
> > on CMA region are used only if there is no movable freepage. In other
> > words, freepages on CMA region are only used as fallback. In that
> > situation where freepages on CMA region are used as fallback, kswapd
> > would be woken up easily since there is no unmovable and reclaimable
> > freepage, too. If kswapd starts to reclaim memory, fallback allocation
> > to MIGRATE_CMA doesn't occur any more since movable freepages are
> > already refilled by kswapd and then most of freepage on CMA are left
> > to be in free. This situation looks like exclusive reserved memory case.
> > 

My understanding is that this was intentional. One of the original design
requirements was that CMA have a high likelihood of allocation success for
devices if it was necessary as an allocation failure was very visible to
the user. It does not *have* to be treated as a reserve because Movable
allocations could try CMA first but it increases allocation latency for
devices that require it and it gets worse if those pages are pinned.

> > In my experiment, I found that if system memory has 1024 MB memory and
> > 512 MB is reserved for CMA, kswapd is mostly woken up when roughly 512 MB
> > free memory is left. Detailed reason is that for keeping enough free
> > memory for unmovable and reclaimable allocation, kswapd uses below
> > equation when calculating free memory and it easily go under the watermark.
> > 
> > Free memory for unmovable and reclaimable = Free total - Free CMA pages
> > 
> > This is derivated from the property of CMA freepage that CMA freepage
> > can't be used for unmovable and reclaimable allocation.
> > 

Yes and also keeping it lightly utilised to reduce CMA allocation
latency and probability of failure.

> > Anyway, in this case, kswapd are woken up when (FreeTotal - FreeCMA)
> > is lower than low watermark and tries to make free memory until
> > (FreeTotal - FreeCMA) is higher than high watermark. That results
> > in that FreeTotal is moving around 512MB boundary consistently. It
> > then means that we can't utilize full memory capacity.
> > 
> > To fix this problem, I submitted some patches [1] about 10 months ago,
> > but, found some more problems to be fixed before solving this problem.
> > It requires many hooks in allocator hotpath so some developers doesn't
> > like it. Instead, some of them suggest different approach [2] to fix
> > all the problems related to CMA, that is, introducing a new zone to deal
> > with free CMA pages. I agree that it is the best way to go so implement
> > here. Although properties of ZONE_MOVABLE and ZONE_CMA is similar,

One of the issues I mentioned at LSF/MM is that I consider ZONE_MOVABLE
to be a mistake. Zones are meant to be about addressing limitations and
both ZONE_MOVABLE and ZONE_CMA violate that. When ZONE_MOVABLE was
introduced, it was intended for use with dynamically resizing the
hugetlbfs pool. It was competing with fragmentation avoidance at the
time and the community could not decide which approach was better so
both ended up being merged as they had different advantages and
disadvantages.

Now, ZONE_MOVABLE is being abused -- memory hotplug was a particular mistake
and I don't want to see CMA fall down the same hole. Both CMA and memory
hotplug would benefit from the notion of having "sticky" MIGRATE_MOVABLE
pageblocks that are never used for UNMOVABLE and RECLAIMABLE fallbacks.
It costs to detect that in the slow path but zones cause their own problems.

> > I
> > decide to add a new zone rather than piggyback on ZONE_MOVABLE since
> > they have some differences. First, reserved CMA pages should not be
> > offlined. If freepage for CMA is managed by ZONE_MOVABLE, we need to keep
> > MIGRATE_CMA migratetype and insert many hooks on memory hotplug code
> > to distiguish hotpluggable memory and reserved memory for CMA in the same
> > zone.

Or treat both as "sticky" MIGRATE_MOVABLE.

> > It would make memory hotplug code which is already complicated
> > more complicated. Second, cma_alloc() can be called more frequently
> > than memory hotplug operation and possibly we need to control
> > allocation rate of ZONE_CMA to optimize latency in the future.
> > In this case, separate zone approach is easy to modify. Third, I'd
> > like to see statistics for CMA, separately. Sometimes, we need to debug
> > why cma_alloc() is failed and separate statistics would be more helpful
> > in this situtaion.
> > 
> > Anyway, this patchset solves four problems related to CMA implementation.
> > 
> > 1) Utilization problem
> > As mentioned above, we can't utilize full memory capacity due to the
> > limitation of CMA freepage and fallback policy. This patchset implements
> > a new zone for CMA and uses it for GFP_HIGHUSER_MOVABLE request. This
> > typed allocation is used for page cache and anonymous pages which
> > occupies most of memory usage in normal case so we can utilize full
> > memory capacity. Below is the experiment result about this problem.
> > 

A zone is not necessary for that. Currently a zone would have a side-benefit
from the fair zone allocation policy because it would interleave between
ZONE_CMA and ZONE_MOVABLE. However, the intention is to remove that policy
by moving LRUs to the node. Once that happens, the interleaving benefit
is lost and you're back to square one.

There may be some justification for interleaving *only* between MOVABLE and
MOVABLE_STICKY for CMA allocations and hiding that behind both a CONFIG_CMA
guard *and* a check if there a CMA region exists. It'd still need
something like the BATCH vmstat but it would only be updated when CMA is
active and hide it from the fast paths.

> > 2) Reclaim problem
> > Currently, there is no logic to distinguish CMA pages in reclaim path.
> > If reclaim is initiated for unmovable and reclaimable allocation,
> > reclaiming CMA pages doesn't help to satisfy the request and reclaiming
> > CMA page is just waste. By managing CMA pages in the new zone, we can
> > skip to reclaim ZONE_CMA completely if it is unnecessary.
> > 

This problem will recur with node-lru. However, that said CMA reclaim is
currently depending on randomly reclaiming followed by compaction. This is
both slow and inefficient. CMA and alloc_contig_range() should strongly
consider isolation pages with a PFN walk of the CMA regions and directly
reclaiming those pages. Those pages may need to be refaulted in but the
priority is for the allocation to succeed. That would side-step the issues
with kswapd scanning the wrong zones.

> > 3) Atomic allocation failure problem
> > Kswapd isn't started to reclaim pages when allocation request is movable
> > type and there is enough free page in the CMA region. After bunch of
> > consecutive movable allocation requests, free pages in ordinary region
> > (not CMA region) would be exhausted without waking up kswapd. At that time,
> > if atomic unmovable allocation comes, it can't be successful since there
> > is not enough page in ordinary region. This problem is reported
> > by Aneesh [4] and can be solved by this patchset.
> > 

Not necessarily as kswapd curently would still reclaim from the lower
zones unnecessarily. Again, targetting the pages required for the CMA
allocation would side-step the issue. The actual core code of lumpy reclaim
was quite small.

> > 4) Inefficiently work of compaction
> > Usual high-order allocation request is unmovable type and it cannot
> > be serviced from CMA area. In compaction, migration scanner doesn't
> > distinguish migratable pages on the CMA area and do migration.
> > In this case, even if we make high-order page on that region, it
> > cannot be used due to type mismatch. This patch will solve this problem
> > by separating CMA pages from ordinary zones.
> > 

Compaction problems are actually compounded by introducing ZONE_CMA as
it only compacts within the zone. Compaction would need to know how to
compact within a node to address the introduction of ZONE_CMA.

> I read the summary of the LSF/MM in LWN.net and Rik's summary e-mail
> and it looks like there is a disagreement on ZONE_CMA approach and
> I'd like to talk about it in this mail.
> 
> I'd like to object Aneesh's statement that using ZONE_CMA just replaces
> one set of problems with another (mentioned in LWN.net).

These are the problems I have as well. Even with current code, reclaim
is balanced between zones and introducing a new one compounds the
problem. With node-lru, it is similarly complicated.

> The fact
> that pages under I/O cannot be moved is also the problem of all CMA
> approaches. It is just separate issue and should not affect the decision
> on ZONE_CMA.

While it's a separate issue, it's also an important one. A linear reclaim
of a CMA region would at least be able to clearly identify pages that are
pinned in that region. Introducing the zone does not help the problem.

> What we should consider is what is the best approach to solve other issues
> that comes from the fact that pages with different characteristic are
> in the same zone. One of the problem is a watermark check. Many MM logic
> based on watermark check to decide something. If there are free pages with
> different characteristic that is not compatible with other migratetypes,
> output of watermark check would cause the problem. We distinguished
> allocation type and adjusted watermark check through ALLOC_CMA flag but
> using it is not so simple and is fragile. Consider about the compaction
> code. There is a checks that there are enough order-0 freepage in the zone
> to check that compaction could work, before entering the compaction.

Which would be addressed by linear reclaiming instead as the contiguous
region is what CMA requires. Compaction was intended to be best effort for
THP. Potentially right now, CMA has to loop constantly reclaiming pages
and hoping compaction works and that can over-reclaim if there are pinned
pages and *still* fail.

> In this case, we could add up CMA freepages even if alloc_flags doesn't
> have ALLOC_CMA because we can utilize CMA freepages as a freepage.
> But, in reality, we missed it. We might fix those cases one by one but
> it's seems to be really error-prone to me. Until recent date, high order
> freepage counting problem was there, too. It partially disappeared
> by Mel's MIGRATE_HIGHATOMIC work, but still remain for ALLOC_HARDER
> request. (We cannot know how many high order freepages are on normal area
> and CMA area.) That problem also shows that it's very fragile design
> that non-compatible types of pages are in the same zone.
> 
> ZONE_CMA separates those pages to a new zone so there is no problem
> mentioned in the above. There are other issues about freepage utilization
> and reclaim efficiency in current kernel code and those also could be solved
> by ZONE_CMA approach. Without a new zone, it need more hooks on core MM code
> and it is uncomfortable to the developers who doesn't use the CMA.
> New zone would be a necessary evil in this situation.
> 
> I don't think another migratetype, sticky MIGRATE_MOVABLE,
> is the right solution here. We already uses MIGRATE_CMA for that purpose
> and it is proved that it doesn't work well.
> 

Partially because the watermark checks do not always do the best thing,
kswapd does not always reclaim the correct pages and compaction does not
always work. A zone alleviates the watermark check but not the reclaim or
compaction problems while introducing issues with balancing zone reclaim,
having additional free lists and getting impacted later when the fair zone
allocation policy is removed. It would be very difficult to convince me
that ZONE_CMA is the way forward when I already think that ZONE_MOVABLE
was a mistake.

What I was proposing at LSF/MM was the following;

1. Create the notion of a sticky MIGRATE_MOVABLE type.
   UNMOVABLE and RECLAIMABLE cannot fallback to these regions. If a sticky
   region exists then the fallback code will need additional checks
   in the slow path. This is slow but it's the cost of protection

2. Express MIGRATE_CMA in terms of sticky MIGRATE_MOVABLE

3. Use linear reclaim instead of reclaim/compaction in alloc_contig_range
   Reclaim/compaction was intended for THP which does not care about zones,
   only node locality. It potentially over-reclaims in the CMA-allocation
   case. If reclaim/aggression is increased then it could potentially
   reclaim the entire system before failing. By using linear reclaim, a
   failure pass will scan just CMA, reclaim everything there and fail. On
   success, it may still over-reclaim if it finds pinned pages but in the
   ideal case, it reclaims exactly what is required for the allocation to
   succeed. Some pages may need to be refaulted but that is likely cheaper
   than multiple reclaim/compaction cycles that eventually fail anyway

   The core of how linear reclaim used to work is still visible in commit
   c53919adc045bf803252e912f23028a68525753d  in the isolate_lru_pages
   function although I would not suggest reintroducing it there and instead
   do something similar in alloc_contig_range.

   Potentially, over-reclaim could be avoided by isolating the full range
   first and if one isolation fails then putback all the pages and restart
   the scan after the pinned page.

4. Interleave MOVABLE and sticky MOVABLE if desired
   This would be in the fallback paths only and be specific to CMA. This
   would alleviate the utilisation problems while not impacting the fast
   paths for everyone else. Functionally it would be similar to the fair
   zone allocation policy which is currently in the fast path and scheduled
   for removal.

5. For kernelcore=, create stick MIGRATE_MOVABLE blocks instead of
   ZONE_MOVABLE

6. For memory hot-add, create sticky MIGRATE_MOVABLE blocks instead of
   adding pages to ZONE_MOVABLE

7. Delete ZONE_MOVABLE

8. Optionally migrate pages about to be pinned from sticky MIGRATE_MOVABLE

   This would benefit both CMA and memory hot-remove. It would be a policy
   choice on whether a failed migration allows the allocation to succeed
   or not.


-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
