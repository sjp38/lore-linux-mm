Date: Tue, 26 Jun 2007 01:18:31 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 12/26] SLUB: Slab defragmentation core
Message-Id: <20070626011831.181d7a6a.akpm@linux-foundation.org>
In-Reply-To: <20070618095916.297690463@sgi.com>
References: <20070618095838.238615343@sgi.com>
	<20070618095916.297690463@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, suresh.b.siddha@intel.com
List-ID: <linux-mm.kvack.org>

On Mon, 18 Jun 2007 02:58:50 -0700 clameter@sgi.com wrote:

> Slab defragmentation occurs either
> 
> 1. Unconditionally when kmem_cache_shrink is called on slab by the kernel
>    calling kmem_cache_shrink or slabinfo triggering slab shrinking. This
>    form performs defragmentation on all nodes of a NUMA system.
> 
> 2. Conditionally when kmem_cache_defrag(<percentage>, <node>) is called.
> 
>    The defragmentation is only performed if the fragmentation of the slab
>    is higher then the specified percentage. Fragmentation ratios are measured
>    by calculating the percentage of objects in use compared to the total
>    number of objects that the slab cache could hold.
> 
>    kmem_cache_defrag takes a node parameter. This can either be -1 if
>    defragmentation should be performed on all nodes, or a node number.
>    If a node number was specified then defragmentation is only performed
>    on a specific node.
> 
>    Slab defragmentation is a memory intensive operation that can be
>    sped up in a NUMA system if mostly node local memory is accessed. That
>    is the case if we just have reclaimed reclaim on a node.
> 
> For defragmentation SLUB first generates a sorted list of partial slabs.
> Sorting is performed according to the number of objects allocated.
> Thus the slabs with the least objects will be at the end.
> 
> We extract slabs off the tail of that list until we have either reached a
> mininum number of slabs or until we encounter a slab that has more than a
> quarter of its objects allocated. Then we attempt to remove the objects
> from each of the slabs taken.
> 
> In order for a slabcache to support defragmentation a couple of functions
> must be defined via kmem_cache_ops. These are
> 
> void *get(struct kmem_cache *s, int nr, void **objects)
> 
> 	Must obtain a reference to the listed objects. SLUB guarantees that
> 	the objects are still allocated. However, other threads may be blocked
> 	in slab_free attempting to free objects in the slab. These may succeed
> 	as soon as get() returns to the slab allocator. The function must
> 	be able to detect the situation and void the attempts to handle such
> 	objects (by for example voiding the corresponding entry in the objects
> 	array).
> 
> 	No slab operations may be performed in get_reference(). Interrupts

s/get_reference/get/, yes?

> 	are disabled. What can be done is very limited. The slab lock
> 	for the page with the object is taken. Any attempt to perform a slab
> 	operation may lead to a deadlock.
> 
> 	get() returns a private pointer that is passed to kick. Should we
> 	be unable to obtain all references then that pointer may indicate
> 	to the kick() function that it should not attempt any object removal
> 	or move but simply remove the reference counts.
> 
> void kick(struct kmem_cache *, int nr, void **objects, void *get_result)
> 
> 	After SLUB has established references to the objects in a
> 	slab it will drop all locks and then use kick() to move objects out
> 	of the slab. The existence of the object is guaranteed by virtue of
> 	the earlier obtained references via get(). The callback may perform
> 	any slab operation since no locks are held at the time of call.
> 
> 	The callback should remove the object from the slab in some way. This
> 	may be accomplished by reclaiming the object and then running
> 	kmem_cache_free() or reallocating it and then running
> 	kmem_cache_free(). Reallocation is advantageous because the partial
> 	slabs were just sorted to have the partial slabs with the most objects
> 	first. Reallocation is likely to result in filling up a slab in
> 	addition to freeing up one slab so that it also can be removed from
> 	the partial list.
> 
> 	Kick() does not return a result. SLUB will check the number of
> 	remaining objects in the slab. If all objects were removed then
> 	we know that the operation was successful.
> 

Nice changelog ;)

> +static int __kmem_cache_vacate(struct kmem_cache *s,
> +		struct page *page, unsigned long flags, void *scratch)
> +{
> +	void **vector = scratch;
> +	void *p;
> +	void *addr = page_address(page);
> +	DECLARE_BITMAP(map, s->objects);

A variable-sized local.  We have a few of these in-kernel.

What's the worst-case here?  With 4k pages and 4-byte slab it's 128 bytes
of stack?  Seems acceptable.

(What's the smallest sized object slub will create?  4 bytes?)



To hold off a concurrent free while defragging, the code relies upon
slab_lock() on the current page, yes?

But slab_lock() isn't taken for slabs whose objects are larger than PAGE_SIZE. 
How's that handled?



Overall: looks good.  It'd be nice to get a buffer_head shrinker in place,
see how that goes from a proof-of-concept POV.


How much testing has been done on this code, and of what form, and with
what results?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
