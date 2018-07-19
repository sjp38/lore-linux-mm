Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id BC4CC6B0003
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 04:23:21 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id r21-v6so2843079edp.23
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 01:23:21 -0700 (PDT)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id k9-v6si3333142edh.39.2018.07.19.01.23.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Jul 2018 01:23:20 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id EADB098765
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 08:23:19 +0000 (UTC)
Date: Thu, 19 Jul 2018 09:23:19 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH v3 2/7] mm, slab/slub: introduce kmalloc-reclaimable
 caches
Message-ID: <20180719082319.6jkltwinon3pyzyn@techsingularity.net>
References: <20180718133620.6205-1-vbabka@suse.cz>
 <20180718133620.6205-3-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20180718133620.6205-3-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Matthew Wilcox <willy@infradead.org>

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
>
> <SNIP>
>
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
> +	 * KMALLOC_DMA and effectively ignore __GFP_RECLAIMABLE
> +	 */
> +	return (is_dma * 2) + (is_reclaimable & !is_dma);
>  }
>  

s/botth/both/



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
> +	} else {
> +		name = kmalloc_info[idx].name;
> +	}
> +
> +	kmalloc_caches[type][idx] = create_kmalloc_cache(name,
>  					kmalloc_info[idx].size, flags, 0,
>  					kmalloc_info[idx].size);
>  }

I was going to query that BUG_ON but if I'm reading it right, we just
have to be careful in the future that the "normal" kmalloc cache is always
initialised before the reclaimable cache or there will be issues.

> @@ -1122,22 +1133,25 @@ static void __init new_kmalloc_cache(int idx, slab_flags_t flags)
>   */
>  void __init create_kmalloc_caches(slab_flags_t flags)
>  {
> -	int i;
> -	int type = KMALLOC_NORMAL;
> +	int i, type;
>  
> -	for (i = KMALLOC_SHIFT_LOW; i <= KMALLOC_SHIFT_HIGH; i++) {
> -		if (!kmalloc_caches[type][i])
> -			new_kmalloc_cache(i, flags);
> +	for (type = KMALLOC_NORMAL; type <= KMALLOC_RECLAIM; type++) {
> +		for (i = KMALLOC_SHIFT_LOW; i <= KMALLOC_SHIFT_HIGH; i++) {
> +			if (!kmalloc_caches[type][i])
> +				new_kmalloc_cache(i, type, flags);
>  

I don't see a problem here as such but the values of the KMALLOC_* types
is important both for this function and the kmalloc_type(). It might be
worth adding a warning that these functions be examined if updating the
types but then again, anyone trying and getting it wrong will have a
broken kernel so;

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs
