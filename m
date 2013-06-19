Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 2D61F6B0033
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 02:30:20 -0400 (EDT)
Date: Wed, 19 Jun 2013 15:30:37 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [3.11 3/4] Move kmalloc_node functions to common code
Message-ID: <20130619063037.GB12231@lge.com>
References: <20130614195500.373711648@linux.com>
 <0000013f444bf6e9-d535ba8b-df9e-4053-9ed4-eaba75e2cfd2-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0000013f444bf6e9-d535ba8b-df9e-4053-9ed4-eaba75e2cfd2-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On Fri, Jun 14, 2013 at 08:06:36PM +0000, Christoph Lameter wrote:
> The kmalloc_node functions of all slab allcoators are similar now so
> lets move them into slab.h. This requires some function naming changes
> in slob.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>
> 
> Index: linux/include/linux/slab.h
> ===================================================================
> --- linux.orig/include/linux/slab.h	2013-06-14 13:40:52.424106451 -0500
> +++ linux/include/linux/slab.h	2013-06-14 14:45:24.000000000 -0500
> @@ -289,6 +289,38 @@ static __always_inline int kmalloc_index
>  }
>  #endif /* !CONFIG_SLOB */
>  
> +void *__kmalloc(size_t size, gfp_t flags);
> +void *kmem_cache_alloc(struct kmem_cache *, gfp_t flags);
> +
> +#ifdef CONFIG_NUMA
> +void *__kmalloc_node(size_t size, gfp_t flags, int node);
> +void *kmem_cache_alloc_node(struct kmem_cache *, gfp_t flags, int node);
> +#else
> +static __always_inline void *__kmalloc_node(size_t size, gfp_t flags, int node)
> +{
> +	return __kmalloc(size, flags);
> +}
> +
> +static __always_inline void *kmem_cache_alloc_node(struct kmem_cache *s, gfp_t flags, int node)
> +{
> +	return kmem_cache_alloc(s, flags);
> +}
> +#endif
> +
> +#ifdef CONFIG_TRACING
> +extern void *kmem_cache_alloc_node_trace(struct kmem_cache *s,
> +					   gfp_t gfpflags,
> +					   int node);
> +#else
> +static __always_inline void *
> +kmem_cache_alloc_node_trace(struct kmem_cache *s,
> +			      gfp_t gfpflags,
> +			      int node)
> +{
> +	return kmem_cache_alloc_node(s, gfpflags, node);
> +}
> +#endif
> +
>  #ifdef CONFIG_SLAB
>  #include <linux/slab_def.h>
>  #endif
> @@ -321,6 +353,23 @@ static __always_inline int kmalloc_size(
>  	return 0;
>  }
>  
> +static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
> +{
> +#ifndef CONFIG_SLOB
> +	if (__builtin_constant_p(size) &&
> +		size <= KMALLOC_MAX_CACHE_SIZE && !(flags & SLAB_CACHE_DMA)) {

s/SLAB_CACHE_DMA/GFP_DMA

> +		int i = kmalloc_index(size);
> +
> +		if (!i)
> +			return ZERO_SIZE_PTR;
> +
> +		return kmem_cache_alloc_node_trace(kmalloc_caches[i],
> +			       			flags, node);
> +	}
> +#endif
> +	return __kmalloc_node(size, flags, node);
> +}
> +
>  /*
>   * Setting ARCH_SLAB_MINALIGN in arch headers allows a different alignment.
>   * Intended for arches that get misalignment faults even for 64 bit integer
> @@ -441,36 +490,6 @@ static inline void *kcalloc(size_t n, si
>  	return kmalloc_array(n, size, flags | __GFP_ZERO);
>  }
>  
> -#if !defined(CONFIG_NUMA) && !defined(CONFIG_SLOB)
> -/**
> - * kmalloc_node - allocate memory from a specific node
> - * @size: how many bytes of memory are required.
> - * @flags: the type of memory to allocate (see kcalloc).
> - * @node: node to allocate from.
> - *
> - * kmalloc() for non-local nodes, used to allocate from a specific node
> - * if available. Equivalent to kmalloc() in the non-NUMA single-node
> - * case.
> - */
> -static inline void *kmalloc_node(size_t size, gfp_t flags, int node)
> -{
> -	return kmalloc(size, flags);
> -}
> -
> -static inline void *__kmalloc_node(size_t size, gfp_t flags, int node)
> -{
> -	return __kmalloc(size, flags);
> -}
> -
> -void *kmem_cache_alloc(struct kmem_cache *, gfp_t);
> -
> -static inline void *kmem_cache_alloc_node(struct kmem_cache *cachep,
> -					gfp_t flags, int node)
> -{
> -	return kmem_cache_alloc(cachep, flags);
> -}
> -#endif /* !CONFIG_NUMA && !CONFIG_SLOB */
> -
>  /*
>   * kmalloc_track_caller is a special version of kmalloc that records the
>   * calling function of the routine calling it for slab leak tracking instead
> Index: linux/include/linux/slub_def.h
> ===================================================================
> --- linux.orig/include/linux/slub_def.h	2013-06-14 13:40:52.424106451 -0500
> +++ linux/include/linux/slub_def.h	2013-06-14 14:45:24.000000000 -0500
> @@ -115,9 +115,6 @@ static inline int kmem_cache_cpu_partial
>  #endif
>  }
>  
> -void *kmem_cache_alloc(struct kmem_cache *, gfp_t);
> -void *__kmalloc(size_t size, gfp_t flags);
> -
>  static __always_inline void *
>  kmalloc_order(size_t size, gfp_t flags, unsigned int order)
>  {
> @@ -185,38 +182,4 @@ static __always_inline void *kmalloc(siz
>  	return __kmalloc(size, flags);
>  }
>  
> -#ifdef CONFIG_NUMA
> -void *__kmalloc_node(size_t size, gfp_t flags, int node);
> -void *kmem_cache_alloc_node(struct kmem_cache *, gfp_t flags, int node);
> -
> -#ifdef CONFIG_TRACING
> -extern void *kmem_cache_alloc_node_trace(struct kmem_cache *s,
> -					   gfp_t gfpflags,
> -					   int node, size_t size);
> -#else
> -static __always_inline void *
> -kmem_cache_alloc_node_trace(struct kmem_cache *s,
> -			      gfp_t gfpflags,
> -			      int node, size_t size)
> -{
> -	return kmem_cache_alloc_node(s, gfpflags, node);
> -}
> -#endif
> -
> -static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
> -{
> -	if (__builtin_constant_p(size) &&
> -		size <= KMALLOC_MAX_CACHE_SIZE && !(flags & GFP_DMA)) {
> -		int index = kmalloc_index(size);
> -
> -		if (!index)
> -			return ZERO_SIZE_PTR;
> -
> -		return kmem_cache_alloc_node_trace(kmalloc_caches[index],
> -			       flags, node, size);
> -	}
> -	return __kmalloc_node(size, flags, node);
> -}
> -#endif
> -
>  #endif /* _LINUX_SLUB_DEF_H */
> Index: linux/include/linux/slab_def.h
> ===================================================================
> --- linux.orig/include/linux/slab_def.h	2013-06-14 13:40:52.424106451 -0500
> +++ linux/include/linux/slab_def.h	2013-06-14 14:45:24.000000000 -0500
> @@ -102,9 +102,6 @@ struct kmem_cache {
>  	 */
>  };
>  
> -void *kmem_cache_alloc(struct kmem_cache *, gfp_t);
> -void *__kmalloc(size_t size, gfp_t flags);
> -
>  #ifdef CONFIG_TRACING
>  extern void *kmem_cache_alloc_trace(struct kmem_cache *, gfp_t, size_t);
>  #else
> @@ -145,53 +142,4 @@ static __always_inline void *kmalloc(siz
>  	return __kmalloc(size, flags);
>  }
>  
> -#ifdef CONFIG_NUMA
> -extern void *__kmalloc_node(size_t size, gfp_t flags, int node);
> -extern void *kmem_cache_alloc_node(struct kmem_cache *, gfp_t flags, int node);
> -
> -#ifdef CONFIG_TRACING
> -extern void *kmem_cache_alloc_node_trace(struct kmem_cache *cachep,
> -					 gfp_t flags,
> -					 int nodeid,
> -					 size_t size);
> -#else
> -static __always_inline void *
> -kmem_cache_alloc_node_trace(struct kmem_cache *cachep,
> -			    gfp_t flags,
> -			    int nodeid,
> -			    size_t size)
> -{
> -	return kmem_cache_alloc_node(cachep, flags, nodeid);
> -}
> -#endif
> -
> -static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
> -{
> -	struct kmem_cache *cachep;
> -
> -	if (__builtin_constant_p(size)) {
> -		int i;
> -
> -		if (!size)
> -			return ZERO_SIZE_PTR;
> -
> -		if (WARN_ON_ONCE(size > KMALLOC_MAX_SIZE))
> -			return NULL;
> -
> -		i = kmalloc_index(size);
> -
> -#ifdef CONFIG_ZONE_DMA
> -		if (flags & GFP_DMA)
> -			cachep = kmalloc_dma_caches[i];
> -		else
> -#endif
> -			cachep = kmalloc_caches[i];
> -
> -		return kmem_cache_alloc_node_trace(cachep, flags, node, size);
> -	}
> -	return __kmalloc_node(size, flags, node);
> -}
> -
> -#endif	/* CONFIG_NUMA */
> -
>  #endif	/* _LINUX_SLAB_DEF_H */
> Index: linux/include/linux/slob_def.h
> ===================================================================
> --- linux.orig/include/linux/slob_def.h	2013-06-14 13:40:52.424106451 -0500
> +++ linux/include/linux/slob_def.h	2013-06-14 14:45:24.000000000 -0500
> @@ -1,24 +1,7 @@
>  #ifndef __LINUX_SLOB_DEF_H
>  #define __LINUX_SLOB_DEF_H
>  
> -#include <linux/numa.h>
> -
> -void *kmem_cache_alloc_node(struct kmem_cache *, gfp_t flags, int node);
> -
> -static __always_inline void *kmem_cache_alloc(struct kmem_cache *cachep,
> -					      gfp_t flags)
> -{
> -	return kmem_cache_alloc_node(cachep, flags, NUMA_NO_NODE);
> -}
> -
> -void *__kmalloc_node(size_t size, gfp_t flags, int node);
> -
> -static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
> -{
> -	return __kmalloc_node(size, flags, node);
> -}
> -
> -/**
> +/*
>   * kmalloc - allocate memory
>   * @size: how many bytes of memory are required.
>   * @flags: the type of memory to allocate (see kcalloc).
> @@ -31,9 +14,4 @@ static __always_inline void *kmalloc(siz
>  	return __kmalloc_node(size, flags, NUMA_NO_NODE);
>  }
>  
> -static __always_inline void *__kmalloc(size_t size, gfp_t flags)
> -{
> -	return kmalloc(size, flags);
> -}
> -
>  #endif /* __LINUX_SLOB_DEF_H */
> Index: linux/mm/slab.c
> ===================================================================
> --- linux.orig/mm/slab.c	2013-06-14 13:40:52.424106451 -0500
> +++ linux/mm/slab.c	2013-06-14 13:40:52.420106378 -0500
> @@ -3681,7 +3681,7 @@ __do_kmalloc_node(size_t size, gfp_t fla
>  	cachep = kmalloc_slab(size, flags);
>  	if (unlikely(ZERO_OR_NULL_PTR(cachep)))
>  		return cachep;
> -	return kmem_cache_alloc_node_trace(cachep, flags, node, size);
> +	return kmem_cache_alloc_node_trace(cachep, flags, node);
>  }
>  
>  #if defined(CONFIG_DEBUG_SLAB) || defined(CONFIG_TRACING)
> Index: linux/mm/slob.c
> ===================================================================
> --- linux.orig/mm/slob.c	2013-06-14 13:14:08.000000000 -0500
> +++ linux/mm/slob.c	2013-06-14 14:44:56.812030812 -0500
> @@ -462,11 +462,11 @@ __do_kmalloc_node(size_t size, gfp_t gfp
>  	return ret;
>  }
>  
> -void *__kmalloc_node(size_t size, gfp_t gfp, int node)
> +void *__kmalloc(size_t size, gfp_t gfp)
>  {
> -	return __do_kmalloc_node(size, gfp, node, _RET_IP_);
> +	return __do_kmalloc_node(size, gfp, NUMA_NO_NODE, _RET_IP_);
>  }
> -EXPORT_SYMBOL(__kmalloc_node);
> +EXPORT_SYMBOL(__kmalloc);
>  
>  #ifdef CONFIG_TRACING
>  void *__kmalloc_track_caller(size_t size, gfp_t gfp, unsigned long caller)
> @@ -534,7 +534,7 @@ int __kmem_cache_create(struct kmem_cach
>  	return 0;
>  }
>  
> -void *kmem_cache_alloc_node(struct kmem_cache *c, gfp_t flags, int node)
> +void *slob_alloc_node(struct kmem_cache *c, gfp_t flags, int node)
>  {
>  	void *b;
>  
> @@ -560,7 +560,27 @@ void *kmem_cache_alloc_node(struct kmem_
>  	kmemleak_alloc_recursive(b, c->size, 1, c->flags, flags);
>  	return b;
>  }
> +EXPORT_SYMBOL(slob_alloc_node);
> +
> +void *kmem_cache_alloc(struct kmem_cache *cachep, gfp_t flags)
> +{
> +	return slob_alloc_node(cachep, flags, NUMA_NO_NODE);
> +}
> +EXPORT_SYMBOL(kmem_cache_alloc);
> +
> +#ifdef CONFIG_NUMA
> +void *__kmalloc_node(size_t size, gfp_t gfp, int node)
> +{
> +	return __do_kmalloc_node(size, gfp, node, _RET_IP_);
> +}
> +EXPORT_SYMBOL(__kmalloc_node);
> +
> +void *kmem_cache_alloc_node(struct kmem_cache *cachep, gfp_t gfp, int node)
> +{
> +	return slob_alloc_node(cachep, gfp, node);
> +}
>  EXPORT_SYMBOL(kmem_cache_alloc_node);
> +#endif
>  
>  static void __kmem_cache_free(void *b, int size)
>  {
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
