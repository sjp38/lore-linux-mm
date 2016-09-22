Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1F49B6B0277
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 09:45:58 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id r126so199130672oib.2
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 06:45:58 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id z204si1615195oiz.263.2016.09.22.06.45.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Sep 2016 06:45:57 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8MDgrA7038440
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 09:45:56 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 25mb2utu2v-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 09:45:56 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Thu, 22 Sep 2016 14:45:53 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 4C2D72190023
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 14:45:12 +0100 (BST)
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u8MDjqAd24969654
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 13:45:52 GMT
Received: from d06av02.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u8MDjpOO019793
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 07:45:52 -0600
Date: Thu, 22 Sep 2016 15:45:49 +0200
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: Re: [PATCH v2 1/1] mm/hugetlb: fix memory offline with hugepage
 size > memory block size
In-Reply-To: <20160922095137.GC11875@dhcp22.suse.cz>
References: <20160920155354.54403-1-gerald.schaefer@de.ibm.com>
	<20160920155354.54403-2-gerald.schaefer@de.ibm.com>
	<05d701d213d1$7fb70880$7f251980$@alibaba-inc.com>
	<20160921143534.0dd95fe7@thinkpad>
	<20160922095137.GC11875@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Message-Id: <20160922154549.483ee313@thinkpad>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Dave Hansen <dave.hansen@linux.intel.com>, Rui Teng <rui.teng@linux.vnet.ibm.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>

On Thu, 22 Sep 2016 11:51:37 +0200
Michal Hocko <mhocko@kernel.org> wrote:

