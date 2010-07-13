Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 46DA16B02A3
	for <linux-mm@kvack.org>; Mon, 12 Jul 2010 21:08:12 -0400 (EDT)
Date: Tue, 13 Jul 2010 03:08:04 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] fix swapin race condition
Message-ID: <20100713010804.GB31974@random.random>
References: <20100709002322.GO6197@random.random>
 <alpine.DEB.1.00.1007091242430.8201@tigran.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.00.1007091242430.8201@tigran.mtv.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi Hugh,

thanks a lot for the review!

On Fri, Jul 09, 2010 at 01:32:45PM -0700, Hugh Dickins wrote:
> Yes, nice find, you're absolutely right: not likely, but possible.
> Swap is slippery stuff, and that pte_same does depend on keeping the
> original page locked (or else an additional swap_duplicate+swap_free).

Agreed. Now this race of swap entry reused during the ksm-copy leading
to pte_same false positive, seems so unlikely that I doubt anybody
could have ever triggered it so far, but possible nevertheless. When
things gets into a cluster getting one in a thousand systems that hits
swap heavy leading to this isn't nice as it's next to impossible to
track the corruption because it'd be not easily reproducible, so it's
better to be safe than sorry ;).

> It is well established that by the time lookup_swap_cache() returns,
> the page it returns may already have been removed from swapcache:
> yes, you have to get page lock to be sure.  Long ago I put a comment 
> on that into lookup_swap_cache(), but it fell out of the 2.6 version
> when we briefly changed how that one worked.

I found it by code review only, so it was unexpected to me. I assume
it was unexpected to do_swap_cache as well if you agree this is a bug
too and it could trigger in theory.

In the old days I'm quite sure lookup_swap_cache wouldn't return a
page evicted by swapcache I think, but this looks good so we can run
try_to_free_swap and release swap space, without care of the page pins
and we decouple the actual pinning of the page from keeping the swap
entry pinned too. Just unexpected to me when reading do_swap_page,
while being used to the "secular" semantics of lookup_swap_cache ;).

I also thought maybe lookup_swap_cache could return the page locked or
return NULL, but then there's the same problem in the regular swapin
that is async and the lock will go away when I/O completes, so there's
still a window for the same race, so I thought it's not worth locking
anything in lookup_swap_cache.

>
> It can even happen when swap is near empty: through swapoff,
> or through reuse_swap_page(), at least.

Agreed, it can also happen with threads swapping in a not shared anon
page.

> I'm not aware of any bug we have from that, but sure, it comes as a
> surprise when you realize it.

:)

> > It's also possible to fix it by forcing do_wp_page to run but for a
> > little while it won't be possible to rmap the the instantiated page so
> > I didn't change that even if it probably would make life easier to
> > memcg swapin handlers (maybe, dunno).
> 
> That's an interesting idea.  I'm not clear what you have in mind there,
> but if we could get rid of ksm_does_need_to_copy(), letting do_wp_page()
> do the copy instead, that would be very satisfying.  However, I suspect
> it would rather involve tricking do_wp_page() into doing it, involve a
> number of hard-to-maintain hacks, appealing to me but to nobody else!

It's actually next to trivial to make that change and it eliminates a
dozen lines of code. I didn't to just make a strict fix that doesn't
alter any logic of the code. But it's just enough to do:

if (ksm_might_need_to_copy())
   flags |= FAULT_FLAG_WRITE;

Then the whole ksm_does_need_to_copy and swapcache variable and the
rest of the code I added goes away (only the pageswapcache check after
page_lock remains for the bug discussed at the top). pte_same in
do_wp_page and do_swap_page then become both reliable because
do_swap_page locks the swapcache before changing the pte to point to
the page, and do_wp_page pins the old page before doing pte_same. So
there's no risk of swap entry reuse that way and it eliminates some
code.

Only downside of ksm_does_need_to_copy removal: rmappability of the
swapcache for a ksm-swapin that isn't linear becomes impossible for a
little window of time, but only split_huge_page requires rmappability
always (only transparent hugepages are required to be precisely
rmapped at all times if they are ever established in any
pmd_trans_huge pmd), and migrate only requires what is remappable to
remain remappable or remove_migration_pte will then crash (but it's ok
if stuff isn't remappable before it's established as the page count
won't match and migrate will temporarily abort). So there is no real
problem if some swapcache (not transparent hugepage) established in a
_new_ pte temporarily isn't remappable. OTOH reducing the window for
lack of rmap is nice too considering it's not going to make any
difference to do_swap_page.

The only one that really may benefit from ksm_does_need_to_copy that I
can imagine memcg, I've no clue how memcg will feel when
mem_cgroup_commit_charge_swapin aren't getting a swapcache. There are
some checks for pageswapcache and it probably doesn't choke but I
can't tell if some stat will go off by one or similar, or if it
already works fine as is.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
