Received: by ug-out-1314.google.com with SMTP id u40so618985ugc.29
        for <linux-mm@kvack.org>; Mon, 14 Apr 2008 20:48:24 -0700 (PDT)
Date: Tue, 15 Apr 2008 05:44:07 +0200
Subject: Re: [patch] SLQB v2
Message-ID: <20080415034407.GA9120@ubuntu>
References: <20080410193137.GB9482@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080410193137.GB9482@wotan.suse.de>
From: "Ahmed S. Darwish" <darwish.07@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>, Christoph Lameter <clameter@sgi.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi!,

On Thu, Apr 10, 2008 at 09:31:38PM +0200, Nick Piggin wrote:
...
> +
> +/*
> + * We use struct slqb_page fields to manage some slob allocation aspects,
> + * however to avoid the horrible mess in include/linux/mm_types.h, we'll
> + * just define our own struct slqb_page type variant here.
> + */
> +struct slqb_page {
> +	union {
> +		struct {
> +			unsigned long flags;	/* mandatory */
> +			atomic_t _count;	/* mandatory */
> +			unsigned int inuse;	/* Nr of objects */
> +		   	struct kmem_cache_list *list; /* Pointer to list */
> +			void **freelist;	/* freelist req. slab lock */
> +			union {
> +				struct list_head lru; /* misc. list */
> +				struct rcu_head rcu_head; /* for rcu freeing */
> +			};
> +		};
> +		struct page page;
> +	};
> +};

A small question for SLUB devs, would you accept a patch that does
a similar thing by creating 'slub_page' instead of stuffing slub 
elements (freelist, inuse, ..) in 'mm_types::struct page' unions ?

Maybe cause I'm new to MM, but I felt I could understand the code 
much more better the SLQB slqb_page way.

...
> +/*
> + * Kmalloc subsystem.
> + */
> +#if defined(ARCH_KMALLOC_MINALIGN) && ARCH_KMALLOC_MINALIGN > 8
> +#define KMALLOC_MIN_SIZE ARCH_KMALLOC_MINALIGN
> +#else
> +#define KMALLOC_MIN_SIZE 8
> +#endif
> +
> +#define KMALLOC_SHIFT_LOW ilog2(KMALLOC_MIN_SIZE)
> +#define KMALLOC_SHIFT_SLQB_HIGH (PAGE_SHIFT + 5)
> +
> +/*
> + * We keep the general caches in an array of slab caches that are used for
> + * 2^x bytes of allocations.
> + */
> +extern struct kmem_cache kmalloc_caches[KMALLOC_SHIFT_SLQB_HIGH + 1];
> +

So AFAIK in an x86 where PAGE_SHIFT = 12, KMALLOC_SHIFT_SLQB_HIGH+1 will
equal= 18.

