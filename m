Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id AA98F6B003D
	for <linux-mm@kvack.org>; Mon,  4 May 2009 01:19:45 -0400 (EDT)
Received: by yw-out-1718.google.com with SMTP id 5so1987682ywm.26
        for <linux-mm@kvack.org>; Sun, 03 May 2009 22:20:02 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 4 May 2009 01:20:02 -0400
Message-ID: <f73f7ab80905032220w4aab3caal90703a253377e91c@mail.gmail.com>
Subject: [v2] Generic LRU cache built on a kmem_cache and a "struct shrinker"
From: Kyle Moffett <kyle@moffetthome.net>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Lars Ellenberg <lars.ellenberg@linbit.com>
Cc: Philipp Reisner <philipp.reisner@linbit.com>, linux-kernel@vger.kernel.org, Jens Axboe <jens.axboe@oracle.com>, Greg KH <gregkh@suse.de>, Neil Brown <neilb@suse.de>, James Bottomley <James.Bottomley@hansenpartnership.com>, Sam Ravnborg <sam@ravnborg.org>, Dave Jones <davej@redhat.com>, Nikanth Karthikesan <knikanth@suse.de>, Lars Marowsky-Bree <lmb@suse.de>, "Nicholas A. Bellinger" <nab@linux-iscsi.org>, Bart Van Assche <bart.vanassche@gmail.com>, linux-mm@kvack.org, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Sun, May 3, 2009 at 8:48 PM, Kyle Moffett <kyle@moffetthome.net> wrote:
> On Sun, May 3, 2009 at 6:48 PM, Lars Ellenberg <lars.ellenberg@linbit.com=
> wrote:
>> but wait for the next post to see a better documented (or possibly
>> rewritten) implementation of this.
>
> Yeah, I'm definitely reworking it now that I have a better
> understanding of what the DRBD code really wants. =C2=A0My main intention
> is to have the code be flexible enough that filesystems and other
> sorts of network-related code can use it transparently, without
> requiring much in the way of manual tuning. =C2=A0See Linus' various
> comments on why he *hates* manual tunables.

I'm heading to bed, but I figured I'd share what I've hacked up so
far.  This new version hasn't even been remotely compile-tested yet,
but it has most of the runtime-adjustable limits and tunables added.

Top-level overview for newcomers:

