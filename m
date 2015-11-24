Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f41.google.com (mail-oi0-f41.google.com [209.85.218.41])
	by kanga.kvack.org (Postfix) with ESMTP id D9C1F6B0038
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 13:16:47 -0500 (EST)
Received: by oiww189 with SMTP id w189so14925386oiw.3
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 10:16:47 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id e11si12320140oig.85.2015.11.24.10.16.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Nov 2015 10:16:47 -0800 (PST)
Subject: Re: [PATCH v1] mm: hugetlb: fix hugepage memory leak caused by wrong
 reserve count
References: <1448004017-23679-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <050201d12369$167a0a10$436e1e30$@alibaba-inc.com>
 <564F9702.5070007@oracle.com>
 <20151124053258.GA27211@hori1.linux.bs1.fc.nec.co.jp>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <5654A984.1020005@oracle.com>
Date: Tue, 24 Nov 2015 10:16:36 -0800
MIME-Version: 1.0
In-Reply-To: <20151124053258.GA27211@hori1.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Hillf Danton <hillf.zj@alibaba-inc.com>, 'Andrew Morton' <akpm@linux-foundation.org>, 'David Rientjes' <rientjes@google.com>, 'Dave Hansen' <dave.hansen@intel.com>, 'Mel Gorman' <mgorman@suse.de>, 'Joonsoo Kim' <iamjoonsoo.kim@lge.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, 'Naoya Horiguchi' <nao.horiguchi@gmail.com>

On 11/23/2015 09:32 PM, Naoya Horiguchi wrote:
> On Fri, Nov 20, 2015 at 01:56:18PM -0800, Mike Kravetz wrote:
>> On 11/19/2015 11:57 PM, Hillf Danton wrote:
>>>>
>>>> When dequeue_huge_page_vma() in alloc_huge_page() fails, we fall back to
>>>> alloc_buddy_huge_page() to directly create a hugepage from the buddy allocator.
>>>> In that case, however, if alloc_buddy_huge_page() succeeds we don't decrement
>>>> h->resv_huge_pages, which means that successful hugetlb_fault() returns without
>>>> releasing the reserve count. As a result, subsequent hugetlb_fault() might fail
>>>> despite that there are still free hugepages.
>>>>
>>>> This patch simply adds decrementing code on that code path.
>>
>> In general, I agree with the patch.  If we allocate a huge page via the
>> buddy allocator and that page will be used to satisfy a reservation, then
>> we need to decrement the reservation count.
>>
>> As Hillf mentions, this code is not exactly the same in linux-next.
>> Specifically, there is the new call to take the memory policy of the
>> vma into account when calling the buddy allocator.  I do not think,
>> this impacts your proposed change but you may want to test with that
>> in place.
>>
>>>>
>>>> I reproduced this problem when testing v4.3 kernel in the following situation:
>>>> - the test machine/VM is a NUMA system,
>>>> - hugepage overcommiting is enabled,
>>>> - most of hugepages are allocated and there's only one free hugepage
>>>>   which is on node 0 (for example),
>>>> - another program, which calls set_mempolicy(MPOL_BIND) to bind itself to
>>>>   node 1, tries to allocate a hugepage,
>>
>> I am curious about this scenario.  When this second program attempts to
>> allocate the page, I assume it creates a reservation first.  Is this
>> reservation before or after setting mempolicy?  If the mempolicy was set
>> first, I would have expected the reservation to allocate a page on
>> node 1 to satisfy the reservation.
> 
> My testing called set_mempolicy() at first then called mmap(), but things
> didn't change if I reordered them, because currently hugetlb reservation is
> not NUMA-aware.

Ah right.  I was looking at gather_surplus_pages() as called by
hugetlb_acct_memory() to account for a new reservation.  In your case,
the global free count is still large enough to satisfy the reservation
so gather_surplus_pages simply increases the global reservation count.

If there were not enough free pages, alloc_buddy_huge_page() would be
called in an attempt to allocate enough free pages.  As is the case in
alloc_huge_page(), the mempolicy of the of the task would be taken into
account (if there is no vma specific policy).  So, the new huge pages to
satisfy the reservation would 'hopefully' be allocated on the correct node.

Sorry, I thinking your test might be allocating a new huge page at
reservation time.  But, it is not.
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
