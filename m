Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 362AF6B0033
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 09:36:53 -0400 (EDT)
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 26 Aug 2013 18:57:07 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id D7675E0057
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 19:07:22 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7QDaike39649334
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 19:06:44 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r7QDako2024115
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 19:06:47 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 14/20] mm, hugetlb: call vma_needs_reservation before entering alloc_huge_page()
In-Reply-To: <1376040398-11212-15-git-send-email-iamjoonsoo.kim@lge.com>
References: <1376040398-11212-1-git-send-email-iamjoonsoo.kim@lge.com> <1376040398-11212-15-git-send-email-iamjoonsoo.kim@lge.com>
Date: Mon, 26 Aug 2013 19:06:45 +0530
Message-ID: <87vc2sd15e.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>

Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:

> In order to validate that this failure is reasonable, we need to know
> whether allocation request is for reserved or not on caller function.
> So moving vma_needs_reservation() up to the caller of alloc_huge_page().
> There is no functional change in this patch and following patch use
> this information.
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 8dff972..bc666cf 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1110,13 +1110,11 @@ static void vma_commit_reservation(struct hstate *h,
>  }
>
>  static struct page *alloc_huge_page(struct vm_area_struct *vma,
> -				    unsigned long addr, int avoid_reserve)
> +				    unsigned long addr, int use_reserve)
>  {
>  	struct hugepage_subpool *spool = subpool_vma(vma);
>  	struct hstate *h = hstate_vma(vma);
>  	struct page *page;
> -	long chg;
> -	bool use_reserve;
>  	int ret, idx;
>  	struct hugetlb_cgroup *h_cg;
>
> @@ -1129,10 +1127,6 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
>  	 * need pages and subpool limit allocated allocated if no reserve
>  	 * mapping overlaps.
>  	 */
> -	chg = vma_needs_reservation(h, vma, addr);
> -	if (chg < 0)
> -		return ERR_PTR(-ENOMEM);
> -	use_reserve = (!chg && !avoid_reserve);
>  	if (!use_reserve)
>  		if (hugepage_subpool_get_pages(spool, 1))
>  			return ERR_PTR(-ENOSPC);
> @@ -2504,6 +2498,8 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
>  	struct hstate *h = hstate_vma(vma);
>  	struct page *old_page, *new_page;
>  	int outside_reserve = 0;
> +	long chg;
> +	bool use_reserve;
>  	unsigned long mmun_start;	/* For mmu_notifiers */
>  	unsigned long mmun_end;		/* For mmu_notifiers */
>
> @@ -2535,7 +2531,17 @@ retry_avoidcopy:
>
>  	/* Drop page_table_lock as buddy allocator may be called */
>  	spin_unlock(&mm->page_table_lock);
> -	new_page = alloc_huge_page(vma, address, outside_reserve);
> +	chg = vma_needs_reservation(h, vma, address);
> +	if (chg == -ENOMEM) {

why not 

    if (chg < 0) ?

Should we try to unmap the page from child and avoid cow here ?. May be
with outside_reserve = 1 we will never have vma_needs_reservation fail.
Any how it would be nice to document why this error case is different
from alloc_huge_page error case.


> +		page_cache_release(old_page);
> +
> +		/* Caller expects lock to be held */
> +		spin_lock(&mm->page_table_lock);
> +		return VM_FAULT_OOM;
> +	}
> +	use_reserve = !chg && !outside_reserve;
> +
> +	new_page = alloc_huge_page(vma, address, use_reserve);
>
>  	if (IS_ERR(new_page)) {
>  		long err = PTR_ERR(new_page);
> @@ -2664,6 +2670,8 @@ static int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  	struct page *page;
>  	struct address_space *mapping;
>  	pte_t new_pte;
> +	long chg;
> +	bool use_reserve;
>
>  	/*
>  	 * Currently, we are forced to kill the process in the event the
> @@ -2689,7 +2697,15 @@ retry:
>  		size = i_size_read(mapping->host) >> huge_page_shift(h);
>  		if (idx >= size)
>  			goto out;
> -		page = alloc_huge_page(vma, address, 0);
> +
> +		chg = vma_needs_reservation(h, vma, address);
> +		if (chg == -ENOMEM) {

if (chg < 0)

> +			ret = VM_FAULT_OOM;
> +			goto out;
> +		}
> +		use_reserve = !chg;
> +
> +		page = alloc_huge_page(vma, address, use_reserve);
>  		if (IS_ERR(page)) {
>  			ret = PTR_ERR(page);
>  			if (ret == -ENOMEM)
> -- 
> 1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
