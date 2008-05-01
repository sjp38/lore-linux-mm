Date: Thu, 1 May 2008 03:54:18 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] SLQB v2
Message-ID: <20080501015418.GC15179@wotan.suse.de>
References: <20080410193137.GB9482@wotan.suse.de> <20080415034407.GA9120@ubuntu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080415034407.GA9120@ubuntu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Ahmed S. Darwish" <darwish.07@gmail.com>
Cc: Christoph Lameter <clameter@sgi.com>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi, sorry I missed this message initially..

On Tue, Apr 15, 2008 at 05:44:07AM +0200, Ahmed S. Darwish wrote:
> Hi!,
> 
> On Thu, Apr 10, 2008 at 09:31:38PM +0200, Nick Piggin wrote:
> ...
> > +
> > +/*
> > + * We use struct slqb_page fields to manage some slob allocation aspects,
> > + * however to avoid the horrible mess in include/linux/mm_types.h, we'll
> > + * just define our own struct slqb_page type variant here.
> > + */
> > +struct slqb_page {
> > +	union {
> > +		struct {
> > +			unsigned long flags;	/* mandatory */
> > +			atomic_t _count;	/* mandatory */
> > +			unsigned int inuse;	/* Nr of objects */
> > +		   	struct kmem_cache_list *list; /* Pointer to list */
> > +			void **freelist;	/* freelist req. slab lock */
> > +			union {
> > +				struct list_head lru; /* misc. list */
> > +				struct rcu_head rcu_head; /* for rcu freeing */
> > +			};
> > +		};
> > +		struct page page;
> > +	};
> > +};
> 
> A small question for SLUB devs, would you accept a patch that does
> a similar thing by creating 'slub_page' instead of stuffing slub 
> elements (freelist, inuse, ..) in 'mm_types::struct page' unions ?

I'd like to see that. I have a patch for SLUB, actually.

 
> Maybe cause I'm new to MM, but I felt I could understand the code 
> much more better the SLQB slqb_page way.
> 
> ...
> > +/*
> > + * Kmalloc subsystem.
> > + */
> > +#if defined(ARCH_KMALLOC_MINALIGN) && ARCH_KMALLOC_MINALIGN > 8
> > +#define KMALLOC_MIN_SIZE ARCH_KMALLOC_MINALIGN
> > +#else
> > +#define KMALLOC_MIN_SIZE 8
> > +#endif
> > +
> > +#define KMALLOC_SHIFT_LOW ilog2(KMALLOC_MIN_SIZE)
> > +#define KMALLOC_SHIFT_SLQB_HIGH (PAGE_SHIFT + 5)
> > +
> > +/*
> > + * We keep the general caches in an array of slab caches that are used for
> > + * 2^x bytes of allocations.
> > + */
> > +extern struct kmem_cache kmalloc_caches[KMALLOC_SHIFT_SLQB_HIGH + 1];
> > +
> 
> So AFAIK in an x86 where PAGE_SHIFT = 12, KMALLOC_SHIFT_SLQB_HIGH+1 will
> equal= 18.

Right. It actually isn't enough in some cases it turns out. I have increased
this a little bit in subsequent code (PAGE_SHIFT+8 I think is reasonable).
For SLUB they hand off to the page allocator instead. It isn't really a
big deal though, such allocations should be quite rare.


> > +/*
> > + * Sorry that the following has to be that ugly but some versions of GCC
> > + * have trouble with constant propagation and loops.
> > + */
> > +static __always_inline int kmalloc_index(size_t size)
> > +{
> > +	if (!size)
> > +		return 0;
> > +
> > +	if (size <= KMALLOC_MIN_SIZE)
> > +		return KMALLOC_SHIFT_LOW;
> > +
> > +	if (size > 64 && size <= 96)
> > +		return 1;
> > +	if (size > 128 && size <= 192)
> > +		return 2;
> > +	if (size <=          8) return 3;
> > +	if (size <=         16) return 4;
> > +	if (size <=         32) return 5;
> > +	if (size <=         64) return 6;
> > +	if (size <=        128) return 7;
> > +	if (size <=        256) return 8;
> > +	if (size <=        512) return 9;
> > +	if (size <=       1024) return 10;
> > +	if (size <=   2 * 1024) return 11;
> > +/*
> > + * The following is only needed to support architectures with a larger page
> > + * size than 4k.
> > + */
> > +	if (size <=   4 * 1024) return 12;
> > +	if (size <=   8 * 1024) return 13;
> > +	if (size <=  16 * 1024) return 14;
> > +	if (size <=  32 * 1024) return 15;
> > +	if (size <=  64 * 1024) return 16;
> > +	if (size <= 128 * 1024) return 17;
> > +	if (size <= 256 * 1024) return 18;
> > +	if (size <= 512 * 1024) return 19;
> 
> I'm sure there's something utterly wrong in my understanding, but how this
> is designed to not overflow kmalloc_caches[18] in an x86-32 machine ?
> 
> I can not see this possible-only-in-my-mind overflow happens in SLUB as it 
> just delegate the work to the page allocator if size > PAGE_SIZE.

Yeah, it is a big rough around the edges ;) I have fixed this up.


