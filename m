Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 2DF5E6B01B7
	for <linux-mm@kvack.org>; Wed,  9 Jun 2010 12:27:21 -0400 (EDT)
Date: Wed, 9 Jun 2010 11:24:02 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [patch 3/4] slub: use is_kmalloc_cache in dma_kmalloc_cache
In-Reply-To: <alpine.DEB.2.00.1006082348310.30606@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1006091120460.21686@router.home>
References: <alpine.DEB.2.00.1006082347440.30606@chino.kir.corp.google.com> <alpine.DEB.2.00.1006082348310.30606@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 8 Jun 2010, David Rientjes wrote:

> diff --git a/mm/slub.c b/mm/slub.c
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -2649,13 +2649,12 @@ static noinline struct kmem_cache *dma_kmalloc_cache(int index, gfp_t flags)
>  	text = kasprintf(flags & ~SLUB_DMA, "kmalloc_dma-%d",
>  			 (unsigned int)realsize);
>
> -	s = NULL;
>  	for (i = 0; i < KMALLOC_CACHES; i++)
>  		if (!kmalloc_caches[i].size)
>  			break;
>
> -	BUG_ON(i >= KMALLOC_CACHES);
>  	s = kmalloc_caches + i;
> +	BUG_ON(!is_kmalloc_cache(s));

The point here is to check if the index I is still within the bonds of
kmalloc_cache. Use of is_kmalloc_cache() will confuse the reader.

The assignment to s can be removed independently but my recent versions of
cleanup patches remove the dynmamic allocation of dma slab caches.

Sadly there is the next conference this week in Berlin. So nothing before
next week I think.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
