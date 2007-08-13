Received: from krystal.dyndns.org ([76.65.103.147])
          by tomts5-srv.bellnexxia.net
          (InterMail vM.5.01.06.13 201-253-122-130-113-20050324) with ESMTP
          id <20070813221847.QPCV1592.tomts5-srv.bellnexxia.net@krystal.dyndns.org>
          for <linux-mm@kvack.org>; Mon, 13 Aug 2007 18:18:47 -0400
Date: Mon, 13 Aug 2007 18:18:47 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: Re: [patch 00/10] [RFC] SLUB patches for more functionality, performance and maintenance
Message-ID: <20070813221847.GA20314@Krystal>
References: <20070708034952.022985379@sgi.com> <p73y7hrywel.fsf@bingen.suse.de> <Pine.LNX.4.64.0707090845520.13792@schroedinger.engr.sgi.com> <46925B5D.8000507@google.com> <Pine.LNX.4.64.0707091055090.16207@schroedinger.engr.sgi.com> <4692A1D0.50308@mbligh.org> <20070709214426.GC1026@Krystal> <Pine.LNX.4.64.0707091451200.18780@schroedinger.engr.sgi.com> <20070709225817.GA5111@Krystal> <Pine.LNX.4.64.0707091715450.2062@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0707091715450.2062@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Martin Bligh <mbligh@mbligh.org>, Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

Some review here. I think we could do much better..

* Christoph Lameter (clameter@sgi.com) wrote:
 