This is a sort-of-generic LRU cache I wrote for a personal project I
was fiddling with, that has been extended to hopefully also make it
usable as a replacement for the DRBD lru_cache (fixed size, apparently
usually very small).  Please let me know if you spot something
fundamentally wrong with it (aside from fitness for the DRBD
requirements, that's a work in progress).

It uses a kmem_cache to allocate fixed-size objects.  Objects are
either in_use (refcount > 0) or on the LRU (refcount =3D=3D 0).  We also
register a shrinker callback (needs a small patch to pass a pointer to
the "struct shrinker" to the callback) which allows us to respond to
memory pressure.

Taking a reference to an already-referenced object is a single atomic
op, as is releasing a secondary reference.

When an object needs to be moved between the in_use list and the LRU,
we currently take an internal spinlock.  This spinlock is also held by
a couple of the set-tunable functions as well as the shrinker (see the
FIXME regarding the ->evict() callback).  I'd like to figure out some
way that I can avoid having to hold that lock for the entire shrink
operation.

Changes in v2:

*  The shrinker code can be completely disabled by setting
"lru_cache_type->seeks" to 0.

*  The shrinker completely ignores up to "nr_elem_min" objects (total)
across the in_use and lru lists.

*  The code _should_ refuse to allocate more than nr_elem_max objects
(need to recheck my design).

*  If lru_cache_alloc() fails and you need an object, you should call
lru_cache_shrink(lc, 1, GFP_KERNEL) and retry.  I'm mulling over a
better API for this, because if it was the kmem_cache_alloc() that
failed, the shrinker may have already been called for you.

*  The "shrink_factor" adjusts the shrinker's perception of the number
of objects you have allocated.  If there are N freeable objects on the
LRU (excluding the first "nr_elem_min" objects as above) then we
report "N * shrink_factor / 1000" objects to the shrinker.

*  There are still a lot of things that could be done to make this
lockless, unfortunately some of the RCU-based list operations will
require that any code using this is prepared to handle some of the
side-effects.  Depending on how many objects are allocated through the
LRU and how many CPUs are pounding it, percpu counters might also
provide some benefit.

Lars, hopefully this is a little bit more usable for you?  The nice
thing about the more complicated implementation with tunables (even if
you initially set most of them to "disable") is that they can be
relatively easily enabled for performance testing.

Well that's about it for me... it's now late enough I'm probably
staring cross-eyed at several obvious bugs and can't even tell... good
night!

Cheers,
Kyle Moffett


/*
 * include/linux/lru_cache.h
 *
 * Copyright (C) 2009, Kyle Moffett <kyle@moffetthome.net>
 *
 * Licensed under the GNU General Public License, version 2
 */

#ifndef  LINUX_LRU_CACHE_H_
# define LINUX_LRU_CACHE_H_ 1

# include <linux/atomic.h>
# include <linux/list.h>
# include <linux/mm.h>
# include <linux/slab.h>
# include <linux/spinlock.h>
# include <linux/types.h>

struct lru_cache_type {
	const char *name;
	size_t size, align;
	unsigned long flags;
	long initial_elem_min;
	long initial_elem_max;
	long initial_shrink_factor;
	int seeks;

	/*
	 * Return nonzero if the passed object may be evicted (IE: freed).
	 * Otherwise return zero and it will be "touched" (IE: moved to the
	 * tail of the LRU) so that later scans will try other objects.
	 *
	 * If you return nonero from this function, "obj" will be immediately
	 * kmem_cache_free()d.
	 *
	 * Warning:  At the moment this is called with the internal spinlock
	 * held, so you may NOT recurse into any other lru_cache function
	 * on this object.
	 */
	unsigned int (*evict)(struct lru_cache *lc, void *obj);
};

struct lru_cache {
	const struct lru_cache_type *type;
	long nr_elem_min;
	long nr_elem_max;
	long shrink_factor;
	size_t offset;

	struct kmem_cache *cache;
	struct shrinker shrinker;

	/* The least-recently used item in the LRU is at the head */
	atomic_long_t nr_avail;
	spinlock_t lock;
	struct list_head lru;
	struct list_head in_use;
	unsigned long nr_lru;
	unsigned long nr_in_use;
};

/* Create, destroy, and shrink whole lru_caches */
int lru_cache_create(struct lru_cache *lc, const struct lru_cache_type *typ=
e);
void lru_cache_destroy(struct lru_cache *lc);
int lru_cache_shrink(struct lru_cache *lc, int nr_scan, gfp_t flags);

/*
 * Allocate and free individual objects within caches.  The alloc function
 * returns an in_use object with a refcount of 1.
 */
void *lru_cache_alloc(struct lru_cache *lc, gfp_t flags);
void lru_cache_free(struct lru_cache *lc, void *obj);

/*
 * These may need to adjust other internal state, and they are atomic with
 * respect to that internal state (although possibly not with the user code=
).
 *
 * Their return values are the atomically-exchanged old value for that fiel=
d.
 */
long lru_cache_set_elem_min(struct lru_cache *lc, long nr_elem_min);
long lru_cache_set_elem_max(struct lru_cache *lc, long nr_elem_max);
long lru_cache_set_shrink_factor(struct lru_cache *lc, long shrink_factor);

/* Manage in-use references on LRU-cache objects */
void *lru_cache_get__(struct lru_cache *lc, void *obj);
void *lru_cache_get(struct lru_cache *lc, void *obj);
void lru_cache_put(struct lru_cache *lc, void *obj);

/* These are nonatomic reads, provide your own exclusion */
static inline long lru_cache_get_elem_min(struct lru_cache *lc)
{
	return lc->elem_min;
}

static inline long lru_cache_get_elem_max(struct lru_cache *lc)
{
	return lc->elem_max;
}

static inline long lru_cache_get_shrink_factor(struct lru_cache *lc)
{
	return lc->shrink_factor;
}

#endif /* not LINUX_LRU_CACHE_H_ */





/*
 * mm/lru_cache.c
 *
 * Copyright (C) 2009, Kyle Moffett <kyle@moffetthome.net>
 *
 * Licensed under the GNU General Public License, version 2
 */

#include <linux/lru_cache.h>

struct lru_cache_elem {
	/* The node is either on the LRU or on this in-use list */
	struct list_head node;
	const struct lru_cache *lc;
	atomic_t refcount;
}

/*
 * FIXME:  Needs a patch to make the shinker->shrink() function take an ext=
ra
 * argument with the address of the "struct shrinker".
 */
static int lru_cache_shrink__(struct shrinker *s, int nr_scan, gfp_t flags)
{
	return lru_cache_shrink(container_of(s, struct lru_cache, shrinker),
				nr_scan, flags);
}

int lru_cache_create(struct lru_cache *lc, const struct lru_cache_type *typ=
e)
{
	/* Align the size so an lru_cache_elem can sit at the end */
	size_t align =3D MAX(type->align, __alignof__(struct lru_cache_elem));
	size_t size =3D ALIGN(type->size, __alignof__(struct lru_cache_elem));
	lc->offset =3D size;

	/* Now add space for that element */
	size +=3D sizeof(struct lru_cache_elem);

	/* Set up internal tunables */
	lc->type =3D type;
	lc->nr_elem_min   =3D type->initial_elem_min      ?:    0L;
	lc->nr_elem_max   =3D type->initial_elem_max      ?:   -1L;
	lc->shrink_factor =3D type->initial_shrink_factor ?: 1000L;

	/* Initialize internal fields */
	atomic_long_set(&lc->nr_avail, lc->nr_elem_max);
	INIT_LIST_HEAD(&lc->lru);
	INIT_LIST_HEAD(&lc->in_use);
	lc->nr_lru =3D 0;
	lc->nr_in_use =3D 0;

	/* Allocate the fixed-sized-object cache */
	lc->cache =3D kmem_cache_create(type->name, size, align,
			type->flags, NULL);
	if (!lc->cache)
		return -ENOMEM;

	/* Now initialize and register our shrinker if desired */
	lc->shrinker.shrink =3D &lru_cache_shrink;
	lc->shrinker.seeks =3D type->seeks;
	if (lc->shrinker.seeks)
		register_shrinker(&lc->shrinker);

	return 0;
}

/*
 * Before you can call this function, you must free all of the objects on t=
he
 * LRU list (which in turn means they must all have zeroed refcounts), and
 * you must ensure that no other functions will be called on this lru-cache=
.
 */
void lru_cache_destroy(struct lru_cache *lc)
{
	BUG_ON(!lc->type);
	BUG_ON(atomic_long_read(&lc->nr_avail) !=3D lc->nr_elem_max);
	BUG_ON(lc->nr_lru);
	BUG_ON(lc->nr_in_use);
	BUG_ON(!list_empty(&lc->lru));
	BUG_ON(!list_empty(&lc->in_use));

	if (lc->shrinker.seeks)
		unregister_shrinker(&lc->shrinker);
	kmem_cache_destroy(lc->cache);
	lc->cache =3D NULL;
}

void *lru_cache_alloc(struct lru_cache *lc, gfp_t flags)
{
	struct lru_cache_elem *elem;
	void *obj;

	/* Ask if we can allocate another object */
	if (!atomic_long_add_unless(&lc->nr_avail, -1, 0))
		return NULL;

	/*
	 * If the counter is negative, lru_cache_set_elem_max() may have just
	 * resized the cache on us.  This rmb matches up with the wmb in that
	 * function to handle that case.
	 */
	if (atomic_read(&lc->nr_avail) < 0) {
		smp_rmb();
		if (lc->nr_elem_max > 0) {
			/* Whoops, it got shrunk on us */
			atomic_long_inc(&lc->nr_avail);
			return NULL;
		}
	}

	/* Allocate the object */
	obj =3D kmem_cache_alloc(lc->cache, flags);
	if (!obj)
		return NULL;

	elem =3D obj + lc->offset;
	atomic_set(&elem->refcount, 1);
	elem->lc =3D lc;
	smp_wmb();

	spin_lock(&lc->lock);
	list_add_tail(&elem->node, &lc->in_use);
	lc->in_use++;
	spin_unlock(&lc->lock);

	return obj;
}

/*
 * You must ensure that the lru object has a zero refcount and can no longe=
r
 * be looked up before calling lru_cache_free().  Specifically, you must
 * ensure that lru_cache_get() cannot be called on this object.
 */
void lru_cache_free(struct lru_cache *lc, void *obj)
{
	struct lru_cache_elem *elem =3D obj + lc->offset;
	BUG_ON(elem->lc !=3D lc);

	spin_lock(&lc->lock);
	BUG_ON(atomic_read(&elem->refcount));
	list_del(&elem->node);
	lc->nr_lru--;
	spin_unlock(&lc->lock);

	/* Free the object and record that it's freed */
	kmem_cache_free(lc->cache, obj);
	atomic_inc(&lc->nr_avail);
}

/*
 * This may be called at any time between lru_cache_create() and
 * lru_cache_destroy() by the shrinker code to reduce our memory usage.
 *
 * FIXME:  Figure out a way to call the evict() callback without holding th=
e
 * internal spinlock.  Preferrably in a way that allows an RCU list-walk.
 */
int lru_cache_shrink(struct lru_cache *lc, int nr_scan, gfp_t flags)
{
	long long nr_freeable, nr_unfreeable, nr_left =3D nr_scan;
	struct lru_cache_elem *elem, *n;

	/* This protects the list and the various list stats */
	spin_lock(&lc->lock);

	/* This undoes the scaling done below on nr_freeable */
	nr_left *=3D 1000LL;
	nr_left +=3D lc->shrink_factor - 1;
	nr_left /=3D lc->shrink_factor;

	/* Try to scan the number of requested objects */
	list_for_each_entry_safe(elem, n, &lc->lru, node) {
		void *obj;

		/* Stop when we've scanned enough */
		if (!nr_left--)
			break;

		/* Also stop if we're below the low-watermark */
		if (lc->nr_lru + lc->nr_in_use <=3D lc->nr_elem_min)
			break;

		/* Sanity check */
		BUG_ON(atomic_read(&elem->refcount));

		/* Ask them if we can free this item */
		obj =3D ((void *)elem) - lc->offset;
		if (!lc->type->evict(lc, obj)) {
			/*
			 * They wouldn't let us free it, so move it to the
			 * other end of the LRU so we can keep scanning.
			 */
			list_del(&elem->node);
			list_add_tail(&elem->node, &lc->lru);
			continue;
		}

		/* Remove this node from the LRU and free it */
		list_del(&elem->node);
		lc->nr_lru--;
		kmem_cache_free(obj);
	}

	/* Figure out how many elements might still be freeable */
	nr_unfreeable =3D (long long)MAX(lc->nr_in_use, lc->nr_elem_min);
	if (lc->nr_in_use + lc->nr_lru > nr_unfreeable)
		nr_freeable =3D lc->nr_in_use + lc->nr_lru - nr_unfreeable;
	else
		nr_freeable =3D 0;

	/*
	 * Rescale nr_freeable by (1000/lc->shrink_factor).  The intent is
	 * that an lru_cache with a shrink_factor less than 1000 will feel
	 * reduced effects from memory pressure, while one with a
	 * shrink_factor greater than 1000 will feel amplified effects from
	 * memory pressure.
	 *
	 * Make sure to round up so if we have any freeable items at all we
	 * will always return a value of at least 1.
	 *
	 * Then clamp it to INT_MAX so we don't overflow
	 */
	nr_freeable *=3D lc->shrink_factor;
	nr_freeable +=3D 999LL;
	nr_freeable /=3D 1000LL;

	/* Ok, we're done with the LRU lists for now */
	spin_unlock(&lc->lock);

	/* If we were asked to shrink tell the kmem_cache as well */
	if (nr_scan)
		kmem_cache_shrink(lc->cache);

	return (int)MIN(nr_freeable, (long long)INT_MAX);
}

long lru_cache_set_elem_min(struct lru_cache *lc, long nr_elem_min)
{
	long oldmin;

	/* Simply take the spinlock and set the field */
	spin_lock(&lc->lock);
	oldmin =3D lc->nr_elem_min;
	lc->nr_elem_min =3D nr_elem_min;
	spin_unlock(&lc->lock);

	return oldmin;
}

long lru_cache_set_elem_max(struct lru_cache *lc, long nr_elem_max)
{
	long oldmax;

	/*
	 * We need to take the spinlock so we can protect against other
	 * CPUs running in the various slow-paths.
	 */
	spin_lock(&lc->lock);

	oldmax =3D lc->nr_elem_max;
	lc->nr_elem_max =3D nr_elem_max;

	/*
	 * This wmb helps the lru_cache_alloc() fastpath figure out whether
	 * or not there is still room for the object he wants to allocate
	 */
	smp_wmb();

	/* We need to adjust for the change in the elem_max */
	atomic_long_add(&lc->nr_avail, lc->nr_elem_max - oldmax);

	spin_unlock(&lc->lock);
	return oldmax;
}

long lru_cache_set_shrink_factor(struct lru_cache *lc, long shrink_factor)
{
	long oldfactor;

	/* Simply take the spinlock and set the field */
	spin_lock(&lc->lock);
	oldfactor =3D lc->shrink_factor;
	lc->shrink_factor =3D shrink_factor;
	spin_unlock(&lc->lock);

	return oldfactor;
}

/* Use this function if you already have a reference to "obj" */
void *lru_cache_get__(struct lru_cache *lc, void *obj)
{
	struct lru_cache_elem *elem =3D obj + lc->offset;
	BUG_ON(elem->lc !=3D lc);
	atomic_inc(&elem->refcount);
	return obj;
}

/*
 * If you do not already have a reference to "obj", you must wrap the
 * combined lookup + lru_cache_get() in rcu_read_lock/unlock().
 */
void *lru_cache_get(struct lru_cache *lc, void *obj)
{
	struct lru_cache_elem *elem =3D obj + lc->offset;
	BUG_ON(elem->lc !=3D lc);

	/* Fastpath:  If it's already referenced just add another one */
	if (atomic_inc_not_zero(&elem->refcount))
		return obj;

	/* Slowpath:  Need to lock the lru-cache and mark the object used */
	spin_lock(&lc->lock);

	/* One more attempt at the fastpath, now that we've got the lock */
	if (atomic_inc_not_zero(&elem->refcount))
		goto out;

	/*
	 * Ok, it has a zero refcount and we've got the lock, anybody else in
	 * here trying to lru_cache_get() this object will wait until we are
	 * done.
	 */

	/* Remove it from the LRU */
	BUG_ON(!lc->nr_lru);
	list_del(&elem->node);
	lc->nr_lru--;

	/* Add it to the in-use list */
	list_add_tail(&elem->node, &lc->in_use);
	lc->nr_in_use++;

	/* Acquire a reference */
	atomic_set(&elem->refcount, 1);

out:
	spin_unlock(&lc->lock);
	return obj;
}

/* This releases one reference */
void lru_cache_put(struct lru_cache *lc, void *obj)
{
	struct lru_cache_elem *elem =3D obj + lc->offset;
	BUG_ON(elem->lc !=3D lc);
	BUG_ON(!atomic_read(&elem->refcount));

	/* Drop the refcount; if it's still nonzero, we're done */
	if (atomic_dec_return(&elem->refcount))
		return;

	/* We need to take the lru-cache lock to make sure we release it */
	spin_lock(&lc->lock);
	if (atomic_read(&elem->refcount))
		goto out;

	/*
	 * Ok, it has a zero refcount and we hold the lock, anybody trying to
	 * lru_cache_get() this object will block until we're done.
	 */

	/* Remove it from the in-use list */
	BUG_ON(!lc->nr_in_use);
	list_del(&elem->node);
	lc->nr_in_use--;

	/* Add it to the LRU list */
	list_add_tail(&elem->node, &lc->lru);
	lc->nr_lru++;

out:
	spin_unlock(&lc->lock);
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
