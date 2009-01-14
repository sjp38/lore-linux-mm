Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 600246B004F
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 05:53:21 -0500 (EST)
Received: by fg-out-1718.google.com with SMTP id 13so243255fge.4
        for <linux-mm@kvack.org>; Wed, 14 Jan 2009 02:53:18 -0800 (PST)
Message-ID: <84144f020901140253s72995188vb35a79501c38eaa3@mail.gmail.com>
Date: Wed, 14 Jan 2009 12:53:18 +0200
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [patch] SLQB slab allocator
In-Reply-To: <20090114090449.GE2942@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20090114090449.GE2942@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Lin Ming <ming.m.lin@intel.com>, Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi Nick,

On Wed, Jan 14, 2009 at 11:04 AM, Nick Piggin <npiggin@suse.de> wrote:
> This is the latest SLQB patch. Since last time, we have imported the sysfs
> framework from SLUB, and added specific event counters things for SLQB. I
> had initially been somewhat against this because it makes SLQB depend on
> another complex subsystem (which itself depends back on the slab allocator).
> But I guess it is not fundamentally different than /proc, and there needs to
> be some reporting somewhere. The individual per-slab counters really do make
> performance analysis much easier. There is a Documentation/vm/slqbinfo.c
> file, which is a parser adapted from slabinfo.c for SLUB.
>
> Fixed some bugs, including a nasty one that was causing remote objects to
> sneak onto local freelist, which would mean NUMA allocation was basically
> broken.
>
> The NUMA side of things is now much more complete. NUMA policies are obeyed.
> There is still a known bug where it won't run on a system with CPU-only
> nodes.
>
> CONFIG options are improved.
>
> Credit to some of the engineers at Intel for helping run tests, contributing
> ideas and patches to improve performance and fix bugs.
>
> I think it is getting to the point where it is stable and featureful. It
> really needs to be further proven in the performance area. We'd welcome
> any performance results or suggestions for tests to run.
>
> After this round of review/feedback, I plan to set about getting SLQB merged.

The code looks sane but I am still bit unhappy it's not a patchset on top of
SLUB. We've discussed this in the past and you mentioned that the design is
"completely different." Looking at it, I don't see any fundamental reason we
can't do a struct kmem_cache_list layer on top of SLUB which would make
merging of all this much less painful. I mean, at least in the past Linus hasn't
been too keen on adding yet another slab allocator to the kernel and I must
say judging from the SLAB -> SLUB experience, I'm not looking forward to it
either.

Also, to merge this, we need to see numbers. I assume SLQB fixes the
long-standing SLUB vs. SLAB regression reported by Intel and doesn't
introduce new performance regressions? Also, it would be nice for me to
be able to reproduce the numbers, especially for those tests where SLUB
performs worse.

One thing that puzzles me a bit is that in addition to the struct
kmem_cache_list caching, I also see things like cache coloring, avoiding
page allocator pass-through, and lots of prefetch hints in the code
which makes evaluating the performance differences quite difficult. If
these optimizations *are* a win, then why don't we add them to SLUB?

A completely different topic is memory efficiency of SLQB. The current
situation is that SLOB out-performs SLAB by huge margin whereas SLUB is
usually quite close. With the introduction of kmemtrace, I'm hopeful
that we will be able to fix up many of the badly fitting allocations in
the kernel to narrow the gap between SLUB and SLOB even more and I worry
SLQB will take us back to the SLAB numbers.

