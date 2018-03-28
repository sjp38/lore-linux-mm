Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 926BE6B000D
	for <linux-mm@kvack.org>; Tue, 27 Mar 2018 20:17:02 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id i137so368685pfe.0
        for <linux-mm@kvack.org>; Tue, 27 Mar 2018 17:17:02 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j2sor686325pfj.37.2018.03.27.17.17.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 27 Mar 2018 17:17:01 -0700 (PDT)
Date: Tue, 27 Mar 2018 17:16:59 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] slab, slub: skip unnecessary kasan_cache_shutdown()
In-Reply-To: <20180327230603.54721-1-shakeelb@google.com>
Message-ID: <alpine.DEB.2.20.1803271715310.8944@chino.kir.corp.google.com>
References: <20180327230603.54721-1-shakeelb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Alexander Potapenko <glider@google.com>, Greg Thelen <gthelen@google.com>, Dmitry Vyukov <dvyukov@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 27 Mar 2018, Shakeel Butt wrote:

> diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
> index 49fffb0ca83b..135ce2838c89 100644
> --- a/mm/kasan/kasan.c
> +++ b/mm/kasan/kasan.c
> @@ -382,7 +382,8 @@ void kasan_cache_shrink(struct kmem_cache *cache)
>  
>  void kasan_cache_shutdown(struct kmem_cache *cache)
>  {
> -	quarantine_remove_cache(cache);
> +	if (!__kmem_cache_empty(cache))
> +		quarantine_remove_cache(cache);
>  }
>  
>  size_t kasan_metadata_size(struct kmem_cache *cache)
> diff --git a/mm/slab.c b/mm/slab.c
> index 9212c64bb705..b59f2cdf28d1 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -2291,6 +2291,18 @@ static int drain_freelist(struct kmem_cache *cache,
>  	return nr_freed;
>  }
>  
> +bool __kmem_cache_empty(struct kmem_cache *s)
> +{
> +	int node;
> +	struct kmem_cache_node *n;
> +
> +	for_each_kmem_cache_node(s, node, n)
> +		if (!list_empty(&n->slabs_full) ||
> +		    !list_empty(&n->slabs_partial))
> +			return false;
> +	return true;
> +}
> +
>  int __kmem_cache_shrink(struct kmem_cache *cachep)
>  {
>  	int ret = 0;
> diff --git a/mm/slab.h b/mm/slab.h
> index e8981e811c45..68bdf498da3b 100644
> --- a/mm/slab.h
> +++ b/mm/slab.h
> @@ -166,6 +166,7 @@ static inline slab_flags_t kmem_cache_flags(unsigned int object_size,
>  			      SLAB_TEMPORARY | \
>  			      SLAB_ACCOUNT)
>  
> +bool __kmem_cache_empty(struct kmem_cache *);
>  int __kmem_cache_shutdown(struct kmem_cache *);
>  void __kmem_cache_release(struct kmem_cache *);
>  int __kmem_cache_shrink(struct kmem_cache *);
> diff --git a/mm/slub.c b/mm/slub.c
> index 1edc8d97c862..44aa7847324a 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -3707,6 +3707,17 @@ static void free_partial(struct kmem_cache *s, struct kmem_cache_node *n)
>  		discard_slab(s, page);
>  }
>  
> +bool __kmem_cache_empty(struct kmem_cache *s)
> +{
> +	int node;
> +	struct kmem_cache_node *n;
> +
> +	for_each_kmem_cache_node(s, node, n)
> +		if (n->nr_partial || slabs_node(s, node))
> +			return false;
> +	return true;
> +}
> +
>  /*
>   * Release all resources used by a slab cache.
>   */

Any reason not to just make quarantine_remove_cache() part of 
__kmem_cache_shutdown() instead of duplicating its logic?
