Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id C65566B0044
	for <linux-mm@kvack.org>; Sat,  5 Dec 2009 07:41:37 -0500 (EST)
Date: Sat, 5 Dec 2009 12:41:26 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH] hugetlb: Acquire the i_mmap_lock before walking the
 prio_tree to unmap a page V2
In-Reply-To: <20091202222049.GC26702@csn.ul.ie>
Message-ID: <Pine.LNX.4.64.0912051237060.31181@sister.anvils>
References: <20091202222049.GC26702@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 2 Dec 2009, Mel Gorman wrote:

> Changelog since V1
> o Delete stupid comment from the description
> 
> When the owner of a mapping fails  COW because a child process is holding
> a reference, the children VMAs are walked and the page is unmapped. The
> i_mmap_lock is taken for the unmapping of the page but not the walking of
> the prio_tree. In theory, that tree could be changing if the lock is not
> held. This patch takes the i_mmap_lock properly for the duration of the
> prio_tree walk.
> 
> [hugh.dickins@tiscali.co.uk: Spotted the problem in the first place]
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

Acked-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>

(and Andrew has already put this version into mmotm, thanks)

> ---
>  mm/hugetlb.c |    9 ++++++++-
>  1 files changed, 8 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index a952cb8..5adc284 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1906,6 +1906,12 @@ static int unmap_ref_private(struct mm_struct *mm, struct vm_area_struct *vma,
>  		+ (vma->vm_pgoff >> PAGE_SHIFT);
>  	mapping = (struct address_space *)page_private(page);
>  
> +	/*
> +	 * Take the mapping lock for the duration of the table walk. As
> +	 * this mapping should be shared between all the VMAs,
> +	 * __unmap_hugepage_range() is called as the lock is already held
> +	 */
> +	spin_lock(&mapping->i_mmap_lock);
>  	vma_prio_tree_foreach(iter_vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
>  		/* Do not unmap the current VMA */
>  		if (iter_vma == vma)
> @@ -1919,10 +1925,11 @@ static int unmap_ref_private(struct mm_struct *mm, struct vm_area_struct *vma,
>  		 * from the time of fork. This would look like data corruption
>  		 */
>  		if (!is_vma_resv_set(iter_vma, HPAGE_RESV_OWNER))
> -			unmap_hugepage_range(iter_vma,
> +			__unmap_hugepage_range(iter_vma,
>  				address, address + huge_page_size(h),
>  				page);
>  	}
> +	spin_unlock(&mapping->i_mmap_lock);
>  
>  	return 1;
>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
