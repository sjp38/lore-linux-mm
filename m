Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 202E36B0313
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 14:24:37 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id 29so8668214lfw.5
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 11:24:37 -0700 (PDT)
Received: from mail-lf0-x22e.google.com (mail-lf0-x22e.google.com. [2a00:1450:4010:c07::22e])
        by mx.google.com with ESMTPS id c138si1748329lfc.458.2017.06.27.11.24.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Jun 2017 11:24:35 -0700 (PDT)
Received: by mail-lf0-x22e.google.com with SMTP id h22so22084890lfk.3
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 11:24:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <87lgodl6c8.fsf@e105922-lin.cambridge.arm.com>
References: <CANaxB-zPGB8Yy9480pTFmj9HECGs3quq9Ak18aBUbx9TsNSsaw@mail.gmail.com>
 <20170624001738.GB7946@gmail.com> <20170624150824.GA19708@gmail.com>
 <bff14c53-815a-0874-5ed9-43d3f4c54ffd@suse.cz> <20170627163734.6js4jkwkwlz6xwir@black.fi.intel.com>
 <87lgodl6c8.fsf@e105922-lin.cambridge.arm.com>
From: Andrei Vagin <avagin@gmail.com>
Date: Tue, 27 Jun 2017 11:24:34 -0700
Message-ID: <CANaxB-x56KxttrijCg5f4U5286Sr=r1hDHYOnShE4Lw+3umSkQ@mail.gmail.com>
Subject: Re: linux-next: BUG: Bad page state in process ip6tables-save pfn:1499f4
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Punit Agrawal <punit.agrawal@arm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Steve Capper <steve.capper@arm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Cyrill Gorcunov <gorcunov@openvz.org>

On Tue, Jun 27, 2017 at 9:53 AM, Punit Agrawal <punit.agrawal@arm.com> wrote:
> "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> writes:
>
>> On Tue, Jun 27, 2017 at 09:18:15AM +0200, Vlastimil Babka wrote:
>>> On 06/24/2017 05:08 PM, Andrei Vagin wrote:
>>> > On Fri, Jun 23, 2017 at 05:17:44PM -0700, Andrei Vagin wrote:
>>> >> On Thu, Jun 22, 2017 at 11:21:03PM -0700, Andrei Vagin wrote:
>>> >>> Hello,
>>> >>>
>>> >>> We run CRIU tests for linux-next and today they triggered a kernel
>>> >>> bug. I want to mention that this kernel is built with kasan. This bug
>>> >>> was triggered in travis-ci. I can't reproduce it on my host. Without
>>> >>> kasan, kernel crashed but it is impossible to get a kernel log for
>>> >>> this case.
>>> >>
>>> >> We use this tree
>>> >> https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/
>>> >>
>>> >> This issue isn't reproduced on the akpm-base branch and
>>> >> it is reproduced each time on the akpm branch. I didn't
>>> >> have time today to bisect it, will do on Monday.
>>> >
>>> > c3aab7b2d4e8434d53bc81770442c14ccf0794a8 is the first bad commit
>>> >
>>> > commit c3aab7b2d4e8434d53bc81770442c14ccf0794a8
>>> > Merge: 849c34f 93a7379
>>> > Author: Stephen Rothwell
>>> > Date:   Fri Jun 23 16:40:07 2017 +1000
>>> >
>>> >     Merge branch 'akpm-current/current'
>>>
>>> Hm is it really the merge of mmotm itself and not one of the patches in
>>> mmotm?
>>> Anyway smells like THP, adding Kirill.
>>
>> Okay, it took a while to figure it out.
>
> I'm sorry you had to go chasing for this one again.
>
> I'd found the same issue while investigating an ltp failure on arm64[0] and
> sent a fix[1]. The fix is effectively the same as your patch below.
>
> Andrew picked up the patch from v5 posting and I can see it in today's
> next[2].

Our tests passed on today's next:
https://travis-ci.org/avagin/criu/jobs/247377006

Thanks,
Andrei

>
>
> [0] http://lists.infradead.org/pipermail/linux-arm-kernel/2017-June/510318.html
> [1] https://patchwork.kernel.org/patch/9766193/
> [2] https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/commit/mm/gup.c?h=next-20170627&id=d31945b5d4ab4490fb5f961dd5b066cc9f560eb3
>
>>
>> The bug is in patch "mm, gup: ensure real head page is ref-counted when
>> using hugepages". We should look for a head *before* the loop. Otherwise
>> 'page' may point to the first page beyond the compound page.
>>
>> The patch below should help.
>>
>> If no objections, Andrew, could you fold it into the problematic patch?
>>
>> diff --git a/mm/gup.c b/mm/gup.c
>> index d8db6e5016a8..6f9ca86b3d03 100644
>> --- a/mm/gup.c
>> +++ b/mm/gup.c
>> @@ -1424,6 +1424,7 @@ static int gup_huge_pmd(pmd_t orig, pmd_t *pmdp, unsigned long addr,
>>
>>       refs = 0;
>>       page = pmd_page(orig) + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
>> +     head = compound_head(page);
>>       do {
>>               pages[*nr] = page;
>>               (*nr)++;
>> @@ -1431,7 +1432,6 @@ static int gup_huge_pmd(pmd_t orig, pmd_t *pmdp, unsigned long addr,
>>               refs++;
>>       } while (addr += PAGE_SIZE, addr != end);
>>
>> -     head = compound_head(page);
>>       if (!page_cache_add_speculative(head, refs)) {
>>               *nr -= refs;
>>               return 0;
>> @@ -1462,6 +1462,7 @@ static int gup_huge_pud(pud_t orig, pud_t *pudp, unsigned long addr,
>>
>>       refs = 0;
>>       page = pud_page(orig) + ((addr & ~PUD_MASK) >> PAGE_SHIFT);
>> +     head = compound_head(page);
>>       do {
>>               pages[*nr] = page;
>>               (*nr)++;
>> @@ -1469,7 +1470,6 @@ static int gup_huge_pud(pud_t orig, pud_t *pudp, unsigned long addr,
>>               refs++;
>>       } while (addr += PAGE_SIZE, addr != end);
>>
>> -     head = compound_head(page);
>>       if (!page_cache_add_speculative(head, refs)) {
>>               *nr -= refs;
>>               return 0;
>> @@ -1499,6 +1499,7 @@ static int gup_huge_pgd(pgd_t orig, pgd_t *pgdp, unsigned long addr,
>>       BUILD_BUG_ON(pgd_devmap(orig));
>>       refs = 0;
>>       page = pgd_page(orig) + ((addr & ~PGDIR_MASK) >> PAGE_SHIFT);
>> +     head = compound_head(page);
>>       do {
>>               pages[*nr] = page;
>>               (*nr)++;
>> @@ -1506,7 +1507,6 @@ static int gup_huge_pgd(pgd_t orig, pgd_t *pgdp, unsigned long addr,
>>               refs++;
>>       } while (addr += PAGE_SIZE, addr != end);
>>
>> -     head = compound_head(page);
>>       if (!page_cache_add_speculative(head, refs)) {
>>               *nr -= refs;
>>               return 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
