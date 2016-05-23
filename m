Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f199.google.com (mail-lb0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id B6AA56B025E
	for <linux-mm@kvack.org>; Mon, 23 May 2016 04:39:28 -0400 (EDT)
Received: by mail-lb0-f199.google.com with SMTP id ga2so73550567lbc.0
        for <linux-mm@kvack.org>; Mon, 23 May 2016 01:39:28 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id o13si14556823wmd.47.2016.05.23.01.39.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 May 2016 01:39:27 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id f75so6406133wmf.2
        for <linux-mm@kvack.org>; Mon, 23 May 2016 01:39:27 -0700 (PDT)
Date: Mon, 23 May 2016 10:39:25 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 06/13] mm, thp: remove __GFP_NORETRY from khugepaged and
 madvised allocations
Message-ID: <20160523083925.GJ2278@dhcp22.suse.cz>
References: <1462865763-22084-1-git-send-email-vbabka@suse.cz>
 <1462865763-22084-7-git-send-email-vbabka@suse.cz>
 <20160512162043.GA4261@dhcp22.suse.cz>
 <57358F03.5080707@suse.cz>
 <20160513120558.GL20141@dhcp22.suse.cz>
 <573C5939.1080909@suse.cz>
 <20160518152423.GK21654@dhcp22.suse.cz>
 <573F17B4.70701@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <573F17B4.70701@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>

