Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 716E16B00E7
	for <linux-mm@kvack.org>; Sat, 22 Jan 2011 16:06:32 -0500 (EST)
Received: from d01dlp01.pok.ibm.com (d01dlp01.pok.ibm.com [9.56.224.56])
	by e8.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p0MKmwld032723
	for <linux-mm@kvack.org>; Sat, 22 Jan 2011 15:48:58 -0500
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id EF1E2728049
	for <linux-mm@kvack.org>; Sat, 22 Jan 2011 16:06:27 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p0ML6ROS249912
	for <linux-mm@kvack.org>; Sat, 22 Jan 2011 16:06:27 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p0ML6Q6J028968
	for <linux-mm@kvack.org>; Sat, 22 Jan 2011 16:06:27 -0500
Date: Sat, 22 Jan 2011 13:06:23 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 00/21] mm: Preemptibility -v6
Message-ID: <20110122210623.GR17752@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20101126143843.801484792@chello.nl>
 <alpine.LSU.2.00.1101172301340.2899@sister.anvils>
 <1295457039.28776.137.camel@laptop>
 <alpine.LSU.2.00.1101201052060.1603@sister.anvils>
 <1295624034.28776.303.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1295624034.28776.303.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Nick Piggin <npiggin@kernel.dk>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Oleg Nesterov <oleg@redhat.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jan 21, 2011 at 04:33:54PM +0100, Peter Zijlstra wrote:
> On Thu, 2011-01-20 at 11:57 -0800, Hugh Dickins wrote:
> > > > 21/21 mm-optimize_page_lock_anon_vma_fast-path.patch
> > > >       I certainly see the call for this patch, I want to eliminate those
> > > >       doubled atomics too.  This appears correct to me, and I've not dreamt
> > > >       up an alternative; but I do dislike it, and I suspect you don't like
> > > >       it much either.  I'm ambivalent about it, would love a better patch.
> > > 
> > > Like said, I fully agree with that sentiment, just haven't been able to
> > > come up with anything saner :/ Although I can optimize the
> > > __put_anon_vma() path a bit by doing something like:
> > > 
> > >   if (mutex_is_locked()) { anon_vma_lock(); anon_vma_unlock(); }
> > > 
> > > But I bet that wants a barrier someplace and my head hurts.. 
> > 
> > Without daring to hurt my head very much, yes, I'd say those kind
> > of "optimizations" have a habit of turning out to be racily wrong.
> > 
> > But you put your finger on it: if you hadn't had to add that lock-
> > unlock pair into __put_anon_vma(), I wouldn't have minded the
> > contortions added to page_lock_anon_vma(). 
> 
> I think there's just about enough implied barriers there that the
> 'simple' code just works ;-)
> 
> But given that I'm trying to think with snot for brains thanks to some
> cold, I don't trust myself at all to have gotten this right.
> 
> [ for Oleg and Paul: https://lkml.org/lkml/2010/11/26/213 contains the
> full patch this is against ]
> 
> ---
> Index: linux-2.6/mm/rmap.c
> ===================================================================
> --- linux-2.6.orig/mm/rmap.c
> +++ linux-2.6/mm/rmap.c
> @@ -1559,9 +1559,20 @@ void __put_anon_vma(struct anon_vma *ano
>  	 * Synchronize against page_lock_anon_vma() such that
>  	 * we can safely hold the lock without the anon_vma getting
>  	 * freed.
> +	 *
> +	 * Relies on the full mb implied by the atomic_dec_and_test() from
> +	 * put_anon_vma() against the full mb implied by mutex_trylock() from
> +	 * page_lock_anon_vma(). This orders:
> +	 *
> +	 * page_lock_anon_vma()		VS	put_anon_vma()
> +	 *   mutex_trylock()			  atomic_dec_and_test()
> +	 *   smp_mb()				  smp_mb()
> +	 *   atomic_read()			  mutex_is_locked()
>  	 */
> -	anon_vma_lock(anon_vma);
> -	anon_vma_unlock(anon_vma);
> +	if (mutex_is_locked(&anon_vma->root->mutex)) {
> +		anon_vma_lock(anon_vma);
> +		anon_vma_unlock(anon_vma);
> +	}
>  
>  	if (anon_vma->root != anon_vma)
>  		put_anon_vma(anon_vma->root);
> 

OK, so the anon_vma slab cache is SLAB_DESTROY_BY_RCU.  Presumably
all callers of page_lock_anon_vma() check the identity of the page
that got locked, since it might be recycled at any time.  But when
I look at 2.6.37, I only see checks for NULL.  So I am assuming
that this code is supposed to prevent such recycling.

I am not sure that I am seeing a consistent snapshot of all of the
relevant code, in particular, I am guessing that the ->lock and ->mutex
are the result of changes rather than there really being both a spinlock
and a mutex in anon_vma.  Mainline currently has a lock, FWIW.  But from
what I do see, I am concerned about the following sequence of events:

o	CPU 0 starts executing page_lock_anon_vma() as shown at
	https://lkml.org/lkml/2010/11/26/213, fetches the pointer
	to anon_vma->root->lock, but does not yet invoke
	mutex_trylock().

o	CPU 1 executes __put_anon_vma() above on the same VMA
	that CPU 0 is attempting to use.  It sees that the
	anon_vma->root->mutex (presumably AKA ->lock) is not held,
	so it calls anon_vma_free().

o	CPU 2 reallocates the anon_vma freed by CPU 1, so that it
	now has a non-zero reference count.

o	CPU 0 continues execution, incorrectly acquiring a reference
	to the now-recycled anon_vma.

Or am I misunderstanding what this code is trying to do?

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
