Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 433296B0278
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 04:18:20 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id w84so9706991wmg.1
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 01:18:20 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id t11si623721wmf.23.2016.09.23.01.18.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Sep 2016 01:18:19 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id l132so1481493wmf.1
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 01:18:19 -0700 (PDT)
Date: Fri, 23 Sep 2016 10:18:17 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC] remove unnecessary condition in remove_inode_hugepages
Message-ID: <20160923081817.GC4478@dhcp22.suse.cz>
References: <57E48B30.2000303@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57E48B30.2000303@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, Hugh Dickins <hughd@google.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

[CC Naoya]

On Fri 23-09-16 09:53:52, zhong jiang wrote:
> 
> At present, we need to call hugetlb_fix_reserve_count when hugetlb_unrserve_pages fails,
> and PagePrivate will decide hugetlb reserves counts.
> 
> we obtain the page from page cache. and use page both lock_page and mutex_lock.
> alloc_huge_page add page to page chace always hold lock page, then bail out clearpageprivate
> before unlock page. 
> 
> but I' m not sure  it is right  or I miss the points.
> 
> 
> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
> index 4ea71eb..010723b 100644
> --- a/fs/hugetlbfs/inode.c
> +++ b/fs/hugetlbfs/inode.c
> @@ -462,14 +462,12 @@ static void remove_inode_hugepages(struct inode *inode, loff_t lstart,
>                          * the page, note PagePrivate which is used in case
>                          * of error.
>                          */
> -                       rsv_on_error = !PagePrivate(page);
>                         remove_huge_page(page);
>                         freed++;
>                         if (!truncate_op) {
>                                 if (unlikely(hugetlb_unreserve_pages(inode,
>                                                         next, next + 1, 1)))
> -                                       hugetlb_fix_reserve_counts(inode,
> -                                                               rsv_on_error);
> +                                       hugetlb_fix_reserve_counts(inode)
>                         }
> 
>                         unlock_page(page);
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
>                                 struct vm_area_struct *vma,
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
>         struct hugepage_subpool *spool = subpool_inode(inode);
>         long rsv_adjust;
> 
>         rsv_adjust = hugepage_subpool_get_pages(spool, 1);
> -       if (restore_reserve && rsv_adjust) {
> +       if (rsv_adjust) {
>                 struct hstate *h = hstate_inode(inode);
> 
>                 hugetlb_acct_memory(h, 1);
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
