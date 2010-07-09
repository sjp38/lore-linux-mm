Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id C831D600922
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 16:33:03 -0400 (EDT)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id o69KWxXt022809
	for <linux-mm@kvack.org>; Fri, 9 Jul 2010 13:32:59 -0700
Received: from pzk5 (pzk5.prod.google.com [10.243.19.133])
	by wpaz5.hot.corp.google.com with ESMTP id o69KWuCv018607
	for <linux-mm@kvack.org>; Fri, 9 Jul 2010 13:32:58 -0700
Received: by pzk5 with SMTP id 5so515921pzk.10
        for <linux-mm@kvack.org>; Fri, 09 Jul 2010 13:32:56 -0700 (PDT)
Date: Fri, 9 Jul 2010 13:32:45 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] fix swapin race condition
In-Reply-To: <20100709002322.GO6197@random.random>
Message-ID: <alpine.DEB.1.00.1007091242430.8201@tigran.mtv.corp.google.com>
References: <20100709002322.GO6197@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Fri, 9 Jul 2010, Andrea Arcangeli wrote:

> Hi Hugh,
> 
> can you review this patch? This is only theoretical so far.
> 
> Basically a thread can get stuck in ksm_does_need_to_copy after the
> unlock_page (with orig_pte pointing to swap entry A). In the meantime
> another thread can do the ksm swapin copy too, the copy can be swapped
> out to swap entry B, then a new swapin can create a new copy that can
> return to swap entry A if reused by things like try_to_free_swap (to
> me it seems the page pin is useless to prevent the swapcache to go
> away, it only helps in page reclaim but swapcache is removed by other
> things too). So then the first thread can finish the ksm-copy find the
> pte_same pointing to swap entry A again (despite it passed through
> swap entry B) and break.

Yes, nice find, you're absolutely right: not likely, but possible.
Swap is slippery stuff, and that pte_same does depend on keeping the
original page locked (or else an additional swap_duplicate+swap_free).

> 
> I also don't seem to see a guarantee that lookup_swap_cache returns
> swapcache until we take the lock on the page.
> 
> I exclude this can cause regressions, but I'd like to know if it
> really can happen or if I'm missing something and it cannot happen. I
> surely looks weird that lookup_swap_cache might return a page that
> gets removed from swapcache before we take the page lock but I don't
> see anything preventing it. Surely it's not going to happen until >50%
> swap is full.

It is well established that by the time lookup_swap_cache() returns,
the page it returns may already have been removed from swapcache:
yes, you have to get page lock to be sure.  Long ago I put a comment 
on that into lookup_swap_cache(), but it fell out of the 2.6 version
when we briefly changed how that one worked.

It can even happen when swap is near empty: through swapoff,
or through reuse_swap_page(), at least.

I'm not aware of any bug we have from that, but sure, it comes as a
surprise when you realize it.

> 
> It's also possible to fix it by forcing do_wp_page to run but for a
> little while it won't be possible to rmap the the instantiated page so
> I didn't change that even if it probably would make life easier to
> memcg swapin handlers (maybe, dunno).

That's an interesting idea.  I'm not clear what you have in mind there,
but if we could get rid of ksm_does_need_to_copy(), letting do_wp_page()
do the copy instead, that would be very satisfying.  However, I suspect
it would rather involve tricking do_wp_page() into doing it, involve a
number of hard-to-maintain hacks, appealing to me but to nobody else!

> 
> Thanks,
> Andrea
> 
> ======
> Subject: fix swapin race condition
> 
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> The pte_same check is reliable only if the swap entry remains pinned
> (by the page lock on swapcache). We've also to ensure the swapcache
> isn't removed before we take the lock as try_to_free_swap won't care
> about the page pin.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
> 
> diff --git a/include/linux/ksm.h b/include/linux/ksm.h
> --- a/include/linux/ksm.h
> +++ b/include/linux/ksm.h
> @@ -16,6 +16,9 @@
>  struct stable_node;
>  struct mem_cgroup;
>  
> +struct page *ksm_does_need_to_copy(struct page *page,
> +			struct vm_area_struct *vma, unsigned long address);
> +

Hmm, I guess that works, but depends on the optimizer to remove the
reference to it when !CONFIG_KSM.  I think it would be better back
in its original place, with a dummy inline added for !CONFIG_KSM.

