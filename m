Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f52.google.com (mail-ee0-f52.google.com [74.125.83.52])
	by kanga.kvack.org (Postfix) with ESMTP id 89D216B0036
	for <linux-mm@kvack.org>; Thu, 15 May 2014 05:01:47 -0400 (EDT)
Received: by mail-ee0-f52.google.com with SMTP id e53so407877eek.25
        for <linux-mm@kvack.org>; Thu, 15 May 2014 02:01:46 -0700 (PDT)
Received: from mail-ee0-x229.google.com (mail-ee0-x229.google.com [2a00:1450:4013:c00::229])
        by mx.google.com with ESMTPS id t45si3667100eel.2.2014.05.15.02.01.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 15 May 2014 02:01:46 -0700 (PDT)
Received: by mail-ee0-f41.google.com with SMTP id t10so424881eei.28
        for <linux-mm@kvack.org>; Thu, 15 May 2014 02:01:45 -0700 (PDT)
Date: Thu, 15 May 2014 11:01:42 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm, hugetlb: move the error handle logic out of normal
 code path
Message-ID: <20140515090142.GB3938@dhcp22.suse.cz>
References: <1400051459-20578-1-git-send-email-nasa4836@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1400051459-20578-1-git-send-email-nasa4836@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianyu Zhan <nasa4836@gmail.com>
Cc: akpm@linux-foundation.org, iamjoonsoo.kim@lge.com, aneesh.kumar@linux.vnet.ibm.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, steve.capper@linaro.org, davidlohr@hp.com, kirill.shutemov@linux.intel.com, dave.hansen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 14-05-14 15:10:59, Jianyu Zhan wrote:
> alloc_huge_page() now mixes normal code path with error handle logic.
> This patches move out the error handle logic, to make normal code
> path more clean and redue code duplicate.

I don't know. Part of the function returns and cleans up on its own and
other part relies on clean up labels. This is not so much nicer than the
previous state.

> Signed-off-by: Jianyu Zhan <nasa4836@gmail.com>
> ---
>  mm/hugetlb.c | 26 +++++++++++++-------------
>  1 file changed, 13 insertions(+), 13 deletions(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 26b1464..e81c69e 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1246,24 +1246,17 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
>  			return ERR_PTR(-ENOSPC);
>  
>  	ret = hugetlb_cgroup_charge_cgroup(idx, pages_per_huge_page(h), &h_cg);
> -	if (ret) {
> -		if (chg || avoid_reserve)
> -			hugepage_subpool_put_pages(spool, 1);
> -		return ERR_PTR(-ENOSPC);
> -	}
> +	if (ret)
> +		goto out_subpool_put;
> +
>  	spin_lock(&hugetlb_lock);
>  	page = dequeue_huge_page_vma(h, vma, addr, avoid_reserve, chg);
>  	if (!page) {
>  		spin_unlock(&hugetlb_lock);
>  		page = alloc_buddy_huge_page(h, NUMA_NO_NODE);
> -		if (!page) {
> -			hugetlb_cgroup_uncharge_cgroup(idx,
> -						       pages_per_huge_page(h),
> -						       h_cg);
> -			if (chg || avoid_reserve)
> -				hugepage_subpool_put_pages(spool, 1);
> -			return ERR_PTR(-ENOSPC);
> -		}
> +		if (!page)
> +			goto out_uncharge_cgroup;
> +
>  		spin_lock(&hugetlb_lock);
>  		list_move(&page->lru, &h->hugepage_activelist);
>  		/* Fall through */
> @@ -1275,6 +1268,13 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
>  
>  	vma_commit_reservation(h, vma, addr);
>  	return page;
> +
> +out_uncharge_cgroup:
> +	hugetlb_cgroup_uncharge_cgroup(idx, pages_per_huge_page(h), h_cg);
> +out_subpool_put:
> +	if (chg || avoid_reserve)
> +		hugepage_subpool_put_pages(spool, 1);
> +	return ERR_PTR(-ENOSPC);
>  }
>  
>  /*
> -- 
> 2.0.0-rc3
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
