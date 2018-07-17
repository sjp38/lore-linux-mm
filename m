Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 449656B0270
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 10:27:46 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id l1-v6so652298edi.11
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 07:27:46 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g25-v6si945662edf.328.2018.07.17.07.27.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jul 2018 07:27:44 -0700 (PDT)
Date: Tue, 17 Jul 2018 16:27:43 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 1/2] mm: fix race on soft-offlining free huge pages
Message-ID: <20180717142743.GJ7193@dhcp22.suse.cz>
References: <1531805552-19547-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1531805552-19547-2-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1531805552-19547-2-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, xishi.qiuxishi@alibaba-inc.com, zy.zhengyi@alibaba-inc.com, linux-kernel@vger.kernel.org

On Tue 17-07-18 14:32:31, Naoya Horiguchi wrote:
> There's a race condition between soft offline and hugetlb_fault which
> causes unexpected process killing and/or hugetlb allocation failure.
> 
> The process killing is caused by the following flow:
> 
>   CPU 0               CPU 1              CPU 2
> 
>   soft offline
>     get_any_page
>     // find the hugetlb is free
>                       mmap a hugetlb file
>                       page fault
>                         ...
>                           hugetlb_fault
>                             hugetlb_no_page
>                               alloc_huge_page
>                               // succeed
>       soft_offline_free_page
>       // set hwpoison flag
>                                          mmap the hugetlb file
>                                          page fault
>                                            ...
>                                              hugetlb_fault
>                                                hugetlb_no_page
>                                                  find_lock_page
>                                                    return VM_FAULT_HWPOISON
>                                            mm_fault_error
>                                              do_sigbus
>                                              // kill the process
> 
> 
> The hugetlb allocation failure comes from the following flow:
> 
>   CPU 0                          CPU 1
> 
>                                  mmap a hugetlb file
>                                  // reserve all free page but don't fault-in
>   soft offline
>     get_any_page
>     // find the hugetlb is free
>       soft_offline_free_page
>       // set hwpoison flag
>         dissolve_free_huge_page
>         // fail because all free hugepages are reserved
>                                  page fault
>                                    ...
>                                      hugetlb_fault
>                                        hugetlb_no_page
>                                          alloc_huge_page
>                                            ...
>                                              dequeue_huge_page_node_exact
>                                              // ignore hwpoisoned hugepage
>                                              // and finally fail due to no-mem
> 
> The root cause of this is that current soft-offline code is written
> based on an assumption that PageHWPoison flag should beset at first to
> avoid accessing the corrupted data.  This makes sense for memory_failure()
> or hard offline, but does not for soft offline because soft offline is
> about corrected (not uncorrected) error and is safe from data lost.
> This patch changes soft offline semantics where it sets PageHWPoison flag
> only after containment of the error page completes successfully.

Could you please expand on the worklow here please? The code is really
hard to grasp. I must be missing something because the thing shouldn't
be really complicated. Either the page is in the free pool and you just
remove it from the allocator (with hugetlb asking for a new hugeltb page
to guaratee reserves) or it is used and you just migrate the content to
a new page (again with the hugetlb reserves consideration). Why should
PageHWPoison flag ordering make any relevance?

Do I get it right that the only difference between the hard and soft
offlining is that hugetlb reserves might break for the former while not
for the latter and that the failed migration kills all owners for the
former while not for latter?
 
