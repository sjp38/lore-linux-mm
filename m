Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id DABA06B0038
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 08:32:19 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id b130so72074361wmc.2
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 05:32:19 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id n204si14976441wmd.134.2016.09.29.05.32.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Sep 2016 05:32:18 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id b184so10502283wma.3
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 05:32:18 -0700 (PDT)
Date: Thu, 29 Sep 2016 14:32:17 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v4 3/3] mm/hugetlb: improve locking in
 dissolve_free_huge_pages()
Message-ID: <20160929123216.GH408@dhcp22.suse.cz>
References: <20160926172811.94033-1-gerald.schaefer@de.ibm.com>
 <20160926172811.94033-4-gerald.schaefer@de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160926172811.94033-4-gerald.schaefer@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Rui Teng <rui.teng@linux.vnet.ibm.com>, Dave Hansen <dave.hansen@linux.intel.com>

On Mon 26-09-16 19:28:11, Gerald Schaefer wrote:
> For every pfn aligned to minimum_order, dissolve_free_huge_pages() will
> call dissolve_free_huge_page() which takes the hugetlb spinlock, even if
> the page is not huge at all or a hugepage that is in-use.
> 
> Improve this by doing the PageHuge() and page_count() checks already in
> dissolve_free_huge_pages() before calling dissolve_free_huge_page(). In
> dissolve_free_huge_page(), when holding the spinlock, those checks need
> to be revalidated.
> 
> Signed-off-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/hugetlb.c | 12 +++++++++---
>  1 file changed, 9 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 91ae1f5..770d83e 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1476,14 +1476,20 @@ static int dissolve_free_huge_page(struct page *page)
>  int dissolve_free_huge_pages(unsigned long start_pfn, unsigned long end_pfn)
>  {
>  	unsigned long pfn;
> +	struct page *page;
>  	int rc = 0;
>  
>  	if (!hugepages_supported())
>  		return rc;
>  
> -	for (pfn = start_pfn; pfn < end_pfn; pfn += 1 << minimum_order)
> -		if (rc = dissolve_free_huge_page(pfn_to_page(pfn)))
> -			break;
> +	for (pfn = start_pfn; pfn < end_pfn; pfn += 1 << minimum_order) {
> +		page = pfn_to_page(pfn);
> +		if (PageHuge(page) && !page_count(page)) {
> +			rc = dissolve_free_huge_page(page);
> +			if (rc)
> +				break;
> +		}
> +	}
>  
>  	return rc;
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
