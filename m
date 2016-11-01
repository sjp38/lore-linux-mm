Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 773996B02A6
	for <linux-mm@kvack.org>; Tue,  1 Nov 2016 04:00:31 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id o20so15191279lfg.2
        for <linux-mm@kvack.org>; Tue, 01 Nov 2016 01:00:31 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id k137si18115927lfe.1.2016.11.01.01.00.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 01 Nov 2016 01:00:29 -0700 (PDT)
Subject: Re: [PATCH v6 2/6] mm/cma: introduce new zone, ZONE_CMA
References: <1476414196-3514-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1476414196-3514-3-git-send-email-iamjoonsoo.kim@lge.com>
From: Chen Feng <puck.chen@hisilicon.com>
Message-ID: <58184B28.8090405@hisilicon.com>
Date: Tue, 1 Nov 2016 15:58:32 +0800
MIME-Version: 1.0
In-Reply-To: <1476414196-3514-3-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh
 Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Hello, I hava a question on cma zone.

When we have cma zone, cma zone will be the highest zone of system.

In android system, the most memory allocator is ION. Media system will
alloc unmovable memory from it.

On low memory scene, will the CMA zone always do balance?

Should we transmit the highest available zone to kswapdi 1/4 ?

On 2016/10/14 11:03, js1304@gmail.com wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> Attached cover-letter:
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
> [1] https://lkml.org/lkml/2014/5/28/64
> [2] https://lkml.org/lkml/2014/11/4/55
> [3] https://lkml.org/lkml/2014/10/15/623
> [4] http://www.spinics.net/lists/linux-mm/msg100562.html
> [5] https://lkml.org/lkml/2014/5/30/320
> 
> For this patch:
> 
> Currently, reserved pages for CMA are managed together with normal pages.
> To distinguish them, we used migratetype, MIGRATE_CMA, and
> do special handlings for this migratetype. But, it turns out that
> there are too many problems with this approach and to fix all of them
> needs many more hooks to page allocation and reclaim path so
> some developers express their discomfort and problems on CMA aren't fixed
> for a long time.
> 
> To terminate this situation and fix CMA problems, this patch implements
> ZONE_CMA. Reserved pages for CMA will be managed in this new zone. This
> approach will remove all exisiting hooks for MIGRATE_CMA and many
> problems related to CMA implementation will be solved.
> 
> This patch only add basic infrastructure of ZONE_CMA. In the following
> patch, ZONE_CMA is actually populated and used.
> 
> Adding a new zone could cause two possible problems. One is the overflow
> of page flags and the other is GFP_ZONES_TABLE issue.
> 
> Following is page-flags layout described in page-flags-layout.h.
> 
> 1. No sparsemem or sparsemem vmemmap: |       NODE     | ZONE |             ... | FLAGS |
> 2.      " plus space for last_cpupid: |       NODE     | ZONE | LAST_CPUPID ... | FLAGS |
> 3. classic sparse with space for node:| SECTION | NODE | ZONE |             ... | FLAGS |
> 4.      " plus space for last_cpupid: | SECTION | NODE | ZONE | LAST_CPUPID ... | FLAGS |
> 5. classic sparse no space for node:  | SECTION |     ZONE    | ... | FLAGS |
> 
> There is no problem in #1, #2 configurations for 64-bit system. There are
> enough room even for extremiely large x86_64 system. 32-bit system would
> not have many nodes so it would have no problem, too.
> System with #3, #4, #5 configurations could be affected by this zone
> addition, but, thanks to recent THP rework which reduce one page flag,
> problem surface would be small. In some configurations, problem is
> still possible, but, it highly depends on individual configuration
> so impact cannot be easily estimated. I guess that usual system
> with CONFIG_CMA would not be affected. If there is a problem,
> we can adjust section width or node width for that architecture.
> 
> Currently, GFP_ZONES_TABLE is 32-bit value for 32-bit bit operation
> in the 32-bit system. If we add one more zone, it will be 48-bit and
> 32-bit bit operation cannot be possible. Although it will cause slight
> overhead, there is no other way so this patch relax GFP_ZONES_TABLE's
> 32-bit limitation. 32-bit System with CONFIG_CMA will be affected by
> this change but it would be marginal.
> 
> Note that there are many checkpatch warnings but I think that current
> code is better for readability than fixing them up.
> 
> Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>  arch/x86/mm/highmem_32.c          |  8 +++++
>  include/linux/gfp.h               | 29 +++++++++++-------
>  include/linux/mempolicy.h         |  2 +-
>  include/linux/mmzone.h            | 31 +++++++++++++++++++-
>  include/linux/vm_event_item.h     | 10 ++++++-
>  include/trace/events/compaction.h | 10 ++++++-
>  kernel/power/snapshot.c           |  8 +++++
>  mm/memory_hotplug.c               |  3 ++
>  mm/page_alloc.c                   | 62 +++++++++++++++++++++++++++++++++------
>  mm/vmstat.c                       |  9 +++++-
>  10 files changed, 147 insertions(+), 25 deletions(-)
> 
> diff --git a/arch/x86/mm/highmem_32.c b/arch/x86/mm/highmem_32.c
> index 6d18b70..52a14da 100644
> --- a/arch/x86/mm/highmem_32.c
> +++ b/arch/x86/mm/highmem_32.c
> @@ -120,6 +120,14 @@ void __init set_highmem_pages_init(void)
>  		if (!is_highmem(zone))
>  			continue;
>  
> +		/*
> +		 * ZONE_CMA is a special zone that should not be
> +		 * participated in initialization because it's pages
> +		 * would be initialized by initialization of other zones.
> +		 */
> +		if (is_zone_cma(zone))
> +			continue;
> +
>  		zone_start_pfn = zone->zone_start_pfn;
>  		zone_end_pfn = zone_start_pfn + zone->spanned_pages;
>  
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index f8041f9de..b86e0c2 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -302,6 +302,12 @@ static inline bool gfpflags_allow_blocking(const gfp_t gfp_flags)
>  #define OPT_ZONE_DMA32 ZONE_NORMAL
>  #endif
>  
> +#ifdef CONFIG_CMA
> +#define OPT_ZONE_CMA ZONE_CMA
> +#else
> +#define OPT_ZONE_CMA ZONE_MOVABLE
> +#endif
> +
>  /*
>   * GFP_ZONE_TABLE is a word size bitstring that is used for looking up the
>   * zone to use given the lowest 4 bits of gfp_t. Entries are ZONE_SHIFT long
> @@ -332,7 +338,6 @@ static inline bool gfpflags_allow_blocking(const gfp_t gfp_flags)
>   *       0xe    => BAD (MOVABLE+DMA32+HIGHMEM)
>   *       0xf    => BAD (MOVABLE+DMA32+HIGHMEM+DMA)
>   *
> - * GFP_ZONES_SHIFT must be <= 2 on 32 bit platforms.
>   */
>  
>  #if defined(CONFIG_ZONE_DEVICE) && (MAX_NR_ZONES-1) <= 4
> @@ -342,19 +347,21 @@ static inline bool gfpflags_allow_blocking(const gfp_t gfp_flags)
>  #define GFP_ZONES_SHIFT ZONES_SHIFT
>  #endif
>  
> -#if 16 * GFP_ZONES_SHIFT > BITS_PER_LONG
> -#error GFP_ZONES_SHIFT too large to create GFP_ZONE_TABLE integer
> +#if !defined(CONFIG_64BITS) && GFP_ZONES_SHIFT > 2
> +#define GFP_ZONE_TABLE_CAST unsigned long long
> +#else
> +#define GFP_ZONE_TABLE_CAST unsigned long
>  #endif
>  
>  #define GFP_ZONE_TABLE ( \
> -	(ZONE_NORMAL << 0 * GFP_ZONES_SHIFT)				       \
> -	| (OPT_ZONE_DMA << ___GFP_DMA * GFP_ZONES_SHIFT)		       \
> -	| (OPT_ZONE_HIGHMEM << ___GFP_HIGHMEM * GFP_ZONES_SHIFT)	       \
> -	| (OPT_ZONE_DMA32 << ___GFP_DMA32 * GFP_ZONES_SHIFT)		       \
> -	| (ZONE_NORMAL << ___GFP_MOVABLE * GFP_ZONES_SHIFT)		       \
> -	| (OPT_ZONE_DMA << (___GFP_MOVABLE | ___GFP_DMA) * GFP_ZONES_SHIFT)    \
> -	| (ZONE_MOVABLE << (___GFP_MOVABLE | ___GFP_HIGHMEM) * GFP_ZONES_SHIFT)\
> -	| (OPT_ZONE_DMA32 << (___GFP_MOVABLE | ___GFP_DMA32) * GFP_ZONES_SHIFT)\
> +	((GFP_ZONE_TABLE_CAST) ZONE_NORMAL << 0 * GFP_ZONES_SHIFT)					\
> +	| ((GFP_ZONE_TABLE_CAST) OPT_ZONE_DMA << ___GFP_DMA * GFP_ZONES_SHIFT)				\
> +	| ((GFP_ZONE_TABLE_CAST) OPT_ZONE_HIGHMEM << ___GFP_HIGHMEM * GFP_ZONES_SHIFT)			\
> +	| ((GFP_ZONE_TABLE_CAST) OPT_ZONE_DMA32 << ___GFP_DMA32 * GFP_ZONES_SHIFT)			\
> +	| ((GFP_ZONE_TABLE_CAST) ZONE_NORMAL << ___GFP_MOVABLE * GFP_ZONES_SHIFT)			\
> +	| ((GFP_ZONE_TABLE_CAST) OPT_ZONE_DMA << (___GFP_MOVABLE | ___GFP_DMA) * GFP_ZONES_SHIFT)	\
> +	| ((GFP_ZONE_TABLE_CAST) OPT_ZONE_CMA << (___GFP_MOVABLE | ___GFP_HIGHMEM) * GFP_ZONES_SHIFT)	\
> +	| ((GFP_ZONE_TABLE_CAST) OPT_ZONE_DMA32 << (___GFP_MOVABLE | ___GFP_DMA32) * GFP_ZONES_SHIFT)	\
>  )
>  
>  /*
> diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
> index 5e5b296..150259f 100644
> --- a/include/linux/mempolicy.h
> +++ b/include/linux/mempolicy.h
> @@ -157,7 +157,7 @@ extern bool mempolicy_nodemask_intersects(struct task_struct *tsk,
>  
>  static inline void check_highest_zone(enum zone_type k)
>  {
> -	if (k > policy_zone && k != ZONE_MOVABLE)
> +	if (k > policy_zone && k != ZONE_MOVABLE && !is_zone_cma_idx(k))
>  		policy_zone = k;
>  }
>  
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index bd30fc1..41faf59 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -334,6 +334,9 @@ enum zone_type {
>  	ZONE_HIGHMEM,
>  #endif
>  	ZONE_MOVABLE,
> +#ifdef CONFIG_CMA
> +	ZONE_CMA,
> +#endif
>  #ifdef CONFIG_ZONE_DEVICE
>  	ZONE_DEVICE,
>  #endif
> @@ -858,11 +861,37 @@ static inline int zone_movable_is_highmem(void)
>  }
>  #endif
>  
> +static inline int is_zone_cma_idx(enum zone_type idx)
> +{
> +#ifdef CONFIG_CMA
> +	return idx == ZONE_CMA;
> +#else
> +	return 0;
> +#endif
> +}
> +
> +static inline int is_zone_cma(struct zone *zone)
> +{
> +	int zone_idx = zone_idx(zone);
> +
> +	return is_zone_cma_idx(zone_idx);
> +}
> +
> +static inline int zone_cma_is_highmem(void)
> +{
> +#ifdef CONFIG_HIGHMEM
> +	return 1;
> +#else
> +	return 0;
> +#endif
> +}
> +
>  static inline int is_highmem_idx(enum zone_type idx)
>  {
>  #ifdef CONFIG_HIGHMEM
>  	return (idx == ZONE_HIGHMEM ||
> -		(idx == ZONE_MOVABLE && zone_movable_is_highmem()));
> +		(idx == ZONE_MOVABLE && zone_movable_is_highmem()) ||
> +		(is_zone_cma_idx(idx) && zone_cma_is_highmem()));
>  #else
>  	return 0;
>  #endif
> diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
> index 4d6ec58..2ff89d4 100644
> --- a/include/linux/vm_event_item.h
> +++ b/include/linux/vm_event_item.h
> @@ -19,7 +19,15 @@
>  #define HIGHMEM_ZONE(xx)
>  #endif
>  
> -#define FOR_ALL_ZONES(xx) DMA_ZONE(xx) DMA32_ZONE(xx) xx##_NORMAL, HIGHMEM_ZONE(xx) xx##_MOVABLE
> +#ifdef CONFIG_CMA
> +#define MOVABLE_ZONE(xx) xx##_MOVABLE,
> +#define CMA_ZONE(xx) xx##_CMA
> +#else
> +#define MOVABLE_ZONE(xx) xx##_MOVABLE
> +#define CMA_ZONE(xx)
> +#endif
> +
> +#define FOR_ALL_ZONES(xx) DMA_ZONE(xx) DMA32_ZONE(xx) xx##_NORMAL, HIGHMEM_ZONE(xx) MOVABLE_ZONE(xx) CMA_ZONE(xx)
>  
>  enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
>  		FOR_ALL_ZONES(PGALLOC),
> diff --git a/include/trace/events/compaction.h b/include/trace/events/compaction.h
> index cbdb90b..25bb8402 100644
> --- a/include/trace/events/compaction.h
> +++ b/include/trace/events/compaction.h
> @@ -38,12 +38,20 @@
>  #define IFDEF_ZONE_HIGHMEM(X)
>  #endif
>  
> +#ifdef CONFIG_CMA
> +#define IFDEF_ZONE_CMA(X, Y, Z) X Z
> +#else
> +#define IFDEF_ZONE_CMA(X, Y, Z) Y
> +#endif
> +
>  #define ZONE_TYPE						\
>  	IFDEF_ZONE_DMA(		EM (ZONE_DMA,	 "DMA"))	\
>  	IFDEF_ZONE_DMA32(	EM (ZONE_DMA32,	 "DMA32"))	\
>  				EM (ZONE_NORMAL, "Normal")	\
>  	IFDEF_ZONE_HIGHMEM(	EM (ZONE_HIGHMEM,"HighMem"))	\
> -				EMe(ZONE_MOVABLE,"Movable")
> +	IFDEF_ZONE_CMA(		EM (ZONE_MOVABLE,"Movable"),	\
> +				EMe(ZONE_MOVABLE,"Movable"),	\
> +				EMe(ZONE_CMA,    "CMA"))
>  
>  /*
>   * First define the enums in the above macros to be exported to userspace
> diff --git a/kernel/power/snapshot.c b/kernel/power/snapshot.c
> index 4f0f060..bb3755e 100644
> --- a/kernel/power/snapshot.c
> +++ b/kernel/power/snapshot.c
> @@ -1166,6 +1166,14 @@ unsigned int snapshot_additional_pages(struct zone *zone)
>  {
>  	unsigned int rtree, nodes;
>  
> +	/*
> +	 * Estimation of needed pages for ZONE_CMA is already considered
> +	 * when calculating other zones since span of ZONE_CMA is subset
> +	 * of other zones.
> +	 */
> +	if (is_zone_cma(zone))
> +		return 0;
> +
>  	rtree = nodes = DIV_ROUND_UP(zone->spanned_pages, BM_BITS_PER_BLOCK);
>  	rtree += DIV_ROUND_UP(rtree * sizeof(struct rtree_node),
>  			      LINKED_PAGE_DATA_SIZE);
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 9629273..d941b6e 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1887,6 +1887,9 @@ static int __ref __offline_pages(unsigned long start_pfn,
>  	if (zone_idx(zone) <= ZONE_NORMAL && !can_offline_normal(zone, nr_pages))
>  		return -EINVAL;
>  
> +	if (is_zone_cma(zone))
> +		return -EINVAL;
> +
>  	/* set above range as isolated */
>  	ret = start_isolate_page_range(start_pfn, end_pfn,
>  				       MIGRATE_MOVABLE, true);
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 92b68cc..ac44b01 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -210,6 +210,9 @@ bool pm_suspended_storage(void)
>  	[ZONE_HIGHMEM] = INT_MAX,
>  #endif
>  	[ZONE_MOVABLE] = INT_MAX,
> +#ifdef CONFIG_CMA
> +	[ZONE_CMA] = INT_MAX,
> +#endif
>  };
>  
>  EXPORT_SYMBOL(totalram_pages);
> @@ -226,6 +229,9 @@ bool pm_suspended_storage(void)
>  	 "HighMem",
>  #endif
>  	 "Movable",
> +#ifdef CONFIG_CMA
> +	 "CMA",
> +#endif
>  #ifdef CONFIG_ZONE_DEVICE
>  	 "Device",
>  #endif
> @@ -5081,6 +5087,15 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
>  	struct memblock_region *r = NULL, *tmp;
>  #endif
>  
> +	/*
> +	 * Physical pages for ZONE_CMA are belong to other zones now. They
> +	 * are initialized when corresponding zone is initialized and they
> +	 * will be moved to ZONE_CMA later. Zone information will also be
> +	 * adjusted later.
> +	 */
> +	if (is_zone_cma_idx(zone))
> +		return;
> +
>  	if (highest_memmap_pfn < end_pfn - 1)
>  		highest_memmap_pfn = end_pfn - 1;
>  
> @@ -5513,7 +5528,7 @@ static void __init find_usable_zone_for_movable(void)
>  {
>  	int zone_index;
>  	for (zone_index = MAX_NR_ZONES - 1; zone_index >= 0; zone_index--) {
> -		if (zone_index == ZONE_MOVABLE)
> +		if (zone_index == ZONE_MOVABLE || is_zone_cma_idx(zone_index))
>  			continue;
>  
>  		if (arch_zone_highest_possible_pfn[zone_index] >
> @@ -5723,6 +5738,8 @@ static void __meminit calculate_node_totalpages(struct pglist_data *pgdat,
>  						unsigned long *zholes_size)
>  {
>  	unsigned long realtotalpages = 0, totalpages = 0;
> +	unsigned long zone_cma_start_pfn = UINT_MAX;
> +	unsigned long zone_cma_end_pfn = 0;
>  	enum zone_type i;
>  
>  	for (i = 0; i < MAX_NR_ZONES; i++) {
> @@ -5730,6 +5747,13 @@ static void __meminit calculate_node_totalpages(struct pglist_data *pgdat,
>  		unsigned long zone_start_pfn, zone_end_pfn;
>  		unsigned long size, real_size;
>  
> +		if (is_zone_cma_idx(i)) {
> +			zone->zone_start_pfn = zone_cma_start_pfn;
> +			size = zone_cma_end_pfn - zone_cma_start_pfn;
> +			real_size = 0;
> +			goto init_zone;
> +		}
> +
>  		size = zone_spanned_pages_in_node(pgdat->node_id, i,
>  						  node_start_pfn,
>  						  node_end_pfn,
> @@ -5739,13 +5763,23 @@ static void __meminit calculate_node_totalpages(struct pglist_data *pgdat,
>  		real_size = size - zone_absent_pages_in_node(pgdat->node_id, i,
>  						  node_start_pfn, node_end_pfn,
>  						  zholes_size);
> -		if (size)
> +		if (size) {
>  			zone->zone_start_pfn = zone_start_pfn;
> -		else
> +			if (zone_cma_start_pfn > zone_start_pfn)
> +				zone_cma_start_pfn = zone_start_pfn;
> +			if (zone_cma_end_pfn < zone_start_pfn + size)
> +				zone_cma_end_pfn = zone_start_pfn + size;
> +		} else
>  			zone->zone_start_pfn = 0;
> +
> +init_zone:
>  		zone->spanned_pages = size;
>  		zone->present_pages = real_size;
>  
> +		/* Prevent to over-count node span */
> +		if (is_zone_cma_idx(i))
> +			size = 0;
> +
>  		totalpages += size;
>  		realtotalpages += real_size;
>  	}
> @@ -5889,6 +5923,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
>  		struct zone *zone = pgdat->node_zones + j;
>  		unsigned long size, realsize, freesize, memmap_pages;
>  		unsigned long zone_start_pfn = zone->zone_start_pfn;
> +		bool zone_kernel = !is_highmem_idx(j) && !is_zone_cma_idx(j);
>  
>  		size = zone->spanned_pages;
>  		realsize = freesize = zone->present_pages;
> @@ -5899,7 +5934,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
>  		 * and per-cpu initialisations
>  		 */
>  		memmap_pages = calc_memmap_size(size, realsize);
> -		if (!is_highmem_idx(j)) {
> +		if (zone_kernel) {
>  			if (freesize >= memmap_pages) {
>  				freesize -= memmap_pages;
>  				if (memmap_pages)
> @@ -5918,7 +5953,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
>  					zone_names[0], dma_reserve);
>  		}
>  
> -		if (!is_highmem_idx(j))
> +		if (zone_kernel)
>  			nr_kernel_pages += freesize;
>  		/* Charge for highmem memmap if there are enough kernel pages */
>  		else if (nr_kernel_pages > memmap_pages * 2)
> @@ -5930,7 +5965,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
>  		 * when the bootmem allocator frees pages into the buddy system.
>  		 * And all highmem pages will be managed by the buddy system.
>  		 */
> -		zone->managed_pages = is_highmem_idx(j) ? realsize : freesize;
> +		zone->managed_pages = zone_kernel ? freesize : realsize;
>  #ifdef CONFIG_NUMA
>  		zone->node = nid;
>  #endif
> @@ -5940,7 +5975,11 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
>  		zone_seqlock_init(zone);
>  		zone_pcp_init(zone);
>  
> -		if (!size)
> +		/*
> +		 * ZONE_CMA should be initialized even if it has no present
> +		 * page now since pages will be moved to the zone later.
> +		 */
> +		if (!size && !is_zone_cma_idx(j))
>  			continue;
>  
>  		set_pageblock_order();
> @@ -6396,7 +6435,7 @@ void __init free_area_init_nodes(unsigned long *max_zone_pfn)
>  	start_pfn = find_min_pfn_with_active_regions();
>  
>  	for (i = 0; i < MAX_NR_ZONES; i++) {
> -		if (i == ZONE_MOVABLE)
> +		if (i == ZONE_MOVABLE || is_zone_cma_idx(i))
>  			continue;
>  
>  		end_pfn = max(max_zone_pfn[i], start_pfn);
> @@ -6415,7 +6454,7 @@ void __init free_area_init_nodes(unsigned long *max_zone_pfn)
>  	/* Print out the zone ranges */
>  	pr_info("Zone ranges:\n");
>  	for (i = 0; i < MAX_NR_ZONES; i++) {
> -		if (i == ZONE_MOVABLE)
> +		if (i == ZONE_MOVABLE || is_zone_cma_idx(i))
>  			continue;
>  		pr_info("  %-8s ", zone_names[i]);
>  		if (arch_zone_lowest_possible_pfn[i] ==
> @@ -7156,6 +7195,11 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
>  	 */
>  	if (zone_idx(zone) == ZONE_MOVABLE)
>  		return false;
> +
> +	/* ZONE_CMA never contains unmovable pages */
> +	if (is_zone_cma(zone))
> +		return false;
> +
>  	mt = get_pageblock_migratetype(page);
>  	if (mt == MIGRATE_MOVABLE || is_migrate_cma(mt))
>  		return false;
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 604f26a..429742f 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -915,8 +915,15 @@ int fragmentation_index(struct zone *zone, unsigned int order)
>  #define TEXT_FOR_HIGHMEM(xx)
>  #endif
>  
> +#ifdef CONFIG_CMA
> +#define TEXT_FOR_CMA(xx) xx "_cma",
> +#else
> +#define TEXT_FOR_CMA(xx)
> +#endif
> +
>  #define TEXTS_FOR_ZONES(xx) TEXT_FOR_DMA(xx) TEXT_FOR_DMA32(xx) xx "_normal", \
> -					TEXT_FOR_HIGHMEM(xx) xx "_movable",
> +					TEXT_FOR_HIGHMEM(xx) xx "_movable", \
> +					TEXT_FOR_CMA(xx)
>  
>  const char * const vmstat_text[] = {
>  	/* enum zone_stat_item countes */
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