> +/*
> + * Sorry that the following has to be that ugly but some versions of GCC
> + * have trouble with constant propagation and loops.
> + */
> +static __always_inline int kmalloc_index(size_t size)
> +{
> +	if (!size)
> +		return 0;
> +
> +	if (size <= KMALLOC_MIN_SIZE)
> +		return KMALLOC_SHIFT_LOW;
> +
> +	if (size > 64 && size <= 96)
> +		return 1;
> +	if (size > 128 && size <= 192)
> +		return 2;
> +	if (size <=          8) return 3;
> +	if (size <=         16) return 4;
> +	if (size <=         32) return 5;
> +	if (size <=         64) return 6;
> +	if (size <=        128) return 7;
> +	if (size <=        256) return 8;
> +	if (size <=        512) return 9;
> +	if (size <=       1024) return 10;
> +	if (size <=   2 * 1024) return 11;
> +/*
> + * The following is only needed to support architectures with a larger page
> + * size than 4k.
> + */
> +	if (size <=   4 * 1024) return 12;
> +	if (size <=   8 * 1024) return 13;
> +	if (size <=  16 * 1024) return 14;
> +	if (size <=  32 * 1024) return 15;
> +	if (size <=  64 * 1024) return 16;
> +	if (size <= 128 * 1024) return 17;
> +	if (size <= 256 * 1024) return 18;
> +	if (size <= 512 * 1024) return 19;

I'm sure there's something utterly wrong in my understanding, but how this
is designed to not overflow kmalloc_caches[18] in an x86-32 machine ?

I can not see this possible-only-in-my-mind overflow happens in SLUB as it 
just delegate the work to the page allocator if size > PAGE_SIZE.

> +	if (size <= 1024 * 1024) return 20;
> +	if (size <=  2 * 1024 * 1024) return 21;
> +	return -1;
> +
> +/*
> + * What we really wanted to do and cannot do because of compiler issues is:
> + *	int i;
> + *	for (i = KMALLOC_SHIFT_LOW; i <= KMALLOC_SHIFT_HIGH; i++)
> + *		if (size <= (1 << i))
> + *			return i;
> + */
> +}
> +
> +/*
> + * Find the slab cache for a given combination of allocation flags and size.
> + *
> + * This ought to end up with a global pointer to the right cache
> + * in kmalloc_caches.
> + */
> +static __always_inline struct kmem_cache *kmalloc_slab(size_t size)
> +{
> +	int index = kmalloc_index(size);
> +
> +	if (index == 0)
> +		return NULL;
> +
> +	return &kmalloc_caches[index];
> +}
> +
> +#ifdef CONFIG_ZONE_DMA
> +#define SLQB_DMA __GFP_DMA
> +#else
> +/* Disable DMA functionality */
> +#define SLQB_DMA (__force gfp_t)0
> +#endif
> +
> +void *kmem_cache_alloc(struct kmem_cache *, gfp_t);
> +void *__kmalloc(size_t size, gfp_t flags);
> +
> +static __always_inline void *kmalloc(size_t size, gfp_t flags)
> +{
> +	if (__builtin_constant_p(size)) {
> +		if (likely(!(flags & SLQB_DMA))) {
> +			struct kmem_cache *s = kmalloc_slab(size);
> +			if (!s)
> +				return ZERO_SIZE_PTR;
> +			return kmem_cache_alloc(s, flags);
> +		}
> +	}
> +	return __kmalloc(size, flags);
> +}
> +
> +#ifdef CONFIG_NUMA
> +void *__kmalloc_node(size_t size, gfp_t flags, int node);
> +void *kmem_cache_alloc_node(struct kmem_cache *, gfp_t flags, int node);
> +
> +static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
> +{
> +	if (__builtin_constant_p(size)) {
> +		if (likely(!(flags & SLQB_DMA))) {
> +			struct kmem_cache *s = kmalloc_slab(size);
> +			if (!s)
> +				return ZERO_SIZE_PTR;
> +			return kmem_cache_alloc_node(s, flags, node);
> +		}
> +	}
> +	return __kmalloc_node(size, flags, node);
> +}

Why this compile-time/run-time divide although both kmem_cache_alloc{,_node}
and __kmalloc{,_node} call slab_alloc() at the end ?

> +#endif
> +
> +#endif /* _LINUX_SLQB_DEF_H */
> Index: linux-2.6/init/Kconfig
> ===================================================================
> --- linux-2.6.orig/init/Kconfig
> +++ linux-2.6/init/Kconfig
> @@ -701,6 +701,11 @@ config SLUB_DEBUG
>  	  SLUB sysfs support. /sys/slab will not exist and there will be
>  	  no support for cache validation etc.
>  
> +config SLQB_DEBUG
> +	default y
> +	bool "Enable SLQB debugging support"
> +	depends on SLQB
> +

Maybe if SLQB got merged it can just be easier to have a general SLAB_DEBUG
option that is recognized by the current 4 slab allocators ?

