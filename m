Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua1-f71.google.com (mail-ua1-f71.google.com [209.85.222.71])
	by kanga.kvack.org (Postfix) with ESMTP id 62A666B2543
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 12:48:31 -0400 (EDT)
Received: by mail-ua1-f71.google.com with SMTP id g9-v6so942589uam.17
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 09:48:31 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id b25-v6si874766uap.322.2018.08.22.09.48.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Aug 2018 09:48:28 -0700 (PDT)
Subject: Re: [PATCH v3 1/2] mm: migration: fix migration of huge PMD shared
 pages
References: <20180821205902.21223-2-mike.kravetz@oracle.com>
 <201808220831.eM0je51n%fengguang.wu@intel.com>
 <975b740d-26a6-eb3f-c8ca-1a9995d0d343@oracle.com>
 <20180822122848.GL29735@dhcp22.suse.cz>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <4a95a24f-534f-0938-f358-2a410817a412@oracle.com>
Date: Wed, 22 Aug 2018 09:48:16 -0700
MIME-Version: 1.0
In-Reply-To: <20180822122848.GL29735@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: kbuild test robot <lkp@intel.com>, kbuild-all@01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org

On 08/22/2018 05:28 AM, Michal Hocko wrote:
> On Tue 21-08-18 18:10:42, Mike Kravetz wrote:
> [...]
>> diff --git a/mm/rmap.c b/mm/rmap.c
>> index eb477809a5c0..8cf853a4b093 100644
>> --- a/mm/rmap.c
>> +++ b/mm/rmap.c
>> @@ -1362,11 +1362,21 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>>  	}
>>  
>>  	/*
>> -	 * We have to assume the worse case ie pmd for invalidation. Note that
>> -	 * the page can not be free in this function as call of try_to_unmap()
>> -	 * must hold a reference on the page.
>> +	 * For THP, we have to assume the worse case ie pmd for invalidation.
>> +	 * For hugetlb, it could be much worse if we need to do pud
>> +	 * invalidation in the case of pmd sharing.
>> +	 *
>> +	 * Note that the page can not be free in this function as call of
>> +	 * try_to_unmap() must hold a reference on the page.
>>  	 */
>>  	end = min(vma->vm_end, start + (PAGE_SIZE << compound_order(page)));
>> +	if (PageHuge(page)) {
>> +		/*
>> +		 * If sharing is possible, start and end will be adjusted
>> +		 * accordingly.
>> +		 */
>> +		(void)huge_pmd_sharing_possible(vma, &start, &end);
>> +	}
>>  	mmu_notifier_invalidate_range_start(vma->vm_mm, start, end);
> 
> I do not get this part. Why don't we simply unconditionally invalidate
> the whole huge page range?

In this routine, we are only unmapping a single page.  The existing code
is limiting the invalidate range to that page size: 4K or 2M.  With shared
PMDs, we have the possibility of unmapping a PUD_SIZE area: 1G.  I don't
think we want to unconditionally invalidate 1G.  Is that what you are asking?

I do not know how often PMD sharing is exercised.  It certainly is used by
DBs for large shared areas.  I suspect it is less frequent than hugtlb pages
in general, and certainly less frequent than THP or base pages.

>>  
>>  	while (page_vma_mapped_walk(&pvmw)) {
>> @@ -1409,6 +1419,32 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>>  		subpage = page - page_to_pfn(page) + pte_pfn(*pvmw.pte);
>>  		address = pvmw.address;
>>  
>> +		if (PageHuge(page)) {
>> +			if (huge_pmd_unshare(mm, &address, pvmw.pte)) {
> 
> huge_pmd_unshare is documented to require a pte lock. Where do we take
> it?

It is somewhat hidden, but we are in the loop:

	while (page_vma_mapped_walk(&pvmw)) {

The routine page_vma_mapped_walk will acquire the lock, and it correctly
checks for huge pages and uses huge_pte_lockptr().

page_vma_mapped_walk_done() will release the lock.
-- 
Mike Kravetz
