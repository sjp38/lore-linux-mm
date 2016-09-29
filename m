Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9384F6B0038
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 08:11:07 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b130so71480520wmc.2
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 05:11:07 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id xv2si14356240wjc.175.2016.09.29.05.11.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Sep 2016 05:11:06 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id b4so10452400wmb.2
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 05:11:06 -0700 (PDT)
Date: Thu, 29 Sep 2016 14:11:04 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v4 1/3] mm/hugetlb: fix memory offline with hugepage size
 > memory block size
Message-ID: <20160929121104.GF408@dhcp22.suse.cz>
References: <20160926172811.94033-1-gerald.schaefer@de.ibm.com>
 <20160926172811.94033-2-gerald.schaefer@de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160926172811.94033-2-gerald.schaefer@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Rui Teng <rui.teng@linux.vnet.ibm.com>, Dave Hansen <dave.hansen@linux.intel.com>

On Mon 26-09-16 19:28:09, Gerald Schaefer wrote:
> dissolve_free_huge_pages() will either run into the VM_BUG_ON() or a
> list corruption and addressing exception when trying to set a memory
> block offline that is part (but not the first part) of a "gigantic"
> hugetlb page with a size > memory block size.
> 
> When no other smaller hugetlb page sizes are present, the VM_BUG_ON()
> will trigger directly. In the other case we will run into an addressing
> exception later, because dissolve_free_huge_page() will not work on the
> head page of the compound hugetlb page which will result in a NULL
> hstate from page_hstate().
> 
> To fix this, first remove the VM_BUG_ON() because it is wrong, and then
> use the compound head page in dissolve_free_huge_page(). This means that
> an unused pre-allocated gigantic page that has any part of itself inside
> the memory block that is going offline will be dissolved completely.
> Losing an unused gigantic hugepage is preferable to failing the memory
> offline, for example in the situation where a (possibly faulty) memory
> DIMM needs to go offline.
> 
> Fixes: c8721bbb ("mm: memory-hotplug: enable memory hotplug to handle hugepage")
> Cc: <stable@vger.kernel.org>
> Signed-off-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/hugetlb.c | 13 +++++++------
>  1 file changed, 7 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 87e11d8..603bdd0 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1443,13 +1443,14 @@ static void dissolve_free_huge_page(struct page *page)
>  {
>  	spin_lock(&hugetlb_lock);
>  	if (PageHuge(page) && !page_count(page)) {
> -		struct hstate *h = page_hstate(page);
> -		int nid = page_to_nid(page);
> -		list_del(&page->lru);
> +		struct page *head = compound_head(page);
> +		struct hstate *h = page_hstate(head);
> +		int nid = page_to_nid(head);
> +		list_del(&head->lru);
>  		h->free_huge_pages--;
>  		h->free_huge_pages_node[nid]--;
>  		h->max_huge_pages--;
> -		update_and_free_page(h, page);
> +		update_and_free_page(h, head);
>  	}
>  	spin_unlock(&hugetlb_lock);
>  }
> @@ -1457,7 +1458,8 @@ static void dissolve_free_huge_page(struct page *page)
>  /*
>   * Dissolve free hugepages in a given pfn range. Used by memory hotplug to
>   * make specified memory blocks removable from the system.
> - * Note that start_pfn should aligned with (minimum) hugepage size.
> + * Note that this will dissolve a free gigantic hugepage completely, if any
> + * part of it lies within the given range.
>   */
>  void dissolve_free_huge_pages(unsigned long start_pfn, unsigned long end_pfn)
>  {
> @@ -1466,7 +1468,6 @@ void dissolve_free_huge_pages(unsigned long start_pfn, unsigned long end_pfn)
>  	if (!hugepages_supported())
>  		return;
>  
> -	VM_BUG_ON(!IS_ALIGNED(start_pfn, 1 << minimum_order));
>  	for (pfn = start_pfn; pfn < end_pfn; pfn += 1 << minimum_order)
>  		dissolve_free_huge_page(pfn_to_page(pfn));
>  }
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