> On Wed 21-09-16 14:35:34, Gerald Schaefer wrote:
> > dissolve_free_huge_pages() will either run into the VM_BUG_ON() or a
> > list corruption and addressing exception when trying to set a memory
> > block offline that is part (but not the first part) of a hugetlb page
> > with a size > memory block size.
> > 
> > When no other smaller hugetlb page sizes are present, the VM_BUG_ON()
> > will trigger directly. In the other case we will run into an addressing
> > exception later, because dissolve_free_huge_page() will not work on the
> > head page of the compound hugetlb page which will result in a NULL
> > hstate from page_hstate().
> > 
> > To fix this, first remove the VM_BUG_ON() because it is wrong, and then
> > use the compound head page in dissolve_free_huge_page().
> 
> OK so dissolve_free_huge_page will work also on tail pages now which
> makes some sense. I would appreciate also few words why do we want to
> sacrifice something as precious as gigantic page rather than fail the
> page block offline. Dave pointed out dim offline usecase for example.
> 
> > Also change locking in dissolve_free_huge_page(), so that it only takes
> > the lock when actually removing a hugepage.
> 
> From a quick look it seems this has been broken since introduced by
> c8721bbbdd36 ("mm: memory-hotplug: enable memory hotplug to handle
> hugepage"). Do we want to have this backported to stable? In any way
> Fixes: SHA1 would be really nice.

That's true, I'll send a v3.

> 
> > Signed-off-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
> 
> Other than that looks good to me, although there is a room for
> improvements here. See below
> 
> > ---
> > Changes in v2:
> > - Update comment in dissolve_free_huge_pages()
> > - Change locking in dissolve_free_huge_page()
> > 
> >  mm/hugetlb.c | 31 +++++++++++++++++++------------
> >  1 file changed, 19 insertions(+), 12 deletions(-)
> > 
> > diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> > index 87e11d8..1522af8 100644
> > --- a/mm/hugetlb.c
> > +++ b/mm/hugetlb.c
> > @@ -1441,23 +1441,30 @@ static int free_pool_huge_page(struct hstate *h, nodemask_t *nodes_allowed,
> >   */
> >  static void dissolve_free_huge_page(struct page *page)
> >  {
> > +	struct page *head = compound_head(page);
> > +	struct hstate *h;
> > +	int nid;
> > +
> > +	if (page_count(head))
> > +		return;
> > +
> > +	h = page_hstate(head);
> > +	nid = page_to_nid(head);
> > +
> >  	spin_lock(&hugetlb_lock);
> > -	if (PageHuge(page) && !page_count(page)) {
> > -		struct hstate *h = page_hstate(page);
> > -		int nid = page_to_nid(page);
> > -		list_del(&page->lru);
> > -		h->free_huge_pages--;
> > -		h->free_huge_pages_node[nid]--;
> > -		h->max_huge_pages--;
> > -		update_and_free_page(h, page);
> > -	}
> > +	list_del(&head->lru);
> > +	h->free_huge_pages--;
> > +	h->free_huge_pages_node[nid]--;
> > +	h->max_huge_pages--;
> > +	update_and_free_page(h, head);
> >  	spin_unlock(&hugetlb_lock);
> >  }
> >  
> >  /*
> >   * Dissolve free hugepages in a given pfn range. Used by memory hotplug to
> >   * make specified memory blocks removable from the system.
> > - * Note that start_pfn should aligned with (minimum) hugepage size.
> > + * Note that this will dissolve a free gigantic hugepage completely, if any
> > + * part of it lies within the given range.
> >   */
> >  void dissolve_free_huge_pages(unsigned long start_pfn, unsigned long end_pfn)
> >  {
> > @@ -1466,9 +1473,9 @@ void dissolve_free_huge_pages(unsigned long start_pfn, unsigned long end_pfn)
> >  	if (!hugepages_supported())
> >  		return;
> >  
> > -	VM_BUG_ON(!IS_ALIGNED(start_pfn, 1 << minimum_order));
> >  	for (pfn = start_pfn; pfn < end_pfn; pfn += 1 << minimum_order)
> > -		dissolve_free_huge_page(pfn_to_page(pfn));
> > +		if (PageHuge(pfn_to_page(pfn)))
> > +			dissolve_free_huge_page(pfn_to_page(pfn));
> >  }
> 
> we can return the number of freed pages from dissolve_free_huge_page and
> move by the approapriate number of pfns. Nothing to really lose sleep
> about but no rocket science either. An early break out if the page is
> used would be nice as well. Something like the following, probably a
> separate patch on top of yours.

Hmm, not sure if this is really worth the effort and the (small) added
complexity. It would surely be worth it for the current code, where we
also have the spinlock involved even for non-huge pages. After this patch
however, dissolve_free_huge_page() will only be called for hugepages,
and the early break-out is also there, although the page_count() check
could probably be moved out from dissolve_free_huge_page() and into the
loop, I'll try this for v3.

The loop count will also not be greatly reduced, at least when there
are only hugepages of minimum_order in the memory block, or no hugepages
at all, it will not improve anything. In any other case the PageHuge()
check in the loop will already prevent unnecessary calls to
dissolve_free_huge_page().

> ---
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 029a80b90cea..d230900f571e 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1434,17 +1434,17 @@ static int free_pool_huge_page(struct hstate *h, nodemask_t *nodes_allowed,
>  }
> 
>  /*
> - * Dissolve a given free hugepage into free buddy pages. This function does
> - * nothing for in-use (including surplus) hugepages.
> + * Dissolve a given free hugepage into free buddy pages. Returns number
> + * of freed pages or EBUSY if the page is in use.
>   */
> -static void dissolve_free_huge_page(struct page *page)
> +static int dissolve_free_huge_page(struct page *page)
>  {
>  	struct page *head = compound_head(page);
>  	struct hstate *h;
>  	int nid;
> 
>  	if (page_count(head))
> -		return;
> +		return -EBUSY;
> 
>  	h = page_hstate(head);
>  	nid = page_to_nid(head);
> @@ -1456,6 +1456,8 @@ static void dissolve_free_huge_page(struct page *page)
>  	h->max_huge_pages--;
>  	update_and_free_page(h, head);
>  	spin_unlock(&hugetlb_lock);
> +
> +	return 1 << h->order;
>  }
> 
>  /*
> @@ -1471,9 +1473,18 @@ void dissolve_free_huge_pages(unsigned long start_pfn, unsigned long end_pfn)
>  	if (!hugepages_supported())
>  		return;
> 
> -	for (pfn = start_pfn; pfn < end_pfn; pfn += 1 << minimum_order)
> -		if (PageHuge(pfn_to_page(pfn)))
> -			dissolve_free_huge_page(pfn_to_page(pfn));
> +	for (pfn = start_pfn; pfn < end_pfn; )
> +		int nr_pages;
> +
> +		if (!PageHuge(pfn_to_page(pfn))) {
> +			pfn += 1 << minimum_order;
> +			continue;
> +		}
> +
> +		nr_pages = dissolve_free_huge_page(pfn_to_page(pfn));
> +		if (IS_ERR(nr_pages))
> +			break;
> +		pfn += nr_pages;
>  }
> 
>  /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
