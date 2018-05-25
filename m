Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 793E66B0279
	for <linux-mm@kvack.org>; Thu, 24 May 2018 20:34:37 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id d20-v6so1859404pfn.16
        for <linux-mm@kvack.org>; Thu, 24 May 2018 17:34:37 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id f17-v6si9437819pgt.243.2018.05.24.17.34.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 May 2018 17:34:35 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -V2 -mm 3/4] mm, hugetlbfs: Rename address to haddr in hugetlb_cow()
References: <20180524005851.4079-1-ying.huang@intel.com>
	<20180524005851.4079-4-ying.huang@intel.com>
	<4e569170-9f4e-eb12-d10d-fe9b7fcdfc9d@oracle.com>
Date: Fri, 25 May 2018 08:34:31 +0800
In-Reply-To: <4e569170-9f4e-eb12-d10d-fe9b7fcdfc9d@oracle.com> (Mike Kravetz's
	message of "Thu, 24 May 2018 14:42:13 -0700")
Message-ID: <87lgc8bmjs.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andi Kleen <andi.kleen@intel.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Shaohua Li <shli@fb.com>, Christopher Lameter <cl@linux.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Punit Agrawal <punit.agrawal@arm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.com>

Mike Kravetz <mike.kravetz@oracle.com> writes:

> On 05/23/2018 05:58 PM, Huang, Ying wrote:
>> From: Huang Ying <ying.huang@intel.com>
>> 
>> To take better advantage of general huge page copying optimization,
>> the target subpage address will be passed to hugetlb_cow(), then
>> copy_user_huge_page().  So we will use both target subpage address and
>> huge page size aligned address in hugetlb_cow().  To distinguish
>> between them, "haddr" is used for huge page size aligned address to be
>> consistent with Transparent Huge Page naming convention.
>> 
>> Now, only huge page size aligned address is used in hugetlb_cow(), so
>> the "address" is renamed to "haddr" in hugetlb_cow() in this patch.
>> Next patch will use target subpage address in hugetlb_cow() too.
>> 
>> The patch is just code cleanup without any functionality changes.
>> 
>> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
>> Suggested-by: Mike Kravetz <mike.kravetz@oracle.com>
>> Suggested-by: Michal Hocko <mhocko@suse.com>
>
> I believe Kirill may have been the one who suggested using haddr to be
> consistent with usage in huge_memory.c.

Yes.  I should have added

Suggested-by: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Best Regards,
Huang, Ying

>> Cc: David Rientjes <rientjes@google.com>
>> Cc: Andrea Arcangeli <aarcange@redhat.com>
>> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
>> Cc: Andi Kleen <andi.kleen@intel.com>
>> Cc: Jan Kara <jack@suse.cz>
>> Cc: Matthew Wilcox <mawilcox@microsoft.com>
>> Cc: Hugh Dickins <hughd@google.com>
>> Cc: Minchan Kim <minchan@kernel.org>
>> Cc: Shaohua Li <shli@fb.com>
>> Cc: Christopher Lameter <cl@linux.com>
>> Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>> Cc: Punit Agrawal <punit.agrawal@arm.com>
>> Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>
>> ---
>>  mm/hugetlb.c | 26 ++++++++++++--------------
>>  1 file changed, 12 insertions(+), 14 deletions(-)
>> 
>> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
>> index 696befffe6f7..ad3bec2ed269 100644
>> --- a/mm/hugetlb.c
>> +++ b/mm/hugetlb.c
>> @@ -3500,7 +3500,7 @@ static void unmap_ref_private(struct mm_struct *mm, struct vm_area_struct *vma,
>>   * Keep the pte_same checks anyway to make transition from the mutex easier.
>>   */
>>  static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
>> -		       unsigned long address, pte_t *ptep,
>> +		       unsigned long haddr, pte_t *ptep,
>>  		       struct page *pagecache_page, spinlock_t *ptl)
>>  {
>>  	pte_t pte;
>> @@ -3518,7 +3518,7 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
>>  	 * and just make the page writable */
>>  	if (page_mapcount(old_page) == 1 && PageAnon(old_page)) {
>>  		page_move_anon_rmap(old_page, vma);
>> -		set_huge_ptep_writable(vma, address, ptep);
>> +		set_huge_ptep_writable(vma, haddr, ptep);
>>  		return 0;
>>  	}
>>  
>> @@ -3542,7 +3542,7 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
>>  	 * be acquired again before returning to the caller, as expected.
>>  	 */
>>  	spin_unlock(ptl);
>> -	new_page = alloc_huge_page(vma, address, outside_reserve);
>> +	new_page = alloc_huge_page(vma, haddr, outside_reserve);
>>  
>>  	if (IS_ERR(new_page)) {
>>  		/*
>> @@ -3555,11 +3555,10 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
>>  		if (outside_reserve) {
>>  			put_page(old_page);
>>  			BUG_ON(huge_pte_none(pte));
>> -			unmap_ref_private(mm, vma, old_page, address);
>> +			unmap_ref_private(mm, vma, old_page, haddr);
>>  			BUG_ON(huge_pte_none(pte));
>>  			spin_lock(ptl);
>> -			ptep = huge_pte_offset(mm, address & huge_page_mask(h),
>> -					       huge_page_size(h));
>> +			ptep = huge_pte_offset(mm, haddr, huge_page_size(h));
>
> Ha!  The name change points out an obviously unnecessary conversion in
> the existing code.  Yes, hugetlb_cow is always passed a hpage aligned
> address today.
>
>>  			if (likely(ptep &&
>>  				   pte_same(huge_ptep_get(ptep), pte)))
>>  				goto retry_avoidcopy;
>> @@ -3584,12 +3583,12 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
>>  		goto out_release_all;
>>  	}
>>  
>> -	copy_user_huge_page(new_page, old_page, address, vma,
>> +	copy_user_huge_page(new_page, old_page, haddr, vma,
>>  			    pages_per_huge_page(h));
>>  	__SetPageUptodate(new_page);
>>  	set_page_huge_active(new_page);
>>  
>> -	mmun_start = address & huge_page_mask(h);
>> +	mmun_start = haddr;
>
> And another one.
>
>>  	mmun_end = mmun_start + huge_page_size(h);
>>  	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
>>  
>> @@ -3598,25 +3597,24 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
>>  	 * before the page tables are altered
>>  	 */
>>  	spin_lock(ptl);
>> -	ptep = huge_pte_offset(mm, address & huge_page_mask(h),
>> -			       huge_page_size(h));
>> +	ptep = huge_pte_offset(mm, haddr, huge_page_size(h));
>
> And yet another.
>
> Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>