> Index: linux-2.6.22-rc6-mm1/mm/slub.c
> ===================================================================
> --- linux-2.6.22-rc6-mm1.orig/mm/slub.c	2007-07-09 15:04:46.000000000 -0700
> +++ linux-2.6.22-rc6-mm1/mm/slub.c	2007-07-09 17:09:00.000000000 -0700
> @@ -1467,12 +1467,14 @@ static void *__slab_alloc(struct kmem_ca
>  {
>  	void **object;
>  	struct page *new;
> +	unsigned long flags;
>  
> +	local_irq_save(flags);
>  	if (!c->page)
>  		goto new_slab;
>  
>  	slab_lock(c->page);
> -	if (unlikely(!node_match(c, node)))
> +	if (unlikely(!node_match(c, node) || c->freelist))
>  		goto another_slab;
>  load_freelist:
>  	object = c->page->freelist;
> @@ -1486,7 +1488,14 @@ load_freelist:
>  	c->page->inuse = s->objects;
>  	c->page->freelist = NULL;
>  	c->node = page_to_nid(c->page);
> +out:
>  	slab_unlock(c->page);
> +	local_irq_restore(flags);
> +	preempt_enable();
> +
> +	if (unlikely((gfpflags & __GFP_ZERO)))
> +		memset(object, 0, c->objsize);
> +
>  	return object;
>  
>  another_slab:
> @@ -1527,6 +1536,8 @@ new_slab:
>  		c->page = new;
>  		goto load_freelist;
>  	}
> +	local_irq_restore(flags);
> +	preempt_enable();
>  	return NULL;
>  debug:
>  	c->freelist = NULL;
> @@ -1536,8 +1547,7 @@ debug:
>  
>  	c->page->inuse++;
>  	c->page->freelist = object[c->offset];
> -	slab_unlock(c->page);
> -	return object;
> +	goto out;
>  }
>  
>  /*
> @@ -1554,23 +1564,20 @@ static void __always_inline *slab_alloc(
>  		gfp_t gfpflags, int node, void *addr)
>  {
>  	void **object;
> -	unsigned long flags;
>  	struct kmem_cache_cpu *c;
>  

What if we prefetch c->freelist here ? I see in this diff that the other
code just reads it sooner as a condition for the if().

> -	local_irq_save(flags);
> +	preempt_disable();
>  	c = get_cpu_slab(s, smp_processor_id());
> -	if (unlikely(!c->page || !c->freelist ||
> -					!node_match(c, node)))
> +redo:
> +	object = c->freelist;
> +	if (unlikely(!object || !node_match(c, node)))
> +		return __slab_alloc(s, gfpflags, node, addr, c);
>  
> -		object = __slab_alloc(s, gfpflags, node, addr, c);
> +	if (cmpxchg_local(&c->freelist, object, object[c->offset]) != object)
> +		goto redo;
>  
> -	else {
> -		object = c->freelist;
> -		c->freelist = object[c->offset];
> -	}
> -	local_irq_restore(flags);
> -
> -	if (unlikely((gfpflags & __GFP_ZERO) && object))
> +	preempt_enable();
> +	if (unlikely((gfpflags & __GFP_ZERO)))
>  		memset(object, 0, c->objsize);
>  
>  	return object;
> @@ -1603,7 +1610,9 @@ static void __slab_free(struct kmem_cach
>  {
>  	void *prior;
>  	void **object = (void *)x;
> +	unsigned long flags;
>  
> +	local_irq_save(flags);
>  	slab_lock(page);
>  
>  	if (unlikely(SlabDebug(page)))
> @@ -1629,6 +1638,8 @@ checks_ok:
>  
>  out_unlock:
>  	slab_unlock(page);
> +	local_irq_restore(flags);
> +	preempt_enable();
>  	return;
>  
>  slab_empty:
> @@ -1639,6 +1650,8 @@ slab_empty:
>  		remove_partial(s, page);
>  
>  	slab_unlock(page);
> +	local_irq_restore(flags);
> +	preempt_enable();
>  	discard_slab(s, page);
>  	return;
>  
> @@ -1663,18 +1676,31 @@ static void __always_inline slab_free(st
>  			struct page *page, void *x, void *addr)
>  {
>  	void **object = (void *)x;
> -	unsigned long flags;
>  	struct kmem_cache_cpu *c;
> +	void **freelist;
>  

Prefetching c->freelist would also make sense here.

> -	local_irq_save(flags);
> +	preempt_disable();
>  	c = get_cpu_slab(s, smp_processor_id());
> -	if (likely(page == c->page && c->freelist)) {
> -		object[c->offset] = c->freelist;
> -		c->freelist = object;
> -	} else
> -		__slab_free(s, page, x, addr, c->offset);
> +redo:
> +	freelist = c->freelist;

I suspect this smp_rmb() may be the cause of a major slowdown.
Therefore, I think we should try taking a copy of c->page and simply
check if it has changed right after the cmpxchg_local:

  page = c->page;

> +	/*
> +	 * Must read freelist before c->page. If a interrupt occurs and
> +	 * changes c->page after we have read it here then it
> +	 * will also have changed c->freelist and the cmpxchg will fail.
> +	 *
> +	 * If we would have checked c->page first then the freelist could
> +	 * have been changed under us before we read c->freelist and we
> +	 * would not be able to detect that situation.
> +	 */
> +	smp_rmb();
> +	if (unlikely(page != c->page || !freelist))
> +		return __slab_free(s, page, x, addr, c->offset);
> +
> +	object[c->offset] = freelist;
-> +	if (cmpxchg_local(&c->freelist, freelist, object) != freelist)
+> +	if (cmpxchg_local(&c->freelist, freelist, object) != freelist
        || page != c->page)
> +		goto redo;
>  

Therefore, in the scenario where:
1 - c->page is read
2 - Interrupt comes, changes c->page and c->freelist
3 - c->freelist is read
4 - cmpxchg c->freelist succeeds
5 - Then, page != c->page, so we goto redo.

It also works if 4 and 5 are swapped.

I could test the modification if you point to me which kernel version it
should apply to. However, I don't have the same hardware you use.

By the way, the smp_rmb() barrier does not make sense with the comment.
If it is _really_ protecting against reordering wrt interrupts, then it
should be a rmb(), not smp_rmb() (because it will be reordered on UP).
But I think the best would just be to work without rmb() at all, as
proposed here.

Mathieu

> -	local_irq_restore(flags);
> +	preempt_enable();
>  }
>  
>  void kmem_cache_free(struct kmem_cache *s, void *x)
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

-- 
Mathieu Desnoyers
Computer Engineering Ph.D. Student, Ecole Polytechnique de Montreal
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
