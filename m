Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 060BE6B029E
	for <linux-mm@kvack.org>; Mon, 31 Oct 2016 19:38:23 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id hr10so40703446pac.2
        for <linux-mm@kvack.org>; Mon, 31 Oct 2016 16:38:22 -0700 (PDT)
Received: from mail-pf0-x22a.google.com (mail-pf0-x22a.google.com. [2607:f8b0:400e:c00::22a])
        by mx.google.com with ESMTPS id i127si15834389pgc.228.2016.10.31.16.38.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Oct 2016 16:38:22 -0700 (PDT)
Received: by mail-pf0-x22a.google.com with SMTP id d2so9347804pfd.0
        for <linux-mm@kvack.org>; Mon, 31 Oct 2016 16:38:22 -0700 (PDT)
Date: Mon, 31 Oct 2016 16:38:20 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] memcg: Prevent memcg caches to be both OFF_SLAB &
 OBJFREELIST_SLAB
In-Reply-To: <1477939010-111710-1-git-send-email-thgarnie@google.com>
Message-ID: <alpine.DEB.2.10.1610311625430.62482@chino.kir.corp.google.com>
References: <1477939010-111710-1-git-send-email-thgarnie@google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Garnier <thgarnie@google.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, gthelen@google.com, vdavydov.dev@gmail.com, mhocko@kernel.org

On Mon, 31 Oct 2016, Thomas Garnier wrote:

> While testing OBJFREELIST_SLAB integration with pagealloc, we found a
> bug where kmem_cache(sys) would be created with both CFLGS_OFF_SLAB &
> CFLGS_OBJFREELIST_SLAB.
> 
> The original kmem_cache is created early making OFF_SLAB not possible.
> When kmem_cache(sys) is created, OFF_SLAB is possible and if pagealloc
> is enabled it will try to enable it first under certain conditions.
> Given kmem_cache(sys) reuses the original flag, you can have both flags
> at the same time resulting in allocation failures and odd behaviors.
> 
> This fix discards allocator specific flags from memcg and ensure
> cache_create cannot be called with them.
> 
> Fixes: b03a017bebc4 ("mm/slab: introduce new slab management type, OBJFREELIST_SLAB")
> Signed-off-by: Thomas Garnier <thgarnie@google.com>
> Signed-off-by: Greg Thelen <gthelen@google.com>

Order of the signoffs is strange, should this have a

From: Greg Thelen <gthelen@google.com>

in the first line or is this your patch?

> ---
> Based on next-20161025
> ---
>  mm/slab.h        |  3 +++
>  mm/slab_common.c | 10 ++++++++--
>  2 files changed, 11 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/slab.h b/mm/slab.h
> index 9653f2e..58be647 100644
> --- a/mm/slab.h
> +++ b/mm/slab.h
> @@ -144,6 +144,9 @@ static inline unsigned long kmem_cache_flags(unsigned long object_size,
>  
>  #define CACHE_CREATE_MASK (SLAB_CORE_FLAGS | SLAB_DEBUG_FLAGS | SLAB_CACHE_FLAGS)
>  
> +/* Common allocator flags allowed for cache_create. */
> +#define SLAB_FLAGS_PERMITTED (CACHE_CREATE_MASK | SLAB_KASAN)
> +
>  int __kmem_cache_shutdown(struct kmem_cache *);
>  void __kmem_cache_release(struct kmem_cache *);
>  int __kmem_cache_shrink(struct kmem_cache *, bool);
> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index 71f0b28..01d067c 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -329,6 +329,12 @@ static struct kmem_cache *create_cache(const char *name,
>  	struct kmem_cache *s;
>  	int err;
>  
> +	/* Do not allow allocator specific flags */
> +	if (flags & ~SLAB_FLAGS_PERMITTED) {
> +		err = -EINVAL;
> +		goto out;
> +	}
> +

Why not just flags &= SLAB_FLAGS_PERMITTED if we're concerned about this 
like kmem_cache_create does &= CACHE_CREATE_MASK?

>  	err = -ENOMEM;
>  	s = kmem_cache_zalloc(kmem_cache, GFP_KERNEL);
>  	if (!s)
> @@ -533,8 +539,8 @@ void memcg_create_kmem_cache(struct mem_cgroup *memcg,
>  
>  	s = create_cache(cache_name, root_cache->object_size,
>  			 root_cache->size, root_cache->align,
> -			 root_cache->flags, root_cache->ctor,
> -			 memcg, root_cache);
> +			 root_cache->flags & SLAB_FLAGS_PERMITTED,
> +			 root_cache->ctor, memcg, root_cache);
>  	/*
>  	 * If we could not create a memcg cache, do not complain, because
>  	 * that's not critical at all as we can always proceed with the root

This introduces an inconsistency that isn't explained: why is SLAB_KASAN, 
the only reason why SLAB_FLAGS_PERMITTED needs to be defined, permitted 
for memcg_create_kmem_cache() but not kmem_cache_create()?  (If we need to 
keep SLAB_FLAGS_PERMITTED around, I think it needs a new name since its a 
restriction on the cache, not slab.)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
