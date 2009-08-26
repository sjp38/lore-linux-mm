Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 52A566B004F
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 15:18:26 -0400 (EDT)
Date: Wed, 26 Aug 2009 20:17:50 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH 13/12] ksm: fix munlock during exit_mmap deadlock
In-Reply-To: <20090825194530.GU14722@random.random>
Message-ID: <Pine.LNX.4.64.0908261910530.15622@sister.anvils>
References: <Pine.LNX.4.64.0908031304430.16449@sister.anvils>
 <Pine.LNX.4.64.0908031317190.16754@sister.anvils> <20090825145832.GP14722@random.random>
 <20090825152217.GQ14722@random.random> <Pine.LNX.4.64.0908251836050.30372@sister.anvils>
 <20090825181019.GT14722@random.random> <Pine.LNX.4.64.0908251958170.5871@sister.anvils>
 <20090825194530.GU14722@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Izik Eidus <ieidus@redhat.com>, Rik van Riel <riel@redhat.com>, Chris Wright <chrisw@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, "Justin M. Forbes" <jmforbes@linuxtx.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Before getting down to details, let me say I'm giving your patch an
Acked-for-now-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>

On Tue, 25 Aug 2009, Andrea Arcangeli wrote:
> On Tue, Aug 25, 2009 at 07:58:43PM +0100, Hugh Dickins wrote:
> > The original deadlock that 9/12 was about was:
> >     There's a now-obvious deadlock in KSM's out-of-memory handling:
> >     imagine ksmd or KSM_RUN_UNMERGE handling, holding ksm_thread_mutex,
> >     trying to allocate a page to break KSM in an mm which becomes the
> >     OOM victim (quite likely in the unmerge case): it's killed and goes
> >     to exit, and hangs there waiting to acquire ksm_thread_mutex.
> 
> Yes I see that, that was before ksm was capable of noticing that it
> was looping indefinitely triggering COW (allocating memory) on a mm
> with mm_users == 0 selected by the OOM killer for release. Not true
> anymore after ksm_test_exit is introduced in the KSM inner paths... I
> mean that part of the fix is enough.

Not enough, actually - but it would be fair to conclude that I'm being
too much of a perfectionist here, and that your patch easily fixes a
much more important and prevalent issue than I'm trying to address.

Plus it strips out complications introduced by 9/12 which we'd all
be glad to do without if we can - and would deserve a patch of its
own to reintroduce if necessary later.

I've now tried several tests and combinations of patches (with and
without your patch, with and without OOM killer patches I worked on
when testing KSM, and found how often the wrong process is killed).

The case I tested last night, where your patch works fine, is
when a process balloons itself up to OOMing point with an madvise
MADV_UNMERGEABLE: it correctly detects, not mm_users == 0, but the 
pending SIGKILL, and backs out to the point where it gets killed
and all is well.

The case I didn't try last night is doing KSM_RUN_UNMERGE (which
behaves as could happen when ksmd is COWing, though a testcase for
that would be much harder to create).  With your patch, that does
not deadlock as I suggest above, but it cannot proceed without the
OOM killer killing the wrong process i.e. the next candidate after
the mergeable process I'm imagining which now gets ballooned up to
OOMing point.

The OOM killer first selects the right candidate, the process being
ballooned by unmerging; but while break_ksm is trying to get memory
to COW another page in it, holding down_read of mmap_sem, the killed
process reaches the down_write of mmap_sem and hangs there, before
it has freed the memory wanted (because you repositioned ksm_exit).

