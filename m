Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id D4D416B0032
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 02:30:09 -0500 (EST)
Received: by pdjz10 with SMTP id z10so10202484pdj.0
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 23:30:09 -0800 (PST)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id gw10si3812394pbd.213.2015.02.11.23.30.07
        for <linux-mm@kvack.org>;
        Wed, 11 Feb 2015 23:30:08 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [RFC 00/16] Introduce ZONE_CMA
Date: Thu, 12 Feb 2015 16:32:04 +0900
Message-Id: <1423726340-4084-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Heesub Shin <heesub.shin@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hui Zhu <zhuhui@xiaomi.com>, Gioh Kim <gioh.kim@lge.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Ritesh Harjani <ritesh.list@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Hello,

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

Anyway, this patchset solves three problems in CMA all at once.

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

3) Incorrect watermark check problem
Currently, although we have statistics for number of freepage per order
in the zone, there is no statistics for number of CMA freepage per order.
This causes incorrect freepage calculation on high order allocation
request. For unmovable and reclaimable allocation request, we can't use
CMA freepage so we should subtract it's number on freepage calculation.
But, because we don't have such value per order, we will do incorrect
calculation. Currently, we did some trick and watermark check would be
passed with more relaxed condition [4]. With the new zone, we don't
need to worry about correct calculation because watermark check for
ZONE_CMA is invoked only by who can use CMA freepage so problem would
disappear itself.

There is one disadvantage from this implementation.

1) Break non-overlapped zone assumption
CMA regions could be spread to all memory range, so, to keep all of them
into one zone, span of ZONE_CMA would be overlap to other zones'.
I'm not sure that there is an assumption about possibility of zone overlap
But, if ZONE_CMA is introduced, this assumption becomes reality
so we should deal with this situation. I investigated most of sites
that iterates pfn on certain zone and found that they normally doesn't
consider zone overlap. I tried to handle these cases by myself in the
early of this series. I hope that there is no more site that depends on
non-overlap zone assumption when iterating pfn on certain zone.

I passed boot test on x86, ARM32 and ARM64. I did some stress tests
on x86 and there is no problem. Feel free to enjoy and please give me
a feedback. :)

This patchset is based on v3.18.

Thanks.

[1] https://lkml.org/lkml/2014/5/28/64
[2] https://lkml.org/lkml/2014/11/4/55 
[3] https://lkml.org/lkml/2014/10/15/623
[4] https://lkml.org/lkml/2014/5/30/320


Joonsoo Kim (16):
  mm/page_alloc: correct highmem memory statistics
  mm/writeback: correct dirty page calculation for highmem
  mm/highmem: make nr_free_highpages() handles all highmem zones by
    itself
  mm/vmstat: make node_page_state() handles all zones by itself
  mm/vmstat: watch out zone range overlap
  mm/page_alloc: watch out zone range overlap
  mm/page_isolation: watch out zone range overlap
  power: watch out zone range overlap
  mm/cma: introduce cma_total_pages() for future use
  mm/highmem: remove is_highmem_idx()
  mm/page_alloc: clean-up free_area_init_core()
  mm/cma: introduce new zone, ZONE_CMA
  mm/cma: populate ZONE_CMA and use this zone when GFP_HIGHUSERMOVABLE
  mm/cma: print stealed page count
  mm/cma: remove ALLOC_CMA
  mm/cma: remove MIGRATE_CMA

 arch/x86/include/asm/sparsemem.h  |    2 +-
 arch/x86/mm/highmem_32.c          |    3 +
 include/linux/cma.h               |    9 ++
 include/linux/gfp.h               |   31 +++---
 include/linux/mempolicy.h         |    2 +-
 include/linux/mm.h                |    1 +
 include/linux/mmzone.h            |   58 +++++-----
 include/linux/page-flags-layout.h |    2 +
 include/linux/vm_event_item.h     |    8 +-
 include/linux/vmstat.h            |   26 +----
 kernel/power/snapshot.c           |   15 +++
 lib/show_mem.c                    |    2 +-
 mm/cma.c                          |   70 ++++++++++--
 mm/compaction.c                   |    6 +-
 mm/highmem.c                      |   12 +-
 mm/hugetlb.c                      |    2 +-
 mm/internal.h                     |    3 +-
 mm/memory_hotplug.c               |    3 +
 mm/mempolicy.c                    |    3 +-
 mm/page-writeback.c               |    8 +-
 mm/page_alloc.c                   |  223 +++++++++++++++++++++----------------
 mm/page_isolation.c               |   14 ++-
 mm/vmscan.c                       |    2 +-
 mm/vmstat.c                       |   16 ++-
 24 files changed, 317 insertions(+), 204 deletions(-)

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
