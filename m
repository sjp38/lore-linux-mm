Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 52DA76B0009
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 21:47:48 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id h61-v6so2302409pld.3
        for <linux-mm@kvack.org>; Wed, 14 Mar 2018 18:47:48 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id i3-v6si3011368pld.404.2018.03.14.18.47.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Mar 2018 18:47:47 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm] mm, madvise, THP: Use THP aligned address in madvise_free_huge_pmd()
References: <20180315011840.27599-1-ying.huang@intel.com>
	<869F4AAA-5BBA-40D6-916F-6919E515D271@cs.rutgers.edu>
Date: Thu, 15 Mar 2018 09:47:44 +0800
In-Reply-To: <869F4AAA-5BBA-40D6-916F-6919E515D271@cs.rutgers.edu> (Zi Yan's
	message of "Wed, 14 Mar 2018 21:39:54 -0400")
Message-ID: <873712az3z.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan@kernel.org>, Shaohua Li <shli@kernel.org>, jglisse@redhat.com, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Zi Yan <zi.yan@cs.rutgers.edu> writes:

> This cannot happen.
>
> Two address parameters are passed: addr and next.
> If a??addra?? is not aligned and a??nexta?? is aligned or the end of madvise range, which might not be aligned,
> either way next - addr < HPAGE_PMD_SIZE.
>
> This means the code in a??if (next - addr != HPAGE_PMD_SIZE)a??, which is above your second hunk,
> will split the THP between a??addra?? and a??nexta?? and get out as long as a??addra?? is not aligned.
> Thus, the code in your second hunk should always get aligned a??addra??.
>
> Let me know if I miss anything.

Yes, you are right!  Thanks for pointing this out.

Sorry for bothering, please ignore this patch.

Best Regards,
Huang, Ying

> a??
> Best Regards,
> Yan Zi
>
> On 14 Mar 2018, at 21:18, Huang, Ying wrote:
>
>> From: Huang Ying <ying.huang@intel.com>
>>
>> The address argument passed in madvise_free_huge_pmd() may be not THP
>> aligned.  But some THP operations like pmdp_invalidate(),
>> set_pmd_at(), and tlb_remove_pmd_tlb_entry() need the address to be
>> THP aligned.  Fix this via using THP aligned address for these
>> functions in madvise_free_huge_pmd().
>>
>> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
>> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
>> Cc: Michal Hocko <mhocko@suse.com>
>> Cc: Minchan Kim <minchan@kernel.org>
>> Cc: Shaohua Li <shli@kernel.org>
>> Cc: Zi Yan <zi.yan@cs.rutgers.edu>
>> Cc: jglisse@redhat.com
>> Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>> ---
>>  mm/huge_memory.c | 7 ++++---
>>  1 file changed, 4 insertions(+), 3 deletions(-)
>>
>> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
>> index 0cc62405de9c..c5e1bfb08bd7 100644
>> --- a/mm/huge_memory.c
>> +++ b/mm/huge_memory.c
>> @@ -1617,6 +1617,7 @@ bool madvise_free_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
>>  	struct page *page;
>>  	struct mm_struct *mm = tlb->mm;
>>  	bool ret = false;
>> +	unsigned long haddr = addr & HPAGE_PMD_MASK;
>>
>>  	tlb_remove_check_page_size_change(tlb, HPAGE_PMD_SIZE);
>>
>> @@ -1663,12 +1664,12 @@ bool madvise_free_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
>>  	unlock_page(page);
>>
>>  	if (pmd_young(orig_pmd) || pmd_dirty(orig_pmd)) {
>> -		pmdp_invalidate(vma, addr, pmd);
>> +		pmdp_invalidate(vma, haddr, pmd);
>>  		orig_pmd = pmd_mkold(orig_pmd);
>>  		orig_pmd = pmd_mkclean(orig_pmd);
>>
>> -		set_pmd_at(mm, addr, pmd, orig_pmd);
>> -		tlb_remove_pmd_tlb_entry(tlb, pmd, addr);
>> +		set_pmd_at(mm, haddr, pmd, orig_pmd);
>> +		tlb_remove_pmd_tlb_entry(tlb, pmd, haddr);
>>  	}
>>
>>  	mark_page_lazyfree(page);
>> -- 
>> 2.16.1
