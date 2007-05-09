Date: Wed, 9 May 2007 09:34:40 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 2/3] SLUB: Implement targeted reclaim and partial list
 defragmentation
In-Reply-To: <Pine.LNX.4.64.0705091404560.13411@skynet.skynet.ie>
Message-ID: <Pine.LNX.4.64.0705090915220.28045@schroedinger.engr.sgi.com>
References: <20070504221555.642061626@sgi.com> <20070504221708.596112123@sgi.com>
 <Pine.LNX.4.64.0705091404560.13411@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, dgc@sgi.com, Eric Dumazet <dada1@cosmosbay.com>
List-ID: <linux-mm.kvack.org>

On Wed, 9 May 2007, Mel Gorman wrote:

> > Must obtain a reference to the object if it has not been freed yet. It is up
> > to the slabcache to resolve the race.
> 
> Is there also a race here between the object being searched for and the
> reference being taken? Would it be appropriate to call this
> find_get_slub_object() to mirror what find_get_page() does except instead of
> offset, it receives some key meaningful to the cache? It might help set a
> developers expectation of what the function is required to do when creating
> such a cache and simplify locking.
> 
> (written much later) Looking through, it's not super-clear if get_reference()
> is only for use by SLUB to get an exclusive reference to an object or
> something that is generally called to reference count it. It looks like only
> one reference is ever taken.

Rights. Its only for SLUB to get a reference to be able to free the 
object. I am not sure what you mean by the object being searched for? In 
the partial lists of SLUB? That has its own locking scheme.

> > SLUB guarantees that the objects is
> > still allocated. However, another thread may be blocked in slab_free
> > attempting to free the same object. It may succeed as soon as
> > get_reference() returns to the slab allocator.
> Fun. If it was find_get_slub_object() instead of get_reference(), the caller
> could block if the object is currently being freed until slab_free completed.
> It would take a hit because the object has to be recreated but maybe it would
> be an easier race to deal with?

It is much easier to let the competing thread succeed. If we find that 
there refcount == 0 then a free is in progress and caller is blocked. SLUB 
will drop all locks after references have been established. At that point 
the concurrent free will succeed. Thus no need to wait.
 
> > get_reference() processing must recognize this situation (i.e. check
> > refcount
> > for zero) and fail in such a sitation (no problem since the object will
> > be freed as soon we drop the slab lock before doing kick calls).
> > 
> 
> Block or fail?

Fail. The competing free must succeed.

> > The callback should remove the object from the slab in some way. This may
> > be accomplished by reclaiming the object and then running kmem_cache_free()
> > or reallocating it and then running kmem_cache_free(). Reallocation
> > is advantageous at this point because it will then allocate from the partial
> > slabs with the most objects because we have just finished slab shrinking.
> > 
> 
> > From the comments alone, it sounds like the page cache API should be 
> copied in name at least like slub_object_get(), slub_object_release() and
> maybe even something like slub_object_get_unless_vacating() if the caller must
> not sleep. It seems the page cache shares similar problems to what SLUB is
> doing here.

We already have such an API. See include/linux/mm.h

/*
 * Try to grab a ref unless the page has a refcount of zero, return false 
if
 * that is the case.
 */
static inline int get_page_unless_zero(struct page *page)
{
        VM_BUG_ON(PageCompound(page));
        return atomic_inc_not_zero(&page->_count);
}


> Take everything I say here with a grain of salt. My understanding of SLUB is
> non-existent at the moment and it makes reviewing this a bit tricky.

Thanks for looking at it. This could greatly increase the useful of 
defragmentation. If all reclaimable slabs would support the hooks then we 
may even get rid of the reclaimable section?

