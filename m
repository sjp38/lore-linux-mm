Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 245AD6B00C5
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 17:40:36 -0400 (EDT)
Date: Tue, 25 Aug 2009 19:58:43 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH 13/12] ksm: fix munlock during exit_mmap deadlock
In-Reply-To: <20090825181019.GT14722@random.random>
Message-ID: <Pine.LNX.4.64.0908251958170.5871@sister.anvils>
References: <Pine.LNX.4.64.0908031304430.16449@sister.anvils>
 <Pine.LNX.4.64.0908031317190.16754@sister.anvils> <20090825145832.GP14722@random.random>
 <20090825152217.GQ14722@random.random> <Pine.LNX.4.64.0908251836050.30372@sister.anvils>
 <20090825181019.GT14722@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Izik Eidus <ieidus@redhat.com>, Rik van Riel <riel@redhat.com>, Chris Wright <chrisw@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, "Justin M. Forbes" <jmforbes@linuxtx.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 25 Aug 2009, Andrea Arcangeli wrote:
> On Tue, Aug 25, 2009 at 06:49:09PM +0100, Hugh Dickins wrote:
> Looking ksm.c it should have been down_write indeed...
> 
> > Nor do we want to change your down_read here to down_write, that will
> > just reintroduce the OOM deadlock that 9/12 was about solving.
> 
> I'm not sure anymore I get what this fix is about...

Yes, it's easy to drop one end of the string while picking up the other ;)

And it wouldn't be exactly the same deadlock, but similar.
The original deadlock that 9/12 was about was:
    There's a now-obvious deadlock in KSM's out-of-memory handling:
    imagine ksmd or KSM_RUN_UNMERGE handling, holding ksm_thread_mutex,
    trying to allocate a page to break KSM in an mm which becomes the
    OOM victim (quite likely in the unmerge case): it's killed and goes
    to exit, and hangs there waiting to acquire ksm_thread_mutex.

Whereas with down_write(&mm->mmap_sem); up_write(&mm->mmap_sem)
just before calling exit_mmap(), the deadlock comes on mmap_sem
instead: the exiting OOM-killed task waiting there (for break_cow
or the like to up_read mmap_sem), before it has freed any memory
to allow break_cow etc. to proceed.

> mm_users is
> allowed to go to 0. If mm_users is allowed to go to 0, it's up to ksm
> to check inside its inner loops that mm_users is 0 and bail
> out. Bailing out it will unblock exit so that exit_mmap can run.

Yes, but one of those checks that mm_users is 0 has to be lie below
handle_mm_fault, because mm_users may go to 0 and exit_mmap proceed
while one of handle_pte_fault's helpers is waiting to allocate a page
(for example; but SMP could race anywhere).  Hence ksm_test_exit()s
in mm/memory.c.

(And as I remarked in the 9/12 comments, it's no use bumping up
mm_users in break_ksm, say, though that would be a normal thing to
do: that just ensures the memory we'd be waiting for cannot be freed.)

> What exactly is the unfixable issue?

Oh, there's no unfixable issue,
just an issue we've not yet found the right fix for ;)

The idea I'm currently playing with, would fix one of your objections
but violate another, is to remove the ksm_test_exit()s from mm/memory.c,
allow KSM to racily fault in too late, but observe mm_users 0 afterwards
and zap it then.

I agree with you that it seems _wrong_ for KSM to fault into an area
being exited, which was why the ksm_test_exit()s; but the neatest
answer might turn out to be to allow it to do so after all.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
