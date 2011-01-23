Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 817F76B00E7
	for <linux-mm@kvack.org>; Sun, 23 Jan 2011 06:05:36 -0500 (EST)
Subject: Re: [PATCH 00/21] mm: Preemptibility -v6
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20110122210623.GR17752@linux.vnet.ibm.com>
References: <20101126143843.801484792@chello.nl>
	 <alpine.LSU.2.00.1101172301340.2899@sister.anvils>
	 <1295457039.28776.137.camel@laptop>
	 <alpine.LSU.2.00.1101201052060.1603@sister.anvils>
	 <1295624034.28776.303.camel@laptop>
	 <20110122210623.GR17752@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Sun, 23 Jan 2011 12:03:50 +0100
Message-ID: <1295780630.2274.43.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: paulmck@linux.vnet.ibm.com
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Nick Piggin <npiggin@kernel.dk>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Oleg Nesterov <oleg@redhat.com>
List-ID: <linux-mm.kvack.org>

On Sat, 2011-01-22 at 13:06 -0800, Paul E. McKenney wrote:

> OK, so the anon_vma slab cache is SLAB_DESTROY_BY_RCU.  Presumably
> all callers of page_lock_anon_vma() check the identity of the page
> that got locked, since it might be recycled at any time.  But when
> I look at 2.6.37, I only see checks for NULL.  So I am assuming
> that this code is supposed to prevent such recycling.
>=20
> I am not sure that I am seeing a consistent snapshot of all of the
> relevant code, in particular, I am guessing that the ->lock and ->mutex
> are the result of changes rather than there really being both a spinlock
> and a mutex in anon_vma.=20

Correct, my earlier spinlock -> mutex conversion left is being called
->lock, but Hugh (rightly) pointed out that I should rename it too, so
in the new (as of yet unposted version its called ->mutex).

>  Mainline currently has a lock, FWIW.  But from
> what I do see, I am concerned about the following sequence of events:
>=20
> o	CPU 0 starts executing page_lock_anon_vma() as shown at
> 	https://lkml.org/lkml/2010/11/26/213, fetches the pointer
> 	to anon_vma->root->lock, but does not yet invoke
> 	mutex_trylock().
>=20
> o	CPU 1 executes __put_anon_vma() above on the same VMA
> 	that CPU 0 is attempting to use.  It sees that the
> 	anon_vma->root->mutex (presumably AKA ->lock) is not held,
> 	so it calls anon_vma_free().
>=20
> o	CPU 2 reallocates the anon_vma freed by CPU 1, so that it
> 	now has a non-zero reference count.
>=20
> o	CPU 0 continues execution, incorrectly acquiring a reference
> 	to the now-recycled anon_vma.
>=20
> Or am I misunderstanding what this code is trying to do?

No that is quite right and possible, its one of the many subtle issues
surrounding the existing page_lock_anon_vma(), we can indeed return a
locked anon_vma that is not in fact related to the page we asked it for,
all calling code SHOULD and afaict does deal with that, mostly by
calling things like vma_address(vma, page) for all vma's obtained from
the anon_vma, to verify the page is indeed (or not) part of the vma.

The race we guard against with all the fancy stuff is the page itself
getting unmapped and us returning an anon_vma for an unmapped page.

And of course, returning a locked but free'd anon_vma, that too isn't
allowed ;-)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
