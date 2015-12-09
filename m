Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id 3476B6B0254
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 13:53:34 -0500 (EST)
Received: by qgeb1 with SMTP id b1so94765752qge.1
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 10:53:33 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d133si10154439qkb.91.2015.12.09.10.53.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Dec 2015 10:53:33 -0800 (PST)
Date: Wed, 9 Dec 2015 19:53:25 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH V2 8/9] slab: implement bulk free in SLAB allocator
Message-ID: <20151209195325.68eaf314@redhat.com>
In-Reply-To: <alpine.DEB.2.20.1512090945570.30894@east.gentwo.org>
References: <20151208161751.21945.53936.stgit@firesoul>
	<20151208161903.21945.33876.stgit@firesoul>
	<alpine.DEB.2.20.1512090945570.30894@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov@virtuozzo.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, brouer@redhat.com

On Wed, 9 Dec 2015 10:06:39 -0600 (CST)
Christoph Lameter <cl@linux.com> wrote:

> On Tue, 8 Dec 2015, Jesper Dangaard Brouer wrote:
> 
> > +void kmem_cache_free_bulk(struct kmem_cache *orig_s, size_t size, void **p)
> 
> Drop orig_s as a parameter? This makes the function have less code and
> makes it more universally useful for freeing large amount of objects.

I really like the idea of making it able to free kmalloc'ed objects.
But I hate to change the API again... (I do have a use-case in the
network stack where I could use this feature).


> Could we do the following API change patch before this series so that
> kmem_cache_free_bulk is properly generalized?

I'm traveling (to Sweden) Thursday (afternoon) and will be back late
Friday (and have to play Viking in the weekend), thus to be realistic
I'll start working on this Monday, so we can get some benchmark numbers
to guide this decision.
 
 
> From: Christoph Lameter <cl@linux.com>
> Subject: slab bulk api: Remove the kmem_cache parameter from kmem_cache_bulk_free()
> 
> It is desirable and necessary to free objects from different kmem_caches.
> It is required in order to support memcg object freeing across different5
> cgroups.
> 
> So drop the pointless parameter and allow freeing of arbitrary lists
> of slab allocated objects.
> 
> This patch also does the proper compound page handling so that
> arbitrary objects allocated via kmalloc() can be handled by
> kmem_cache_bulk_free().
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>
> 
> Index: linux/include/linux/slab.h
> ===================================================================
> --- linux.orig/include/linux/slab.h
> +++ linux/include/linux/slab.h
> @@ -315,7 +315,7 @@ void kmem_cache_free(struct kmem_cache *
>   *
>   * Note that interrupts must be enabled when calling these functions.
>   */
> -void kmem_cache_free_bulk(struct kmem_cache *, size_t, void **);
> +void kmem_cache_free_bulk(size_t, void **);
>  int kmem_cache_alloc_bulk(struct kmem_cache *, gfp_t, size_t, void **);
> 
>  #ifdef CONFIG_NUMA
> Index: linux/mm/slab.c
> ===================================================================
> --- linux.orig/mm/slab.c
> +++ linux/mm/slab.c
> @@ -3413,9 +3413,9 @@ void *kmem_cache_alloc(struct kmem_cache
>  }
>  EXPORT_SYMBOL(kmem_cache_alloc);
> 
> -void kmem_cache_free_bulk(struct kmem_cache *s, size_t size, void **p)
> +void kmem_cache_free_bulk(size_t size, void **p)
>  {
> -	__kmem_cache_free_bulk(s, size, p);
> +	__kmem_cache_free_bulk(size, p);
>  }
>  EXPORT_SYMBOL(kmem_cache_free_bulk);
> 
> Index: linux/mm/slab.h
> ===================================================================
> --- linux.orig/mm/slab.h
> +++ linux/mm/slab.h
> @@ -166,10 +166,10 @@ ssize_t slabinfo_write(struct file *file
>  /*
>   * Generic implementation of bulk operations
>   * These are useful for situations in which the allocator cannot
> - * perform optimizations. In that case segments of the objecct listed
> + * perform optimizations. In that case segments of the object listed
>   * may be allocated or freed using these operations.
>   */
> -void __kmem_cache_free_bulk(struct kmem_cache *, size_t, void **);
> +void __kmem_cache_free_bulk(size_t, void **);
>  int __kmem_cache_alloc_bulk(struct kmem_cache *, gfp_t, size_t, void **);
> 
>  #ifdef CONFIG_MEMCG_KMEM
> Index: linux/mm/slub.c
> ===================================================================
> --- linux.orig/mm/slub.c
> +++ linux/mm/slub.c
> @@ -2887,23 +2887,30 @@ static int build_detached_freelist(struc
> 
> 
>  /* Note that interrupts must be enabled when calling this function. */
> -void kmem_cache_free_bulk(struct kmem_cache *orig_s, size_t size, void **p)
> +void kmem_cache_free_bulk(size_t size, void **p)
>  {
>  	if (WARN_ON(!size))
>  		return;
> 
>  	do {
>  		struct detached_freelist df;
> -		struct kmem_cache *s;
> +		struct page *page;
> 
> -		/* Support for memcg */
> -		s = cache_from_obj(orig_s, p[size - 1]);
> +		page = virt_to_head_page(p[size - 1]);

Think we can drop this.
 
> -		size = build_detached_freelist(s, size, p, &df);
> +		if (unlikely(!PageSlab(page))) {
> +			BUG_ON(!PageCompound(page));
> +			kfree_hook(p[size - 1]);
> +			__free_kmem_pages(page, compound_order(page));
> +			p[--size] = NULL;
> +			continue;
> +		}

and move above into build_detached_freelist() and make it a little more
pretty code wise (avoiding the p[size -1] juggling).

> +
> +		size = build_detached_freelist(page->slab_cache, size, p, &df);

also think we should be able to drop the kmem_cache param "page->slab_cache".


>  		if (unlikely(!df.page))
>  			continue;
> 
> -		slab_free(s, df.page, df.freelist, df.tail, df.cnt, _RET_IP_);
> +		slab_free(page->slab_cache, df.page, df.freelist, df.tail, df.cnt, _RET_IP_);
>  	} while (likely(size));
>  }
>  EXPORT_SYMBOL(kmem_cache_free_bulk);
> @@ -2963,7 +2970,7 @@ int kmem_cache_alloc_bulk(struct kmem_ca
>  error:
>  	local_irq_enable();
>  	slab_post_alloc_hook(s, flags, i, p);
> -	__kmem_cache_free_bulk(s, i, p);
> +	__kmem_cache_free_bulk(i, p);
>  	return 0;
>  }
>  EXPORT_SYMBOL(kmem_cache_alloc_bulk);


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