>  #ifdef CONFIG_KSM
>  int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
>  		unsigned long end, int advice, unsigned long *vm_flags);
> @@ -70,19 +73,14 @@ static inline void set_page_stable_node(
>   * We'd like to make this conditional on vma->vm_flags & VM_MERGEABLE,
>   * but what if the vma was unmerged while the page was swapped out?
>   */
> -struct page *ksm_does_need_to_copy(struct page *page,
> -			struct vm_area_struct *vma, unsigned long address);
> -static inline struct page *ksm_might_need_to_copy(struct page *page,
> +static inline int ksm_might_need_to_copy(struct page *page,
>  			struct vm_area_struct *vma, unsigned long address)
>  {
>  	struct anon_vma *anon_vma = page_anon_vma(page);
>  
> -	if (!anon_vma ||
> -	    (anon_vma->root == vma->anon_vma->root &&
> -	     page->index == linear_page_index(vma, address)))
> -		return page;
> -
> -	return ksm_does_need_to_copy(page, vma, address);
> +	return anon_vma &&
> +		(anon_vma->root != vma->anon_vma->root ||
> +		 page->index != linear_page_index(vma, address));
>  }

Hiding in here is a bigger question than your concern:
are these tests right since Rik refactored the anon_vmas?
I just don't know, but hope you and Rik can answer.

I put in this ksm_might_need_to_copy() stuff with the old anon_vma:
it was necessary to avoid the BUG_ON(page->mapping != vma->anon_vma)
in the old __page_check_anon_rmap().  Not just to avoid the BUG_ON -
it was correct to be checking that the page would be rmap-findable.
Nowadays that check is gone, and I wonder if ksm_does_need_to_copy()
is getting called in cases when we do not need to copy at all?

(We need to copy on bringing back from swap when KSM collapsed pages
unrelated by fork into one single page which was then swapped out.)

>  
>  int page_referenced_ksm(struct page *page,
> @@ -115,10 +113,10 @@ static inline int ksm_madvise(struct vm_
>  	return 0;
>  }
>  
> -static inline struct page *ksm_might_need_to_copy(struct page *page,
> +static inline int ksm_might_need_to_copy(struct page *page,
>  			struct vm_area_struct *vma, unsigned long address)
>  {
> -	return page;
> +	return 0;
>  }
>  
>  static inline int page_referenced_ksm(struct page *page,
> diff --git a/mm/ksm.c b/mm/ksm.c
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -1518,8 +1518,6 @@ struct page *ksm_does_need_to_copy(struc
>  {
>  	struct page *new_page;
>  
> -	unlock_page(page);	/* any racers will COW it, not modify it */
> -
>  	new_page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, address);
>  	if (new_page) {
>  		copy_user_highpage(new_page, page, address, vma);
> @@ -1535,7 +1533,6 @@ struct page *ksm_does_need_to_copy(struc
>  			add_page_to_unevictable_list(new_page);
>  	}
>  
> -	page_cache_release(page);
>  	return new_page;
>  }
>  
> diff --git a/mm/memory.c b/mm/memory.c
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2616,7 +2616,7 @@ static int do_swap_page(struct mm_struct
>  		unsigned int flags, pte_t orig_pte)
>  {
>  	spinlock_t *ptl;
> -	struct page *page;
> +	struct page *page, *swapcache = NULL;

If we're honest (and ksm_might_need_to_copy really is giving the
right answers it should), we'd name that ksm_swapcache, and notice
how KSM has intruded here rather more than we wanted.

>  	swp_entry_t entry;
>  	pte_t pte;
>  	struct mem_cgroup *ptr = NULL;
> @@ -2671,10 +2671,23 @@ static int do_swap_page(struct mm_struct
>  	lock_page(page);
>  	delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
>  
> -	page = ksm_might_need_to_copy(page, vma, address);
> -	if (!page) {
> -		ret = VM_FAULT_OOM;
> -		goto out;
> +	/*
> +	 * Make sure try_to_free_swap didn't release the swapcache
> +	 * from under us. The page pin isn't enough to prevent that.
> +	 */
> +	if (unlikely(!PageSwapCache(page)))
> +		goto out_page;

Do you actually need to add that check there? (And do we actually
need the same check in mem_cgroup_try_charge_swapin?  Now I think not.)
You would if you were to proceed by holding the swap entry with an
additional swap_duplicate+swap_free (which conceptually I'd prefer,
but you're more efficient to use the page lock we already have).

If you really want to add it, just to make things easier to think
about, that's fair enough; but I don't see that it's necessary.

> +
> +	if (ksm_might_need_to_copy(page, vma, address)) {
> +		swapcache = page;
> +		page = ksm_does_need_to_copy(page, vma, address);
> +
> +		if (unlikely(!page)) {
> +			ret = VM_FAULT_OOM;
> +			page = swapcache;
> +			swapcache = NULL;
> +			goto out_page;
> +		}
>  	}
>  
>  	if (mem_cgroup_try_charge_swapin(mm, page, GFP_KERNEL, &ptr)) {

There's a related bug of mine lurking here, only realized in looking
through this, which you might want to fix at the same time: I should
have moved the PageUptodate check from after the pte_same check to
before the ksm_might_need_to_copy, shouldn't I?  As it stands, we
might copy junk from an invalid !Uptodate page into a clean new page.

> @@ -2725,6 +2738,18 @@ static int do_swap_page(struct mm_struct
>  	if (vm_swap_full() || (vma->vm_flags & VM_LOCKED) || PageMlocked(page))
>  		try_to_free_swap(page);
>  	unlock_page(page);
> +	if (swapcache) {
> +		/*
> +		 * Hold the lock to avoid the swap entry to be reused
> +		 * until we take the PT lock for the pte_same() check
> +		 * (to avoid false positives from pte_same). For
> +		 * further safety release the lock after the swap_free
> +		 * so that the swap count won't change under a
> +		 * parallel locked swapcache.
> +		 */
> +		unlock_page(swapcache);
> +		page_cache_release(swapcache);
> +	}
>  
>  	if (flags & FAULT_FLAG_WRITE) {
>  		ret |= do_wp_page(mm, vma, address, page_table, pmd, ptl, pte);
> @@ -2746,6 +2771,10 @@ out_page:
>  	unlock_page(page);
>  out_release:
>  	page_cache_release(page);
> +	if (swapcache) {
> +		unlock_page(swapcache);
> +		page_cache_release(swapcache);
> +	}

Minor point, but couldn't that added block go just after the unlock_page
above, before the out_release label?  Doesn't matter, just pairs up more
naturally.

>  	return ret;
>  }

Yes, I don't like the way KSM is intruding further on do_swap_page(),
but I haven't thought of a nicer way of handling the case.

Thanks for finding this - probably years before any user hits it!
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
