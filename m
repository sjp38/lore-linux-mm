Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 233D46B0390
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 23:17:36 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id m66so134905517pga.15
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 20:17:36 -0700 (PDT)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id e3si15431330plb.171.2017.04.10.20.17.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Apr 2017 20:17:34 -0700 (PDT)
Received: by mail-pg0-x241.google.com with SMTP id 81so28018515pgh.3
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 20:17:34 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH v7 0/7] Introduce ZONE_CMA
Date: Tue, 11 Apr 2017 12:17:13 +0900
Message-Id: <1491880640-9944-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@lge.com, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Changed from v6
o Rebase on next-20170405
o Add a fix for lowmem mapping on ARM (last patch)
o Re-organize the cover letter

Changes from v5
o Rebase on next-20161013
o Cosmetic change on patch 1
o Optimize span of ZONE_CMA on multiple node system

Changes from v4
o Rebase on next-20160825
o Add general fix patch for lowmem reserve
o Fix lowmem reserve ratio
o Fix zone span optimizaion per Vlastimil
o Fix pageset initialization
o Change invocation timing on cma_init_reserved_areas()

Changes from v3
o Rebase on next-20160805
o Split first patch per Vlastimil
o Remove useless function parameter per Vlastimil
o Add code comment per Vlastimil
o Add following description on cover-letter

Changes from v2
o Rebase on next-20160525
o No other changes except following description

Changes from v1
o Separate some patches which deserve to submit independently
o Modify description to reflect current kernel state
(e.g. high-order watermark problem disappeared by Mel's work)
o Don't increase SECTION_SIZE_BITS to make a room in page flags
(detailed reason is on the patch that adds ZONE_CMA)
o Adjust ZONE_CMA population code


Hello,

This is the 7th version of ZONE_CMA patchset. One patch is added
to fix potential problem on ARM. Other changes are just due to rebase.

This patchset has long history and got some reviews before. This
cover-letter has the summary and my opinion on those reviews. Content
order is so confusing so I make a simple index. If anyone want to
understand the history properly, please read them by reverse order.

PART 1. Strong points of the zone approach
PART 2. Summary in LSF/MM 2016 discussion
PART 3. Original motivation of this patchset

***** PART 1 *****

CMA has many problems and I mentioned them on the bottom of the
cover letter. These problems comes from limitation of CMA memory that
should be always migratable for device usage. I think that introducing
a new zone is the best approach to solve them. Here are the reasons.

Zone is introduced to solve some issues due to H/W addressing limitation.
MM subsystem is implemented to work efficiently with these zones.
Allocation/reclaim logic in MM consider this limitation very much.
What I did in this patchset is introducing a new zone and extending zone's
concept slightly. New concept is that zone can have not only H/W addressing
limitation but also S/W limitation to guarantee page migration.
This concept is originated from ZONE_MOVABLE and it works well
for a long time. So, ZONE_CMA should not be special at this moment.

There is a major concern from Mel that ZONE_MOVABLE which has
S/W limitation causes highmem/lowmem problem. Highmem/lowmem problem is
that some of memory cannot be usable for kernel memory due to limitation
of the zone. It causes to break LRU ordering and makes hard to find kernel
usable memory when memory pressure.

However, important point is that this problem doesn't come from
implementation detail (ZONE_MOVABLE/MIGRATETYPE). Even if we implement it
by MIGRATETYPE instead of by ZONE_MOVABLE, we cannot use that type of
memory for kernel allocation because it isn't migratable. So, it will cause
to break LRU ordering, too. We cannot avoid the problem in any case.
Therefore, we should focus on which solution is better for maintenance
and not intrusive for MM subsystem.

In this viewpoint, I think that zone approach is better. As mentioned
earlier, MM subsystem already have many infrastructures to deal with
zone's H/W addressing limitation. Adding S/W limitation on zone concept
and adding a new zone doesn't change anything. It will work by itself.
My patchset can remove many hooks related to CMA area management in MM
while solving the problems. More hooks are required to solve the problems
if we choose MIGRATETYPE approach.

Although Mel withdrew the review, Vlastimil expressed an agreement on this
new zone approach [6].

 "I realize I differ here from much more experienced mm guys, and will
 probably deservingly regret it later on, but I think that the ZONE_CMA
 approach could work indeed better than current MIGRATE_CMA pageblocks."

If anyone has a different opinion, please let me know.

Thanks.

***** PART 2 *****

There was a discussion with Mel [5] after LSF/MM 2016. I could summarise
it to help merge decision but it's better to read by yourself since
if I summarise it, it would be biased for me. But, if anyone hope
the summary, I will do it. :)

