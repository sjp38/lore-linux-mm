Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 667826B0010
	for <linux-mm@kvack.org>; Thu,  8 Feb 2018 07:30:49 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id r48so2289159otb.0
        for <linux-mm@kvack.org>; Thu, 08 Feb 2018 04:30:49 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id l187si1273786oig.335.2018.02.08.04.30.47
        for <linux-mm@kvack.org>;
        Thu, 08 Feb 2018 04:30:48 -0800 (PST)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: Re: [PATCH v2] mm: hwpoison: disable memory error handling on 1GB hugepage
References: <20180130013919.GA19959@hori1.linux.bs1.fc.nec.co.jp>
	<1517284444-18149-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<87inbbjx2w.fsf@e105922-lin.cambridge.arm.com>
	<20180207011455.GA15214@hori1.linux.bs1.fc.nec.co.jp>
Date: Thu, 08 Feb 2018 12:30:45 +0000
In-Reply-To: <20180207011455.GA15214@hori1.linux.bs1.fc.nec.co.jp> (Naoya
	Horiguchi's message of "Wed, 7 Feb 2018 01:14:57 +0000")
Message-ID: <87fu6bfytm.fsf@e105922-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Horiguchi-san,

Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> writes:

> Hi Punit,
>
> On Mon, Feb 05, 2018 at 03:05:43PM +0000, Punit Agrawal wrote:
>> Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> writes:
>> 

[...]

>> >
>> > You can easily reproduce this by calling madvise(MADV_HWPOISON) twice on
>> > a 1GB hugepage. This happens because get_user_pages_fast() is not aware
>> > of a migration entry on pud that was created in the 1st madvise() event.
>> 
>> Maybe I'm doing something wrong but I wasn't able to reproduce the issue
>> using the test at the end. I get -
>> 
>>     $ sudo ./hugepage
>> 
>>     Poisoning page...once
>>     [  121.295771] Injecting memory failure for pfn 0x8300000 at process virtual address 0x400000000000
>>     [  121.386450] Memory failure: 0x8300000: recovery action for huge page: Recovered
>> 
>>     Poisoning page...once again
>>     madvise: Bad address
>> 
>> What am I missing?
>
> The test program below is exactly what I intended, so you did right
> testing.

Thanks for the confirmation. And the flow outline below. 

> I try to guess what could happen. The related code is like below:
>
>   static int gup_pud_range(p4d_t p4d, unsigned long addr, unsigned long end,
>                            int write, struct page **pages, int *nr)
>   {
>           ...
>           do {
>                   pud_t pud = READ_ONCE(*pudp);
>
>                   next = pud_addr_end(addr, end);
>                   if (pud_none(pud))
>                           return 0;
>                   if (unlikely(pud_huge(pud))) {
>                           if (!gup_huge_pud(pud, pudp, addr, next, write,
>                                             pages, nr))
>                                   return 0;
>
> pud_none() always returns false for hwpoison entry in any arch.
> I guess that pud_huge() could behave in undefined manner for hwpoison entry
> because pud_huge() assumes that a given pud has the present bit set, which
> is not true for hwpoison entry.

This is where the arm64 helpers behaves differently (though more by
chance then design). A poisoned pud passes pud_huge() as it doesn't seem
to be explicitly checking for the present bit.

    int pud_huge(pud_t pud)
    {
            return pud_val(pud) && !(pud_val(pud) & PUD_TABLE_BIT);
    }


This doesn't lead to a crash as the first thing gup_huge_pud() does is
check for pud_access_permitted() which does check for the present bit.

I was able to crash the kernel by changing pud_huge() to check for the
present bit.

> As a result, pud_huge() checks an irrelevant bit used for other
> purpose depending on non-present page table format of each arch. If
> pud_huge() returns false for hwpoison entry, we try to go to the lower
> level and the kernel highly likely to crash. So I guess your kernel
> fell back the slow path and somehow ended up with returning EFAULT.

Makes sense. Due to the difference above on arm64, it ends up falling
back to the slow path which eventually returns -EFAULT (via
follow_hugetlb_page) for poisoned pages.

>
> So I don't think that the above test result means that errors are properly
> handled, and the proposed patch should help for arm64.

Although, the deviation of pud_huge() avoids a kernel crash the code
would be easier to maintain and reason about if arm64 helpers are
consistent with expectations by core code.

I'll look to update the arm64 helpers once this patch gets merged. But
it would be helpful if there was a clear expression of semantics for
pud_huge() for various cases. Is there any version that can be used as
reference?

Also, do you know what the plans are for re-enabling hugepage poisoning
disabled here?

Thanks,
Punit

[...]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
