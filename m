Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 284B06B0038
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 10:24:38 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id n141so20211860qke.1
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 07:24:38 -0800 (PST)
Received: from resqmta-ch2-10v.sys.comcast.net (resqmta-ch2-10v.sys.comcast.net. [2001:558:fe21:29:69:252:207:42])
        by mx.google.com with ESMTPS id w135si9547695qkw.88.2017.03.03.07.24.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Mar 2017 07:24:36 -0800 (PST)
Date: Fri, 3 Mar 2017 09:24:23 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [LSF/MM TOPIC] Movable memory and reliable higher order
 allocations
In-Reply-To: <20170302205540.GQ16328@bombadil.infradead.org>
Message-ID: <alpine.DEB.2.20.1703030915170.16721@east.gentwo.org>
References: <alpine.DEB.2.20.1702281526170.31946@east.gentwo.org> <20170228231733.GI16328@bombadil.infradead.org> <20170302041238.GM16328@bombadil.infradead.org> <alpine.DEB.2.20.1703021111350.31249@east.gentwo.org>
 <20170302205540.GQ16328@bombadil.infradead.org>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, Jesper Dangaard Brouer <brouer@redhat.com>, riel@redhat.com, Mel Gorman <mel@csn.ul.ie>



> We may need to negotiate the API a little ;-)

Well lets continue the fun then.

>
> > 1. Callback
> >
> > void *defrag_get_func(struct kmem_cache *s, int nr, void **objects)
>
> OK, so you're passing me an array of pointers of length 'nr'?
> It's conventional to put 'objects' before 'nr' -- see release_pages()
> and vm_map_ram()

Ok.

> > Locks are held. Interrupts are disabled. No slab operations may be
> > performed and any operations on the slab page will cause that the
> > concurrent access to block.
> >
> > The callback must establish a stable reference to the slab objects.
> > Meaning generally a additional refcount is added so that any free
> > operations will not remove the object. This is required in order to ensure
> > that free operations will not interfere with reclaim processing.
>
> I don't currently have a way to do that.  There is a refcount on the node,
> but if somebody does an operation which causes the node to be removed
> from the tree (something like splatting a huge page over the top of it),
> we ignore the refcount and free the node.  However, since it's been in
> the tree, we pass it to RCU to free, so if you hold the RCU read lock in
> addition to your other locks, the xarray can satisfy your requirements
> that the object not be handed back to slab.

We need a general solution here. Objects having a refcount is the common
way to provide an existence guarantee. Holding rcu_locks in a
function that performs slab operations or lenghty object inspection
calling a variety of VM operations is not advisable.

> That takes care of nodes currently in the tree and nodes handed to RCU.
> It doesn't take care of nodes which have been recently allocated and
> not yet inserted into the tree.  I've got no way of freeing them, nor
> of preventing them from being freed.

The function can fail if you encounter such objects. You do not have to
free any objects that are currently busy.

> > The get() will return a pointer to a private data structure that is passed
> > on to the second function. Before that callback the slab allocator will
> > drop all the locks. If the function returns NULL then that is an
> > indication that the objects are in use and that a reclaim operation cannot
> > be performed. No refcount has been taken.
>
> I don't think I have a useful private data structure that I can create.
> I assume returning (void *)1 will be acceptable.

Yep.

> > This is required to have a stable array of objects to work on. If the
> > objects could be freed at any time then the objects could not be inspected
> > for state nor could an array of pointers to the objects be passed on for
> > future processing.
>
> If I can free some, but not all of the objects, is that worth doing,
> or should I return NULL here?

The objects are all objects from the same slab page. If you cannot free
one then the whole slab page must remain. It it advantageous to not free
objects. The slab can then be used for more allocations and filled up
again.

> > 2. Callback
> >
> > defrag_reclaim_func(struct kmem_cache *s, int nr, void **objects, void *private)
>
> You missed the return type here ... assuming it's void.

Yes.

> > Here anything may be done. Free the objects or reallocate them (calling
> > kmalloc or so to allocate another object to move it to). On return the
> > slab allocator will inspect the slab page and if there are no objects
> > remaining then the slab page will be freed.
>
> I have to reallocate; I have no way of knowing what my user is using
> the xarray for, so I can't throw away nodes.

That is fine.

> > During proccesing the slab page is exempt from allocation and thus objects
> > can only be removed from the slab page until processing is complete.
>
> That's great for me.

Allright.

> > > +/*
> > > + * We rely on the following assumptions:
> > > + *  - The slab allocator calls us in process context with IRQs enabled and
> > > + *    no locks held (not even the RCU lock)
> >
> > This is true for the second callback.
> >
> > > + *  - We can allocate a replacement using GFP_KERNEL
> > > + *  - If the victim is freed while reclaim is running,
> > > + *    - The slab allocator will not overwrite any fields in the victim
> > > + *    - The page will not be returned to the page allocator until we return
> > > + *    - The victim will not be reallocated until we return
> >
> > The viction cannot be freed during processing since the first callback
> > established a reference. The callback must free the object if possible and
> > drop the reference count.
>
> Most of the frees are going to be coming via call_rcu().  I think that
> actually satisfies your requirements.

I doubt that we can hold the rcu locks for the entirety of the processing.
There are other slab caches that also need to use this (dentry and inodes)
and all of those are refcount based.

> The objects may well be in different xarrays, so I can't hold the lock
> across the entire collection of objects you're asking to free.
>
> I understand your desire to batch up all the objects on a page and ask
> the reclaimer to free them all, but is the additional complexity worth
> the performance gains you're expecting to see?

Depends on the number of objects in a slab page. I think for starters we
can avoid the complexity and just process one by one. However, a slab page
has a number of allocated objects and the slab functions are geared to
process them together since the slab page containing them needs to be
exempted from allocations, locked etc etc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
