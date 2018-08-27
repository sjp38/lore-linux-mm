Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 29B096B417B
	for <linux-mm@kvack.org>; Mon, 27 Aug 2018 12:42:15 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id l5-v6so6651798vkd.12
        for <linux-mm@kvack.org>; Mon, 27 Aug 2018 09:42:15 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id c48-v6si6963156uad.207.2018.08.27.09.42.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Aug 2018 09:42:13 -0700 (PDT)
Subject: Re: [PATCH v6 1/2] mm: migration: fix migration of huge PMD shared
 pages
References: <20180823205917.16297-1-mike.kravetz@oracle.com>
 <20180823205917.16297-2-mike.kravetz@oracle.com>
 <20180824084157.GD29735@dhcp22.suse.cz>
 <6063f215-a5c8-2f0c-465a-2c515ddc952d@oracle.com>
 <20180827074645.GB21556@dhcp22.suse.cz>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <3d9057ef-13ad-7796-ebb0-f86cf7936127@oracle.com>
Date: Mon, 27 Aug 2018 09:42:03 -0700
MIME-Version: 1.0
In-Reply-To: <20180827074645.GB21556@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org

On 08/27/2018 12:46 AM, Michal Hocko wrote:
> On Fri 24-08-18 11:08:24, Mike Kravetz wrote:
>> On 08/24/2018 01:41 AM, Michal Hocko wrote:
>>> On Thu 23-08-18 13:59:16, Mike Kravetz wrote:
>>>
>>> Acked-by: Michal Hocko <mhocko@suse.com>
>>>
>>> One nit below.
>>>
>>> [...]
>>>> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
>>>> index 3103099f64fd..a73c5728e961 100644
>>>> --- a/mm/hugetlb.c
>>>> +++ b/mm/hugetlb.c
>>>> @@ -4548,6 +4548,9 @@ static unsigned long page_table_shareable(struct vm_area_struct *svma,
>>>>  	return saddr;
>>>>  }
>>>>  
>>>> +#define _range_in_vma(vma, start, end) \
>>>> +	((vma)->vm_start <= (start) && (end) <= (vma)->vm_end)
>>>> +
>>>
>>> static inline please. Macros and potential side effects on given
>>> arguments are just not worth the risk. I also think this is something
>>> for more general use. We have that pattern at many places. So I would
>>> stick that to linux/mm.h
>>
>> Thanks Michal,
>>
>> Here is an updated patch which does as you suggest above.
> [...]
>> @@ -1409,6 +1419,32 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>>  		subpage = page - page_to_pfn(page) + pte_pfn(*pvmw.pte);
>>  		address = pvmw.address;
>>  
>> +		if (PageHuge(page)) {
>> +			if (huge_pmd_unshare(mm, &address, pvmw.pte)) {
>> +				/*
>> +				 * huge_pmd_unshare unmapped an entire PMD
>> +				 * page.  There is no way of knowing exactly
>> +				 * which PMDs may be cached for this mm, so
>> +				 * we must flush them all.  start/end were
>> +				 * already adjusted above to cover this range.
>> +				 */
>> +				flush_cache_range(vma, start, end);
>> +				flush_tlb_range(vma, start, end);
>> +				mmu_notifier_invalidate_range(mm, start, end);
>> +
>> +				/*
>> +				 * The ref count of the PMD page was dropped
>> +				 * which is part of the way map counting
>> +				 * is done for shared PMDs.  Return 'true'
>> +				 * here.  When there is no other sharing,
>> +				 * huge_pmd_unshare returns false and we will
>> +				 * unmap the actual page and drop map count
>> +				 * to zero.
>> +				 */
>> +				page_vma_mapped_walk_done(&pvmw);
>> +				break;
>> +			}
> 
> This still calls into notifier while holding the ptl lock. Either I am
> missing something or the invalidation is broken in this loop (not also
> for other invalidations).

As Jerome said ...

When creating this patch, I started by using the same flush/invalidation
routines used by the existing code.  This is because it is not obvious what
interfaces can be called in what context, and I didn't want to do anything
different.  The best 'documentation' are the comments in the mmu_notifier_ops
definition.

-- 
Mike Kravetz
