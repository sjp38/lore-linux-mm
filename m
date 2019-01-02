Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5AD288E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 11:59:38 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id c53so32431914edc.9
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 08:59:38 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id x47si1149282edb.265.2019.01.02.08.59.36
        for <linux-mm@kvack.org>;
        Wed, 02 Jan 2019 08:59:37 -0800 (PST)
Date: Wed, 2 Jan 2019 16:59:31 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH] kmemleak: survive in a low-memory situation
Message-ID: <20190102165931.GB6584@arrakis.emea.arm.com>
References: <0b2ecfe8-b98b-755c-5b5d-00a09a0d9e57@lca.pw>
 <20190102160849.11480-1-cai@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190102160849.11480-1-cai@lca.pw>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Qian,

On Wed, Jan 02, 2019 at 11:08:49AM -0500, Qian Cai wrote:
> Kmemleak could quickly fail to allocate an object structure and then
> disable itself in a low-memory situation. For example, running a mmap()
> workload triggering swapping and OOM [1].
> 
> First, it unnecessarily attempt to allocate even though the tracking
> object is NULL in kmem_cache_alloc(). For example,
> 
> alloc_io
>   bio_alloc_bioset
>     mempool_alloc
>       mempool_alloc_slab
>         kmem_cache_alloc
>           slab_alloc_node
>             __slab_alloc <-- could return NULL
>             slab_post_alloc_hook
>               kmemleak_alloc_recursive

kmemleak_alloc() only continues with the kmemleak_object allocation if
the given pointer is not NULL.

> diff --git a/mm/slab.h b/mm/slab.h
> index 4190c24ef0e9..51a9a942cc56 100644
> --- a/mm/slab.h
> +++ b/mm/slab.h
> @@ -435,15 +435,16 @@ static inline void slab_post_alloc_hook(struct kmem_cache *s, gfp_t flags,
>  {
>  	size_t i;
>  
> -	flags &= gfp_allowed_mask;
> -	for (i = 0; i < size; i++) {
> -		void *object = p[i];
> -
> -		kmemleak_alloc_recursive(object, s->object_size, 1,
> -					 s->flags, flags);
> -		p[i] = kasan_slab_alloc(s, object, flags);
> +	if (*p) {
> +		flags &= gfp_allowed_mask;
> +		for (i = 0; i < size; i++) {
> +			void *object = p[i];
> +
> +			kmemleak_alloc_recursive(object, s->object_size, 1,
> +						 s->flags, flags);
> +			p[i] = kasan_slab_alloc(s, object, flags);
> +		}
>  	}

This is not necessary for kmemleak.

-- 
Catalin
