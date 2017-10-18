Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 75C776B0038
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 08:54:10 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id p2so3457719pfk.13
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 05:54:10 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u19si7416829pfg.51.2017.10.18.05.54.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 Oct 2017 05:54:09 -0700 (PDT)
Subject: Re: [patch] mm, slab: only set __GFP_RECLAIMABLE once
References: <alpine.DEB.2.10.1710171527560.140898@chino.kir.corp.google.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <1ddfd892-cf15-f7ca-4649-c3bb11682ce0@suse.cz>
Date: Wed, 18 Oct 2017 14:54:02 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1710171527560.140898@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@techsingularity.net>

+CC Mel who added that code (long time ago though :) in case he
remembers some catch.

On 10/18/2017 12:30 AM, David Rientjes wrote:
> SLAB_RECLAIM_ACCOUNT is a permanent attribute of a slab cache.  Set 
> __GFP_RECLAIMABLE as part of its ->allocflags rather than check the cachep 
> flag on every page allocation.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Seems correct to me, and SLUB does that this way too, since the beginning.

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/slab.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/slab.c b/mm/slab.c
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -1409,8 +1409,6 @@ static struct page *kmem_getpages(struct kmem_cache *cachep, gfp_t flags,
>  	int nr_pages;
>  
>  	flags |= cachep->allocflags;
> -	if (cachep->flags & SLAB_RECLAIM_ACCOUNT)
> -		flags |= __GFP_RECLAIMABLE;
>  
>  	page = __alloc_pages_node(nodeid, flags | __GFP_NOTRACK, cachep->gfporder);
>  	if (!page) {
> @@ -2143,6 +2141,8 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
>  	cachep->allocflags = __GFP_COMP;
>  	if (flags & SLAB_CACHE_DMA)
>  		cachep->allocflags |= GFP_DMA;
> +	if (flags & SLAB_RECLAIM_ACCOUNT)
> +		cachep->allocflags |= __GFP_RECLAIMABLE;
>  	cachep->size = size;
>  	cachep->reciprocal_buffer_size = reciprocal_value(size);
>  
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
