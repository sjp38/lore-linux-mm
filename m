Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id A210A6B000E
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 14:16:57 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id e23-v6so7665791oii.10
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 11:16:57 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id r64-v6si4180252oif.153.2018.07.19.11.16.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jul 2018 11:16:56 -0700 (PDT)
Date: Thu, 19 Jul 2018 11:16:17 -0700
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH v3 2/7] mm, slab/slub: introduce kmalloc-reclaimable
 caches
Message-ID: <20180719181613.GA26595@castle.DHCP.thefacebook.com>
References: <20180718133620.6205-1-vbabka@suse.cz>
 <20180718133620.6205-3-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20180718133620.6205-3-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>

On Wed, Jul 18, 2018 at 03:36:15PM +0200, Vlastimil Babka wrote:
> Kmem caches can be created with a SLAB_RECLAIM_ACCOUNT flag, which indicates
> they contain objects which can be reclaimed under memory pressure (typically
> through a shrinker). This makes the slab pages accounted as NR_SLAB_RECLAIMABLE
> in vmstat, which is reflected also the MemAvailable meminfo counter and in
> overcommit decisions. The slab pages are also allocated with __GFP_RECLAIMABLE,
> which is good for anti-fragmentation through grouping pages by mobility.
> 
> The generic kmalloc-X caches are created without this flag, but sometimes are
> used also for objects that can be reclaimed, which due to varying size cannot
> have a dedicated kmem cache with SLAB_RECLAIM_ACCOUNT flag. A prominent example
> are dcache external names, which prompted the creation of a new, manually
> managed vmstat counter NR_INDIRECTLY_RECLAIMABLE_BYTES in commit f1782c9bc547
> ("dcache: account external names as indirectly reclaimable memory").
> 
> To better handle this and any other similar cases, this patch introduces
> SLAB_RECLAIM_ACCOUNT variants of kmalloc caches, named kmalloc-rcl-X.
> They are used whenever the kmalloc() call passes __GFP_RECLAIMABLE among gfp
> flags. They are added to the kmalloc_caches array as a new type. Allocations
> with both __GFP_DMA and __GFP_RECLAIMABLE will use a dma type cache.
> 
> This change only applies to SLAB and SLUB, not SLOB. This is fine, since SLOB's
> target are tiny system and this patch does add some overhead of kmem management
> objects.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> ---
>  include/linux/slab.h | 16 +++++++++++----
>  mm/slab_common.c     | 48 ++++++++++++++++++++++++++++----------------
>  2 files changed, 43 insertions(+), 21 deletions(-)
> 
> diff --git a/include/linux/slab.h b/include/linux/slab.h
> index 4299c59353a1..d89e934e0d8b 100644
> --- a/include/linux/slab.h
> +++ b/include/linux/slab.h
> @@ -296,11 +296,12 @@ static inline void __check_heap_object(const void *ptr, unsigned long n,
>                                 (KMALLOC_MIN_SIZE) : 16)
>  
>  #define KMALLOC_NORMAL	0
> +#define KMALLOC_RECLAIM	1
>  #ifdef CONFIG_ZONE_DMA
> -#define KMALLOC_DMA	1
> -#define KMALLOC_TYPES	2
> +#define KMALLOC_DMA	2
> +#define KMALLOC_TYPES	3
>  #else
> -#define KMALLOC_TYPES	1
> +#define KMALLOC_TYPES	2
>  #endif
>  
>  #ifndef CONFIG_SLOB
> @@ -309,12 +310,19 @@ extern struct kmem_cache *kmalloc_caches[KMALLOC_TYPES][KMALLOC_SHIFT_HIGH + 1];
>  static __always_inline unsigned int kmalloc_type(gfp_t flags)
>  {
>  	int is_dma = 0;
> +	int is_reclaimable;
>  
>  #ifdef CONFIG_ZONE_DMA
>  	is_dma = !!(flags & __GFP_DMA);
>  #endif
>  
> -	return is_dma;
> +	is_reclaimable = !!(flags & __GFP_RECLAIMABLE);
> +
> +	/*
> +	 * If an allocation is botth __GFP_DMA and __GFP_RECLAIMABLE, return
                                 ^^
			       typo
> +	 * KMALLOC_DMA and effectively ignore __GFP_RECLAIMABLE
> +	 */
> +	return (is_dma * 2) + (is_reclaimable & !is_dma);

Maybe
is_dma * KMALLOC_DMA + (is_reclaimable && !is_dma) * KMALLOC_RECLAIM
looks better?

>  }
>  
>  /*
> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index 4614248ca381..614fb7ab8312 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -1107,10 +1107,21 @@ void __init setup_kmalloc_cache_index_table(void)
>  	}
>  }
>  
> -static void __init new_kmalloc_cache(int idx, slab_flags_t flags)
> +static void __init
> +new_kmalloc_cache(int idx, int type, slab_flags_t flags)
>  {
> -	kmalloc_caches[KMALLOC_NORMAL][idx] = create_kmalloc_cache(
> -					kmalloc_info[idx].name,
> +	const char *name;
> +
> +	if (type == KMALLOC_RECLAIM) {
> +		flags |= SLAB_RECLAIM_ACCOUNT;
> +		name = kasprintf(GFP_NOWAIT, "kmalloc-rcl-%u",
> +						kmalloc_info[idx].size);
> +		BUG_ON(!name);

I'd replace this with WARN_ON() and falling back to kmalloc_info[idx].name.

> +	} else {
> +		name = kmalloc_info[idx].name;
> +	}
> +
> +	kmalloc_caches[type][idx] = create_kmalloc_cache(name,
>  					kmalloc_info[idx].size, flags, 0,
>  					kmalloc_info[idx].size);
>  }
