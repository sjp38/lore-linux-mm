Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f170.google.com (mail-ie0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id 3FB6F6B0187
	for <linux-mm@kvack.org>; Wed, 11 Jun 2014 19:12:59 -0400 (EDT)
Received: by mail-ie0-f170.google.com with SMTP id tr6so449009ieb.1
        for <linux-mm@kvack.org>; Wed, 11 Jun 2014 16:12:59 -0700 (PDT)
Received: from mail-ie0-x231.google.com (mail-ie0-x231.google.com [2607:f8b0:4001:c03::231])
        by mx.google.com with ESMTPS id g3si25056445igi.15.2014.06.11.16.12.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 11 Jun 2014 16:12:58 -0700 (PDT)
Received: by mail-ie0-f177.google.com with SMTP id tp5so435648ieb.36
        for <linux-mm@kvack.org>; Wed, 11 Jun 2014 16:12:56 -0700 (PDT)
Date: Wed, 11 Jun 2014 16:12:54 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/3] slub: Use new node functions
In-Reply-To: <20140611191519.070677452@linux.com>
Message-ID: <alpine.DEB.2.02.1406111610130.27885@chino.kir.corp.google.com>
References: <20140611191510.082006044@linux.com> <20140611191519.070677452@linux.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On Wed, 11 Jun 2014, Christoph Lameter wrote:

> Index: linux/mm/slub.c
> ===================================================================
> --- linux.orig/mm/slub.c	2014-06-10 13:49:22.154458193 -0500
> +++ linux/mm/slub.c	2014-06-10 13:51:03.959192299 -0500
> @@ -2157,6 +2157,7 @@ slab_out_of_memory(struct kmem_cache *s,
>  	static DEFINE_RATELIMIT_STATE(slub_oom_rs, DEFAULT_RATELIMIT_INTERVAL,
>  				      DEFAULT_RATELIMIT_BURST);
>  	int node;
> +	struct kmem_cache_node *n;
>  
>  	if ((gfpflags & __GFP_NOWARN) || !__ratelimit(&slub_oom_rs))
>  		return;
> @@ -2171,15 +2172,11 @@ slab_out_of_memory(struct kmem_cache *s,
>  		pr_warn("  %s debugging increased min order, use slub_debug=O to disable.\n",
>  			s->name);
>  
> -	for_each_online_node(node) {
> -		struct kmem_cache_node *n = get_node(s, node);
> +	for_each_kmem_cache_node(s, node, n) {
>  		unsigned long nr_slabs;
>  		unsigned long nr_objs;
>  		unsigned long nr_free;
>  
> -		if (!n)
> -			continue;
> -
>  		nr_free  = count_partial(n, count_free);
>  		nr_slabs = node_nr_slabs(n);
>  		nr_objs  = node_nr_objs(n);
> @@ -2923,13 +2920,10 @@ static void early_kmem_cache_node_alloc(
>  static void free_kmem_cache_nodes(struct kmem_cache *s)
>  {
>  	int node;
> +	struct kmem_cache_node *n;
>  
> -	for_each_node_state(node, N_NORMAL_MEMORY) {
> -		struct kmem_cache_node *n = s->node[node];
> -
> -		if (n)
> -			kmem_cache_free(kmem_cache_node, n);
> -
> +	for_each_kmem_cache_node(s, node, n) {
> +		kmem_cache_free(kmem_cache_node, n);
>  		s->node[node] = NULL;
>  	}
>  }
> @@ -3217,11 +3211,11 @@ static void free_partial(struct kmem_cac
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

Newline not removed?

> @@ -3407,11 +3401,7 @@ int __kmem_cache_shrink(struct kmem_cach
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

Is there any reason not to keep the !n->nr_partial check to avoid taking 
n->list_lock unnecessarily?

> @@ -3581,6 +3571,7 @@ static struct kmem_cache * __init bootst
>  {
>  	int node;
>  	struct kmem_cache *s = kmem_cache_zalloc(kmem_cache, GFP_NOWAIT);
> +	struct kmem_cache_node *n;
>  
>  	memcpy(s, static_cache, kmem_cache->object_size);
>  
> @@ -3590,19 +3581,16 @@ static struct kmem_cache * __init bootst
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
> @@ -3955,16 +3943,14 @@ static long validate_slab_cache(struct k
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
> @@ -4118,6 +4104,7 @@ static int list_locations(struct kmem_ca
>  	int node;
>  	unsigned long *map = kmalloc(BITS_TO_LONGS(oo_objects(s->max)) *
>  				     sizeof(unsigned long), GFP_KERNEL);
> +	struct kmem_cache_node *n;
>  
>  	if (!map || !alloc_loc_track(&t, PAGE_SIZE / sizeof(struct location),
>  				     GFP_TEMPORARY)) {
> @@ -4127,8 +4114,7 @@ static int list_locations(struct kmem_ca
>  	/* Push back cpu slabs */
>  	flush_all(s);
>  
> -	for_each_node_state(node, N_NORMAL_MEMORY) {
> -		struct kmem_cache_node *n = get_node(s, node);
> +	for_each_kmem_cache_node(s, node, n) {
>  		unsigned long flags;
>  		struct page *page;
>  
> @@ -4327,8 +4313,9 @@ static ssize_t show_slab_objects(struct
>  	get_online_mems();
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

Another unnecessary newline?

> @@ -4344,8 +4331,9 @@ static ssize_t show_slab_objects(struct
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

Ditto.

> @@ -4359,7 +4347,7 @@ static ssize_t show_slab_objects(struct
>  	}
>  	x = sprintf(buf, "%lu", total);
>  #ifdef CONFIG_NUMA
> -	for_each_node_state(node, N_NORMAL_MEMORY)
> +	for(node = 0; node < nr_node_ids; node++)
>  		if (nodes[node])
>  			x += sprintf(buf + x, " N%d=%lu",
>  					node, nodes[node]);
> @@ -4373,16 +4361,12 @@ static ssize_t show_slab_objects(struct
>  static int any_slab_objects(struct kmem_cache *s)
>  {
>  	int node;
> +	struct kmem_cache_node *n;
>  
> -	for_each_online_node(node) {
> -		struct kmem_cache_node *n = get_node(s, node);
> -
> -		if (!n)
> -			continue;
> -
> +	for_each_kmem_cache_node(s, node, n)
>  		if (atomic_long_read(&n->total_objects))
>  			return 1;
> -	}
> +
>  	return 0;
>  }
>  #endif
> @@ -5337,12 +5321,9 @@ void get_slabinfo(struct kmem_cache *s,
>  	unsigned long nr_objs = 0;
>  	unsigned long nr_free = 0;
>  	int node;
> +	struct kmem_cache_node *n;
>  
> -	for_each_online_node(node) {
> -		struct kmem_cache_node *n = get_node(s, node);
> -
> -		if (!n)
> -			continue;
> +	for_each_kmem_cache_node(s, node, n) {
>  
>  		nr_slabs += node_nr_slabs(n);
>  		nr_objs += node_nr_objs(n);
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
