Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id mAPKOUEk012507
	for <linux-mm@kvack.org>; Tue, 25 Nov 2008 15:24:30 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mAPKOpcv178294
	for <linux-mm@kvack.org>; Tue, 25 Nov 2008 15:24:51 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mAPLP0F4026386
	for <linux-mm@kvack.org>; Tue, 25 Nov 2008 16:25:00 -0500
Subject: Re: [RFC][PATCH -tip] kmemcheck: add hooks for the page allocator
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20081125170231.GA19260@localhost.localdomain>
References: <20081125170231.GA19260@localhost.localdomain>
Content-Type: text/plain
Date: Tue, 25 Nov 2008 12:24:49 -0800
Message-Id: <1227644689.12109.32.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Vegard Nossum <vegard.nossum@gmail.com>
Cc: Ingo Molnar <mingo@elte.hu>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2008-11-25 at 18:02 +0100, Vegard Nossum wrote:
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -23,6 +23,7 @@
>  #include <linux/bootmem.h>
>  #include <linux/compiler.h>
>  #include <linux/kernel.h>
> +#include <linux/kmemcheck.h>
>  #include <linux/module.h>
>  #include <linux/suspend.h>
>  #include <linux/pagevec.h>
> @@ -511,6 +512,9 @@ static void __free_pages_ok(struct page *page, unsigned int order)
>  	int i;
>  	int reserved = 0;
> 
> +	if (kmemcheck_page_is_tracked(page))
> +		kmemcheck_free_shadow(page, order);
> +
>  	for (i = 0 ; i < (1 << order) ; ++i)
>  		reserved += free_pages_check(page + i);
>  	if (reserved)
> @@ -974,6 +978,9 @@ static void free_hot_cold_page(struct page *page, int cold)
>  	struct per_cpu_pages *pcp;
>  	unsigned long flags;
> 
> +	if (kmemcheck_page_is_tracked(page))
> +		kmemcheck_free_shadow(page, 0);

I think it would be best to just integrate the
kmemcheck_page_is_tracked() inside of kmemcheck_free_shadow().  It will
be shorter and less error-prone.

>  	if (PageAnon(page))
>  		page->mapping = NULL;
>  	if (free_pages_check(page))
> @@ -1637,7 +1644,28 @@ nopage:
>  		dump_stack();
>  		show_mem();
>  	}
> +	return page;
>  got_pg:
> +	if (kmemcheck_enabled
> +		&& !(gfp_mask & (__GFP_HIGHMEM | __GFP_IO | __GFP_NOTRACK)))
> +	{
> +		int nr_pages = 1 << order;
> +
> +		/*
> +		 * NOTE: We choose to track GFP_ZERO pages too; in fact, they
> +		 * can become uninitialized by copying uninitialized memory
> +		 * into them.
> +		 */
> +
> +		/* XXX: Can use zone->node for node? */
> +		kmemcheck_alloc_shadow(page, order, gfp_mask, -1);
> +
> +		if (gfp_mask & __GFP_ZERO)
> +			kmemcheck_mark_initialized_pages(page, nr_pages);
> +		else
> +			kmemcheck_mark_uninitialized_pages(page, nr_pages);
> +	}
> +
>  	return page;
>  }

That's too much gunk to add to a core function like
free_hot_cold_page().  Can you please break this out into a function?

Does 'kmemcheck_enabled' get compiled down to a constant if !
CONFIG_KMEMCHECK?  If not, it should.

