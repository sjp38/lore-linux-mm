Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f177.google.com (mail-qc0-f177.google.com [209.85.216.177])
	by kanga.kvack.org (Postfix) with ESMTP id 11B746B0032
	for <linux-mm@kvack.org>; Fri, 23 Jan 2015 11:52:35 -0500 (EST)
Received: by mail-qc0-f177.google.com with SMTP id p6so7176577qcv.8
        for <linux-mm@kvack.org>; Fri, 23 Jan 2015 08:52:34 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id k2si2674287qao.19.2015.01.23.08.52.33
        for <linux-mm@kvack.org>;
        Fri, 23 Jan 2015 08:52:34 -0800 (PST)
Message-ID: <54C2739C.10509@redhat.com>
Date: Fri, 23 Jan 2015 11:15:24 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: incorporate read-only pages into transparent huge
 pages
References: <1421999256-3881-1-git-send-email-ebru.akagunduz@gmail.com> <54C2730A.8040601@suse.cz>
In-Reply-To: <54C2730A.8040601@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, kirill@shutemov.name, mhocko@suse.cz, mgorman@suse.de, rientjes@google.com, sasha.levin@oracle.com, hughd@google.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, aarcange@redhat.com

On 01/23/2015 11:12 AM, Vlastimil Babka wrote:
> On 01/23/2015 08:47 AM, Ebru Akagunduz wrote:
>> This patch aims to improve THP collapse rates, by allowing
>> THP collapse in the presence of read-only ptes, like those
>> left in place by do_swap_page after a read fault.
> 
> An other examples? What about zero pages?

I don't think this patch handles the zero page, due to
the reference count being higher than 1.

Handling the zero page could be a good next case to handle
in Ebru's OPW project to improve the THP collapse rate.

