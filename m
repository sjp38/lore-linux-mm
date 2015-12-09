Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f169.google.com (mail-io0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id B42936B0255
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 21:35:44 -0500 (EST)
Received: by ioc74 with SMTP id 74so44880751ioc.2
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 18:35:44 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTPS id i4si9345552igu.39.2015.12.08.18.35.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 08 Dec 2015 18:35:43 -0800 (PST)
Date: Wed, 9 Dec 2015 11:36:58 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC PATCH V2 2/9] mm: generalize avoid fault-inject on
 bootstrap kmem_cache
Message-ID: <20151209023658.GA12482@js1304-P5Q-DELUXE>
References: <20151208161751.21945.53936.stgit@firesoul>
 <20151208161832.21945.55076.stgit@firesoul>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151208161832.21945.55076.stgit@firesoul>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Dec 08, 2015 at 05:18:32PM +0100, Jesper Dangaard Brouer wrote:
> Move slab_should_failslab() check from SLAB allocator to generic
> slab_pre_alloc_hook().  The check guards against slab alloc
> fault-injects failures for the bootstrap slab that is used for
> allocating "kmem_cache" objects to the allocator itself.
> 
> I'm not really happy with this code...
> ---
>  mm/failslab.c |    2 ++
>  mm/slab.c     |    8 --------
>  mm/slab.h     |   23 ++++++++++++++++++++++-
>  3 files changed, 24 insertions(+), 9 deletions(-)
> 
> diff --git a/mm/failslab.c b/mm/failslab.c
> index 79171b4a5826..a2ad28ba696c 100644
> --- a/mm/failslab.c
> +++ b/mm/failslab.c
> @@ -13,6 +13,8 @@ static struct {
>  
>  bool should_failslab(size_t size, gfp_t gfpflags, unsigned long cache_flags)
>  {
> +	// Should we place bootstrap kmem_cache check here???
> +
>  	if (gfpflags & __GFP_NOFAIL)
>  		return false;
>  
> diff --git a/mm/slab.c b/mm/slab.c
> index 4765c97ce690..4684c2496982 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -2917,14 +2917,6 @@ static void *cache_alloc_debugcheck_after(struct kmem_cache *cachep,
>  #define cache_alloc_debugcheck_after(a,b,objp,d) (objp)
>  #endif
>  
> -static bool slab_should_failslab(struct kmem_cache *cachep, gfp_t flags)
> -{
> -	if (unlikely(cachep == kmem_cache))
> -		return false;
> -
> -	return should_failslab(cachep->object_size, flags, cachep->flags);
> -}
> -
>  static inline void *____cache_alloc(struct kmem_cache *cachep, gfp_t flags)
>  {
>  	void *objp;
> diff --git a/mm/slab.h b/mm/slab.h
> index 588bc5281fc8..4e7b0e62f3f4 100644
> --- a/mm/slab.h
> +++ b/mm/slab.h
> @@ -360,6 +360,27 @@ static inline size_t slab_ksize(const struct kmem_cache *s)
>  }
>  #endif
>  
> +/* FIXME: This construct sucks, because this compare+branch needs to
> + * get removed by compiler then !CONFIG_FAILSLAB (maybe compiler is
> + * smart enough to realize only "false" can be generated).
> + *
> + * Comments please: Pulling out CONFIG_FAILSLAB here looks ugly...
> + *  should we instead change API of should_failslab() ??
> + *
> + * Next question: is the bootstrap cache check okay to add for all
> + * allocators? (this would be the easiest, else need more ugly ifdef's)
> + */
> +static inline bool slab_should_failslab(struct kmem_cache *cachep, gfp_t flags)
> +{
> +	/* No fault-injection for bootstrap cache */
> +#ifdef CONFIG_FAILSLAB
> +	if (unlikely(cachep == kmem_cache))
> +		return false;
> +#endif
> +
> +	return should_failslab(cachep->object_size, flags, cachep->flags);
> +}
> +
>  static inline struct kmem_cache *slab_pre_alloc_hook(struct kmem_cache *s,
>  						     gfp_t flags)
>  {
> @@ -367,7 +388,7 @@ static inline struct kmem_cache *slab_pre_alloc_hook(struct kmem_cache *s,
>  	lockdep_trace_alloc(flags);
>  	might_sleep_if(gfpflags_allow_blocking(flags));
>  
> -	if (should_failslab(s->object_size, flags, s->flags))
> +	if (slab_should_failslab(s, flags))
>  		return NULL;

It'd be better to remove slab_should_failslab() and insert following code
snippet here.

if (IS_ENABLED(CONFIG_FAILSLAB) &&
        cachep != kmem_cache &&
        should_failslab())
        return NULL;

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
