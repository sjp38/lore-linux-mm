Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id DB0546B01C7
	for <linux-mm@kvack.org>; Wed,  9 Jun 2010 02:14:58 -0400 (EDT)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id o596ElXA003703
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 23:14:47 -0700
Received: from pxi1 (pxi1.prod.google.com [10.243.27.1])
	by wpaz24.hot.corp.google.com with ESMTP id o596EjAw008568
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 23:14:46 -0700
Received: by pxi1 with SMTP id 1so2582655pxi.8
        for <linux-mm@kvack.org>; Tue, 08 Jun 2010 23:14:45 -0700 (PDT)
Date: Tue, 8 Jun 2010 23:14:40 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC V2 SLEB 06/14] SLUB: Get rid of the kmalloc_node slab
In-Reply-To: <20100521211540.439539135@quilx.com>
Message-ID: <alpine.DEB.2.00.1006082311130.28827@chino.kir.corp.google.com>
References: <20100521211452.659982351@quilx.com> <20100521211540.439539135@quilx.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 21 May 2010, Christoph Lameter wrote:

> Currently bootstrap works with the kmalloc_node slab.

s/kmalloc_node/kmem_cache_node/

> We can avoid
> creating that slab and boot using allocation from a kmalloc array slab
> instead. This is necessary for the future if we want to dynamically
> size kmem_cache structures.
> 
> Signed-off-by: Christoph Lameter <cl@linux-foundation.org>
> 
> ---
>  mm/slub.c |   39 ++++++++++++++++++++++++---------------
>  1 file changed, 24 insertions(+), 15 deletions(-)
> 
> Index: linux-2.6/mm/slub.c
> ===================================================================
> --- linux-2.6.orig/mm/slub.c	2010-05-20 14:26:53.000000000 -0500
> +++ linux-2.6/mm/slub.c	2010-05-20 14:37:19.000000000 -0500
> @@ -2111,10 +2111,11 @@ static void early_kmem_cache_node_alloc(
>  	struct page *page;
>  	struct kmem_cache_node *n;
>  	unsigned long flags;
> +	int i = kmalloc_index(sizeof(struct kmem_cache_node));
>  

const int?


Maybe even better would be

	struct kmem_cache *s = kmalloc_caches + i;

to make the rest of this easier?

> -	BUG_ON(kmalloc_caches->size < sizeof(struct kmem_cache_node));
> +	BUG_ON(kmalloc_caches[i].size < sizeof(struct kmem_cache_node));
>  
> -	page = new_slab(kmalloc_caches, gfpflags, node);
> +	page = new_slab(kmalloc_caches + i, gfpflags, node);
>  
>  	BUG_ON(!page);
>  	if (page_to_nid(page) != node) {
> @@ -2126,15 +2127,15 @@ static void early_kmem_cache_node_alloc(
>  
>  	n = page->freelist;
>  	BUG_ON(!n);

I don't think we need this BUG_ON() anymore, but that's a seperate issue.

> -	page->freelist = get_freepointer(kmalloc_caches, n);
> +	page->freelist = get_freepointer(kmalloc_caches + i, n);
>  	page->inuse++;
> -	kmalloc_caches->node[node] = n;
> +	kmalloc_caches[i].node[node] = n;
>  #ifdef CONFIG_SLUB_DEBUG
> -	init_object(kmalloc_caches, n, 1);
> -	init_tracking(kmalloc_caches, n);
> +	init_object(kmalloc_caches + i, n, 1);
> +	init_tracking(kmalloc_caches + i, n);
>  #endif
> -	init_kmem_cache_node(n, kmalloc_caches);
> -	inc_slabs_node(kmalloc_caches, node, page->objects);
> +	init_kmem_cache_node(n, kmalloc_caches + i);
> +	inc_slabs_node(kmalloc_caches + i, node, page->objects);
>  
>  	/*
>  	 * lockdep requires consistent irq usage for each lock
> @@ -2152,8 +2153,9 @@ static void free_kmem_cache_nodes(struct
>  
>  	for_each_node_state(node, N_NORMAL_MEMORY) {
>  		struct kmem_cache_node *n = s->node[node];
> +
>  		if (n && n != &s->local_node)
> -			kmem_cache_free(kmalloc_caches, n);
> +			kfree(n);
>  		s->node[node] = NULL;
>  	}
>  }
> @@ -2178,8 +2180,8 @@ static int init_kmem_cache_nodes(struct 
>  				early_kmem_cache_node_alloc(gfpflags, node);
>  				continue;
>  			}
> -			n = kmem_cache_alloc_node(kmalloc_caches,
> -							gfpflags, node);
> +			n = kmalloc_node(sizeof(struct kmem_cache_node), gfpflags,
> +				node);
>  
>  			if (!n) {
>  				free_kmem_cache_nodes(s);
> @@ -2574,6 +2576,12 @@ static struct kmem_cache *create_kmalloc
>  {
>  	unsigned int flags = 0;
>  
> +	if (s->size) {
> +		s->name = name;

Do we need this?  The iteration at the end of kmem_cache_init() should 
reset this kmalloc cache to have the standard kmalloc-<size> name, so I 
don't think we need to reset "bootstrap" here.

> +		/* Already created */
> +		return s;
> +	}
> +
>  	if (gfp_flags & SLUB_DMA)
>  		flags = SLAB_CACHE_DMA;
>  
> @@ -2978,7 +2986,7 @@ static void slab_mem_offline_callback(vo
>  			BUG_ON(slabs_node(s, offline_node));
>  
>  			s->node[offline_node] = NULL;
> -			kmem_cache_free(kmalloc_caches, n);
> +			kfree(n);
>  		}
>  	}
>  	up_read(&slub_lock);
> @@ -3011,7 +3019,7 @@ static int slab_mem_going_online_callbac
>  		 *      since memory is not yet available from the node that
>  		 *      is brought up.
>  		 */
> -		n = kmem_cache_alloc(kmalloc_caches, GFP_KERNEL);
> +		n = kmalloc(sizeof(struct kmem_cache_node), GFP_KERNEL);
>  		if (!n) {
>  			ret = -ENOMEM;
>  			goto out;
> @@ -3068,9 +3076,10 @@ void __init kmem_cache_init(void)
>  	 * struct kmem_cache_node's. There is special bootstrap code in
>  	 * kmem_cache_open for slab_state == DOWN.
>  	 */
> -	create_kmalloc_cache(&kmalloc_caches[0], "kmem_cache_node",
> +	i = kmalloc_index(sizeof(struct kmem_cache_node));
> +	create_kmalloc_cache(&kmalloc_caches[i], "bootstrap",
>  		sizeof(struct kmem_cache_node), GFP_NOWAIT);
> -	kmalloc_caches[0].refcount = -1;
> +	kmalloc_caches[i].refcount = -1;
>  	caches++;
>  
>  	hotplug_memory_notifier(slab_memory_callback, SLAB_CALLBACK_PRI);

So kmalloc_caches[0] will never be used after this change, then?


We could also remove the gfp_t argument to create_kmalloc_cache(), it's 
not used for anything other than GFP_NOWAIT anymore.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
