Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 7CB0F6B0062
	for <linux-mm@kvack.org>; Mon, 22 Oct 2012 03:57:45 -0400 (EDT)
Message-ID: <5084FC73.1030302@parallels.com>
Date: Mon, 22 Oct 2012 11:57:39 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: CK2 [01/15] slab: Simplify bootstrap
References: <20121019142254.724806786@linux.com> <0000013a796a77f9-b0c5beb7-21e0-4e62-bc08-5b909617f678-000000@email.amazonses.com>
In-Reply-To: <0000013a796a77f9-b0c5beb7-21e0-4e62-bc08-5b909617f678-000000@email.amazonses.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, elezegarcia@gmail.com

On 10/19/2012 06:25 PM, Christoph Lameter wrote:
> The nodelists field in kmem_cache is pointing to the first unused
> object in the array field when bootstrap is complete.
> 
> A problem with the current approach is that the statically sized
> kmem_cache structure use on boot can only contain NR_CPUS entries.
> If the number of nodes plus the number of cpus is greater then we
> would overwrite memory following the kmem_cache_boot definition.
> 
> Increase the size of the array field to ensure that also the node
> pointers fit into the array field.
> 
> Once we do that we no longer need the kmem_cache_nodelists
> array and we can then also use that structure elsewhere.

Fair.

One comment:

>  /*
> + * The memory after the last cpu cache pointer is used for the
> + * the nodelists pointer.
> + */
> +static void setup_nodelists_pointer(struct kmem_cache *s)
> +{
> +	s->nodelists = (struct kmem_list3 **)&s->array[nr_cpu_ids];
> +}
> +
> +/*
>   * Initialisation.  Called after the page allocator have been initialised and
>   * before smp_init().
>   */
> @@ -1590,13 +1597,15 @@ void __init kmem_cache_init(void)
>  	int node;
>  
>  	kmem_cache = &kmem_cache_boot;
> +	setup_nodelists_pointer(kmem_cache);
>  
>  	if (num_possible_nodes() == 1)
>  		use_alien_caches = 0;
>  
> +
>  	for (i = 0; i < NUM_INIT_LISTS; i++) {
>  		kmem_list3_init(&initkmem_list3[i]);
> -		if (i < MAX_NUMNODES)
> +		if (i < nr_node_ids)
>  			kmem_cache->nodelists[i] = NULL;
>  	}

With nodelists being part of kmem_cache, and kmem_cache being allocated
with kmem_cache_zalloc, it seems to me that you can actually just get
rid of the inner loop instead of patching it. But this is orthogonal to
this patch...

So:

Acked-by: Glauber Costa <glommer@parallels.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
