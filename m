Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id A01896B0031
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 01:09:34 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id rd3so3897pab.4
        for <linux-mm@kvack.org>; Sun, 01 Jun 2014 22:09:34 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id gu4si14681799pac.206.2014.06.01.22.09.32
        for <linux-mm@kvack.org>;
        Sun, 01 Jun 2014 22:09:33 -0700 (PDT)
Date: Mon, 2 Jun 2014 14:12:54 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 4/4] slab: Use for_each_kmem_cache_node function
Message-ID: <20140602051254.GD17964@js1304-P5Q-DELUXE>
References: <20140530182753.191965442@linux.com>
 <20140530182801.678250467@linux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140530182801.678250467@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>

On Fri, May 30, 2014 at 01:27:57PM -0500, Christoph Lameter wrote:
> Reduce code somewhat by the use of kmem_cache_node.

Hello,

There are some other places that we can replace such as get_slabinfo(),
leaks_show(), etc.. If you want to replace for_each_online_node()
with for_each_kmem_cache_node, please also replace them.

Meanwhile, I think that this change is not good for readability. There
are many for_each_online_node() usage that we can't replace, so I don't
think this abstraction is really helpful clean-up. Possibly, using
for_each_online_node() consistently would be more readable than this
change.

Thanks.

> 
> Signed-off-by: Christoph Lameter <cl@linux.com>
> 
> Index: linux/mm/slab.c
> ===================================================================
> --- linux.orig/mm/slab.c	2014-05-30 13:08:32.986856450 -0500
> +++ linux/mm/slab.c	2014-05-30 13:08:32.986856450 -0500
> @@ -2415,17 +2415,12 @@ static void drain_cpu_caches(struct kmem
>  
>  	on_each_cpu(do_drain, cachep, 1);
>  	check_irq_on();
> -	for_each_online_node(node) {
> -		n = get_node(cachep, node);
> -		if (n && n->alien)
> +	for_each_kmem_cache_node(cachep, node, n)
> +		if (n->alien)
>  			drain_alien_cache(cachep, n->alien);
> -	}
>  
> -	for_each_online_node(node) {
> -		n = get_node(cachep, node);
> -		if (n)
> -			drain_array(cachep, n, n->shared, 1, node);
> -	}
> +	for_each_kmem_cache_node(cachep, node, n)
> +		drain_array(cachep, n, n->shared, 1, node);
>  }
>  
>  /*
> @@ -2478,11 +2473,7 @@ static int __cache_shrink(struct kmem_ca
>  	drain_cpu_caches(cachep);
>  
>  	check_irq_on();
> -	for_each_online_node(i) {
> -		n = get_node(cachep, i);
> -		if (!n)
> -			continue;
> -
> +	for_each_kmem_cache_node(cachep, i, n) {
>  		drain_freelist(cachep, n, slabs_tofree(cachep, n));
>  
>  		ret += !list_empty(&n->slabs_full) ||
> @@ -2525,13 +2516,10 @@ int __kmem_cache_shutdown(struct kmem_ca
>  	    kfree(cachep->array[i]);
>  
>  	/* NUMA: free the node structures */
> -	for_each_online_node(i) {
> -		n = get_node(cachep, i);
> -		if (n) {
> -			kfree(n->shared);
> -			free_alien_cache(n->alien);
> -			kfree(n);
> -		}
> +	for_each_kmem_cache_node(cachep, i, n) {
> +		kfree(n->shared);
> +		free_alien_cache(n->alien);
> +		kfree(n);
>  	}
>  	return 0;
>  }
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
