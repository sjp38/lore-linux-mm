Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8AD776B0038
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 08:30:04 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id b130so72006023wmc.2
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 05:30:04 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id j143si25825503wmf.117.2016.09.29.05.30.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Sep 2016 05:30:03 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id b184so10493211wma.3
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 05:30:02 -0700 (PDT)
Date: Thu, 29 Sep 2016 14:30:01 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v4 2/3] mm/hugetlb: check for reserved hugepages during
 memory offline
Message-ID: <20160929123001.GG408@dhcp22.suse.cz>
References: <20160926172811.94033-1-gerald.schaefer@de.ibm.com>
 <20160926172811.94033-3-gerald.schaefer@de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160926172811.94033-3-gerald.schaefer@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Rui Teng <rui.teng@linux.vnet.ibm.com>, Dave Hansen <dave.hansen@linux.intel.com>

On Mon 26-09-16 19:28:10, Gerald Schaefer wrote:
> In dissolve_free_huge_pages(), free hugepages will be dissolved without
> making sure that there are enough of them left to satisfy hugepage
> reservations.

otherwise a poor process with a reservation might get unexpected SIGBUS,
right?

> Fix this by adding a return value to dissolve_free_huge_pages() and
> checking h->free_huge_pages vs. h->resv_huge_pages. Note that this may
> lead to the situation where dissolve_free_huge_page() returns an error
> and all free hugepages that were dissolved before that error are lost,
> while the memory block still cannot be set offline.

Hmm, OK offline failure is certainly a better option than an application
failure.
 
> Fixes: c8721bbb ("mm: memory-hotplug: enable memory hotplug to handle hugepage")
> Signed-off-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>

Acked-by: Michal Hocko <mhocko@suse.com>
> ---
>  include/linux/hugetlb.h |  6 +++---
>  mm/hugetlb.c            | 26 +++++++++++++++++++++-----
>  mm/memory_hotplug.c     |  4 +++-
>  3 files changed, 27 insertions(+), 9 deletions(-)
> 
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index c26d463..fe99e6f 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -450,8 +450,8 @@ static inline pgoff_t basepage_index(struct page *page)
>  	return __basepage_index(page);
>  }
>  
> -extern void dissolve_free_huge_pages(unsigned long start_pfn,
> -				     unsigned long end_pfn);
> +extern int dissolve_free_huge_pages(unsigned long start_pfn,
> +				    unsigned long end_pfn);
>  static inline bool hugepage_migration_supported(struct hstate *h)
>  {
>  #ifdef CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION
> @@ -518,7 +518,7 @@ static inline pgoff_t basepage_index(struct page *page)
>  {
>  	return page->index;
>  }
> -#define dissolve_free_huge_pages(s, e)	do {} while (0)
> +#define dissolve_free_huge_pages(s, e)	0
>  #define hugepage_migration_supported(h)	false
>  
>  static inline spinlock_t *huge_pte_lockptr(struct hstate *h,
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 603bdd0..91ae1f5 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1437,22 +1437,32 @@ static int free_pool_huge_page(struct hstate *h, nodemask_t *nodes_allowed,
>  
>  /*
>   * Dissolve a given free hugepage into free buddy pages. This function does
> - * nothing for in-use (including surplus) hugepages.
> + * nothing for in-use (including surplus) hugepages. Returns -EBUSY if the
> + * number of free hugepages would be reduced below the number of reserved
> + * hugepages.
>   */
> -static void dissolve_free_huge_page(struct page *page)
> +static int dissolve_free_huge_page(struct page *page)
>  {
> +	int rc = 0;
> +
>  	spin_lock(&hugetlb_lock);
>  	if (PageHuge(page) && !page_count(page)) {
>  		struct page *head = compound_head(page);
>  		struct hstate *h = page_hstate(head);
>  		int nid = page_to_nid(head);
> +		if (h->free_huge_pages - h->resv_huge_pages == 0) {
> +			rc = -EBUSY;
> +			goto out;
> +		}
>  		list_del(&head->lru);
>  		h->free_huge_pages--;
>  		h->free_huge_pages_node[nid]--;
>  		h->max_huge_pages--;
>  		update_and_free_page(h, head);
>  	}
> +out:
>  	spin_unlock(&hugetlb_lock);
> +	return rc;
>  }
>  
>  /*
> @@ -1460,16 +1470,22 @@ static void dissolve_free_huge_page(struct page *page)
>   * make specified memory blocks removable from the system.
>   * Note that this will dissolve a free gigantic hugepage completely, if any
>   * part of it lies within the given range.
> + * Also note that if dissolve_free_huge_page() returns with an error, all
> + * free hugepages that were dissolved before that error are lost.
>   */
> -void dissolve_free_huge_pages(unsigned long start_pfn, unsigned long end_pfn)
> +int dissolve_free_huge_pages(unsigned long start_pfn, unsigned long end_pfn)
>  {
>  	unsigned long pfn;
> +	int rc = 0;
>  
>  	if (!hugepages_supported())
> -		return;
> +		return rc;
>  
>  	for (pfn = start_pfn; pfn < end_pfn; pfn += 1 << minimum_order)
> -		dissolve_free_huge_page(pfn_to_page(pfn));
> +		if (rc = dissolve_free_huge_page(pfn_to_page(pfn)))
> +			break;
> +
> +	return rc;
>  }
>  
>  /*
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index b58906b..13998d9 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1945,7 +1945,9 @@ static int __ref __offline_pages(unsigned long start_pfn,
>  	 * dissolve free hugepages in the memory block before doing offlining
>  	 * actually in order to make hugetlbfs's object counting consistent.
>  	 */
> -	dissolve_free_huge_pages(start_pfn, end_pfn);
> +	ret = dissolve_free_huge_pages(start_pfn, end_pfn);
> +	if (ret)
> +		goto failed_removal;
>  	/* check again */
>  	offlined_pages = check_pages_isolated(start_pfn, end_pfn);
>  	if (offlined_pages < 0) {
> -- 
> 2.8.4

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
