Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f197.google.com (mail-yb0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id D2B7D6B0253
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 16:40:33 -0400 (EDT)
Received: by mail-yb0-f197.google.com with SMTP id 63so34857875ybs.5
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 13:40:33 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id 67si2657346itj.109.2016.10.24.13.40.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Oct 2016 13:40:33 -0700 (PDT)
Subject: Re: [PATCH 1/1] mm/hugetlb: fix huge page reservation leak in private
 mapping error paths
References: <1476933077-23091-1-git-send-email-mike.kravetz@oracle.com>
 <1476933077-23091-2-git-send-email-mike.kravetz@oracle.com>
 <87vawjthzr.fsf@linux.vnet.ibm.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <4ec1a385-396a-7aab-1981-6dce58a12109@oracle.com>
Date: Mon, 24 Oct 2016 13:40:23 -0700
MIME-Version: 1.0
In-Reply-To: <87vawjthzr.fsf@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Michal Hocko <mhocko@suse.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Dave Hansen <dave.hansen@linux.intel.com>, Jan Stancek <jstancek@redhat.com>, stable@vger.kernel.org

On 10/23/2016 04:36 AM, Aneesh Kumar K.V wrote:
> Mike Kravetz <mike.kravetz@oracle.com> writes:
> 
>> Error paths in hugetlb_cow() and hugetlb_no_page() may free a newly
>> allocated huge page.  If a reservation was associated with the huge
>> page, alloc_huge_page() consumed the reservation while allocating.
>> When the newly allocated page is freed in free_huge_page(), it will
>> increment the global reservation count.  However, the reservation entry
>> in the reserve map will remain.  This is not an issue for shared
>> mappings as the entry in the reserve map indicates a reservation exists.
>> But, an entry in a private mapping reserve map indicates the reservation
>> was consumed and no longer exists.  This results in an inconsistency
>> between the reserve map and the global reservation count.  This 'leaks'
>> a reserved huge page.
>>
>> Create a new routine restore_reserve_on_error() to restore the reserve
>> entry in these specific error paths.  This routine makes use of a new
>> function vma_add_reservation() which will add a reserve entry for a
>> specific address/page.
>>
>> In general, these error paths were rarely (if ever) taken on most
>> architectures.  However, powerpc contained arch specific code that
>> that resulted in an extra fault and execution of these error paths
>> on all private mappings.
>>
>> Fixes: 67961f9db8c4 ("mm/hugetlb: fix huge page reserve accounting for private mappings)
>>
>> Cc: stable@vger.kernel.org
>> Reported-by: Jan Stancek <jstancek@redhat.com>
>> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
>> ---
>>  mm/hugetlb.c | 66 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>>  1 file changed, 66 insertions(+)
>>
>> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
>> index ec49d9e..418bf01 100644
>> --- a/mm/hugetlb.c
>> +++ b/mm/hugetlb.c
>> @@ -1826,11 +1826,17 @@ static void return_unused_surplus_pages(struct hstate *h,
>>   * is not the case is if a reserve map was changed between calls.  It
>>   * is the responsibility of the caller to notice the difference and
>>   * take appropriate action.
>> + *
>> + * vma_add_reservation is used in error paths where a reservation must
>> + * be restored when a newly allocated huge page must be freed.  It is
>> + * to be called after calling vma_needs_reservation to determine if a
>> + * reservation exists.
>>   */
>>  enum vma_resv_mode {
>>  	VMA_NEEDS_RESV,
>>  	VMA_COMMIT_RESV,
>>  	VMA_END_RESV,
>> +	VMA_ADD_RESV,
>>  };
>>  static long __vma_reservation_common(struct hstate *h,
>>  				struct vm_area_struct *vma, unsigned long addr,
>> @@ -1856,6 +1862,14 @@ static long __vma_reservation_common(struct hstate *h,
>>  		region_abort(resv, idx, idx + 1);
>>  		ret = 0;
>>  		break;
>> +	case VMA_ADD_RESV:
>> +		if (vma->vm_flags & VM_MAYSHARE)
>> +			ret = region_add(resv, idx, idx + 1);
>> +		else {
>> +			region_abort(resv, idx, idx + 1);
>> +			ret = region_del(resv, idx, idx + 1);
>> +		}
> 
> It is confusing to find ADD_RESV doing region_del, but I don't have
> suggestion for a better name.

Thanks for the review Aneesh.

Of course, this naming is the result of shared and private mappings having
completely opposite reserve map semantics.  In shared mappings, an entry
in the reserve map indicates a reservation exists.  For private mappings,
the absence of an entry in the reserve map indicates a reservation exists.

-- 
Mike Kravetz

> 
> -aneesh
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
