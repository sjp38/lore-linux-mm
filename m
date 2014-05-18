Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id 259246B0036
	for <linux-mm@kvack.org>; Sun, 18 May 2014 13:27:39 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id uo5so4770130pbc.14
        for <linux-mm@kvack.org>; Sun, 18 May 2014 10:27:38 -0700 (PDT)
Received: from e23smtp04.au.ibm.com (e23smtp04.au.ibm.com. [202.81.31.146])
        by mx.google.com with ESMTPS id is5si8120735pbb.345.2014.05.18.10.27.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 18 May 2014 10:27:38 -0700 (PDT)
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 19 May 2014 03:27:33 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 721CF2BB0057
	for <linux-mm@kvack.org>; Mon, 19 May 2014 03:27:29 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s4IH5uAn62062774
	for <linux-mm@kvack.org>; Mon, 19 May 2014 03:05:57 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s4IHRRWu026300
	for <linux-mm@kvack.org>; Mon, 19 May 2014 03:27:28 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm, hugetlb: move the error handle logic out of normal code path
In-Reply-To: <1400051459-20578-1-git-send-email-nasa4836@gmail.com>
References: <1400051459-20578-1-git-send-email-nasa4836@gmail.com>
Date: Sun, 18 May 2014 22:57:16 +0530
Message-ID: <87oayvngjv.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianyu Zhan <nasa4836@gmail.com>, akpm@linux-foundation.org, iamjoonsoo.kim@lge.com, n-horiguchi@ah.jp.nec.com, mhocko@suse.cz, aarcange@redhat.com, steve.capper@linaro.org, davidlohr@hp.com, kirill.shutemov@linux.intel.com, dave.hansen@linux.intel.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Jianyu Zhan <nasa4836@gmail.com> writes:

> alloc_huge_page() now mixes normal code path with error handle logic.
> This patches move out the error handle logic, to make normal code
> path more clean and redue code duplicate.
>
> Signed-off-by: Jianyu Zhan <nasa4836@gmail.com>

Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

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
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
