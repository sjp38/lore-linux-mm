Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 494166B01EE
	for <linux-mm@kvack.org>; Thu, 13 May 2010 17:09:57 -0400 (EDT)
Date: Thu, 13 May 2010 14:09:19 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -v2 4/5] always lock the root (oldest) anon_vma
Message-Id: <20100513140919.0a037845.akpm@linux-foundation.org>
In-Reply-To: <20100513103356.25665186@annuminas.surriel.com>
References: <20100512133815.0d048a86@annuminas.surriel.com>
	<20100512134029.36c286c4@annuminas.surriel.com>
	<20100512210216.GP24989@csn.ul.ie>
	<4BEB18BB.5010803@redhat.com>
	<20100513095439.GA27949@csn.ul.ie>
	<20100513103356.25665186@annuminas.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Linux-MM <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Thu, 13 May 2010 10:33:56 -0400
Rik van Riel <riel@redhat.com> wrote:

> > Looking at the if condition, brk() would appear to be the most important
> > case, right? This would appear to correlate with the reasoning behind
> > that condition in the first place in commit
> > 252c5f94d944487e9f50ece7942b0fbf659c5c31 where sbrk contended on the
> > lock heavily.
> 
> You are right.  Here is a new patch 4/5:
> ---------------------
> 
> Subject: always lock the root (oldest) anon_vma
> 
> Always (and only) lock the root (oldest) anon_vma whenever we do something in an
> anon_vma.  The recently introduced anon_vma scalability is due to the rmap code
> scanning only the VMAs that need to be scanned.  Many common operations still
> took the anon_vma lock on the root anon_vma, so always taking that lock is not
> expected to introduce any scalability issues.
> 
> However, always taking the same lock does mean we only need to take one lock,
> which means rmap_walk on pages from any anon_vma in the vma is excluded from
> occurring during an munmap, expand_stack or other operation that needs to
> exclude rmap_walk and similar functions.
> 
> Also add the proper locking to vma_adjust.
> 
> ...
>
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -325,7 +325,7 @@ static void drop_anon_vma(struct rmap_item *rmap_item)
>  {
>  	struct anon_vma *anon_vma = rmap_item->anon_vma;
>  
> -	if (atomic_dec_and_lock(&anon_vma->ksm_refcount, &anon_vma->lock)) {
> +	if (atomic_dec_and_lock(&anon_vma->ksm_refcount, &anon_vma->root->lock)) {
>  		int empty = list_empty(&anon_vma->head);
>  		anon_vma_unlock(anon_vma);
>  		if (empty)

Well that had me confused for a while.  The anon_vma_unlock(anon_vma)
looks like it's unlocking a different lock from the one which
atomic_dec_and_lock() took.  But I worked it out!  I guess one could
add an anon_vma_atomic_dec_and_lock() to make things nice and
symmetrical, but there seems little point.  A comment would suffice.

It wouldn't hurt to add some nice descriptions to these functions, IMO.


General comment on these patches: I had to fix quite a lot of rejects
and some instances of spin_lock(vma->lock) were missed.  It would have
been a good idea to rename anon_vma.lock to something else early in the
patch series so that unconverted code fails to compile, rather than
causing mysterious bugs.  And if the requirement is that all code
should use the helper functions, the lock should be renamed to
double-underscore-something, with a suitable comment telling people not
to use it directly.


I'm still not very confident that I got them all.

<greps or a while>

What's this, in 

mm/migrate.c:unmap_and_move()?

	/* Drop an anon_vma reference if we took one */
	if (anon_vma && atomic_dec_and_lock(&anon_vma->external_refcount, &anon_vma->lock)) {
		int empty = list_empty(&anon_vma->head);
		spin_unlock(&anon_vma->lock);
		if (empty)
			anon_vma_free(anon_vma);
	}

it looks awfully similar to drop_anon_vma().


I'm not very confident in merging all these onto the current MM pile.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