> > Index: slub/mm/slub.c
> > ===================================================================
> > --- slub.orig/mm/slub.c	2007-05-04 13:32:34.000000000 -0700
> > +++ slub/mm/slub.c	2007-05-04 13:56:25.000000000 -0700
> > @@ -173,7 +173,7 @@ static struct notifier_block slab_notifi
> > static enum {
> > 	DOWN,		/* No slab functionality available */
> > 	PARTIAL,	/* kmem_cache_open() works but kmalloc does not */
> > -	UP,		/* Everything works */
> > +	UP,		/* Everything works but does not show up in sysfs */
> 
> Should this be here?

No that slipped in here somehow.
 

> > -	page->flags |= 1 << PG_slab;
> > -	if (s->flags & (SLAB_DEBUG_FREE | SLAB_RED_ZONE | SLAB_POISON |
> > -			SLAB_STORE_USER | SLAB_TRACE))
> > -		page->flags |= 1 << PG_error;
> > -
> > +	page->inuse = 0;
> 
> You probably have explained this a million times already and in the main SLUB
> patches, but why is _count not used?

_count is used by kmem_cache_vacate to insure that the page does not go 
away. page->inuse is used to make sure that we do not vacate objects in a 
slab that is just being setup for slab or being torn down and freed.
_count effect the page allocator. page->inuse the slab processing.

> > /*
> > + * Vacate all objects in the given slab. Slab must be locked.
> > + *
> > + * Will drop and regain and drop the slab lock.
> > + * Slab must be marked PageActive() to avoid concurrent slab_free from
> 
> I just noticed this PageActive() overloading of the page->flags. Is it worth
> defining SlabPerCPU() as an alias or something?

I have done this already for PageError. Maybe someday.

> > +	/*
> > +	 * Get a refcount for all used objects. If that fails then
> > +	 * no KICK callback can be performed.
> > +	 */
> > +	for(p = addr; p < addr + s->objects * s->size; p += s->size)
> > +		if (!test_bit((p - addr) / s->size, map))
> > +			if (!s->slab_ops->get_reference(p))
> > +				set_bit((p - addr) / s->size, map);
> > +
> 
> The comment and code implies that only one caller can hold a reference at a
> time and the count is either 1 or 0.

Multiple callers can hold a reference. If the reference is not gone by the 
time we do the kick calls then the object will not be freed.

> 
> (later)
> 
> It looks like get_reference() is only intended for use by SLUB. I don't
> currently see how an implementer of a cache could determine if an object is
> being actively referenced or not when deciding whether to return 1 for
> get_reference() unless the cache interally implemented a referencing count
> API. That might lead to many, similar but subtly different implementations of
> reference counting.

Right the reclaimable caches in general implement such a scheme. The hook 
is there so that the different implementations of reference counting can 
be handled.

> 
> > +	/* Got all the references we need. Now we can drop the slab lock */
> > +	slab_unlock(page);
> > +
> 
> Where did we check we got all the references? It looks more like we got all
> the references we could.

Right. We only reclaim on those where we did get references. The others 
may fail or succeed (concurrent free) independently.

> > +
> > +/*
> > + * Attempt to free objects in a page. Return 1 when succesful.
> > + */
> 
> when or if? Looks more like if

Right. Sorry in German if = when

> > +	if (!PageSlab(page) || PageActive(page) || !page->inuse) {
> > +		slab_unlock(page);
> > +		goto out;
> > +	}
> > +
> 
> The PageActive() part is going to confuse someone eventually because they'll
> interpret it to mean that slab pages are on the LRU now.

Ok one more argument to have a different name there.

> > +	/*
> > +	 * We are holding a lock on a slab page that is not in the
> > +	 * process of being allocated or freed.
> > +	 */
> > +	s = page->slab;
> > +	remove_from_lists(s, page);
> > +	SetPageActive(page);
> > +	rc = __kmem_cache_vacate(s, page) == 0;
> 
> The name rc is misleading here. I am reading it as reference count, but it's
> not a reference count at all.

Its the result yes. Need to rename it.

> > +out:
> > +	put_page(page);
> > +	return rc;
> > +}
> 
> Where do partially freed slab pages get put back on the lists? Do they just
> remain off the lists until they are totally freed as a type of lazy free? If
> so, a wait_on_slab_page_free() call may be needed later.

No putback_slab puts them back. The refcount for the page is separate. 
This means that a page may be "freed" by SLUB while kmem_cache_vacate 
is running but it will not really be freed because the refcount is > 0.
Only if kmem_cache_vacate terminates will the page be returned to the free 
page pool. Otherwise the page could vanish under us and be used for some 
other purpose.

> > +/*
> >  *  kmem_cache_shrink removes empty slabs from the partial lists
> >  *  and then sorts the partially allocated slabs by the number
> >  *  of items in use. The slabs with the most items in use
> > @@ -2137,11 +2251,12 @@ int kmem_cache_shrink(struct kmem_cache
> > 	int node;
> > 	int i;
> > 	struct kmem_cache_node *n;
> > -	struct page *page;
> > +	struct page *page, *page2;
> 
> page2, is a pretty bad name.

Its a throwaway variable for list operations.

 
> > +			if (page->inuse > s->objects / 4)
> > +				break;
> > +
> 
> I get the idea of the check but it may have unexpected consequences if all of
> the slabs in use happen to be half full.

I am open for other proposals. I do not want the slabs to be too dense. 
Having them half full means that SLUB does not have to do any list 
operations on any kfree operations for awhile.

> 
> > +			list_move(&page->lru, &zaplist);
> > +			n->nr_partial--;
> > +			SetPageActive(page);
> > +			slab_unlock(page);
> > +		}
> 
> Ok, not sure if this is a problem or not. I don't get why SetPageActive() is
> being called and it's because I don't understand SLUB yet.

SetPageActive disables all list operations on a slab. If all objects are 
freed in a slab then the slab is usually freed. If PageActive is set then 
the slab is left alone.

> > 		spin_unlock_irqrestore(&n->list_lock, flags);
> > +
> > +		/* Now we can free objects in the slabs on the zaplist */
> > +		list_for_each_entry_safe(page, page2, &zaplist, lru) {
> > +			slab_lock(page);
> > +			__kmem_cache_vacate(s, page);
> > +		}
> 
> No checking the return value here which is why I think that slab pages once
> vacated are expected to be off the lists and totally freed. If that is the
> case, it might have consequences if the cache is badly behaving and never
> freeing objects.

__kmem_cache_vacate puts the slab back into the lists or frees them. Thus 
no need to check return codes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
