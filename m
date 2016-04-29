Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f199.google.com (mail-ig0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id 333386B0005
	for <linux-mm@kvack.org>; Fri, 29 Apr 2016 03:04:18 -0400 (EDT)
Received: by mail-ig0-f199.google.com with SMTP id z8so30811615igl.3
        for <linux-mm@kvack.org>; Fri, 29 Apr 2016 00:04:18 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id cp4si2953859igc.103.2016.04.29.00.04.16
        for <linux-mm@kvack.org>;
        Fri, 29 Apr 2016 00:04:17 -0700 (PDT)
Date: Fri, 29 Apr 2016 16:04:27 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 2/6] mm/cma: introduce new zone, ZONE_CMA
Message-ID: <20160429070426.GC19896@js1304-P5Q-DELUXE>
References: <1461561670-28012-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1461561670-28012-3-git-send-email-iamjoonsoo.kim@lge.com>
 <71acbf31-aba5-c6c3-9336-296ce1d8ad51@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <71acbf31-aba5-c6c3-9336-296ce1d8ad51@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rui Teng <rui.teng@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Apr 26, 2016 at 05:38:18PM +0800, Rui Teng wrote:
> On 4/25/16 1:21 PM, js1304@gmail.com wrote:
> >From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >
> >Attached cover-letter:
> >
> >This series try to solve problems of current CMA implementation.
> >
> >CMA is introduced to provide physically contiguous pages at runtime
> >without exclusive reserved memory area. But, current implementation
> >works like as previous reserved memory approach, because freepages
> >on CMA region are used only if there is no movable freepage. In other
> >words, freepages on CMA region are only used as fallback. In that
> >situation where freepages on CMA region are used as fallback, kswapd
> >would be woken up easily since there is no unmovable and reclaimable
> >freepage, too. If kswapd starts to reclaim memory, fallback allocation
> >to MIGRATE_CMA doesn't occur any more since movable freepages are
> >already refilled by kswapd and then most of freepage on CMA are left
> >to be in free. This situation looks like exclusive reserved memory case.
> >
> >In my experiment, I found that if system memory has 1024 MB memory and
> >512 MB is reserved for CMA, kswapd is mostly woken up when roughly 512 MB
> >free memory is left. Detailed reason is that for keeping enough free
> >memory for unmovable and reclaimable allocation, kswapd uses below
> >equation when calculating free memory and it easily go under the watermark.
> >
> >Free memory for unmovable and reclaimable = Free total - Free CMA pages
> >
> >This is derivated from the property of CMA freepage that CMA freepage
> >can't be used for unmovable and reclaimable allocation.
> >
> >Anyway, in this case, kswapd are woken up when (FreeTotal - FreeCMA)
> >is lower than low watermark and tries to make free memory until
> >(FreeTotal - FreeCMA) is higher than high watermark. That results
> >in that FreeTotal is moving around 512MB boundary consistently. It
> >then means that we can't utilize full memory capacity.
> >
> >To fix this problem, I submitted some patches [1] about 10 months ago,
> >but, found some more problems to be fixed before solving this problem.
> >It requires many hooks in allocator hotpath so some developers doesn't
> >like it. Instead, some of them suggest different approach [2] to fix
> >all the problems related to CMA, that is, introducing a new zone to deal
> >with free CMA pages. I agree that it is the best way to go so implement
> >here. Although properties of ZONE_MOVABLE and ZONE_CMA is similar, I
> >decide to add a new zone rather than piggyback on ZONE_MOVABLE since
> >they have some differences. First, reserved CMA pages should not be
> >offlined. If freepage for CMA is managed by ZONE_MOVABLE, we need to keep
> >MIGRATE_CMA migratetype and insert many hooks on memory hotplug code
> >to distiguish hotpluggable memory and reserved memory for CMA in the same
> >zone. It would make memory hotplug code which is already complicated
> >more complicated. Second, cma_alloc() can be called more frequently
> >than memory hotplug operation and possibly we need to control
> >allocation rate of ZONE_CMA to optimize latency in the future.
> >In this case, separate zone approach is easy to modify. Third, I'd
> >like to see statistics for CMA, separately. Sometimes, we need to debug
> >why cma_alloc() is failed and separate statistics would be more helpful
> >in this situtaion.
> >
> >Anyway, this patchset solves four problems related to CMA implementation.
> >
> >1) Utilization problem
> >As mentioned above, we can't utilize full memory capacity due to the
> >limitation of CMA freepage and fallback policy. This patchset implements
> >a new zone for CMA and uses it for GFP_HIGHUSER_MOVABLE request. This
> >typed allocation is used for page cache and anonymous pages which
> >occupies most of memory usage in normal case so we can utilize full
> >memory capacity. Below is the experiment result about this problem.
> >
> >8 CPUs, 1024 MB, VIRTUAL MACHINE
> >make -j16
> >
> ><Before this series>
> >CMA reserve:            0 MB            512 MB
> >Elapsed-time:           92.4		186.5
> >pswpin:                 82		18647
> >pswpout:                160		69839
> >
> ><After this series>
> >CMA reserve:            0 MB            512 MB
> >Elapsed-time:           93.1		93.4
> >pswpin:                 84		46
> >pswpout:                183		92
> >
> >FYI, there is another attempt [3] trying to solve this problem in lkml.
> >And, as far as I know, Qualcomm also has out-of-tree solution for this
> >problem.
> >
> >2) Reclaim problem
> >Currently, there is no logic to distinguish CMA pages in reclaim path.
> >If reclaim is initiated for unmovable and reclaimable allocation,
> >reclaiming CMA pages doesn't help to satisfy the request and reclaiming
> >CMA page is just waste. By managing CMA pages in the new zone, we can
> >skip to reclaim ZONE_CMA completely if it is unnecessary.
> >
> >3) Atomic allocation failure problem
> >Kswapd isn't started to reclaim pages when allocation request is movable
> >type and there is enough free page in the CMA region. After bunch of
> >consecutive movable allocation requests, free pages in ordinary region
> >(not CMA region) would be exhausted without waking up kswapd. At that time,
> >if atomic unmovable allocation comes, it can't be successful since there
> >is not enough page in ordinary region. This problem is reported
> >by Aneesh [4] and can be solved by this patchset.
> >
> >4) Inefficiently work of compaction
> >Usual high-order allocation request is unmovable type and it cannot
> >be serviced from CMA area. In compaction, migration scanner doesn't
> >distinguish migratable pages on the CMA area and do migration.
> >In this case, even if we make high-order page on that region, it
> >cannot be used due to type mismatch. This patch will solve this problem
> >by separating CMA pages from ordinary zones.
> >
> >[1] https://lkml.org/lkml/2014/5/28/64
> >[2] https://lkml.org/lkml/2014/11/4/55
> >[3] https://lkml.org/lkml/2014/10/15/623
> >[4] http://www.spinics.net/lists/linux-mm/msg100562.html
> >[5] https://lkml.org/lkml/2014/5/30/320
> >
> >For this patch:
> >
> >Currently, reserved pages for CMA are managed together with normal pages.
> >To distinguish them, we used migratetype, MIGRATE_CMA, and
> >do special handlings for this migratetype. But, it turns out that
> >there are too many problems with this approach and to fix all of them
> >needs many more hooks to page allocation and reclaim path so
> >some developers express their discomfort and problems on CMA aren't fixed
> >for a long time.
> >
> >To terminate this situation and fix CMA problems, this patch implements
> >ZONE_CMA. Reserved pages for CMA will be managed in this new zone. This
> >approach will remove all exisiting hooks for MIGRATE_CMA and many
> >problems related to CMA implementation will be solved.
> >
> >This patch only add basic infrastructure of ZONE_CMA. In the following
> >patch, ZONE_CMA is actually populated and used.
> >
> >Adding a new zone could cause two possible problems. One is the overflow
> >of page flags and the other is GFP_ZONES_TABLE issue.
> >
> >Following is page-flags layout described in page-flags-layout.h.
> >
> >1. No sparsemem or sparsemem vmemmap: |       NODE     | ZONE |             ... | FLAGS |
> >2.      " plus space for last_cpupid: |       NODE     | ZONE | LAST_CPUPID ... | FLAGS |
> >3. classic sparse with space for node:| SECTION | NODE | ZONE |             ... | FLAGS |
> >4.      " plus space for last_cpupid: | SECTION | NODE | ZONE | LAST_CPUPID ... | FLAGS |
> >5. classic sparse no space for node:  | SECTION |     ZONE    | ... | FLAGS |
> >
> >There is no problem in #1, #2 configurations for 64-bit system. There are
> >enough room even for extremiely large x86_64 system. 32-bit system would
> >not have many nodes so it would have no problem, too.
> >System with #3, #4, #5 configurations could be affected by this zone
> >addition, but, thanks to recent THP rework which reduce one page flag,
> >problem surface would be small. In some configurations, problem is
> >still possible, but, it highly depends on individual configuration
> >so impact cannot be easily estimated. I guess that usual system
> >with CONFIG_CMA would not be affected. If there is a problem,
> >we can adjust section width or node width for that architecture.
> >
> >Currently, GFP_ZONES_TABLE is 32-bit value for 32-bit bit operation
> >in the 32-bit system. If we add one more zone, it will be 48-bit and
> >32-bit bit operation cannot be possible. Although it will cause slight
> >overhead, there is no other way so this patch relax GFP_ZONES_TABLE's
> >32-bit limitation. 32-bit System with CONFIG_CMA will be affected by
> >this change but it would be marginal.
> >
> >Note that there are many checkpatch warnings but I think that current
> >code is better for readability than fixing them up.
> >
> >Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >---
> > arch/x86/mm/highmem_32.c          |  8 +++++
> > include/linux/gfp.h               | 29 +++++++++++-------
> > include/linux/mempolicy.h         |  2 +-
> > include/linux/mmzone.h            | 31 ++++++++++++++++++-
> > include/linux/vm_event_item.h     | 10 ++++++-
> > include/trace/events/compaction.h | 10 ++++++-
> > kernel/power/snapshot.c           |  8 +++++
> > mm/memory_hotplug.c               |  3 ++
> > mm/page_alloc.c                   | 63 +++++++++++++++++++++++++++++++++------
> > mm/vmstat.c                       |  9 +++++-
> > 10 files changed, 148 insertions(+), 25 deletions(-)
> >
> >diff --git a/arch/x86/mm/highmem_32.c b/arch/x86/mm/highmem_32.c
> >index a6d7392..a7fcb12 100644
> >--- a/arch/x86/mm/highmem_32.c
> >+++ b/arch/x86/mm/highmem_32.c
> >@@ -120,6 +120,14 @@ void __init set_highmem_pages_init(void)
> > 		if (!is_highmem(zone))
> > 			continue;
> >
> >+		/*
> >+		 * ZONE_CMA is a special zone that should not be
> >+		 * participated in initialization because it's pages
> >+		 * would be initialized by initialization of other zones.
> >+		 */
> >+		if (is_zone_cma(zone))
> >+			continue;
> >+
> > 		zone_start_pfn = zone->zone_start_pfn;
> > 		zone_end_pfn = zone_start_pfn + zone->spanned_pages;
> >
> >diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> >index 570383a..4d6c008 100644
> >--- a/include/linux/gfp.h
> >+++ b/include/linux/gfp.h
> >@@ -301,6 +301,12 @@ static inline bool gfpflags_allow_blocking(const gfp_t gfp_flags)
> > #define OPT_ZONE_DMA32 ZONE_NORMAL
> > #endif
> >
> >+#ifdef CONFIG_CMA
> >+#define OPT_ZONE_CMA ZONE_CMA
> >+#else
> >+#define OPT_ZONE_CMA ZONE_MOVABLE
> >+#endif
> >+
> > /*
> >  * GFP_ZONE_TABLE is a word size bitstring that is used for looking up the
> >  * zone to use given the lowest 4 bits of gfp_t. Entries are ZONE_SHIFT long
> >@@ -331,7 +337,6 @@ static inline bool gfpflags_allow_blocking(const gfp_t gfp_flags)
> >  *       0xe    => BAD (MOVABLE+DMA32+HIGHMEM)
> >  *       0xf    => BAD (MOVABLE+DMA32+HIGHMEM+DMA)
> >  *
> >- * GFP_ZONES_SHIFT must be <= 2 on 32 bit platforms.
> >  */
> >
> > #if defined(CONFIG_ZONE_DEVICE) && (MAX_NR_ZONES-1) <= 4
> >@@ -341,19 +346,21 @@ static inline bool gfpflags_allow_blocking(const gfp_t gfp_flags)
> > #define GFP_ZONES_SHIFT ZONES_SHIFT
> > #endif
> >
> >-#if 16 * GFP_ZONES_SHIFT > BITS_PER_LONG
> >-#error GFP_ZONES_SHIFT too large to create GFP_ZONE_TABLE integer
> >+#if !defined(CONFIG_64BITS) && GFP_ZONES_SHIFT > 2
> >+#define GFP_ZONE_TABLE_CAST unsigned long long
> >+#else
> >+#define GFP_ZONE_TABLE_CAST unsigned long
> > #endif
> >
> > #define GFP_ZONE_TABLE ( \
> >-	(ZONE_NORMAL << 0 * GFP_ZONES_SHIFT)				       \
> >-	| (OPT_ZONE_DMA << ___GFP_DMA * GFP_ZONES_SHIFT)		       \
> >-	| (OPT_ZONE_HIGHMEM << ___GFP_HIGHMEM * GFP_ZONES_SHIFT)	       \
> >-	| (OPT_ZONE_DMA32 << ___GFP_DMA32 * GFP_ZONES_SHIFT)		       \
> >-	| (ZONE_NORMAL << ___GFP_MOVABLE * GFP_ZONES_SHIFT)		       \
> >-	| (OPT_ZONE_DMA << (___GFP_MOVABLE | ___GFP_DMA) * GFP_ZONES_SHIFT)    \
> >-	| (ZONE_MOVABLE << (___GFP_MOVABLE | ___GFP_HIGHMEM) * GFP_ZONES_SHIFT)\
> >-	| (OPT_ZONE_DMA32 << (___GFP_MOVABLE | ___GFP_DMA32) * GFP_ZONES_SHIFT)\
> >+	((GFP_ZONE_TABLE_CAST) ZONE_NORMAL << 0 * GFP_ZONES_SHIFT)					\
> >+	| ((GFP_ZONE_TABLE_CAST) OPT_ZONE_DMA << ___GFP_DMA * GFP_ZONES_SHIFT)				\
> >+	| ((GFP_ZONE_TABLE_CAST) OPT_ZONE_HIGHMEM << ___GFP_HIGHMEM * GFP_ZONES_SHIFT)			\
> >+	| ((GFP_ZONE_TABLE_CAST) OPT_ZONE_DMA32 << ___GFP_DMA32 * GFP_ZONES_SHIFT)			\
> >+	| ((GFP_ZONE_TABLE_CAST) ZONE_NORMAL << ___GFP_MOVABLE * GFP_ZONES_SHIFT)			\
> >+	| ((GFP_ZONE_TABLE_CAST) OPT_ZONE_DMA << (___GFP_MOVABLE | ___GFP_DMA) * GFP_ZONES_SHIFT)	\
> >+	| ((GFP_ZONE_TABLE_CAST) OPT_ZONE_CMA << (___GFP_MOVABLE | ___GFP_HIGHMEM) * GFP_ZONES_SHIFT)	\
> >+	| ((GFP_ZONE_TABLE_CAST) OPT_ZONE_DMA32 << (___GFP_MOVABLE | ___GFP_DMA32) * GFP_ZONES_SHIFT)	\
> > )
> >
> > /*
> >diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
> >index 4429d25..c4cc86e 100644
> >--- a/include/linux/mempolicy.h
> >+++ b/include/linux/mempolicy.h
> >@@ -157,7 +157,7 @@ extern enum zone_type policy_zone;
> >
> > static inline void check_highest_zone(enum zone_type k)
> > {
> >-	if (k > policy_zone && k != ZONE_MOVABLE)
> >+	if (k > policy_zone && k != ZONE_MOVABLE && !is_zone_cma_idx(k))
> > 		policy_zone = k;
> > }
> >
> >diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> >index f4ae0abb..5c97ba9 100644
> >--- a/include/linux/mmzone.h
> >+++ b/include/linux/mmzone.h
> >@@ -322,6 +322,9 @@ enum zone_type {
> > 	ZONE_HIGHMEM,
> > #endif
> > 	ZONE_MOVABLE,
> >+#ifdef CONFIG_CMA
> >+	ZONE_CMA,
> >+#endif
> > #ifdef CONFIG_ZONE_DEVICE
> > 	ZONE_DEVICE,
> > #endif
> >@@ -812,11 +815,37 @@ static inline int zone_movable_is_highmem(void)
> > }
> > #endif
> >
> >+static inline int is_zone_cma_idx(enum zone_type idx)
> >+{
> >+#ifdef CONFIG_CMA
> >+	return idx == ZONE_CMA;
> >+#else
> >+	return 0;
> >+#endif
> >+}
> >+
> >+static inline int is_zone_cma(struct zone *zone)
> >+{
> >+	int zone_idx = zone_idx(zone);
> >+
> >+	return is_zone_cma_idx(zone_idx);
> >+}
> >+
> >+static inline int zone_cma_is_highmem(void)
> >+{
> >+#ifdef CONFIG_HIGHMEM
> 
> Whether it needs to check the CONFIG_CMA here also?

It's not necessary because zone_cma_is_highmem() will be called
after checking whether zone is CMA or not.

> 
> >+	return 1;
> >+#else
> >+	return 0;
> >+#endif
> >+}
> >+
> > static inline int is_highmem_idx(enum zone_type idx)
> > {
> > #ifdef CONFIG_HIGHMEM
> > 	return (idx == ZONE_HIGHMEM ||
> >-		(idx == ZONE_MOVABLE && zone_movable_is_highmem()));
> >+		(idx == ZONE_MOVABLE && zone_movable_is_highmem()) ||
> >+		(is_zone_cma_idx(idx) && zone_cma_is_highmem()));
> 
> When CONFIG_HIGHMEM defined, zone_cma_is_highmem() will always return 1.
> I think it is not necessary to call the function here, and even define
> it.

We can remove it. But, I'd like to remain it because we can do similar
thing like as ZONE_MOVABLE which don't unconditionally set highmem bit
through checking memory map.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