> +/*
> + * Primary per-cpu, per-kmem_cache structure.
> + */
> +struct kmem_cache_cpu {
> +	struct kmem_cache_list list; /* List for node-local slabs. */
> +
> +	unsigned int colour_next;

Do you see a performance improvement with cache coloring? IIRC,
Christoph has stated in the past that SLUB doesn't do it because newer
associative cache designs take care of the issue.

> +/*
> + * Constant size allocations use this path to find index into kmalloc caches
> + * arrays. get_slab() function is used for non-constant sizes.
> + */
> +static __always_inline int kmalloc_index(size_t size)
> +{
> +	if (unlikely(!size))
> +		return 0;
> +	if (unlikely(size > 1UL << KMALLOC_SHIFT_SLQB_HIGH))
> +		return 0;

SLUB doesn't have the above check. Does it fix an actual bug? Should we
add that to SLUB as well?

> +
> +	if (unlikely(size <= KMALLOC_MIN_SIZE))
> +		return KMALLOC_SHIFT_LOW;
> +
> +#if L1_CACHE_BYTES < 64
> +	if (size > 64 && size <= 96)
> +		return 1;
> +#endif
> +#if L1_CACHE_BYTES < 128
> +	if (size > 128 && size <= 192)
> +		return 2;
> +#endif
> +	if (size <=	  8) return 3;
> +	if (size <=	 16) return 4;
> +	if (size <=	 32) return 5;
> +	if (size <=	 64) return 6;
> +	if (size <=	128) return 7;
> +	if (size <=	256) return 8;
> +	if (size <=	512) return 9;
> +	if (size <=       1024) return 10;
> +	if (size <=   2 * 1024) return 11;
> +	if (size <=   4 * 1024) return 12;
> +	if (size <=   8 * 1024) return 13;
> +	if (size <=  16 * 1024) return 14;
> +	if (size <=  32 * 1024) return 15;
> +	if (size <=  64 * 1024) return 16;
> +	if (size <= 128 * 1024) return 17;
> +	if (size <= 256 * 1024) return 18;
> +	if (size <= 512 * 1024) return 19;
> +	if (size <= 1024 * 1024) return 20;
> +	if (size <=  2 * 1024 * 1024) return 21;
> +	return -1;

I suppose we could just make this one return zero and drop the above
check?

> +#define KMALLOC_HEADER (ARCH_KMALLOC_MINALIGN < sizeof(void *) ? sizeof(void *) : ARCH_KMALLOC_MINALIGN)
> +
> +static __always_inline void *kmalloc(size_t size, gfp_t flags)
> +{

So no page allocator pass-through, why is that? Looking at commit
aadb4bc4a1f9108c1d0fbd121827c936c2ed4217 ("SLUB: direct pass through of
page size or higher kmalloc requests"), I'd assume SQLB would get many
of the same benefits as well? It seems like a bad idea to hang on onto
large chuncks of pages in caches, no?

> +	if (__builtin_constant_p(size)) {
> +		struct kmem_cache *s;
> +
> +		s = kmalloc_slab(size, flags);
> +		if (unlikely(ZERO_OR_NULL_PTR(s)))
> +			return s;
> +
> +		return kmem_cache_alloc(s, flags);
> +	}
> +	return __kmalloc(size, flags);
> +}

> Index: linux-2.6/mm/slqb.c
> ===================================================================
> --- /dev/null
> +++ linux-2.6/mm/slqb.c
> @@ -0,0 +1,3368 @@
> +/*
> + * SLQB: A slab allocator that focuses on per-CPU scaling, and good performance
> + * with order-0 allocations. Fastpaths emphasis is placed on local allocaiton
> + * and freeing, but with a secondary goal of good remote freeing (freeing on
> + * another CPU from that which allocated).
> + *
> + * Using ideas and code from mm/slab.c, mm/slob.c, and mm/slub.c.
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
> +static inline int slab_hiwater(struct kmem_cache *s)
> +{
> +	return s->hiwater;
> +}
> +
> +static inline int slab_freebatch(struct kmem_cache *s)
> +{
> +	return s->freebatch;
> +}
> +
> +/*
> + * slqb_page overloads struct page, and is used to manage some slob allocation
> + * aspects, however to avoid the horrible mess in include/linux/mm_types.h,
> + * we'll just define our own struct slqb_page type variant here.
> + */

You say horrible mess, I say convenient. I think it's good that core vm
hackers who have no interest in the slab allocator can clearly see we're
overloading some of the struct page fields. But as SLOB does it like
this as well, I suppose we can keep it as-is.

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
> +static inline void struct_slqb_page_wrong_size(void)
> +{ BUILD_BUG_ON(sizeof(struct slqb_page) != sizeof(struct page)); }
> +
> +#define PG_SLQB_BIT (1 << PG_slab)
> +
> +static int kmem_size __read_mostly;
> +#ifdef CONFIG_NUMA
> +static int numa_platform __read_mostly;
> +#else
> +#define numa_platform 0
> +#endif

Hmm, why do we want to do this? If someone is running a CONFIG_NUMA
kernel on an UMA machine, let them suffer?

And if we *do* need to do this, can we move numa_platform() logic out of
the memory allocator?

> +#ifdef CONFIG_SMP
> +/*
> + * If enough objects have been remotely freed back to this list,
> + * remote_free_check will be set. In which case, we'll eventually come here
> + * to take those objects off our remote_free list and onto our LIFO freelist.
> + *
> + * Caller must be the owner CPU in the case of per-CPU list, or hold the node's
> + * list_lock in the case of per-node list.
> + */
> +static void claim_remote_free_list(struct kmem_cache *s, struct kmem_cache_list *l)
> +{
> +	void **head, **tail;
> +	int nr;
> +
> +	VM_BUG_ON(!l->remote_free.list.head != !l->remote_free.list.tail);
> +
> +	if (!l->remote_free.list.nr)
> +		return;
> +
> +	l->remote_free_check = 0;
> +	head = l->remote_free.list.head;
> +	prefetchw(head);

So this prefetchw() is for flush_free_list(), right? A comment would be
nice.

> +
> +	spin_lock(&l->remote_free.lock);
> +	l->remote_free.list.head = NULL;
> +	tail = l->remote_free.list.tail;
> +	l->remote_free.list.tail = NULL;
> +	nr = l->remote_free.list.nr;
> +	l->remote_free.list.nr = 0;
> +	spin_unlock(&l->remote_free.lock);
> +
> +	if (!l->freelist.nr)
> +		l->freelist.head = head;
> +	else
> +		set_freepointer(s, l->freelist.tail, head);
> +	l->freelist.tail = tail;
> +
> +	l->freelist.nr += nr;
> +
> +	slqb_stat_inc(l, CLAIM_REMOTE_LIST);
> +	slqb_stat_add(l, CLAIM_REMOTE_LIST_OBJECTS, nr);
> +}
> +#endif
> +
> +/*
> + * Allocation fastpath. Get an object from the list's LIFO freelist, or
> + * return NULL if it is empty.
> + *
> + * Caller must be the owner CPU in the case of per-CPU list, or hold the node's
> + * list_lock in the case of per-node list.
> + */
> +static __always_inline void *__cache_list_get_object(struct kmem_cache *s, struct kmem_cache_list *l)
> +{
> +	void *object;
> +
> +	object = l->freelist.head;
> +	if (likely(object)) {
> +		void *next = get_freepointer(s, object);
> +		VM_BUG_ON(!l->freelist.nr);
> +		l->freelist.nr--;
> +		l->freelist.head = next;
> +		if (next)
> +			prefetchw(next);

Why do we need this prefetchw() here?

> +		return object;
> +	}
> +	VM_BUG_ON(l->freelist.nr);
> +
> +#ifdef CONFIG_SMP
> +	if (unlikely(l->remote_free_check)) {
> +		claim_remote_free_list(s, l);
> +
> +		if (l->freelist.nr > slab_hiwater(s))
> +			flush_free_list(s, l);
> +
> +		/* repetition here helps gcc :( */
> +		object = l->freelist.head;
> +		if (likely(object)) {
> +			void *next = get_freepointer(s, object);
> +			VM_BUG_ON(!l->freelist.nr);
> +			l->freelist.nr--;
> +			l->freelist.head = next;
> +			if (next)
> +				prefetchw(next);

Or here?

> +			return object;
> +		}
> +		VM_BUG_ON(l->freelist.nr);
> +	}
> +#endif
> +
> +	return NULL;
> +}
> +
> +/*
> + * Slow(er) path. Get a page from this list's existing pages. Will be a
> + * new empty page in the case that __slab_alloc_page has just been called
> + * (empty pages otherwise never get queued up on the lists), or a partial page
> + * already on the list.
> + *
> + * Caller must be the owner CPU in the case of per-CPU list, or hold the node's
> + * list_lock in the case of per-node list.
> + */
> +static noinline void *__cache_list_get_page(struct kmem_cache *s, struct kmem_cache_list *l)
> +{
> +	struct slqb_page *page;
> +	void *object;
> +
> +	if (unlikely(!l->nr_partial))
> +		return NULL;
> +
> +	page = list_first_entry(&l->partial, struct slqb_page, lru);
> +	VM_BUG_ON(page->inuse == s->objects);
> +	if (page->inuse + 1 == s->objects) {
> +		l->nr_partial--;
> +		list_del(&page->lru);
> +/*XXX		list_move(&page->lru, &l->full); */
> +	}
> +
> +	VM_BUG_ON(!page->freelist);
> +
> +	page->inuse++;
> +
> +//	VM_BUG_ON(node != -1 && node != slqb_page_to_nid(page));
> +
> +	object = page->freelist;
> +	page->freelist = get_freepointer(s, object);
> +	if (page->freelist)
> +		prefetchw(page->freelist);

I don't understand this prefetchw(). Who exactly is going to be updating
contents of page->freelist?

> +/*
> + * Perform some interrupts-on processing around the main allocation path
> + * (debug checking and memset()ing).
> + */
> +static __always_inline void *slab_alloc(struct kmem_cache *s,
> +		gfp_t gfpflags, int node, void *addr)
> +{
> +	void *object;
> +	unsigned long flags;
> +
> +again:
> +	local_irq_save(flags);
> +	object = __slab_alloc(s, gfpflags, node);
> +	local_irq_restore(flags);
> +

As a cleanup, you could just do:

    if (unlikely(object == NULL))
            return NULL;

here to avoid the double comparison. Maybe it even generates better asm.

> +	if (unlikely(slab_debug(s)) && likely(object)) {
> +		if (unlikely(!alloc_debug_processing(s, object, addr)))
> +			goto again;
> +	}
> +
> +	if (unlikely(gfpflags & __GFP_ZERO) && likely(object))
> +		memset(object, 0, s->objsize);
> +
> +	return object;
> +}
> +
> +void *kmem_cache_alloc(struct kmem_cache *s, gfp_t gfpflags)
> +{
> +	int node = -1;
> +#ifdef CONFIG_NUMA
> +	if (unlikely(current->flags & (PF_SPREAD_SLAB | PF_MEMPOLICY)))
> +		node = alternate_nid(s, gfpflags, node);
> +#endif
> +	return slab_alloc(s, gfpflags, node, __builtin_return_address(0));

The return address is wrong when kmem_cache_alloc() is called through
__kmalloc().

As a side note, you can use the shorter _RET_IP_ instead of
builtin_return_address(0) everywhere.

                            Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
