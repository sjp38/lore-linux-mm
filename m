Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f171.google.com (mail-ie0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id CDC646B0253
	for <linux-mm@kvack.org>; Fri, 10 Jul 2015 11:02:48 -0400 (EDT)
Received: by iecvh10 with SMTP id vh10so198368312iec.3
        for <linux-mm@kvack.org>; Fri, 10 Jul 2015 08:02:48 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0065.hostedemail.com. [216.40.44.65])
        by mx.google.com with ESMTP id 9si1631392igr.5.2015.07.10.08.02.47
        for <linux-mm@kvack.org>;
        Fri, 10 Jul 2015 08:02:47 -0700 (PDT)
Date: Fri, 10 Jul 2015 11:02:42 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [patch] mm/slub: Move slab initialization into irq enabled
 region
Message-ID: <20150710110242.25c84965@gandalf.local.home>
In-Reply-To: <20150710120259.836414367@linutronix.de>
References: <20150710120259.836414367@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Peter Zijlstra <peterz@infradead.org>

On Fri, 10 Jul 2015 12:07:13 -0000
Thomas Gleixner <tglx@linutronix.de> wrote:


>  /*
>   * Slab allocation and freeing
>   */
> @@ -1336,6 +1347,8 @@ static struct page *allocate_slab(struct
>  	struct page *page;
>  	struct kmem_cache_order_objects oo = s->oo;
>  	gfp_t alloc_gfp;
> +	void *start, *p;
> +	int idx, order;
>  
>  	flags &= gfp_allowed_mask;
>  
> @@ -1364,8 +1377,11 @@ static struct page *allocate_slab(struct
>  			stat(s, ORDER_FALLBACK);
>  	}
>  
> -	if (kmemcheck_enabled && page
> -		&& !(s->flags & (SLAB_NOTRACK | DEBUG_DEFAULT_FLAGS))) {
> +	if (!page)
> +		goto out;

Since the above now looks like this:

	page = alloc_slab_page(s, alloc_gfp, node, oo);
	if (unlikely(!page)) {
		oo = s->min;
		alloc_gfp = flags;
		/*
		 * Allocation may have failed due to fragmentation.
		 * Try a lower order alloc if possible
		 */
		page = alloc_slab_page(s, alloc_gfp, node, oo);

		if (page)
			stat(s, ORDER_FALLBACK);
	}

	if (!page)
		goto out;

Why not have it do this:

	page = alloc_slab_page(s, alloc_gfp, node, oo);
	if (unlikely(!page)) {
		oo = s->min;
		alloc_gfp = flags;
		/*
		 * Allocation may have failed due to fragmentation.
		 * Try a lower order alloc if possible
		 */
		page = alloc_slab_page(s, alloc_gfp, node, oo);
		if (unlikely(!page))
			goto out;

		stat(s, ORDER_FALLBACK);
	}

And get rid of the double check for !page in the fast path.

-- Steve


> +
> +	if (kmemcheck_enabled &&
> +	    !(s->flags & (SLAB_NOTRACK | DEBUG_DEFAULT_FLAGS))) {
>  		int pages = 1 << oo_order(oo);
>  
>  		kmemcheck_alloc_shadow(page, oo_order(oo), alloc_gfp, node);
> @@ -1380,51 +1396,12 @@ static struct page *allocate_slab(struct
>  			kmemcheck_mark_unallocated_pages(page, pages);
>  	}
>  
> -	if (flags & __GFP_WAIT)
> -		local_irq_disable();
>  	if (!page)
> -		return NULL;
> +		goto out;
>  
>  	page->objects = oo_objects(oo);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
