Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id B60416B0031
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 14:06:05 -0400 (EDT)
Date: Mon, 29 Jul 2013 14:05:51 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1375121151-dxyftdvy-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1375075929-6119-9-git-send-email-iamjoonsoo.kim@lge.com>
References: <1375075929-6119-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1375075929-6119-9-git-send-email-iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 08/18] mm, hugetlb: do hugepage_subpool_get_pages() when
 avoid_reserve
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Hillf Danton <dhillf@gmail.com>

On Mon, Jul 29, 2013 at 02:31:59PM +0900, Joonsoo Kim wrote:
> When we try to get a huge page with avoid_reserve, we don't consume
> a reserved page. So it is treated like as non-reserve case.

This patch will be completely overwritten with 9/18.
So is this patch necessary?

Naoya Horiguchi

> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 1426c03..749629e 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1149,12 +1149,13 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
>  	if (has_reserve < 0)
>  		return ERR_PTR(-ENOMEM);
>  
> -	if (!has_reserve && (hugepage_subpool_get_pages(spool, 1) < 0))
> +	if ((!has_reserve || avoid_reserve)
> +		&& (hugepage_subpool_get_pages(spool, 1) < 0))
>  			return ERR_PTR(-ENOSPC);
>  
>  	ret = hugetlb_cgroup_charge_cgroup(idx, pages_per_huge_page(h), &h_cg);
>  	if (ret) {
> -		if (!has_reserve)
> +		if (!has_reserve || avoid_reserve)
>  			hugepage_subpool_put_pages(spool, 1);
>  		return ERR_PTR(-ENOSPC);
>  	}
> @@ -1167,7 +1168,7 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
>  			hugetlb_cgroup_uncharge_cgroup(idx,
>  						       pages_per_huge_page(h),
>  						       h_cg);
> -			if (!has_reserve)
> +			if (!has_reserve || avoid_reserve)
>  				hugepage_subpool_put_pages(spool, 1);
>  			return ERR_PTR(-ENOSPC);
>  		}
> -- 
> 1.7.9.5
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
