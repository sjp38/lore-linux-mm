Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 784D48D0039
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 10:33:23 -0500 (EST)
Subject: Re: [PATCH 00/21] mm: Preemptibility -v6
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <alpine.LSU.2.00.1101201052060.1603@sister.anvils>
References: <20101126143843.801484792@chello.nl>
	 <alpine.LSU.2.00.1101172301340.2899@sister.anvils>
	 <1295457039.28776.137.camel@laptop>
	 <alpine.LSU.2.00.1101201052060.1603@sister.anvils>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Fri, 21 Jan 2011 16:33:54 +0100
Message-ID: <1295624034.28776.303.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Nick Piggin <npiggin@kernel.dk>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Oleg Nesterov <oleg@redhat.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2011-01-20 at 11:57 -0800, Hugh Dickins wrote:
> > > 21/21 mm-optimize_page_lock_anon_vma_fast-path.patch
> > >       I certainly see the call for this patch, I want to eliminate th=
ose
> > >       doubled atomics too.  This appears correct to me, and I've not =
dreamt
> > >       up an alternative; but I do dislike it, and I suspect you don't=
 like
> > >       it much either.  I'm ambivalent about it, would love a better p=
atch.
> >=20
> > Like said, I fully agree with that sentiment, just haven't been able to
> > come up with anything saner :/ Although I can optimize the
> > __put_anon_vma() path a bit by doing something like:
> >=20
> >   if (mutex_is_locked()) { anon_vma_lock(); anon_vma_unlock(); }
> >=20
> > But I bet that wants a barrier someplace and my head hurts..=20
>=20
> Without daring to hurt my head very much, yes, I'd say those kind
> of "optimizations" have a habit of turning out to be racily wrong.
>=20
> But you put your finger on it: if you hadn't had to add that lock-
> unlock pair into __put_anon_vma(), I wouldn't have minded the
> contortions added to page_lock_anon_vma().=20

I think there's just about enough implied barriers there that the
'simple' code just works ;-)

But given that I'm trying to think with snot for brains thanks to some
cold, I don't trust myself at all to have gotten this right.

[ for Oleg and Paul: https://lkml.org/lkml/2010/11/26/213 contains the
full patch this is against ]

---
Index: linux-2.6/mm/rmap.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/mm/rmap.c
+++ linux-2.6/mm/rmap.c
@@ -1559,9 +1559,20 @@ void __put_anon_vma(struct anon_vma *ano
 	 * Synchronize against page_lock_anon_vma() such that
 	 * we can safely hold the lock without the anon_vma getting
 	 * freed.
+	 *
+	 * Relies on the full mb implied by the atomic_dec_and_test() from
+	 * put_anon_vma() against the full mb implied by mutex_trylock() from
+	 * page_lock_anon_vma(). This orders:
+	 *
+	 * page_lock_anon_vma()		VS	put_anon_vma()
+	 *   mutex_trylock()			  atomic_dec_and_test()
+	 *   smp_mb()				  smp_mb()
+	 *   atomic_read()			  mutex_is_locked()
 	 */
-	anon_vma_lock(anon_vma);
-	anon_vma_unlock(anon_vma);
+	if (mutex_is_locked(&anon_vma->root->mutex)) {
+		anon_vma_lock(anon_vma);
+		anon_vma_unlock(anon_vma);
+	}
=20
 	if (anon_vma->root !=3D anon_vma)
 		put_anon_vma(anon_vma->root);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
