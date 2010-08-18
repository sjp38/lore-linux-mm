Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id B4E366B01F1
	for <linux-mm@kvack.org>; Tue, 17 Aug 2010 20:29:09 -0400 (EDT)
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id o7I0T6hf020263
	for <linux-mm@kvack.org>; Tue, 17 Aug 2010 17:29:06 -0700
Received: from pxi14 (pxi14.prod.google.com [10.243.27.14])
	by hpaq2.eem.corp.google.com with ESMTP id o7I0T477006314
	for <linux-mm@kvack.org>; Tue, 17 Aug 2010 17:29:05 -0700
Received: by pxi14 with SMTP id 14so3225202pxi.38
        for <linux-mm@kvack.org>; Tue, 17 Aug 2010 17:29:04 -0700 (PDT)
Date: Tue, 17 Aug 2010 17:28:57 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [S+Q Cleanup 5/6] slub: Extract hooks for memory checkers from
 hotpaths
In-Reply-To: <20100817211137.241962968@linux.com>
Message-ID: <alpine.DEB.2.00.1008171726210.21514@chino.kir.corp.google.com>
References: <20100817211118.958108012@linux.com> <20100817211137.241962968@linux.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 17 Aug 2010, Christoph Lameter wrote:

> Index: linux-2.6/mm/slub.c
> ===================================================================
> --- linux-2.6.orig/mm/slub.c	2010-08-13 10:33:05.000000000 -0500
> +++ linux-2.6/mm/slub.c	2010-08-13 10:33:09.000000000 -0500
> @@ -792,6 +792,37 @@ static void trace(struct kmem_cache *s, 
>  }
>  
>  /*
> + * Hooks for other subsystems that check memory allocations. In a typical
> + * production configuration these hooks all should produce no code at all.
> + */
> +static inline int slab_pre_alloc_hook(struct kmem_cache *s, gfp_t flags)
> +{
> +	lockdep_trace_alloc(flags);
> +	might_sleep_if(flags & __GFP_WAIT);
> +
> +	return should_failslab(s->objsize, flags, s->flags);
> +}
> +
> +static inline void slab_post_alloc_hook(struct kmem_cache *s, gfp_t flags, void *object)
> +{
> +	kmemcheck_slab_alloc(s, flags, object, s->objsize);
> +	kmemleak_alloc_recursive(object, s->objsize, 1, s->flags, flags);
> +}
> +
> +static inline void slab_free_hook(struct kmem_cache *s, void *x)
> +{
> +	kmemleak_free_recursive(x, s->flags);
> +}
> +
> +static inline void slab_free_hook_irq(struct kmem_cache *s, void *object)
> +{
> +	kmemcheck_slab_free(s, object, s->objsize);
> +	debug_check_no_locks_freed(object, s->objsize);
> +	if (!(s->flags & SLAB_DEBUG_OBJECTS))
> +		debug_check_no_obj_freed(object, s->objsize);
> +}
> +
> +/*
>   * Tracking of fully allocated slabs for debugging purposes.
>   */
>  static void add_full(struct kmem_cache_node *n, struct page *page)
> @@ -1697,10 +1728,7 @@ static __always_inline void *slab_alloc(
>  
>  	gfpflags &= gfp_allowed_mask;
>  
> -	lockdep_trace_alloc(gfpflags);
> -	might_sleep_if(gfpflags & __GFP_WAIT);
> -
> -	if (should_failslab(s->objsize, gfpflags, s->flags))
> +	if (!slab_pre_alloc_hook(s, gfpflags))

That's inverted, it should be slab_pre_alloc_hook()?

>  		return NULL;
>  
>  	local_irq_save(flags);
> @@ -1719,8 +1747,7 @@ static __always_inline void *slab_alloc(
>  	if (unlikely(gfpflags & __GFP_ZERO) && object)
>  		memset(object, 0, s->objsize);
>  
> -	kmemcheck_slab_alloc(s, gfpflags, object, s->objsize);
> -	kmemleak_alloc_recursive(object, s->objsize, 1, s->flags, gfpflags);
> +	slab_post_alloc_hook(s, gfpflags, object);
>  
>  	return object;
>  }
> @@ -1850,13 +1877,13 @@ static __always_inline void slab_free(st
>  	struct kmem_cache_cpu *c;
>  	unsigned long flags;
>  
> -	kmemleak_free_recursive(x, s->flags);
> +	slab_free_hook(s, x);
> +
>  	local_irq_save(flags);
>  	c = __this_cpu_ptr(s->cpu_slab);
> -	kmemcheck_slab_free(s, object, s->objsize);
> -	debug_check_no_locks_freed(object, s->objsize);
> -	if (!(s->flags & SLAB_DEBUG_OBJECTS))
> -		debug_check_no_obj_freed(object, s->objsize);
> +
> +	slab_free_hook_irq(s, x);
> +
>  	if (likely(page == c->page && c->node >= 0)) {
>  		set_freepointer(s, object, c->freelist);
>  		c->freelist = object;
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
