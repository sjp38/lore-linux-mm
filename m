Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 44C236B0387
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 12:26:43 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id n76so77271503ioe.1
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 09:26:43 -0800 (PST)
Received: from resqmta-ch2-06v.sys.comcast.net (resqmta-ch2-06v.sys.comcast.net. [2001:558:fe21:29:69:252:207:38])
        by mx.google.com with ESMTPS id c77si9621482itc.15.2017.03.02.09.26.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Mar 2017 09:26:42 -0800 (PST)
Date: Thu, 2 Mar 2017 11:26:39 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [LSF/MM TOPIC] Movable memory and reliable higher order
 allocations
In-Reply-To: <20170302041238.GM16328@bombadil.infradead.org>
Message-ID: <alpine.DEB.2.20.1703021111350.31249@east.gentwo.org>
References: <alpine.DEB.2.20.1702281526170.31946@east.gentwo.org> <20170228231733.GI16328@bombadil.infradead.org> <20170302041238.GM16328@bombadil.infradead.org>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, Jesper Dangaard Brouer <brouer@redhat.com>, riel@redhat.com, Mel Gorman <mel@csn.ul.ie>

On Wed, 1 Mar 2017, Matthew Wilcox wrote:

> Let me know whether the assumptions I listed above xa_reclaim() are
> reasonable ... also, do you want me returning a bool to indicate whether
> I freed the node, or is that not useful because you'll know that anyway?

The way that the slab logic works is in two phases:

1. Callback

void *defrag_get_func(struct kmem_cache *s, int nr, void **objects)

Locks are held. Interrupts are disabled. No slab operations may be
performed and any operations on the slab page will cause that the
concurrent access to block.

The callback must establish a stable reference to the slab objects.
Meaning generally a additional refcount is added so that any free
operations will not remove the object. This is required in order to ensure
that free operations will not interfere with reclaim processing.

The get() will return a pointer to a private data structure that is passed
on to the second function. Before that callback the slab allocator will
drop all the locks. If the function returns NULL then that is an
indication that the objects are in use and that a reclaim operation cannot
be performed. No refcount has been taken.

This is required to have a stable array of objects to work on. If the
objects could be freed at any time then the objects could not be inspected
for state nor could an array of pointers to the objects be passed on for
future processing.

2. Callback

defrag_reclaim_func(struct kmem_cache *s, int nr, void **objects, void *private)

Here anything may be done. Free the objects or reallocate them (calling
kmalloc or so to allocate another object to move it to). On return the
slab allocator will inspect the slab page and if there are no objects
remaining then the slab page will be freed.

During proccesing the slab page is exempt from allocation and thus objects
can only be removed from the slab page until processing is complete.


> +/*
> + * We rely on the following assumptions:
> + *  - The slab allocator calls us in process context with IRQs enabled and
> + *    no locks held (not even the RCU lock)

This is true for the second callback.

> + *  - We can allocate a replacement using GFP_KERNEL
> + *  - If the victim is freed while reclaim is running,
> + *    - The slab allocator will not overwrite any fields in the victim
> + *    - The page will not be returned to the page allocator until we return
> + *    - The victim will not be reallocated until we return

The viction cannot be freed during processing since the first callback
established a reference. The callback must free the object if possible and
drop the reference count.

> + */
> +static bool xa_reclaim(void *arg)

Ok lets assume that this is the second callback.

> +{
> +	struct xa_node *node, *victim = arg;
> +	struct xarray *xa = READ_ONCE(victim->array);
> +	void __rcu **slot;
> +	unsigned int i;
> +
> +	/* Node has been allocated, but not yet placed in a tree. */
> +	if (!xa)
> +		return false;
> +	/* If the node has already been freed, we only need to wait for RCU */
> +	if (xa == XA_RCU_FREE)
> +		goto out;

Hmmm... We really need a refcount here.

> +	node = kmem_cache_alloc(xa_node_cache, GFP_KERNEL);
> +
> +	xa_lock_irq(xa);

The lock may be held for the set of objects being processed.

> +
> +	/* Might have been freed since we last checked */
> +	xa = victim->array;
> +	if (xa == XA_RCU_FREE)
> +		goto unlock;
> +
> +	/* Can't grab the LRU list lock here */
> +	if (!list_empty(&victim->private_list))
> +		goto busy;
> +
> +	memcpy(node, victim, sizeof(*node));
> +	INIT_LIST_HEAD(&node->private_list);
> +	for (i = 0; i < XA_CHUNK_SIZE; i++) {
> +		void *entry = xa_entry_locked(xa, node, i);
> +		if (xa_is_node(entry))
> +			rcu_assign_pointer(xa_node(entry)->parent, node);
> +	}
> +	if (!node->parent)
> +		slot = &xa->xa_head;
> +	else
> +		slot = &xa_parent_locked(xa, node)->slots[node->offset];
> +	rcu_assign_pointer(*slot, xa_mk_node(node));
> +unlock:
> +	xa_unlock_irq(xa);
> +	xa_node_free(victim);
> +
> +out:
> +	rcu_barrier();
> +	return true;
> +
> +busy:
> +	xa_unlock_irq(xa);
> +	return false;
> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