>  choice
>  	prompt "Choose SLAB allocator"
>  	default SLUB
> @@ -724,6 +729,9 @@ config SLUB
>  	   of queues of objects. SLUB can use memory efficiently
>  	   and has enhanced diagnostics.
>  
> +config SLQB
> +	bool "SLQB (Qeued allocator)"
> +
>  config SLOB
>  	depends on EMBEDDED
>  	bool "SLOB (Simple Allocator)"
> @@ -763,7 +771,7 @@ endmenu		# General setup
>  config SLABINFO
>  	bool
>  	depends on PROC_FS
> -	depends on SLAB || SLUB
> +	depends on SLAB || SLUB || SLQB
>  	default y
>  
>  config RT_MUTEXES
> Index: linux-2.6/lib/Kconfig.debug
> ===================================================================
> --- linux-2.6.orig/lib/Kconfig.debug
> +++ linux-2.6/lib/Kconfig.debug
> @@ -221,6 +221,16 @@ config SLUB_STATS
>  	  out which slabs are relevant to a particular load.
>  	  Try running: slabinfo -DA
>  
> +config SLQB_DEBUG_ON
> +	bool "SLQB debugging on by default"
> +	depends on SLQB_DEBUG
> +	default n
> +
> +config SLQB_STATS
> +	default n
> +	bool "Enable SLQB performance statistics"
> +	depends on SLQB
> +
>  config DEBUG_PREEMPT
>  	bool "Debug preemptible kernel"
>  	depends on DEBUG_KERNEL && PREEMPT && (TRACE_IRQFLAGS_SUPPORT || PPC64)
> Index: linux-2.6/mm/slqb.c
> ===================================================================
> --- /dev/null
> +++ linux-2.6/mm/slqb.c
> @@ -0,0 +1,4027 @@
> +/*
> + * SLQB: A slab allocator that focuses on per-CPU scaling, and good performance
> + * with order-0 allocations. Fastpaths emphasis is placed on local allocaiton
> + * and freeing, and remote freeing (freeing on another CPU from that which
> + * allocated).
> + *
> + * Using ideas from mm/slab.c, mm/slob.c, and mm/slub.c,
> + *
> + * And parts of code from mm/slub.c
> + * (C) 2007 SGI, Christoph Lameter <clameter@sgi.com>
> + */
> +
> +#include <linux/mm.h>
> +#include <linux/module.h>
> +#include <linux/bit_spinlock.h>
> +#include <linux/interrupt.h>
> +#include <linux/bitops.h>
> +#include <linux/slab.h>
> +#include <linux/seq_file.h>
> +#include <linux/cpu.h>
> +#include <linux/cpuset.h>
> +#include <linux/mempolicy.h>
> +#include <linux/ctype.h>
> +#include <linux/kallsyms.h>
> +#include <linux/memory.h>
> +
> +/*
> + * Lock order:
> + *   1. kmem_cache_node->list_lock
> + *    2. kmem_cache_remote_free->lock
> + *
> + *   Interrupts are disabled during allocation and deallocation in order to
> + *   make the slab allocator safe to use in the context of an irq. In addition
> + *   interrupts are disabled to ensure that the processor does not change
> + *   while handling per_cpu slabs, due to kernel preemption.
> + *
> + * SLIB assigns one slab for allocation to each processor.
> + * Allocations only occur from these slabs called cpu slabs.
> + *

SLQB is a much more better name than SLIB :).

> + * Slabs with free elements are kept on a partial list and during regular
> + * operations no list for full slabs is used. If an object in a full slab is
> + * freed then the slab will show up again on the partial lists.
> + * We track full slabs for debugging purposes though because otherwise we
> + * cannot scan all objects.
> + *
> + * Slabs are freed when they become empty. Teardown and setup is
> + * minimal so we rely on the page allocators per cpu caches for
> + * fast frees and allocs.
> + */
> +

Ok, I admit I didn't do my homework yet of fully understanding the
diff between SLUB and SLQB except in the kmalloc(> PAGE_SIZE) case.
I hope my understanding will get better soon.

