Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 6C8756B0033
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 09:44:15 -0400 (EDT)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 27 Aug 2013 10:38:23 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id CEFD03578050
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 23:44:10 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7QDS6ws8782134
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 23:28:07 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r7QDi9H0020491
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 23:44:10 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 16/20] mm, hugetlb: move down outside_reserve check
In-Reply-To: <1376040398-11212-17-git-send-email-iamjoonsoo.kim@lge.com>
References: <1376040398-11212-1-git-send-email-iamjoonsoo.kim@lge.com> <1376040398-11212-17-git-send-email-iamjoonsoo.kim@lge.com>
Date: Mon, 26 Aug 2013 19:14:04 +0530
Message-ID: <87ppt0d0t7.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>

Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:

> Just move down outside_reserve check and don't check
> vma_need_reservation() when outside_resever is true. It is slightly
> optimized implementation.
>
> This makes code more readable.
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

I guess this address the comment I had with the previous patch

Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

>
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 24de2ca..2372f75 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -2499,7 +2499,7 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
>  	struct page *old_page, *new_page;
>  	int outside_reserve = 0;
>  	long chg;
> -	bool use_reserve;
> +	bool use_reserve = false;
>  	unsigned long mmun_start;	/* For mmu_notifiers */
>  	unsigned long mmun_end;		/* For mmu_notifiers */
>
> @@ -2514,6 +2514,11 @@ retry_avoidcopy:
>  		return 0;
>  	}
>
> +	page_cache_get(old_page);
> +
> +	/* Drop page_table_lock as buddy allocator may be called */
> +	spin_unlock(&mm->page_table_lock);
> +
>  	/*
>  	 * If the process that created a MAP_PRIVATE mapping is about to
>  	 * perform a COW due to a shared page count, attempt to satisfy
> @@ -2527,19 +2532,17 @@ retry_avoidcopy:
>  			old_page != pagecache_page)
>  		outside_reserve = 1;
>
> -	page_cache_get(old_page);
> -
> -	/* Drop page_table_lock as buddy allocator may be called */
> -	spin_unlock(&mm->page_table_lock);
> -	chg = vma_needs_reservation(h, vma, address);
> -	if (chg == -ENOMEM) {
> -		page_cache_release(old_page);
> +	if (!outside_reserve) {
> +		chg = vma_needs_reservation(h, vma, address);
> +		if (chg == -ENOMEM) {
> +			page_cache_release(old_page);
>
> -		/* Caller expects lock to be held */
> -		spin_lock(&mm->page_table_lock);
> -		return VM_FAULT_OOM;
> +			/* Caller expects lock to be held */
> +			spin_lock(&mm->page_table_lock);
> +			return VM_FAULT_OOM;
> +		}
> +		use_reserve = !chg;
>  	}
> -	use_reserve = !chg && !outside_reserve;
>
>  	new_page = alloc_huge_page(vma, address, use_reserve);
>
> -- 
> 1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
