Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id C28CE6B007E
	for <linux-mm@kvack.org>; Wed,  9 Sep 2009 07:31:43 -0400 (EDT)
Date: Wed, 9 Sep 2009 12:31:43 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 5/8] mm: follow_hugetlb_page flags
Message-ID: <20090909113143.GG24614@csn.ul.ie>
References: <Pine.LNX.4.64.0909072222070.15424@sister.anvils> <Pine.LNX.4.64.0909072235360.15430@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0909072235360.15430@sister.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 07, 2009 at 10:37:14PM +0100, Hugh Dickins wrote:
> follow_hugetlb_page() shouldn't be guessing about the coredump case
> either: pass the foll_flags down to it, instead of just the write bit.
> 
> Remove that obscure huge_zeropage_ok() test.  The decision is easy,
> though unlike the non-huge case - here vm_ops->fault is always set.
> But we know that a fault would serve up zeroes, unless there's
> already a hugetlbfs pagecache page to back the range.
> 
> (Alternatively, since hugetlb pages aren't swapped out under pressure,
> you could save more dump space by arguing that a page not yet faulted
> into this process cannot be relevant to the dump; but that would be
> more surprising.)
> 

It would be more surprising. It's an implementation detail that hugetlb
pages cannot be swapped out and someone reading the dump shouldn't have
to be aware of it. It's better to treat non-faulted pages as if they
were zero-filled.

> Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> ---
> 
>  include/linux/hugetlb.h |    4 +-
>  mm/hugetlb.c            |   62 ++++++++++++++++++++++----------------
>  mm/memory.c             |   14 ++++----
>  3 files changed, 48 insertions(+), 32 deletions(-)
> 
> --- mm4/include/linux/hugetlb.h	2009-09-05 14:40:16.000000000 +0100
> +++ mm5/include/linux/hugetlb.h	2009-09-07 13:16:46.000000000 +0100
> @@ -24,7 +24,9 @@ int hugetlb_sysctl_handler(struct ctl_ta
>  int hugetlb_overcommit_handler(struct ctl_table *, int, void __user *, size_t *, loff_t *);
>  int hugetlb_treat_movable_handler(struct ctl_table *, int, void __user *, size_t *, loff_t *);
>  int copy_hugetlb_page_range(struct mm_struct *, struct mm_struct *, struct vm_area_struct *);
> -int follow_hugetlb_page(struct mm_struct *, struct vm_area_struct *, struct page **, struct vm_area_struct **, unsigned long *, int *, int, int);
> +int follow_hugetlb_page(struct mm_struct *, struct vm_area_struct *,
> +			struct page **, struct vm_area_struct **,
> +			unsigned long *, int *, int, unsigned int flags);
>  void unmap_hugepage_range(struct vm_area_struct *,
>  			unsigned long, unsigned long, struct page *);
>  void __unmap_hugepage_range(struct vm_area_struct *,
> --- mm4/mm/hugetlb.c	2009-09-05 14:40:16.000000000 +0100
> +++ mm5/mm/hugetlb.c	2009-09-07 13:16:46.000000000 +0100
> @@ -2016,6 +2016,23 @@ static struct page *hugetlbfs_pagecache_
>  	return find_lock_page(mapping, idx);
>  }
>  
> +/* Return whether there is a pagecache page to back given address within VMA */
> +static bool hugetlbfs_backed(struct hstate *h,
> +			struct vm_area_struct *vma, unsigned long address)
> +{
> +	struct address_space *mapping;
> +	pgoff_t idx;
> +	struct page *page;
> +
> +	mapping = vma->vm_file->f_mapping;
> +	idx = vma_hugecache_offset(h, vma, address);
> +
> +	page = find_get_page(mapping, idx);
> +	if (page)
> +		put_page(page);
> +	return page != NULL;
> +}
> +

It's a total nit-pick, but this is very similar to
hugetlbfs_pagecache_page(). It would have been nice to have them nearby
and called something like hugetlbfs_pagecache_present() or else reuse
the function and have the caller unlock_page but it's probably not worth
addressing.

>  static int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  			unsigned long address, pte_t *ptep, unsigned int flags)
>  {
> @@ -2211,54 +2228,52 @@ follow_huge_pud(struct mm_struct *mm, un
>  	return NULL;
>  }
>  
> -static int huge_zeropage_ok(pte_t *ptep, int write, int shared)
> -{
> -	if (!ptep || write || shared)
> -		return 0;
> -	else
> -		return huge_pte_none(huge_ptep_get(ptep));
> -}
> -
>  int follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  			struct page **pages, struct vm_area_struct **vmas,
>  			unsigned long *position, int *length, int i,
> -			int write)
> +			unsigned int flags)

