Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B24356B01F9
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 02:56:44 -0400 (EDT)
Received: from kpbe15.cbf.corp.google.com (kpbe15.cbf.corp.google.com [172.25.105.79])
	by smtp-out.google.com with ESMTP id o2U6uvlW023929
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 08:56:57 +0200
Received: from gyd12 (gyd12.prod.google.com [10.243.49.204])
	by kpbe15.cbf.corp.google.com with ESMTP id o2U6utwd008558
	for <linux-mm@kvack.org>; Mon, 29 Mar 2010 23:56:56 -0700
Received: by gyd12 with SMTP id 12so21988862gyd.2
        for <linux-mm@kvack.org>; Mon, 29 Mar 2010 23:56:55 -0700 (PDT)
Date: Mon, 29 Mar 2010 23:56:38 -0700 (PDT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH 35 of 41] don't leave orhpaned swap cache after ksm
 merging
In-Reply-To: <20100329140125.GT5825@random.random>
Message-ID: <alpine.LSU.2.00.1003292302080.11420@sister.anvils>
References: <patchbomb.1269622804@v2.random> <6a19c093c020d009e736.1269622839@v2.random> <4BACEBF8.90909@redhat.com> <20100326172321.GA5825@random.random> <alpine.LSU.2.00.1003262113310.8896@sister.anvils> <20100327010818.GI5825@random.random>
 <20100329140125.GT5825@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Mon, 29 Mar 2010, Andrea Arcangeli wrote:
> On Sat, Mar 27, 2010 at 02:08:18AM +0100, Andrea Arcangeli wrote:
> > more familiar with, only takes the PG_lock during page_wrprotect! Why
> > do you keep the PG_lock during replace_page too? do_wp_page can't run
> > as we re-verify the pte didn't change. Maybe is just to be safer?
> 
> I re-read it and I can't see any valid reason to hold the PG_lock
> after write_protect_page returns. The only reason we added the PG_lock
> is needed is to abort the page merging if there's any GUP pin on the
> page. And so we must prevent the swapcache to alter the page_count
> while we read PageSwapCache and we include it in the page_count
> comparison. We also must read the pte value inside that critical
> section to re-check it later inside replace_page with pte_same with
> the PT lock hold to serialize against the VM.
> 
> So I think returning to the previous locking should be the preferred
> way. What do you think? I don't think the fact kpage can be swapped
> can affect it, "page" should always be a regular anon page and never a
> ksm page. Otherwise it would be futile to try to wrprotect it in the
> first place for example.
> 
> Let me know if you think something like this could be ok, and I'll
> send it to Andrew separately (not more mixed with the rest).

I deeply resent you forcing me to think like this ;)

There is a simple bug with your patch below, isn't there?
The BUG_ON(!PageLocked(page)) in munlock_vma_page().
I expect that could be worked around with more messiness.

But really you're interested in whether I see an absolute reason why
we have to hold page lock across the replace_page().  And no, I can't
at this moment name an absolute reason, but still feel as I did when
I made that change: it makes thinking about the transition easier.

I just have a feeling that if I thought longer and harder I'd find
a good reason for it... but admit that's one of the sloppiest and
most dishonest arguments you'll ever meet!

But now I look at this again, I think we can keep that page lock,
without being messy at all: we're placing too much faith in
"free_page_and_swap_cache" as a primitive construct, when actually
its just a collection of things to do.

So why don't you leave try_to_merge_one_page() just as it is,
and leave replace_page()'s put_page() as it is, but add in
	if (!page_mapped(page))
		try_to_free_swap(page);
either before or after the put_page?  The page_mapped test
is not vital; but if the page is still mapped elsewhere,
we usually take that as justification for keeping its swap.

(I should note in passing that really the thing to do here is
not necessarily to free the swap, but to consider transferring
the swap to the KSM page.  If all goes well, the KSM page remains
stable and we should be able to reread it from swap later on,
without having to write it out there again.  But the way swapping
of KSM pages works, the chance that the KSM page will be the one
that's already PageSwapcache is fairly low; and so we do repeatedly
write them out to swap.  I was working to avoid that when doing the
KSM swapping, but it grew such a long conditional expression -
almost as long as the Cc list on this mail - and became so awkward
between replace_page and try_to_merge_one_page, that I decided to put
it all off to a later optimization.  That I've never yet got around to.)

Hugh

> 
> Thanks again for spotting it ;).
> Andrea
> 
> Subject: don't leave orhpaned swap cache after ksm merging
> 
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> When swapcache is replaced by a ksm page don't leave orhpaned swap cache.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
> 
> diff --git a/mm/ksm.c b/mm/ksm.c
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -817,7 +817,7 @@ static int replace_page(struct vm_area_s
>  	set_pte_at_notify(mm, addr, ptep, mk_pte(kpage, vma->vm_page_prot));
>  
>  	page_remove_rmap(page);
> -	put_page(page);
> +	free_page_and_swap_cache(page);
>  
>  	pte_unmap_unlock(ptep, ptl);
>  	err = 0;
> @@ -863,7 +863,18 @@ static int try_to_merge_one_page(struct 
>  	 * ptes are necessarily already write-protected.  But in either
>  	 * case, we need to lock and check page_count is not raised.
>  	 */
> -	if (write_protect_page(vma, page, &orig_pte) == 0) {
> +	err = write_protect_page(vma, page, &orig_pte);
> +
> +	/*
> +	 * After this mapping is wrprotected we don't need further
> +	 * checks for PageSwapCache vs page_count unlock_page(page)
> +	 * and we rely only on the pte_same() check run under PT lock
> +	 * to ensure the pte didn't change since when we wrprotected
> +	 * it under PG_lock.
> +	 */
> +	unlock_page(page);
> +
> +	if (!err) {
>  		if (!kpage) {
>  			/*
>  			 * While we hold page lock, upgrade page from
> @@ -872,22 +883,20 @@ static int try_to_merge_one_page(struct 
>  			 */
>  			set_page_stable_node(page, NULL);
>  			mark_page_accessed(page);
> -			err = 0;
>  		} else if (pages_identical(page, kpage))
>  			err = replace_page(vma, page, kpage, orig_pte);
> -	}
> +	} else
> +		err = -EFAULT;
>  
>  	if ((vma->vm_flags & VM_LOCKED) && kpage && !err) {
>  		munlock_vma_page(page);
>  		if (!PageMlocked(kpage)) {
> -			unlock_page(page);
>  			lock_page(kpage);
>  			mlock_vma_page(kpage);
> -			page = kpage;		/* for final unlock */
> +			unlock_page(kpage);
>  		}
>  	}
>  
> -	unlock_page(page);
>  out:
>  	return err;
>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
