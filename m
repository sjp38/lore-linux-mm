Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 3B1F26B01EF
	for <linux-mm@kvack.org>; Wed, 12 May 2010 17:58:31 -0400 (EDT)
Date: Wed, 12 May 2010 14:55:33 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 4/5] always lock the root (oldest) anon_vma
In-Reply-To: <20100512134029.36c286c4@annuminas.surriel.com>
Message-ID: <alpine.LFD.2.00.1005121441350.3711@i5.linux-foundation.org>
References: <20100512133815.0d048a86@annuminas.surriel.com> <20100512134029.36c286c4@annuminas.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Linux-MM <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>



On Wed, 12 May 2010, Rik van Riel wrote:
> 
> Always (and only) lock the root (oldest) anon_vma whenever we do 
> something in an anon_vma.  The recently introduced anon_vma scalability 
> is due to the rmap code scanning only the VMAs that need to be scanned.  
> Many common operations still took the anon_vma lock on the root 
> anon_vma, so always taking that lock is not expected to introduce any 
> scalability issues.

Ack for this (and the whole series, for that matter - looks fine to me). 

Somebody should run the performance numbers with AIM7 or whatever, just to 
check that the lock isn't a problem, but this approach certainly gets rid 
of all my objections about crazy locking. 

That patch #5 is pretty ugly, though. And I think this part (in 
drop_anon_vma) is approaching being wrong:

+       if (atomic_dec_and_lock(&anon_vma->ksm_refcount, &anon_vma->root->lock)) {

because I do _not_ believe that you need to decrement that ksm_refcount 
under the lock, do you? It's just a refcount, isn't it?

Wouldn't it be sufficient to do

	if (atomic_dec_and_test(&anon_vma->ksm_refcount)) {
		anon_vma_lock(anon_vma);

instead? The "atomic_dec_and_lock()" semantics are _much_ stricter than a 
regular "decrement and test and then lock", and that strictness means that 
it's way more complicated and expensive. So if you don't need the 
semantics, you shouldn't use them.

But maybe we do need those "lock before decrementing to zero" semantics. 
The old ksm.c code had it too, although I suspect it's just being 
confused.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
