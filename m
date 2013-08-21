Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 7A00F6B003B
	for <linux-mm@kvack.org>; Wed, 21 Aug 2013 05:28:43 -0400 (EDT)
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 21 Aug 2013 19:11:44 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id A191E2CE804D
	for <linux-mm@kvack.org>; Wed, 21 Aug 2013 19:28:37 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7L9CW9r46596200
	for <linux-mm@kvack.org>; Wed, 21 Aug 2013 19:12:40 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r7L9SSXk021120
	for <linux-mm@kvack.org>; Wed, 21 Aug 2013 19:28:29 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 03/20] mm, hugetlb: fix subpool accounting handling
In-Reply-To: <1376040398-11212-4-git-send-email-iamjoonsoo.kim@lge.com>
References: <1376040398-11212-1-git-send-email-iamjoonsoo.kim@lge.com> <1376040398-11212-4-git-send-email-iamjoonsoo.kim@lge.com>
Date: Wed, 21 Aug 2013 14:58:20 +0530
Message-ID: <87vc2zgzpn.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>

Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:

> If we alloc hugepage with avoid_reserve, we don't dequeue reserved one.
> So, we should check subpool counter when avoid_reserve.
> This patch implement it.

Can you explain this better ? ie, if we don't have a reservation in the
area chg != 0. So why look at avoid_reserve. 

Also the code will become if you did

if (!chg && avoid_reserve)
   chg = 1;

and then rest of the code will be able to handle the case.

>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 12b6581..ea1ae0a 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1144,13 +1144,14 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
>  	chg = vma_needs_reservation(h, vma, addr);
>  	if (chg < 0)
>  		return ERR_PTR(-ENOMEM);
> -	if (chg)
> -		if (hugepage_subpool_get_pages(spool, chg))
> +	if (chg || avoid_reserve)
> +		if (hugepage_subpool_get_pages(spool, 1))
>  			return ERR_PTR(-ENOSPC);
>
>  	ret = hugetlb_cgroup_charge_cgroup(idx, pages_per_huge_page(h), &h_cg);
>  	if (ret) {
> -		hugepage_subpool_put_pages(spool, chg);
> +		if (chg || avoid_reserve)
> +			hugepage_subpool_put_pages(spool, 1);
>  		return ERR_PTR(-ENOSPC);
>  	}
>  	spin_lock(&hugetlb_lock);
> @@ -1162,7 +1163,8 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
>  			hugetlb_cgroup_uncharge_cgroup(idx,
>  						       pages_per_huge_page(h),
>  						       h_cg);
> -			hugepage_subpool_put_pages(spool, chg);
> +			if (chg || avoid_reserve)
> +				hugepage_subpool_put_pages(spool, 1);
>  			return ERR_PTR(-ENOSPC);
>  		}
>  		spin_lock(&hugetlb_lock);
> -- 
> 1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
