Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id C390428029C
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 07:18:05 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id g186so3709355pfb.11
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 04:18:05 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m2si3776428pgd.498.2018.01.17.04.18.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 17 Jan 2018 04:18:04 -0800 (PST)
Date: Wed, 17 Jan 2018 13:18:01 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [bug report] hugetlb, mempolicy: fix the mbind hugetlb migration
Message-ID: <20180117121801.GE2900@dhcp22.suse.cz>
References: <20180109200539.g7chrnzftxyn3nom@mwanda>
 <20180110104712.GR1732@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180110104712.GR1732@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mike Kravetz <mike.kravetz@oracle.com>

On Wed 10-01-18 11:47:12, Michal Hocko wrote:
> [CC Mike and Naoya]

ping

> From 7227218bd526cceb954a688727d78af0b5874e18 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Wed, 10 Jan 2018 11:40:20 +0100
> Subject: [PATCH] hugetlb, mbind: fall back to default policy if vma is NULL
> 
> Dan Carpenter has noticed that mbind migration callback (new_page)
> can get a NULL vma pointer and choke on it inside alloc_huge_page_vma
> which relies on the VMA to get the hstate. We used to BUG_ON this
> case but the BUG_+ON has been removed recently by "hugetlb, mempolicy:
> fix the mbind hugetlb migration".
> 
> The proper way to handle this is to get the hstate from the migrated
> page and rely on huge_node (resp. get_vma_policy) do the right thing
> with null VMA. We are currently falling back to the default mempolicy in
> that case which is in line what THP path is doing here.
> 
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  include/linux/hugetlb.h | 5 +++--
>  mm/hugetlb.c            | 5 ++---
>  mm/mempolicy.c          | 3 ++-
>  3 files changed, 7 insertions(+), 6 deletions(-)
> 
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index 612a29b7f6c6..36fa6a2a82e3 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -358,7 +358,8 @@ struct page *alloc_huge_page(struct vm_area_struct *vma,
>  struct page *alloc_huge_page_node(struct hstate *h, int nid);
>  struct page *alloc_huge_page_nodemask(struct hstate *h, int preferred_nid,
>  				nodemask_t *nmask);
> -struct page *alloc_huge_page_vma(struct vm_area_struct *vma, unsigned long address);
> +struct page *alloc_huge_page_vma(struct hstate *h, struct vm_area_struct *vma,
> +				unsigned long address);
>  int huge_add_to_page_cache(struct page *page, struct address_space *mapping,
>  			pgoff_t idx);
>  
> @@ -536,7 +537,7 @@ struct hstate {};
>  #define alloc_huge_page(v, a, r) NULL
>  #define alloc_huge_page_node(h, nid) NULL
>  #define alloc_huge_page_nodemask(h, preferred_nid, nmask) NULL
> -#define alloc_huge_page_vma(vma, address) NULL
> +#define alloc_huge_page_vma(h, vma, address) NULL
>  #define alloc_bootmem_huge_page(h) NULL
>  #define hstate_file(f) NULL
>  #define hstate_sizelog(s) NULL
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index ffcae114ceed..27872270ead7 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1675,16 +1675,15 @@ struct page *alloc_huge_page_nodemask(struct hstate *h, int preferred_nid,
>  }
>  
>  /* mempolicy aware migration callback */
> -struct page *alloc_huge_page_vma(struct vm_area_struct *vma, unsigned long address)
> +struct page *alloc_huge_page_vma(struct hstate *h, struct vm_area_struct *vma,
> +		unsigned long address)
>  {
>  	struct mempolicy *mpol;
>  	nodemask_t *nodemask;
>  	struct page *page;
> -	struct hstate *h;
>  	gfp_t gfp_mask;
>  	int node;
>  
> -	h = hstate_vma(vma);
>  	gfp_mask = htlb_alloc_mask(h);
>  	node = huge_node(vma, address, gfp_mask, &mpol, &nodemask);
>  	page = alloc_huge_page_nodemask(h, node, nodemask);
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 30e68da64873..a8b7d59002e8 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -1097,7 +1097,8 @@ static struct page *new_page(struct page *page, unsigned long start)
>  	}
>  
>  	if (PageHuge(page)) {
> -		return alloc_huge_page_vma(vma, address);
> +		return alloc_huge_page_vma(page_hstate(compound_head(page)),
> +				vma, address);
>  	} else if (PageTransHuge(page)) {
>  		struct page *thp;
>  
> -- 
> 2.15.1
> 
> -- 
> Michal Hocko
> SUSE Labs

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
