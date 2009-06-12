Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id AE4266B004D
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 05:56:40 -0400 (EDT)
Subject: Re: [PATCH v2] slab,slub: ignore __GFP_WAIT if we're booting or
 suspending
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <Pine.LNX.4.64.0906121244020.30911@melkki.cs.Helsinki.FI>
References: <Pine.LNX.4.64.0906121113210.29129@melkki.cs.Helsinki.FI>
	 <Pine.LNX.4.64.0906121201490.30049@melkki.cs.Helsinki.FI>
	 <20090612091002.GA32052@elte.hu> <1244798515.7172.99.camel@pasglop>
	 <84144f020906120224v5ef44637pb849fd247eab84ea@mail.gmail.com>
	 <1244799389.7172.110.camel@pasglop>
	 <Pine.LNX.4.64.0906121244020.30911@melkki.cs.Helsinki.FI>
Content-Type: text/plain
Date: Fri, 12 Jun 2009 19:58:15 +1000
Message-Id: <1244800695.7172.115.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pekka J Enberg <penberg@cs.helsinki.fi>
Cc: Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, npiggin@suse.de, akpm@linux-foundation.org, cl@linux-foundation.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Fri, 2009-06-12 at 12:45 +0300, Pekka J Enberg wrote:
> On Fri, 12 Jun 2009, Benjamin Herrenschmidt wrote:
> > Take a break, take a step back, and look at the big picture. Do you
> > really want to find all the needles in the haystack or just make sure
> > you wear gloves when handling the hay ? :-)
> 
> Well, I would like to find the needles but I think we should do it with 
> gloves on.
> 
> If everyone is happy with this version of Ben's patch, I'm going to just 
> apply it and push it to Linus.

Thanks :-) Looks right at first glance. I'll test tomorrow.

Cheers,
Ben.

