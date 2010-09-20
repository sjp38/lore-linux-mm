Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 01E6A6B0047
	for <linux-mm@kvack.org>; Sun, 19 Sep 2010 22:40:40 -0400 (EDT)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id o8K2eaX6015400
	for <linux-mm@kvack.org>; Sun, 19 Sep 2010 19:40:36 -0700
Received: from pwi9 (pwi9.prod.google.com [10.241.219.9])
	by wpaz13.hot.corp.google.com with ESMTP id o8K2eY7T027846
	for <linux-mm@kvack.org>; Sun, 19 Sep 2010 19:40:35 -0700
Received: by pwi9 with SMTP id 9so1251352pwi.30
        for <linux-mm@kvack.org>; Sun, 19 Sep 2010 19:40:34 -0700 (PDT)
Date: Sun, 19 Sep 2010 19:40:22 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] mm: further fix swapin race condition
In-Reply-To: <alpine.LSU.2.00.1009191924110.2779@sister.anvils>
Message-ID: <alpine.LSU.2.00.1009191938110.3025@sister.anvils>
References: <20100903153958.GC16761@random.random> <alpine.LSU.2.00.1009051926330.12092@sister.anvils> <alpine.LSU.2.00.1009151534060.5630@tigran.mtv.corp.google.com> <20100915234237.GR5981@random.random> <alpine.DEB.2.00.1009151703060.7332@tigran.mtv.corp.google.com>
 <20100916210349.GU5981@random.random> <alpine.LSU.2.00.1009161905190.2517@tigran.mtv.corp.google.com> <20100918131907.GI18596@random.random> <alpine.LSU.2.00.1009191924110.2779@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Greg KH <greg@kroah.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Commit 4969c1192d15afa3389e7ae3302096ff684ba655 "mm: fix swapin race condition"
is now agreed to be incomplete.  There's a race, not very much less likely
than the original race envisaged, in which it is further necessary to check
that the swapcache page's swap has not changed.

Here's the reasoning: cast in terms of reuse_swap_page(), but probably could
be reformulated to rely on try_to_free_swap() instead, or on swapoff+swapon.

A, faults into do_swap_page(): does page1 = lookup_swap_cache(swap1)
and comes through the lock_page(page1).

B, a racing thread of the same process, faults on the same address:
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

Signed-off-by: Hugh Dickins <hughd@google.com>
Cc: stable@kernel.org
---

 mm/memory.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

--- 2.6.36-rc4/mm/memory.c	2010-09-12 17:34:03.000000000 -0700
+++ linux/mm/memory.c	2010-09-19 18:23:43.000000000 -0700
@@ -2680,10 +2680,12 @@ static int do_swap_page(struct mm_struct
 	delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
 
 	/*
-	 * Make sure try_to_free_swap didn't release the swapcache
-	 * from under us. The page pin isn't enough to prevent that.
+	 * Make sure try_to_free_swap or reuse_swap_page or swapoff did not
+	 * release the swapcache from under us.  The page pin, and pte_same
+	 * test below, are not enough to exclude that.  Even if it is still
+	 * swapcache, we need to check that the page's swap has not changed.
 	 */
-	if (unlikely(!PageSwapCache(page)))
+	if (unlikely(!PageSwapCache(page) || page_private(page) != entry.val))
 		goto out_page;
 
 	if (ksm_might_need_to_copy(page, vma, address)) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
