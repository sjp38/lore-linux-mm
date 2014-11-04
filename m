Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 657CC6B009A
	for <linux-mm@kvack.org>; Tue,  4 Nov 2014 01:35:09 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id kx10so13797168pab.20
        for <linux-mm@kvack.org>; Mon, 03 Nov 2014 22:35:09 -0800 (PST)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com. [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id iu5si17067827pbc.243.2014.11.03.22.35.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 03 Nov 2014 22:35:07 -0800 (PST)
Received: by mail-pa0-f42.google.com with SMTP id bj1so13868626pad.1
        for <linux-mm@kvack.org>; Mon, 03 Nov 2014 22:35:07 -0800 (PST)
Date: Mon, 3 Nov 2014 22:35:04 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 10/10] mm/hugetlb: share the i_mmap_rwsem
In-Reply-To: <1414697657-1678-11-git-send-email-dave@stgolabs.net>
Message-ID: <alpine.LSU.2.11.1411032208390.15596@eggly.anvils>
References: <1414697657-1678-1-git-send-email-dave@stgolabs.net> <1414697657-1678-11-git-send-email-dave@stgolabs.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.cz>, akpm@linux-foundation.org, hughd@google.com, riel@redhat.com, mgorman@suse.de, peterz@infradead.org, mingo@kernel.org, linux-kernel@vger.kernel.org, dbueso@suse.de, linux-mm@kvack.org

On Thu, 30 Oct 2014, Davidlohr Bueso wrote:

> The i_mmap_rwsem protects shared pages against races
> when doing the sharing and unsharing, ultimately
> calling huge_pmd_share/unshare() for PMD pages --
> it also needs it to avoid races when populating the pud
> for pmd allocation when looking for a shareable pmd page
> for hugetlb. Ultimately the interval tree remains intact.
> 
> Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
> Acked-by: Kirill A. Shutemov <kirill.shutemov@intel.linux.com>
                                                linux.intel.com

I'm uncomfortable with this one: I'm certainly not prepared to Ack it;
but that could easily be that I'm just not thinking hard enough - I'd
rather leave the heavy thinking to someone else!

The fs/hugetlbfs/inode.c part of it should be okay, but the rest is
iffy.  It gets into huge page table sharing territory, which is very
tricky and surprising territory indeed (take a look at my
__unmap_hugepage_range_final() comment, for one example).

You're right that the interval tree remains intact, but I've a feeling
we end up using i_mmap_mutex for more exclusion than just that (rather
like how huge_memory.c finds anon_vma lock useful for other exclusions).

I think Mel (already Cc'ed) and Michal (adding him) both have past
experience with the shared page table (as do I, but I'm in denial).

I wonder if the huge shared page table would be a good next target
for Kirill's removal of mm nastiness.  (Removing it wouldn't hurt
Google for one: we have it "#if 0"ed out, though I forget why at
this moment.)

But, returning to the fs/hugetlbfs/inode.c part of it, that reminds
me: you're missing one patch from the series, aren't you?  Why no
i_mmap_lock_read() in mm/memory.c unmap_mapping_range()?  I doubt
it will add much useful parallelism, but it would be correct.

Hugh

> ---
>  fs/hugetlbfs/inode.c |  4 ++--
>  mm/hugetlb.c         | 12 ++++++------
>  mm/memory.c          |  4 ++--
>  3 files changed, 10 insertions(+), 10 deletions(-)
> 
> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
> index 5eba47f..0dca54d 100644
> --- a/fs/hugetlbfs/inode.c
> +++ b/fs/hugetlbfs/inode.c
> @@ -412,10 +412,10 @@ static int hugetlb_vmtruncate(struct inode *inode, loff_t offset)
>  	pgoff = offset >> PAGE_SHIFT;
>  
>  	i_size_write(inode, offset);
> -	i_mmap_lock_write(mapping);
> +	i_mmap_lock_read(mapping);
>  	if (!RB_EMPTY_ROOT(&mapping->i_mmap))
>  		hugetlb_vmtruncate_list(&mapping->i_mmap, pgoff);
> -	i_mmap_unlock_write(mapping);
> +	i_mmap_unlock_read(mapping);
>  	truncate_hugepages(inode, offset);
>  	return 0;
>  }
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 2071cf4..80349f2 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -2775,7 +2775,7 @@ static void unmap_ref_private(struct mm_struct *mm, struct vm_area_struct *vma,
>  	 * this mapping should be shared between all the VMAs,
>  	 * __unmap_hugepage_range() is called as the lock is already held
>  	 */
> -	i_mmap_lock_write(mapping);
> +	i_mmap_lock_read(mapping);
>  	vma_interval_tree_foreach(iter_vma, &mapping->i_mmap, pgoff, pgoff) {
>  		/* Do not unmap the current VMA */
>  		if (iter_vma == vma)
> @@ -2792,7 +2792,7 @@ static void unmap_ref_private(struct mm_struct *mm, struct vm_area_struct *vma,
>  			unmap_hugepage_range(iter_vma, address,
>  					     address + huge_page_size(h), page);
>  	}
> -	i_mmap_unlock_write(mapping);
> +	i_mmap_unlock_read(mapping);
>  }
>  
>  /*
> @@ -3350,7 +3350,7 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
>  	flush_cache_range(vma, address, end);
>  
>  	mmu_notifier_invalidate_range_start(mm, start, end);
> -	i_mmap_lock_write(vma->vm_file->f_mapping);
> +	i_mmap_lock_read(vma->vm_file->f_mapping);
>  	for (; address < end; address += huge_page_size(h)) {
>  		spinlock_t *ptl;
>  		ptep = huge_pte_offset(mm, address);
> @@ -3379,7 +3379,7 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
>  	 */
>  	flush_tlb_range(vma, start, end);
>  	mmu_notifier_invalidate_range(mm, start, end);
> -	i_mmap_unlock_write(vma->vm_file->f_mapping);
> +	i_mmap_unlock_read(vma->vm_file->f_mapping);
>  	mmu_notifier_invalidate_range_end(mm, start, end);
>  
>  	return pages << h->order;
> @@ -3547,7 +3547,7 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
>  	if (!vma_shareable(vma, addr))
>  		return (pte_t *)pmd_alloc(mm, pud, addr);
>  
> -	i_mmap_lock_write(mapping);
> +	i_mmap_lock_read(mapping);
>  	vma_interval_tree_foreach(svma, &mapping->i_mmap, idx, idx) {
>  		if (svma == vma)
>  			continue;
> @@ -3575,7 +3575,7 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
>  	spin_unlock(ptl);
>  out:
>  	pte = (pte_t *)pmd_alloc(mm, pud, addr);
> -	i_mmap_unlock_write(mapping);
> +	i_mmap_unlock_read(mapping);
>  	return pte;
>  }
>  
> diff --git a/mm/memory.c b/mm/memory.c
> index 22c3089..2ca3105 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1345,9 +1345,9 @@ static void unmap_single_vma(struct mmu_gather *tlb,
>  			 * safe to do nothing in this case.
>  			 */
>  			if (vma->vm_file) {
> -				i_mmap_lock_write(vma->vm_file->f_mapping);
> +				i_mmap_lock_read(vma->vm_file->f_mapping);
>  				__unmap_hugepage_range_final(tlb, vma, start, end, NULL);
> -				i_mmap_unlock_write(vma->vm_file->f_mapping);
> +				i_mmap_unlock_read(vma->vm_file->f_mapping);
>  			}
>  		} else
>  			unmap_page_range(tlb, vma, start, end, details);
> -- 
> 1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
