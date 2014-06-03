Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id B328A6B0039
	for <linux-mm@kvack.org>; Tue,  3 Jun 2014 02:54:33 -0400 (EDT)
Received: by mail-pb0-f50.google.com with SMTP id ma3so5145985pbc.9
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 23:54:33 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id wh5si18925731pbc.30.2014.06.02.23.54.31
        for <linux-mm@kvack.org>;
        Mon, 02 Jun 2014 23:54:32 -0700 (PDT)
Date: Tue, 3 Jun 2014 15:57:56 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 2/4] slub: Use new node functions
Message-ID: <20140603065756.GA31135@js1304-P5Q-DELUXE>
References: <20140530182753.191965442@linux.com>
 <20140530182801.436674724@linux.com>
 <20140602045933.GC17964@js1304-P5Q-DELUXE>
 <alpine.DEB.2.10.1406021025240.2987@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1406021025240.2987@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: Pekka Enberg <penberg@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>

On Mon, Jun 02, 2014 at 10:42:35AM -0500, Christoph Lameter wrote:
> On Mon, 2 Jun 2014, Joonsoo Kim wrote:
> 
> > I think that we can use for_each_kmem_cache_node() instead of
> > using for_each_node_state(node, N_NORMAL_MEMORY). Just one
> > exception is init_kmem_cache_nodes() which is responsible
> > for setting kmem_cache_node correctly.
> 
> Yup.
> 
> > Is there any reason not to use it for for_each_node_state()?
> 
> There are two cases in which is doesnt work. free_kmem_cache_nodes() and
> init_kmem_cache_nodes() as you noted before. And there is a case in the
> statistics subsystem that needs to be handled a bit differently.

Hello,

I think that We can also replace for_each_node_state() in
free_kmem_cache_nodes(). What prevent it from being replaced?

> 
> Here is a patch doing the additional modifications:
> 

Seems good to me.

Thanks.

