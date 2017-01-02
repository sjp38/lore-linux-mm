Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id EA18C6B0069
	for <linux-mm@kvack.org>; Mon,  2 Jan 2017 09:18:43 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id iq1so46455968wjb.1
        for <linux-mm@kvack.org>; Mon, 02 Jan 2017 06:18:43 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ce10si73544514wjd.29.2017.01.02.06.18.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 02 Jan 2017 06:18:42 -0800 (PST)
Subject: Re: [PATCH 2/2] mm: get rid of __GFP_OTHER_NODE
References: <20161221075711.GF16502@dhcp22.suse.cz>
 <20161221080653.29437-1-mhocko@kernel.org>
 <20161221080653.29437-2-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <75e600d4-42e5-bfc6-c9ab-7f2dad146425@suse.cz>
Date: Mon, 2 Jan 2017 15:18:41 +0100
MIME-Version: 1.0
In-Reply-To: <20161221080653.29437-2-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, Jia He <hejianet@gmail.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Andi Kleen <ak@linux.intel.com>

[CC Andi who introduced __GFP_OTHER_NODE]

On 12/21/2016 09:06 AM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> The flag has been introduced by 78afd5612deb ("mm: add __GFP_OTHER_NODE
> flag") to allow proper accounting of remote node allocations done by
> kernel daemons on behalf of a process - e.g. khugepaged.
> 
> After "mm: fix remote numa hits statistics" we do not need and actually
> use the flag so we can safely remove it because all allocations which
> are satisfied from their "home" node are accounted properly.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  include/linux/gfp.h            | 13 +++----------
>  include/trace/events/mmflags.h |  1 -
>  mm/huge_memory.c               |  3 +--
>  mm/khugepaged.c                |  5 ++---
>  mm/page_alloc.c                |  5 ++---
>  tools/perf/builtin-kmem.c      |  1 -
>  6 files changed, 8 insertions(+), 20 deletions(-)
> 
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 4175dca4ac39..7806a8f80abc 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -38,9 +38,8 @@ struct vm_area_struct;
>  #define ___GFP_ACCOUNT		0x100000u
>  #define ___GFP_NOTRACK		0x200000u
>  #define ___GFP_DIRECT_RECLAIM	0x400000u
> -#define ___GFP_OTHER_NODE	0x800000u
> -#define ___GFP_WRITE		0x1000000u
> -#define ___GFP_KSWAPD_RECLAIM	0x2000000u
> +#define ___GFP_WRITE		0x800000u
> +#define ___GFP_KSWAPD_RECLAIM	0x1000000u
>  /* If the above are modified, __GFP_BITS_SHIFT may need updating */
>  
>  /*
> @@ -172,11 +171,6 @@ struct vm_area_struct;
>   * __GFP_NOTRACK_FALSE_POSITIVE is an alias of __GFP_NOTRACK. It's a means of
>   *   distinguishing in the source between false positives and allocations that
>   *   cannot be supported (e.g. page tables).
> - *
> - * __GFP_OTHER_NODE is for allocations that are on a remote node but that
> - *   should not be accounted for as a remote allocation in vmstat. A
> - *   typical user would be khugepaged collapsing a huge page on a remote
> - *   node.
>   */
>  #define __GFP_COLD	((__force gfp_t)___GFP_COLD)
>  #define __GFP_NOWARN	((__force gfp_t)___GFP_NOWARN)
> @@ -184,10 +178,9 @@ struct vm_area_struct;
>  #define __GFP_ZERO	((__force gfp_t)___GFP_ZERO)
>  #define __GFP_NOTRACK	((__force gfp_t)___GFP_NOTRACK)
>  #define __GFP_NOTRACK_FALSE_POSITIVE (__GFP_NOTRACK)
> -#define __GFP_OTHER_NODE ((__force gfp_t)___GFP_OTHER_NODE)
>  
>  /* Room for N __GFP_FOO bits */
> -#define __GFP_BITS_SHIFT 26
> +#define __GFP_BITS_SHIFT 25
>  #define __GFP_BITS_MASK ((__force gfp_t)((1 << __GFP_BITS_SHIFT) - 1))
>  
>  /*
> diff --git a/include/trace/events/mmflags.h b/include/trace/events/mmflags.h
> index 5a81ab48a2fb..556a0efa8298 100644
> --- a/include/trace/events/mmflags.h
> +++ b/include/trace/events/mmflags.h
> @@ -48,7 +48,6 @@
>  	{(unsigned long)__GFP_RECLAIM,		"__GFP_RECLAIM"},	\
>  	{(unsigned long)__GFP_DIRECT_RECLAIM,	"__GFP_DIRECT_RECLAIM"},\
>  	{(unsigned long)__GFP_KSWAPD_RECLAIM,	"__GFP_KSWAPD_RECLAIM"},\
> -	{(unsigned long)__GFP_OTHER_NODE,	"__GFP_OTHER_NODE"}	\
>  
>  #define show_gfp_flags(flags)						\
>  	(flags) ? __print_flags(flags, "|",				\
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index f3c2040edbb1..8206abf4ac03 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -918,8 +918,7 @@ static int do_huge_pmd_wp_page_fallback(struct vm_fault *vmf, pmd_t orig_pmd,
>  	}
>  
>  	for (i = 0; i < HPAGE_PMD_NR; i++) {
> -		pages[i] = alloc_page_vma_node(GFP_HIGHUSER_MOVABLE |
> -					       __GFP_OTHER_NODE, vma,
> +		pages[i] = alloc_page_vma_node(GFP_HIGHUSER_MOVABLE, vma,
>  					       vmf->address, page_to_nid(page));
>  		if (unlikely(!pages[i] ||
>  			     mem_cgroup_try_charge(pages[i], vma->vm_mm,
> diff --git a/mm/khugepaged.c b/mm/khugepaged.c
> index e32389a97030..211974a3992b 100644
> --- a/mm/khugepaged.c
> +++ b/mm/khugepaged.c
> @@ -943,7 +943,7 @@ static void collapse_huge_page(struct mm_struct *mm,
>  	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
>  
>  	/* Only allocate from the target node */
> -	gfp = alloc_hugepage_khugepaged_gfpmask() | __GFP_OTHER_NODE | __GFP_THISNODE;
> +	gfp = alloc_hugepage_khugepaged_gfpmask() | __GFP_THISNODE;
>  
>  	/*
>  	 * Before allocating the hugepage, release the mmap_sem read lock.
> @@ -1326,8 +1326,7 @@ static void collapse_shmem(struct mm_struct *mm,
>  	VM_BUG_ON(start & (HPAGE_PMD_NR - 1));
>  
>  	/* Only allocate from the target node */
> -	gfp = alloc_hugepage_khugepaged_gfpmask() |
> -		__GFP_OTHER_NODE | __GFP_THISNODE;
> +	gfp = alloc_hugepage_khugepaged_gfpmask() | __GFP_THISNODE;
>  
>  	new_page = khugepaged_alloc_page(hpage, gfp, node);
>  	if (!new_page) {
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 506946a902c5..647e940e6921 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2584,8 +2584,7 @@ int __isolate_free_page(struct page *page, unsigned int order)
>   *
>   * Must be called with interrupts disabled.
>   */
> -static inline void zone_statistics(struct zone *preferred_zone, struct zone *z,
> -								gfp_t flags)
> +static inline void zone_statistics(struct zone *preferred_zone, struct zone *z)
>  {
>  #ifdef CONFIG_NUMA
>  	if (z->node == preferred_zone->node) {
> @@ -2666,7 +2665,7 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
>  	}
>  
>  	__count_zid_vm_events(PGALLOC, page_zonenum(page), 1 << order);
> -	zone_statistics(preferred_zone, zone, gfp_flags);
> +	zone_statistics(preferred_zone, zone);
>  	local_irq_restore(flags);
>  
>  	VM_BUG_ON_PAGE(bad_range(zone, page), page);
> diff --git a/tools/perf/builtin-kmem.c b/tools/perf/builtin-kmem.c
> index d426dcb18ce9..33b959d47545 100644
> --- a/tools/perf/builtin-kmem.c
> +++ b/tools/perf/builtin-kmem.c
> @@ -645,7 +645,6 @@ static const struct {
>  	{ "__GFP_RECLAIM",		"R" },
>  	{ "__GFP_DIRECT_RECLAIM",	"DR" },
>  	{ "__GFP_KSWAPD_RECLAIM",	"KR" },
> -	{ "__GFP_OTHER_NODE",		"ON" },
>  };
>  
>  static size_t max_gfp_len;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
