Date: Tue, 10 Jun 2008 17:50:14 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: 2.6.26-rc5-mm2
In-Reply-To: <1213112065.6872.12.camel@lts-notebook>
Message-ID: <Pine.LNX.4.64.0806101723070.23096@blonde.site>
References: <20080609223145.5c9a2878.akpm@linux-foundation.org>
 <200806101728.27486.nickpiggin@yahoo.com.au> <1213112065.6872.12.camel@lts-notebook>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 10 Jun 2008, Lee Schermerhorn wrote:
> On Tue, 2008-06-10 at 17:28 +1000, Nick Piggin wrote:
> > mm/memory.c:do_wp_page
> > //TODO:  is this safe?  do_anonymous_page() does it this way.
> > 
> > That's a bit disheartening. Surely a question like that has to
> > be answered definitively? (hopefully whatever is doing the
> > asking won't get merged until answered)
> 
> I put those C++ TODO comments in there specifically to raise their
> visibility in hopes that someone [like you :)] would notice and maybe
> have an answer to the question.  I noted the issue in the change log as
> well--i.e., that I had moved set_pte_at() to after the lru_cache_add and
> 'new_rmap.   The existing order may be that way for a reason, but it's
> not clear [to me] what that reason is.  As I noted, do_anonymous_page()
> sets the pte after the lru_add and new_rmap.
> 
> I agree, these questions need to be answered and the TODO's resolved
> before merging.   Any thoughts as to the ordering?

The ordering of lru_cache_add*, page_add_*_rmap and set_pte_at does
not matter (but update_mmu_cache must come after set_pte_at not before).

Even if the page table lock were not held across them (it is), I think
their ordering would not matter much (just benign races); though it's
always worth keeping in mind that once you've done the lru_cache_add,
that page is now visible to vmscan.c.

But I'm all in favour of you imposing consistency there (as part of
a wider patch? perhaps not; and do_swap_page does now look out of step).
It can sometimes help when inserting debug checks e.g. on page_mapcount.

I think you'll find the lru_cache_add_active_or_noreclaim could
actually be moved into page_add_new_rmap - I found that helpful when
working on eliminating the PageSwapCache flag (work now grown out of
date, I'm afraid), to know that the page was not publicly visible
until I did lru_cache_add_active at the end of page_add_new_rmap.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
