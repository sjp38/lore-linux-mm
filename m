Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 912AB6B0387
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 15:55:45 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id x63so27470721pfx.7
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 12:55:45 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id u86si8427260pfj.197.2017.03.02.12.55.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Mar 2017 12:55:44 -0800 (PST)
Date: Thu, 2 Mar 2017 12:55:40 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [LSF/MM TOPIC] Movable memory and reliable higher order
 allocations
Message-ID: <20170302205540.GQ16328@bombadil.infradead.org>
References: <alpine.DEB.2.20.1702281526170.31946@east.gentwo.org>
 <20170228231733.GI16328@bombadil.infradead.org>
 <20170302041238.GM16328@bombadil.infradead.org>
 <alpine.DEB.2.20.1703021111350.31249@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1703021111350.31249@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, Jesper Dangaard Brouer <brouer@redhat.com>, riel@redhat.com, Mel Gorman <mel@csn.ul.ie>

On Thu, Mar 02, 2017 at 11:26:39AM -0600, Christoph Lameter wrote:
> On Wed, 1 Mar 2017, Matthew Wilcox wrote:
> 
> > Let me know whether the assumptions I listed above xa_reclaim() are
> > reasonable ... also, do you want me returning a bool to indicate whether
> > I freed the node, or is that not useful because you'll know that anyway?
> 
> The way that the slab logic works is in two phases:

We may need to negotiate the API a little ;-)

> 1. Callback
> 
> void *defrag_get_func(struct kmem_cache *s, int nr, void **objects)

OK, so you're passing me an array of pointers of length 'nr'?
It's conventional to put 'objects' before 'nr' -- see release_pages()
and vm_map_ram()

> Locks are held. Interrupts are disabled. No slab operations may be
> performed and any operations on the slab page will cause that the
> concurrent access to block.
> 
> The callback must establish a stable reference to the slab objects.
> Meaning generally a additional refcount is added so that any free
> operations will not remove the object. This is required in order to ensure
> that free operations will not interfere with reclaim processing.

I don't currently have a way to do that.  There is a refcount on the node,
but if somebody does an operation which causes the node to be removed
from the tree (something like splatting a huge page over the top of it),
we ignore the refcount and free the node.  However, since it's been in
the tree, we pass it to RCU to free, so if you hold the RCU read lock in
addition to your other locks, the xarray can satisfy your requirements
that the object not be handed back to slab.

That takes care of nodes currently in the tree and nodes handed to RCU.
It doesn't take care of nodes which have been recently allocated and
not yet inserted into the tree.  I've got no way of freeing them, nor
of preventing them from being freed.

> The get() will return a pointer to a private data structure that is passed
> on to the second function. Before that callback the slab allocator will
> drop all the locks. If the function returns NULL then that is an
> indication that the objects are in use and that a reclaim operation cannot
> be performed. No refcount has been taken.

I don't think I have a useful private data structure that I can create.
I assume returning (void *)1 will be acceptable.

> This is required to have a stable array of objects to work on. If the
> objects could be freed at any time then the objects could not be inspected
> for state nor could an array of pointers to the objects be passed on for
> future processing.

If I can free some, but not all of the objects, is that worth doing,
or should I return NULL here?

> 2. Callback
> 
> defrag_reclaim_func(struct kmem_cache *s, int nr, void **objects, void *private)

You missed the return type here ... assuming it's void.

> Here anything may be done. Free the objects or reallocate them (calling
> kmalloc or so to allocate another object to move it to). On return the
> slab allocator will inspect the slab page and if there are no objects
> remaining then the slab page will be freed.

I have to reallocate; I have no way of knowing what my user is using
the xarray for, so I can't throw away nodes.

> During proccesing the slab page is exempt from allocation and thus objects
> can only be removed from the slab page until processing is complete.

That's great for me.

> > +/*
> > + * We rely on the following assumptions:
> > + *  - The slab allocator calls us in process context with IRQs enabled and
> > + *    no locks held (not even the RCU lock)
> 
> This is true for the second callback.
> 
> > + *  - We can allocate a replacement using GFP_KERNEL
> > + *  - If the victim is freed while reclaim is running,
> > + *    - The slab allocator will not overwrite any fields in the victim
> > + *    - The page will not be returned to the page allocator until we return
> > + *    - The victim will not be reallocated until we return
> 
> The viction cannot be freed during processing since the first callback
> established a reference. The callback must free the object if possible and
> drop the reference count.

Most of the frees are going to be coming via call_rcu().  I think that
actually satisfies your requirements.

> > + */
> > +static bool xa_reclaim(void *arg)
> 
> Ok lets assume that this is the second callback.

Yes, it at least approximates your second callback.

> > +{
> > +	struct xa_node *node, *victim = arg;
> > +	struct xarray *xa = READ_ONCE(victim->array);
> > +	void __rcu **slot;
> > +	unsigned int i;
> > +
> > +	/* Node has been allocated, but not yet placed in a tree. */
> > +	if (!xa)
> > +		return false;
> > +	/* If the node has already been freed, we only need to wait for RCU */
> > +	if (xa == XA_RCU_FREE)
> > +		goto out;
> 
> Hmmm... We really need a refcount here.
> 
> > +	node = kmem_cache_alloc(xa_node_cache, GFP_KERNEL);
> > +
> > +	xa_lock_irq(xa);
> 
> The lock may be held for the set of objects being processed.

The objects may well be in different xarrays, so I can't hold the lock
across the entire collection of objects you're asking to free.

I understand your desire to batch up all the objects on a page and ask
the reclaimer to free them all, but is the additional complexity worth
the performance gains you're expecting to see?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
