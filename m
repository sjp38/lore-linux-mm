Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id ABF326B002B
	for <linux-mm@kvack.org>; Mon,  8 Oct 2012 17:28:39 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa10so4900440pad.14
        for <linux-mm@kvack.org>; Mon, 08 Oct 2012 14:28:39 -0700 (PDT)
Date: Mon, 8 Oct 2012 14:28:37 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v4] slab: Ignore internal flags in cache creation
In-Reply-To: <1349434154-8000-1-git-send-email-glommer@parallels.com>
Message-ID: <alpine.DEB.2.00.1210081424340.22552@chino.kir.corp.google.com>
References: <1349434154-8000-1-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>

On Fri, 5 Oct 2012, Glauber Costa wrote:

> diff --git a/mm/slab.h b/mm/slab.h
> index 7deeb44..4c35c17 100644
> --- a/mm/slab.h
> +++ b/mm/slab.h
> @@ -45,6 +45,31 @@ static inline struct kmem_cache *__kmem_cache_alias(const char *name, size_t siz
>  #endif
>  
>  
> +/* Legal flag mask for kmem_cache_create(), for various configurations */
> +#define SLAB_CORE_FLAGS (SLAB_HWCACHE_ALIGN | SLAB_CACHE_DMA | SLAB_PANIC | \
> +			 SLAB_DESTROY_BY_RCU | SLAB_DEBUG_OBJECTS )
> +
> +#if defined(CONFIG_DEBUG_SLAB)
> +#define SLAB_DEBUG_FLAGS (SLAB_RED_ZONE | SLAB_POISON | SLAB_STORE_USER)
> +#elif defined(CONFIG_SLUB_DEBUG)
> +#define SLAB_DEBUG_FLAGS (SLAB_RED_ZONE | SLAB_POISON | SLAB_STORE_USER | \
> +			  SLAB_TRACE | SLAB_DEBUG_FREE)
> +#else
> +#define SLAB_DEBUG_FLAGS (0)
> +#endif
> +
> +#if defined(CONFIG_SLAB)
> +#define SLAB_CACHE_FLAGS (SLAB_MEMSPREAD | SLAB_NOLEAKTRACE | \

s/SLAB_MEMSPREAD/SLAB_MEM_SPREAD/

> +			  SLAB_RECLAIM_ACCOUNT | SLAB_TEMPORARY | SLAB_NOTRACK)
> +#elif defined(CONFIG_SLUB)
> +#define SLAB_CACHE_FLAGS (SLAB_NOLEAKTRACE | SLAB_RECLAIM_ACCOUNT | \
> +			  SLAB_TEMPORARY | SLAB_NOTRACK)
> +#else
> +#define SLAB_CACHE_FLAGS (0)
> +#endif
> +
> +#define CACHE_CREATE_MASK (SLAB_CORE_FLAGS | SLAB_DEBUG_FLAGS | SLAB_CACHE_FLAGS)
> +
>  int __kmem_cache_shutdown(struct kmem_cache *);
>  
>  #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