Anyway, Mel's position on this patchset seems to be neutral. He saids:
"I'm not going to outright NAK your series but I won't ACK it either"

We can fix the problems with any approach but I hope to go a new zone
approach because it is less error-prone. It reduces some corner case
handling for now and remove need for potential corner case handling to fix
problems.

Note that our company is already using ZONE_CMA and there is no problem.

If anyone has a different opinion, please let me know and let's discuss
together.

Andrew, if there is something to do for merge, please let me know.

***** PART 3 *****

This series try to solve problems of current CMA implementation.

CMA is introduced to provide physically contiguous pages at runtime
without exclusive reserved memory area. But, current implementation
works like as previous reserved memory approach, because freepages
on CMA region are used only if there is no movable freepage. In other
words, freepages on CMA region are only used as fallback. In that
situation where freepages on CMA region are used as fallback, kswapd
would be woken up easily since there is no unmovable and reclaimable
freepage, too. If kswapd starts to reclaim memory, fallback allocation
to MIGRATE_CMA doesn't occur any more since movable freepages are
already refilled by kswapd and then most of freepage on CMA are left
to be in free. This situation looks like exclusive reserved memory case.

In my experiment, I found that if system memory has 1024 MB memory and
512 MB is reserved for CMA, kswapd is mostly woken up when roughly 512 MB
free memory is left. Detailed reason is that for keeping enough free
memory for unmovable and reclaimable allocation, kswapd uses below
equation when calculating free memory and it easily go under the watermark.

Free memory for unmovable and reclaimable = Free total - Free CMA pages

This is derivated from the property of CMA freepage that CMA freepage
can't be used for unmovable and reclaimable allocation.

Anyway, in this case, kswapd are woken up when (FreeTotal - FreeCMA)
is lower than low watermark and tries to make free memory until
(FreeTotal - FreeCMA) is higher than high watermark. That results
in that FreeTotal is moving around 512MB boundary consistently. It
then means that we can't utilize full memory capacity.

To fix this problem, I submitted some patches [1] about 10 months ago,
but, found some more problems to be fixed before solving this problem.
It requires many hooks in allocator hotpath so some developers doesn't
like it. Instead, some of them suggest different approach [2] to fix
all the problems related to CMA, that is, introducing a new zone to deal
with free CMA pages. I agree that it is the best way to go so implement
here. Although properties of ZONE_MOVABLE and ZONE_CMA is similar, I
decide to add a new zone rather than piggyback on ZONE_MOVABLE since
they have some differences. First, reserved CMA pages should not be
offlined. If freepage for CMA is managed by ZONE_MOVABLE, we need to keep
MIGRATE_CMA migratetype and insert many hooks on memory hotplug code
to distiguish hotpluggable memory and reserved memory for CMA in the same
zone. It would make memory hotplug code which is already complicated
more complicated. Second, cma_alloc() can be called more frequently
than memory hotplug operation and possibly we need to control
allocation rate of ZONE_CMA to optimize latency in the future.
In this case, separate zone approach is easy to modify. Third, I'd
like to see statistics for CMA, separately. Sometimes, we need to debug
why cma_alloc() is failed and separate statistics would be more helpful
in this situtaion.

Anyway, this patchset solves four problems related to CMA implementation.

1) Utilization problem
As mentioned above, we can't utilize full memory capacity due to the
limitation of CMA freepage and fallback policy. This patchset implements
a new zone for CMA and uses it for GFP_HIGHUSER_MOVABLE request. This
typed allocation is used for page cache and anonymous pages which
occupies most of memory usage in normal case so we can utilize full
memory capacity. Below is the experiment result about this problem.

8 CPUs, 1024 MB, VIRTUAL MACHINE
make -j16

