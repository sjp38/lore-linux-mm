Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 043196B00A4
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 18:08:47 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so778178pbc.14
        for <linux-mm@kvack.org>; Wed, 14 Nov 2012 15:08:47 -0800 (PST)
Date: Wed, 14 Nov 2012 15:08:45 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v5 04/11] thp: do_huge_pmd_wp_page(): handle huge zero
 page
In-Reply-To: <1352300463-12627-5-git-send-email-kirill.shutemov@linux.intel.com>
Message-ID: <alpine.DEB.2.00.1211141442590.22537@chino.kir.corp.google.com>
References: <1352300463-12627-1-git-send-email-kirill.shutemov@linux.intel.com> <1352300463-12627-5-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>

On Wed, 7 Nov 2012, Kirill A. Shutemov wrote:

> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index fa06804..fe329da 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -516,6 +516,14 @@ static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
>  }
>  #endif
>  
> +#ifndef my_zero_pfn
> +static inline unsigned long my_zero_pfn(unsigned long addr)
> +{
> +	extern unsigned long zero_pfn;

I don't think you should be declaring this inside an inlined function, you 
probably should be protecting the declarations of the variable and the 
function instead.  Perhaps by CONFIG_MMU?

> +	return zero_pfn;
> +}
> +#endif
> +
>  /*
>   * Multiple processes may "see" the same page. E.g. for untouched
>   * mappings of /dev/null, all processes see the same page full of
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 0d903bf..d767a7c 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -824,6 +824,88 @@ out:
>  	return ret;
>  }
>  
> +/* no "address" argument so destroys page coloring of some arch */
> +pgtable_t get_pmd_huge_pte(struct mm_struct *mm)
> +{

Umm, this is a copy and paste of pgtable_trans_huge_withdraw() from the 
generic page table handling.  Why can't you reuse that and support (and/or 
modify) the s390 and sparc code?

> +	pgtable_t pgtable;
> +
> +	assert_spin_locked(&mm->page_table_lock);
> +
> +	/* FIFO */
> +	pgtable = mm->pmd_huge_pte;
> +	if (list_empty(&pgtable->lru))
> +		mm->pmd_huge_pte = NULL;
> +	else {
> +		mm->pmd_huge_pte = list_entry(pgtable->lru.next,
> +					      struct page, lru);
> +		list_del(&pgtable->lru);
> +	}
> +	return pgtable;
> +}
> +
> +static int do_huge_pmd_wp_zero_page_fallback(struct mm_struct *mm,
> +		struct vm_area_struct *vma, unsigned long address,
> +		pmd_t *pmd, unsigned long haddr)

This whole function is extremely similar to the implementation of 
do_huge_pmd_wp_page_fallback(), there really is no way to fold the two?  
Typically in cases like this it's helpful to split out different logical 
segments of a function into smaller functions that would handle both  
page and !page accordingly.

