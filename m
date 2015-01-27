Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 55F366B0032
	for <linux-mm@kvack.org>; Tue, 27 Jan 2015 03:20:16 -0500 (EST)
Received: by mail-pd0-f172.google.com with SMTP id v10so17537115pde.3
        for <linux-mm@kvack.org>; Tue, 27 Jan 2015 00:20:16 -0800 (PST)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id nj1si486078pbc.249.2015.01.27.00.20.14
        for <linux-mm@kvack.org>;
        Tue, 27 Jan 2015 00:20:15 -0800 (PST)
Date: Tue, 27 Jan 2015 17:21:32 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC 1/3] Slab infrastructure for array operations
Message-ID: <20150127082132.GE11358@js1304-P5Q-DELUXE>
References: <20150123213727.142554068@linux.com>
 <20150123213735.590610697@linux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150123213735.590610697@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: akpm@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@kernel.org, iamjoonsoo@lge.com, Jesper Dangaard Brouer <brouer@redhat.com>

On Fri, Jan 23, 2015 at 03:37:28PM -0600, Christoph Lameter wrote:
> This patch adds the basic infrastructure for alloc / free operations
> on pointer arrays. It includes a fallback function that can perform
> the array operations using the single alloc and free that every
> slab allocator performs.
> 
> Allocators must define _HAVE_SLAB_ALLOCATOR_OPERATIONS in their
> header files in order to implement their own fast version for
> these array operations.
> 
> Array operations allow a reduction of the processing overhead
> during allocation and therefore speed up acquisition of larger
> amounts of objects.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>
> 
> Index: linux/include/linux/slab.h
> ===================================================================
> --- linux.orig/include/linux/slab.h
> +++ linux/include/linux/slab.h
> @@ -123,6 +123,7 @@ struct kmem_cache *memcg_create_kmem_cac
>  void kmem_cache_destroy(struct kmem_cache *);
>  int kmem_cache_shrink(struct kmem_cache *);
>  void kmem_cache_free(struct kmem_cache *, void *);
> +void kmem_cache_free_array(struct kmem_cache *, size_t, void **);
>  
>  /*
>   * Please use this macro to create slab caches. Simply specify the
> @@ -290,6 +291,39 @@ static __always_inline int kmalloc_index
>  void *__kmalloc(size_t size, gfp_t flags);
>  void *kmem_cache_alloc(struct kmem_cache *, gfp_t flags);
>  
> +/*
> + * Additional flags that may be specified in kmem_cache_alloc_array()'s
> + * gfp flags.
> + *
> + * If no flags are specified then kmem_cache_alloc_array() will first exhaust
> + * the partial slab page lists of the local node, then allocate new pages from
> + * the page allocator as long as more than objects per page objects are wanted
> + * and fill up the rest from local cached objects. If that is not enough then
> + * the remaining objects will be allocated via kmem_cache_alloc()
> + */
> +
> +/* Use objects cached for the processor */
> +#define GFP_SLAB_ARRAY_LOCAL		((__force gfp_t)0x40000000)
> +
> +/* Use slabs from this node that have objects available */
> +#define GFP_SLAB_ARRAY_PARTIAL		((__force gfp_t)0x20000000)
> +
> +/* Allocate new slab pages from page allocator */
> +#define GFP_SLAB_ARRAY_NEW		((__force gfp_t)0x10000000)

Hello, Christoph.

Please correct my e-mail address next time. :)
iamjoonsoo.kim@lge.com or js1304@gmail.com

IMHO, exposing these options is not a good idea. It's really
implementation specific. And, this flag won't show consistent performance
according to specific slab implementation. For example, to get best
performance, if SLAB is used, GFP_SLAB_ARRAY_LOCAL would be the best option,
but, for the same purpose, if SLUB is used, GFP_SLAB_ARRAY_NEW would
be the best option. And, performance could also depend on number of objects
and size.

And, overriding gfp flag isn't a good idea. Someday gfp could use
these values and they can't notice that these are used in slab
subsystem with different meaning.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
