Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id B0AAE6B0071
	for <linux-mm@kvack.org>; Mon,  7 Jun 2010 23:57:39 -0400 (EDT)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id o583vbc1031352
	for <linux-mm@kvack.org>; Mon, 7 Jun 2010 20:57:38 -0700
Received: from pxi8 (pxi8.prod.google.com [10.243.27.8])
	by wpaz21.hot.corp.google.com with ESMTP id o583vZ6r000854
	for <linux-mm@kvack.org>; Mon, 7 Jun 2010 20:57:36 -0700
Received: by pxi8 with SMTP id 8so3237114pxi.5
        for <linux-mm@kvack.org>; Mon, 07 Jun 2010 20:57:35 -0700 (PDT)
Date: Mon, 7 Jun 2010 20:57:31 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC V2 SLEB 03/14] SLUB: Use kmem_cache flags to detect if Slab
 is in debugging mode.
In-Reply-To: <20100521211538.695980225@quilx.com>
Message-ID: <alpine.DEB.2.00.1006072056250.18773@chino.kir.corp.google.com>
References: <20100521211452.659982351@quilx.com> <20100521211538.695980225@quilx.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 21 May 2010, Christoph Lameter wrote:

> Index: linux-2.6/mm/slub.c
> ===================================================================
> --- linux-2.6.orig/mm/slub.c	2010-04-27 12:41:05.000000000 -0500
> +++ linux-2.6/mm/slub.c	2010-04-27 13:15:32.000000000 -0500
> @@ -107,11 +107,17 @@
>   * 			the fast path and disables lockless freelists.
>   */
>  
> +#define SLAB_DEBUG_FLAGS (SLAB_RED_ZONE | SLAB_POISON | SLAB_STORE_USER | \
> +		SLAB_TRACE | SLAB_DEBUG_FREE)
> +
> +static inline int debug_on(struct kmem_cache *s)
> +{
>  #ifdef CONFIG_SLUB_DEBUG
> -#define SLABDEBUG 1
> +	return unlikely(s->flags & SLAB_DEBUG_FLAGS);
>  #else
> -#define SLABDEBUG 0
> +	return 0;
>  #endif
> +}
>  
>  /*
>   * Issues still to be resolved:

Nice optimization!  I'd recommend a non-generic name for this check, 
though, such as cache_debug_on().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
