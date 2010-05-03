Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id D9BC26007B8
	for <linux-mm@kvack.org>; Mon,  3 May 2010 13:59:07 -0400 (EDT)
Message-ID: <4BDF0ECC.5080902@redhat.com>
Date: Mon, 03 May 2010 13:58:36 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] mm: Take all anon_vma locks in anon_vma_lock
References: <20100503121743.653e5ecc@annuminas.surriel.com> <20100503121847.7997d280@annuminas.surriel.com> <alpine.LFD.2.00.1005030940490.5478@i5.linux-foundation.org> <4BDEFF9E.6080508@redhat.com> <alpine.LFD.2.00.1005030958140.5478@i5.linux-foundation.org>
In-Reply-To: <alpine.LFD.2.00.1005030958140.5478@i5.linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux.com>
List-ID: <linux-mm.kvack.org>

On 05/03/2010 01:17 PM, Linus Torvalds wrote:

> Quite frankly, I think it's totally insane to walk a list of all
> anon_vma's that are associated with one vma, just to lock them all.
>
> Tell me why you just don't put the lock in the vma itself then? Walking a
> list in order to lock multiple things is something we should _never_ do
> under any normal circumstances.

One problem is that we cannot find the VMAs (multiple) from
the page, except by walking the anon_vma_chain.same_anon_vma
list.  At the very least, that list requires locking, done
by the anon_vma.lock.

When already you have that lock, also taking per-VMA locks
would be superfluous. It could also be difficult, especially
since the rmap side code and the mmap side code approach the
data structures from the other side, potentially leading to
locking order conflicts.

> I can see why you'd want to do this in theory (the "other side" of the
> locker might have to lock just the _one_ anon_vma), but if your argument
> is that the list is usually not very deep ("one"?), then there is no
> advantage, because putting the lock in the anon_vma vs the vma will get
> the same kind of contention.

In a freshly exec()d process, there will be one anon_vma.

In workloads with forking daemons, like apache, postgresql
or sendmail, the child process will end up with two anon_vmas
in VMAs inherited from the parent.

> And if the list _is_ deep, then walking the list to lock them all is a
> crime against humanity.

A forkbomb could definately end up getting slowed down by
this patch.  Is there any real workload out there that just
forks deeper and deeper from the parent process, without
calling exec() after a generation or two?

>> As for patch 2/2, Mel has an alternative approach for that:
>>
>> http://lkml.org/lkml/2010/4/30/198
>>
>> Does Mel's patch seem more reasonable to you?
>
> Well, I certainly think that seems to be a lot more targeted,

> In particular, why don't we just make rmap_walk() be the one that locks
> all the anon_vma's? Instead of locking just one? THAT is the function that
> cares. THAT is the function that should do proper locking and not expect
> others to do extra unnecessary locking.

That looks like it might work for rmap_walk.

> So again, my gut feel is that if the lock just were in the vma itself,
> then the "normal" users would have just one natural lock, while the
> special case users (rmap_walk_anon) would have to lock each vma it
> traverses. That would seem to be the more natural way to lock things.

However ... there's still the issue of page_lock_anon_vma
in try_to_unmap_anon.

I guess it protects against any of the VMAs going away,
because anon_vma_unlink also takes the anon_vma->lock.

Does it need to protect against anything else?

> Btw, Mel's patch doesn't really match the description of 2/2. 2/2 says
> that all pages must always be findable in rmap. Mel's patch seems to
> explicitly say "we want to ignore that thing that is busy for execve". Are
> we just avoiding a BUG_ON()? Is perhaps the BUG_ON() buggy?

I have no good answer to this question.

Mel?  Andrea?

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
