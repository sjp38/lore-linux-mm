Date: Mon, 7 Aug 2006 16:51:01 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 1/2] mm: speculative get_page
Message-ID: <20060807145101.GF4433@wotan.suse.de>
References: <20060726063905.GA32107@wotan.suse.de> <Pine.LNX.4.64.0608071058510.9318@blonde.wat.veritas.com> <20060807132633.GD4433@wotan.suse.de> <Pine.LNX.4.64.0608071530210.10881@blonde.wat.veritas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0608071530210.10881@blonde.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 07, 2006 at 03:37:12PM +0100, Hugh Dickins wrote:
> On Mon, 7 Aug 2006, Nick Piggin wrote:
> > On Mon, Aug 07, 2006 at 11:11:15AM +0100, Hugh Dickins wrote:
> > > 
> > > Yes, I understand why remove_mapping and migrate_page_move_mapping
> > > (on page) do the PageNoNewRefs business; but why do add_to_page_cache,
> > > __add_to_swap_cache and migrate_page_move_mapping (on newpage) do it?
> > 
> > add_to_*_cache(), because they insert the page *then* set up fields
> > in the page. Without the bit set, the page is visible to pagecache
> > as soon as it hits the radix tree.
> 
> Aha, thank you.
> 
> > In the page_cache case, I have a subsequent patch to rearrange this a bit,
> > and reduce the number of atomic ops. I thought it would just add too much
> > to review for now, though.
> 
> Well, it's a slightly different use for PageNoNewRefs, and would need
> to be commented if it stays: I'd recommend avoiding the need for that
> comment and the unnecessary atomics, doing your rearrangement in a
> preceding patch.

It's the same use in that when you combine tree_lock with the page
bit, you get the same semantics as the old write_lock(&tree_lock).

What I mean is: if the current slightly different uses of tree_lock
don't warrant different comments, then I'm don't see that PG_nnr
does either.

> 
> Though maybe cleaner to have mapping/index/SwapCache/private properly
> set before inserting page into radix tree, page_cache_get_speculative
> callers all have to check afterwards and repeat if wrong; so the only
> thing that's essential to do earlier is the SetPageLocked, isn't it?

Something like that, yes.

> 
> On the subject of mapping/index, I think there's potential for a very
> very unlikely race you're ignoring, a race you can blame on me and my
> passion for squeezing in alternative uses of struct page fields:
> 
> Isn't it conceivable that a page_cache_get_speculative finds a page
> in the radix tree, but by the time its callers do those mapping/index
> checks, that page is reused for some other purpose completely, which
> happens to set the field formerly known as page->mapping to something
> (perhaps a sequence of 4 or 8 random bytes) identical to what was
> there before (and leaves index untouched, or changes it to the same)?
> 
> I'm thinking particularly of the per-pagetable page spinlock, where
> what goes into page->mapping depends on CONFIG_DEBUG_SPINLOCK de jour.
> 
> I think we can probably (but I've not tried) satisfy ourselves that
> there's currently no way that can happen; but how shall we prevent
> ourselves from later making a change which opens up the possibility?
> (By passing my address to a hitman, perhaps.)
> 
> An alternative would be to go more the radix_tree_lookup_slot way,
> and the checks be on page remaining in slot; but I think you comment
> that it cannot be used for RCU lookups, I didn't investigate further.
> 
> This is not a grave concern: but (unless I'm plain wrong) we do need
> to be aware of it.

No, it is something I'm worried about too. And definitely the lookup_slot
approach would solve it. I'm inclined to go back to the lookup_slot
method which would solve the weird gang lookup problems that come about
with this approach. And as another bonus we don't need find_get_swap_page.

The problem is not so much with RCU lookups as with the direct-data
patch: one can take the address of a slot in a radix-tree node with the
knowledge that, under RCU lock, it will always dereference to either
NULL or a valid item.

However, direct data stores 0-height trees' item at ->rnode. But this
can also be switched to point to a radix-tree node or vice versa at
any time.

The solution is just a little bit more API to do the dereferencing work
for us. Shouldn't be a big problem.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
