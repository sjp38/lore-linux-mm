Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id D177C6B02B4
	for <linux-mm@kvack.org>; Fri,  2 Jun 2017 12:21:56 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id z125so78262539itc.4
        for <linux-mm@kvack.org>; Fri, 02 Jun 2017 09:21:56 -0700 (PDT)
Received: from mail-it0-x22f.google.com (mail-it0-x22f.google.com. [2607:f8b0:4001:c0b::22f])
        by mx.google.com with ESMTPS id r145si2917857itc.120.2017.06.02.09.21.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Jun 2017 09:21:56 -0700 (PDT)
Received: by mail-it0-x22f.google.com with SMTP id r63so23679220itc.1
        for <linux-mm@kvack.org>; Fri, 02 Jun 2017 09:21:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <747b71d8-86a7-3b96-cf90-60d6c2ce0171@intel.com>
References: <20170602112720.28948-1-ard.biesheuvel@linaro.org>
 <e98368d8-b1bc-5804-2115-370ec7109e9b@intel.com> <CAKv+Gu964bDsV52gZ7QCJf26kXVaWgmuwXZSm0qWxa-34Eqttw@mail.gmail.com>
 <747b71d8-86a7-3b96-cf90-60d6c2ce0171@intel.com>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Fri, 2 Jun 2017 16:21:55 +0000
Message-ID: <CAKv+Gu_0cQDyRP0urZEF6OAn7cOEVH3WXL2UpDgg6wKUrWcRYA@mail.gmail.com>
Subject: Re: [PATCH] mm: vmalloc: make vmalloc_to_page() deal with PMD/PUD mappings
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Steve Capper <steve.capper@linaro.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Ingo Molnar <mingo@kernel.org>, Laura Abbott <labbott@fedoraproject.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Zhong Jiang <zhongjiang@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Tanxiaojun <tanxiaojun@huawei.com>, "Shutemov, Kirill" <kirill.shutemov@intel.com>

(apologies for the lack of patience in sending out my v2)

(+ Steve)

On 2 June 2017 at 16:03, Dave Hansen <dave.hansen@intel.com> wrote:
> On 06/02/2017 08:11 AM, Ard Biesheuvel wrote:
>>>> +     pte_t pte = huge_ptep_get((pte_t *)pud);
>>>> +
>>>> +     if (pte_present(pte))
>>>> +             page = pud_page(*pud) + ((addr & ~PUD_MASK) >> PAGE_SHIFT);
>>> x86 has pmd/pud_page().  Seems a bit silly to open-code it here.
>>>
>> So I should replace pud_page() with what exactly?
>
> Whoops, I was reading that wrong.
>
> So, the pud in this case is a huge pud pointing to data.  pud_page()
> gives us the head page, but not the base (tail) page.  The 'addr' math
> gets us that.
>
> First of all, this math isn't guaranteed to work.  We don't guarantee
> virtual contiguity for all mem_map[]s.  I think you need to go to a pfn
> or paddr first, add the pud offset, then convert to a 'struct page'.
>

OK, so you are saying the slice of the struct page array covering the
range could be discontiguous even though the physical range it
describes is contiguous? (which is guaranteed due to the nature of a
PMD mapping IIUC) In that case,

> But, what *is* the right thing to return here?  Do the users here want
> the head page or the tail page?
>

Hmm, I see what you mean. The vread() code that I am trying to fix
simply kmaps the returned page, copies from it and unmaps it, so it is
after the tail page. But I guess code that is aware of compound pages
is after the head page instead.

> BTW, _are_ your huge vmalloc pages compound?
>

Not in the case that I am trying to solve, no. They are simply VM_MAP
mappings of sequences of pages that are occupied by the kernel itself,
and not allocated by the page allocator.


>>>> +#else
>>>> +     VIRTUAL_BUG_ON(1);
>>>> +#endif
>>>> +     return page;
>>>> +}
>>> So if somebody manages to call this function on a huge page table entry,
>>> but doesn't have hugetlbfs configured on, we kill the machine?
>> Yes. But only if you have CONFIG_DEBUG_VIRTUAL defined, in which case
>> it seems appropriate to signal a failure rather than proceed with
>> dereferencing the huge PMD entry as if it were a table entry.
>
> Why kill the machine rather than just warning and returning NULL?

I know this is generally a bad thing, but in this case, when a debug
option has been enabled exactly for this purpose, I think it is not
inappropriate to BUG() when encountering such a mapping. But I am
happy to relax it to a WARN() and return NULL instead, but in that
case, it should be unconditional imo and not based on
CONFIG_DEBUG_VIRTUAL or the likes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
