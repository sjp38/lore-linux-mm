Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 93BD26B007E
	for <linux-mm@kvack.org>; Mon, 25 Apr 2016 01:33:23 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id dx6so256454818pad.0
        for <linux-mm@kvack.org>; Sun, 24 Apr 2016 22:33:23 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id p9si4743618paa.62.2016.04.24.22.33.21
        for <linux-mm@kvack.org>;
        Sun, 24 Apr 2016 22:33:22 -0700 (PDT)
Date: Mon, 25 Apr 2016 14:36:54 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 0/6] Introduce ZONE_CMA
Message-ID: <20160425053653.GA25662@js1304-P5Q-DELUXE>
References: <1461561670-28012-1-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1461561670-28012-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Apr 25, 2016 at 02:21:04PM +0900, js1304@gmail.com wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> Hello,
> 
> Changes from v1
> o Separate some patches which deserve to submit independently
> o Modify description to reflect current kernel state
> (e.g. high-order watermark problem disappeared by Mel's work)
> o Don't increase SECTION_SIZE_BITS to make a room in page flags
> (detailed reason is on the patch that adds ZONE_CMA)
> o Adjust ZONE_CMA population code
> 
> This series try to solve problems of current CMA implementation.
> 
> CMA is introduced to provide physically contiguous pages at runtime
> without exclusive reserved memory area. But, current implementation
> works like as previous reserved memory approach, because freepages
> on CMA region are used only if there is no movable freepage. In other
> words, freepages on CMA region are only used as fallback. In that
> situation where freepages on CMA region are used as fallback, kswapd
> would be woken up easily since there is no unmovable and reclaimable
> freepage, too. If kswapd starts to reclaim memory, fallback allocation
> to MIGRATE_CMA doesn't occur any more since movable freepages are
> already refilled by kswapd and then most of freepage on CMA are left
> to be in free. This situation looks like exclusive reserved memory case.
> 
> In my experiment, I found that if system memory has 1024 MB memory and
> 512 MB is reserved for CMA, kswapd is mostly woken up when roughly 512 MB
> free memory is left. Detailed reason is that for keeping enough free
> memory for unmovable and reclaimable allocation, kswapd uses below
> equation when calculating free memory and it easily go under the watermark.
> 
> Free memory for unmovable and reclaimable = Free total - Free CMA pages
> 
> This is derivated from the property of CMA freepage that CMA freepage
> can't be used for unmovable and reclaimable allocation.
> 
> Anyway, in this case, kswapd are woken up when (FreeTotal - FreeCMA)
> is lower than low watermark and tries to make free memory until
> (FreeTotal - FreeCMA) is higher than high watermark. That results
> in that FreeTotal is moving around 512MB boundary consistently. It
> then means that we can't utilize full memory capacity.
> 
> To fix this problem, I submitted some patches [1] about 10 months ago,
> but, found some more problems to be fixed before solving this problem.
> It requires many hooks in allocator hotpath so some developers doesn't
> like it. Instead, some of them suggest different approach [2] to fix
> all the problems related to CMA, that is, introducing a new zone to deal
> with free CMA pages. I agree that it is the best way to go so implement
> here. Although properties of ZONE_MOVABLE and ZONE_CMA is similar, I
> decide to add a new zone rather than piggyback on ZONE_MOVABLE since
> they have some differences. First, reserved CMA pages should not be
> offlined. If freepage for CMA is managed by ZONE_MOVABLE, we need to keep
> MIGRATE_CMA migratetype and insert many hooks on memory hotplug code
> to distiguish hotpluggable memory and reserved memory for CMA in the same
> zone. It would make memory hotplug code which is already complicated
> more complicated. Second, cma_alloc() can be called more frequently
> than memory hotplug operation and possibly we need to control
> allocation rate of ZONE_CMA to optimize latency in the future.
> In this case, separate zone approach is easy to modify. Third, I'd
> like to see statistics for CMA, separately. Sometimes, we need to debug
> why cma_alloc() is failed and separate statistics would be more helpful
> in this situtaion.
> 
> Anyway, this patchset solves four problems related to CMA implementation.
> 
> 1) Utilization problem
> As mentioned above, we can't utilize full memory capacity due to the
> limitation of CMA freepage and fallback policy. This patchset implements
> a new zone for CMA and uses it for GFP_HIGHUSER_MOVABLE request. This
> typed allocation is used for page cache and anonymous pages which
> occupies most of memory usage in normal case so we can utilize full
> memory capacity. Below is the experiment result about this problem.
> 
> 8 CPUs, 1024 MB, VIRTUAL MACHINE
> make -j16
> 
> <Before this series>
> CMA reserve:            0 MB            512 MB
> Elapsed-time:           92.4		186.5
> pswpin:                 82		18647
> pswpout:                160		69839
> 
> <After this series>
> CMA reserve:            0 MB            512 MB
> Elapsed-time:           93.1		93.4
> pswpin:                 84		46
> pswpout:                183		92
> 
> FYI, there is another attempt [3] trying to solve this problem in lkml.
> And, as far as I know, Qualcomm also has out-of-tree solution for this
> problem.
> 
> 2) Reclaim problem
> Currently, there is no logic to distinguish CMA pages in reclaim path.
> If reclaim is initiated for unmovable and reclaimable allocation,
> reclaiming CMA pages doesn't help to satisfy the request and reclaiming
> CMA page is just waste. By managing CMA pages in the new zone, we can
> skip to reclaim ZONE_CMA completely if it is unnecessary.
> 
> 3) Atomic allocation failure problem
> Kswapd isn't started to reclaim pages when allocation request is movable
> type and there is enough free page in the CMA region. After bunch of
> consecutive movable allocation requests, free pages in ordinary region
> (not CMA region) would be exhausted without waking up kswapd. At that time,
> if atomic unmovable allocation comes, it can't be successful since there
> is not enough page in ordinary region. This problem is reported
> by Aneesh [4] and can be solved by this patchset.
> 
> 4) Inefficiently work of compaction
> Usual high-order allocation request is unmovable type and it cannot
> be serviced from CMA area. In compaction, migration scanner doesn't
> distinguish migratable pages on the CMA area and do migration.
> In this case, even if we make high-order page on that region, it
> cannot be used due to type mismatch. This patch will solve this problem
> by separating CMA pages from ordinary zones.
> 
> I passed boot test on x86_64, x86_32, arm and arm64. I did some stress
> tests on x86_64 and x86_32 and there is no problem. Feel free to enjoy
> and please give me a feedback. :)
> 
> This patchset is based on linux-next-20160413.
> 
> Thanks.
> 
> [1] https://lkml.org/lkml/2014/5/28/64
> [2] https://lkml.org/lkml/2014/11/4/55
> [3] https://lkml.org/lkml/2014/10/15/623
> [4] http://www.spinics.net/lists/linux-mm/msg100562.html
> 
> Joonsoo Kim (6):
>   mm/page_alloc: recalculate some of zone threshold when on/offline
>     memory
>   mm/cma: introduce new zone, ZONE_CMA
>   mm/cma: populate ZONE_CMA
>   mm/cma: remove ALLOC_CMA
>   mm/cma: remove MIGRATE_CMA
>   mm/cma: remove per zone CMA stat
> 
>  arch/x86/mm/highmem_32.c          |   8 ++
>  fs/proc/meminfo.c                 |   2 +-
>  include/linux/cma.h               |   6 +
>  include/linux/gfp.h               |  32 +++---
>  include/linux/memory_hotplug.h    |   3 -
>  include/linux/mempolicy.h         |   2 +-
>  include/linux/mmzone.h            |  54 +++++----
>  include/linux/vm_event_item.h     |  10 +-
>  include/linux/vmstat.h            |   8 --
>  include/trace/events/compaction.h |  10 +-
>  kernel/power/snapshot.c           |   8 ++
>  mm/cma.c                          |  58 +++++++++-
>  mm/compaction.c                   |  10 +-
>  mm/hugetlb.c                      |   2 +-
>  mm/internal.h                     |   6 +-
>  mm/memory_hotplug.c               |   3 +
>  mm/page_alloc.c                   | 236 ++++++++++++++++++++++----------------
>  mm/page_isolation.c               |   5 +-
>  mm/vmstat.c                       |  15 ++-
>  19 files changed, 303 insertions(+), 175 deletions(-)

