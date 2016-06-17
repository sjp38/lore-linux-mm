Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id BB98F6B025E
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 11:59:33 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id a64so144458574oii.1
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 08:59:33 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id gk6si16747239pac.121.2016.06.17.08.59.32
        for <linux-mm@kvack.org>;
        Fri, 17 Jun 2016 08:59:33 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH] MADVISE_FREE, THP: Fix madvise_free_huge_pmd return value after splitting
In-Reply-To: <20160617053102.GA2374@bbox> (Minchan Kim's message of "Fri, 17
	Jun 2016 14:31:02 +0900")
References: <1466132640-18932-1-git-send-email-ying.huang@intel.com>
	<20160617053102.GA2374@bbox>
Date: Fri, 17 Jun 2016 08:59:31 -0700
Message-ID: <87inx7lsbg.fsf@yhuang-mobile.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Minchan Kim <minchan@kernel.org> writes:

> Hi,
>
> On Thu, Jun 16, 2016 at 08:03:54PM -0700, Huang, Ying wrote:
>> From: Huang Ying <ying.huang@intel.com>
>> 
>> madvise_free_huge_pmd should return 0 if the fallback PTE operations are
>> required.  In madvise_free_huge_pmd, if part pages of THP are discarded,
>> the THP will be split and fallback PTE operations should be used if
>> splitting succeeds.  But the original code will make fallback PTE
>> operations skipped, after splitting succeeds.  Fix that via make
>> madvise_free_huge_pmd return 0 after splitting successfully, so that the
>> fallback PTE operations will be done.
>
> You're right. Thanks!
>
>> 
>> Know issues: if my understanding were correct, return 1 from
>> madvise_free_huge_pmd means the following processing for the PMD should
>> be skipped, while return 0 means the following processing is still
>> needed.  So the function should return 0 only if the THP is split
>> successfully or the PMD is not trans huge.  But the pmd_trans_unstable
>> after madvise_free_huge_pmd guarantee the following processing will be
>> skipped for huge PMD.  So current code can run properly.  But if my
>> understanding were correct, we can clean up return code of
>> madvise_free_huge_pmd accordingly.
>
> I like your clean up. Just a minor comment below.
>
>> 
>> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
>> ---
>>  mm/huge_memory.c | 7 +------
>>  1 file changed, 1 insertion(+), 6 deletions(-)
>> 
>> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
>> index 2ad52d5..64dc95d 100644
>> --- a/mm/huge_memory.c
>> +++ b/mm/huge_memory.c
>
> First of all, let's change ret from int to bool.
> And then, add description in the function entry.
>
> /*
>  * Return true if we do MADV_FREE successfully on entire pmd page.
>  * Otherwise, return false.
>  */
>
> And do not set to 1 if it is huge_zero_pmd but just goto out to
> return false.

Do you want to fold the cleanup with this patch or do that in another
patch?

Best Regards,
Huang, Ying

> Thanks!
>
>> @@ -1655,14 +1655,9 @@ int madvise_free_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
>>  	if (next - addr != HPAGE_PMD_SIZE) {
>>  		get_page(page);
>>  		spin_unlock(ptl);
>> -		if (split_huge_page(page)) {
>> -			put_page(page);
>> -			unlock_page(page);
>> -			goto out_unlocked;
>> -		}
>> +		split_huge_page(page);
>>  		put_page(page);
>>  		unlock_page(page);
>> -		ret = 1;
>>  		goto out_unlocked;
>>  	}
>>  
>> -- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