...
> +/*
> + * Slow path. The lockless freelist is empty or we need to perform
> + * debugging duties.
> + *
> + * Interrupts are disabled.
> + *
> + * Processing is still very fast if new objects have been freed to the
> + * regular freelist. In that case we simply take over the regular freelist
> + * as the lockless freelist and zap the regular freelist.
> + *
> + * If that is not working then we fall back to the partial lists. We take the
> + * first element of the freelist as the object to allocate now and move the
> + * rest of the freelist to the lockless freelist.
> + *
> + * And if we were unable to get a new slab from the partial slab lists then
> + * we need to allocate a new slab. This is slowest path since we may sleep.
> + */
> +static __always_inline void *__slab_alloc(struct kmem_cache *s,
> +		gfp_t gfpflags, int node, void *addr)
> +{

__slab_alloc istelf is not the slow-path, but the slow path begins 
from the alloc_new: label, right ? 

If so, then IMHO the comment is a bit misleading since it gives 
the impression that the whole __slab_alloc() is the slow path.

> +	void *object;
> +	struct slqb_page *page;
> +	struct kmem_cache_cpu *c;
> +	struct kmem_cache_list *l;
> +#ifdef CONFIG_NUMA
> +	struct kmem_cache_node *n;
> +
> +	if (unlikely(node != -1) && unlikely(node != numa_node_id())) {
> +		n = s->node[node];
> +		VM_BUG_ON(!n);
> +		l = &n->list;
> +
> +		if (unlikely(!l->nr_partial && !l->nr_free && !l->remote_free_check))
> +			goto alloc_new;
> +
> +		spin_lock(&n->list_lock);
> +remote_list_have_object:
> +		page = __cache_list_get_page(s, l);
> +		if (unlikely(!page)) {
> +			spin_unlock(&n->list_lock);
> +			goto alloc_new;
> +		}
> +		VM_BUG_ON(node != -1 && node != slqb_page_to_nid(page));
> +
> +remote_found:
> +		object = page->freelist;
> +		page->freelist = get_freepointer(s, object);
> +		//prefetch(((void *)page->freelist) + s->offset);
> +		page->inuse++;
> +		VM_BUG_ON((page->inuse == s->objects) != (page->freelist == NULL));
> +		spin_unlock(&n->list_lock);
> +
> +		return object;
> +	}
> +#endif
> +
> +	c = get_cpu_slab(s, smp_processor_id());
> +	VM_BUG_ON(!c);
> +	l = &c->list;
> +	page = __cache_list_get_page(s, l);
> +	if (unlikely(!page))
> +		goto alloc_new;
> +	VM_BUG_ON(node != -1 && node != slqb_page_to_nid(page));
> +
> +local_found:
> +	object = page->freelist;
> +	page->freelist = get_freepointer(s, object);
> +	//prefetch(((void *)page->freelist) + s->offset);
> +	page->inuse++;
> +	VM_BUG_ON((page->inuse == s->objects) != (page->freelist == NULL));
> +
> +	return object;
> +
> +alloc_new:
> +#if 0
> +	/* XXX: load any partial? */
> +#endif
> +
> +	/* Caller handles __GFP_ZERO */
> +	gfpflags &= ~__GFP_ZERO;
> +
> +	if (gfpflags & __GFP_WAIT)
> +		local_irq_enable();
> +	page = new_slab_page(s, gfpflags, node);
> +	if (gfpflags & __GFP_WAIT)
> +		local_irq_disable();
> +	if (unlikely(!page))
> +		return NULL;
> +
> +	if (!NUMA_BUILD || likely(slqb_page_to_nid(page) == numa_node_id())) {
> +		c = get_cpu_slab(s, smp_processor_id());
> +		l = &c->list;
> +		page->list = l;
> +		l->nr_slabs++;
> +		if (page->inuse + 1 < s->objects) {
> +			list_add(&page->lru, &l->partial);
> +			l->nr_partial++;
> +		} else {
> +/*XXX			list_add(&page->lru, &l->full); */
> +		}
> +		goto local_found;
> +	} else {
> +#ifdef CONFIG_NUMA
> +		n = s->node[slqb_page_to_nid(page)];
> +		spin_lock(&n->list_lock);
> +		l = &n->list;
> +
> +		if (l->nr_free || l->nr_partial || l->remote_free_check) {
> +			__free_slab(s, page);
> +			goto remote_list_have_object;
> +		}
> +
> +		l->nr_slabs++;
> +		page->list = l;
> +		if (page->inuse + 1 < s->objects) {
> +			list_add(&page->lru, &l->partial);
> +			l->nr_partial++;
> +		} else {
> +/*XXX			list_add(&page->lru, &l->full); */
> +		}
> +		goto remote_found;
> +#endif
> +	}
> +
...

Thanks for helping me gaining a better understanding of SLQB!

Warm regards

-- 

"Better to light a candle, than curse the darkness"

Ahmed S. Darwish
Homepage: http://darwish.07.googlepages.com
Blog: http://darwish-07.blogspot.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
