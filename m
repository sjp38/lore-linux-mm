Subject: Re: [patch] mm: fix race in COW logic
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20080623123030.GB26555@wotan.suse.de>
References: <20080622153035.GA31114@wotan.suse.de>
	 <Pine.LNX.4.64.0806221742330.31172@blonde.site>
	 <alpine.LFD.1.10.0806221033200.2926@woody.linux-foundation.org>
	 <Pine.LNX.4.64.0806221854050.5466@blonde.site>
	 <20080623014940.GA29413@wotan.suse.de>
	 <Pine.LNX.4.64.0806231015140.3513@blonde.site>
	 <20080623121831.GA26555@wotan.suse.de>
	 <20080623123030.GB26555@wotan.suse.de>
Content-Type: text/plain
Date: Fri, 27 Jun 2008 11:19:26 +0200
Message-Id: <1214558366.2801.26.camel@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Hugh Dickins <hugh@veritas.com>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2008-06-23 at 14:30 +0200, Nick Piggin wrote:
> On Mon, Jun 23, 2008 at 02:18:31PM +0200, Nick Piggin wrote:
> > On Mon, Jun 23, 2008 at 11:04:31AM +0100, Hugh Dickins wrote:
> > > moving the page_remove_rmap down was to be fully effective, it needed
> > > to move through a suitable barrier; it hadn't occurred to me that it
> > > was carrying the suitable barrier with it.  But if that is indeed
> > > correct, I think it would be better to rely upon that, than resort
> > > to more difficult arguments.
> > 
> > No I actually think you make a good point, and I'll resubmit the
> > patch with a replacement comment to say we've got the ordering
> > covered if nothing else then by the atomic op in rmap.
> 
> OK, this is a new comment. I don't actually know if it is any good.
> It is hard to be coherent if you write these things in English.
> Maybe it is best to illustrate with the interleaving diagram in the
> changelog?
> 
> --
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

Since I bothered to read all the way through this thread, I might as
well provide an ack,..

Acked-by: Peter Zijlstra <peterz@infradead.org>

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
> @@ -1788,6 +1787,32 @@ gotten:
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
> +			 * The critical issue is to order this
> +			 * page_remove_rmap with the ptp_clear_flush above.
> +			 * Those stores are ordered by (if nothing else,)
> +			 * the barrier present in the atomic_add_negative
> +			 * in page_remove_rmap.
> +			 *
> +			 * Then the TLB flush in ptep_clear_flush ensures that
> +			 * no process can access the old page before the
> +			 * decremented mapcount is visible. And the old page
> +			 * cannot be reused until after the decremented
> +			 * mapcount is visible. So transitively, TLBs to
> +			 * old page will be flushed before it can be reused.
> +			 */
> +			page_remove_rmap(old_page, vma);
> +		}
> +
>  		/* Free the old page.. */
>  		new_page = old_page;
>  		ret |= VM_FAULT_WRITE;
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
