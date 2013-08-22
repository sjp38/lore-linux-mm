Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 325C46B0071
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 04:44:53 -0400 (EDT)
Received: from /spool/local
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 22 Aug 2013 18:33:34 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 075103578053
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 18:44:45 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7M8Sj2Q19464204
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 18:28:46 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r7M8ih8T024792
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 18:44:44 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 12/20] mm, hugetlb: remove vma_has_reserves()
In-Reply-To: <1376040398-11212-13-git-send-email-iamjoonsoo.kim@lge.com>
References: <1376040398-11212-1-git-send-email-iamjoonsoo.kim@lge.com> <1376040398-11212-13-git-send-email-iamjoonsoo.kim@lge.com>
Date: Thu, 22 Aug 2013 14:14:38 +0530
Message-ID: <87siy215e1.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>

Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:

> vma_has_reserves() can be substituted by using return value of
> vma_needs_reservation(). If chg returned by vma_needs_reservation()
> is 0, it means that vma has reserves. Otherwise, it means that vma don't
> have reserves and need a hugepage outside of reserve pool. This definition
> is perfectly same as vma_has_reserves(), so remove vma_has_reserves().
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

>
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index e6c0c77..22ceb04 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -473,39 +473,6 @@ void reset_vma_resv_huge_pages(struct vm_area_struct *vma)
>  		vma->vm_private_data = (void *)0;
>  }
>
> -/* Returns true if the VMA has associated reserve pages */
> -static int vma_has_reserves(struct vm_area_struct *vma, long chg)
> -{
> -	if (vma->vm_flags & VM_NORESERVE) {
> -		/*
> -		 * This address is already reserved by other process(chg == 0),
> -		 * so, we should decreament reserved count. Without
> -		 * decreamenting, reserve count is remained after releasing
> -		 * inode, because this allocated page will go into page cache
> -		 * and is regarded as coming from reserved pool in releasing
> -		 * step. Currently, we don't have any other solution to deal
> -		 * with this situation properly, so add work-around here.
> -		 */
> -		if (vma->vm_flags & VM_MAYSHARE && chg == 0)
> -			return 1;
> -		else
> -			return 0;
> -	}
> -
> -	/* Shared mappings always use reserves */
> -	if (vma->vm_flags & VM_MAYSHARE)
> -		return 1;
> -
> -	/*
> -	 * Only the process that called mmap() has reserves for
> -	 * private mappings.
> -	 */
> -	if (is_vma_resv_set(vma, HPAGE_RESV_OWNER))
> -		return 1;
> -
> -	return 0;
> -}
> -
>  static void copy_gigantic_page(struct page *dst, struct page *src)
>  {
>  	int i;
> @@ -580,8 +547,7 @@ static struct page *dequeue_huge_page_vma(struct hstate *h,
>  	 * have no page reserves. This check ensures that reservations are
>  	 * not "stolen". The child may still get SIGKILLed
>  	 */
> -	if (!vma_has_reserves(vma, chg) &&
> -			h->free_huge_pages - h->resv_huge_pages == 0)
> +	if (chg && h->free_huge_pages - h->resv_huge_pages == 0)
>  		return NULL;
>
>  	/* If reserves cannot be used, ensure enough pages are in the pool */
> @@ -600,7 +566,7 @@ retry_cpuset:
>  			if (page) {
>  				if (avoid_reserve)
>  					break;
> -				if (!vma_has_reserves(vma, chg))
> +				if (chg)
>  					break;
>
>  				SetPagePrivate(page);

Can you add a comment above both the place to explain why checking chg
is good enough ?

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
