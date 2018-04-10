Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0AB966B026C
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 09:40:56 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id x184so5198644pfd.14
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 06:40:56 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f123si1847332pfc.374.2018.04.10.06.40.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 10 Apr 2018 06:40:53 -0700 (PDT)
Subject: Re: [PATCH 1/2] slab: __GFP_ZERO is incompatible with a constructor
References: <20180410125351.15837-1-willy@infradead.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <84575e2b-1d67-905d-9d04-023622b49855@suse.cz>
Date: Tue, 10 Apr 2018 15:40:49 +0200
MIME-Version: 1.0
In-Reply-To: <20180410125351.15837-1-willy@infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, stable@vger.kernel.org

On 04/10/2018 02:53 PM, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> __GFP_ZERO requests that the object be initialised to all-zeroes,
> while the purpose of a constructor is to initialise an object to a
> particular pattern.  We cannot do both.  Add a warning to catch any
> users who mistakenly pass a __GFP_ZERO flag when allocating a slab with
> a constructor.
> 
> Fixes: d07dbea46405 ("Slab allocators: support __GFP_ZERO in all allocators")
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
> Cc: stable@vger.kernel.org

It doesn't fix any known problem, does it? Then the stable tag seems too
much IMHO. Especially for fixing a 2007 commit.

Otherwise
Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/slab.c | 6 ++++--
>  mm/slob.c | 4 +++-
>  mm/slub.c | 6 ++++--
>  3 files changed, 11 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/slab.c b/mm/slab.c
> index 38d3f4fd17d7..8b2cb7db85db 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -3313,8 +3313,10 @@ slab_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid,
>  	local_irq_restore(save_flags);
>  	ptr = cache_alloc_debugcheck_after(cachep, flags, ptr, caller);
>  
> -	if (unlikely(flags & __GFP_ZERO) && ptr)
> -		memset(ptr, 0, cachep->object_size);
> +	if (unlikely(flags & __GFP_ZERO) && ptr) {
> +		if (!WARN_ON_ONCE(cachep->ctor))
> +			memset(ptr, 0, cachep->object_size);
> +	}
>  
>  	slab_post_alloc_hook(cachep, flags, 1, &ptr);
>  	return ptr;
> diff --git a/mm/slob.c b/mm/slob.c
> index 1a46181b675c..958173fd7c24 100644
> --- a/mm/slob.c
> +++ b/mm/slob.c
> @@ -556,8 +556,10 @@ static void *slob_alloc_node(struct kmem_cache *c, gfp_t flags, int node)
>  					    flags, node);
>  	}
>  
> -	if (b && c->ctor)
> +	if (b && c->ctor) {
> +		WARN_ON_ONCE(flags & __GFP_ZERO);
>  		c->ctor(b);
> +	}
>  
>  	kmemleak_alloc_recursive(b, c->size, 1, c->flags, flags);
>  	return b;
> diff --git a/mm/slub.c b/mm/slub.c
> index 9e1100f9298f..0f55f0a0dcaa 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -2714,8 +2714,10 @@ static __always_inline void *slab_alloc_node(struct kmem_cache *s,
>  		stat(s, ALLOC_FASTPATH);
>  	}
>  
> -	if (unlikely(gfpflags & __GFP_ZERO) && object)
> -		memset(object, 0, s->object_size);
> +	if (unlikely(gfpflags & __GFP_ZERO) && object) {
> +		if (!WARN_ON_ONCE(s->ctor))
> +			memset(object, 0, s->object_size);
> +	}
>  
>  	slab_post_alloc_hook(s, gfpflags, 1, &object);
>  
> 
