Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id BE1E96B007B
	for <linux-mm@kvack.org>; Mon,  1 Feb 2010 03:30:24 -0500 (EST)
Date: Mon, 1 Feb 2010 17:15:32 +1100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH -mm] remove VM_LOCK_RMAP code
Message-ID: <20100201061532.GC9085@laptop>
References: <20100128002000.2bf5e365@annuminas.surriel.com>
 <20100129151423.8b71b88e.akpm@linux-foundation.org>
 <20100129193410.7ce915d0@annuminas.surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100129193410.7ce915d0@annuminas.surriel.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, lwoodman@redhat.com, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, aarcange@redhat.com
List-ID: <linux-mm.kvack.org>

On Fri, Jan 29, 2010 at 07:34:10PM -0500, Rik van Riel wrote:
> When a VMA is in an inconsistent state during setup or teardown, the
> worst that can happen is that the rmap code will not be able to find
> the page.

OK, but you missed the interesting thing, which is to explain why
that worst case is not a problem.

rmap of course is not just used for reclaim but also invalidations
from mappings, and those guys definitely need to know that all
page table entries have been handled by the time they return.

> 
> It is also impossible for the rmap code to follow a pointer to an
> already freed VMA, because the rmap code holds the anon_vma->lock,
> which the VMA teardown code needs to take before the VMA is removed
> from the anon_vma chain.
> 
> Hence, we should not need the VM_LOCK_RMAP locking at all.
> 
> Sent as a separate patch because I would appreciate it if others
> could verify my logic :)
> 
> Signed-off-by: Rik van Riel <riel@redhat.com>
> ---
>  include/linux/mm.h |    4 ----
>  mm/mmap.c          |   15 ---------------
>  mm/rmap.c          |   12 ------------
>  3 files changed, 0 insertions(+), 31 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 93bbb70..5866e0c 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -96,11 +96,7 @@ extern unsigned int kobjsize(const void *objp);
>  #define VM_NORESERVE	0x00200000	/* should the VM suppress accounting */
>  #define VM_HUGETLB	0x00400000	/* Huge TLB Page VM */
>  #define VM_NONLINEAR	0x00800000	/* Is non-linear (remap_file_pages) */
> -#ifdef CONFIG_MMU
> -#define VM_LOCK_RMAP	0x01000000	/* Do not follow this rmap (mmu mmap) */
> -#else
>  #define VM_MAPPED_COPY	0x01000000	/* T if mapped copy of data (nommu mmap) */
> -#endif
>  #define VM_INSERTPAGE	0x02000000	/* The vma has had "vm_insert_page()" done on it */
>  #define VM_ALWAYSDUMP	0x04000000	/* Always include in core dumps */
>  
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 58a3d72..de9e953 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -554,9 +554,7 @@ again:			remove_next = 1 + (end > next->vm_end);
>  		 */
>  		if (importer && !importer->anon_vma) {
>  			/* Block reverse map lookups until things are set up. */
> -			importer->vm_flags |= VM_LOCK_RMAP;
>  			if (anon_vma_clone(importer, vma)) {
> -				importer->vm_flags &= ~VM_LOCK_RMAP;
>  				return -ENOMEM;
>  			}
>  			importer->anon_vma = anon_vma;
> @@ -618,11 +616,6 @@ again:			remove_next = 1 + (end > next->vm_end);
>  		__vma_unlink(mm, next, vma);
>  		if (file)
>  			__remove_shared_vm_struct(next, file, mapping);
> -		/*
> -		 * This VMA is now dead, no need for rmap to follow it.
> -		 * Call anon_vma_merge below, outside of i_mmap_lock.
> -		 */
> -		next->vm_flags |= VM_LOCK_RMAP;
>  	} else if (insert) {
>  		/*
>  		 * split_vma has split insert from vma, and needs
> @@ -635,20 +628,12 @@ again:			remove_next = 1 + (end > next->vm_end);
>  	if (mapping)
>  		spin_unlock(&mapping->i_mmap_lock);
>  
> -	/*
> -	 * The current VMA has been set up. It is now safe for the
> -	 * rmap code to get from the pages to the ptes.
> -	 */
> -	if (anon_vma && importer)
> -		importer->vm_flags &= ~VM_LOCK_RMAP;
> -
>  	if (remove_next) {
>  		if (file) {
>  			fput(file);
>  			if (next->vm_flags & VM_EXECUTABLE)
>  				removed_exe_file_vma(mm);
>  		}
> -		/* Protected by mmap_sem and VM_LOCK_RMAP. */
>  		if (next->anon_vma)
>  			anon_vma_merge(vma, next);
>  		mm->map_count--;
> diff --git a/mm/rmap.c b/mm/rmap.c
> index aa11f3c..818615a 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -329,18 +329,6 @@ vma_address(struct page *page, struct vm_area_struct *vma)
>  		/* page should be within @vma mapping range */
>  		return -EFAULT;
>  	}
> -	if (unlikely(vma->vm_flags & VM_LOCK_RMAP)) {
> -		/*
> -		 * This VMA is being unlinked or is not yet linked into the
> -		 * VMA tree.  Do not try to follow this rmap.  This race
> -		 * condition can result in page_referenced() ignoring a
> -		 * reference or in try_to_unmap() failing to unmap a page.
> -		 * The VMA cannot be freed under us because we hold the
> -		 * anon_vma->lock, which the munmap code takes while
> -		 * unlinking the anon_vmas from the VMA.
> -		 */
> -		return -EFAULT;
> -	}
>  	return address;
>  }
>  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
