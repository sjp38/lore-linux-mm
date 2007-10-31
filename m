Received: from toip5.srvr.bell.ca ([209.226.175.88])
          by tomts16-srv.bellnexxia.net
          (InterMail vM.5.01.06.13 201-253-122-130-113-20050324) with ESMTP
          id <20071031022811.WMDE574.tomts16-srv.bellnexxia.net@toip5.srvr.bell.ca>
          for <linux-mm@kvack.org>; Tue, 30 Oct 2007 22:28:11 -0400
Date: Tue, 30 Oct 2007 22:28:10 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: Re: [patch 08/10] SLUB: Optional fast path using cmpxchg_local
Message-ID: <20071031022810.GA2323@Krystal>
References: <20071028033156.022983073@sgi.com> <20071028033300.240703208@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
In-Reply-To: <20071028033300.240703208@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Matthew Wilcox <matthew@wil.cx>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

* Christoph Lameter (clameter@sgi.com) wrote:
> Provide an alternate implementation of the SLUB fast paths for alloc
> and free using cmpxchg_local. The cmpxchg_local fast path is selected
> for arches that have CONFIG_FAST_CMPXCHG_LOCAL set. An arch should only
> set CONFIG_FAST_CMPXCHG_LOCAL if the cmpxchg_local is faster than an
> interrupt enable/disable sequence. This is known to be true for both
> x86 platforms so set FAST_CMPXCHG_LOCAL for both arches.
> 
> Not all arches can support fast cmpxchg operations. Typically the
> architecture must have an optimized cmpxchg instruction. The
> cmpxchg fast path makes no sense on platforms whose cmpxchg is
> slower than interrupt enable/disable (like f.e. IA64).
> 
> The advantages of a cmpxchg_local based fast path are:
> 
> 1. Lower cycle count (30%-60% faster)
> 
> 2. There is no need to disable and enable interrupts on the fast path.
>    Currently interrupts have to be disabled and enabled on every
>    slab operation. This is likely saving a significant percentage
>    of interrupt off / on sequences in the kernel.
> 
> 3. The disposal of freed slabs can occur with interrupts enabled.
> 

It would require some testing, but I suspect that powerpc, mips and m32r
are three other architectures that could benefit from this (from the top
of my head)

Mathieu