> 			Pekka
> 
> >From 7760451b006b165bce052622af7316b54bd5a122 Mon Sep 17 00:00:00 2001
> From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Date: Fri, 12 Jun 2009 12:39:58 +0300
> Subject: [PATCH] Sanitize "gfp" flags during boot
> 
> With the recent shuffle of initialization order to move memory related
> inits earlier, various subtle breakage was introduced in archs like
> powerpc due to code somewhat assuming that GFP_KERNEL can be used as
> soon as the allocators are up. This is not true because any __GFP_WAIT
> allocation will cause interrupts to be enabled, which can be fatal if
> it happens too early.
> 
> This isn't trivial to fix on every call site. For example, powerpc's
> ioremap implementation needs to be called early. For that, it uses two
> different mechanisms to carve out virtual space. Before memory init,
> by moving down VMALLOC_END, and then, by calling get_vm_area().
> Unfortunately, the later does GFK_KERNEL allocations. But we can't do
> anything else because once vmalloc's been initialized, we can no longer
> safely move VMALLOC_END to carve out space.
> 
> There are other examples, wehere can can be called either very early
> or later on when devices are hot-plugged. It would be a major pain for
> such code to have to "know" whether it's in a context where it should
> use GFP_KERNEL or GFP_NOWAIT.
> 
> Finally, by having the ability to silently removed __GFP_WAIT from
> allocations, we pave the way for suspend-to-RAM to use that feature
> to also remove __GFP_IO from allocations done after suspending devices
> has started. This is important because such allocations may hang if
> devices on the swap-out path have been suspended, but not-yet suspended
> drivers don't know about it, and may deadlock themselves by being hung
> into a kmalloc somewhere while holding a mutex for example.
> 
> Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Signed-off-by: Pekka Enberg <penberg@cs.helsinki.fi>
> ---
>  include/linux/gfp.h |    9 +++++++++
>  init/main.c         |    1 +
>  mm/page_alloc.c     |   18 ++++++++++++++++++
>  mm/slab.c           |    9 +++++++++
>  mm/slub.c           |    3 +++
>  5 files changed, 40 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 0bbc15f..8d2ea79 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -99,6 +99,13 @@ struct vm_area_struct;
>  /* 4GB DMA on some platforms */
>  #define GFP_DMA32	__GFP_DMA32
>  
> +extern gfp_t gfp_allowed_bits;
> +
> +static inline gfp_t gfp_sanitize(gfp_t gfp_flags)
> +{
> +	return gfp_flags & gfp_allowed_bits;
> +}
> +
>  /* Convert GFP flags to their corresponding migrate type */
>  static inline int allocflags_to_migratetype(gfp_t gfp_flags)
>  {
> @@ -245,4 +252,6 @@ void drain_zone_pages(struct zone *zone, struct per_cpu_pages *pcp);
>  void drain_all_pages(void);
>  void drain_local_pages(void *dummy);
>  
> +void mm_late_init(void);
> +
>  #endif /* __LINUX_GFP_H */
> diff --git a/init/main.c b/init/main.c
> index b3e8f14..34c6e7e 100644
> --- a/init/main.c
> +++ b/init/main.c
> @@ -640,6 +640,7 @@ asmlinkage void __init start_kernel(void)
>  				 "enabled early\n");
>  	early_boot_irqs_on();
>  	local_irq_enable();
> +	mm_late_init();
>  
>  	/*
>  	 * HACK ALERT! This is early. We're enabling the console before
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 7760ef9..a42e4c7 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -77,6 +77,13 @@ int percpu_pagelist_fraction;
>  int pageblock_order __read_mostly;
>  #endif
>  
> +/*
> + * We set up the page allocator and the slab allocator early on with interrupts
> + * disabled. Therefore, make sure that we sanitize GFP flags accordingly before
> + * everything is up and running.
> + */
> +gfp_t gfp_allowed_bits = ~(__GFP_WAIT|__GFP_FS | __GFP_IO);
> +
>  static void __free_pages_ok(struct page *page, unsigned int order);
>  
>  /*
> @@ -1473,6 +1480,9 @@ __alloc_pages_internal(gfp_t gfp_mask, unsigned int order,
>  	unsigned long did_some_progress;
>  	unsigned long pages_reclaimed = 0;
>  
> +	/* Sanitize flags so we don't enable irqs too early during boot */
> +	gfp_mask = gfp_sanitize(gfp_mask);
> +
>  	lockdep_trace_alloc(gfp_mask);
>  
>  	might_sleep_if(wait);
> @@ -4728,3 +4738,11 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
>  	spin_unlock_irqrestore(&zone->lock, flags);
>  }
>  #endif
> +
> +void mm_late_init(void)
> +{
> +	/*
> +	 * Interrupts are enabled now so all GFP allocations are safe.
> +	 */
> +	gfp_allowed_bits = __GFP_BITS_MASK;
> +}
> diff --git a/mm/slab.c b/mm/slab.c
> index f46b65d..87b166e 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -2791,6 +2791,9 @@ static int cache_grow(struct kmem_cache *cachep,
>  	gfp_t local_flags;
>  	struct kmem_list3 *l3;
>  
> +	/* Sanitize flags so we don't enable irqs too early during boot */
> +	gfp_mask = gfp_sanitize(gfp_mask);
> +
>  	/*
>  	 * Be lazy and only check for valid flags here,  keeping it out of the
>  	 * critical path in kmem_cache_alloc().
> @@ -3212,6 +3215,9 @@ static void *fallback_alloc(struct kmem_cache *cache, gfp_t flags)
>  	void *obj = NULL;
>  	int nid;
>  
> +	/* Sanitize flags so we don't enable irqs too early during boot */
> +	gfp_mask = gfp_sanitize(gfp_mask);
> +
>  	if (flags & __GFP_THISNODE)
>  		return NULL;
>  
> @@ -3434,6 +3440,9 @@ __cache_alloc(struct kmem_cache *cachep, gfp_t flags, void *caller)
>  	unsigned long save_flags;
>  	void *objp;
>  
> +	/* Sanitize flags so we don't enable irqs too early during boot */
> +	gfp_mask = gfp_sanitize(gfp_mask);
> +
>  	lockdep_trace_alloc(flags);
>  
>  	if (slab_should_failslab(cachep, flags))
> diff --git a/mm/slub.c b/mm/slub.c
> index 3964d3c..5c646f7 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -1512,6 +1512,9 @@ static void *__slab_alloc(struct kmem_cache *s, gfp_t gfpflags, int node,
>  	/* We handle __GFP_ZERO in the caller */
>  	gfpflags &= ~__GFP_ZERO;
>  
> +	/* Sanitize flags so we don't enable irqs too early during boot */
> +	gfpflags = gfp_sanitize(gfpflags);
> +
>  	if (!c->page)
>  		goto new_slab;
>  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
