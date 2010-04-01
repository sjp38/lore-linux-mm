Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id C07136B01EE
	for <linux-mm@kvack.org>; Thu,  1 Apr 2010 12:48:57 -0400 (EDT)
Date: Thu, 1 Apr 2010 18:47:58 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 35 of 41] don't leave orhpaned swap cache after ksm
 merging
Message-ID: <20100401164758.GZ5825@random.random>
References: <patchbomb.1269622804@v2.random>
 <6a19c093c020d009e736.1269622839@v2.random>
 <4BACEBF8.90909@redhat.com>
 <20100326172321.GA5825@random.random>
 <alpine.LSU.2.00.1003262113310.8896@sister.anvils>
 <20100327010818.GI5825@random.random>
 <20100329140125.GT5825@random.random>
 <alpine.LSU.2.00.1003292302080.11420@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1003292302080.11420@sister.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Mon, Mar 29, 2010 at 11:56:38PM -0700, Hugh Dickins wrote:
> I deeply resent you forcing me to think like this ;)

sorry ;)

> There is a simple bug with your patch below, isn't there?
> The BUG_ON(!PageLocked(page)) in munlock_vma_page().
> I expect that could be worked around with more messiness.

Didn't notice this, no more messiness just like in do_wp_page:

     	lock_page(old_page);	/* for LRU manipulation */
        clear_page_mlock(old_page);
	unlock_page(old_page);

diff --git a/mm/ksm.c b/mm/ksm.c
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -889,7 +889,9 @@ static int try_to_merge_one_page(struct 
 		err = -EFAULT;
 
 	if ((vma->vm_flags & VM_LOCKED) && kpage && !err) {
+		lock_page(page);	/* for LRU manipulation */
 		munlock_vma_page(page);
+		unlock_page(page);
 		if (!PageMlocked(kpage)) {
 			lock_page(kpage);
 			mlock_vma_page(kpage);


So no big deal, the chances we block in that lock are close to zero
considering we just released it. The VM could still take it because
the page is still in the lru, but it will bail out when it sees the
page_mapcount() == 0. So no risk to wait for I/O.

> But really you're interested in whether I see an absolute reason why
> we have to hold page lock across the replace_page().  And no, I can't
> at this moment name an absolute reason, but still feel as I did when
> I made that change: it makes thinking about the transition easier.

What about do_wp_page? It also reads the orig_pte. It takes the page
lock just to run reuse_swap_cache. If that fails it drops the PT lock
allocates the page, take the PT lock again, runs pte_same the same way
reuse_swap_cache does it, and finally it copies and replaces the page.

How is that any different? I mean are we introducing a new case or
it's the same as do_wp_page.

I think it boils down to the answer of the above question. I think
they're equal, but if you think they're different I'll keep the lock
hold during replace_page no problem. I don't want to introduce new
locking cases, but to me it doesn't look like one!

> So why don't you leave try_to_merge_one_page() just as it is,
> and leave replace_page()'s put_page() as it is, but add in
> 	if (!page_mapped(page))
> 		try_to_free_swap(page);
> either before or after the put_page?  The page_mapped test
> is not vital; but if the page is still mapped elsewhere,
> we usually take that as justification for keeping its swap.

No doubt we can leave the page lock around replace_page too, but I
personally hate to leave unknown-needed locking, especially if there
are other places that release the page lock and they only relies on
the pte_same check under PT lock when they replace the page
(do_wp_page).

Originally, before I found the trouble with the gup pins in
page_wrprotect (current write_protect_page) we didn't take the PG_lock
at all. We had to introduce it to do the page_count accounting right
on the swapcache and that's about it...

> (I should note in passing that really the thing to do here is
> not necessarily to free the swap, but to consider transferring
> the swap to the KSM page.  If all goes well, the KSM page remains
> stable and we should be able to reread it from swap later on,
> without having to write it out there again.  But the way swapping

Agreed that would be ideal. It'd save one I/O if both pte and
swapcache are clean, and it might improve swap locality even when one
of the two is dirty.

> of KSM pages works, the chance that the KSM page will be the one
> that's already PageSwapcache is fairly low; and so we do repeatedly
> write them out to swap.  I was working to avoid that when doing the
> KSM swapping, but it grew such a long conditional expression -
> almost as long as the Cc list on this mail - and became so awkward
> between replace_page and try_to_merge_one_page, that I decided to put
> it all off to a later optimization.  That I've never yet got around to.)

No problem. It's not high priority for sure. The only high priority
thing as far as KSM is concerned is to make it work on hugepages. For
now shutting down a VM and not being life with gigabytes of swap used
is enough...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
