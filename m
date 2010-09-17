Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id A97926B0078
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 22:32:08 -0400 (EDT)
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [172.25.149.3])
	by smtp-out.google.com with ESMTP id o8H2W9Zd028339
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 19:32:09 -0700
Received: from iwn3 (iwn3.prod.google.com [10.241.68.67])
	by hpaq3.eem.corp.google.com with ESMTP id o8H2W6G7022385
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 19:32:07 -0700
Received: by iwn3 with SMTP id 3so2475546iwn.17
        for <linux-mm@kvack.org>; Thu, 16 Sep 2010 19:32:06 -0700 (PDT)
Date: Thu, 16 Sep 2010 19:31:57 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] fix swapin race condition
In-Reply-To: <20100916210349.GU5981@random.random>
Message-ID: <alpine.LSU.2.00.1009161905190.2517@tigran.mtv.corp.google.com>
References: <20100903153958.GC16761@random.random> <alpine.LSU.2.00.1009051926330.12092@sister.anvils> <alpine.LSU.2.00.1009151534060.5630@tigran.mtv.corp.google.com> <20100915234237.GR5981@random.random> <alpine.DEB.2.00.1009151703060.7332@tigran.mtv.corp.google.com>
 <20100916210349.GU5981@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Greg KH <greg@kroah.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 16 Sep 2010, Andrea Arcangeli wrote:
> On Wed, Sep 15, 2010 at 05:10:36PM -0700, Hugh Dickins wrote:
> > I agree that if my scenario happened on its own, the pte_same check
> > would catch it.  But if my scenario happens along with your scenario
> > (and I'm thinking that the combination is not that much less likely
> > than either alone), then the PageSwapCache test will succeed and the
> > pte_same test will succeed, but we're still putting the wrong page into
> > the pte, since this page is now represented by a different swap entry
> > (and the page that should be there by our original swap entry).
> 
> If I understood well you're saying that it is possible that this
> BUG_ON triggers:
> 
>    page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
>    BUG_ON(page_private(page) != entry.val && pte_same(*page_table, orig_pte));
>    if (unlikely(!pte_same(*page_table, orig_pte)))

Yes, I believe so.

> 
> I still don't get it (that doesn't make me right though).
> 
> I'll try to rephrase my argument: if the page was swapped in from
> swapcache by swapoff and then swapon runs again and the page is added
> to swapcache to a different swap entry, in between the
> lookup_swap_cache and the lock_page, the pte_same(*page_table,
> orig_pte) in pte_same should always fail in the first place (so
> without requiring the page_private(page) != entry.val check).

Usually yes, but more may have happened in between.

> 
> If the page is found mapped during pte_same the pte_same check will
> fail (pte_present first of all). If the page got unmapped and
> page_private(page) != entry.val, the "entry" == "orig_pte" will be
> different to what we read in *page_table at the above BUG_ON line (the
> page has to be unmapped before pte_same check can succeed, but if gets
> unmapped the new swap entry will be written in the page_table and it
> won't risk to succeed the pte_same check).

Usually yes, but not necessarily.

> 
> If the page wasn't mapped when it was removed from swapcache, it can't
> be added to swapcache at all because it was pinned: because only free
> pages (during swapin) or mapped pages (during swapout) can be added to
> swapcache.

Yes, I think that happens to be the case, but does not rule out my
scenario.  Perhaps there's a page_count test that I've overlooked
that makes my scenario impossible, but is_page_cache_freeable()
appears to prevent writeout without affecting swap allocation.

> 
> If I'm missing something a trace of the exact scenario would help to
> clarify your point.

Indeed yes: I was being lazy, hoping to get you to do my thinking
for me (in my defence, and in your praise, I have to say that that
is usually much the quickest strategy :-)  Thank you for the time
you've spent on it, when I should have tried harder.

Here's what I think can happen: you may shame me by shooting it down
immediately, but go ahead!

I've cast it in terms of reuse_swap_page(), but I expect it could be
reformulated to rely on try_to_free_swap() instead, or swapoff+swapon.


A, in do_swap_page(): does page1 = lookup_swap_cache(swap1)
and comes through the lock_page(page1).

B, a racing thread of same process, also faults into do_swap_page():
does page1 = lookup_swap_cache(swap1) and now waits in lock_page(page1),
but for whatever reason is unlucky not to get the lock any time soon.

A carries on through do_swap_page(), a write fault, but cannot reuse
the swap page1 (another reference to swap1).  Unlocks the page1 (but B
doesn't get it yet), does COW in do_wp_page(), page2 now in that pte.

C, perhaps the parent of A+B, comes in and write faults the same swap
page1 into its mm, reuse_swap_page() succeeds this time, swap1 is freed.

kswapd comes in after some time (B still unlucky) and swaps out some
pages from A+B and C: it allocates the original swap1 to page2 in A+B,
and some other swap2 to the original page1 now in C.  But does not
immediately free page1 (actually it couldn't: B holds a reference),
leaving it in swap cache for now.

B at last gets the lock on page1, hooray!  Is PageSwapCache(page1)?
Yes.  Is pte_same(*page_table, orig_pte)?  Yes, because page2 has
now been given the swap1 which page1 used to have.  So B proceeds
to insert page1 into A+B's page_table, though its content now
belongs to C, quite different from what A wrote there.

B ought to have checked that page1's swap was still swap1.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
