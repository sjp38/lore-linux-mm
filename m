Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 26D296B0253
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 19:39:55 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so114958668pac.3
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 16:39:54 -0800 (PST)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com. [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id ua10si30721521pab.236.2015.11.13.16.39.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Nov 2015 16:39:54 -0800 (PST)
Received: by pacej9 with SMTP id ej9so8360074pac.2
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 16:39:54 -0800 (PST)
Date: Fri, 13 Nov 2015 16:39:52 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v3] mm/hugetlbfs Fix bugs in fallocate hole punch of
 areas with holes
In-Reply-To: <1447215288-23753-1-git-send-email-mike.kravetz@oracle.com>
Message-ID: <alpine.LSU.2.11.1511131636350.1310@eggly.anvils>
References: <1447215288-23753-1-git-send-email-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, Davidlohr Bueso <dave@stgolabs.net>

On Tue, 10 Nov 2015, Mike Kravetz wrote:

> Hugh Dickins pointed out problems with the new hugetlbfs fallocate
> hole punch code.  These problems are in the routine remove_inode_hugepages
> and mostly occur in the case where there are holes in the range of
> pages to be removed.  These holes could be the result of a previous hole
> punch or simply sparse allocation.  The current code could access pages
> outside the specified range.
> 
> remove_inode_hugepages handles both hole punch and truncate operations.
> Page index handling was fixed/cleaned up so that the loop index always
> matches the page being processed.  The code now only makes a single pass
> through the range of pages as it was determined page faults could not
> race with truncate.  A cond_resched() was added after removing up to
> PAGEVEC_SIZE pages.
> 
> Some totally unnecessary code in hugetlbfs_fallocate() that remained from
> early development was also removed.
> 
> V3:
>   Add more descriptive comments and minor improvements as suggested by
>   Naoya Horiguchi
> v2:
>   Make remove_inode_hugepages simpler after verifying truncate can not
>   race with page faults here.
> 
> Tested with fallocate tests submitted here:
> http://librelist.com/browser//libhugetlbfs/2015/6/25/patch-tests-add-tests-for-fallocate-system-call/
> And, some ftruncate tests under development
> 
> Fixes: b5cec28d36f5 ("hugetlbfs: truncate_hugepages() takes a range of pages")
> Cc: stable@vger.kernel.org [4.3]
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>

Acked-by: Hugh Dickins <hughd@google.com>

> ---
>  fs/hugetlbfs/inode.c | 65 ++++++++++++++++++++++++++--------------------------
>  1 file changed, 32 insertions(+), 33 deletions(-)
> 
> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
> index 316adb9..de4bdfa 100644
> --- a/fs/hugetlbfs/inode.c
> +++ b/fs/hugetlbfs/inode.c
> @@ -332,12 +332,17 @@ static void remove_huge_page(struct page *page)
>   * truncation is indicated by end of range being LLONG_MAX
>   *	In this case, we first scan the range and release found pages.
>   *	After releasing pages, hugetlb_unreserve_pages cleans up region/reserv
> - *	maps and global counts.
> + *	maps and global counts.  Page faults can not race with truncation
> + *	in this routine.  hugetlb_no_page() prevents page faults in the
> + *	truncated range.  It checks i_size before allocation, and again after
> + *	with the page table lock for the page held.  The same lock must be
> + *	acquired to unmap a page.
>   * hole punch is indicated if end is not LLONG_MAX
>   *	In the hole punch case we scan the range and release found pages.
>   *	Only when releasing a page is the associated region/reserv map
>   *	deleted.  The region/reserv map for ranges without associated
> - *	pages are not modified.
> + *	pages are not modified.  Page faults can race with hole punch.
> + *	This is indicated if we find a mapped page.
>   * Note: If the passed end of range value is beyond the end of file, but
>   * not LLONG_MAX this routine still performs a hole punch operation.
>   */
> @@ -361,46 +366,37 @@ static void remove_inode_hugepages(struct inode *inode, loff_t lstart,
>  	next = start;
>  	while (next < end) {
>  		/*
> -		 * Make sure to never grab more pages that we
> -		 * might possibly need.
> +		 * Don't grab more pages than the number left in the range.
>  		 */
>  		if (end - next < lookup_nr)
>  			lookup_nr = end - next;
>  
>  		/*
> -		 * This pagevec_lookup() may return pages past 'end',
> -		 * so we must check for page->index > end.
> +		 * When no more pages are found, we are done.
>  		 */
> -		if (!pagevec_lookup(&pvec, mapping, next, lookup_nr)) {
> -			if (next == start)
> -				break;
> -			next = start;
> -			continue;
> -		}
> +		if (!pagevec_lookup(&pvec, mapping, next, lookup_nr))
> +			break;
>  
>  		for (i = 0; i < pagevec_count(&pvec); ++i) {
>  			struct page *page = pvec.pages[i];
>  			u32 hash;
>  
> +			/*
> +			 * The page (index) could be beyond end.  This is
> +			 * only possible in the punch hole case as end is
> +			 * max page offset in the truncate case.
> +			 */
> +			next = page->index;
> +			if (next >= end)
> +				break;
> +
>  			hash = hugetlb_fault_mutex_hash(h, current->mm,
>  							&pseudo_vma,
>  							mapping, next, 0);
>  			mutex_lock(&hugetlb_fault_mutex_table[hash]);
>  
>  			lock_page(page);
> -			if (page->index >= end) {
> -				unlock_page(page);
> -				mutex_unlock(&hugetlb_fault_mutex_table[hash]);
> -				next = end;	/* we are done */
> -				break;
> -			}
> -
> -			/*
> -			 * If page is mapped, it was faulted in after being
> -			 * unmapped.  Do nothing in this race case.  In the
> -			 * normal case page is not mapped.
> -			 */
> -			if (!page_mapped(page)) {
> +			if (likely(!page_mapped(page))) {
>  				bool rsv_on_error = !PagePrivate(page);
>  				/*
>  				 * We must free the huge page and remove
> @@ -421,17 +417,23 @@ static void remove_inode_hugepages(struct inode *inode, loff_t lstart,
>  						hugetlb_fix_reserve_counts(
>  							inode, rsv_on_error);
>  				}
> +			} else {
> +				/*
> +				 * If page is mapped, it was faulted in after
> +				 * being unmapped.  It indicates a race between
> +				 * hole punch and page fault.  Do nothing in
> +				 * this case.  Getting here in a truncate
> +				 * operation is a bug.
> +				 */
> +				BUG_ON(truncate_op);
>  			}
>  
> -			if (page->index > next)
> -				next = page->index;
> -
> -			++next;
>  			unlock_page(page);
> -
>  			mutex_unlock(&hugetlb_fault_mutex_table[hash]);
>  		}
> +		++next;
>  		huge_pagevec_release(&pvec);
> +		cond_resched();
>  	}
>  
>  	if (truncate_op)
> @@ -647,9 +649,6 @@ static long hugetlbfs_fallocate(struct file *file, int mode, loff_t offset,
>  	if (!(mode & FALLOC_FL_KEEP_SIZE) && offset + len > inode->i_size)
>  		i_size_write(inode, offset + len);
>  	inode->i_ctime = CURRENT_TIME;
> -	spin_lock(&inode->i_lock);
> -	inode->i_private = NULL;
> -	spin_unlock(&inode->i_lock);
>  out:
>  	mutex_unlock(&inode->i_mutex);
>  	return error;
> -- 
> 2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
