Date: Sun, 22 Jun 2008 18:11:02 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch] mm: fix race in COW logic
In-Reply-To: <20080622153035.GA31114@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0806221742330.31172@blonde.site>
References: <20080622153035.GA31114@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Sun, 22 Jun 2008, Nick Piggin wrote:
> 
> Can someone please review my thinking here? (no this is not a fix for
> Robin's recent issue, but something completely different)

You have a wicked mind, and I think you're right, and the fix right.

One thing though, in moving the page_remove_rmap in that way, aren't
you assuming that there's an appropriate wmbarrier between the two
locations?  If that is necessarily so (there's plenty happening in
between), it may deserve a comment to say just where that barrier is.

Hugh

> 
> Thanks,
> Nick
> 
> 
> There is a race in the COW logic. It contains a shortcut to avoid the
> COW and reuse the page if we have the sole reference on the page, however it
> is possible to have two racing do_wp_page()ers with one causing the other to
> mistakenly believe it is safe to take the shortcut when it is not. This could
> lead to data corruption.
> 
> Process 1 and process2 each have a wp pte of the same anon page (ie. one
> forked the other). The page's mapcount is 2. Then they both attempt to write
> to it around the same time...
> 
>   proc1				proc2 thr1			proc2 thr2
>   CPU0				CPU1				CPU3
>   do_wp_page()			do_wp_page()
> 				 trylock_page()
> 				  can_share_swap_page()
> 				   load page mapcount (==2)
> 				  reuse = 0
> 				 pte unlock
> 				 copy page to new_page
> 				 pte lock
> 				 page_remove_rmap(page);
>    trylock_page()	
>     can_share_swap_page()
>      load page mapcount (==1)
>     reuse = 1
>    ptep_set_access_flags (allow W)
> 
>   write private key into page
> 								read from page
> 				ptep_clear_flush()
> 				set_pte_at(pte of new_page)
> 
> 
> Fix this by moving the page_remove_rmap of the old page after the pte clear
> and flush. Potentially the entire branch could be moved down here, but in
> order to stay consistent, I won't (should probably move all the *_mm_counter
> stuff with one patch).
> 
> Signed-off-by: Nick Piggin <npiggin@suse.de>
> ---
> Index: linux-2.6/mm/memory.c
> ===================================================================
> --- linux-2.6.orig/mm/memory.c
> +++ linux-2.6/mm/memory.c
> @@ -1766,7 +1766,6 @@ gotten:
>  	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
>  	if (likely(pte_same(*page_table, orig_pte))) {
>  		if (old_page) {
> -			page_remove_rmap(old_page, vma);
>  			if (!PageAnon(old_page)) {
>  				dec_mm_counter(mm, file_rss);
>  				inc_mm_counter(mm, anon_rss);
> @@ -1788,6 +1787,24 @@ gotten:
>  		lru_cache_add_active(new_page);
>  		page_add_new_anon_rmap(new_page, vma, address);
>  
> +		if (old_page) {
> +			/*
> +			 * Only after switching the pte to the new page may
> +			 * we remove the mapcount here. Otherwise another
> +			 * process may come and find the rmap count decremented
> +			 * before the pte is switched to the new page, and
> +			 * "reuse" the old page writing into it while our pte
> +			 * here still points into it and can be read by other
> +			 * threads.
> +			 *
> +			 * The ptep_clear_flush should be enough to prevent
> +			 * any possible reordering making the old page visible
> +			 * to other threads afterwards, so just executing
> +			 * after it is fine.
> +			 */
> +			page_remove_rmap(old_page, vma);
> +		}
> +
>  		/* Free the old page.. */
>  		new_page = old_page;
>  		ret |= VM_FAULT_WRITE;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
