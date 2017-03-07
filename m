Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id EF02C6B038A
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 17:03:52 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id l66so25598327pfl.6
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 14:03:52 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id o1si1176331pgn.177.2017.03.07.14.03.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Mar 2017 14:03:51 -0800 (PST)
Date: Tue, 7 Mar 2017 14:03:43 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC 5/6] slub: Slab defrag core
Message-ID: <20170307220343.GV16328@bombadil.infradead.org>
References: <20170307212429.044249411@linux.com>
 <20170307212438.294581405@linux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170307212438.294581405@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, akpm@linux-foundation.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org, Rik van Riel <riel@redhat.com>

On Tue, Mar 07, 2017 at 03:24:34PM -0600, Christoph Lameter wrote:
> kmem_defrag_get_func (void *get(struct kmem_cache *s, int nr, void **objects))
> 
> 	Must obtain a reference to the listed objects. SLUB guarantees that
> 	the objects are still allocated. However, other threads may be blocked
> 	in slab_free() attempting to free objects in the slab. These may succeed
> 	as soon as get() returns to the slab allocator. The function must
> 	be able to detect such situations and void the attempts to free such
> 	objects (by for example voiding the corresponding entry in the objects
> 	array).
> 
> 	No slab operations may be performed in get(). Interrupts
> 	are disabled. What can be done is very limited. The slab lock
> 	for the page that contains the object is taken. Any attempt to perform
> 	a slab operation may lead to a deadlock.
> 
> 	kmem_defrag_get_func returns a private pointer that is passed to
> 	kmem_defrag_kick_func(). Should we be unable to obtain all references
> 	then that pointer may indicate to the kick() function that it should
> 	not attempt any object removal or move but simply remove the
> 	reference counts.

I think calling it 'get' is overly prescriptive of how an implementation should
work.  Perhaps 'test'?  And returning ERR_PTR if we cannot free all objects?

> kmem_defrag_kick_func (void kick(struct kmem_cache *, int nr, void **objects,
> 							void *get_result))
> 
> 	After SLUB has established references to the objects in a
> 	slab it will then drop all locks and use kick() to move objects out
> 	of the slab. The existence of the object is guaranteed by virtue of
> 	the earlier obtained references via kmem_defrag_get_func(). The
> 	callback may perform any slab operation since no locks are held at
> 	the time of call.
> 
> 	The callback should remove the object from the slab in some way. This
> 	may be accomplished by reclaiming the object and then running
> 	kmem_cache_free() or reallocating it and then running
> 	kmem_cache_free(). Reallocation is advantageous because the partial
> 	slabs were just sorted to have the partial slabs with the most objects
> 	first. Reallocation is likely to result in filling up a slab in
> 	addition to freeing up one slab. A filled up slab can also be removed
> 	from the partial list. So there could be a double effect.
> 
> 	kmem_defrag_kick_func() does not return a result. SLUB will check
> 	the number of remaining objects in the slab. If all objects were
> 	removed then the slab is freed and we have reduced the overall
> 	fragmentation of the slab cache.

I think 'kick' is a bad name.  'evict', maybe?

Also, xarray, dcache and the inode cache all use RCU to free objects, so
perhaps a sentence or two in here about that would be beneficial ...

	If objects are freed to this slab using RCU, the evict function
	should call rcu_barrier() before returning to ensure that all
	objects have been returned and the slab page can be freed.

> +	private = s->get(s, count, vector);
> +
> +	/*
> +	 * Got references. Now we can drop the slab lock. The slab
> +	 * is frozen so it cannot vanish from under us nor will
> +	 * allocations be performed on the slab. However, unlocking the
> +	 * slab will allow concurrent slab_frees to proceed.
> +	 */
> +	slab_unlock(page);
> +	local_irq_restore(flags);
> +
> +	/*
> +	 * Perform the KICK callbacks to remove the objects.
> +	 */
> +	s->kick(s, count, vector, private);

	private = s->test(vector, count);
	slab_unlock(page);
	local_irq_restore(flags);
	if (!IS_ERR(private))
		s->evict(vector, count, private);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