<Before this series>
CMA reserve:            0 MB            512 MB
Elapsed-time:           92.4		186.5
pswpin:                 82		18647
pswpout:                160		69839

<After this series>
CMA reserve:            0 MB            512 MB
Elapsed-time:           93.1		93.4
pswpin:                 84		46
pswpout:                183		92

FYI, there is another attempt [3] trying to solve this problem in lkml.
And, as far as I know, Qualcomm also has out-of-tree solution for this
problem.

2) Reclaim problem
Currently, there is no logic to distinguish CMA pages in reclaim path.
If reclaim is initiated for unmovable and reclaimable allocation,
reclaiming CMA pages doesn't help to satisfy the request and reclaiming
CMA page is just waste. By managing CMA pages in the new zone, we can
skip to reclaim ZONE_CMA completely if it is unnecessary.

3) Atomic allocation failure problem
Kswapd isn't started to reclaim pages when allocation request is movable
type and there is enough free page in the CMA region. After bunch of
consecutive movable allocation requests, free pages in ordinary region
(not CMA region) would be exhausted without waking up kswapd. At that time,
if atomic unmovable allocation comes, it can't be successful since there
is not enough page in ordinary region. This problem is reported
by Aneesh [4] and can be solved by this patchset.

4) Inefficiently work of compaction
Usual high-order allocation request is unmovable type and it cannot
be serviced from CMA area. In compaction, migration scanner doesn't
distinguish migratable pages on the CMA area and do migration.
In this case, even if we make high-order page on that region, it
cannot be used due to type mismatch. This patch will solve this problem
by separating CMA pages from ordinary zones.

I passed boot test on x86_64, x86_32, arm and arm64. I did some stress
tests on x86_64 and x86_32 and there is no problem. Feel free to enjoy
and please give me a feedback. :)


Thanks.

[1] https://lkml.org/lkml/2014/5/28/64
[2] https://lkml.org/lkml/2014/11/4/55
[3] https://lkml.org/lkml/2014/10/15/623
[4] http://www.spinics.net/lists/linux-mm/msg100562.html
[5] https://lkml.kernel.org/r/20160425053653.GA25662@js1304-P5Q-DELUXE
[6] https://lkml.kernel.org/r/1919a85d-6e1e-374f-b8c3-1236c36b0393@suse.cz

Joonsoo Kim (7):
  mm/page_alloc: don't reserve ZONE_HIGHMEM for ZONE_MOVABLE request
  mm/cma: introduce new zone, ZONE_CMA
  mm/cma: populate ZONE_CMA
  mm/cma: remove ALLOC_CMA
  mm/cma: remove MIGRATE_CMA
  mm/cma: remove per zone CMA stat
  ARM: CMA: avoid re-mapping CMA region if CONFIG_HIGHMEM

 arch/arm/mm/dma-mapping.c           |   7 +-
 arch/powerpc/mm/mmu_context_iommu.c |   2 +-
 arch/x86/mm/highmem_32.c            |   8 ++
 fs/proc/meminfo.c                   |   2 +-
 include/linux/cma.h                 |   7 ++
 include/linux/gfp.h                 |  32 +++---
 include/linux/memory_hotplug.h      |   3 -
 include/linux/mempolicy.h           |   2 +-
 include/linux/mm.h                  |   1 +
 include/linux/mmzone.h              |  60 +++++-----
 include/linux/page-isolation.h      |   5 +-
 include/linux/vm_event_item.h       |  10 +-
 include/linux/vmstat.h              |   8 --
 include/trace/events/mmflags.h      |  10 +-
 kernel/power/snapshot.c             |   8 ++
 mm/cma.c                            |  78 +++++++++++--
 mm/compaction.c                     |  12 +-
 mm/hugetlb.c                        |   3 +-
 mm/internal.h                       |   4 +-
 mm/memory_hotplug.c                 |   7 +-
 mm/page_alloc.c                     | 220 ++++++++++++++++++------------------
 mm/page_isolation.c                 |  15 +--
 mm/page_owner.c                     |   6 +-
 mm/usercopy.c                       |   4 +-
 mm/vmstat.c                         |  10 +-
 25 files changed, 310 insertions(+), 214 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
