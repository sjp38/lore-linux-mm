Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id ADA436B0031
	for <linux-mm@kvack.org>; Tue,  3 Dec 2013 21:06:25 -0500 (EST)
Received: by mail-pd0-f172.google.com with SMTP id g10so21344256pdj.31
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 18:06:25 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id ws5si53063563pab.64.2013.12.03.18.06.23
        for <linux-mm@kvack.org>;
        Tue, 03 Dec 2013 18:06:24 -0800 (PST)
Date: Tue, 3 Dec 2013 18:07:17 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 2/2] fs: buffer: move allocation failure loop into the
 allocator
Message-Id: <20131203180717.94c013d1.akpm@linux-foundation.org>
In-Reply-To: <20131204015218.GA19709@lge.com>
References: <1381265890-11333-1-git-send-email-hannes@cmpxchg.org>
	<1381265890-11333-2-git-send-email-hannes@cmpxchg.org>
	<20131203165910.54d6b4724a1f3e329af52ac6@linux-foundation.org>
	<20131204015218.GA19709@lge.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, azurIt <azurit@pobox.sk>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Christian Casteyde <casteyde.christian@free.fr>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>

On Wed, 4 Dec 2013 10:52:18 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:

> SLUB already try to allocate high order page with clearing __GFP_NOFAIL.
> But, when allocating shadow page for kmemcheck, it missed clearing
> the flag. This trigger WARN_ON_ONCE() reported by Christian Casteyde.
> 
> https://bugzilla.kernel.org/show_bug.cgi?id=65991
> 
> This patch fix this situation by using same allocation flag as original
> allocation.
> 
> Reported-by: Christian Casteyde <casteyde.christian@free.fr>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> diff --git a/mm/slub.c b/mm/slub.c
> index 545a170..3dd28b1 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -1335,11 +1335,12 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
>  	page = alloc_slab_page(alloc_gfp, node, oo);
>  	if (unlikely(!page)) {
>  		oo = s->min;

What is the value of s->min?  Please tell me it's zero.

> +		alloc_gfp = flags;
>  		/*
>  		 * Allocation may have failed due to fragmentation.
>  		 * Try a lower order alloc if possible
>  		 */
> -		page = alloc_slab_page(flags, node, oo);
> +		page = alloc_slab_page(alloc_gfp, node, oo);
>  
>  		if (page)
>  			stat(s, ORDER_FALLBACK);

This change doesn't actually do anything.

> @@ -1349,7 +1350,7 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
>  		&& !(s->flags & (SLAB_NOTRACK | DEBUG_DEFAULT_FLAGS))) {
>  		int pages = 1 << oo_order(oo);
>  
> -		kmemcheck_alloc_shadow(page, oo_order(oo), flags, node);
> +		kmemcheck_alloc_shadow(page, oo_order(oo), alloc_gfp, node);

That seems reasonable, assuming kmemcheck can handle the allocation
failure.


Still I dislike this practice of using unnecessarily large allocations.
What does it gain us?  Slightly improved object packing density. 
Anything else?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
