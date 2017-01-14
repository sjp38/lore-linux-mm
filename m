Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id A32FE6B0253
	for <linux-mm@kvack.org>; Sat, 14 Jan 2017 08:42:23 -0500 (EST)
Received: by mail-lf0-f72.google.com with SMTP id z134so31499704lff.5
        for <linux-mm@kvack.org>; Sat, 14 Jan 2017 05:42:23 -0800 (PST)
Received: from smtp14.mail.ru (smtp14.mail.ru. [94.100.181.95])
        by mx.google.com with ESMTPS id o203si9865493lfo.109.2017.01.14.05.42.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 14 Jan 2017 05:42:22 -0800 (PST)
Date: Sat, 14 Jan 2017 16:42:11 +0300
From: Vladimir Davydov <vdavydov@tarantool.org>
Subject: Re: [PATCH 7/9] slab: introduce __kmemcg_cache_deactivate()
Message-ID: <20170114134211.GF2668@esperanza>
References: <20170114055449.11044-1-tj@kernel.org>
 <20170114055449.11044-8-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170114055449.11044-8-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, jsvana@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, kernel-team@fb.com

On Sat, Jan 14, 2017 at 12:54:47AM -0500, Tejun Heo wrote:
> __kmem_cache_shrink() is called with %true @deactivate only for memcg
> caches.  Remove @deactivate from __kmem_cache_shrink() and introduce
> __kmemcg_cache_deactivate() instead.  Each memcg-supporting allocator
> should implement it and it should deactivate and drain the cache.
> 
> This is to allow memcg cache deactivation behavior to further deviate
> from simple shrinking without messing up __kmem_cache_shrink().
> 
> This is pure reorganization and doesn't introduce any observable
> behavior changes.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Pekka Enberg <penberg@kernel.org>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>

Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>

...
> diff --git a/mm/slab.h b/mm/slab.h
> index 8f47a44..73ed6b5 100644
> --- a/mm/slab.h
> +++ b/mm/slab.h
> @@ -164,7 +164,10 @@ static inline unsigned long kmem_cache_flags(unsigned long object_size,
>  
>  int __kmem_cache_shutdown(struct kmem_cache *);
>  void __kmem_cache_release(struct kmem_cache *);
> -int __kmem_cache_shrink(struct kmem_cache *, bool);
> +int __kmem_cache_shrink(struct kmem_cache *);
> +#if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
> +void __kmemcg_cache_deactivate(struct kmem_cache *s);
> +#endif

nit: ifdef is not necessary

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
