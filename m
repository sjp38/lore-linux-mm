Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 147B46B0253
	for <linux-mm@kvack.org>; Tue, 28 Jul 2015 09:36:11 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so157693887wib.0
        for <linux-mm@kvack.org>; Tue, 28 Jul 2015 06:36:10 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q2si20491298wiy.12.2015.07.28.06.36.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Jul 2015 06:36:09 -0700 (PDT)
Subject: Re: [PATCH 05/10] mm, page_alloc: Remove unnecessary updating of GFP
 flags during normal operation
References: <1437379219-9160-1-git-send-email-mgorman@suse.com>
 <1437379219-9160-6-git-send-email-mgorman@suse.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55B78545.8000906@suse.cz>
Date: Tue, 28 Jul 2015 15:36:05 +0200
MIME-Version: 1.0
In-Reply-To: <1437379219-9160-6-git-send-email-mgorman@suse.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.com>, Linux-MM <linux-mm@kvack.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Pintu Kumar <pintu.k@samsung.com>, Xishi Qiu <qiuxishi@huawei.com>, Gioh Kim <gioh.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Peter Zijlstra <peterz@infradead.org>

On 07/20/2015 10:00 AM, Mel Gorman wrote:
> From: Mel Gorman <mgorman@suse.de>
>
> During boot and suspend there is a restriction on the allowed GFP
> flags. During boot it prevents blocking operations before the scheduler
> is active. During suspend it is to avoid IO operations when storage is
> unavailable. The restriction on the mask is applied in some allocator
> hot-paths during normal operation which is wasteful. Use jump labels
> to only update the GFP mask when it is restricted.
>
> Signed-off-by: Mel Gorman <mgorman@suse.de>

[+CC Peterz, not trimmed due to that]

