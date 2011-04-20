Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1089C8D003B
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 08:39:29 -0400 (EDT)
Subject: Re: [PATCH 20/20] mm: Optimize page_lock_anon_vma() fast-path
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20110419130800.7148a602.akpm@linux-foundation.org>
References: <20110401121258.211963744@chello.nl>
	 <20110401121726.285750519@chello.nl>
	 <20110419130800.7148a602.akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Wed, 20 Apr 2011 14:38:44 +0200
Message-ID: <1303303124.8345.218.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>

On Tue, 2011-04-19 at 13:08 -0700, Andrew Morton wrote:
> On Fri, 01 Apr 2011 14:13:18 +0200
> Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
>=20
> > Optimize the page_lock_anon_vma() fast path to be one atomic op,
> > instead of two.
> >=20
> > Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> > LKML-Reference: <new-submission>
> > ---
> >  mm/rmap.c |   86 +++++++++++++++++++++++++++++++++++++++++++++++++++++=
++++++---
> >  1 file changed, 82 insertions(+), 4 deletions(-)
> >=20
> > Index: linux-2.6/mm/rmap.c
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > --- linux-2.6.orig/mm/rmap.c
> > +++ linux-2.6/mm/rmap.c
> > @@ -85,6 +85,29 @@ static inline struct anon_vma *anon_vma_
> >  static inline void anon_vma_free(struct anon_vma *anon_vma)
> >  {
> >  	VM_BUG_ON(atomic_read(&anon_vma->refcount));
> > +
> > +	/*
> > +	 * Synchronize against page_lock_anon_vma() such that
> > +	 * we can safely hold the lock without the anon_vma getting
> > +	 * freed.
> > +	 *
> > +	 * Relies on the full mb implied by the atomic_dec_and_test() from
> > +	 * put_anon_vma() against the acquire barrier implied by
> > +	 * mutex_trylock() from page_lock_anon_vma(). This orders:
> > +	 *
> > +	 * page_lock_anon_vma()		VS	put_anon_vma()
> > +	 *   mutex_trylock()			  atomic_dec_and_test()
> > +	 *   LOCK				  MB
> > +	 *   atomic_read()			  mutex_is_locked()
> > +	 *
> > +	 * LOCK should suffice since the actual taking of the lock must
> > +	 * happen _before_ what follows.
> > +	 */
> > +	if (mutex_is_locked(&anon_vma->root->mutex)) {
> > +		anon_vma_lock(anon_vma);
> > +		anon_vma_unlock(anon_vma);
> > +	}
> > +
> >  	kmem_cache_free(anon_vma_cachep, anon_vma);
> >  }
>=20
> Did we need to include all this stuff in uniprocessor builds?

For sure, even UP can schedule while holding a mutex.

> It would be neater to add a new anon_vma_is_locked().

I'd agree if there was a user outside of rmap.c, but seeing as rmap.c is
and must be aware of the whole anon_vma->root thing I don't much see the
point in extra wrappery.

