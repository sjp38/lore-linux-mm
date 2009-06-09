Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 825856B004D
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 12:49:38 -0400 (EDT)
Date: Tue, 9 Jun 2009 18:24:35 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH 0/4] RFC - ksm api change into madvise
In-Reply-To: <20090609074848.5357839a@woof.tlv.redhat.com>
Message-ID: <Pine.LNX.4.64.0906091807300.20120@sister.anvils>
References: <1242261048-4487-1-git-send-email-ieidus@redhat.com>
 <Pine.LNX.4.64.0906081555360.22943@sister.anvils> <4A2D47C1.5020302@redhat.com>
 <Pine.LNX.4.64.0906081902520.9518@sister.anvils> <4A2D7036.1010800@redhat.com>
 <20090609074848.5357839a@woof.tlv.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Izik Eidus <ieidus@redhat.com>
Cc: aarcange@redhat.com, akpm@linux-foundation.org, nickpiggin@yahoo.com.au, chrisw@redhat.com, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 9 Jun 2009, Izik Eidus wrote:
> How does this look like?

It looks about right to me, and how delightful to be rid of that
horrid odirect_sync argument!

For now I'll turn a blind eye to your idiosyncratic return code
convention (0 for success, 1 for failure: we're already schizoid
enough with 0 for failure, 1 for success boolean functions versus
0 for success, -errno for failure functions): you're being consistent
with yourself, let's run through ksm.c at a later date to sort that out.

One improvment to make now, though: you've elsewhere avoided
the pgd,pud,pmd,pte descent in ksm.c (using get_pte instead), and
page_check_address() is not static to rmap.c (filemap_xip wanted it),
so please continue to use that.  It's not exported, right, but I think
Chris was already decisive that we should abandon modular KSM, yes?

So I think slip in a patch before this one to remove the modular
option, so as not to generate traffic from people who build all
modular kernels.  Or if you think the modular option should remain,
append an EXPORT_SYMBOL to page_check_address().

Thanks,
Hugh

