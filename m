Date: Wed, 28 Mar 2007 18:17:57 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: kswapd freed a swap space?
Message-ID: <Pine.LNX.4.64.0703281808410.20922@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew,

Please drop your "kswapd freed a swap space"-spamming
mm-only-free-swap-space-of-reactivated-pages-debug.patch
from the -mm tree, and please also drop Rik's
free-swap-space-of-reactivated-pages.patch
upon which you placed it to inform.

I wonder why nobody else got irritated by the spam?  Nobody else
half-filling their swap, I suppose.  But it was a really cunning
way of forcing me to look closer at Rik's patch, I couldn't fairly
ask you to stop the spam without doing so.

Rik's patch is plausible, I like the idea, as I hate the idea of
marking anon pages "mlocked" once swap fills up.  But I found
several amusing things once I tested how it works in practice.

Firstly, the vast majority of the pages arriving at pagevec_swap_free
were !PageActive, the very ones it wanted not to free the swap of.
Perhaps "vast majority" was an artifact of the kbuild workload, and
others would show a different balance: but because the pvec is first
given l_inactive pages, then l_active pages added without intervening
flush, there's certainly a tendency for !PageActive pages to get
caught up with the PageActive ones it want to free the swap of.
Easily fixed by adding a pagevec_release (though irritating to
have to drop and reget the lru_lock around it), or by testing
for PageActive in pagevec_swap_free.

Secondly, I found that of all those "kswapd freed a swap space"
pages, actually _none_ of them freed a swap space: the return value
from remove_exclusive_swap_page tells that, and when you follow it
up, you find that the page_count is too high for it to free them.
Now those page_count checks in remove_exclusive_swap_page (and in
free_swap_and_cache) are rather antique, from long before mapcount:
both Andrea and Nick have in the past suggested we change them, and
I've resisted for no better reasons than excessive caution and my
mind on other matters.  Probably it is now time to change them:
and to take the testing further I did so (though I'd want to spend
a lot more time mulling over and testing the new versions before
pushing them forward), so pagevec_swap_free could now free swap.

Thirdly, I instrumented __delete_from_swap_cache and its various
callpaths to count where swap was actually getting freed from.
And the number freed via pagevec_swap_free was so tiny compared
with the other routes, it doesn't seem worth adding the overhead.
(Whereas the simple vm_swap_full remove_exclusive_swap_page which
Rik added at activate_locked was an order of magnitude more
successful: not a major route, but still worth doing.)

Why did pagevec_swap_free end up freeing so little?  I guess
because the vm_swap_full remove_exclusive_swap_page in do_swap_page
was successfully freeing so much.  But also, because of another
(incomplete) patch I've had around for months, which I added in
to the instrumentation: when do_wp_page decides it can use the
swapcache page directly, isn't that a very good time to remove
from swapcache?  The data on disk can no longer be useful,
the only advantage to leaving in swapcache is to avoid the
overhead of remove-and-perhaps-later-add-again: against that,
if the page has to be written out to swap again, its old swap
position is likely to be far away from where swap_writepage is
now writing freshly allocated swap.

Perhaps Rik can offer some very different results to support
his patch; but if not, I think drop it (and your debug) from
mm for now.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