>  EXPORT_SYMBOL(__alloc_pages_internal);
> diff --git a/mm/slab.c b/mm/slab.c
> index 37deade..286c6a6 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -1600,7 +1600,7 @@ static void *kmem_getpages(struct kmem_cache *cachep, gfp_t flags, int nodeid)
>  	if (cachep->flags & SLAB_RECLAIM_ACCOUNT)
>  		flags |= __GFP_RECLAIMABLE;
> 
> -	page = alloc_pages_node(nodeid, flags, cachep->gfporder);
> +	page = alloc_pages_node(nodeid, flags & ~__GFP_NOTRACK, cachep->gfporder);
>  	if (!page)
>  		return NULL;
> 
> @@ -1614,8 +1614,14 @@ static void *kmem_getpages(struct kmem_cache *cachep, gfp_t flags, int nodeid)
>  	for (i = 0; i < nr_pages; i++)
>  		__SetPageSlab(page + i);
> 
> -	if (kmemcheck_enabled && !(cachep->flags & SLAB_NOTRACK))
> -		kmemcheck_alloc_shadow(cachep, flags, nodeid, page, cachep->gfporder);
> +	if (kmemcheck_enabled && !(cachep->flags & SLAB_NOTRACK)) {
> +		kmemcheck_alloc_shadow(page, cachep->gfporder, flags, nodeid);
> +
> +		if (cachep->ctor)
> +			kmemcheck_mark_uninitialized_pages(page, nr_pages);
> +		else
> +			kmemcheck_mark_unallocated_pages(page, nr_pages);
> +	}
> 
>  	return page_address(page);
>  }
> @@ -1630,7 +1636,7 @@ static void kmem_freepages(struct kmem_cache *cachep, void *addr)
>  	const unsigned long nr_freed = i;
> 
>  	if (kmemcheck_page_is_tracked(page))
> -		kmemcheck_free_shadow(cachep, page, cachep->gfporder);
> +		kmemcheck_free_shadow(page, cachep->gfporder);
> 
>  	if (cachep->flags & SLAB_RECLAIM_ACCOUNT)
>  		sub_zone_page_state(page_zone(page),
> diff --git a/mm/slub.c b/mm/slub.c
> index adcb5e3..eb9855f 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -1064,6 +1064,8 @@ static inline struct page *alloc_slab_page(gfp_t flags, int node,
>  {
>  	int order = oo_order(oo);
> 
> +	flags |= __GFP_NOTRACK;
> +
>  	if (node == -1)
>  		return alloc_pages(flags, order);
>  	else
> @@ -1095,7 +1097,18 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
>  	if (kmemcheck_enabled
>  		&& !(s->flags & (SLAB_NOTRACK | DEBUG_DEFAULT_FLAGS)))
>  	{
> -		kmemcheck_alloc_shadow(s, flags, node, page, compound_order(page));
> +		int pages = 1 << oo_order(oo);
> +
> +		kmemcheck_alloc_shadow(page, oo_order(oo), flags, node);
> +
> +		/*
> +		 * Objects from caches that have a constructor don't get
> +		 * cleared when they're allocated, so we need to do it here.
> +		 */
> +		if (s->ctor)
> +			kmemcheck_mark_uninitialized_pages(page, pages);
> +		else
> +			kmemcheck_mark_unallocated_pages(page, pages);
>  	}
> 
>  	page->objects = oo_objects(oo);
> @@ -1172,7 +1185,7 @@ static void __free_slab(struct kmem_cache *s, struct page *page)
>  	}
> 
>  	if (kmemcheck_page_is_tracked(page))
> -		kmemcheck_free_shadow(s, page, compound_order(page));
> +		kmemcheck_free_shadow(page, compound_order(page));
> 
>  	mod_zone_page_state(page_zone(page),
>  		(s->flags & SLAB_RECLAIM_ACCOUNT) ?
> @@ -2679,8 +2692,8 @@ EXPORT_SYMBOL(__kmalloc);
> 
>  static void *kmalloc_large_node(size_t size, gfp_t flags, int node)
>  {
> -	struct page *page = alloc_pages_node(node, flags | __GFP_COMP,
> -						get_order(size));
> +	struct page *page = alloc_pages_node(node,
> +		flags | __GFP_COMP | __GFP_NOTRACK, get_order(size));
> 
>  	if (page)
>  		return page_address(page);

Adding the new flag made that pretty ugly.  Can you fix it up?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