> 
> From f41b092bee1437f6f436faa74f5da56403f61009 Mon Sep 17 00:00:00 2001
> From: Izik Eidus <ieidus@redhat.com>
> Date: Tue, 9 Jun 2009 07:24:25 +0300
> Subject: [PATCH] ksm: remove page_wrprotect() from rmap.c
> 
> Remove page_wrprotect() from rmap.c and instead embedded the needed code
> into ksm.c
> 
> Hugh pointed out that for the ksm usage case, we dont have to walk over the rmap
> and to write protected page after page beacuse when Anonymous page is mapped
> more than once, it have to be write protected already, and in a case that it
> mapped just once, no need to walk over the rmap, we can instead write protect
> it from inside ksm.c.
> 
> Thanks.
> 
> Signed-off-by: Izik Eidus <ieidus@redhat.com>
> ---
>  include/linux/rmap.h |   12 ----
>  mm/ksm.c             |   83 ++++++++++++++++++++++++++----
>  mm/rmap.c            |  139 --------------------------------------------------
>  3 files changed, 73 insertions(+), 161 deletions(-)
> 
> diff --git a/include/linux/rmap.h b/include/linux/rmap.h
> index 469376d..350e76d 100644
> --- a/include/linux/rmap.h
> +++ b/include/linux/rmap.h
> @@ -118,10 +118,6 @@ static inline int try_to_munlock(struct page *page)
>  }
>  #endif
>  
> -#if defined(CONFIG_KSM) || defined(CONFIG_KSM_MODULE)
> -int page_wrprotect(struct page *page, int *odirect_sync, int count_offset);
> -#endif
> -
>  #else	/* !CONFIG_MMU */
>  
>  #define anon_vma_init()		do {} while (0)
> @@ -136,14 +132,6 @@ static inline int page_mkclean(struct page *page)
>  	return 0;
>  }
>  
> -#if defined(CONFIG_KSM) || defined(CONFIG_KSM_MODULE)
> -static inline int page_wrprotect(struct page *page, int *odirect_sync,
> -				 int count_offset)
> -{
> -	return 0;
> -}
> -#endif
> -
>  #endif	/* CONFIG_MMU */
>  
>  /*
> diff --git a/mm/ksm.c b/mm/ksm.c
> index 74d921b..9fce82b 100644
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -37,6 +37,7 @@
>  #include <linux/swap.h>
>  #include <linux/rbtree.h>
>  #include <linux/anon_inodes.h>
> +#include <linux/mmu_notifier.h>
>  #include <linux/ksm.h>
>  
>  #include <asm/tlbflush.h>
> @@ -642,6 +643,75 @@ static inline int pages_identical(struct page *page1, struct page *page2)
>  	return !memcmp_pages(page1, page2);
>  }
>  
> +static inline int write_protect_page(struct page *page,
> +				     struct vm_area_struct *vma,
> +				     unsigned long addr,
> +				     pte_t orig_pte)
> +{
> +	struct mm_struct *mm = vma->vm_mm;
> +	pgd_t *pgd;
> +	pud_t *pud;
> +	pmd_t *pmd;
> +	pte_t *ptep;
> +	spinlock_t *ptl;
> +	int swapped;
> +	int ret = 1;
> +
> +	pgd = pgd_offset(mm, addr);
> +	if (!pgd_present(*pgd))
> +		goto out;
> +
> +	pud = pud_offset(pgd, addr);
> +	if (!pud_present(*pud))
> +		goto out;
> +
> +	pmd = pmd_offset(pud, addr);
> +	if (!pmd_present(*pmd))
> +		goto out;
> +
> +	ptep = pte_offset_map_lock(mm, pmd, addr, &ptl);
> +	if (!ptep)
> +		goto out;
> +
> +	if (!pte_same(*ptep, orig_pte)) {
> +		pte_unmap_unlock(ptep, ptl);
> +		goto out;
> +	}
> +
> +	if (pte_write(*ptep)) {
> +		pte_t entry;
> +
> +		swapped = PageSwapCache(page);
> +		flush_cache_page(vma, addr, page_to_pfn(page));
> +		/*
> +		 * Ok this is tricky, when get_user_pages_fast() run it doesnt
> +		 * take any lock, therefore the check that we are going to make
> +		 * with the pagecount against the mapcount is racey and
> +		 * O_DIRECT can happen right after the check.
> +		 * So we clear the pte and flush the tlb before the check
> +		 * this assure us that no O_DIRECT can happen after the check
> +		 * or in the middle of the check.
> +		 */
> +		entry = ptep_clear_flush(vma, addr, ptep);
> +		/*
> +		 * Check that no O_DIRECT or similar I/O is in progress on the
> +		 * page
> +		 */
> +		if ((page_mapcount(page) + 2 + swapped) != page_count(page)) {
> +			set_pte_at_notify(mm, addr, ptep, entry);
> +			goto out_unlock;
> +		}
> +		entry = pte_wrprotect(entry);
> +		set_pte_at_notify(mm, addr, ptep, entry);
> +	}
> +	ret = 0;
> +
> +out_unlock:
> +	pte_unmap_unlock(ptep, ptl);
> +out:
> +	return ret;
> +}
> +
>  /*
>   * try_to_merge_one_page - take two pages and merge them into one
>   * @mm: mm_struct that hold vma pointing into oldpage
> @@ -661,7 +731,6 @@ static int try_to_merge_one_page(struct mm_struct *mm,
>  				 pgprot_t newprot)
>  {
>  	int ret = 1;
> -	int odirect_sync;
>  	unsigned long page_addr_in_vma;
>  	pte_t orig_pte, *orig_ptep;
>  
> @@ -686,25 +755,19 @@ static int try_to_merge_one_page(struct mm_struct *mm,
>  		goto out_putpage;
>  	/*
>  	 * we need the page lock to read a stable PageSwapCache in
> -	 * page_wrprotect().
> +	 * write_protect_page().
>  	 * we use trylock_page() instead of lock_page(), beacuse we dont want to
>  	 * wait here, we prefer to continue scanning and merging diffrent pages
>  	 * and to come back to this page when it is unlocked.
>  	 */
>  	if (!trylock_page(oldpage))
>  		goto out_putpage;
> -	/*
> -	 * page_wrprotect check if the page is swapped or in swap cache,
> -	 * in the future we might want to run here if_present_pte and then
> -	 * swap_free
> -	 */
> -	if (!page_wrprotect(oldpage, &odirect_sync, 2)) {
> +
> +	if (write_protect_page(oldpage, vma, page_addr_in_vma, orig_pte)) {
>  		unlock_page(oldpage);
>  		goto out_putpage;
>  	}
>  	unlock_page(oldpage);
> -	if (!odirect_sync)
> -		goto out_putpage;
>  
>  	orig_pte = pte_wrprotect(orig_pte);
>  
> diff --git a/mm/rmap.c b/mm/rmap.c
> index f53074c..c3ba0b9 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -585,145 +585,6 @@ int page_mkclean(struct page *page)
>  }
>  EXPORT_SYMBOL_GPL(page_mkclean);
>  
> -#if defined(CONFIG_KSM) || defined(CONFIG_KSM_MODULE)
> -
> -static int page_wrprotect_one(struct page *page, struct vm_area_struct *vma,
> -			      int *odirect_sync, int count_offset)
> -{
> -	struct mm_struct *mm = vma->vm_mm;
> -	unsigned long address;
> -	pte_t *pte;
> -	spinlock_t *ptl;
> -	int ret = 0;
> -
> -	address = vma_address(page, vma);
> -	if (address == -EFAULT)
> -		goto out;
> -
> -	pte = page_check_address(page, mm, address, &ptl, 0);
> -	if (!pte)
> -		goto out;
> -
> -	if (pte_write(*pte)) {
> -		pte_t entry;
> -
> -		flush_cache_page(vma, address, pte_pfn(*pte));
> -		/*
> -		 * Ok this is tricky, when get_user_pages_fast() run it doesnt
> -		 * take any lock, therefore the check that we are going to make
> -		 * with the pagecount against the mapcount is racey and
> -		 * O_DIRECT can happen right after the check.
> -		 * So we clear the pte and flush the tlb before the check
> -		 * this assure us that no O_DIRECT can happen after the check
> -		 * or in the middle of the check.
> -		 */
> -		entry = ptep_clear_flush(vma, address, pte);
> -		/*
> -		 * Check that no O_DIRECT or similar I/O is in progress on the
> -		 * page
> -		 */
> -		if ((page_mapcount(page) + count_offset) != page_count(page)) {
> -			*odirect_sync = 0;
> -			set_pte_at_notify(mm, address, pte, entry);
> -			goto out_unlock;
> -		}
> -		entry = pte_wrprotect(entry);
> -		set_pte_at_notify(mm, address, pte, entry);
> -	}
> -	ret = 1;
> -
> -out_unlock:
> -	pte_unmap_unlock(pte, ptl);
> -out:
> -	return ret;
> -}
> -
> -static int page_wrprotect_file(struct page *page, int *odirect_sync,
> -			       int count_offset)
> -{
> -	struct address_space *mapping;
> -	struct prio_tree_iter iter;
> -	struct vm_area_struct *vma;
> -	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
> -	int ret = 0;
> -
> -	mapping = page_mapping(page);
> -	if (!mapping)
> -		return ret;
> -
> -	spin_lock(&mapping->i_mmap_lock);
> -
> -	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff)
> -		ret += page_wrprotect_one(page, vma, odirect_sync,
> -					  count_offset);
> -
> -	spin_unlock(&mapping->i_mmap_lock);
> -
> -	return ret;
> -}
> -
> -static int page_wrprotect_anon(struct page *page, int *odirect_sync,
> -			       int count_offset)
> -{
> -	struct vm_area_struct *vma;
> -	struct anon_vma *anon_vma;
> -	int ret = 0;
> -
> -	anon_vma = page_lock_anon_vma(page);
> -	if (!anon_vma)
> -		return ret;
> -
> -	/*
> -	 * If the page is inside the swap cache, its _count number was
> -	 * increased by one, therefore we have to increase count_offset by one.
> -	 */
> -	if (PageSwapCache(page))
> -		count_offset++;
> -
> -	list_for_each_entry(vma, &anon_vma->head, anon_vma_node)
> -		ret += page_wrprotect_one(page, vma, odirect_sync,
> -					  count_offset);
> -
> -	page_unlock_anon_vma(anon_vma);
> -
> -	return ret;
> -}
> -
> -/**
> - * page_wrprotect - set all ptes pointing to a page as readonly
> - * @page:         the page to set as readonly
> - * @odirect_sync: boolean value that is set to 0 when some of the ptes were not
> - *                marked as readonly beacuse page_wrprotect_one() was not able
> - *                to mark this ptes as readonly without opening window to a race
> - *                with odirect
> - * @count_offset: number of times page_wrprotect() caller had called get_page()
> - *                on the page
> - *
> - * returns the number of ptes which were marked as readonly.
> - * (ptes that were readonly before this function was called are counted as well)
> - */
> -int page_wrprotect(struct page *page, int *odirect_sync, int count_offset)
> -{
> -	int ret = 0;
> -
> -	/*
> -	 * Page lock is needed for anon pages for the PageSwapCache check,
> -	 * and for page_mapping for filebacked pages
> -	 */
> -	BUG_ON(!PageLocked(page));
> -
> -	*odirect_sync = 1;
> -	if (PageAnon(page))
> -		ret = page_wrprotect_anon(page, odirect_sync, count_offset);
> -	else
> -		ret = page_wrprotect_file(page, odirect_sync, count_offset);
> -
> -	return ret;
> -}
> -EXPORT_SYMBOL(page_wrprotect);
> -
> -#endif
> -
>  /**
>   * __page_set_anon_rmap - setup new anonymous rmap
>   * @page:	the page to add the mapping to
> -- 
> 1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
