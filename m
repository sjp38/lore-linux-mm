Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 26C756B0069
	for <linux-mm@kvack.org>; Mon, 22 Oct 2012 04:09:51 -0400 (EDT)
Message-ID: <5084FF48.9040001@parallels.com>
Date: Mon, 22 Oct 2012 12:09:44 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: CK2 [04/15] slab: Use the new create_boot_cache function to simplify
 bootstrap
References: <20121019142254.724806786@linux.com> <0000013a7979e9c4-0f9a8d4b-34b4-45dd-baff-a4ccac7a51a6-000000@email.amazonses.com>
In-Reply-To: <0000013a7979e9c4-0f9a8d4b-34b4-45dd-baff-a4ccac7a51a6-000000@email.amazonses.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, elezegarcia@gmail.com

On 10/19/2012 06:42 PM, Christoph Lameter wrote:
> Simplify setup and reduce code in kmem_cache_init(). This allows us to
> get rid of initarray_cache as well as the manual setup code for
> the kmem_cache and kmem_cache_node arrays during bootstrap.
> 
> We introduce a new bootstrap state "PARTIAL" for slab that signals the
> creation of a kmem_cache boot cache.
> 
> V1->V2: Get rid of initarray_cache as well.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>
> ---
>  mm/slab.c |   51 ++++++++++++++++++---------------------------------
>  1 file changed, 18 insertions(+), 33 deletions(-)
> 
> Index: linux/mm/slab.c
> ===================================================================
> --- linux.orig/mm/slab.c	2012-10-19 09:12:44.158404719 -0500
> +++ linux/mm/slab.c	2012-10-19 09:12:49.046488276 -0500
> @@ -564,8 +564,6 @@ static struct cache_names __initdata cac
>  #undef CACHE
>  };
>  
> -static struct arraycache_init initarray_cache __initdata =
> -    { {0, BOOT_CPUCACHE_ENTRIES, 1, 0} };
>  static struct arraycache_init initarray_generic =
>      { {0, BOOT_CPUCACHE_ENTRIES, 1, 0} };
>  
> @@ -1589,12 +1587,9 @@ static void setup_nodelists_pointer(stru
>   */
>  void __init kmem_cache_init(void)
>  {
> -	size_t left_over;
>  	struct cache_sizes *sizes;
>  	struct cache_names *names;
>  	int i;
> -	int order;
> -	int node;
>  
>  	kmem_cache = &kmem_cache_boot;
>  	setup_nodelists_pointer(kmem_cache);
> @@ -1638,36 +1633,17 @@ void __init kmem_cache_init(void)
>  	 * 6) Resize the head arrays of the kmalloc caches to their final sizes.
>  	 */
>  
> -	node = numa_mem_id();
> -
>  	/* 1) create the kmem_cache */
> -	INIT_LIST_HEAD(&slab_caches);
> -	list_add(&kmem_cache->list, &slab_caches);
> -	kmem_cache->colour_off = cache_line_size();
> -	kmem_cache->array[smp_processor_id()] = &initarray_cache.cache;
>  
>  	/*
>  	 * struct kmem_cache size depends on nr_node_ids & nr_cpu_ids
>  	 */
> -	kmem_cache->size = offsetof(struct kmem_cache, array[nr_cpu_ids]) +
> -				  nr_node_ids * sizeof(struct kmem_list3 *);
> -	kmem_cache->object_size = kmem_cache->size;
> -	kmem_cache->size = ALIGN(kmem_cache->object_size,
> -					cache_line_size());
> -	kmem_cache->reciprocal_buffer_size =
> -		reciprocal_value(kmem_cache->size);
> -
> -	for (order = 0; order < MAX_ORDER; order++) {
> -		cache_estimate(order, kmem_cache->size,
> -			cache_line_size(), 0, &left_over, &kmem_cache->num);
> -		if (kmem_cache->num)
> -			break;
> -	}
> -	BUG_ON(!kmem_cache->num);
> -	kmem_cache->gfporder = order;
> -	kmem_cache->colour = left_over / kmem_cache->colour_off;
> -	kmem_cache->slab_size = ALIGN(kmem_cache->num * sizeof(kmem_bufctl_t) +
> -				      sizeof(struct slab), cache_line_size());
> +	create_boot_cache(kmem_cache, "kmem_cache",
> +		offsetof(struct kmem_cache, array[nr_cpu_ids]) +
> +				  nr_node_ids * sizeof(struct kmem_list3 *),
> +				  SLAB_HWCACHE_ALIGN);
> +
> +	slab_state = PARTIAL;
>  

With this, plus the statement in setup_cpu_cache, it is possible that we
set the state to PARTIAL from two different locations. Although it
wouldn't be the first instance of it, I can't say I am a big fan.

Is there any reason why you need to initialize the state to PARTIAL from
two different locations?

I would just just get rid of the second and keep this one, which is
called early enough and unconditionally.

> +	} else
> +	if (slab_state == PARTIAL) {
> +		/*

} else if ...


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
