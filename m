Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id 0D50A6B0038
	for <linux-mm@kvack.org>; Sat, 29 Aug 2015 05:59:55 -0400 (EDT)
Received: by qgi69 with SMTP id 69so13365994qgi.1
        for <linux-mm@kvack.org>; Sat, 29 Aug 2015 02:59:54 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k70si10468595qhc.26.2015.08.29.02.59.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 29 Aug 2015 02:59:53 -0700 (PDT)
Date: Sat, 29 Aug 2015 11:59:48 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH] slub: create new ___slab_alloc function that can be
 called with irqs disabled
Message-ID: <20150829115948.52eb7f5a@redhat.com>
In-Reply-To: <alpine.DEB.2.11.1508281442390.11894@east.gentwo.org>
References: <alpine.DEB.2.11.1508281442390.11894@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, brouer@redhat.com


I like it, as I have a similar patch.  The difference is just that I
don't introduce a extra function call, but instead enable/disable IRQ
at call site of __slab_alloc().

But hopefully the compiler will inline __slab_alloc() to avoid the
extra level of function call indirection (extra cost 7 cycles see[1]).
Coding wise your solution is more clean.

On Fri, 28 Aug 2015 14:43:26 -0500 (CDT) Christoph Lameter <cl@linux.com> wrote:

> Bulk alloc needs a function like that because it enables interrupts before
> calling __slab_alloc which promptly disables them again using the expensive
> local_irq_save().
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>

Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>

Hint measure overhead on your own CPU:
 [1] https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/lib/time_bench_sample.c

 
> Index: linux/mm/slub.c
> ===================================================================
> --- linux.orig/mm/slub.c	2015-08-28 14:33:01.520254081 -0500
> +++ linux/mm/slub.c	2015-08-28 14:34:21.050215578 -0500
> @@ -2300,23 +2300,15 @@ static inline void *get_freelist(struct
>   * And if we were unable to get a new slab from the partial slab lists then
>   * we need to allocate a new slab. This is the slowest path since it involves
>   * a call to the page allocator and the setup of a new slab.
> + *
> + * Version of __slab_alloc to use when we know that interrupts are
> + * already disabled (which is the case for bulk allocation).
>   */
> -static void *__slab_alloc(struct kmem_cache *s, gfp_t gfpflags, int node,
> +static void *___slab_alloc(struct kmem_cache *s, gfp_t gfpflags, int node,
>  			  unsigned long addr, struct kmem_cache_cpu *c)
>  {
>  	void *freelist;
>  	struct page *page;
> -	unsigned long flags;
> -
> -	local_irq_save(flags);
> -#ifdef CONFIG_PREEMPT
> -	/*
> -	 * We may have been preempted and rescheduled on a different
> -	 * cpu before disabling interrupts. Need to reload cpu area
> -	 * pointer.
> -	 */
> -	c = this_cpu_ptr(s->cpu_slab);
> -#endif
> 
>  	page = c->page;
>  	if (!page)
> @@ -2374,7 +2366,6 @@ load_freelist:
>  	VM_BUG_ON(!c->page->frozen);
>  	c->freelist = get_freepointer(s, freelist);
>  	c->tid = next_tid(c->tid);
> -	local_irq_restore(flags);
>  	return freelist;
> 
>  new_slab:
> @@ -2391,7 +2382,6 @@ new_slab:
> 
>  	if (unlikely(!freelist)) {
>  		slab_out_of_memory(s, gfpflags, node);
> -		local_irq_restore(flags);
>  		return NULL;
>  	}
> 
> @@ -2407,11 +2397,35 @@ new_slab:
>  	deactivate_slab(s, page, get_freepointer(s, freelist));
>  	c->page = NULL;
>  	c->freelist = NULL;
> -	local_irq_restore(flags);
>  	return freelist;
>  }
> 
>  /*
> + * Another one that disabled interrupt and compensates for possible
> + * cpu changes by refetching the per cpu area pointer.
> + */
> +static void *__slab_alloc(struct kmem_cache *s, gfp_t gfpflags, int node,
> +			  unsigned long addr, struct kmem_cache_cpu *c)

Compiler will hopefully inline this call.

> +{
> +	void *p;
> +	unsigned long flags;
> +
> +	local_irq_save(flags);
> +#ifdef CONFIG_PREEMPT
> +	/*
> +	 * We may have been preempted and rescheduled on a different
> +	 * cpu before disabling interrupts. Need to reload cpu area
> +	 * pointer.
> +	 */
> +	c = this_cpu_ptr(s->cpu_slab);
> +#endif
> +
> +	p = ___slab_alloc(s, gfpflags, node, addr, c);
> +	local_irq_restore(flags);
> +	return p;
> +}
[...]


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