On Fri 20-05-16 15:57:08, Vlastimil Babka wrote:
[...]
> From: Vlastimil Babka <vbabka@suse.cz>
> Date: Wed, 4 May 2016 13:40:03 +0200
> Subject: [PATCH] mm, thp: remove __GFP_NORETRY from khugepaged and madvised
>  allocations
> 
> After the previous patch, we can distinguish costly allocations that should be
> really lightweight, such as THP page faults, with __GFP_NORETRY. This means we
> don't need to recognize khugepaged allocations via PF_KTHREAD anymore. We can
> also change THP page faults in areas where madvise(MADV_HUGEPAGE) was used to
> try as hard as khugepaged, as the process has indicated that it benefits from
> THP's and is willing to pay some initial latency costs.
> 
> We can also make the flags handling less cryptic by distinguishing
> GFP_TRANSHUGE_LIGHT (no reclaim at all, default mode in page fault) from
> GFP_TRANSHUGE (only direct reclaim, khugepaged default). Adding __GFP_NORETRY
> or __GFP_KSWAPD_RECLAIM is done where needed.
> 
> The patch effectively changes the current GFP_TRANSHUGE users as follows:
> 
> * get_huge_zero_page() - the zero page lifetime should be relatively long and
>   it's shared by multiple users, so it's worth spending some effort on it.
>   We use GFP_TRANSHUGE, and __GFP_NORETRY is not added. This also restores
>   direct reclaim to this allocation, which was unintentionally removed by
>   commit e4a49efe4e7e ("mm: thp: set THP defrag by default to madvise and add
>   a stall-free defrag option")
> 
> * alloc_hugepage_khugepaged_gfpmask() - this is khugepaged, so latency is not
>   an issue. So if khugepaged "defrag" is enabled (the default), do reclaim
>   via GFP_TRANSHUGE without __GFP_NORETRY. We can remove the PF_KTHREAD check
>   from page alloc.
>   As a side-effect, khugepaged will now no longer check if the initial
>   compaction was deferred or contended. This is OK, as khugepaged sleep times
>   between collapsion attemps are long enough to prevent noticeable disruption,
>   so we should allow it to spend some effort.
> 
> * migrate_misplaced_transhuge_page() - already was masking out __GFP_RECLAIM,
>   so just convert to GFP_TRANSHUGE_LIGHT which is equivalent.
> 
> * alloc_hugepage_direct_gfpmask() - vma's with VM_HUGEPAGE (via madvise) are
>   now allocating without __GFP_NORETRY. Other vma's keep using __GFP_NORETRY
>   if direct reclaim/compaction is at all allowed (by default it's allowed only
>   for madvised vma's). The rest is conversion to GFP_TRANSHUGE(_LIGHT).
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

I like it more than the previous approach.

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

> ---
>  include/linux/gfp.h            | 14 ++++++++------
>  include/trace/events/mmflags.h |  1 +
>  mm/huge_memory.c               | 27 +++++++++++++++------------
>  mm/migrate.c                   |  2 +-
>  mm/page_alloc.c                |  6 ++----
>  tools/perf/builtin-kmem.c      |  1 +
>  6 files changed, 28 insertions(+), 23 deletions(-)
> 
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 570383a41853..1dfca27df492 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -238,9 +238,11 @@ struct vm_area_struct;
>   *   are expected to be movable via page reclaim or page migration. Typically,
>   *   pages on the LRU would also be allocated with GFP_HIGHUSER_MOVABLE.
>   *
> - * GFP_TRANSHUGE is used for THP allocations. They are compound allocations
> - *   that will fail quickly if memory is not available and will not wake
> - *   kswapd on failure.
> + * GFP_TRANSHUGE and GFP_TRANSHUGE_LIGHT are used for THP allocations. They are
> + *   compound allocations that will generally fail quickly if memory is not
> + *   available and will not wake kswapd/kcompactd on failure. The _LIGHT
> + *   version does not attempt reclaim/compaction at all and is by default used
> + *   in page fault path, while the non-light is used by khugepaged.
>   */
>  #define GFP_ATOMIC	(__GFP_HIGH|__GFP_ATOMIC|__GFP_KSWAPD_RECLAIM)
>  #define GFP_KERNEL	(__GFP_RECLAIM | __GFP_IO | __GFP_FS)
> @@ -255,9 +257,9 @@ struct vm_area_struct;
>  #define GFP_DMA32	__GFP_DMA32
>  #define GFP_HIGHUSER	(GFP_USER | __GFP_HIGHMEM)
>  #define GFP_HIGHUSER_MOVABLE	(GFP_HIGHUSER | __GFP_MOVABLE)
> -#define GFP_TRANSHUGE	((GFP_HIGHUSER_MOVABLE | __GFP_COMP | \
> -			 __GFP_NOMEMALLOC | __GFP_NORETRY | __GFP_NOWARN) & \
> -			 ~__GFP_RECLAIM)
> +#define GFP_TRANSHUGE_LIGHT	((GFP_HIGHUSER_MOVABLE | __GFP_COMP | \
> +			 __GFP_NOMEMALLOC| __GFP_NOWARN) & ~__GFP_RECLAIM)
> +#define GFP_TRANSHUGE	(GFP_TRANSHUGE_LIGHT | __GFP_DIRECT_RECLAIM)
>  
>  /* Convert GFP flags to their corresponding migrate type */
>  #define GFP_MOVABLE_MASK (__GFP_RECLAIMABLE|__GFP_MOVABLE)
> diff --git a/include/trace/events/mmflags.h b/include/trace/events/mmflags.h
> index 43cedbf0c759..5a81ab48a2fb 100644
> --- a/include/trace/events/mmflags.h
> +++ b/include/trace/events/mmflags.h
> @@ -11,6 +11,7 @@
>  
>  #define __def_gfpflag_names						\
>  	{(unsigned long)GFP_TRANSHUGE,		"GFP_TRANSHUGE"},	\
> +	{(unsigned long)GFP_TRANSHUGE_LIGHT,	"GFP_TRANSHUGE_LIGHT"}, \
>  	{(unsigned long)GFP_HIGHUSER_MOVABLE,	"GFP_HIGHUSER_MOVABLE"},\
>  	{(unsigned long)GFP_HIGHUSER,		"GFP_HIGHUSER"},	\
>  	{(unsigned long)GFP_USER,		"GFP_USER"},		\
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 87f09dc986ab..aa87db8c7f8f 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -882,29 +882,32 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
>  }
>  
>  /*
> - * If THP is set to always then directly reclaim/compact as necessary
> - * If set to defer then do no reclaim and defer to khugepaged
> + * If THP defrag is set to always then directly reclaim/compact as necessary
> + * If set to defer then do only background reclaim/compact and defer to khugepaged
>   * If set to madvise and the VMA is flagged then directly reclaim/compact
> + * When direct reclaim/compact is allowed, don't retry except for flagged VMA's
>   */
>  static inline gfp_t alloc_hugepage_direct_gfpmask(struct vm_area_struct *vma)
>  {
> -	gfp_t reclaim_flags = 0;
> +	bool vma_madvised = !!(vma->vm_flags & VM_HUGEPAGE);
>  
> -	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG, &transparent_hugepage_flags) &&
> -	    (vma->vm_flags & VM_HUGEPAGE))
> -		reclaim_flags = __GFP_DIRECT_RECLAIM;
> -	else if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_FLAG, &transparent_hugepage_flags))
> -		reclaim_flags = __GFP_KSWAPD_RECLAIM;
> -	else if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG, &transparent_hugepage_flags))
> -		reclaim_flags = __GFP_DIRECT_RECLAIM;
> +	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG,
> +				&transparent_hugepage_flags) && vma_madvised)
> +		return GFP_TRANSHUGE;
> +	else if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_FLAG,
> +						&transparent_hugepage_flags))
> +		return GFP_TRANSHUGE_LIGHT | __GFP_KSWAPD_RECLAIM;
> +	else if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG,
> +						&transparent_hugepage_flags))
> +		return GFP_TRANSHUGE | (vma_madvised ? 0 : __GFP_NORETRY);
>  
> -	return GFP_TRANSHUGE | reclaim_flags;
> +	return GFP_TRANSHUGE_LIGHT;
>  }
>  
>  /* Defrag for khugepaged will enter direct reclaim/compaction if necessary */
>  static inline gfp_t alloc_hugepage_khugepaged_gfpmask(void)
>  {
> -	return GFP_TRANSHUGE | (khugepaged_defrag() ? __GFP_DIRECT_RECLAIM : 0);
> +	return khugepaged_defrag() ? GFP_TRANSHUGE : GFP_TRANSHUGE_LIGHT;
>  }
>  
>  /* Caller must hold page table lock. */
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 53ab6398e7a2..bc82c56fa3af 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -1771,7 +1771,7 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
>  		goto out_dropref;
>  
>  	new_page = alloc_pages_node(node,
> -		(GFP_TRANSHUGE | __GFP_THISNODE) & ~__GFP_RECLAIM,
> +		(GFP_TRANSHUGE_LIGHT | __GFP_THISNODE),
>  		HPAGE_PMD_ORDER);
>  	if (!new_page)
>  		goto out_fail;
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 0cee863397e4..4a34187827ca 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3619,11 +3619,9 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  			/*
>  			 * Looks like reclaim/compaction is worth trying, but
>  			 * sync compaction could be very expensive, so keep
> -			 * using async compaction, unless it's khugepaged
> -			 * trying to collapse.
> +			 * using async compaction.
>  			 */
> -			if (!(current->flags & PF_KTHREAD))
> -				migration_mode = MIGRATE_ASYNC;
> +			migration_mode = MIGRATE_ASYNC;
>  		}
>  	}
>  
> diff --git a/tools/perf/builtin-kmem.c b/tools/perf/builtin-kmem.c
> index 5da5a9511cef..7fde754b344d 100644
> --- a/tools/perf/builtin-kmem.c
> +++ b/tools/perf/builtin-kmem.c
> @@ -608,6 +608,7 @@ static const struct {
>  	const char *compact;
>  } gfp_compact_table[] = {
>  	{ "GFP_TRANSHUGE",		"THP" },
> +	{ "GFP_TRANSHUGE_LIGHT",	"THL" },
>  	{ "GFP_HIGHUSER_MOVABLE",	"HUM" },
>  	{ "GFP_HIGHUSER",		"HU" },
>  	{ "GFP_USER",			"U" },
> -- 
> 2.8.2
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
