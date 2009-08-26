Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id D1BBE6B005A
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 12:18:48 -0400 (EDT)
Received: by pzk6 with SMTP id 6so326285pzk.11
        for <linux-mm@kvack.org>; Wed, 26 Aug 2009 09:18:53 -0700 (PDT)
Subject: Re: [PATCH 13/12] ksm: fix munlock during exit_mmap deadlock
From: "Justin M. Forbes" <jmforbes@linuxtx.org>
In-Reply-To: <20090825194530.GU14722@random.random>
References: <Pine.LNX.4.64.0908031304430.16449@sister.anvils>
	 <Pine.LNX.4.64.0908031317190.16754@sister.anvils>
	 <20090825145832.GP14722@random.random>
	 <20090825152217.GQ14722@random.random>
	 <Pine.LNX.4.64.0908251836050.30372@sister.anvils>
	 <20090825181019.GT14722@random.random>
	 <Pine.LNX.4.64.0908251958170.5871@sister.anvils>
	 <20090825194530.GU14722@random.random>
Content-Type: text/plain
Date: Wed, 26 Aug 2009 11:18:51 -0500
Message-Id: <1251303531.2836.7.camel@fedora64.linuxtx.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Izik Eidus <ieidus@redhat.com>, Rik van Riel <riel@redhat.com>, Chris Wright <chrisw@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2009-08-25 at 21:45 +0200, Andrea Arcangeli wrote:
> On Tue, Aug 25, 2009 at 07:58:43PM +0100, Hugh Dickins wrote:
> > On Tue, 25 Aug 2009, Andrea Arcangeli wrote:
> > > On Tue, Aug 25, 2009 at 06:49:09PM +0100, Hugh Dickins wrote:
> > > Looking ksm.c it should have been down_write indeed...
> > > 
> > > > Nor do we want to change your down_read here to down_write, that will
> > > > just reintroduce the OOM deadlock that 9/12 was about solving.
> > > 
> > > I'm not sure anymore I get what this fix is about...
> > 
> > Yes, it's easy to drop one end of the string while picking up the other ;)
> > 
> > And it wouldn't be exactly the same deadlock, but similar.
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
> ---
> 

After review and testing, this patch passes my tests with KSM enabled.

Acked-by: Justin M. Forbes <jforbes@redhat.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
