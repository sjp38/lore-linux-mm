Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id 50F726B0035
	for <linux-mm@kvack.org>; Wed, 20 Aug 2014 08:20:06 -0400 (EDT)
Received: by mail-ig0-f170.google.com with SMTP id h3so11056741igd.5
        for <linux-mm@kvack.org>; Wed, 20 Aug 2014 05:20:06 -0700 (PDT)
Received: from e34.co.us.ibm.com (e34.co.us.ibm.com. [32.97.110.152])
        by mx.google.com with ESMTPS id gj19si26740295icb.4.2014.08.20.05.20.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 20 Aug 2014 05:20:05 -0700 (PDT)
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 20 Aug 2014 06:20:04 -0600
Received: from b03cxnp07029.gho.boulder.ibm.com (b03cxnp07029.gho.boulder.ibm.com [9.17.130.16])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id DA71319D803F
	for <linux-mm@kvack.org>; Wed, 20 Aug 2014 06:19:50 -0600 (MDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp07029.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id s7KAG8Zd9699660
	for <linux-mm@kvack.org>; Wed, 20 Aug 2014 12:16:08 +0200
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id s7KCOLrw019643
	for <linux-mm@kvack.org>; Wed, 20 Aug 2014 06:24:21 -0600
Date: Wed, 20 Aug 2014 05:19:59 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: slub/debugobjects: lockup when freeing memory
Message-ID: <20140820121959.GT4752@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <alpine.DEB.2.11.1406191001090.2785@gentwo.org>
 <20140619165247.GA4904@linux.vnet.ibm.com>
 <alpine.DEB.2.10.1406192127100.5170@nanos>
 <alpine.DEB.2.11.1406191519090.4002@gentwo.org>
 <20140818163757.GA30742@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1408182147400.28727@gentwo.org>
 <20140819035828.GI4752@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1408192057200.32428@gentwo.org>
 <20140820023121.GS4752@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1408200059260.2810@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1408200059260.2810@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Sasha Levin <sasha.levin@oracle.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Aug 20, 2014 at 01:01:19AM -0500, Christoph Lameter wrote:
> On Tue, 19 Aug 2014, Paul E. McKenney wrote:
> 
> > > We could also remove the #ifdefs if init_rcu_head and destroy_rcu_head
> > > are no ops if CONFIG_DEBUG_RCU_HEAD is not defined.
> >
> > And indeed they are, good point!  It appears to me that both sets of
> > #ifdefs can go away.
> 
> Ok then this is a first workable version I think. How do we test this?

It looks good to me.

Sasha, could you please try this out?  This should fix the problem
you reported here:  https://lkml.org/lkml/2014/6/19/306

							Thanx, Paul

> From: Christoph Lameter <cl@linux.com>
> Subject: slub: Add init/destroy function calls for rcu_heads
> 
> In order to do proper debugging for rcu_head use we need some
> additional structures allocated when an object potentially
> using a rcu_head is allocated in the slub allocator.
> 
> This adds the proper calls to init_rcu_head()
> and destroy_rcu_head().
> 
> init_rcu_head() is a bit of an unusual function since:
> 1. It does not touch the contents of the rcu_head. This is
>    required since the rcu_head is only used during
>    slab_page freeing. Outside of that the same memory location
>    is used for slab page list management. However, the
>    initialization occurs when the slab page is initially allocated.
>    So in the time between init_rcu_head() and destroy_rcu_head()
>    there may be multiple uses of the indicated address as a
>    list_head.
> 
> 2. It is called without gfp flags and could potentially
>    be called from atomic contexts. Allocations from init_rcu_head()
>    context need to deal with this.
> 
> 3. init_rcu_head() is called from within the slab allocation
>    functions. Since init_rcu_head() calls the allocator again
>    for more allocations it must avoid to use slabs that use
>    rcu freeing. Otherwise endless recursion may occur
>    (We may have to convince lockdep that what we do here is sane).
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>
> 
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
> @@ -1357,6 +1376,29 @@ static struct page *allocate_slab(struct
>  			kmemcheck_mark_unallocated_pages(page, pages);
>  	}
> 
> +	if (unlikely(s->flags & SLAB_DESTROY_BY_RCU) && page)
> +		/*
> +		 * Initialize various things. However, this init is
> +	 	 * not allowed to modify the contents of the rcu head.
> +		 * The allocator typically overloads the rcu head over
> +		 * page->lru which is also used to manage lists of
> +		 * slab pages.
> +		 *
> +		 * Allocations are permitted in init_rcu_head().
> +		 * However, the use of the same cache or another
> +		 * cache with SLAB_DESTROY_BY_RCU set will cause
> +		 * additional recursions.
> +		 *
> +		 * So in order to be safe the slab caches used
> +		 * in init_rcu_head() should be restricted to be of the
> +		 * non rcu kind only.
> +		 *
> +		 * Note also that no GFPFLAG is passed. The function
> +		 * may therefore be called from atomic contexts
> +		 * and somehow(?) needs to do the right thing.
> +		 */
> +		init_rcu_head(get_rcu_head(s, page));
> +
>  	if (flags & __GFP_WAIT)
>  		local_irq_disable();
>  	if (!page)
> @@ -1452,13 +1494,11 @@ static void __free_slab(struct kmem_cach
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
> +	destroy_rcu_head(h);
>  	if (need_reserve_slab_rcu)
>  		page = virt_to_head_page(h);
>  	else
> @@ -1469,24 +1509,9 @@ static void rcu_free_slab(struct rcu_hea
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
