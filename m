Message-ID: <48E63E76.1010702@cosmosbay.com>
Date: Fri, 03 Oct 2008 17:47:02 +0200
From: Eric Dumazet <dada1@cosmosbay.com>
MIME-Version: 1.0
Subject: Re: [patch 2/3] cpu alloc: Use in slub
References: <20081003152436.089811999@quilx.com> <20081003152500.102106878@quilx.com>
In-Reply-To: <20081003152500.102106878@quilx.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, ebiederm@xmission.com, travis@sgi.com, herbert@gondor.apana.org.au, xemul@openvz.org, penberg@cs.helsinki.fi
List-ID: <linux-mm.kvack.org>

Christoph Lameter a ecrit :
> Using cpu alloc removes the needs for the per cpu arrays in the kmem_cache struct.
> These could get quite big if we have to support system of up to thousands of cpus.
> The use of cpu_alloc means that:
> 
> 1. The size of kmem_cache for SMP configuration shrinks since we will only
>    need 1 pointer instead of NR_CPUS. The same pointer can be used by all
>    processors. Reduces cache footprint of the allocator.
> 
> 2. We can dynamically size kmem_cache according to the actual nodes in the
>    system meaning less memory overhead for configurations that may potentially
>    support up to 1k NUMA nodes / 4k cpus.
> 
> 3. We can remove the diddle widdle with allocating and releasing of
>    kmem_cache_cpu structures when bringing up and shutting down cpus. The cpu
>    alloc logic will do it all for us. Removes some portions of the cpu hotplug
>    functionality.
> 
> 4. Fastpath performance increases.
> 
> Signed-off-by: Christoph Lameter <cl@linux-foundation.org>
> 
> Index: linux-2.6/include/linux/slub_def.h
> ===================================================================
> --- linux-2.6.orig/include/linux/slub_def.h	2008-10-03 09:05:11.000000000 -0500
> +++ linux-2.6/include/linux/slub_def.h	2008-10-03 10:17:32.000000000 -0500
> @@ -68,6 +68,7 @@
>   * Slab cache management.
>   */
>  struct kmem_cache {
> +	struct kmem_cache_cpu *cpu_slab;
>  	/* Used for retriving partial slabs etc */
>  	unsigned long flags;
>  	int size;		/* The size of an object including meta data */
> @@ -102,11 +103,6 @@
>  	int remote_node_defrag_ratio;
>  	struct kmem_cache_node *node[MAX_NUMNODES];

Then maybe change MAX_NUMNODES to 0 or 1 to reflect
node[] is dynamically sized ?


>  #endif
> -#ifdef CONFIG_SMP
> -	struct kmem_cache_cpu *cpu_slab[NR_CPUS];
> -#else
> -	struct kmem_cache_cpu cpu_slab;
> -#endif
>  };



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