> Reported-by: Xishi Qiu <xishi.qiuxishi@alibaba-inc.com>
> Suggested-by: Xishi Qiu <xishi.qiuxishi@alibaba-inc.com>
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
> changelog v1->v2:
> - don't use set_hwpoison_free_buddy_page() (not defined yet)
> - updated comment in soft_offline_huge_page()
> ---
>  mm/hugetlb.c        | 11 +++++------
>  mm/memory-failure.c | 24 ++++++++++++++++++------
>  mm/migrate.c        |  2 --
>  3 files changed, 23 insertions(+), 14 deletions(-)
> 
> diff --git v4.18-rc4-mmotm-2018-07-10-16-50/mm/hugetlb.c v4.18-rc4-mmotm-2018-07-10-16-50_patched/mm/hugetlb.c
> index 430be42..937c142 100644
> --- v4.18-rc4-mmotm-2018-07-10-16-50/mm/hugetlb.c
> +++ v4.18-rc4-mmotm-2018-07-10-16-50_patched/mm/hugetlb.c
> @@ -1479,22 +1479,20 @@ static int free_pool_huge_page(struct hstate *h, nodemask_t *nodes_allowed,
>  /*
>   * Dissolve a given free hugepage into free buddy pages. This function does
>   * nothing for in-use (including surplus) hugepages. Returns -EBUSY if the
> - * number of free hugepages would be reduced below the number of reserved
> - * hugepages.
> + * dissolution fails because a give page is not a free hugepage, or because
> + * free hugepages are fully reserved.
>   */
>  int dissolve_free_huge_page(struct page *page)
>  {
> -	int rc = 0;
> +	int rc = -EBUSY;
>  
>  	spin_lock(&hugetlb_lock);
>  	if (PageHuge(page) && !page_count(page)) {
>  		struct page *head = compound_head(page);
>  		struct hstate *h = page_hstate(head);
>  		int nid = page_to_nid(head);
> -		if (h->free_huge_pages - h->resv_huge_pages == 0) {
> -			rc = -EBUSY;
> +		if (h->free_huge_pages - h->resv_huge_pages == 0)
>  			goto out;
> -		}
>  		/*
>  		 * Move PageHWPoison flag from head page to the raw error page,
>  		 * which makes any subpages rather than the error page reusable.
> @@ -1508,6 +1506,7 @@ int dissolve_free_huge_page(struct page *page)
>  		h->free_huge_pages_node[nid]--;
>  		h->max_huge_pages--;
>  		update_and_free_page(h, head);
> +		rc = 0;
>  	}
>  out:
>  	spin_unlock(&hugetlb_lock);
> diff --git v4.18-rc4-mmotm-2018-07-10-16-50/mm/memory-failure.c v4.18-rc4-mmotm-2018-07-10-16-50_patched/mm/memory-failure.c
> index 9d142b9..9b77f85 100644
> --- v4.18-rc4-mmotm-2018-07-10-16-50/mm/memory-failure.c
> +++ v4.18-rc4-mmotm-2018-07-10-16-50_patched/mm/memory-failure.c
> @@ -1598,8 +1598,20 @@ static int soft_offline_huge_page(struct page *page, int flags)
>  		if (ret > 0)
>  			ret = -EIO;
>  	} else {
> -		if (PageHuge(page))
> -			dissolve_free_huge_page(page);
> +		/*
> +		 * We set PG_hwpoison only when the migration source hugepage
> +		 * was successfully dissolved, because otherwise hwpoisoned
> +		 * hugepage remains on free hugepage list. The allocator ignores
> +		 * such a hwpoisoned page so it's never allocated, but it could
> +		 * kill a process because of no-memory rather than hwpoison.
> +		 * Soft-offline never impacts the userspace, so this is
> +		 * undesired.
> +		 */
> +		ret = dissolve_free_huge_page(page);
> +		if (!ret) {
> +			if (!TestSetPageHWPoison(page))
> +				num_poisoned_pages_inc();
> +		}
>  	}
>  	return ret;
>  }
> @@ -1715,13 +1727,13 @@ static int soft_offline_in_use_page(struct page *page, int flags)
>  
>  static void soft_offline_free_page(struct page *page)
>  {
> +	int rc = 0;
>  	struct page *head = compound_head(page);
>  
> -	if (!TestSetPageHWPoison(head)) {
> +	if (PageHuge(head))
> +		rc = dissolve_free_huge_page(page);
> +	if (!rc && !TestSetPageHWPoison(page))
>  		num_poisoned_pages_inc();
> -		if (PageHuge(head))
> -			dissolve_free_huge_page(page);
> -	}
>  }
>  
>  /**
> diff --git v4.18-rc4-mmotm-2018-07-10-16-50/mm/migrate.c v4.18-rc4-mmotm-2018-07-10-16-50_patched/mm/migrate.c
> index 198af42..3ae213b 100644
> --- v4.18-rc4-mmotm-2018-07-10-16-50/mm/migrate.c
> +++ v4.18-rc4-mmotm-2018-07-10-16-50_patched/mm/migrate.c
> @@ -1318,8 +1318,6 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
>  out:
>  	if (rc != -EAGAIN)
>  		putback_active_hugepage(hpage);
> -	if (reason == MR_MEMORY_FAILURE && !test_set_page_hwpoison(hpage))
> -		num_poisoned_pages_inc();
>  
>  	/*
>  	 * If migration was not successful and there's a freeing callback, use
> -- 
> 2.7.0

-- 
Michal Hocko
SUSE Labs
