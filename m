Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C1FD76007B8
	for <linux-mm@kvack.org>; Mon,  3 May 2010 14:21:32 -0400 (EDT)
Date: Mon, 3 May 2010 11:19:46 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 1/2] mm: Take all anon_vma locks in anon_vma_lock
In-Reply-To: <4BDF0ECC.5080902@redhat.com>
Message-ID: <alpine.LFD.2.00.1005031111170.5478@i5.linux-foundation.org>
References: <20100503121743.653e5ecc@annuminas.surriel.com> <20100503121847.7997d280@annuminas.surriel.com> <alpine.LFD.2.00.1005030940490.5478@i5.linux-foundation.org> <4BDEFF9E.6080508@redhat.com> <alpine.LFD.2.00.1005030958140.5478@i5.linux-foundation.org>
 <4BDF0ECC.5080902@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux.com>
List-ID: <linux-mm.kvack.org>



On Mon, 3 May 2010, Rik van Riel wrote:
> 
> One problem is that we cannot find the VMAs (multiple) from
> the page, except by walking the anon_vma_chain.same_anon_vma
> list.  At the very least, that list requires locking, done
> by the anon_vma.lock.

But that's exactly what we do in rmap_walk() anyway.

But yes, I can well imagine that in other cases we only do the one 
anon_vma. I didn't check who used the lock.

So if we do want to keep the lock in the anon_vma, I would just suggest 
that instead of making "normal" users do lots of locking, make the 
rmap_walk side one.

> A forkbomb could definately end up getting slowed down by
> this patch.  Is there any real workload out there that just
> forks deeper and deeper from the parent process, without
> calling exec() after a generation or two?

Heh. AIM7. Wasn't that why we merged the multiple anon_vma's in the first 
place?

> > So again, my gut feel is that if the lock just were in the vma itself,
> > then the "normal" users would have just one natural lock, while the
> > special case users (rmap_walk_anon) would have to lock each vma it
> > traverses. That would seem to be the more natural way to lock things.
> 
> However ... there's still the issue of page_lock_anon_vma
> in try_to_unmap_anon.

Do we care?

We've not locked them all there, and we've historically not cares about 
the rmap list being "perfect", have we? 

So I _think_ it's just the migration case (and apparently potentially the 
hugepage case) that wants _exact_ information. Which is why I suggest the 
onus of the extra locking should be on _them_, not on the regular code.

I dunno. Again, my objections to the patches are really based more on a 
gut feel of "that can't be the right thing to do" than anything else.

We have _extremely_ few places that walk lists to lock things. And they 
are never "normal" code. Things like that magic "mm_take_all_locks()", for 
example. That is why I then react with "that can't be right" to patches 
like this.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
