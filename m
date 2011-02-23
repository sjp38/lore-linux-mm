Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id AAB748D0039
	for <linux-mm@kvack.org>; Wed, 23 Feb 2011 18:12:23 -0500 (EST)
Received: from kpbe19.cbf.corp.google.com (kpbe19.cbf.corp.google.com [172.25.105.83])
	by smtp-out.google.com with ESMTP id p1NNCJF4016615
	for <linux-mm@kvack.org>; Wed, 23 Feb 2011 15:12:20 -0800
Received: from yic13 (yic13.prod.google.com [10.243.65.141])
	by kpbe19.cbf.corp.google.com with ESMTP id p1NNBt9b009714
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 23 Feb 2011 15:12:18 -0800
Received: by yic13 with SMTP id 13so460997yic.17
        for <linux-mm@kvack.org>; Wed, 23 Feb 2011 15:12:13 -0800 (PST)
Date: Wed, 23 Feb 2011 15:12:02 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: prevent concurrent unmap_mapping_range() on the same
 inode
In-Reply-To: <AANLkTimeihuzjgR2f7Avq2PJrCw1vZxtjh=wBPXO3aHP@mail.gmail.com>
Message-ID: <alpine.LSU.2.00.1102231448460.5732@sister.anvils>
References: <E1PsEA7-0007G0-29@pomaz-ex.szeredi.hu> <AANLkTimeihuzjgR2f7Avq2PJrCw1vZxtjh=wBPXO3aHP@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Miklos Szeredi <miklos@szeredi.hu>, akpm@linux-foundation.org, hch@infradead.org, a.p.zijlstra@chello.nl, gurudas.pai@oracle.com, lkml20101129@newton.leun.net, rjw@sisk.pl, florian@mickler.org, trond.myklebust@fys.uio.no, maciej.rutecki@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 23 Feb 2011, Linus Torvalds wrote:
> On Wed, Feb 23, 2011 at 4:49 AM, Miklos Szeredi <miklos@szeredi.hu> wrote:
> >
> > This resolves Bug 25822 listed in the regressions since 2.6.36 (though
> > it's a bug much older than that, for some reason it only started
> > triggering for people recently).
> 
> Gaah. I hate this patch. It is, in fact, a patch that makes me finally
> think that the mm preemptibility is actually worth it, because then
> i_mmap_lock turns into a mutex and makes the whole "drop the lock"
> thing hopefully a thing of the past (see the patch "mm: Remove
> i_mmap_mutex lockbreak").
> 
> Because as far as I can see, the only thing that makes this thing
> needed in the first place is that horribly ugly "we drop i_mmap_lock
> in the middle of random operations that really still need it".
> 
> That said, I don't really see any alternatives - I guess we can't
> really just say "remove that crazy lock dropping". Even though I
> really really really would like to.

Those feelings understood and shared.

> 
> Of course, we could also just decide that we should apply the mm
> preemptibility series instead. Can people confirm that that fixes the
> bug too?

It would fix it, but there's a but.

In his [2/8] mm: remove i_mmap_mutex lockbreak patch, Peter says
"shouldn't hold up reclaim more than lock_page() would".  But (apart
from a write error case) we always use trylock_page() in reclaim, we
never dare hold it up on a lock_page().  So page reclaim would get
held up on truncation more than at present - though he's right to
point out that truncation will usually be freeing pages much faster.

I'm not sure whether it will prove good enough to abandon the lock
breaking if we move to a mutex there.  And besides, this unmapping
BUG does need a fix in stable, well before we want to try out the
preemptible mmu gathering.

I'd rather hold out Peter's series as a hope that we can
eliminate this extra unmapping mutex in a few months time.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