> This code is too tricksy to deserve life :(

I'd mostly agree with you there, but there was a strong desire to keep
page_lock_anon_vma() a single atomic. I'll see if I can actually measure
any difference using aim7 or so, which I think is the favorite anon_vma
stress tool.

> > @@ -371,20 +394,75 @@ struct anon_vma *page_get_anon_vma(struc
> >  	return anon_vma;
> >  }
> > =20
> > +/*
> > + * Similar to page_get_anon_vma() except it locks the anon_vma.
> > + *
> > + * Its a little more complex as it tries to keep the fast path to a si=
ngle
> > + * atomic op -- the trylock. If we fail the trylock, we fall back to g=
etting a
> > + * reference like with page_get_anon_vma() and then block on the mutex=
.
> > + */
> >  struct anon_vma *page_lock_anon_vma(struct page *page)
> >  {
> > -	struct anon_vma *anon_vma =3D page_get_anon_vma(page);
> > +	struct anon_vma *anon_vma =3D NULL;
> > +	unsigned long anon_mapping;
> > =20
> > -	if (anon_vma)
> > -		anon_vma_lock(anon_vma);
> > +	rcu_read_lock();
> > +	anon_mapping =3D (unsigned long) ACCESS_ONCE(page->mapping);
> > +	if ((anon_mapping & PAGE_MAPPING_FLAGS) !=3D PAGE_MAPPING_ANON)
> > +		goto out;
>=20
> Why?  Needs a comment.

Uhm, why we're testing to see if there is an anon_vma at all? Or why we
need that ACCESS_ONCE()?

> > +	if (!page_mapped(page))
> > +		goto out;
>=20
> Why?  How can this come about? Needs a comment.

Well, the existing comment says to look at page_get_anon_vma() and the
comment there does explain how all this is racy wrt page_remove_rmap().
Do you want more comments?

> > +
> > +	anon_vma =3D (struct anon_vma *) (anon_mapping - PAGE_MAPPING_ANON);
> > +	if (mutex_trylock(&anon_vma->root->mutex)) {
>=20
> anon_vma_trylock()?
>=20
> Or just remove all the wrapper functions and open-code all the locking.
> These tricks all seem pretty tied-up with the mutex implementation
> anyway.

Well, we cannot remove all the wrappers, anon_vma_{un,}lock() are used
outside of rmap.c and we don't want to expose the implementation of the
anon_vma locking outside of here, but like said, inside rmap.c I don't
see much reason to introduce new wrappers.

And yes, all of this is needed because of the anon_vma->lock mutex
conversion since, in general, we cannot schedule under rcu_read_lock and
therefore have to play these tricks with the reference count to bridge
the gap between rcu_read_unlock() and acquiring the lock.

> > +		/*
> > +		 * If we observe a !0 refcount, then holding the lock ensures
> > +		 * the anon_vma will not go away, see __put_anon_vma().
> > +		 */
> > +		if (!atomic_read(&anon_vma->refcount)) {
> > +			anon_vma_unlock(anon_vma);
> > +			anon_vma =3D NULL;
> > +		}
> > +		goto out;
> > +	}
> > +
> > +	/* trylock failed, we got to sleep */
> > +	if (!atomic_inc_not_zero(&anon_vma->refcount)) {
> > +		anon_vma =3D NULL;
> > +		goto out;
> > +	}
> > =20
> > +	if (!page_mapped(page)) {
> > +		put_anon_vma(anon_vma);
> > +		anon_vma =3D NULL;
> > +		goto out;
> > +	}
>=20
> Also quite opaque, needs decent commentary.
>=20
> I'd have expected this test to occur after the lock was acquired.

Right, so I think we could drop that test from both here and
page_get_anon_vma() and nothing would break, its simply avoiding some
work in case we do detect the race with page_remove_rmap().

So yes, I think I'll move it down because that'll widen the scope of
this optimization.

> > +	/* we pinned the anon_vma, its safe to sleep */
> > +	rcu_read_unlock();
> > +	anon_vma_lock(anon_vma);
> > +
> > +	if (atomic_dec_and_test(&anon_vma->refcount)) {
> > +		/*
> > +		 * Oops, we held the last refcount, release the lock
> > +		 * and bail -- can't simply use put_anon_vma() because
> > +		 * we'll deadlock on the anon_vma_lock() recursion.
> > +		 */
> > +		anon_vma_unlock(anon_vma);
> > +		__put_anon_vma(anon_vma);
> > +		anon_vma =3D NULL;
> > +	}
> > +
> > +	return anon_vma;
> > +
> > +out:
> > +	rcu_read_unlock();
> >  	return anon_vma;
> >  }
> > =20
> >  void page_unlock_anon_vma(struct anon_vma *anon_vma)
> >  {
> >  	anon_vma_unlock(anon_vma);
> > -	put_anon_vma(anon_vma);
> >  }
>=20
> Geeze, I hope this patch is worth it :( :(

There is a reason this is the last patch in the series ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
