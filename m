Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 84C646B01F1
	for <linux-mm@kvack.org>; Tue, 17 Aug 2010 19:59:43 -0400 (EDT)
Received: from kpbe19.cbf.corp.google.com (kpbe19.cbf.corp.google.com [172.25.105.83])
	by smtp-out.google.com with ESMTP id o7HNxeTm016836
	for <linux-mm@kvack.org>; Tue, 17 Aug 2010 16:59:40 -0700
Received: from pwi3 (pwi3.prod.google.com [10.241.219.3])
	by kpbe19.cbf.corp.google.com with ESMTP id o7HNwrLo022590
	for <linux-mm@kvack.org>; Tue, 17 Aug 2010 16:58:59 -0700
Received: by pwi3 with SMTP id 3so61045pwi.14
        for <linux-mm@kvack.org>; Tue, 17 Aug 2010 16:58:53 -0700 (PDT)
Date: Tue, 17 Aug 2010 16:58:49 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [S+Q Cleanup 3/6] slub: Remove static kmem_cache_cpu array for
 boot
In-Reply-To: <20100817211136.091336874@linux.com>
Message-ID: <alpine.DEB.2.00.1008171638160.31928@chino.kir.corp.google.com>
References: <20100817211118.958108012@linux.com> <20100817211136.091336874@linux.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 17 Aug 2010, Christoph Lameter wrote:

> Index: linux-2.6/mm/slub.c
> ===================================================================
> --- linux-2.6.orig/mm/slub.c	2010-08-13 10:32:45.000000000 -0500
> +++ linux-2.6/mm/slub.c	2010-08-13 10:32:50.000000000 -0500
> @@ -2062,23 +2062,14 @@ init_kmem_cache_node(struct kmem_cache_n
>  #endif
>  }
>  
> -static DEFINE_PER_CPU(struct kmem_cache_cpu, kmalloc_percpu[KMALLOC_CACHES]);
> -
>  static inline int alloc_kmem_cache_cpus(struct kmem_cache *s)
>  {
> -	if (s < kmalloc_caches + KMALLOC_CACHES && s >= kmalloc_caches)
> -		/*
> -		 * Boot time creation of the kmalloc array. Use static per cpu data
> -		 * since the per cpu allocator is not available yet.
> -		 */
> -		s->cpu_slab = kmalloc_percpu + (s - kmalloc_caches);
> -	else
> -		s->cpu_slab =  alloc_percpu(struct kmem_cache_cpu);
> +	BUILD_BUG_ON(PERCPU_DYNAMIC_EARLY_SIZE <
> +			SLUB_PAGE_SHIFT * sizeof(struct kmem_cache));

This fails with CONFIG_NODES_SHIFT=10 on x86_64, which means it will fail 
the ia64 defconfig as well.  struct kmem_cache stores nodemask pointers up 
to MAX_NUMNODES, which makes the conditional fail.

struct kmem_cache is 8376 bytes with that config (and CONFIG_SLUB_DEBUG), 
so it looks like PERCPU_DYNAMIC_EARLY_SIZE will need to be at least 117264 
for this not to fail (four orders larger than it currently is, or
12 << 14).  Tejun?

>  
> -	if (!s->cpu_slab)
> -		return 0;
> +	s->cpu_slab = alloc_percpu(struct kmem_cache_cpu);
>  
> -	return 1;
> +	return s->cpu_slab != NULL;
>  }
>  
>  #ifdef CONFIG_NUMA
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
