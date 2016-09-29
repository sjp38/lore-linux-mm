Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0D43E28024D
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 04:27:45 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id l138so66178808wmg.3
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 01:27:45 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id 125si24883341wmz.124.2016.09.29.01.27.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Sep 2016 01:27:43 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id b4so9546893wmb.2
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 01:27:43 -0700 (PDT)
Date: Thu, 29 Sep 2016 10:27:42 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3] mm: remove unnecessary condition in
 remove_inode_hugepages
Message-ID: <20160929082741.GC408@dhcp22.suse.cz>
References: <1475113323-29368-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1475113323-29368-1-git-send-email-zhongjiang@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhongjiang <zhongjiang@huawei.com>
Cc: akpm@linux-foundation.org, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com, linux-mm@kvack.org

On Thu 29-09-16 09:42:03, zhongjiang wrote:
> From: zhong jiang <zhongjiang@huawei.com>
> 
> when the huge page is added to the page cahce (huge_add_to_page_cache),
> the page private flag will be cleared. since this code
> (remove_inode_hugepages) will only be called for pages in the
> page cahce, PagePrivate(page) will always be false.
> 
> The patch remove the code without any functional change.
> 
> Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>
> Tested-by: Mike Kravetz <mike.kravetz@oracle.com>
> Signed-off-by: zhong jiang <zhongjiang@huawei.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  fs/hugetlbfs/inode.c    | 12 +++++-------
>  include/linux/hugetlb.h |  2 +-
>  mm/hugetlb.c            |  4 ++--
>  3 files changed, 8 insertions(+), 10 deletions(-)
> 
> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
> index 4ea71eb..7337cac 100644
> --- a/fs/hugetlbfs/inode.c
> +++ b/fs/hugetlbfs/inode.c
> @@ -416,7 +416,6 @@ static void remove_inode_hugepages(struct inode *inode, loff_t lstart,
>  
>  		for (i = 0; i < pagevec_count(&pvec); ++i) {
>  			struct page *page = pvec.pages[i];
> -			bool rsv_on_error;
>  			u32 hash;
>  
>  			/*
> @@ -458,18 +457,17 @@ static void remove_inode_hugepages(struct inode *inode, loff_t lstart,
>  			 * cache (remove_huge_page) BEFORE removing the
>  			 * region/reserve map (hugetlb_unreserve_pages).  In
>  			 * rare out of memory conditions, removal of the
> -			 * region/reserve map could fail.  Before free'ing
> -			 * the page, note PagePrivate which is used in case
> -			 * of error.
> +			 * region/reserve map could fail. Correspondingly,
> +			 * the subpool and global reserve usage count can need
> +			 * to be adjusted.
>  			 */
> -			rsv_on_error = !PagePrivate(page);
> +			VM_BUG_ON(PagePrivate(page));
>  			remove_huge_page(page);
>  			freed++;
>  			if (!truncate_op) {
>  				if (unlikely(hugetlb_unreserve_pages(inode,
>  							next, next + 1, 1)))
> -					hugetlb_fix_reserve_counts(inode,
> -								rsv_on_error);
> +					hugetlb_fix_reserve_counts(inode);
>  			}
>  
>  			unlock_page(page);
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index c26d463..d2e0fc5 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -90,7 +90,7 @@ int dequeue_hwpoisoned_huge_page(struct page *page);
>  bool isolate_huge_page(struct page *page, struct list_head *list);
>  void putback_active_hugepage(struct page *page);
>  void free_huge_page(struct page *page);
> -void hugetlb_fix_reserve_counts(struct inode *inode, bool restore_reserve);
> +void hugetlb_fix_reserve_counts(struct inode *inode);
>  extern struct mutex *hugetlb_fault_mutex_table;
>  u32 hugetlb_fault_mutex_hash(struct hstate *h, struct mm_struct *mm,
>  				struct vm_area_struct *vma,
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 87e11d8..28a079a 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -567,13 +567,13 @@ retry:
>   * appear as a "reserved" entry instead of simply dangling with incorrect
>   * counts.
>   */
> -void hugetlb_fix_reserve_counts(struct inode *inode, bool restore_reserve)
> +void hugetlb_fix_reserve_counts(struct inode *inode)
>  {
>  	struct hugepage_subpool *spool = subpool_inode(inode);
>  	long rsv_adjust;
>  
>  	rsv_adjust = hugepage_subpool_get_pages(spool, 1);
> -	if (restore_reserve && rsv_adjust) {
> +	if (rsv_adjust) {
>  		struct hstate *h = hstate_inode(inode);
>  
>  		hugetlb_acct_memory(h, 1);
> -- 
> 1.8.3.1

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