> The alternate path is realized using #ifdef's. Several attempts to do the
> same with macros and in line functions resulted in a mess (in particular due
> to the strange way that local_interrupt_save() handles its argument and due
> to the need to define macros/functions that sometimes disable interrupts
> and sometimes do something else. The macro based approaches made it also
> difficult to preserve the optimizations for the non cmpxchg paths).
> 
> #ifdef seems to be the way to go here to have a readable source.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 
> ---
>  arch/x86/Kconfig.i386   |    4 ++
>  arch/x86/Kconfig.x86_64 |    4 ++
>  mm/slub.c               |   71 ++++++++++++++++++++++++++++++++++++++++++++++--
>  3 files changed, 77 insertions(+), 2 deletions(-)
> 
> Index: linux-2.6/mm/slub.c
> ===================================================================
> --- linux-2.6.orig/mm/slub.c	2007-10-27 10:39:07.583665939 -0700
> +++ linux-2.6/mm/slub.c	2007-10-27 10:40:19.710415861 -0700
> @@ -1496,7 +1496,12 @@ static void *__slab_alloc(struct kmem_ca
>  {
>  	void **object;
>  	struct page *new;
> +#ifdef CONFIG_FAST_CMPXCHG_LOCAL
> +	unsigned long flags;
>  
> +	local_irq_save(flags);
> +	preempt_enable_no_resched();
> +#endif
>  	if (!c->page)
>  		goto new_slab;
>  
> @@ -1518,6 +1523,10 @@ load_freelist:
>  unlock_out:
>  	slab_unlock(c->page);
>  out:
> +#ifdef CONFIG_FAST_CMPXCHG_LOCAL
> +	preempt_disable();
> +	local_irq_restore(flags);
> +#endif
>  	return object;
>  
>  another_slab:
> @@ -1592,9 +1601,26 @@ static void __always_inline *slab_alloc(
>  		gfp_t gfpflags, int node, void *addr)
>  {
>  	void **object;
> -	unsigned long flags;
>  	struct kmem_cache_cpu *c;
>  
> +#ifdef CONFIG_FAST_CMPXCHG_LOCAL
> +	c = get_cpu_slab(s, get_cpu());
> +	do {
> +		object = c->freelist;
> +		if (unlikely(is_end(object) || !node_match(c, node))) {
> +			object = __slab_alloc(s, gfpflags, node, addr, c);
> +			if (unlikely(!object)) {
> +				put_cpu();
> +				goto out;
> +			}
> +			break;
> +		}
> +	} while (cmpxchg_local(&c->freelist, object, object[c->offset])
> +								!= object);
> +	put_cpu();
> +#else
> +	unsigned long flags;
> +
>  	local_irq_save(flags);
>  	c = get_cpu_slab(s, smp_processor_id());
>  	if (unlikely((is_end(c->freelist)) || !node_match(c, node))) {
> @@ -1609,6 +1635,7 @@ static void __always_inline *slab_alloc(
>  		c->freelist = object[c->offset];
>  	}
>  	local_irq_restore(flags);
> +#endif
>  
>  	if (unlikely((gfpflags & __GFP_ZERO)))
>  		memset(object, 0, c->objsize);
> @@ -1644,6 +1671,11 @@ static void __slab_free(struct kmem_cach
>  	void *prior;
>  	void **object = (void *)x;
>  
> +#ifdef CONFIG_FAST_CMPXCHG_LOCAL
> +	unsigned long flags;
> +
> +	local_irq_save(flags);
> +#endif
>  	slab_lock(page);
>  
>  	if (unlikely(SlabDebug(page)))
> @@ -1669,6 +1701,9 @@ checks_ok:
>  
>  out_unlock:
>  	slab_unlock(page);
> +#ifdef CONFIG_FAST_CMPXCHG_LOCAL
> +	local_irq_restore(flags);
> +#endif
>  	return;
>  
>  slab_empty:
> @@ -1679,6 +1714,9 @@ slab_empty:
>  		remove_partial(s, page);
>  
>  	slab_unlock(page);
> +#ifdef CONFIG_FAST_CMPXCHG_LOCAL
> +	local_irq_restore(flags);
> +#endif
>  	discard_slab(s, page);
>  	return;
>  
> @@ -1703,9 +1741,37 @@ static void __always_inline slab_free(st
>  			struct page *page, void *x, void *addr)
>  {
>  	void **object = (void *)x;
> -	unsigned long flags;
>  	struct kmem_cache_cpu *c;
>  
> +#ifdef CONFIG_FAST_CMPXCHG_LOCAL
> +	void **freelist;
> +
> +	c = get_cpu_slab(s, get_cpu());
> +	debug_check_no_locks_freed(object, s->objsize);
> +	do {
> +		freelist = c->freelist;
> +		barrier();
> +		/*
> +		 * If the compiler would reorder the retrieval of c->page to
> +		 * come before c->freelist then an interrupt could
> +		 * change the cpu slab before we retrieve c->freelist. We
> +		 * could be matching on a page no longer active and put the
> +		 * object onto the freelist of the wrong slab.
> +		 *
> +		 * On the other hand: If we already have the freelist pointer
> +		 * then any change of cpu_slab will cause the cmpxchg to fail
> +		 * since the freelist pointers are unique per slab.
> +		 */
> +		if (unlikely(page != c->page || c->node < 0)) {
> +			__slab_free(s, page, x, addr, c->offset);
> +			break;
> +		}
> +		object[c->offset] = freelist;
> +	} while (cmpxchg_local(&c->freelist, freelist, object) != freelist);
> +	put_cpu();
> +#else
> +	unsigned long flags;
> +
>  	local_irq_save(flags);
>  	debug_check_no_locks_freed(object, s->objsize);
>  	c = get_cpu_slab(s, smp_processor_id());
> @@ -1716,6 +1782,7 @@ static void __always_inline slab_free(st
>  		__slab_free(s, page, x, addr, c->offset);
>  
>  	local_irq_restore(flags);
> +#endif
>  }
>  
>  void kmem_cache_free(struct kmem_cache *s, void *x)
> Index: linux-2.6/arch/x86/Kconfig.i386
> ===================================================================
> --- linux-2.6.orig/arch/x86/Kconfig.i386	2007-10-27 10:38:33.630415778 -0700
> +++ linux-2.6/arch/x86/Kconfig.i386	2007-10-27 10:40:19.710415861 -0700
> @@ -51,6 +51,10 @@ config X86
>  	bool
>  	default y
>  
> +config FAST_CMPXCHG_LOCAL
> +	bool
> +	default y
> +
>  config MMU
>  	bool
>  	default y
> Index: linux-2.6/arch/x86/Kconfig.x86_64
> ===================================================================
> --- linux-2.6.orig/arch/x86/Kconfig.x86_64	2007-10-27 10:38:33.630415778 -0700
> +++ linux-2.6/arch/x86/Kconfig.x86_64	2007-10-27 10:40:19.710415861 -0700
> @@ -97,6 +97,10 @@ config X86_CMPXCHG
>  	bool
>  	default y
>  
> +config FAST_CMPXCHG_LOCAL
> +	bool
> +	default y
> +
>  config EARLY_PRINTK
>  	bool
>  	default y
> 
> -- 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

-- 
Mathieu Desnoyers
Computer Engineering Ph.D. Student, Ecole Polytechnique de Montreal
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