Hello, Mel and Aneesh.

I read the summary of the LSF/MM in LWN.net and Rik's summary e-mail
and it looks like there is a disagreement on ZONE_CMA approach and
I'd like to talk about it in this mail.

I'd like to object Aneesh's statement that using ZONE_CMA just replaces
one set of problems with another (mentioned in LWN.net). The fact
that pages under I/O cannot be moved is also the problem of all CMA
approaches. It is just separate issue and should not affect the decision
on ZONE_CMA. It would be solved by migration before I/O and pinning.
And, mlocked pages in CMA area can be moved. THP pages aren't moved
in current implementation but it can be solved by linear/lumpy reclaim
mentioned in that discussion. It is also the problem of all the approaches
so should not affect the decision on ZONE_CMA.

What we should consider is what is the best approach to solve other issues
that comes from the fact that pages with different characteristic are
in the same zone. One of the problem is a watermark check. Many MM logic
based on watermark check to decide something. If there are free pages with
different characteristic that is not compatible with other migratetypes,
output of watermark check would cause the problem. We distinguished
allocation type and adjusted watermark check through ALLOC_CMA flag but
using it is not so simple and is fragile. Consider about the compaction
code. There is a checks that there are enough order-0 freepage in the zone
to check that compaction could work, before entering the compaction.
In this case, we could add up CMA freepages even if alloc_flags doesn't
have ALLOC_CMA because we can utilize CMA freepages as a freepage.
But, in reality, we missed it. We might fix those cases one by one but
it's seems to be really error-prone to me. Until recent date, high order
freepage counting problem was there, too. It partially disappeared
by Mel's MIGRATE_HIGHATOMIC work, but still remain for ALLOC_HARDER
request. (We cannot know how many high order freepages are on normal area
and CMA area.) That problem also shows that it's very fragile design
that non-compatible types of pages are in the same zone.

ZONE_CMA separates those pages to a new zone so there is no problem
mentioned in the above. There are other issues about freepage utilization
and reclaim efficiency in current kernel code and those also could be solved
by ZONE_CMA approach. Without a new zone, it need more hooks on core MM code
and it is uncomfortable to the developers who doesn't use the CMA.
New zone would be a necessary evil in this situation.

I don't think another migratetype, sticky MIGRATE_MOVABLE,
is the right solution here. We already uses MIGRATE_CMA for that purpose
and it is proved that it doesn't work well.

If someone still disagree with ZONE_CMA approach, please let me know
what is the problem of this approach and how to solve these real problems
in more detail.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
