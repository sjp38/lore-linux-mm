Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3B13F280250
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 05:51:42 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id w84so65231658wmg.1
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 02:51:42 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id j23si21738880wmj.17.2016.09.22.02.51.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Sep 2016 02:51:39 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id 133so13064977wmq.2
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 02:51:39 -0700 (PDT)
Date: Thu, 22 Sep 2016 11:51:37 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 1/1] mm/hugetlb: fix memory offline with hugepage size
 > memory block size
Message-ID: <20160922095137.GC11875@dhcp22.suse.cz>
References: <20160920155354.54403-1-gerald.schaefer@de.ibm.com>
 <20160920155354.54403-2-gerald.schaefer@de.ibm.com>
 <05d701d213d1$7fb70880$7f251980$@alibaba-inc.com>
 <20160921143534.0dd95fe7@thinkpad>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160921143534.0dd95fe7@thinkpad>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Dave Hansen <dave.hansen@linux.intel.com>, Rui Teng <rui.teng@linux.vnet.ibm.com>

On Wed 21-09-16 14:35:34, Gerald Schaefer wrote:
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

OK so dissolve_free_huge_page will work also on tail pages now which
makes some sense. I would appreciate also few words why do we want to
sacrifice something as precious as gigantic page rather than fail the
page block offline. Dave pointed out dim offline usecase for example.

> Also change locking in dissolve_free_huge_page(), so that it only takes
> the lock when actually removing a hugepage.

>From a quick look it seems this has been broken since introduced by
c8721bbbdd36 ("mm: memory-hotplug: enable memory hotplug to handle
hugepage"). Do we want to have this backported to stable? In any way
Fixes: SHA1 would be really nice.

> Signed-off-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>

Other than that looks good to me, although there is a room for
improvements here. See below

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
>  }

we can return the number of freed pages from dissolve_free_huge_page and
move by the approapriate number of pfns. Nothing to really lose sleep
about but no rocket science either. An early break out if the page is
used would be nice as well. Something like the following, probably a
separate patch on top of yours.
---
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 029a80b90cea..d230900f571e 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1434,17 +1434,17 @@ static int free_pool_huge_page(struct hstate *h, nodemask_t *nodes_allowed,
 }
 
 /*
- * Dissolve a given free hugepage into free buddy pages. This function does
- * nothing for in-use (including surplus) hugepages.
+ * Dissolve a given free hugepage into free buddy pages. Returns number
+ * of freed pages or EBUSY if the page is in use.
  */
-static void dissolve_free_huge_page(struct page *page)
+static int dissolve_free_huge_page(struct page *page)
 {
 	struct page *head = compound_head(page);
 	struct hstate *h;
 	int nid;
 
 	if (page_count(head))
-		return;
+		return -EBUSY;
 
 	h = page_hstate(head);
 	nid = page_to_nid(head);
@@ -1456,6 +1456,8 @@ static void dissolve_free_huge_page(struct page *page)
 	h->max_huge_pages--;
 	update_and_free_page(h, head);
 	spin_unlock(&hugetlb_lock);
+
+	return 1 << h->order;
 }
 
 /*
@@ -1471,9 +1473,18 @@ void dissolve_free_huge_pages(unsigned long start_pfn, unsigned long end_pfn)
 	if (!hugepages_supported())
 		return;
 
-	for (pfn = start_pfn; pfn < end_pfn; pfn += 1 << minimum_order)
-		if (PageHuge(pfn_to_page(pfn)))
-			dissolve_free_huge_page(pfn_to_page(pfn));
+	for (pfn = start_pfn; pfn < end_pfn; )
+		int nr_pages;
+
+		if (!PageHuge(pfn_to_page(pfn))) {
+			pfn += 1 << minimum_order;
+			continue;
+		}
+
+		nr_pages = dissolve_free_huge_page(pfn_to_page(pfn));
+		if (IS_ERR(nr_pages))
+			break;
+		pfn += nr_pages;
 }
 
 /*
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
