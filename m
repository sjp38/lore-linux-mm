Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3F7086B0092
	for <linux-mm@kvack.org>; Mon, 24 Jan 2011 10:00:22 -0500 (EST)
Subject: Re: [PATCH 00/21] mm: Preemptibility -v6
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20110124143407.GA19856@redhat.com>
References: <20101126143843.801484792@chello.nl>
	 <alpine.LSU.2.00.1101172301340.2899@sister.anvils>
	 <1295457039.28776.137.camel@laptop>
	 <alpine.LSU.2.00.1101201052060.1603@sister.anvils>
	 <1295624034.28776.303.camel@laptop> <1295871714.28776.406.camel@laptop>
	 <20110124143407.GA19856@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Mon, 24 Jan 2011 16:00:46 +0100
Message-ID: <1295881246.28776.445.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Nick Piggin <npiggin@kernel.dk>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, "Paul E.
 McKenney" <paulmck@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2011-01-24 at 15:34 +0100, Oleg Nesterov wrote:
> On 01/24, Peter Zijlstra wrote:
> >
> > On Fri, 2011-01-21 at 16:33 +0100, Peter Zijlstra wrote:
> >
> > > Index: linux-2.6/mm/rmap.c
> > > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > > --- linux-2.6.orig/mm/rmap.c
> > > +++ linux-2.6/mm/rmap.c
> > > @@ -1559,9 +1559,20 @@ void __put_anon_vma(struct anon_vma *ano
> > >  	 * Synchronize against page_lock_anon_vma() such that
> > >  	 * we can safely hold the lock without the anon_vma getting
> > >  	 * freed.
> > > +	 *
> > > +	 * Relies on the full mb implied by the atomic_dec_and_test() from
> > > +	 * put_anon_vma() against the full mb implied by mutex_trylock() fr=
om
> > > +	 * page_lock_anon_vma(). This orders:
> > > +	 *
> > > +	 * page_lock_anon_vma()		VS	put_anon_vma()
> > > +	 *   mutex_trylock()			  atomic_dec_and_test()
> > > +	 *   smp_mb()				  smp_mb()
> > > +	 *   atomic_read()			  mutex_is_locked()
> >
> > Bah!, I thought all mutex_trylock() implementations used an atomic op
> > with return value (which implies a mb), but it looks like (at least*)
> > PPC doesn't and only provides a LOCK barrier.
>=20
> But, mutex_trylock() must imply the one-way barrier, otherwise it
> is buggy, no?

> If this atomic_read() can leak out of the critical section, then
> I think mutex_trylock() should be fixed. Or I misunderstood the
> problem completely...

It implies the LOCK barrier, the one way permeable thing, not a full mb.

But I'm not sure the LOCK is sufficient to make the above scenario work.

> BTW, from https://lkml.org/lkml/2010/11/26/213
>=20
> 	+ * Similar to page_get_anon_vma() except it locks the anon_vma.
> 	...
> 	-	struct anon_vma *anon_vma =3D page_get_anon_vma(page);
>=20
> looks like, page_get_anon_vma() becomes unused.

In my current tree there's two left in mm/migrate.c.


git://git.kernel.org/pub/scm/linux/kernel/git/peterz/linux-2.6-mmu_preempt.=
git

HEAD: 7e23542fae47ed3b811583cb925837e3aa7a3f0f

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
