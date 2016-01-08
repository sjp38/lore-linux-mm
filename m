Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 18F5D6B025B
	for <linux-mm@kvack.org>; Thu,  7 Jan 2016 22:02:18 -0500 (EST)
Received: by mail-ig0-f176.google.com with SMTP id z14so48677888igp.1
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 19:02:18 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTPS id b20si25927405igr.10.2016.01.07.19.02.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 07 Jan 2016 19:02:17 -0800 (PST)
Date: Fri, 8 Jan 2016 12:05:19 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 04/10] slab: use slab_pre_alloc_hook in SLAB allocator
 shared with SLUB
Message-ID: <20160108030518.GD14457@js1304-P5Q-DELUXE>
References: <20160107140253.28907.5469.stgit@firesoul>
 <20160107140353.28907.45217.stgit@firesoul>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160107140353.28907.45217.stgit@firesoul>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Thu, Jan 07, 2016 at 03:03:53PM +0100, Jesper Dangaard Brouer wrote:
> Dedublicate code in SLAB allocator functions slab_alloc() and
> slab_alloc_node() by using the slab_pre_alloc_hook() call, which
> is now shared between SLUB and SLAB.
> 
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> ---
>  mm/slab.c |   18 ++++--------------
>  1 file changed, 4 insertions(+), 14 deletions(-)
> 
> diff --git a/mm/slab.c b/mm/slab.c
> index d5b29e7bee81..17fd6268ad41 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -3140,15 +3140,10 @@ slab_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid,
>  	void *ptr;
>  	int slab_node = numa_mem_id();
>  
> -	flags &= gfp_allowed_mask;
> -
> -	lockdep_trace_alloc(flags);
> -
> -	if (should_failslab(cachep, flags))
> +	cachep = slab_pre_alloc_hook(cachep, flags);
> +	if (!cachep)
>  		return NULL;

How about adding unlikely here?

>  
> -	cachep = memcg_kmem_get_cache(cachep, flags);
> -
>  	cache_alloc_debugcheck_before(cachep, flags);
>  	local_irq_save(save_flags);
>  
> @@ -3228,15 +3223,10 @@ slab_alloc(struct kmem_cache *cachep, gfp_t flags, unsigned long caller)
>  	unsigned long save_flags;
>  	void *objp;
>  
> -	flags &= gfp_allowed_mask;
> -
> -	lockdep_trace_alloc(flags);
> -
> -	if (should_failslab(cachep, flags))
> +	cachep = slab_pre_alloc_hook(cachep, flags);
> +	if (!cachep)
>  		return NULL;

Dito.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
