Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 7410F6B005D
	for <linux-mm@kvack.org>; Thu, 16 Aug 2012 03:02:29 -0400 (EDT)
Received: by lahd3 with SMTP id d3so1511168lah.14
        for <linux-mm@kvack.org>; Thu, 16 Aug 2012 00:02:27 -0700 (PDT)
Date: Thu, 16 Aug 2012 10:02:25 +0300 (EEST)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [PATCH] slub: prevent validate_slab() error due to race
 condition
In-Reply-To: <alpine.DEB.2.00.1205301254080.31078@router.home>
Message-ID: <alpine.LFD.2.02.1208160944400.2133@tux.localdomain>
References: <1335466658-29063-1-git-send-email-Waiman.Long@hp.com> <alpine.DEB.2.00.1204270911080.29198@router.home> <4F9AFD28.2030801@hp.com> <CAOJsxLGXZsq22LuNa5ef5iv7Jy0A0w_S2MbDQeBW=dFvUwFRjA@mail.gmail.com> <alpine.DEB.2.00.1205011522340.2091@router.home>
 <alpine.LFD.2.02.1205300946170.2681@tux.localdomain> <alpine.DEB.2.00.1205301039420.29257@router.home> <alpine.DEB.2.00.1205301254080.31078@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, waiman.long@hp.com, rientjes@google.com

On Wed, 30 May 2012, Christoph Lameter wrote:
> Subject: slub: Take node lock during object free checks
> 
> Only applies to scenarios where debugging is on:
> 
> Validation of slabs can currently occur while debugging
> information is updated from the fast paths of the allocator.
> This results in various races where we get false reports about
> slab metadata not being in order.
> 
> This patch makes the fast paths take the node lock so that
> serialization with slab validation will occur. Causes additional
> slowdown in debug scenarios.
> 
> Reported-by: Waiman Long <Waiman.Long@hp.com>
> Signed-off-by: Christoph Lameter <cl@linux.com>

Applied! Thanks and sorry for the delay.

> 
> ---
>  mm/slub.c |   30 ++++++++++++++++++------------
>  1 file changed, 18 insertions(+), 12 deletions(-)
> 
> Index: linux-2.6/mm/slub.c
> ===================================================================
> --- linux-2.6.orig/mm/slub.c	2012-05-21 08:58:30.000000000 -0500
> +++ linux-2.6/mm/slub.c	2012-05-30 12:53:29.000000000 -0500
> @@ -1082,13 +1082,13 @@ bad:
>  	return 0;
>  }
> 
> -static noinline int free_debug_processing(struct kmem_cache *s,
> -		 struct page *page, void *object, unsigned long addr)
> +static noinline struct kmem_cache_node *free_debug_processing(
> +	struct kmem_cache *s, struct page *page, void *object,
> +	unsigned long addr, unsigned long *flags)
>  {
> -	unsigned long flags;
> -	int rc = 0;
> +	struct kmem_cache_node *n = get_node(s, page_to_nid(page));
> 
> -	local_irq_save(flags);
> +	spin_lock_irqsave(&n->list_lock, *flags);
>  	slab_lock(page);
> 
>  	if (!check_slab(s, page))
> @@ -1126,15 +1126,19 @@ static noinline int free_debug_processin
>  		set_track(s, object, TRACK_FREE, addr);
>  	trace(s, page, object, 0);
>  	init_object(s, object, SLUB_RED_INACTIVE);
> -	rc = 1;
>  out:
>  	slab_unlock(page);
> -	local_irq_restore(flags);
> -	return rc;
> +	/*
> +	 * Keep node_lock to preserve integrity
> +	 * until the object is actually freed
> +	 */
> +	return n;
> 
>  fail:
> +	slab_unlock(page);
> +	spin_unlock_irqrestore(&n->list_lock, *flags);
>  	slab_fix(s, "Object at 0x%p not freed", object);
> -	goto out;
> +	return NULL;
>  }
> 
>  static int __init setup_slub_debug(char *str)
> @@ -1227,8 +1231,9 @@ static inline void setup_object_debug(st
>  static inline int alloc_debug_processing(struct kmem_cache *s,
>  	struct page *page, void *object, unsigned long addr) { return 0; }
> 
> -static inline int free_debug_processing(struct kmem_cache *s,
> -	struct page *page, void *object, unsigned long addr) { return 0; }
> +static inline struct kmem_cache_node *free_debug_processing(
> +	struct kmem_cache *s, struct page *page, void *object,
> +	unsigned long addr, unsigned long *flags) { return NULL; }
> 
>  static inline int slab_pad_check(struct kmem_cache *s, struct page *page)
>  			{ return 1; }
> @@ -2445,7 +2450,8 @@ static void __slab_free(struct kmem_cach
> 
>  	stat(s, FREE_SLOWPATH);
> 
> -	if (kmem_cache_debug(s) && !free_debug_processing(s, page, x, addr))
> +	if (kmem_cache_debug(s) &&
> +		!(n = free_debug_processing(s, page, x, addr, &flags)))
>  		return;
> 
>  	do {
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
