Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 9922C830B2
	for <linux-mm@kvack.org>; Sun,  7 Feb 2016 14:10:24 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id ho8so62034765pac.2
        for <linux-mm@kvack.org>; Sun, 07 Feb 2016 11:10:24 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id x77si40720280pfa.33.2016.02.07.11.10.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Feb 2016 11:10:23 -0800 (PST)
Date: Sun, 7 Feb 2016 22:10:07 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH] mm: slab: free kmem_cache_node after destroy sysfs file
Message-ID: <20160207191006.GC19151@esperanza>
References: <1454692612-14856-1-git-send-email-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1454692612-14856-1-git-send-email-dsafonov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <dsafonov@virtuozzo.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, 0x7f454c46@gmail.com, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Fri, Feb 05, 2016 at 08:16:52PM +0300, Dmitry Safonov wrote:
...
> diff --git a/mm/slab.c b/mm/slab.c
> index 6ecc697..41176dd 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -2414,13 +2414,19 @@ int __kmem_cache_shrink(struct kmem_cache *cachep, bool deactivate)
>  
>  int __kmem_cache_shutdown(struct kmem_cache *cachep)
>  {
> -	int i;
> -	struct kmem_cache_node *n;
>  	int rc = __kmem_cache_shrink(cachep, false);
>  
>  	if (rc)
>  		return rc;

Nit:

 int __kmem_cache_shutdown(struct kmem_cache *cachep)
 {
-	int rc = __kmem_cache_shrink(cachep, false);
-
-	if (rc)
-		return rc;
-
-	return 0;
+	return __kmem_cache_shrink(cachep, false);
 }

>  
> +	return 0;
> +}
> +
> +void __kmem_cache_release(struct kmem_cache *cachep)
> +{
> +	int i;
> +	struct kmem_cache_node *n;
> +
>  	free_percpu(cachep->cpu_cache);
>  
>  	/* NUMA: free the node structures */
> @@ -2430,7 +2436,6 @@ int __kmem_cache_shutdown(struct kmem_cache *cachep)
>  		kfree(n);
>  		cachep->node[i] = NULL;
>  	}
> -	return 0;
>  }
>  
>  /*

You seem to forget to replace __kmem_cache_shutdown with
__kmem_cache_release in __kmem_cache_create error path:

@@ -2168,7 +2168,7 @@ done:
 
 	err = setup_cpu_cache(cachep, gfp);
 	if (err) {
-		__kmem_cache_shutdown(cachep);
+		__kmem_cache_release(cachep);
 		return err;
 	}

...
> diff --git a/mm/slub.c b/mm/slub.c
> index 2e1355a..ce21ce2 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -3173,11 +3173,12 @@ static void early_kmem_cache_node_alloc(int node)
>  	__add_partial(n, page, DEACTIVATE_TO_HEAD);
>  }
>  
> -static void free_kmem_cache_nodes(struct kmem_cache *s)
> +void __kmem_cache_release(struct kmem_cache *s)
>  {
>  	int node;
>  	struct kmem_cache_node *n;
>  
> +	free_percpu(s->cpu_slab);

That's rather nit-picking, but this kinda disrupts
init_kmem_cache_nodes/free_kmem_cache_nodes symmetry.
I'd leave free_kmem_cache_nodes alone and make
__kmem_cache_release call it along with free_percpu.
This would also reduce the patch footprint, because
the two hunks below wouldn't be needed.

>  	for_each_kmem_cache_node(s, node, n) {
>  		kmem_cache_free(kmem_cache_node, n);
>  		s->node[node] = NULL;
> @@ -3199,7 +3200,7 @@ static int init_kmem_cache_nodes(struct kmem_cache *s)
>  						GFP_KERNEL, node);
>  
>  		if (!n) {
> -			free_kmem_cache_nodes(s);
> +			__kmem_cache_release(s);
>  			return 0;
>  		}
>  
> @@ -3405,7 +3406,7 @@ static int kmem_cache_open(struct kmem_cache *s, unsigned long flags)
>  	if (alloc_kmem_cache_cpus(s))
>  		return 0;
>  
> -	free_kmem_cache_nodes(s);
> +	__kmem_cache_release(s);
>  error:
>  	if (flags & SLAB_PANIC)
>  		panic("Cannot create slab %s size=%lu realsize=%u "
> @@ -3443,7 +3444,7 @@ static void list_slab_objects(struct kmem_cache *s, struct page *page,
>  
>  /*
>   * Attempt to free all partial slabs on a node.
> - * This is called from kmem_cache_close(). We must be the last thread
> + * This is called from __kmem_cache_shutdown(). We must be the last thread
>   * using the cache and therefore we do not need to lock anymore.

Well, that's not true as we've found out - sysfs might still access the
cache in parallel. And alloc_calls_show -> list_locations does walk over
the kmem_cache_node->partial list, which we prune on shutdown.

I guess we should reintroduce locking for free_partial() in the scope of
this patch, partially reverting 69cb8e6b7c298.

>   */
>  static void free_partial(struct kmem_cache *s, struct kmem_cache_node *n)
> @@ -3456,7 +3457,7 @@ static void free_partial(struct kmem_cache *s, struct kmem_cache_node *n)
>  			discard_slab(s, page);
>  		} else {
>  			list_slab_objects(s, page,
> -			"Objects remaining in %s on kmem_cache_close()");
> +			"Objects remaining in %s on __kmem_cache_shutdown()");
>  		}
>  	}
>  }
> @@ -3464,7 +3465,7 @@ static void free_partial(struct kmem_cache *s, struct kmem_cache_node *n)
>  /*
>   * Release all resources used by a slab cache.
>   */
> -static inline int kmem_cache_close(struct kmem_cache *s)
> +int __kmem_cache_shutdown(struct kmem_cache *s)
>  {
>  	int node;
>  	struct kmem_cache_node *n;
> @@ -3476,16 +3477,9 @@ static inline int kmem_cache_close(struct kmem_cache *s)
>  		if (n->nr_partial || slabs_node(s, node))
>  			return 1;
>  	}
> -	free_percpu(s->cpu_slab);
> -	free_kmem_cache_nodes(s);
>  	return 0;
>  }
>  
> -int __kmem_cache_shutdown(struct kmem_cache *s)
> -{
> -	return kmem_cache_close(s);
> -}
> -
>  /********************************************************************
>   *		Kmalloc subsystem
>   *******************************************************************/
> @@ -3979,8 +3973,10 @@ int __kmem_cache_create(struct kmem_cache *s, unsigned long flags)
>  
>  	memcg_propagate_slab_attrs(s);
>  	err = sysfs_slab_add(s);
> -	if (err)
> -		kmem_cache_close(s);
> +	if (err) {
> +		__kmem_cache_shutdown(s);
> +		__kmem_cache_release(s);
> +	}

No point calling __kmem_cache_shutdown on __kmem_cache_create error path
- the cache hasn't been used yet.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
