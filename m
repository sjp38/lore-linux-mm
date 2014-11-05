Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f175.google.com (mail-ie0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id AE4706B006C
	for <linux-mm@kvack.org>; Wed,  5 Nov 2014 13:43:34 -0500 (EST)
Received: by mail-ie0-f175.google.com with SMTP id y20so1327527ier.20
        for <linux-mm@kvack.org>; Wed, 05 Nov 2014 10:43:34 -0800 (PST)
Received: from resqmta-po-08v.sys.comcast.net (resqmta-po-08v.sys.comcast.net. [2001:558:fe16:19:96:114:154:167])
        by mx.google.com with ESMTPS id f83si6291872ioj.34.2014.11.05.10.43.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 05 Nov 2014 10:43:33 -0800 (PST)
Date: Wed, 5 Nov 2014 12:43:31 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH -mm 8/8] slab: recharge slab pages to the allocating
 memory cgroup
In-Reply-To: <fe7c55a7ff9bb8a1ddff0256f5404196c10bfd08.1415046910.git.vdavydov@parallels.com>
Message-ID: <alpine.DEB.2.11.1411051242410.28485@gentwo.org>
References: <cover.1415046910.git.vdavydov@parallels.com> <fe7c55a7ff9bb8a1ddff0256f5404196c10bfd08.1415046910.git.vdavydov@parallels.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 3 Nov 2014, Vladimir Davydov wrote:

> +static __always_inline void slab_free(struct kmem_cache *cachep, void *objp);
> +
>  static __always_inline void *
>  slab_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid,
>  		   unsigned long caller)
> @@ -3185,6 +3187,10 @@ slab_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid,
>  		kmemcheck_slab_alloc(cachep, flags, ptr, cachep->object_size);
>  		if (unlikely(flags & __GFP_ZERO))
>  			memset(ptr, 0, cachep->object_size);
> +		if (unlikely(memcg_kmem_recharge_slab(ptr, flags))) {
> +			slab_free(cachep, ptr);
> +			ptr = NULL;
> +		}
>  	}
>
>  	return ptr;
> @@ -3250,6 +3256,10 @@ slab_alloc(struct kmem_cache *cachep, gfp_t flags, unsigned long caller)
>  		kmemcheck_slab_alloc(cachep, flags, objp, cachep->object_size);
>  		if (unlikely(flags & __GFP_ZERO))
>  			memset(objp, 0, cachep->object_size);
> +		if (unlikely(memcg_kmem_recharge_slab(objp, flags))) {
> +			slab_free(cachep, objp);
> +			objp = NULL;
> +		}
>  	}
>

Please do not add code to the hotpaths if its avoidable. Can you charge
the full slab only when allocated please?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
