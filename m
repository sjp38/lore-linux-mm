Date: Mon, 19 Mar 2007 13:35:56 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 3/4] mm: move mlocked pages off the LRU
In-Reply-To: <20070312042620.5536.55886.sendpatchset@linux.site>
Message-ID: <Pine.LNX.4.64.0703191325120.8150@schroedinger.engr.sgi.com>
References: <20070312042553.5536.73828.sendpatchset@linux.site>
 <20070312042620.5536.55886.sendpatchset@linux.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Mon, 12 Mar 2007, Nick Piggin wrote:

> @@ -859,9 +873,23 @@ static int try_to_unmap_anon(struct page
>  		ret = try_to_unmap_one(page, vma, migration);
>  		if (ret == SWAP_FAIL || !page_mapped(page))
>  			break;
> +		if (ret == SWAP_MLOCK) {
> +			if (down_read_trylock(&vma->vm_mm->mmap_sem)) {
> +				if (vma->vm_flags & VM_LOCKED) {
> +					mlock_vma_page(page);
> +					mlocked++;
> +				}

Ok. we move mlocked pages off the LRU here...

> +				up_read(&vma->vm_mm->mmap_sem);
> +			}

			^^^ else ret = SWAP_AGAIN ?
> +		}
>  	}
> -
>  	page_unlock_anon_vma(anon_vma);
> +
> +	if (mlocked)
> +		ret = SWAP_MLOCK;
> +	else if (ret == SWAP_MLOCK)
> +		ret = SWAP_AGAIN;

So if we failed to mlock (because we could not acquire mmap_sem) then we 
fall back to SWAP_AGAIN. Would it not be cleaner to change ret to 
SWAP_AGAIN as I noted above?

>  		if (ret == SWAP_FAIL || !page_mapped(page))
>  			goto out;
> +		if (ret == SWAP_MLOCK) {
> +			if (down_read_trylock(&vma->vm_mm->mmap_sem)) {
> +				if (vma->vm_flags & VM_LOCKED) {
> +					mlock_vma_page(page);
> +					mlocked++;
> +				}
> +				up_read(&vma->vm_mm->mmap_sem);
> +			}
> +		}

Humpf. Code replication.

> Index: linux-2.6/mm/memory.c
> ===================================================================
>  		update_mmu_cache(vma, address, entry);
> -		lru_cache_add_active(new_page);
> +		if (!(vma->vm_flags & VM_LOCKED))
> +			lru_cache_add_active(new_page);
> +		else
> +			mlock_new_vma_page(new_page);
>  		page_add_new_anon_rmap(new_page, vma, address);

^^^ The above block repeats again and again.

> Index: linux-2.6/mm/mempolicy.c
> ===================================================================
> --- linux-2.6.orig/mm/mempolicy.c
> +++ linux-2.6/mm/mempolicy.c
> +	struct pagevec migrate;
> +	int i;
> +
> +resume:
> +	pagevec_init(&migrate, 0);

Thats new. use a pagevec.
  
> @@ -254,12 +261,26 @@ static int check_pte_range(struct vm_are
>  
>  		if (flags & MPOL_MF_STATS)
>  			gather_stats(page, private, pte_dirty(*pte));
> -		else if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL))
> -			migrate_page_add(page, private, flags);
> -		else
> +		else if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL)) {
> +			if (!pagevec_add(&migrate, page)) {

pagevec adds increases refcount right? How can isolate_page_lru cope
with the refcount increase? Wont work.

> +				pte_unmap_unlock(orig_pte, ptl);
> +				for (i = 0; i < pagevec_count(&migrate); i++) {
> +					struct page *page = migrate.pages[i];
> +					if (PageMLock(page)) {
> +						lock_page(page);
> +						clear_page_mlock(page);
> +						unlock_page(page);
> +						lru_add_drain();
> +					}

If you do not take the refcount in pagevec_add then there is nothing here
holding the page except for the pte reference.

> +					migrate_page_add(page, private, flags);

migrate_page_add is going to fail always. Migrate_page_add should make the
decision if a page can be taken off the LRU or not. That is why we could 
not use a pagevec.

> @@ -363,6 +384,7 @@ check_range(struct mm_struct *mm, unsign
>  				endvma = end;
>  			if (vma->vm_start > start)
>  				start = vma->vm_start;
> +
>  			err = check_pgd_range(vma, start, endvma, nodes,
>  						flags, private);
>  			if (err) {

Huh? No changes to migrate.c?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
