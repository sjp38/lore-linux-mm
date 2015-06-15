Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id B692F6B0038
	for <linux-mm@kvack.org>; Mon, 15 Jun 2015 14:43:06 -0400 (EDT)
Received: by pdbnf5 with SMTP id nf5so78847095pdb.2
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 11:43:06 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id na2si8663925pdb.130.2015.06.15.11.43.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jun 2015 11:43:05 -0700 (PDT)
Message-ID: <557F1C91.9080904@oracle.com>
Date: Mon, 15 Jun 2015 11:42:25 -0700
From: Mike Kravetz <mike.kravetz@oracle.com>
MIME-Version: 1.0
Subject: Re: [RFC v4 PATCH 6/9] mm/hugetlb: alloc_huge_page handle areas hole
 punched by fallocate
References: <1434056500-2434-1-git-send-email-mike.kravetz@oracle.com> <1434056500-2434-7-git-send-email-mike.kravetz@oracle.com> <20150615063444.GA26050@hori1.linux.bs1.fc.nec.co.jp>
In-Reply-To: <20150615063444.GA26050@hori1.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christoph Hellwig <hch@infradead.org>

On 06/14/2015 11:34 PM, Naoya Horiguchi wrote:
> On Thu, Jun 11, 2015 at 02:01:37PM -0700, Mike Kravetz wrote:
>> Areas hole punched by fallocate will not have entries in the
>> region/reserve map.  However, shared mappings with min_size subpool
>> reservations may still have reserved pages.  alloc_huge_page needs
>> to handle this special case and do the proper accounting.
>>
>> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
>> ---
>>   mm/hugetlb.c | 48 +++++++++++++++++++++++++++---------------------
>>   1 file changed, 27 insertions(+), 21 deletions(-)
>>
>> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
>> index ecbaffe..9c295c9 100644
>> --- a/mm/hugetlb.c
>> +++ b/mm/hugetlb.c
>> @@ -692,19 +692,9 @@ static int vma_has_reserves(struct vm_area_struct *vma, long chg)
>>   			return 0;
>>   	}
>>   
>> -	if (vma->vm_flags & VM_MAYSHARE) {
>> -		/*
>> -		 * We know VM_NORESERVE is not set.  Therefore, there SHOULD
>> -		 * be a region map for all pages.  The only situation where
>> -		 * there is no region map is if a hole was punched via
>> -		 * fallocate.  In this case, there really are no reverves to
>> -		 * use.  This situation is indicated if chg != 0.
>> -		 */
>> -		if (chg)
>> -			return 0;
>> -		else
>> -			return 1;
>> -	}
>> +	/* Shared mappings always use reserves */
>> +	if (vma->vm_flags & VM_MAYSHARE)
>> +		return 1;
> 
> This change completely reverts 5/9, so can you omit 5/9?

That was a mistake.  This change should not be in the patch.  The
change from 5/9 needs to remain.  Sorry for confusion.  Thanks for
catching.

>>   	/*
>>   	 * Only the process that called mmap() has reserves for
>> @@ -1601,6 +1591,7 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
>>   	struct hstate *h = hstate_vma(vma);
>>   	struct page *page;
>>   	long chg, commit;
>> +	long gbl_chg;
>>   	int ret, idx;
>>   	struct hugetlb_cgroup *h_cg;
>>   
>> @@ -1608,24 +1599,39 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
>>   	/*
>>   	 * Processes that did not create the mapping will have no
>>   	 * reserves and will not have accounted against subpool
>> -	 * limit. Check that the subpool limit can be made before
>> -	 * satisfying the allocation MAP_NORESERVE mappings may also
>> -	 * need pages and subpool limit allocated allocated if no reserve
>> -	 * mapping overlaps.
>> +	 * limit. Check that the subpool limit will not be exceeded
>> +	 * before performing the allocation.  Allocations for
>> +	 * MAP_NORESERVE mappings also need to be checked against
>> +	 * any subpool limit.
>> +	 *
>> +	 * NOTE: Shared mappings with holes punched via fallocate
>> +	 * may still have reservations, even without entries in the
>> +	 * reserve map as indicated by vma_needs_reservation.  This
>> +	 * would be the case if hugepage_subpool_get_pages returns
>> +	 * zero to indicate no changes to the global reservation count
>> +	 * are necessary.  In this case, pass the output of
>> +	 * hugepage_subpool_get_pages (zero) to dequeue_huge_page_vma
>> +	 * so that the page is not counted against the global limit.
>> +	 * For MAP_NORESERVE mappings always pass the output of
>> +	 * vma_needs_reservation.  For race detection and error cleanup
>> +	 * use output of vma_needs_reservation as well.
>>   	 */
>> -	chg = vma_needs_reservation(h, vma, addr);
>> +	chg = gbl_chg = vma_needs_reservation(h, vma, addr);
>>   	if (chg < 0)
>>   		return ERR_PTR(-ENOMEM);
>> -	if (chg || avoid_reserve)
>> -		if (hugepage_subpool_get_pages(spool, 1) < 0)
>> +	if (chg || avoid_reserve) {
>> +		gbl_chg = hugepage_subpool_get_pages(spool, 1);
>> +		if (gbl_chg < 0)
>>   			return ERR_PTR(-ENOSPC);
>> +	}
>>   
>>   	ret = hugetlb_cgroup_charge_cgroup(idx, pages_per_huge_page(h), &h_cg);
>>   	if (ret)
>>   		goto out_subpool_put;
>>   
>>   	spin_lock(&hugetlb_lock);
>> -	page = dequeue_huge_page_vma(h, vma, addr, avoid_reserve, chg);
>> +	page = dequeue_huge_page_vma(h, vma, addr, avoid_reserve,
>> +					avoid_reserve ? chg : gbl_chg);
> 
> You use chg or gbl_chg depending on avoid_reserve here, and below this line
> there's code like below
> 
> 	commit = vma_commit_reservation(h, vma, addr);
> 	if (unlikely(chg > commit)) {
> 		...
> 	}
> 
> This also need to be changed to use chg or gbl_chg depending on avoid_reserve?

It should use chg only.  I attempted to address this at the end of the
Note above.
" For race detection and error cleanup use output of vma_needs_reservation
  as well."
I will add more comments to make it clear.

> # I feel that this reserve-handling code in alloc_huge_page() is too complicated
> # and hard to understand, so some cleanup like separating reserve parts into
> # other new routine(s) might be helpful...

I agree, let me think about ways to split this up and hopefully make
it easier to understand.

-- 
Mike Kravetz

> 
> Thanks,
> Naoya Horiguchi
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