> +{
> +	pgtable_t pgtable;
> +	pmd_t _pmd;
> +	struct page *page;
> +	int i, ret = 0;
> +	unsigned long mmun_start;	/* For mmu_notifiers */
> +	unsigned long mmun_end;		/* For mmu_notifiers */
> +
> +	page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, address);
> +	if (!page) {
> +		ret |= VM_FAULT_OOM;
> +		goto out;
> +	}
> +
> +	if (mem_cgroup_newpage_charge(page, mm, GFP_KERNEL)) {
> +		put_page(page);
> +		ret |= VM_FAULT_OOM;
> +		goto out;
> +	}
> +
> +	clear_user_highpage(page, address);
> +	__SetPageUptodate(page);
> +
> +	mmun_start = haddr;
> +	mmun_end   = haddr + HPAGE_PMD_SIZE;
> +	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
> +
> +	spin_lock(&mm->page_table_lock);
> +	pmdp_clear_flush(vma, haddr, pmd);
> +	/* leave pmd empty until pte is filled */
> +
> +	pgtable = get_pmd_huge_pte(mm);
> +	pmd_populate(mm, &_pmd, pgtable);
> +
> +	for (i = 0; i < HPAGE_PMD_NR; i++, haddr += PAGE_SIZE) {
> +		pte_t *pte, entry;
> +		if (haddr == (address & PAGE_MASK)) {
> +			entry = mk_pte(page, vma->vm_page_prot);
> +			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
> +			page_add_new_anon_rmap(page, vma, haddr);
> +		} else {
> +			entry = pfn_pte(my_zero_pfn(haddr), vma->vm_page_prot);
> +			entry = pte_mkspecial(entry);
> +		}
> +		pte = pte_offset_map(&_pmd, haddr);
> +		VM_BUG_ON(!pte_none(*pte));
> +		set_pte_at(mm, haddr, pte, entry);
> +		pte_unmap(pte);
> +	}
> +	smp_wmb(); /* make pte visible before pmd */
> +	pmd_populate(mm, pmd, pgtable);
> +	spin_unlock(&mm->page_table_lock);
> +
> +	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
> +
> +	ret |= VM_FAULT_WRITE;
> +out:
> +	return ret;
> +}
> +
>  static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
>  					struct vm_area_struct *vma,
>  					unsigned long address,
> @@ -930,19 +1012,21 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  			unsigned long address, pmd_t *pmd, pmd_t orig_pmd)
>  {
>  	int ret = 0;
> -	struct page *page, *new_page;
> +	struct page *page = NULL, *new_page;
>  	unsigned long haddr;
>  	unsigned long mmun_start;	/* For mmu_notifiers */
>  	unsigned long mmun_end;		/* For mmu_notifiers */
>  
>  	VM_BUG_ON(!vma->anon_vma);
> +	haddr = address & HPAGE_PMD_MASK;
> +	if (is_huge_zero_pmd(orig_pmd))
> +		goto alloc;
>  	spin_lock(&mm->page_table_lock);
>  	if (unlikely(!pmd_same(*pmd, orig_pmd)))
>  		goto out_unlock;
>  
>  	page = pmd_page(orig_pmd);
>  	VM_BUG_ON(!PageCompound(page) || !PageHead(page));
> -	haddr = address & HPAGE_PMD_MASK;
>  	if (page_mapcount(page) == 1) {
>  		pmd_t entry;
>  		entry = pmd_mkyoung(orig_pmd);
> @@ -954,7 +1038,7 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  	}
>  	get_page(page);
>  	spin_unlock(&mm->page_table_lock);
> -
> +alloc:

This could all use a minor restructuring to make it much more cleaner, 
perhaps by extracting the page_mapcount(page) == 1 case to be a separate 
function that deals with non-copying writes?

>  	if (transparent_hugepage_enabled(vma) &&
>  	    !transparent_hugepage_debug_cow())
>  		new_page = alloc_hugepage_vma(transparent_hugepage_defrag(vma),
> @@ -964,24 +1048,34 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  
>  	if (unlikely(!new_page)) {
>  		count_vm_event(THP_FAULT_FALLBACK);
> -		ret = do_huge_pmd_wp_page_fallback(mm, vma, address,
> -						   pmd, orig_pmd, page, haddr);
> -		if (ret & VM_FAULT_OOM)
> -			split_huge_page(page);
> -		put_page(page);
> +		if (is_huge_zero_pmd(orig_pmd)) {
> +			ret = do_huge_pmd_wp_zero_page_fallback(mm, vma,
> +					address, pmd, haddr);
> +		} else {
> +			ret = do_huge_pmd_wp_page_fallback(mm, vma, address,
> +					pmd, orig_pmd, page, haddr);
> +			if (ret & VM_FAULT_OOM)
> +				split_huge_page(page);
> +			put_page(page);
> +		}
>  		goto out;
>  	}
>  	count_vm_event(THP_FAULT_ALLOC);
>  
>  	if (unlikely(mem_cgroup_newpage_charge(new_page, mm, GFP_KERNEL))) {
>  		put_page(new_page);
> -		split_huge_page(page);
> -		put_page(page);
> +		if (page) {
> +			split_huge_page(page);
> +			put_page(page);
> +		}
>  		ret |= VM_FAULT_OOM;
>  		goto out;
>  	}
>  
> -	copy_user_huge_page(new_page, page, haddr, vma, HPAGE_PMD_NR);
> +	if (is_huge_zero_pmd(orig_pmd))
> +		clear_huge_page(new_page, haddr, HPAGE_PMD_NR);
> +	else
> +		copy_user_huge_page(new_page, page, haddr, vma, HPAGE_PMD_NR);
>  	__SetPageUptodate(new_page);
>  
>  	mmun_start = haddr;
> @@ -989,7 +1083,8 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
>  
>  	spin_lock(&mm->page_table_lock);
> -	put_page(page);
> +	if (page)
> +		put_page(page);
>  	if (unlikely(!pmd_same(*pmd, orig_pmd))) {
>  		spin_unlock(&mm->page_table_lock);
>  		mem_cgroup_uncharge_page(new_page);
> @@ -997,7 +1092,6 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  		goto out_mn;
>  	} else {
>  		pmd_t entry;
> -		VM_BUG_ON(!PageHead(page));
>  		entry = mk_pmd(new_page, vma->vm_page_prot);
>  		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
>  		entry = pmd_mkhuge(entry);
> @@ -1005,8 +1099,13 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  		page_add_new_anon_rmap(new_page, vma, haddr);
>  		set_pmd_at(mm, haddr, pmd, entry);
>  		update_mmu_cache_pmd(vma, address, pmd);
> -		page_remove_rmap(page);
> -		put_page(page);
> +		if (is_huge_zero_pmd(orig_pmd))
> +			add_mm_counter(mm, MM_ANONPAGES, HPAGE_PMD_NR);
> +		if (page) {

Couldn't this be an "else" instead?

> +			VM_BUG_ON(!PageHead(page));
> +			page_remove_rmap(page);
> +			put_page(page);
> +		}
>  		ret |= VM_FAULT_WRITE;
>  	}
>  	spin_unlock(&mm->page_table_lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
