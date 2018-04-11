Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id BB2716B0006
	for <linux-mm@kvack.org>; Wed, 11 Apr 2018 09:46:58 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id i4so1123950wrh.4
        for <linux-mm@kvack.org>; Wed, 11 Apr 2018 06:46:58 -0700 (PDT)
Received: from resqmta-ch2-06v.sys.comcast.net (resqmta-ch2-06v.sys.comcast.net. [2001:558:fe21:29:69:252:207:38])
        by mx.google.com with ESMTPS id v12si1513002eda.271.2018.04.11.06.46.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Apr 2018 06:46:57 -0700 (PDT)
Date: Wed, 11 Apr 2018 08:44:23 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH v2 2/2] slab: __GFP_ZERO is incompatible with a
 constructor
In-Reply-To: <20180411060320.14458-3-willy@infradead.org>
Message-ID: <alpine.DEB.2.20.1804110842560.3788@nuc-kabylake>
References: <20180411060320.14458-1-willy@infradead.org> <20180411060320.14458-3-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Mel Gorman <mgorman@techsingularity.net>

On Tue, 10 Apr 2018, Matthew Wilcox wrote:

> diff --git a/mm/slab.h b/mm/slab.h
> index 3cd4677953c6..896818c7b30a 100644
> --- a/mm/slab.h
> +++ b/mm/slab.h
> @@ -515,6 +515,13 @@ static inline void dump_unreclaimable_slab(void)
>
>  void ___cache_free(struct kmem_cache *cache, void *x, unsigned long addr);
>
> +static inline bool slab_no_ctor(struct kmem_cache *s)
> +{
> +	if (IS_ENABLED(CONFIG_DEBUG_VM))
> +		return !WARN_ON_ONCE(s->ctor);
> +	return true;
> +}
> +
>  #ifdef CONFIG_SLAB_FREELIST_RANDOM
>  int cache_random_seq_create(struct kmem_cache *cachep, unsigned int count,
>  			gfp_t gfp);

Move that to mm/slab.c? Debugging is runtime enabled with SLUB not compile
time as with SLAB.

> +++ b/mm/slub.c
> @@ -2725,7 +2726,7 @@ static __always_inline void *slab_alloc_node(struct kmem_cache *s,
>  		stat(s, ALLOC_FASTPATH);
>  	}
>
> -	if (unlikely(gfpflags & __GFP_ZERO) && object)
> +	if (unlikely(gfpflags & __GFP_ZERO) && object && slab_no_ctor(s))
>  		memset(object, 0, s->object_size);
>
>  	slab_post_alloc_hook(s, gfpflags, 1, &object);

Please put this in a code path that is enabled by specifying

slub_debug

on the kernel command line.
