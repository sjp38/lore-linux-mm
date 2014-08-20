Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id E4F106B0035
	for <linux-mm@kvack.org>; Tue, 19 Aug 2014 22:31:28 -0400 (EDT)
Received: by mail-ig0-f169.google.com with SMTP id r2so10568972igi.4
        for <linux-mm@kvack.org>; Tue, 19 Aug 2014 19:31:28 -0700 (PDT)
Received: from e33.co.us.ibm.com (e33.co.us.ibm.com. [32.97.110.151])
        by mx.google.com with ESMTPS id i12si1261758igt.5.2014.08.19.19.31.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 19 Aug 2014 19:31:28 -0700 (PDT)
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Tue, 19 Aug 2014 20:31:27 -0600
Received: from b03cxnp07029.gho.boulder.ibm.com (b03cxnp07029.gho.boulder.ibm.com [9.17.130.16])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 0523B3E4004E
	for <linux-mm@kvack.org>; Tue, 19 Aug 2014 20:31:24 -0600 (MDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp07029.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id s7K0RUux6029676
	for <linux-mm@kvack.org>; Wed, 20 Aug 2014 02:27:30 +0200
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id s7K2Zg1A007900
	for <linux-mm@kvack.org>; Tue, 19 Aug 2014 20:35:43 -0600
Date: Tue, 19 Aug 2014 19:31:21 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: slub/debugobjects: lockup when freeing memory
Message-ID: <20140820023121.GS4752@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <53A2F406.4010109@oracle.com>
 <alpine.DEB.2.11.1406191001090.2785@gentwo.org>
 <20140619165247.GA4904@linux.vnet.ibm.com>
 <alpine.DEB.2.10.1406192127100.5170@nanos>
 <alpine.DEB.2.11.1406191519090.4002@gentwo.org>
 <20140818163757.GA30742@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1408182147400.28727@gentwo.org>
 <20140819035828.GI4752@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1408192057200.32428@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1408192057200.32428@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Sasha Levin <sasha.levin@oracle.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Aug 19, 2014 at 09:00:05PM -0500, Christoph Lameter wrote:
> On Mon, 18 Aug 2014, Paul E. McKenney wrote:
> 
> > > +#ifdef CONFIG_RCU_DEBUG_XYZ
> >
> > If you make CONFIG_RCU_DEBUG_XYZ instead be CONFIG_DEBUG_OBJECTS_RCU_HEAD,
> > then it will automatically show up when it needs to.
> 
> Ok.
> 
> > The rest looks plausible, for whatever that is worth.
> 
> We talked in the hallway about init_rcu_head not touching
> the contents of the rcu_head. If that is the case then we can simplify
> the patch.

That is correct -- the debug-objects code uses separate storage to track
states, and does not touch the memory to which the state applies.

> We could also remove the #ifdefs if init_rcu_head and destroy_rcu_head
> are no ops if CONFIG_DEBUG_RCU_HEAD is not defined.

And indeed they are, good point!  It appears to me that both sets of
#ifdefs can go away.

							Thanx, Paul

> Index: linux/mm/slub.c
> ===================================================================
> --- linux.orig/mm/slub.c
> +++ linux/mm/slub.c
> @@ -1308,6 +1308,25 @@ static inline struct page *alloc_slab_pa
>  	return page;
>  }
> 
> +#define need_reserve_slab_rcu						\
> +	(sizeof(((struct page *)NULL)->lru) < sizeof(struct rcu_head))
> +
> +static struct rcu_head *get_rcu_head(struct kmem_cache *s, struct page *page)
> +{
> +	if (need_reserve_slab_rcu) {
> +		int order = compound_order(page);
> +		int offset = (PAGE_SIZE << order) - s->reserved;
> +
> +		VM_BUG_ON(s->reserved != sizeof(struct rcu_head));
> +		return page_address(page) + offset;
> +	} else {
> +		/*
> +		 * RCU free overloads the RCU head over the LRU
> +		 */
> +		return (void *)&page->lru;
> +	}
> +}
> +
>  static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
>  {
>  	struct page *page;
> @@ -1357,6 +1376,22 @@ static struct page *allocate_slab(struct
>  			kmemcheck_mark_unallocated_pages(page, pages);
>  	}
> 
> +#ifdef CONFIG_DEBUG_OBJECTS_RCU_HEAD
> +	if (unlikely(s->flags & SLAB_DESTROY_BY_RCU) && page)
> +		/*
> +		 * Initialize various things. However, this init is
> +	 	 * not allowed to modify the contents of the rcu head.
> +		 * Allocations are permitted. However, the use of
> +		 * the same cache or another cache with SLAB_RCU_DESTROY
> +		 * set may cause additional recursions.
> +		 *
> +		 * So in order to be safe the slab caches used
> +		 * in init_rcu_head should be restricted to be of the
> +		 * non rcu kind only.
> +		 */
> +		init_rcu_head(get_rcu_head(s, page));
> +#endif
> +
>  	if (flags & __GFP_WAIT)
>  		local_irq_disable();
>  	if (!page)
> @@ -1452,13 +1487,13 @@ static void __free_slab(struct kmem_cach
>  	memcg_uncharge_slab(s, order);
>  }
> 
> -#define need_reserve_slab_rcu						\
> -	(sizeof(((struct page *)NULL)->lru) < sizeof(struct rcu_head))
> -
>  static void rcu_free_slab(struct rcu_head *h)
>  {
>  	struct page *page;
> 
> +#ifdef CONFIG_DEBUG_OBJECTS_RCU_HEAD
> +	destroy_rcu_head(h);
> +#endif
>  	if (need_reserve_slab_rcu)
>  		page = virt_to_head_page(h);
>  	else
> @@ -1469,24 +1504,9 @@ static void rcu_free_slab(struct rcu_hea
> 
>  static void free_slab(struct kmem_cache *s, struct page *page)
>  {
> -	if (unlikely(s->flags & SLAB_DESTROY_BY_RCU)) {
> -		struct rcu_head *head;
> -
> -		if (need_reserve_slab_rcu) {
> -			int order = compound_order(page);
> -			int offset = (PAGE_SIZE << order) - s->reserved;
> -
> -			VM_BUG_ON(s->reserved != sizeof(*head));
> -			head = page_address(page) + offset;
> -		} else {
> -			/*
> -			 * RCU free overloads the RCU head over the LRU
> -			 */
> -			head = (void *)&page->lru;
> -		}
> -
> -		call_rcu(head, rcu_free_slab);
> -	} else
> +	if (unlikely(s->flags & SLAB_DESTROY_BY_RCU))
> +		call_rcu(get_rcu_head(s, page), rcu_free_slab);
> +	else
>  		__free_slab(s, page);
>  }
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
