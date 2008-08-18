Subject: Re: [patch] mm: dirty page tracking race fix
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20080818053821.GA3011@wotan.suse.de>
References: <20080818053821.GA3011@wotan.suse.de>
Content-Type: text/plain
Date: Mon, 18 Aug 2008 09:49:06 +0200
Message-Id: <1219045746.10800.261.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2008-08-18 at 07:38 +0200, Nick Piggin wrote:
> There is a race with dirty page accounting where a page may not properly
> be accounted for.
> 
> clear_page_dirty_for_io() calls page_mkclean; then TestClearPageDirty.
> 
> page_mkclean walks the rmaps for that page, and for each one it cleans and
> write protects the pte if it was dirty. It uses page_check_address to find the
> pte. That function has a shortcut to avoid the ptl if the pte is not
> present. Unfortunately, the pte can be switched to not-present then back to
> present by other code while holding the page table lock -- this should not
> be a signal for page_mkclean to ignore that pte, because it may be dirty.
> 
> For example, powerpc64's set_pte_at will clear a previously present pte before
> setting it to the desired value. There may also be other code in core mm or
> in arch which do similar things.
> 
> The consequence of the bug is loss of data integrity due to msync, and loss
> of dirty page accounting accuracy. XIP's __xip_unmap could easily also be
> unreliable (depending on the exact XIP locking scheme), which can lead to data
> corruption.
> 
> Fix this by having an option to always take ptl to check the pte in
> page_check_address.
> 
> It's possible to retain this optimization for page_referenced and
> try_to_unmap.

s/synch/sync/ ?

we use sync all over the kernel to mean synchonous, so why are you
inventing a new shorthand?

Anyway, still

Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

> Signed-off-by: Nick Piggin <npiggin@suse.de>
> ---
> Index: linux-2.6/include/linux/rmap.h
> ===================================================================
> --- linux-2.6.orig/include/linux/rmap.h
> +++ linux-2.6/include/linux/rmap.h
> @@ -102,7 +102,7 @@ int try_to_unmap(struct page *, int igno
>   * Called from mm/filemap_xip.c to unmap empty zero page
>   */
>  pte_t *page_check_address(struct page *, struct mm_struct *,
> -				unsigned long, spinlock_t **);
> +				unsigned long, spinlock_t **, int);
>  
>  /*
>   * Used by swapoff to help locate where page is expected in vma.
> Index: linux-2.6/mm/filemap_xip.c
> ===================================================================
> --- linux-2.6.orig/mm/filemap_xip.c
> +++ linux-2.6/mm/filemap_xip.c
> @@ -185,7 +185,7 @@ __xip_unmap (struct address_space * mapp
>  		address = vma->vm_start +
>  			((pgoff - vma->vm_pgoff) << PAGE_SHIFT);
>  		BUG_ON(address < vma->vm_start || address >= vma->vm_end);
> -		pte = page_check_address(page, mm, address, &ptl);
> +		pte = page_check_address(page, mm, address, &ptl, 1);
>  		if (pte) {
>  			/* Nuke the page table entry. */
>  			flush_cache_page(vma, address, pte_pfn(*pte));
> Index: linux-2.6/mm/rmap.c
> ===================================================================
> --- linux-2.6.orig/mm/rmap.c
> +++ linux-2.6/mm/rmap.c
> @@ -224,10 +224,14 @@ unsigned long page_address_in_vma(struct
>  /*
>   * Check that @page is mapped at @address into @mm.
>   *
> + * If @synch is false, page_check_address may perform a racy check to avoid
> + * the page table lock when the pte is not present (helpful when reclaiming
> + * highly shared pages).
> + *
>   * On success returns with pte mapped and locked.
>   */
>  pte_t *page_check_address(struct page *page, struct mm_struct *mm,
> -			  unsigned long address, spinlock_t **ptlp)
> +			  unsigned long address, spinlock_t **ptlp, int synch)
>  {
>  	pgd_t *pgd;
>  	pud_t *pud;
> @@ -249,7 +253,7 @@ pte_t *page_check_address(struct page *p
>  
>  	pte = pte_offset_map(pmd, address);
>  	/* Make a quick check before getting the lock */
> -	if (!pte_present(*pte)) {
> +	if (!synch && !pte_present(*pte)) {
>  		pte_unmap(pte);
>  		return NULL;
>  	}
> @@ -281,7 +285,7 @@ static int page_referenced_one(struct pa
>  	if (address == -EFAULT)
>  		goto out;
>  
> -	pte = page_check_address(page, mm, address, &ptl);
> +	pte = page_check_address(page, mm, address, &ptl, 0);
>  	if (!pte)
>  		goto out;
>  
> @@ -450,7 +454,7 @@ static int page_mkclean_one(struct page 
>  	if (address == -EFAULT)
>  		goto out;
>  
> -	pte = page_check_address(page, mm, address, &ptl);
> +	pte = page_check_address(page, mm, address, &ptl, 1);
>  	if (!pte)
>  		goto out;
>  
> @@ -697,7 +701,7 @@ static int try_to_unmap_one(struct page 
>  	if (address == -EFAULT)
>  		goto out;
>  
> -	pte = page_check_address(page, mm, address, &ptl);
> +	pte = page_check_address(page, mm, address, &ptl, 0);
>  	if (!pte)
>  		goto out;
>  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
