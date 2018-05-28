Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id A8E4E6B000E
	for <linux-mm@kvack.org>; Mon, 28 May 2018 11:42:19 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id l17-v6so5402890wrm.3
        for <linux-mm@kvack.org>; Mon, 28 May 2018 08:42:19 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z17-v6si1229867edc.424.2018.05.28.08.42.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 28 May 2018 08:42:18 -0700 (PDT)
Date: Mon, 28 May 2018 10:52:31 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch] mm, hugetlb_cgroup: suppress SIGBUS when hugetlb_cgroup
 charge fails
Message-ID: <20180528085231.GA1648@dhcp22.suse.cz>
References: <alpine.DEB.2.21.1805251316090.167008@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1805251316090.167008@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri 25-05-18 13:16:45, David Rientjes wrote:
> When charging to a hugetlb_cgroup fails, alloc_huge_page() returns
> ERR_PTR(-ENOSPC) which will cause VM_FAULT_SIGBUS to be returned to the
> page fault handler.
> 
> Instead, return the proper error code, ERR_PTR(-ENOMEM), so VM_FAULT_OOM
> is handled correctly.  This is consistent with failing mem cgroup charges
> in the non-hugetlb fault path.

Could you describe the acutal problem you are trying to solve, please?
Also could you explain Why should be the charge and the reservation
failure any different? My memory is dim but the original hugetlb code
was aiming at being compatible with the reservation failures because in
essence the hugetlb simply subdivides the existing pool between cgroups.
I might misremember of course but the changelog should be much more
clear in that case.

> At the same time, restructure the return paths of alloc_huge_page() so it
> is consistent.

Please make an unrelated change in a separate commit.

> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  mm/hugetlb.c | 18 ++++++++++++------
>  1 file changed, 12 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
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
>  
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
>  
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
>  int alloc_bootmem_huge_page(struct hstate *h)

-- 
Michal Hocko
SUSE Labs