Page allocation has no way to notice that mm_users is 0 for the mm
being faulted into, nor that there's a TIF_MEMDIE on that task.
But it's not a deadlock, because p->mm is NULL now, so next time
around the OOM killer will skip it (I somewhat disagree with that
behaviour, but that's another story) and select another candidate
to kill, and that should free up a page to let break_ksm get out
to the next mm_users 0 test.

If you say that the OOM killer very often selects the wrong candidate
anyway, so what's the big deal here, I'd have to agree with you: I'd
been hoping to clean up some of that, but until I'm satisfied with and
sent in patches for that, maybe I'm silly to worry about this KSM case.

Certainly we need to worry more, and more urgently, about the hang
I've introduced to Rawhide, which your patch fixes.  (Side note:
I'm not for a moment saying we don't need to fix the KSM end, but
it does seem strange to me that this issue is so easily reproducible
on Rawhide with just an mlockall(MCL_CURRENT|MCL_FUTURE) program.
I couldn't get it with that, had to mmap beyond EOF then ftruncate
up to get it to happen; and nobody has reported the issue with mmotm.
Has anyone looked at why Rawhide's mlockall is not faulting in the
pages, I wonder if there's a separate bug there?)

> 
> > Whereas with down_write(&mm->mmap_sem); up_write(&mm->mmap_sem)
> > just before calling exit_mmap(), the deadlock comes on mmap_sem
> > instead: the exiting OOM-killed task waiting there (for break_cow
> > or the like to up_read mmap_sem), before it has freed any memory
> > to allow break_cow etc. to proceed.
> 
> The whole difference is that now KSM will notice that mm_users is
> already zero and it will release the mmap_sem promptly allowing
> exit_mmap to run...

No, not while it's down inside page allocation.

> 
> > Yes, but one of those checks that mm_users is 0 has to be lie below
> > handle_mm_fault, because mm_users may go to 0 and exit_mmap proceed
> > while one of handle_pte_fault's helpers is waiting to allocate a page
> > (for example; but SMP could race anywhere).  Hence ksm_test_exit()s
> > in mm/memory.c.
> 
> Hmm but you're trying here to perfect something that isn't needed to
> be perfected... and that is a generic issue that always happens with
> the OOM killer. I doesn't make any difference if it's KSM or the
> application that triggered a page fault on the MM. If mmap_sem is hold
> in read mode by a regular application page fault while OOM killer
> fires, the exit_mmap routine will not run until the page fault is
> complete. The SMP race anywhere is the reason the OOM killer has to
> stop a moment before killing a second task to give a chance to the
> task to run exit_mmap...

I think you're imagining the MADV_UNMERGEABLE case which I first
tested: what happens when a process does it to itself.  The problem
arises when one process (ksmd or "echo 2 >run") does it to another.

> 
> > (And as I remarked in the 9/12 comments, it's no use bumping up
> > mm_users in break_ksm, say, though that would be a normal thing to
> > do: that just ensures the memory we'd be waiting for cannot be freed.)
> 
> Yes, that would also prevent KSM to notice that the OOM killer
> selected the mm for release. Well unless we check against mm_users ==
> 1, which only works as only as only ksm does that and no other driver
> similar to KSM ;) so it's not a real solution...
> 
> > just an issue we've not yet found the right fix for ;)
> 
> I think you already did the right fix in simply doing ksm_test_exit
> inside the KSM inner loops and adding as well a dummy
> down_write;up_write in the ksm_exit case where rmap_items exists on
> the mm_slot that is exiting. But there was no need of actually
> teaching the page faults to bail out to react immediately to the OOM
> killer (the task itself will not react immediately) and second
> ksm_exit with its serializing down_write should be moved back before
> exit_mmap and it will have the same effect of my previous patch with
> down_write (s/read/write) just before exit_mmap.
> 
> > The idea I'm currently playing with, would fix one of your objections
> > but violate another, is to remove the ksm_test_exit()s from mm/memory.c,
> > allow KSM to racily fault in too late, but observe mm_users 0 afterwards
> > and zap it then.
> 
> ;)
> 
> > I agree with you that it seems _wrong_ for KSM to fault into an area
> > being exited, which was why the ksm_test_exit()s; but the neatest
> > answer might turn out to be to allow it to do so after all.
> 
> Hmm no... I think it's definitely asking for troubles, I would agree
> with you if an immediate reaction to OOM killer would actually provide
> any benefit, but I don't see the benefit, and this makes exit_mmap
> simpler, and it avoids messing with tlb_gather and putting a
> definitive stop on KSM before pagetables are freed.

I still like the idea of that solution (if ksm_test_exit zap_page_range
in break_ksm); however, I believe it too hits a problem with exit_mmap's
munlocking - since I didn't have any serialization there, it couldn't
know which side of the munlocking it is, so would be liable to do the
wrong thing with respect to VM_LOCKED areas, one way or the other.

But you don't like that approach at all, hmm.  It sounds like we'll
have a fight if I try either that or to reintroduce the ksm_test_exits
in memory.c, once the munlock faulting is eliminated.  Well, I'll give
it more thought: your patch is a lot better than the status quo,
and should go in for now - thanks.

> 
> I did this new patch what you think? And any further change in the
> anti-oom-deadlock area if still needed, should reside on ksm.c.
> 
> --------
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> Allowing page faults triggered by drivers tracking the mm during
> exit_mmap with mm_users already zero is asking for troubles. And we
> can't stop page faults from happening during exit_mmap or munlock fails
> (munlock also better stop triggering page faults with mm_users zero).
> 
> ksm_exit if there are rmap_items still chained on this mm slot, will
> take mmap_sem write side so preventing ksm to keep working on a mm while
> exit_mmap runs. And ksm will bail out as soon as it notices that
> mm_users is already zero thanks to the ksm_test_exit checks. So that
> when a task is killed by OOM killer or the user, ksm will not
> indefinitely prevent it to run exit_mmap and release its memory. 
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

I disagree with quite a lot of your description, which doesn't even
mention the problem being fixed and how it is fixed; what drivers?
and ksm's ksm_test_exit checks are too high up to really help.
But this is a good patch until we've got a better...

Acked-for-now-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
