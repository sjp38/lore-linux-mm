Date: Thu, 14 Feb 2008 14:06:15 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [patch 2/5] slub: Fallback to kmalloc_large for failing higher order allocs
Message-ID: <20080214140614.GE17641@csn.ul.ie>
References: <20080214040245.915842795@sgi.com> <20080214040313.616551392@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20080214040313.616551392@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On (13/02/08 20:02), Christoph Lameter didst pronounce:
> Slub already has two ways of allocating an object. One is via its own
> logic and the other is via the call to kmalloc_large to hand of object
> allocation to the page allocator. kmalloc_large is typically used
> for objects >= PAGE_SIZE.
> 
> We can use that handoff to avoid failing if a higher order kmalloc slab
> allocation cannot be satisfied by the page allocator.  If we reach the
> out of memory path then simply try a kmalloc_large(). kfree() can
> already handle the case of an object that was allocated via the page
> allocator and so this will work just fine (apart from object
> accounting...).
> 

This patch is depending on another patchset I haven't read so take any
comments with a grain of salt. But, if a kmalloc slab allocation fails and
it ultimately uses the page allocator, I do not see how calling the page
allocator directly makes a difference.

> For any kmalloc slab that already requires higher order allocs (which
> makes it impossible to use the page allocator fastpath!)
> we just use PAGE_ALLOC_COSTLY_ORDER to get the largest number of
> objects in one go from the page allocator slowpath.
> 
> On a 4k platform this patch will lead to the following use of higher
> order pages for the following kmalloc slabs:
> 
> 8 ... 1024	order 0
> 2048 .. 4096	order 3 (4k slab only after the next patch)
> 
> We may waste some space if fallback occurs on a 2k slab but we
> are always able to fallback to an order 0 alloc. I hope that
> satisfies Nick's concerns?
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 
> ---
>  mm/slub.c |   43 ++++++++++++++++++++++++++++++++++++++-----
>  1 file changed, 38 insertions(+), 5 deletions(-)
> 
> Index: linux-2.6/mm/slub.c
> ===================================================================
> --- linux-2.6.orig/mm/slub.c	2008-02-13 18:54:58.360385977 -0800
> +++ linux-2.6/mm/slub.c	2008-02-13 19:28:59.906913253 -0800
> @@ -211,6 +211,8 @@ static inline void ClearSlabDebug(struct
>  /* Internal SLUB flags */
>  #define __OBJECT_POISON		0x80000000 /* Poison object */
>  #define __SYSFS_ADD_DEFERRED	0x40000000 /* Not yet visible via sysfs */
> +#define __KMALLOC_CACHE		0x20000000 /* objects freed using kfree */
> +#define __PAGE_ALLOC_FALLBACK	0x10000000 /* Allow fallback to page alloc */
>  
>  /* Not all arches define cache_line_size */
>  #ifndef cache_line_size
> @@ -1539,7 +1541,6 @@ load_freelist:
>  unlock_out:
>  	slab_unlock(c->page);
>  	stat(c, ALLOC_SLOWPATH);
> -out:
>  #ifdef SLUB_FASTPATH
>  	local_irq_restore(flags);
>  #endif
> @@ -1574,8 +1575,24 @@ new_slab:
>  		c->page = new;
>  		goto load_freelist;
>  	}
> -	object = NULL;
> -	goto out;
> +#ifdef SLUB_FASTPATH
> +	local_irq_restore(flags);
> +#endif
> +	/*
> +	 * No memory available.
> +	 *
> +	 * If the slab uses higher order allocs but the object is
> +	 * smaller than a page size then we can fallback in emergencies
> +	 * to the page allocator via kmalloc_large. The page allocator may
> +	 * have failed to obtain a higher order page and we can try to
> +	 * allocate a single page if the object fits into a single page.
> +	 * That is only possible if certain conditions are met that are being
> +	 * checked when a slab is created.
> +	 */
> +	if (!(gfpflags & __GFP_THISNODE) && (s->flags & __PAGE_ALLOC_FALLBACK))
> +		return kmalloc_large(s->objsize, gfpflags);
> +
> +	return NULL;
>  debug:
>  	object = c->page->freelist;
>  	if (!alloc_debug_processing(s, c->page, object, addr))
> @@ -2322,7 +2339,20 @@ static int calculate_sizes(struct kmem_c
>  	size = ALIGN(size, align);
>  	s->size = size;
>  
> -	s->order = calculate_order(size);
> +	if ((flags & __KMALLOC_CACHE) &&
> +			PAGE_SIZE / size < slub_min_objects) {
> +		/*
> +		 * Kmalloc cache that would not have enough objects in
> +		 * an order 0 page. Kmalloc slabs can fallback to
> +		 * page allocator order 0 allocs so take a reasonably large
> +		 * order that will allows us a good number of objects.
> +		 */
> +		s->order = max(slub_max_order, PAGE_ALLOC_COSTLY_ORDER);
> +		s->flags |= __PAGE_ALLOC_FALLBACK;
> +		s->allocflags |= __GFP_NOWARN;

Here, it would make more sense to call buffered_rmqueue() for the number
of pages you want. That function does not know how to properly batch
allocations yet and work is needed to make it batch properly without
impacting anti-fragmentation. However, fixing it there means that the
PCP-refill would benefit as well as SLUB.

> +	} else
> +		s->order = calculate_order(size);
> +
>  	if (s->order < 0)
>  		return 0;
>  
> @@ -2539,7 +2569,7 @@ static struct kmem_cache *create_kmalloc
>  
>  	down_write(&slub_lock);
>  	if (!kmem_cache_open(s, gfp_flags, name, size, ARCH_KMALLOC_MINALIGN,
> -			flags, NULL))
> +			flags | __KMALLOC_CACHE, NULL))
>  		goto panic;
>  
>  	list_add(&s->list, &slab_caches);
> @@ -3058,6 +3088,9 @@ static int slab_unmergeable(struct kmem_
>  	if (slub_nomerge || (s->flags & SLUB_NEVER_MERGE))
>  		return 1;
>  
> +	if ((s->flags & __PAGE_ALLOC_FALLBACK)
> +		return 1;
> +
>  	if (s->ctor)
>  		return 1;
>  
> 
> -- 
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
