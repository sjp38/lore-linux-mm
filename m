Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 2C9F66007E3
	for <linux-mm@kvack.org>; Wed,  2 Dec 2009 15:13:47 -0500 (EST)
Date: Wed, 2 Dec 2009 20:13:39 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH] hugetlb: Acquire the i_mmap_lock before walking the
 prio_tree to unmap a page
In-Reply-To: <20091202141930.GF1457@csn.ul.ie>
Message-ID: <Pine.LNX.4.64.0912022003100.8113@sister.anvils>
References: <20091202141930.GF1457@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 2 Dec 2009, Mel Gorman wrote:

> When the owner of a mapping fails COW because a child process is holding a
> reference and no pages are available, the children VMAs are walked and the
> page is unmapped. The i_mmap_lock is taken for the unmapping of the page but
> not the walking of the prio_tree. In theory, that tree could be changing
> while the lock is released although in practice it is protected by the
> hugetlb_instantiation_mutex. This patch takes the i_mmap_lock properly for
> the duration of the prio_tree walk in case the hugetlb_instantiation_mutex
> ever goes away.
> 
> [hugh.dickins@tiscali.co.uk: Spotted the problem in the first place]
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

The patch looks good - thanks for taking care of that, Mel.

But the comment seems wrong to me: hugetlb_instantiation_mutex
guards against concurrent hugetlb_fault()s; but the structure of
the prio_tree shifts as vmas based on that inode are inserted into
(mmap'ed) and removed from (munmap'ed) that tree (always while
holding i_mmap_lock).  I don't see hugetlb_instantiation_mutex
giving us any protection against this at present.

Hugh

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
