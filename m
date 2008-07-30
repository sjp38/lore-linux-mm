Subject: Re: [PATCH 06/30] mm: kmem_alloc_estimate()
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <1217420503.7813.170.camel@penberg-laptop>
References: <20080724140042.408642539@chello.nl>
	 <20080724141529.716339226@chello.nl>
	 <1217420503.7813.170.camel@penberg-laptop>
Content-Type: text/plain
Date: Wed, 30 Jul 2008 15:31:02 +0200
Message-Id: <1217424662.8157.58.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, Daniel Lezcano <dlezcano@fr.ibm.com>, Neil Brown <neilb@suse.de>, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Wed, 2008-07-30 at 15:21 +0300, Pekka Enberg wrote:
> Hi Peter,
> 
> On Thu, 2008-07-24 at 16:00 +0200, Peter Zijlstra wrote:

> Just a nitpick, but:
> 
> > +unsigned kmalloc_estimate_fixed(size_t, gfp_t, int);
> 
> kmalloc_estimate_objs()?
> 
> > +unsigned kmalloc_estimate_variable(gfp_t, size_t);
> 
> kmalloc_estimate_bytes()?

Sounds good, I'll do some sed magic on the patch-set to make it happen.

> >  
> >  /*
> >   * Allocator specific definitions. These are mainly used to establish optimized
> > Index: linux-2.6/mm/slub.c
> > ===================================================================
> > --- linux-2.6.orig/mm/slub.c
> > +++ linux-2.6/mm/slub.c
> > @@ -2412,6 +2412,42 @@ const char *kmem_cache_name(struct kmem_
> >  }
> >  EXPORT_SYMBOL(kmem_cache_name);
> >  
> > +/*
> > + * Calculate the upper bound of pages required to sequentially allocate
> > + * @objects objects from @cachep.
> > + *
> > + * We should use s->min_objects because those are the least efficient.
> > + */
> > +unsigned kmem_alloc_estimate(struct kmem_cache *s, gfp_t flags, int objects)
> > +{
> > +	unsigned long pages;
> > +	struct kmem_cache_order_objects x;
> > +
> > +	if (WARN_ON(!s) || WARN_ON(!oo_objects(s->min)))
> > +		return 0;
> > +
> > +	x = s->min;
> > +	pages = DIV_ROUND_UP(objects, oo_objects(x)) << oo_order(x);
> > +
> > +	/*
> > +	 * Account the possible additional overhead if the slab holds more that
> > +	 * one object. Use s->max_objects because that's the worst case.
> > +	 */
> > +	x = s->oo;
> > +	if (oo_objects(x) > 1) {
> 
> Hmm, I'm not sure why slab with just one object is treated separately
> here. Surely you have per-CPU slabs then as well?

The thought was that if the slab only contains 1 obj, then the per-cpu
slabs are always full (or empty but already there), so you don't loose
memory to other cpu's having half-filled slabs.

Say you want to reserve memory for 10 object.

In the 1 object per slab case, you will always allocate a slab, no
matter what cpu you do the allocation on.

With say, 16 objects per slab and allocations spread across 2 cpus, you
have to allow for per-cpu slabs to be half-filled.

> > +		/*
> > +		 * Account the possible additional overhead if per cpu slabs
> > +		 * are currently empty and have to be allocated. This is very
> > +		 * unlikely but a possible scenario immediately after
> > +		 * kmem_cache_shrink.
> > +		 */
> > +		pages += num_online_cpus() << oo_order(x);
> 
> Isn't this problematic with CPU hotplug? Shouldn't we use
> num_possible_cpus() here?

ACK, thanks!

> > +/*
> > + * Calculate the upper bound of pages requires to sequentially allocate @bytes
> > + * from kmalloc in an unspecified number of allocations of nonuniform size.
> > + */
> > +unsigned kmalloc_estimate_variable(gfp_t flags, size_t bytes)
> > +{
> > +	int i;
> > +	unsigned long pages;
> > +
> > +	/*
> > +	 * multiply by two, in order to account the worst case slack space
> > +	 * due to the power-of-two allocation sizes.
> > +	 */
> > +	pages = DIV_ROUND_UP(2 * bytes, PAGE_SIZE);
> 
> For bytes > PAGE_SIZE this doesn't look right (for SLUB). We do page
> allocator pass-through which means that we'll be grabbing high order
> pages which can be bigger than what 'pages' is here.

Hehe - you actually made me think here.

Satisfying allocations from a bucket distribution with power-of-two
(which page alloc order satisfies) has a worst case slack space of:

S(x) = 2^n - (2^(n-1)) - 1, n = ceil(log2(x))

This can be seen for the cases where x = 2^i + 1.

If we approximate S(x) by 2^(n-1) and compute the slack ratio for any
given x:

 R(x) ~ 2^n / 2^(n-1) = 2

We'll see that for any amount of x, we can only use half that due to
slack space.

Therefore, by multiplying the demand @bytes by 2 we'll always have
enough to cover the worst case slack considering the power-of-two
allocation buckets.

In example, if @bytes asks for 4 pages + 1 byte = 16385 bytes (assuming
4k pages), then the above will request 8 pages + 2 bytes, rounded up to
pages, is 9 pages. Which is enough to satisfy the order 3 allocation
needed for the 8 contiguous pages to store the requested 16385 bytes.

> > Index: linux-2.6/mm/slab.c
> > ===================================================================
> > --- linux-2.6.orig/mm/slab.c
> > +++ linux-2.6/mm/slab.c
> > @@ -3854,6 +3854,81 @@ const char *kmem_cache_name(struct kmem_
> >  EXPORT_SYMBOL_GPL(kmem_cache_name);
> >  
> >  /*
> > + * Calculate the upper bound of pages required to sequentially allocate
> > + * @objects objects from @cachep.
> > + */
> > +unsigned kmem_alloc_estimate(struct kmem_cache *cachep,
> > +		gfp_t flags, int objects)
> > +{
> > +	/*
> > +	 * (1) memory for objects,
> > +	 */
> > +	unsigned nr_slabs = DIV_ROUND_UP(objects, cachep->num);
> > +	unsigned nr_pages = nr_slabs << cachep->gfporder;
> > +
> > +	/*
> > +	 * (2) memory for each per-cpu queue (nr_cpu_ids),
> > +	 * (3) memory for each per-node alien queues (nr_cpu_ids), and
> > +	 * (4) some amount of memory for the slab management structures
> > +	 *
> > +	 * XXX: truely account these
> 
> Heh, yes please. Or add a comment why it doesn't matter.

Since you were the one I cribbed that comment from some (long) time ago,
can you advise on how well the below approximation is to an upper bound
on the above factors - assuming SLAB will live long enough to make it
worth the effort?

> > +	 */
> > +	nr_pages += 1 + ilog2(nr_pages);
> > +
> > +	return nr_pages;
> > +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
