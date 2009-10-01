Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 2D8FD6B00A3
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 16:49:12 -0400 (EDT)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id n91Kn6tp014314
	for <linux-mm@kvack.org>; Thu, 1 Oct 2009 21:49:06 +0100
Received: from pzk15 (pzk15.prod.google.com [10.243.19.143])
	by wpaz21.hot.corp.google.com with ESMTP id n91Ki6cL031711
	for <linux-mm@kvack.org>; Thu, 1 Oct 2009 13:49:03 -0700
Received: by pzk15 with SMTP id 15so545744pzk.3
        for <linux-mm@kvack.org>; Thu, 01 Oct 2009 13:49:03 -0700 (PDT)
Date: Thu, 1 Oct 2009 13:49:00 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 30/31] Fix use of uninitialized variable in
 cache_grow()
In-Reply-To: <1254406257-16735-1-git-send-email-sjayaraman@suse.de>
Message-ID: <alpine.DEB.1.00.0910011341280.27559@chino.kir.corp.google.com>
References: <1254406257-16735-1-git-send-email-sjayaraman@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Suresh Jayaraman <sjayaraman@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, Neil Brown <neilb@suse.de>, Miklos Szeredi <mszeredi@suse.cz>, Wouter Verhelst <w@uter.be>, Peter Zijlstra <a.p.zijlstra@chello.nl>, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

On Thu, 1 Oct 2009, Suresh Jayaraman wrote:

> From: Miklos Szeredi <mszeredi@suse.cz>
> 
> This fixes a bug in reserve-slub.patch.
> 
> If cache_grow() was called with objp != NULL then the 'reserve' local
> variable wasn't initialized. This resulted in ac->reserve being set to
> a rubbish value.  Due to this in some circumstances huge amounts of
> slab pages were allocated (due to slab_force_alloc() returning true),
> which caused atomic page allocation failures and slowdown of the
> system.
> 
> Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
> Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>
> ---
>  mm/slab.c |    5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> Index: mmotm/mm/slab.c
> ===================================================================
> --- mmotm.orig/mm/slab.c
> +++ mmotm/mm/slab.c
> @@ -2760,7 +2760,7 @@ static int cache_grow(struct kmem_cache
>  	size_t offset;
>  	gfp_t local_flags;
>  	struct kmem_list3 *l3;
> -	int reserve;
> +	int reserve = -1;
>  
>  	/*
>  	 * Be lazy and only check for valid flags here,  keeping it out of the
> @@ -2816,7 +2816,8 @@ static int cache_grow(struct kmem_cache
>  	if (local_flags & __GFP_WAIT)
>  		local_irq_disable();
>  	check_irq_off();
> -	slab_set_reserve(cachep, reserve);
> +	if (reserve != -1)
> +		slab_set_reserve(cachep, reserve);
>  	spin_lock(&l3->list_lock);
>  
>  	/* Make slab active. */

Given the patch description, shouldn't this be a test for objp != NULL 
instead, then?

If so, it doesn't make sense because reserve will only be initialized when 
objp == NULL in the call to kmem_getpages() from cache_grow().


The title of the patch suggests this is just dealing with an uninitialized 
auto variable so the anticipated change would be from "int reserve" to 
"int uninitialized_var(result)".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