>> Currently THP can collapse 4kB pages into a THP when
>> there are up to khugepaged_max_ptes_none pte_none ptes
>> in a 2MB range. This patch applies the same limit for
>> read-only ptes.
>>
>> The patch was tested with a test program that allocates
>> 800MB of memory, writes to it, and then sleeps. I force
>> the system to swap out all but 190MB of the program by
>> touching other memory. Afterwards, the test program does
>> a mix of reads and writes to its memory, and the memory
>> gets swapped back in.
>>
>> Without the patch, only the memory that did not get
>> swapped out remained in THPs, which corresponds to 24% of
>> the memory of the program. The percentage did not increase
>> over time.
>>
>> With this patch, after 5 minutes of waiting khugepaged had
>> collapsed 55% of the program's memory back into THPs.
>>
>> Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
>> Reviewed-by: Rik van Riel <riel@redhat.com>
> 
> Sounds like a good idea.
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> nits below:
> 
>> ---
>> I've written down test results:
>>
>> With the patch:
>> After swapped out:
>> cat /proc/pid/smaps:
>> Anonymous:      100352 kB
>> AnonHugePages:  98304 kB
>> Swap:           699652 kB
>> Fraction:       97,95
>>
>> cat /proc/meminfo:
>> AnonPages:      1763732 kB
>> AnonHugePages:  1716224 kB
>> Fraction:       97,30
>>
>> After swapped in:
>> In a few seconds:
>> cat /proc/pid/smaps
>> Anonymous:      800004 kB
>> AnonHugePages:  235520 kB
>> Swap:           0 kB
>> Fraction:       29,43
>>
>> cat /proc/meminfo:
>> AnonPages:      2464336 kB
>> AnonHugePages:  1853440 kB
>> Fraction:       75,21
>>
>> In five minutes:
>> cat /proc/pid/smaps:
>> Anonymous:      800004 kB
>> AnonHugePages:  440320 kB
>> Swap:           0 kB
>> Fraction:       55,0
>>
>> cat /proc/meminfo:
>> AnonPages:      2464340
>> AnonHugePages:  2058240
>> Fraction:       83,52
>>
>> Without the patch:
>> After swapped out:
>> cat /proc/pid/smaps:
>> Anonymous:      190660 kB
>> AnonHugePages:  190464 kB
>> Swap:           609344 kB
>> Fraction:       99,89
>>
>> cat /proc/meminfo:
>> AnonPages:      1740456 kB
>> AnonHugePages:  1667072 kB
>> Fraction:       95,78
>>
>> After swapped in:
>> cat /proc/pid/smaps:
>> Anonymous:      800004 kB
>> AnonHugePages:  190464 kB
>> Swap:           0 kB
>> Fraction:       23,80
>>
>> cat /proc/meminfo:
>> AnonPages:      2350032 kB
>> AnonHugePages:  1667072 kB
>> Fraction:       70,93
>>
>> I waited 10 minutes the fractions
>> did not change without the patch.
>>
>>   mm/huge_memory.c | 25 ++++++++++++++++++++-----
>>   1 file changed, 20 insertions(+), 5 deletions(-)
>>
>> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
>> index 817a875..af750d9 100644
>> --- a/mm/huge_memory.c
>> +++ b/mm/huge_memory.c
>> @@ -2158,7 +2158,7 @@ static int __collapse_huge_page_isolate(struct
>> vm_area_struct *vma,
>>               else
>>                   goto out;
>>           }
>> -        if (!pte_present(pteval) || !pte_write(pteval))
>> +        if (!pte_present(pteval))
>>               goto out;
>>           page = vm_normal_page(vma, address, pteval);
>>           if (unlikely(!page))
>> @@ -2169,7 +2169,7 @@ static int __collapse_huge_page_isolate(struct
>> vm_area_struct *vma,
>>           VM_BUG_ON_PAGE(!PageSwapBacked(page), page);
>>
>>           /* cannot use mapcount: can't collapse if there's a gup pin */
>> -        if (page_count(page) != 1)
>> +        if (page_count(page) != 1 + !!PageSwapCache(page))
> 
> Took me a while to grok this !!PageSwapCache(page) part. Perhaps expand
> the comment?
> 
>>               goto out;
>>           /*
>>            * We can do it before isolate_lru_page because the
>> @@ -2179,6 +2179,17 @@ static int __collapse_huge_page_isolate(struct
>> vm_area_struct *vma,
>>            */
>>           if (!trylock_page(page))
>>               goto out;
>> +        if (!pte_write(pteval)) {
>> +            if (PageSwapCache(page) && !reuse_swap_page(page)) {
>> +                    unlock_page(page);
>> +                    goto out;
> 
> Too much indent on the 2 lines above.
> 
>> +            }
>> +            /*
>> +             * Page is not in the swap cache, and page count is
>> +             * one (see above). It can be collapsed into a THP.
>> +             */
> 
> Such comment sounds like a good place for:
> 
>             VM_BUG_ON(page_count(page) != 1));
> 
>> +        }
>> +
>>           /*
>>            * Isolate the page to avoid collapsing an hugepage
>>            * currently in use by the VM.
>> @@ -2550,7 +2561,7 @@ static int khugepaged_scan_pmd(struct mm_struct
>> *mm,
>>   {
>>       pmd_t *pmd;
>>       pte_t *pte, *_pte;
>> -    int ret = 0, referenced = 0, none = 0;
>> +    int ret = 0, referenced = 0, none = 0, ro = 0;
>>       struct page *page;
>>       unsigned long _address;
>>       spinlock_t *ptl;
>> @@ -2573,8 +2584,12 @@ static int khugepaged_scan_pmd(struct mm_struct
>> *mm,
>>               else
>>                   goto out_unmap;
>>           }
>> -        if (!pte_present(pteval) || !pte_write(pteval))
>> +        if (!pte_present(pteval))
>>               goto out_unmap;
>> +        if (!pte_write(pteval)) {
>> +            if (++ro > khugepaged_max_ptes_none)
>> +                goto out_unmap;
>> +        }
>>           page = vm_normal_page(vma, _address, pteval);
>>           if (unlikely(!page))
>>               goto out_unmap;
>> @@ -2592,7 +2607,7 @@ static int khugepaged_scan_pmd(struct mm_struct
>> *mm,
>>           if (!PageLRU(page) || PageLocked(page) || !PageAnon(page))
>>               goto out_unmap;
>>           /* cannot use mapcount: can't collapse if there's a gup pin */
>> -        if (page_count(page) != 1)
>> +        if (page_count(page) != 1 + !!PageSwapCache(page))
> 
> Same as above. Even more so, as there's no other page swap cache
> handling code in this function.
> 
> Thanks.
> 
>>               goto out_unmap;
>>           if (pte_young(pteval) || PageReferenced(page) ||
>>               mmu_notifier_test_young(vma->vm_mm, address))
>>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
