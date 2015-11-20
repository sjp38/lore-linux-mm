Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f51.google.com (mail-oi0-f51.google.com [209.85.218.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6EFC26B0253
	for <linux-mm@kvack.org>; Fri, 20 Nov 2015 16:56:32 -0500 (EST)
Received: by oiww189 with SMTP id w189so72698189oiw.3
        for <linux-mm@kvack.org>; Fri, 20 Nov 2015 13:56:32 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id i17si865778oib.131.2015.11.20.13.56.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Nov 2015 13:56:31 -0800 (PST)
Subject: Re: [PATCH v1] mm: hugetlb: fix hugepage memory leak caused by wrong
 reserve count
References: <1448004017-23679-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <050201d12369$167a0a10$436e1e30$@alibaba-inc.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <564F9702.5070007@oracle.com>
Date: Fri, 20 Nov 2015 13:56:18 -0800
MIME-Version: 1.0
In-Reply-To: <050201d12369$167a0a10$436e1e30$@alibaba-inc.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>, 'Naoya Horiguchi' <n-horiguchi@ah.jp.nec.com>, 'Andrew Morton' <akpm@linux-foundation.org>
Cc: 'David Rientjes' <rientjes@google.com>, 'Dave Hansen' <dave.hansen@intel.com>, 'Mel Gorman' <mgorman@suse.de>, 'Joonsoo Kim' <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, 'Naoya Horiguchi' <nao.horiguchi@gmail.com>

On 11/19/2015 11:57 PM, Hillf Danton wrote:
>>
>> When dequeue_huge_page_vma() in alloc_huge_page() fails, we fall back to
>> alloc_buddy_huge_page() to directly create a hugepage from the buddy allocator.
>> In that case, however, if alloc_buddy_huge_page() succeeds we don't decrement
>> h->resv_huge_pages, which means that successful hugetlb_fault() returns without
>> releasing the reserve count. As a result, subsequent hugetlb_fault() might fail
>> despite that there are still free hugepages.
>>
>> This patch simply adds decrementing code on that code path.

In general, I agree with the patch.  If we allocate a huge page via the
buddy allocator and that page will be used to satisfy a reservation, then
we need to decrement the reservation count.

As Hillf mentions, this code is not exactly the same in linux-next.
Specifically, there is the new call to take the memory policy of the
vma into account when calling the buddy allocator.  I do not think,
this impacts your proposed change but you may want to test with that
in place.

>>
>> I reproduced this problem when testing v4.3 kernel in the following situation:
>> - the test machine/VM is a NUMA system,
>> - hugepage overcommiting is enabled,
>> - most of hugepages are allocated and there's only one free hugepage
>>   which is on node 0 (for example),
>> - another program, which calls set_mempolicy(MPOL_BIND) to bind itself to
>>   node 1, tries to allocate a hugepage,

I am curious about this scenario.  When this second program attempts to
allocate the page, I assume it creates a reservation first.  Is this
reservation before or after setting mempolicy?  If the mempolicy was set
first, I would have expected the reservation to allocate a page on
node 1 to satisfy the reservation.

-- 
Mike Kravetz

>> - the allocation should fail but the reserve count is still hold.
>>
>> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>> Cc: <stable@vger.kernel.org> [3.16+]
>> ---
>> - the reason why I set stable target to "3.16+" is that this patch can be
>>   applied easily/automatically on these versions. But this bug seems to be
>>   old one, so if you are interested in backporting to older kernels,
>>   please let me know.
>> ---
>>  mm/hugetlb.c |    5 ++++-
>>  1 files changed, 4 insertions(+), 1 deletions(-)
>>
>> diff --git v4.3/mm/hugetlb.c v4.3_patched/mm/hugetlb.c
>> index 9cc7734..77c518c 100644
>> --- v4.3/mm/hugetlb.c
>> +++ v4.3_patched/mm/hugetlb.c
>> @@ -1790,7 +1790,10 @@ struct page *alloc_huge_page(struct vm_area_struct *vma,
>>  		page = alloc_buddy_huge_page(h, NUMA_NO_NODE);
>>  		if (!page)
>>  			goto out_uncharge_cgroup;
>> -
>> +		if (!avoid_reserve && vma_has_reserves(vma, gbl_chg)) {
>> +			SetPagePrivate(page);
>> +			h->resv_huge_pages--;
>> +		}
> 
> I am wondering if this patch was prepared against the next tree.
> 
>>  		spin_lock(&hugetlb_lock);
>>  		list_move(&page->lru, &h->hugepage_activelist);
>>  		/* Fall through */
>> --
>> 1.7.1
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