Total aside, but in line with gfp_t flags, is there a case for having
foll_t type for FOLL_* ?

>  {
>  	unsigned long pfn_offset;
>  	unsigned long vaddr = *position;
>  	int remainder = *length;
>  	struct hstate *h = hstate_vma(vma);
> -	int zeropage_ok = 0;
> -	int shared = vma->vm_flags & VM_SHARED;
>  
>  	spin_lock(&mm->page_table_lock);
>  	while (vaddr < vma->vm_end && remainder) {
>  		pte_t *pte;
> +		int absent;
>  		struct page *page;
>  
>  		/*
>  		 * Some archs (sparc64, sh*) have multiple pte_ts to
> -		 * each hugepage.  We have to make * sure we get the
> +		 * each hugepage.  We have to make sure we get the
>  		 * first, for the page indexing below to work.
>  		 */
>  		pte = huge_pte_offset(mm, vaddr & huge_page_mask(h));
> -		if (huge_zeropage_ok(pte, write, shared))
> -			zeropage_ok = 1;
> +		absent = !pte || huge_pte_none(huge_ptep_get(pte));
> +
> +		/*
> +		 * When coredumping, it suits get_dump_page if we just return
> +		 * an error if there's a hole and no huge pagecache to back it.
> +		 */
> +		if (absent &&
> +		    ((flags & FOLL_DUMP) && !hugetlbfs_backed(h, vma, vaddr))) {
> +			remainder = 0;
> +			break;
> +		}

Does this break an assumption of get_user_pages() whereby when there are
holes, the corresponding pages are NULL but the following pages are still
checked? I guess the caller is informed ultimately that the read was only
partial but offhand I don't know if that's generally expected or not.

Or is your comment saying that because the only caller using FOLL_DUMP is
get_dump_page() using an array of one page, it doesn't care and the case is
just not worth dealing with?

>  
> -		if (!pte ||
> -		    (huge_pte_none(huge_ptep_get(pte)) && !zeropage_ok) ||
> -		    (write && !pte_write(huge_ptep_get(pte)))) {
> +		if (absent ||
> +		    ((flags & FOLL_WRITE) && !pte_write(huge_ptep_get(pte)))) {
>  			int ret;
>  
>  			spin_unlock(&mm->page_table_lock);
> -			ret = hugetlb_fault(mm, vma, vaddr, write);
> +			ret = hugetlb_fault(mm, vma, vaddr,
> +				(flags & FOLL_WRITE) ? FAULT_FLAG_WRITE : 0);
>  			spin_lock(&mm->page_table_lock);
>  			if (!(ret & VM_FAULT_ERROR))
>  				continue;
>  
>  			remainder = 0;
> -			if (!i)
> -				i = -EFAULT;
>  			break;
>  		}
>  
> @@ -2266,10 +2281,7 @@ int follow_hugetlb_page(struct mm_struct
>  		page = pte_page(huge_ptep_get(pte));
>  same_page:
>  		if (pages) {
> -			if (zeropage_ok)
> -				pages[i] = ZERO_PAGE(0);
> -			else
> -				pages[i] = mem_map_offset(page, pfn_offset);
> +			pages[i] = mem_map_offset(page, pfn_offset);
>  			get_page(pages[i]);
>  		}
>  
> @@ -2293,7 +2305,7 @@ same_page:
>  	*length = remainder;
>  	*position = vaddr;
>  
> -	return i;
> +	return i ? i : -EFAULT;
>  }
>  
>  void hugetlb_change_protection(struct vm_area_struct *vma,
> --- mm4/mm/memory.c	2009-09-07 13:16:39.000000000 +0100
> +++ mm5/mm/memory.c	2009-09-07 13:16:46.000000000 +0100
> @@ -1260,17 +1260,19 @@ int __get_user_pages(struct task_struct
>  		    !(vm_flags & vma->vm_flags))
>  			return i ? : -EFAULT;
>  
> -		if (is_vm_hugetlb_page(vma)) {
> -			i = follow_hugetlb_page(mm, vma, pages, vmas,
> -						&start, &nr_pages, i, write);
> -			continue;
> -		}
> -
>  		foll_flags = FOLL_TOUCH;
>  		if (pages)
>  			foll_flags |= FOLL_GET;
>  		if (flags & GUP_FLAGS_DUMP)
>  			foll_flags |= FOLL_DUMP;
> +		if (write)
> +			foll_flags |= FOLL_WRITE;
> +
> +		if (is_vm_hugetlb_page(vma)) {
> +			i = follow_hugetlb_page(mm, vma, pages, vmas,
> +					&start, &nr_pages, i, foll_flags);
> +			continue;
> +		}
>  
>  		do {
>  			struct page *page;
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
