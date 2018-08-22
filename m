Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id C56F76B2453
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 08:28:53 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id d47-v6so897487edb.3
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 05:28:53 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z39-v6si515303edz.13.2018.08.22.05.28.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Aug 2018 05:28:52 -0700 (PDT)
Date: Wed, 22 Aug 2018 14:28:48 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3 1/2] mm: migration: fix migration of huge PMD shared
 pages
Message-ID: <20180822122848.GL29735@dhcp22.suse.cz>
References: <20180821205902.21223-2-mike.kravetz@oracle.com>
 <201808220831.eM0je51n%fengguang.wu@intel.com>
 <975b740d-26a6-eb3f-c8ca-1a9995d0d343@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <975b740d-26a6-eb3f-c8ca-1a9995d0d343@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: kbuild test robot <lkp@intel.com>, kbuild-all@01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org

On Tue 21-08-18 18:10:42, Mike Kravetz wrote:
[...]
> diff --git a/mm/rmap.c b/mm/rmap.c
> index eb477809a5c0..8cf853a4b093 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1362,11 +1362,21 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  	}
>  
>  	/*
> -	 * We have to assume the worse case ie pmd for invalidation. Note that
> -	 * the page can not be free in this function as call of try_to_unmap()
> -	 * must hold a reference on the page.
> +	 * For THP, we have to assume the worse case ie pmd for invalidation.
> +	 * For hugetlb, it could be much worse if we need to do pud
> +	 * invalidation in the case of pmd sharing.
> +	 *
> +	 * Note that the page can not be free in this function as call of
> +	 * try_to_unmap() must hold a reference on the page.
>  	 */
>  	end = min(vma->vm_end, start + (PAGE_SIZE << compound_order(page)));
> +	if (PageHuge(page)) {
> +		/*
> +		 * If sharing is possible, start and end will be adjusted
> +		 * accordingly.
> +		 */
> +		(void)huge_pmd_sharing_possible(vma, &start, &end);
> +	}
>  	mmu_notifier_invalidate_range_start(vma->vm_mm, start, end);

I do not get this part. Why don't we simply unconditionally invalidate
the whole huge page range?

>  
>  	while (page_vma_mapped_walk(&pvmw)) {
> @@ -1409,6 +1419,32 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  		subpage = page - page_to_pfn(page) + pte_pfn(*pvmw.pte);
>  		address = pvmw.address;
>  
> +		if (PageHuge(page)) {
> +			if (huge_pmd_unshare(mm, &address, pvmw.pte)) {

huge_pmd_unshare is documented to require a pte lock. Where do we take
it?
-- 
Michal Hocko
SUSE Labs