> 
> 
> 
> Subject: slub: Replace for_each_node_state with for_each_kmem_cache_node
> 
> More uses for the new function.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>
> 
> Index: linux/mm/slub.c
> ===================================================================
> --- linux.orig/mm/slub.c	2014-05-30 13:23:24.863105538 -0500
> +++ linux/mm/slub.c	2014-06-02 10:39:50.218883865 -0500
> @@ -3210,11 +3210,11 @@ static void free_partial(struct kmem_cac
>  static inline int kmem_cache_close(struct kmem_cache *s)
>  {
>  	int node;
> +	struct kmem_cache_node *n;
> 
>  	flush_all(s);
>  	/* Attempt to free all objects */
> -	for_each_node_state(node, N_NORMAL_MEMORY) {
> -		struct kmem_cache_node *n = get_node(s, node);
> +	for_each_kmem_cache_node(s, node, n) {
> 
>  		free_partial(s, n);
>  		if (n->nr_partial || slabs_node(s, node))
> @@ -3400,11 +3400,7 @@ int kmem_cache_shrink(struct kmem_cache
>  		return -ENOMEM;
> 
>  	flush_all(s);
> -	for_each_node_state(node, N_NORMAL_MEMORY) {
> -		n = get_node(s, node);
> -
> -		if (!n->nr_partial)
> -			continue;
> +	for_each_kmem_cache_node(s, node, n) {
> 
>  		for (i = 0; i < objects; i++)
>  			INIT_LIST_HEAD(slabs_by_inuse + i);
> @@ -3575,6 +3571,7 @@ static struct kmem_cache * __init bootst
>  {
>  	int node;
>  	struct kmem_cache *s = kmem_cache_zalloc(kmem_cache, GFP_NOWAIT);
> +	struct kmem_cache_node *n;
> 
>  	memcpy(s, static_cache, kmem_cache->object_size);
> 
> @@ -3584,19 +3581,16 @@ static struct kmem_cache * __init bootst
>  	 * IPIs around.
>  	 */
>  	__flush_cpu_slab(s, smp_processor_id());
> -	for_each_node_state(node, N_NORMAL_MEMORY) {
> -		struct kmem_cache_node *n = get_node(s, node);
> +	for_each_kmem_cache_node(s, node, n) {
>  		struct page *p;
> 
> -		if (n) {
> -			list_for_each_entry(p, &n->partial, lru)
> -				p->slab_cache = s;
> +		list_for_each_entry(p, &n->partial, lru)
> +			p->slab_cache = s;
> 
>  #ifdef CONFIG_SLUB_DEBUG
> -			list_for_each_entry(p, &n->full, lru)
> -				p->slab_cache = s;
> +		list_for_each_entry(p, &n->full, lru)
> +			p->slab_cache = s;
>  #endif
> -		}
>  	}
>  	list_add(&s->list, &slab_caches);
>  	return s;
> @@ -3952,16 +3946,14 @@ static long validate_slab_cache(struct k
>  	unsigned long count = 0;
>  	unsigned long *map = kmalloc(BITS_TO_LONGS(oo_objects(s->max)) *
>  				sizeof(unsigned long), GFP_KERNEL);
> +	struct kmem_cache_node *n;
> 
>  	if (!map)
>  		return -ENOMEM;
> 
>  	flush_all(s);
> -	for_each_node_state(node, N_NORMAL_MEMORY) {
> -		struct kmem_cache_node *n = get_node(s, node);
> -
> +	for_each_kmem_cache_node(s, node, n)
>  		count += validate_slab_node(s, n, map);
> -	}
>  	kfree(map);
>  	return count;
>  }
> @@ -4115,6 +4107,7 @@ static int list_locations(struct kmem_ca
>  	int node;
>  	unsigned long *map = kmalloc(BITS_TO_LONGS(oo_objects(s->max)) *
>  				     sizeof(unsigned long), GFP_KERNEL);
> +	struct kmem_cache_node *n;
> 
>  	if (!map || !alloc_loc_track(&t, PAGE_SIZE / sizeof(struct location),
>  				     GFP_TEMPORARY)) {
> @@ -4124,8 +4117,7 @@ static int list_locations(struct kmem_ca
>  	/* Push back cpu slabs */
>  	flush_all(s);
> 
> -	for_each_node_state(node, N_NORMAL_MEMORY) {
> -		struct kmem_cache_node *n = get_node(s, node);
> +	for_each_kmem_cache_node(s, node, n) {
>  		unsigned long flags;
>  		struct page *page;
> 
> @@ -4327,8 +4319,9 @@ static ssize_t show_slab_objects(struct
>  	lock_memory_hotplug();
>  #ifdef CONFIG_SLUB_DEBUG
>  	if (flags & SO_ALL) {
> -		for_each_node_state(node, N_NORMAL_MEMORY) {
> -			struct kmem_cache_node *n = get_node(s, node);
> +		struct kmem_cache_node *n;
> +
> +		for_each_kmem_cache_node(s, node, n) {
> 
>  			if (flags & SO_TOTAL)
>  				x = atomic_long_read(&n->total_objects);
> @@ -4344,8 +4337,9 @@ static ssize_t show_slab_objects(struct
>  	} else
>  #endif
>  	if (flags & SO_PARTIAL) {
> -		for_each_node_state(node, N_NORMAL_MEMORY) {
> -			struct kmem_cache_node *n = get_node(s, node);
> +		struct kmem_cache_node *n;
> +
> +		for_each_kmem_cache_node(s, node, n) {
> 
>  			if (flags & SO_TOTAL)
>  				x = count_partial(n, count_total);
> @@ -4359,7 +4353,7 @@ static ssize_t show_slab_objects(struct
>  	}
>  	x = sprintf(buf, "%lu", total);
>  #ifdef CONFIG_NUMA
> -	for_each_node_state(node, N_NORMAL_MEMORY)
> +	for(node = 0; node < nr_node_ids; node++)
>  		if (nodes[node])
>  			x += sprintf(buf + x, " N%d=%lu",
>  					node, nodes[node]);
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
