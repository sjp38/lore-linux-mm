Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id ACECD6B0003
	for <linux-mm@kvack.org>; Fri, 25 May 2018 16:45:02 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id w6-v6so1703615plp.14
        for <linux-mm@kvack.org>; Fri, 25 May 2018 13:45:02 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 43-v6si25221865pla.509.2018.05.25.13.45.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 May 2018 13:45:01 -0700 (PDT)
Date: Fri, 25 May 2018 13:44:59 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] mm, hugetlb_cgroup: suppress SIGBUS when hugetlb_cgroup
 charge fails
Message-Id: <20180525134459.5c6f8e06f55307f72b95a901@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.21.1805251316090.167008@chino.kir.corp.google.com>
References: <alpine.DEB.2.21.1805251316090.167008@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 25 May 2018 13:16:45 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:

> When charging to a hugetlb_cgroup fails, alloc_huge_page() returns
> ERR_PTR(-ENOSPC) which will cause VM_FAULT_SIGBUS to be returned to the
> page fault handler.
> 
> Instead, return the proper error code, ERR_PTR(-ENOMEM), so VM_FAULT_OOM
> is handled correctly.  This is consistent with failing mem cgroup charges
> in the non-hugetlb fault path.
> 
> At the same time, restructure the return paths of alloc_huge_page() so it
> is consistent.

Patch doesn't appear to match the changelog?

> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -2006,8 +2006,10 @@ struct page *alloc_huge_page(struct vm_area_struct *vma,
>  	 * code of zero indicates a reservation exists (no change).
>  	 */
>  	map_chg = gbl_chg = vma_needs_reservation(h, vma, addr);
> -	if (map_chg < 0)
> -		return ERR_PTR(-ENOMEM);
> +	if (map_chg < 0) {
> +		ret = -ENOMEM;
> +		goto out;
> +	}

This doesn't change the return value.

>  	/*
>  	 * Processes that did not create the mapping will have no
> @@ -2019,8 +2021,8 @@ struct page *alloc_huge_page(struct vm_area_struct *vma,
>  	if (map_chg || avoid_reserve) {
>  		gbl_chg = hugepage_subpool_get_pages(spool, 1);
>  		if (gbl_chg < 0) {
> -			vma_end_reservation(h, vma, addr);
> -			return ERR_PTR(-ENOSPC);
> +			ret = -ENOSPC;
> +			goto out_reservation;
>  		}

Nor does this.
 
>  		/*
> @@ -2049,8 +2051,10 @@ struct page *alloc_huge_page(struct vm_area_struct *vma,
>  	if (!page) {
>  		spin_unlock(&hugetlb_lock);
>  		page = alloc_buddy_huge_page_with_mpol(h, vma, addr);
> -		if (!page)
> +		if (!page) {
> +			ret = -ENOSPC;
>  			goto out_uncharge_cgroup;
> +		}

Nor does this.

>  		if (!avoid_reserve && vma_has_reserves(vma, gbl_chg)) {
>  			SetPagePrivate(page);
>  			h->resv_huge_pages--;
> @@ -2087,8 +2091,10 @@ struct page *alloc_huge_page(struct vm_area_struct *vma,
>  out_subpool_put:
>  	if (map_chg || avoid_reserve)
>  		hugepage_subpool_put_pages(spool, 1);
> +out_reservation:
>  	vma_end_reservation(h, vma, addr);
> -	return ERR_PTR(-ENOSPC);
> +out:
> +	return ERR_PTR(ret);
>  }
>  

It would be nice if you could add a comment over alloc_huge_page()
explaining the return values (at least).  Why sometimes ENOMEM, other
times ENOSPC?
