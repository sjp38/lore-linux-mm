Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 3B1356B0038
	for <linux-mm@kvack.org>; Thu, 28 May 2015 17:09:23 -0400 (EDT)
Received: by pacwv17 with SMTP id wv17so32178367pac.2
        for <linux-mm@kvack.org>; Thu, 28 May 2015 14:09:23 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id sj10si5262686pac.198.2015.05.28.14.09.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 May 2015 14:09:22 -0700 (PDT)
Message-ID: <556781DE.5070300@oracle.com>
Date: Thu, 28 May 2015 14:00:14 -0700
From: Mike Kravetz <mike.kravetz@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 3/3] mm/hugetlb: handle races in alloc_huge_page and
 hugetlb_reserve_pages
References: <1432749371-32220-1-git-send-email-mike.kravetz@oracle.com>	 <1432749371-32220-4-git-send-email-mike.kravetz@oracle.com> <1432821670.13915.3.camel@stgolabs.net>
In-Reply-To: <1432821670.13915.3.camel@stgolabs.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, Luiz Capitulino <lcapitulino@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

On 05/28/2015 07:01 AM, Davidlohr Bueso wrote:
> On Wed, 2015-05-27 at 10:56 -0700, Mike Kravetz wrote:
>> alloc_huge_page and hugetlb_reserve_pages use region_chg to
>> calculate the number of pages which will be added to the reserve
>> map.  Subpool and global reserve counts are adjusted based on
>> the output of region_chg.  Before the pages are actually added
>> to the reserve map, these routines could race and add fewer
>> pages than expected.  If this happens, the subpool and global
>> reserve counts are not correct.
>>
>> Compare the number of pages actually added (region_add) to those
>> expected to added (region_chg).  If fewer pages are actually added,
>> this indicates a race and adjust counters accordingly.
>>
>> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
>
> Reviewed-by: Davidlohr Bueso <dave@stgolabs.net>
>
> With one nit below.
>
>> ---
>>   mm/hugetlb.c | 34 ++++++++++++++++++++++++++++++----
>>   1 file changed, 30 insertions(+), 4 deletions(-)
>>
>> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
>> index b3d3d59..038c84e 100644
>> --- a/mm/hugetlb.c
>> +++ b/mm/hugetlb.c
>> @@ -1544,7 +1544,7 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
>>   	struct hugepage_subpool *spool = subpool_vma(vma);
>>   	struct hstate *h = hstate_vma(vma);
>>   	struct page *page;
>> -	long chg;
>> +	long chg, commit;
>>   	int ret, idx;
>>   	struct hugetlb_cgroup *h_cg;
>>
>> @@ -1585,7 +1585,20 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
>>
>>   	set_page_private(page, (unsigned long)spool);
>>
>> -	vma_commit_reservation(h, vma, addr);
>> +	commit = vma_commit_reservation(h, vma, addr);
>> +	if (unlikely(chg > commit)) {
>> +		/*
>> +		 * The page was added to the reservation map between
>> +		 * vma_needs_reservation and vma_commit_reservation.
>> +		 * This indicates a race with hugetlb_reserve_pages.
>> +		 * Adjust for the subpool count incremented above AND
>> +		 * in hugetlb_reserve_pages for the same page.  Also,
>> +		 * the reservation count added in hugetlb_reserve_pages
>> +		 * no longer applies.
>> +		 */
>> +		hugepage_subpool_put_pages(spool, 1);
>> +		hugetlb_acct_memory(h, -1);
>
> Should these fixups be encapsulated in a helper? The comment is the same
> for both alloc_huge_page and hugetlb_reserve_pages.

I would like to leave things as they are right now.  It makes it
pretty explicit what fixup is needed and performed.

As you know, discovery of this bug came out of my hugetlbfs fallocate
work.  In that patchset, I created a race fixup routine.  If fallocate
moves forward, I'll reexamine the above fixups and look into helpers.

Thanks for the review,
-- 
Mike Kravetz

>
> Thanks,
> Davidlohr
>
>> +	}
>>   	return page;
>>
>>   out_uncharge_cgroup:
>> @@ -3699,8 +3712,21 @@ int hugetlb_reserve_pages(struct inode *inode,
>>   	 * consumed reservations are stored in the map. Hence, nothing
>>   	 * else has to be done for private mappings here
>>   	 */
>> -	if (!vma || vma->vm_flags & VM_MAYSHARE)
>> -		region_add(resv_map, from, to);
>> +	if (!vma || vma->vm_flags & VM_MAYSHARE) {
>> +		long add = region_add(resv_map, from, to);
>> +
>> +		if (unlikely(chg > add)) {
>> +			/*
>> +			 * pages in this range were added to the reserve
>> +			 * map between region_chg and region_add.  This
>> +			 * indicates a race with alloc_huge_page.  Adjust
>> +			 * the subpool and reserve counts modified above
>> +			 * based on the difference.
>> +			 */
>> +			hugepage_subpool_put_pages(spool, chg - add);
>> +			hugetlb_acct_memory(h, -(chg - ret));
>> +		}
>> +	}
>>   	return 0;
>>   out_err:
>>   	if (vma && is_vma_resv_set(vma, HPAGE_RESV_OWNER))
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