> > +#ifdef CONFIG_NUMA
> > +void *__kmalloc_node(size_t size, gfp_t flags, int node);
> > +void *kmem_cache_alloc_node(struct kmem_cache *, gfp_t flags, int node);
> > +
> > +static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
> > +{
> > +	if (__builtin_constant_p(size)) {
> > +		if (likely(!(flags & SLQB_DMA))) {
> > +			struct kmem_cache *s = kmalloc_slab(size);
> > +			if (!s)
> > +				return ZERO_SIZE_PTR;
> > +			return kmem_cache_alloc_node(s, flags, node);
> > +		}
> > +	}
> > +	return __kmalloc_node(size, flags, node);
> > +}
> 
> Why this compile-time/run-time divide although both kmem_cache_alloc{,_node}
> and __kmalloc{,_node} call slab_alloc() at the end ?

Constant size is by far the most common case, and so the kmalloc slab
should actually be able to be found by the compiler in that case.


> > +#endif
> > +
> > +#endif /* _LINUX_SLQB_DEF_H */
> > Index: linux-2.6/init/Kconfig
> > ===================================================================
> > --- linux-2.6.orig/init/Kconfig
> > +++ linux-2.6/init/Kconfig
> > @@ -701,6 +701,11 @@ config SLUB_DEBUG
> >  	  SLUB sysfs support. /sys/slab will not exist and there will be
> >  	  no support for cache validation etc.
> >  
> > +config SLQB_DEBUG
> > +	default y
> > +	bool "Enable SLQB debugging support"
> > +	depends on SLQB
> > +
> 
> Maybe if SLQB got merged it can just be easier to have a general SLAB_DEBUG
> option that is recognized by the current 4 slab allocators ?

Could be an idea.


> > + * SLIB assigns one slab for allocation to each processor.
> > + * Allocations only occur from these slabs called cpu slabs.
> > + *
> 
> SLQB is a much more better name than SLIB :).

Right! I experimented ;)

 
> > + * Slabs with free elements are kept on a partial list and during regular
> > + * operations no list for full slabs is used. If an object in a full slab is
> > + * freed then the slab will show up again on the partial lists.
> > + * We track full slabs for debugging purposes though because otherwise we
> > + * cannot scan all objects.
> > + *
> > + * Slabs are freed when they become empty. Teardown and setup is
> > + * minimal so we rely on the page allocators per cpu caches for
> > + * fast frees and allocs.
> > + */
> > +
> 
> Ok, I admit I didn't do my homework yet of fully understanding the
> diff between SLUB and SLQB except in the kmalloc(> PAGE_SIZE) case.
> I hope my understanding will get better soon.
> 
> ...
> > +/*
> > + * Slow path. The lockless freelist is empty or we need to perform
> > + * debugging duties.
> > + *
> > + * Interrupts are disabled.
> > + *
> > + * Processing is still very fast if new objects have been freed to the
> > + * regular freelist. In that case we simply take over the regular freelist
> > + * as the lockless freelist and zap the regular freelist.
> > + *
> > + * If that is not working then we fall back to the partial lists. We take the
> > + * first element of the freelist as the object to allocate now and move the
> > + * rest of the freelist to the lockless freelist.
> > + *
> > + * And if we were unable to get a new slab from the partial slab lists then
> > + * we need to allocate a new slab. This is slowest path since we may sleep.
> > + */
> > +static __always_inline void *__slab_alloc(struct kmem_cache *s,
> > +		gfp_t gfpflags, int node, void *addr)
> > +{
> 
> __slab_alloc istelf is not the slow-path, but the slow path begins 
> from the alloc_new: label, right ? 
> 
> If so, then IMHO the comment is a bit misleading since it gives 
> the impression that the whole __slab_alloc() is the slow path.

Oh. Yeah the comments are going to be all wrong, sorry. Ignore them
and stick to the code.

Thanks,
Nick 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
