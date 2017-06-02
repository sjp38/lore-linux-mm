Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id C0AA36B02B4
	for <linux-mm@kvack.org>; Fri,  2 Jun 2017 12:03:37 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id p74so80324368pfd.11
        for <linux-mm@kvack.org>; Fri, 02 Jun 2017 09:03:37 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id 203si23587332pfu.4.2017.06.02.09.03.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Jun 2017 09:03:36 -0700 (PDT)
Subject: Re: [PATCH] mm: vmalloc: make vmalloc_to_page() deal with PMD/PUD
 mappings
References: <20170602112720.28948-1-ard.biesheuvel@linaro.org>
 <e98368d8-b1bc-5804-2115-370ec7109e9b@intel.com>
 <CAKv+Gu964bDsV52gZ7QCJf26kXVaWgmuwXZSm0qWxa-34Eqttw@mail.gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <747b71d8-86a7-3b96-cf90-60d6c2ce0171@intel.com>
Date: Fri, 2 Jun 2017 09:03:34 -0700
MIME-Version: 1.0
In-Reply-To: <CAKv+Gu964bDsV52gZ7QCJf26kXVaWgmuwXZSm0qWxa-34Eqttw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Ingo Molnar <mingo@kernel.org>, Laura Abbott <labbott@fedoraproject.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Zhong Jiang <zhongjiang@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Tanxiaojun <tanxiaojun@huawei.com>, "Shutemov, Kirill" <kirill.shutemov@intel.com>

On 06/02/2017 08:11 AM, Ard Biesheuvel wrote:
>>> +     pte_t pte = huge_ptep_get((pte_t *)pud);
>>> +
>>> +     if (pte_present(pte))
>>> +             page = pud_page(*pud) + ((addr & ~PUD_MASK) >> PAGE_SHIFT);
>> x86 has pmd/pud_page().  Seems a bit silly to open-code it here.
>>
> So I should replace pud_page() with what exactly?

Whoops, I was reading that wrong.

So, the pud in this case is a huge pud pointing to data.  pud_page()
gives us the head page, but not the base (tail) page.  The 'addr' math
gets us that.

First of all, this math isn't guaranteed to work.  We don't guarantee
virtual contiguity for all mem_map[]s.  I think you need to go to a pfn
or paddr first, add the pud offset, then convert to a 'struct page'.

But, what *is* the right thing to return here?  Do the users here want
the head page or the tail page?

BTW, _are_ your huge vmalloc pages compound?

>>> +#else
>>> +     VIRTUAL_BUG_ON(1);
>>> +#endif
>>> +     return page;
>>> +}
>> So if somebody manages to call this function on a huge page table entry,
>> but doesn't have hugetlbfs configured on, we kill the machine?
> Yes. But only if you have CONFIG_DEBUG_VIRTUAL defined, in which case
> it seems appropriate to signal a failure rather than proceed with
> dereferencing the huge PMD entry as if it were a table entry.

Why kill the machine rather than just warning and returning NULL?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
