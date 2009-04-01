Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id BFEEA6B003D
	for <linux-mm@kvack.org>; Wed,  1 Apr 2009 04:37:49 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n318cMEw006545
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 1 Apr 2009 17:38:23 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A234345DD7F
	for <linux-mm@kvack.org>; Wed,  1 Apr 2009 17:38:22 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7511D45DD78
	for <linux-mm@kvack.org>; Wed,  1 Apr 2009 17:38:22 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id BAAAAE08001
	for <linux-mm@kvack.org>; Wed,  1 Apr 2009 17:38:21 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 90E561DB803B
	for <linux-mm@kvack.org>; Wed,  1 Apr 2009 17:38:20 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: add_to_swap_cache with GFP_ATOMIC ?
In-Reply-To: <Pine.LNX.4.64.0903311154570.19028@blonde.anvils>
References: <28c262360903310338k20b8eebbncb86baac9b09e54@mail.gmail.com> <Pine.LNX.4.64.0903311154570.19028@blonde.anvils>
Message-Id: <20090401165516.B1EB.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed,  1 Apr 2009 17:38:19 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh@veritas.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

(cc to related person)

> The questionable one is add_to_swap (when vmscanning), which calls
> it with __GFP_HIGH|__GFP_NOMEMALLOC|__GFP_NOWARN, i.e. GFP_ATOMIC
> plus __GFP_NOMEMALLOC|__GFP_NOWARN.  That one I have wondered
> about from time to time: GFP_NOIO would be the obvious choice,
> that's what swap_writepage will use to allocate bio soon after.
> 
> I've been tempted to change it, but afraid to touch that house
> of cards, and afraid of long testing and justification required.
> Would it be safe to drop that __GFP_HIGH?  What's the effect of the
> __GFP_NOMEMALLOC (we've layer on layer of tweak this one way because
> we're in the reclaim path so let it eat more, then tweak it the other
> way because we don't want it to eat up _too_ much).  I just let it stay.

firstly, following some patch indicate add_to_swap() parameter history.

ac47b003d03c2a4f28aef1d505b66d24ad191c4f(Hugh, Jan 6 2009) reverted 
1480a540c98525640174a7eadd712378fcd6fd63(Cristoph, Jan 8 2006).

bd53b714d32a29bdf33009f812e295667e92b930(Nick, May 1 2005) added
__GFP_NOMEMALLOC. __GFP_NOMEMALLOC mean "please don't eat emergency memory".

c4b3efde0744e038d16b33d18110d39e762ef80c(akpm, Jan 6 2003) explained
why no using emergency memory is better.
it said 

    In the case of adding pages to swapcache we're still using GFP_ATOMIC, so
    these addition attempts can still fail.  That's OK, because the error is
    handled and, unlike file pages, it will not cause user applicaton failures.


IOW, GFP_ATOMIC on add_to_swap() was introduced accidentally. the reason 
was old add_to_page_cache() didn't have gfp_mask parameter and we didn't
 have the reason of changing add_to_swap() behavior.
I think it don't have deeply reason and changing GFP_NOIO don't cause regression.



---------------------------------------------

commit ac47b003d03c2a4f28aef1d505b66d24ad191c4f
Author: Hugh Dickins <hugh@veritas.com>
Date:   Tue Jan 6 14:39:39 2009 -0800

    mm: remove gfp_mask from add_to_swap

    Remove gfp_mask argument from add_to_swap(): it's misleading because its
    only caller, shrink_page_list(), is not atomic at that point; and in due
    course (implementing discard) we'll sometimes want to allocate some memory
    with GFP_NOIO (as is used in swap_writepage) when allocating swap.

    No change to the gfp_mask passed down to add_to_swap_cache(): still use
    __GFP_HIGH without __GFP_WAIT (with nomemalloc and nowarn as before):
    though it's not obvious if that's the best combination to ask for here.

-int add_to_swap(struct page * page, gfp_t gfp_mask)
+int add_to_swap(struct page *page)
 {
        swp_entry_t entry;
        int err;
@@ -153,7 +153,7 @@ int add_to_swap(struct page * page, gfp_t gfp_mask)
                 * Add it to the swap cache and mark it dirty
                 */
                err = add_to_swap_cache(page, entry,
-                               gfp_mask|__GFP_NOMEMALLOC|__GFP_NOWARN);
+                               __GFP_HIGH|__GFP_NOMEMALLOC|__GFP_NOWARN);

---------------------------------------------

commit 1480a540c98525640174a7eadd712378fcd6fd63
Author: Christoph Lameter <clameter@sgi.com>
Date:   Sun Jan 8 01:00:53 2006 -0800

    [PATCH] SwapMig: add_to_swap() avoid atomic allocations

    Add gfp_mask to add_to_swap

    add_to_swap does allocations with GFP_ATOMIC in order not to interfere with
    swapping.  During migration we may have use add_to_swap extensively which may
    lead to out of memory errors.

    This patch makes add_to_swap take a parameter that specifies the gfp mask.
    The page migration code can then make add_to_swap use GFP_KERNEL.

-int add_to_swap(struct page * page)
+int add_to_swap(struct page * page, gfp_t gfp_mask)
 {
        swp_entry_t entry;
        int err;
@@ -166,7 +166,7 @@ int add_to_swap(struct page * page)
                 * Add it to the swap cache and mark it dirty
                 */
                err = __add_to_swap_cache(page, entry,
-                               GFP_ATOMIC|__GFP_NOMEMALLOC|__GFP_NOWARN);
+                               gfp_mask|__GFP_NOMEMALLOC|__GFP_NOWARN);

---------------------------------------------

commit bd53b714d32a29bdf33009f812e295667e92b930
Author: Nick Piggin <nickpiggin@yahoo.com.au>
Date:   Sun May 1 08:58:37 2005 -0700

    [PATCH] mm: use __GFP_NOMEMALLOC

    Use the new __GFP_NOMEMALLOC to simplify the previous handling of
    PF_MEMALLOC.

    Signed-off-by: Nick Piggin <nickpiggin@yahoo.com.au>
    Signed-off-by: Andrew Morton <akpm@osdl.org>
    Signed-off-by: Linus Torvalds <torvalds@osdl.org>

@@ -154,29 +153,19 @@ int add_to_swap(struct page * page)
                if (!entry.val)
                        return 0;

-               /* Radix-tree node allocations are performing
-                * GFP_ATOMIC allocations under PF_MEMALLOC.
-                * They can completely exhaust the page allocator.
-                *
-                * So PF_MEMALLOC is dropped here.  This causes the slab
-                * allocations to fail earlier, so radix-tree nodes will
-                * then be allocated from the mempool reserves.
+               /*
+                * Radix-tree node allocations from PF_MEMALLOC contexts could
+                * completely exhaust the page allocator. __GFP_NOMEMALLOC
+                * stops emergency reserves from being allocated.
                 *
-                * We're still using __GFP_HIGH for radix-tree node
-                * allocations, so some of the emergency pools are available,
-                * just not all of them.
+                * TODO: this could cause a theoretical memory reclaim
+                * deadlock in the swap out path.
                 */
-
-               pf_flags = current->flags;
-               current->flags &= ~PF_MEMALLOC;
-
                /*
                 * Add it to the swap cache and mark it dirty
                 */
-               err = __add_to_swap_cache(page, entry, GFP_ATOMIC|__GFP_NOWARN);
-
-               if (pf_flags & PF_MEMALLOC)
-                       current->flags |= PF_MEMALLOC;
+               err = __add_to_swap_cache(page, entry,
+                               GFP_ATOMIC|__GFP_NOMEMALLOC|__GFP_NOWARN);

---------------------------------------------
commit b84a35be0285229b0a8a5e2e04d79360c5b75562
Author: Nick Piggin <nickpiggin@yahoo.com.au>
Date:   Sun May 1 08:58:36 2005 -0700

    [PATCH] mempool: NOMEMALLOC and NORETRY

    Mempools have 2 problems.

    The first is that mempool_alloc can possibly get stuck in __alloc_pages
    when they should opt to fail, and take an element from their reserved pool.

    The second is that it will happily eat emergency PF_MEMALLOC reserves
    instead of going to their reserved pools.

    Fix the first by passing __GFP_NORETRY in the allocation calls in
    mempool_alloc.  Fix the second by introducing a __GFP_MEMPOOL flag which
    directs the page allocator not to allocate from the reserve pool.

    Signed-off-by: Andrew Morton <akpm@osdl.org>
    Signed-off-by: Linus Torvalds <torvalds@osdl.org>

---------------------------------------------

commit c22eeaf4682941543d1426621ca1e3c6d3833fe2
Author: akpm <akpm>
Date:   Fri Sep 3 17:20:58 2004 +0000

    [PATCH] add_to_swap(): suppress oom message

    Page allocation failures are expected when add_to_swap() tries to allocate
    radix-tree nodes without PF_MEMALLOC.  Kill the __alloc_pages() warnings.

    Signed-off-by: Andrew Morton <akpm@osdl.org>
    Signed-off-by: Linus Torvalds <torvalds@osdl.org>

    BKrev: 4138a7faauXIloxI3vwZ04xvfa1paQ

@@ -171,7 +171,7 @@ int add_to_swap(struct page * page)
                /*
                 * Add it to the swap cache and mark it dirty
                 */
-               err = __add_to_swap_cache(page, entry, GFP_ATOMIC);
+               err = __add_to_swap_cache(page, entry, GFP_ATOMIC|__GFP_NOWARN);

                if (pf_flags & PF_MEMALLOC)
                        current->flags |= PF_MEMALLOC;


---------------------------------------------

commit c4b3efde0744e038d16b33d18110d39e762ef80c
Author: akpm <akpm>
Date:   Mon Jan 6 03:51:29 2003 +0000

    [PATCH] handle radix_tree_node allocation failures

    This patch uses the radix_tree_preload() API in add_to_page_cache().

    A new gfp_mask argument is added to add_to_page_cache(), which is then passed
    on to radix_tree_preload().   It's pretty simple.

    In the case of adding pages to swapcache we're still using GFP_ATOMIC, so
    these addition attempts can still fail.  That's OK, because the error is
    handled and, unlike file pages, it will not cause user applicaton failures.
    This codepath (radix-tree node exhaustion on swapout) was well tested in the
    days when the swapper_space radix tree was fragmented all over the place due
    to unfortunate swp_entry bit layout.

    BKrev: 3e18fd41cbfAQY7P7NcjQYCevjYG2g

@@ -149,7 +149,8 @@ int add_to_swap(struct page * page)
                /*
                 * Add it to the swap cache and mark it dirty
                 */
-               err = add_to_page_cache(page, &swapper_space, entry.val);
+               err = add_to_page_cache(page, &swapper_space,
+                                       entry.val, GFP_ATOMIC);

---------------------------------------------

commit e9cb95284376950d34943acd2ddd33a473ba9ba3
Author: torvalds <torvalds>
Date:   Tue Dec 3 22:59:18 2002 +0000

    Merge master.kernel.org:/home/hch/BK/xfs/linux-2.5
    into penguin.transmeta.com:/home/penguin/torvalds/repositories/kernel/linux


@@ -149,9 +150,15 @@ int add_to_swap(struct page * page)
                /*
                 * Add it to the swap cache and mark it dirty
                 */
-               switch (add_to_page_cache(page, &swapper_space, entry.val)) {
+               err = add_to_page_cache(page, &swapper_space, entry.val);
+
+               if (!(pf_flags & PF_NOWARN))
+                       current->flags &= ~PF_NOWARN;
+               if (pf_flags & PF_MEMALLOC)
+                       current->flags |= PF_MEMALLOC;
+
+               switch (err) {



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
