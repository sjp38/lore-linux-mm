Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id CDDD66B00DE
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 18:04:37 -0400 (EDT)
Date: Tue, 25 Aug 2009 18:35:56 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH 9/12] ksm: fix oom deadlock
In-Reply-To: <20090825145832.GP14722@random.random>
Message-ID: <Pine.LNX.4.64.0908251738070.30372@sister.anvils>
References: <Pine.LNX.4.64.0908031304430.16449@sister.anvils>
 <Pine.LNX.4.64.0908031317190.16754@sister.anvils> <20090825145832.GP14722@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Izik Eidus <ieidus@redhat.com>, Rik van Riel <riel@redhat.com>, Chris Wright <chrisw@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, "Justin M. Forbes" <jmforbes@linuxtx.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 25 Aug 2009, Andrea Arcangeli wrote:
> On Mon, Aug 03, 2009 at 01:18:16PM +0100, Hugh Dickins wrote:
> > tables which have been freed for reuse; and even do_anonymous_page
> > and __do_fault need to check they're not being called by break_ksm
> > to reinstate a pte after zap_pte_range has zapped that page table.
> 
> This deadlocks exit_mmap in an infinite loop when there's some region
> locked. mlock calls gup and pretends to page fault successfully if
> there's a vma existing on the region, but it doesn't page fault
> anymore because of the mm_count being 0 already, so follow_page fails
> and gup retries the page fault forever.

That's right.  Justin alerted me to this issue last night, and at first
I was utterly mystified (and couldn't reproduce).  But a look at the
.jpg in the Fedora bugzilla, and another look at KSM 9/12, brought
me to the same conclusion that you've reached.

The _right_ solution (without even knowing of this problem) is
coincidentally being discussed currently in a different thread,
"make munlock fast when mlock is canceled by sigkill".  It's just
idiotic that munlock (in this case, munlocking pages on exit) should
be trying to fault in pages, and that causes its own problems when
mlock of a large area goes OOM and invokes the OOM killer on itself
(the munlock hangs trying to fault in what the mlock failed to do:
at this instant I forget whether that deadlocks the system, or
causes the wrong processes to be killed - I've several other OOM
fixes to make).

I have now made a patch with munlock_vma_pages_range() doing a
follow_page() loop instead of faulting in; but I've not yet tested
it properly, and it's rather mixed up with three other topics
(a coredump GUP flag to __get_user_pages to govern the ZERO_PAGE
shortcut, instead of confused guesses; reinstating do_anonymous
ZERO_PAGE; cleaning away unnecessary GUP flags).  It's something
that will need exposure in mmotm before going any further, whereas
this ksm_test_exit() issue needs a safe fix quicker than that.

I was pondering what to do when you wrote in.

> And generally I don't like to add those checks to page fault fast path.

I'd prefer not to have them too, but haven't yet worked out how to
get along safely without them.

> 
> Given we check mm_users == 0 (ksm_test_exit) after taking mmap_sem in
> unmerge_and_remove_all_rmap_items, why do we actually need to care
> that a page fault happens? We hold mmap_sem so we're guaranteed to see
> mm_users == 0 and we won't ever break COW on that mm with mm_users ==
> 0 so I think those troublesome checks from page fault can be simply
> removed.

break_ksm called from madvise(,,MADV_UNMERGEABLE) does have down_write
of mmap_sem.  break_ksm called from "echo 2 >/sys/kernel/mm/ksm/run"
has down_read of mmap_sem (taken in unmerge_and_remove_all_rmap_items).
break_ksm called from any of ksmd's break_cows has down_read of mmap_sem.

But the mmap_sem is not enough to exclude the mm exiting
(until __ksm_exit does its little down_write,up_write dance):
break_cow etc. do the ksm_test_exit check on mm_users before
proceeding any further, but that's just not enough to prevent
break_ksm's handle_pte_fault racing with exit_mmap - hence the
ksm_test_exits in mm/memory.c, to stop ptes being instantiated
after the final zap thinks it's wiped the pagetables.

Let's look at your actual patch...

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
