Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id E84386B0033
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 09:46:43 -0400 (EDT)
Received: from /spool/local
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 26 Aug 2013 23:38:09 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id EA2863578051
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 23:46:38 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7QDUZpt4456856
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 23:30:35 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r7QDkbQH015143
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 23:46:38 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 14/20] mm, hugetlb: call vma_needs_reservation before entering alloc_huge_page()
In-Reply-To: <87vc2sd15e.fsf@linux.vnet.ibm.com>
References: <1376040398-11212-1-git-send-email-iamjoonsoo.kim@lge.com> <1376040398-11212-15-git-send-email-iamjoonsoo.kim@lge.com> <87vc2sd15e.fsf@linux.vnet.ibm.com>
Date: Mon, 26 Aug 2013 19:16:33 +0530
Message-ID: <87mwo4d0p2.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>

"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> writes:

> Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:
>
>> In order to validate that this failure is reasonable, we need to know
>> whether allocation request is for reserved or not on caller function.
>> So moving vma_needs_reservation() up to the caller of alloc_huge_page().
>> There is no functional change in this patch and following patch use
>> this information.
>>
>> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>>
>> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
>> index 8dff972..bc666cf 100644
>> --- a/mm/hugetlb.c
>> +++ b/mm/hugetlb.c
>> @@ -1110,13 +1110,11 @@ static void vma_commit_reservation(struct hstate *h,
>>  }
>>
>>  static struct page *alloc_huge_page(struct vm_area_struct *vma,
>> -				    unsigned long addr, int avoid_reserve)
>> +				    unsigned long addr, int use_reserve)
>>  {
>>  	struct hugepage_subpool *spool = subpool_vma(vma);
>>  	struct hstate *h = hstate_vma(vma);
>>  	struct page *page;
>> -	long chg;
>> -	bool use_reserve;
>>  	int ret, idx;
>>  	struct hugetlb_cgroup *h_cg;
>>
>> @@ -1129,10 +1127,6 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
>>  	 * need pages and subpool limit allocated allocated if no reserve
>>  	 * mapping overlaps.
>>  	 */
>> -	chg = vma_needs_reservation(h, vma, addr);
>> -	if (chg < 0)
>> -		return ERR_PTR(-ENOMEM);
>> -	use_reserve = (!chg && !avoid_reserve);
>>  	if (!use_reserve)
>>  		if (hugepage_subpool_get_pages(spool, 1))
>>  			return ERR_PTR(-ENOSPC);
>> @@ -2504,6 +2498,8 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
>>  	struct hstate *h = hstate_vma(vma);
>>  	struct page *old_page, *new_page;
>>  	int outside_reserve = 0;
>> +	long chg;
>> +	bool use_reserve;
>>  	unsigned long mmun_start;	/* For mmu_notifiers */
>>  	unsigned long mmun_end;		/* For mmu_notifiers */
>>
>> @@ -2535,7 +2531,17 @@ retry_avoidcopy:
>>
>>  	/* Drop page_table_lock as buddy allocator may be called */
>>  	spin_unlock(&mm->page_table_lock);
>> -	new_page = alloc_huge_page(vma, address, outside_reserve);
>> +	chg = vma_needs_reservation(h, vma, address);
>> +	if (chg == -ENOMEM) {
>
> why not 
>
>     if (chg < 0) ?
>
> Should we try to unmap the page from child and avoid cow here ?. May be
> with outside_reserve = 1 we will never have vma_needs_reservation fail.
> Any how it would be nice to document why this error case is different
> from alloc_huge_page error case.
>

I guess patch  16 address this . So if we do if (chg < 0) we are good
here.

Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
