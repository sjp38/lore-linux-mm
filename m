Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7ECE16B01F1
	for <linux-mm@kvack.org>; Tue, 17 Aug 2010 20:35:16 -0400 (EDT)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id o7I0Z8uU032099
	for <linux-mm@kvack.org>; Tue, 17 Aug 2010 17:35:14 -0700
Received: from pzk6 (pzk6.prod.google.com [10.243.19.134])
	by wpaz37.hot.corp.google.com with ESMTP id o7I0Z6QT006211
	for <linux-mm@kvack.org>; Tue, 17 Aug 2010 17:35:07 -0700
Received: by pzk6 with SMTP id 6so2578147pzk.3
        for <linux-mm@kvack.org>; Tue, 17 Aug 2010 17:35:06 -0700 (PDT)
Date: Tue, 17 Aug 2010 17:35:03 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [S+Q Cleanup 6/6] slub: Move gfpflag masking out of the
 hotpath
In-Reply-To: <20100817211137.816192692@linux.com>
Message-ID: <alpine.DEB.2.00.1008171734150.21514@chino.kir.corp.google.com>
References: <20100817211118.958108012@linux.com> <20100817211137.816192692@linux.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 17 Aug 2010, Christoph Lameter wrote:

> Index: linux-2.6/mm/slub.c
> ===================================================================
> --- linux-2.6.orig/mm/slub.c	2010-08-13 10:33:09.000000000 -0500
> +++ linux-2.6/mm/slub.c	2010-08-13 10:33:13.000000000 -0500
> @@ -797,6 +797,7 @@ static void trace(struct kmem_cache *s, 
>   */
>  static inline int slab_pre_alloc_hook(struct kmem_cache *s, gfp_t flags)
>  {
> +	flags &= gfp_allowed_mask;
>  	lockdep_trace_alloc(flags);
>  	might_sleep_if(flags & __GFP_WAIT);
>  
> @@ -805,6 +806,7 @@ static inline int slab_pre_alloc_hook(st
>  
>  static inline void slab_post_alloc_hook(struct kmem_cache *s, gfp_t flags, void *object)
>  {
> +	flags &= gfp_allowed_mask;
>  	kmemcheck_slab_alloc(s, flags, object, s->objsize);
>  	kmemleak_alloc_recursive(object, s->objsize, 1, s->flags, flags);
>  }
> @@ -1678,6 +1680,7 @@ new_slab:
>  		goto load_freelist;
>  	}
>  
> +	gfpflags &= gfp_allowed_mask;
>  	if (gfpflags & __GFP_WAIT)
>  		local_irq_enable();
>  

Couldn't this include the masking of __GFP_ZERO at the beginning of 
__slab_alloc()?

> @@ -1726,8 +1729,6 @@ static __always_inline void *slab_alloc(
>  	struct kmem_cache_cpu *c;
>  	unsigned long flags;
>  
> -	gfpflags &= gfp_allowed_mask;
> -
>  	if (!slab_pre_alloc_hook(s, gfpflags))
>  		return NULL;
>  
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
