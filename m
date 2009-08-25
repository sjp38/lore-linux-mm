Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 25ECE6B00A8
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 16:16:24 -0400 (EDT)
Received: from int-mx04.intmail.prod.int.phx2.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.17])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id n7PKGSj3026312
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 16:16:28 -0400
Date: Tue, 25 Aug 2009 19:47:30 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 9/12] ksm: fix oom deadlock
Message-ID: <20090825174730.GR14722@random.random>
References: <Pine.LNX.4.64.0908031304430.16449@sister.anvils>
 <Pine.LNX.4.64.0908031317190.16754@sister.anvils>
 <20090825145832.GP14722@random.random>
 <Pine.LNX.4.64.0908251738070.30372@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0908251738070.30372@sister.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Izik Eidus <ieidus@redhat.com>, Rik van Riel <riel@redhat.com>, Chris Wright <chrisw@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, "Justin M. Forbes" <jmforbes@linuxtx.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 25, 2009 at 06:35:56PM +0100, Hugh Dickins wrote:
> "make munlock fast when mlock is canceled by sigkill".  It's just
> idiotic that munlock (in this case, munlocking pages on exit) should
> be trying to fault in pages, and that causes its own problems when

I also pondered if to address the thing by fixing automatic munlock,
but then I think the same way it's asking for troubles to cause page
faults with mm_users == 0 in munlock, it's also asking for troubles to
cause page faults with mm_users == 0 in ksm. So if munlock is wrong
ksm was also wrong, and I tried to fix ksm not to do that, while
leaving munlock fixage for later/others.. ;)

> I have now made a patch with munlock_vma_pages_range() doing a
> follow_page() loop instead of faulting in; but I've not yet tested

That is a separate problem in my view.

> I'd prefer not to have them too, but haven't yet worked out how to
> get along safely without them.

ok.

> But the mmap_sem is not enough to exclude the mm exiting
> (until __ksm_exit does its little down_write,up_write dance):
> break_cow etc. do the ksm_test_exit check on mm_users before
> proceeding any further, but that's just not enough to prevent
> break_ksm's handle_pte_fault racing with exit_mmap - hence the
> ksm_test_exits in mm/memory.c, to stop ptes being instantiated
> after the final zap thinks it's wiped the pagetables.
> 
> Let's look at your actual patch...

I tried to work out how to get along safely without them, in short my
patch makes mmap_sem + ksm_test_exit check on mm_users before
proceeding any further "enough" (while still allowing ksm loop to bail
out if mm_users suddenly reaches zero because of oom killer).

Furthermore the mmap_sem is already guaranteed l1 hot and exclusive
because we wrote to it a few nanoseconds before calling mmput (to be
fair locked ops are not cheap but I'd rather add two locked op to the
last exit syscall of a thread group than a new branch to every single
page fault as there are tons more page faults than exit syscalls).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
