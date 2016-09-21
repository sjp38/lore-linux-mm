Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id D600B28024C
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 09:17:51 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id y6so10670758lff.0
        for <linux-mm@kvack.org>; Wed, 21 Sep 2016 06:17:51 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id g83si31124449wme.77.2016.09.21.06.17.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Sep 2016 06:17:47 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8LDCqf0020681
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 09:17:46 -0400
Received: from e36.co.us.ibm.com (e36.co.us.ibm.com [32.97.110.154])
	by mx0a-001b2d01.pphosted.com with ESMTP id 25kkqb2w3c-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 09:17:45 -0400
Received: from localhost
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rui.teng@linux.vnet.ibm.com>;
	Wed, 21 Sep 2016 07:17:44 -0600
Subject: Re: [PATCH v2 1/1] mm/hugetlb: fix memory offline with hugepage size
 > memory block size
References: <20160920155354.54403-1-gerald.schaefer@de.ibm.com>
 <20160920155354.54403-2-gerald.schaefer@de.ibm.com>
 <05d701d213d1$7fb70880$7f251980$@alibaba-inc.com>
 <20160921143534.0dd95fe7@thinkpad>
From: Rui Teng <rui.teng@linux.vnet.ibm.com>
Date: Wed, 21 Sep 2016 21:17:29 +0800
MIME-Version: 1.0
In-Reply-To: <20160921143534.0dd95fe7@thinkpad>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Message-Id: <f3b4221f-8f23-23ce-6bf5-052df7274470@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gerald Schaefer <gerald.schaefer@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Dave Hansen <dave.hansen@linux.intel.com>

On 9/21/16 8:35 PM, Gerald Schaefer wrote:
> dissolve_free_huge_pages() will either run into the VM_BUG_ON() or a
> list corruption and addressing exception when trying to set a memory
> block offline that is part (but not the first part) of a hugetlb page
> with a size > memory block size.
>
> When no other smaller hugetlb page sizes are present, the VM_BUG_ON()
> will trigger directly. In the other case we will run into an addressing
> exception later, because dissolve_free_huge_page() will not work on the
> head page of the compound hugetlb page which will result in a NULL
> hstate from page_hstate().
>
> To fix this, first remove the VM_BUG_ON() because it is wrong, and then
> use the compound head page in dissolve_free_huge_page().
>
> Also change locking in dissolve_free_huge_page(), so that it only takes
> the lock when actually removing a hugepage.
>
> Signed-off-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
> ---
> Changes in v2:
> - Update comment in dissolve_free_huge_pages()
> - Change locking in dissolve_free_huge_page()
>
>  mm/hugetlb.c | 31 +++++++++++++++++++------------
>  1 file changed, 19 insertions(+), 12 deletions(-)
>
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 87e11d8..1522af8 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1441,23 +1441,30 @@ static int free_pool_huge_page(struct hstate *h, nodemask_t *nodes_allowed,
>   */
>  static void dissolve_free_huge_page(struct page *page)
>  {
> +	struct page *head = compound_head(page);
> +	struct hstate *h;
> +	int nid;
> +
> +	if (page_count(head))
> +		return;
> +
> +	h = page_hstate(head);
> +	nid = page_to_nid(head);
> +
>  	spin_lock(&hugetlb_lock);
> -	if (PageHuge(page) && !page_count(page)) {
> -		struct hstate *h = page_hstate(page);
> -		int nid = page_to_nid(page);
> -		list_del(&page->lru);
> -		h->free_huge_pages--;
> -		h->free_huge_pages_node[nid]--;
> -		h->max_huge_pages--;
> -		update_and_free_page(h, page);
> -	}
> +	list_del(&head->lru);
> +	h->free_huge_pages--;
> +	h->free_huge_pages_node[nid]--;
> +	h->max_huge_pages--;
> +	update_and_free_page(h, head);
>  	spin_unlock(&hugetlb_lock);
>  }
>
>  /*
>   * Dissolve free hugepages in a given pfn range. Used by memory hotplug to
>   * make specified memory blocks removable from the system.
> - * Note that start_pfn should aligned with (minimum) hugepage size.
> + * Note that this will dissolve a free gigantic hugepage completely, if any
> + * part of it lies within the given range.
>   */
>  void dissolve_free_huge_pages(unsigned long start_pfn, unsigned long end_pfn)
>  {
> @@ -1466,9 +1473,9 @@ void dissolve_free_huge_pages(unsigned long start_pfn, unsigned long end_pfn)
>  	if (!hugepages_supported())
>  		return;
>
> -	VM_BUG_ON(!IS_ALIGNED(start_pfn, 1 << minimum_order));
>  	for (pfn = start_pfn; pfn < end_pfn; pfn += 1 << minimum_order)
> -		dissolve_free_huge_page(pfn_to_page(pfn));
> +		if (PageHuge(pfn_to_page(pfn)))
> +			dissolve_free_huge_page(pfn_to_page(pfn));
How many times will dissolve_free_huge_page() be invoked in this loop?
For each pfn, it will be converted to the head page, and then the list
will be deleted repeatedly.
>  }
>
>  /*
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