> ---
>   include/linux/gfp.h | 33 ++++++++++++++++++++++++++++-----
>   init/main.c         |  2 +-
>   mm/page_alloc.c     | 21 +++++++--------------
>   mm/slab.c           |  4 ++--
>   mm/slob.c           |  4 ++--
>   mm/slub.c           |  6 +++---
>   6 files changed, 43 insertions(+), 27 deletions(-)
>
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index ad35f300b9a4..6d3a2d430715 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -394,12 +394,35 @@ static inline void page_alloc_init_late(void)
>
>   /*
>    * gfp_allowed_mask is set to GFP_BOOT_MASK during early boot to restrict what
> - * GFP flags are used before interrupts are enabled. Once interrupts are
> - * enabled, it is set to __GFP_BITS_MASK while the system is running. During
> - * hibernation, it is used by PM to avoid I/O during memory allocation while
> - * devices are suspended.
> + * GFP flags are used before interrupts are enabled. During hibernation, it is
> + * used by PM to avoid I/O during memory allocation while devices are suspended.
>    */
> -extern gfp_t gfp_allowed_mask;
> +extern gfp_t __gfp_allowed_mask;
> +
> +/* Only update the gfp_mask when it is restricted */
> +extern struct static_key gfp_restricted_key;
> +
> +static inline gfp_t gfp_allowed_mask(gfp_t gfp_mask)
> +{
> +	if (static_key_false(&gfp_restricted_key))

This is where it uses static_key_false()...

> +		return gfp_mask;
> +
> +	return gfp_mask & __gfp_allowed_mask;
> +}
> +
> +static inline void unrestrict_gfp_allowed_mask(void)
> +{
> +	WARN_ON(!static_key_enabled(&gfp_restricted_key));
> +	__gfp_allowed_mask = __GFP_BITS_MASK;
> +	static_key_slow_dec(&gfp_restricted_key);
> +}
> +
> +static inline void restrict_gfp_allowed_mask(gfp_t gfp_mask)
> +{
> +	WARN_ON(static_key_enabled(&gfp_restricted_key));
> +	__gfp_allowed_mask = gfp_mask;
> +	static_key_slow_inc(&gfp_restricted_key);
> +}
>
>   /* Returns true if the gfp_mask allows use of ALLOC_NO_WATERMARK */
>   bool gfp_pfmemalloc_allowed(gfp_t gfp_mask);
> diff --git a/init/main.c b/init/main.c
> index c5d5626289ce..7e3a227559c6 100644
> --- a/init/main.c
> +++ b/init/main.c
> @@ -983,7 +983,7 @@ static noinline void __init kernel_init_freeable(void)
>   	wait_for_completion(&kthreadd_done);
>
>   	/* Now the scheduler is fully set up and can do blocking allocations */
> -	gfp_allowed_mask = __GFP_BITS_MASK;
> +	unrestrict_gfp_allowed_mask();
>
>   	/*
>   	 * init can allocate pages on any node
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 7c2dc022f4ba..56432b59b797 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -124,7 +124,9 @@ unsigned long totalcma_pages __read_mostly;
>   unsigned long dirty_balance_reserve __read_mostly;
>
>   int percpu_pagelist_fraction;
> -gfp_t gfp_allowed_mask __read_mostly = GFP_BOOT_MASK;
> +
> +gfp_t __gfp_allowed_mask __read_mostly = GFP_BOOT_MASK;
> +struct static_key gfp_restricted_key __read_mostly = STATIC_KEY_INIT_TRUE;

... and here it's combined with STATIC_KEY_INIT_TRUE. I've suspected 
that this is not allowed, which Peter confirmed on IRC.

It's however true that the big comment at the top of 
include/linux/jump_label.h only explicitly talks about combining 
static_key_false() and static_key_true().

I'm not sure what's the correct idiom for a default-false static key 
which however has to start as true on boot (Peter said such cases do 
exist)...

>
>   #ifdef CONFIG_PM_SLEEP
>   /*
> @@ -136,30 +138,21 @@ gfp_t gfp_allowed_mask __read_mostly = GFP_BOOT_MASK;
>    * guaranteed not to run in parallel with that modification).
>    */
>
> -static gfp_t saved_gfp_mask;
> -
>   void pm_restore_gfp_mask(void)
>   {
>   	WARN_ON(!mutex_is_locked(&pm_mutex));
> -	if (saved_gfp_mask) {
> -		gfp_allowed_mask = saved_gfp_mask;
> -		saved_gfp_mask = 0;
> -	}
> +	unrestrict_gfp_allowed_mask();
>   }
>
>   void pm_restrict_gfp_mask(void)
>   {
>   	WARN_ON(!mutex_is_locked(&pm_mutex));
> -	WARN_ON(saved_gfp_mask);
> -	saved_gfp_mask = gfp_allowed_mask;
> -	gfp_allowed_mask &= ~GFP_IOFS;
> +	restrict_gfp_allowed_mask(__GFP_BITS_MASK & ~GFP_IOFS);
>   }
>
>   bool pm_suspended_storage(void)
>   {
> -	if ((gfp_allowed_mask & GFP_IOFS) == GFP_IOFS)
> -		return false;
> -	return true;
> +	return static_key_enabled(&gfp_restricted_key);
>   }
>   #endif /* CONFIG_PM_SLEEP */
>
> @@ -2968,7 +2961,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
>   		.migratetype = gfpflags_to_migratetype(gfp_mask),
>   	};
>
> -	gfp_mask &= gfp_allowed_mask;
> +	gfp_mask = gfp_allowed_mask(gfp_mask);
>
>   	lockdep_trace_alloc(gfp_mask);
>
> diff --git a/mm/slab.c b/mm/slab.c
> index 200e22412a16..2c715b8c88f7 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -3151,7 +3151,7 @@ slab_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid,
>   	void *ptr;
>   	int slab_node = numa_mem_id();
>
> -	flags &= gfp_allowed_mask;
> +	flags = gfp_allowed_mask(flags);
>
>   	lockdep_trace_alloc(flags);
>
> @@ -3239,7 +3239,7 @@ slab_alloc(struct kmem_cache *cachep, gfp_t flags, unsigned long caller)
>   	unsigned long save_flags;
>   	void *objp;
>
> -	flags &= gfp_allowed_mask;
> +	flags = gfp_allowed_mask(flags);
>
>   	lockdep_trace_alloc(flags);
>
> diff --git a/mm/slob.c b/mm/slob.c
> index 4765f65019c7..23dbdac87fcb 100644
> --- a/mm/slob.c
> +++ b/mm/slob.c
> @@ -430,7 +430,7 @@ __do_kmalloc_node(size_t size, gfp_t gfp, int node, unsigned long caller)
>   	int align = max_t(size_t, ARCH_KMALLOC_MINALIGN, ARCH_SLAB_MINALIGN);
>   	void *ret;
>
> -	gfp &= gfp_allowed_mask;
> +	gfp = gfp_allowed_mask(gfp);
>
>   	lockdep_trace_alloc(gfp);
>
> @@ -536,7 +536,7 @@ static void *slob_alloc_node(struct kmem_cache *c, gfp_t flags, int node)
>   {
>   	void *b;
>
> -	flags &= gfp_allowed_mask;
> +	flags = gfp_allowed_mask(flags);
>
>   	lockdep_trace_alloc(flags);
>
> diff --git a/mm/slub.c b/mm/slub.c
> index 816df0016555..9eb79f7a48ba 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -1261,7 +1261,7 @@ static inline void kfree_hook(const void *x)
>   static inline struct kmem_cache *slab_pre_alloc_hook(struct kmem_cache *s,
>   						     gfp_t flags)
>   {
> -	flags &= gfp_allowed_mask;
> +	flags = gfp_allowed_mask(flags);
>   	lockdep_trace_alloc(flags);
>   	might_sleep_if(flags & __GFP_WAIT);
>
> @@ -1274,7 +1274,7 @@ static inline struct kmem_cache *slab_pre_alloc_hook(struct kmem_cache *s,
>   static inline void slab_post_alloc_hook(struct kmem_cache *s,
>   					gfp_t flags, void *object)
>   {
> -	flags &= gfp_allowed_mask;
> +	flags = gfp_allowed_mask(flags);
>   	kmemcheck_slab_alloc(s, flags, object, slab_ksize(s));
>   	kmemleak_alloc_recursive(object, s->object_size, 1, s->flags, flags);
>   	memcg_kmem_put_cache(s);
> @@ -1337,7 +1337,7 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
>   	struct kmem_cache_order_objects oo = s->oo;
>   	gfp_t alloc_gfp;
>
> -	flags &= gfp_allowed_mask;
> +	flags = gfp_allowed_mask(flags);
>
>   	if (flags & __GFP_WAIT)
>   		local_irq_enable();
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
