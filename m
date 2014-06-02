Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id EC85C6B0031
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 00:56:14 -0400 (EDT)
Received: by mail-pb0-f51.google.com with SMTP id ma3so3790951pbc.24
        for <linux-mm@kvack.org>; Sun, 01 Jun 2014 21:56:14 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id g1si14475864pbw.91.2014.06.01.21.56.13
        for <linux-mm@kvack.org>;
        Sun, 01 Jun 2014 21:56:14 -0700 (PDT)
Date: Mon, 2 Jun 2014 13:59:34 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 2/4] slub: Use new node functions
Message-ID: <20140602045933.GC17964@js1304-P5Q-DELUXE>
References: <20140530182753.191965442@linux.com>
 <20140530182801.436674724@linux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140530182801.436674724@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>

On Fri, May 30, 2014 at 01:27:55PM -0500, Christoph Lameter wrote:
> Make use of the new node functions in mm/slab.h
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>
> 
> Index: linux/mm/slub.c
> ===================================================================
> --- linux.orig/mm/slub.c	2014-05-30 13:15:30.541864121 -0500
> +++ linux/mm/slub.c	2014-05-30 13:15:30.541864121 -0500
> @@ -2148,6 +2148,7 @@ static noinline void
>  slab_out_of_memory(struct kmem_cache *s, gfp_t gfpflags, int nid)
>  {
>  	int node;
> +	struct kmem_cache_node *n;
>  
>  	printk(KERN_WARNING
>  		"SLUB: Unable to allocate memory on node %d (gfp=0x%x)\n",
> @@ -2160,15 +2161,11 @@ slab_out_of_memory(struct kmem_cache *s,
>  		printk(KERN_WARNING "  %s debugging increased min order, use "
>  		       "slub_debug=O to disable.\n", s->name);
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
> @@ -4376,16 +4373,12 @@ static ssize_t show_slab_objects(struct
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
> @@ -5340,12 +5333,9 @@ void get_slabinfo(struct kmem_cache *s,
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

Hello, Christoph.

I think that we can use for_each_kmem_cache_node() instead of
using for_each_node_state(node, N_NORMAL_MEMORY). Just one
exception is init_kmem_cache_nodes() which is responsible
for setting kmem_cache_node correctly.

Is there any reason not to use it for for_each_node_state()?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
