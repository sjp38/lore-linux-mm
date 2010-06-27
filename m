Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 817AC6B01AD
	for <linux-mm@kvack.org>; Sat, 26 Jun 2010 20:02:55 -0400 (EDT)
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [172.25.149.3])
	by smtp-out.google.com with ESMTP id o5R02p4N021665
	for <linux-mm@kvack.org>; Sat, 26 Jun 2010 17:02:51 -0700
Received: from pxi5 (pxi5.prod.google.com [10.243.27.5])
	by hpaq3.eem.corp.google.com with ESMTP id o5R02nkM023287
	for <linux-mm@kvack.org>; Sat, 26 Jun 2010 17:02:50 -0700
Received: by pxi5 with SMTP id 5so478061pxi.11
        for <linux-mm@kvack.org>; Sat, 26 Jun 2010 17:02:49 -0700 (PDT)
Date: Sat, 26 Jun 2010 17:02:47 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [S+Q 10/16] slub: Remove static kmem_cache_cpu array for boot
In-Reply-To: <20100625212106.973996317@quilx.com>
Message-ID: <alpine.DEB.2.00.1006261657290.27174@chino.kir.corp.google.com>
References: <20100625212026.810557229@quilx.com> <20100625212106.973996317@quilx.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Nick Piggin <npiggin@suse.de>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

On Fri, 25 Jun 2010, Christoph Lameter wrote:

> The percpu allocator can now handle allocations in early boot.
> So drop the static kmem_cache_cpu array.
> 
> Early memory allocations require the use of GFP_NOWAIT instead of
> GFP_KERNEL. Mask GFP_KERNEL with gfp_allowed_mask to get to GFP_NOWAIT
> in a boot scenario.
> 
> Cc: Tejun Heo <tj@kernel.org>
> Signed-off-by: Christoph Lameter <cl@linux-foundation.org>
> 
> ---
>  mm/slub.c |   21 ++++++---------------
>  1 file changed, 6 insertions(+), 15 deletions(-)
> 
> Index: linux-2.6.34/mm/slub.c
> ===================================================================
> --- linux-2.6.34.orig/mm/slub.c	2010-06-22 09:50:00.000000000 -0500
> +++ linux-2.6.34/mm/slub.c	2010-06-23 09:59:53.000000000 -0500
> @@ -2068,23 +2068,14 @@ init_kmem_cache_node(struct kmem_cache_n
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
> @@ -2105,7 +2096,7 @@ static void early_kmem_cache_node_alloc(
>  
>  	BUG_ON(kmalloc_caches->size < sizeof(struct kmem_cache_node));
>  
> -	page = new_slab(kmalloc_caches, GFP_KERNEL, node);
> +	page = new_slab(kmalloc_caches, GFP_KERNEL & gfp_allowed_mask, node);
>  
>  	BUG_ON(!page);
>  	if (page_to_nid(page) != node) {

This needs to be merged into the preceding patch since it had broken new 
slab allocations during early boot while irqs are still disabled; it also 
seems deserving of a big fat comment about why it's required in this 
situation.

> @@ -2161,7 +2152,7 @@ static int init_kmem_cache_nodes(struct 
>  			continue;
>  		}
>  		n = kmem_cache_alloc_node(kmalloc_caches,
> -						GFP_KERNEL, node);
> +			GFP_KERNEL & gfp_allowed_mask, node);
>  
>  		if (!n) {
>  			free_kmem_cache_nodes(s);

Likewise.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
