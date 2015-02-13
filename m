Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id BEF966B0038
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 21:42:59 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id bj1so15667562pad.5
        for <linux-mm@kvack.org>; Thu, 12 Feb 2015 18:42:59 -0800 (PST)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id y5si1028916pdo.245.2015.02.12.18.42.57
        for <linux-mm@kvack.org>;
        Thu, 12 Feb 2015 18:42:58 -0800 (PST)
Date: Fri, 13 Feb 2015 11:45:15 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 2/3] slub: Support for array operations
Message-ID: <20150213024515.GB6592@js1304-P5Q-DELUXE>
References: <20150210194804.288708936@linux.com>
 <20150210194811.902155759@linux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150210194811.902155759@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: akpm@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@kernel.org, iamjoonsoo@lge.com, Jesper Dangaard Brouer <brouer@redhat.com>

On Tue, Feb 10, 2015 at 01:48:06PM -0600, Christoph Lameter wrote:
> The major portions are there but there is no support yet for
> directly allocating per cpu objects. There could also be more
> sophisticated code to exploit the batch freeing.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>
> 
> Index: linux/include/linux/slub_def.h
> ===================================================================
> --- linux.orig/include/linux/slub_def.h
> +++ linux/include/linux/slub_def.h
> @@ -110,4 +110,5 @@ static inline void sysfs_slab_remove(str
>  }
>  #endif
>  
> +#define _HAVE_SLAB_ALLOCATOR_ARRAY_OPERATIONS
>  #endif /* _LINUX_SLUB_DEF_H */
> Index: linux/mm/slub.c
> ===================================================================
> --- linux.orig/mm/slub.c
> +++ linux/mm/slub.c
> @@ -1379,13 +1379,9 @@ static void setup_object(struct kmem_cac
>  		s->ctor(object);
>  }
>  
> -static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
> +static struct page *__new_slab(struct kmem_cache *s, gfp_t flags, int node)
>  {
>  	struct page *page;
> -	void *start;
> -	void *p;
> -	int order;
> -	int idx;
>  
>  	if (unlikely(flags & GFP_SLAB_BUG_MASK)) {
>  		pr_emerg("gfp: %u\n", flags & GFP_SLAB_BUG_MASK);
> @@ -1394,33 +1390,42 @@ static struct page *new_slab(struct kmem
>  
>  	page = allocate_slab(s,
>  		flags & (GFP_RECLAIM_MASK | GFP_CONSTRAINT_MASK), node);
> -	if (!page)
> -		goto out;
> +	if (page) {
> +		inc_slabs_node(s, page_to_nid(page), page->objects);
> +		page->slab_cache = s;
> +		__SetPageSlab(page);
> +		if (page->pfmemalloc)
> +			SetPageSlabPfmemalloc(page);
> +	}
>  
> -	order = compound_order(page);
> -	inc_slabs_node(s, page_to_nid(page), page->objects);
> -	page->slab_cache = s;
> -	__SetPageSlab(page);
> -	if (page->pfmemalloc)
> -		SetPageSlabPfmemalloc(page);
> -
> -	start = page_address(page);
> -
> -	if (unlikely(s->flags & SLAB_POISON))
> -		memset(start, POISON_INUSE, PAGE_SIZE << order);
> -
> -	for_each_object_idx(p, idx, s, start, page->objects) {
> -		setup_object(s, page, p);
> -		if (likely(idx < page->objects))
> -			set_freepointer(s, p, p + s->size);
> -		else
> -			set_freepointer(s, p, NULL);
> -	}
> -
> -	page->freelist = start;
> -	page->inuse = page->objects;
> -	page->frozen = 1;
> -out:
> +	return page;
> +}
> +
> +static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
> +{
> +	struct page *page = __new_slab(s, flags, node);
> +
> +	if (page) {
> +		void *p;
> +		int idx;
> +		void *start = page_address(page);
> +
> +		if (unlikely(s->flags & SLAB_POISON))
> +			memset(start, POISON_INUSE,
> +				PAGE_SIZE << compound_order(page));

I'm not sure, but, this poisoning is also needed for
slab_array_alloc_from_page_allocator()?

> +
> +		for_each_object_idx(p, idx, s, start, page->objects) {
> +			setup_object(s, page, p);
> +			if (likely(idx < page->objects))
> +				set_freepointer(s, p, p + s->size);
> +			else
> +				set_freepointer(s, p, NULL);
> +		}
> +
> +		page->freelist = start;
> +		page->inuse = page->objects;
> +		page->frozen = 1;
> +	}
>  	return page;
>  }
>  
> @@ -2516,8 +2521,78 @@ EXPORT_SYMBOL(kmem_cache_alloc_node_trac
>  #endif
>  #endif
>  
> +int slab_array_alloc_from_partial(struct kmem_cache *s,
> +			size_t nr, void **p)
> +{
> +	void **end = p + nr;
> +	struct kmem_cache_node *n = get_node(s, numa_mem_id());
> +	int allocated = 0;
> +	unsigned long flags;
> +	struct page *page, *page2;
> +
> +	if (!n->nr_partial)
> +		return 0;
> +
> +
> +	spin_lock_irqsave(&n->list_lock, flags);
> +	list_for_each_entry_safe(page, page2, &n->partial, lru) {
> +		void *freelist;
> +
> +		if (page->objects - page->inuse > end - p)
> +			/* More objects free in page than we want */
> +			break;
> +		list_del(&page->lru);
> +		slab_lock(page);

slab_lock() doesn't protect freelist if CONFIG_HAVE_CMPXCHG_DOUBLE is
enabled. You should use cmpxchg_double_slab() things.

And, better solution is to use acquire_slab() rather than
re-implementation of detaching freelist.

> +		freelist = page->freelist;
> +		page->inuse = page->objects;
> +		page->freelist = NULL;
> +		slab_unlock(page);
> +		/* Grab all available objects */
> +		while (freelist) {
> +			*p++ = freelist;
> +			freelist = get_freepointer(s, freelist);
> +			allocated++;
> +		}

Fetching all objects with holding node lock could result in enomourous
lock contention. How about getting free ojbect pointer without holding
the node lock? We can temporarilly store all head of freelists in
array p and can fetch each object pointer without holding node lock.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
