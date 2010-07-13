Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8A5AD6B02A4
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 17:30:48 -0400 (EDT)
Received: from kpbe19.cbf.corp.google.com (kpbe19.cbf.corp.google.com [172.25.105.83])
	by smtp-out.google.com with ESMTP id o6DLUjnf001352
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 14:30:45 -0700
Received: from pwj8 (pwj8.prod.google.com [10.241.219.72])
	by kpbe19.cbf.corp.google.com with ESMTP id o6DLUhVs019205
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 14:30:44 -0700
Received: by pwj8 with SMTP id 8so3605425pwj.23
        for <linux-mm@kvack.org>; Tue, 13 Jul 2010 14:30:43 -0700 (PDT)
Date: Tue, 13 Jul 2010 14:30:34 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] fix swapin race condition
In-Reply-To: <20100713010804.GB31974@random.random>
Message-ID: <alpine.DEB.1.00.1007131320170.20413@tigran.mtv.corp.google.com>
References: <20100709002322.GO6197@random.random> <alpine.DEB.1.00.1007091242430.8201@tigran.mtv.corp.google.com> <20100713010804.GB31974@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, 13 Jul 2010, Andrea Arcangeli wrote:
> On Fri, Jul 09, 2010 at 01:32:45PM -0700, Hugh Dickins wrote:
> > It is well established that by the time lookup_swap_cache() returns,
> > the page it returns may already have been removed from swapcache:
> > yes, you have to get page lock to be sure.  Long ago I put a comment 
> > on that into lookup_swap_cache(), but it fell out of the 2.6 version
> > when we briefly changed how that one worked.
> 
> I found it by code review only, so it was unexpected to me. I assume
> it was unexpected to do_swap_cache as well if you agree this is a bug
> too and it could trigger in theory.

I _was_ disagreeing with you that there's such a bug in do_swap_page(),
beyond the recent KSM case you discovered and first drew attention to.
But you should have argued with me, when I questioned the need for the
extra PageSwapCache test you add to do_swap_page().

Thinking it over again, I now see what I think you moved on to saying
after highlighting the ksm_might_need_to_copy() case: never mind KSM,
that pte_same() test has been inadequate ever since it came in 2.4.8.

Because it's conceivable that before do_swap_page() gets lock_page(),
a racing thread could swap in the page for writing, COW it, the original
page be deleted from swap cache and its swap freed, the new page be
modified and then swapped out, and happen to get exactly the same
swap slot as the original had: pte_same!  In which case, without your
PageSwapCache test after lock_page(), the code goes on to insert the
now out-of-date version of the page in place of the modified version.

All very very unlikely; and some of those details impossible before
2.6.29, when I scrapped the exclusive page_count requirement of
remove_exclusive_swap_page - but the scenario still made possible
from earliest days by swapoff, which never cared about page_count.

> 
> In the old days I'm quite sure lookup_swap_cache wouldn't return a
> page evicted by swapcache I think,

If by old days you mean 2.2, yes, its lookup_swap_cache() returned a
locked page.  But 2.4 and 2.6 always returned an unlocked page, which
could already have been evicted from swapcache: as we realized in 2.4.10.

> but this looks good so we can run
> try_to_free_swap and release swap space, without care of the page pins
> and we decouple the actual pinning of the page from keeping the swap
> entry pinned too. Just unexpected to me when reading do_swap_page,
> while being used to the "secular" semantics of lookup_swap_cache ;).
> 
> I also thought maybe lookup_swap_cache could return the page locked or
> return NULL, but then there's the same problem in the regular swapin
> that is async and the lock will go away when I/O completes, so there's
> still a window for the same race, so I thought it's not worth locking
> anything in lookup_swap_cache.
> 
> >
> > It can even happen when swap is near empty: through swapoff,
> > or through reuse_swap_page(), at least.
> 
> Agreed, it can also happen with threads swapping in a not shared anon
> page.
> 
> > I'm not aware of any bug we have from that, but sure, it comes as a
> > surprise when you realize it.
> 
> :)
> 
> > > It's also possible to fix it by forcing do_wp_page to run but for a
> > > little while it won't be possible to rmap the the instantiated page so
> > > I didn't change that even if it probably would make life easier to
> > > memcg swapin handlers (maybe, dunno).
> > 
> > That's an interesting idea.  I'm not clear what you have in mind there,
> > but if we could get rid of ksm_does_need_to_copy(), letting do_wp_page()
> > do the copy instead, that would be very satisfying.  However, I suspect
> > it would rather involve tricking do_wp_page() into doing it, involve a
> > number of hard-to-maintain hacks, appealing to me but to nobody else!
> 
> It's actually next to trivial to make that change and it eliminates a
> dozen lines of code. I didn't to just make a strict fix that doesn't
> alter any logic of the code. But it's just enough to do:
> 
> if (ksm_might_need_to_copy())
>    flags |= FAULT_FLAG_WRITE;

That's very attractive, but I think you'll find it's not quite as
simple as that.

For a start, there's still the CONFIG_DEBUG_VM BUG_ON page->index
test in __page_check_anon_rmap(): perhaps we could just give up on
__page_check_anon_rmap(), though Nick likes it.  Then reuse_swap_page()
will be liable to let the same page be used, though its page->mapping
points to an irrelevant anon_vma - leaving the page rmap-unfindable
thereafter.  That could perhaps be fixed by forcing page->mapping and
page->index when reusing, but that will be something new: changing
page_anon_vma(page) while page is in use, perhaps that will turn out
to be safe while the page is locked, but would need an audit.  There
may be other gotchas, I've not thought further.

But I do like very much your idea of deleting ksm_does_need_to_copy(),
letting do_wp_page() do the work: it's easy to imagine people updating
do_wp_page() copying and forgetting to update ksm_does_need_to_copy().

Hugh

> 
> Then the whole ksm_does_need_to_copy and swapcache variable and the
> rest of the code I added goes away (only the pageswapcache check after
> page_lock remains for the bug discussed at the top). pte_same in
> do_wp_page and do_swap_page then become both reliable because
> do_swap_page locks the swapcache before changing the pte to point to
> the page, and do_wp_page pins the old page before doing pte_same. So
> there's no risk of swap entry reuse that way and it eliminates some
> code.
> 
> Only downside of ksm_does_need_to_copy removal: rmappability of the
> swapcache for a ksm-swapin that isn't linear becomes impossible for a
> little window of time, but only split_huge_page requires rmappability
> always (only transparent hugepages are required to be precisely
> rmapped at all times if they are ever established in any
> pmd_trans_huge pmd), and migrate only requires what is remappable to
> remain remappable or remove_migration_pte will then crash (but it's ok
> if stuff isn't remappable before it's established as the page count
> won't match and migrate will temporarily abort). So there is no real
> problem if some swapcache (not transparent hugepage) established in a
> _new_ pte temporarily isn't remappable. OTOH reducing the window for
> lack of rmap is nice too considering it's not going to make any
> difference to do_swap_page.
> 
> The only one that really may benefit from ksm_does_need_to_copy that I
> can imagine memcg, I've no clue how memcg will feel when
> mem_cgroup_commit_charge_swapin aren't getting a swapcache. There are
> some checks for pageswapcache and it probably doesn't choke but I
> can't tell if some stat will go off by one or similar, or if it
> already works fine as is.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
