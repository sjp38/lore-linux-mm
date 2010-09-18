Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 97EC16B007B
	for <linux-mm@kvack.org>; Sat, 18 Sep 2010 09:19:12 -0400 (EDT)
Date: Sat, 18 Sep 2010 15:19:07 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] fix swapin race condition
Message-ID: <20100918131907.GI18596@random.random>
References: <20100903153958.GC16761@random.random>
 <alpine.LSU.2.00.1009051926330.12092@sister.anvils>
 <alpine.LSU.2.00.1009151534060.5630@tigran.mtv.corp.google.com>
 <20100915234237.GR5981@random.random>
 <alpine.DEB.2.00.1009151703060.7332@tigran.mtv.corp.google.com>
 <20100916210349.GU5981@random.random>
 <alpine.LSU.2.00.1009161905190.2517@tigran.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1009161905190.2517@tigran.mtv.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Greg KH <greg@kroah.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Sep 16, 2010 at 07:31:57PM -0700, Hugh Dickins wrote:
> Indeed yes: I was being lazy, hoping to get you to do my thinking
> for me (in my defence, and in your praise, I have to say that that
> is usually much the quickest strategy :-)  Thank you for the time
> you've spent on it, when I should have tried harder.
> 
> Here's what I think can happen: you may shame me by shooting it down
> immediately, but go ahead!

Can't shoot it. This definitely helped. My previous scenario only
involved threads, so I was only thinking at threads...

> I've cast it in terms of reuse_swap_page(), but I expect it could be
> reformulated to rely on try_to_free_swap() instead, or swapoff+swapon.

It's actually better to formulate in reuse_swap_page terms as it
doesn't require swapoff to trigger.

> A, in do_swap_page(): does page1 = lookup_swap_cache(swap1)
> and comes through the lock_page(page1).
> 
> B, a racing thread of same process, also faults into do_swap_page():
> does page1 = lookup_swap_cache(swap1) and now waits in lock_page(page1),
> but for whatever reason is unlucky not to get the lock any time soon.
> 
> A carries on through do_swap_page(), a write fault, but cannot reuse
> the swap page1 (another reference to swap1).  Unlocks the page1 (but B
> doesn't get it yet), does COW in do_wp_page(), page2 now in that pte.
> 
> C, perhaps the parent of A+B, comes in and write faults the same swap
> page1 into its mm, reuse_swap_page() succeeds this time, swap1 is freed.

The key is C mm is different from the A/B mm. If C was sharing the
same mm (as in the scenario I was thinking of with threads)
reuse_swap_cache couldn't run in C because the pte_same check would
fail.

> kswapd comes in after some time (B still unlucky) and swaps out some
> pages from A+B and C: it allocates the original swap1 to page2 in A+B,
> and some other swap2 to the original page1 now in C.  But does not
> immediately free page1 (actually it couldn't: B holds a reference),
> leaving it in swap cache for now.
> 
> B at last gets the lock on page1, hooray!  Is PageSwapCache(page1)?
> Yes.  Is pte_same(*page_table, orig_pte)?  Yes, because page2 has
> now been given the swap1 which page1 used to have.  So B proceeds
> to insert page1 into A+B's page_table, though its content now
> belongs to C, quite different from what A wrote there.
> 
> B ought to have checked that page1's swap was still swap1.

I suggest adding the explanation to the patch comment.

Thanks!
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
