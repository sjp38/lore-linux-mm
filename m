Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4D8066B0279
	for <linux-mm@kvack.org>; Fri,  2 Jun 2017 11:11:19 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id d68so70234082ita.13
        for <linux-mm@kvack.org>; Fri, 02 Jun 2017 08:11:19 -0700 (PDT)
Received: from mail-io0-x22b.google.com (mail-io0-x22b.google.com. [2607:f8b0:4001:c06::22b])
        by mx.google.com with ESMTPS id x62si2821979itx.48.2017.06.02.08.11.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Jun 2017 08:11:18 -0700 (PDT)
Received: by mail-io0-x22b.google.com with SMTP id o12so53627515iod.3
        for <linux-mm@kvack.org>; Fri, 02 Jun 2017 08:11:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <e98368d8-b1bc-5804-2115-370ec7109e9b@intel.com>
References: <20170602112720.28948-1-ard.biesheuvel@linaro.org> <e98368d8-b1bc-5804-2115-370ec7109e9b@intel.com>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Fri, 2 Jun 2017 15:11:17 +0000
Message-ID: <CAKv+Gu964bDsV52gZ7QCJf26kXVaWgmuwXZSm0qWxa-34Eqttw@mail.gmail.com>
Subject: Re: [PATCH] mm: vmalloc: make vmalloc_to_page() deal with PMD/PUD mappings
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Ingo Molnar <mingo@kernel.org>, Laura Abbott <labbott@fedoraproject.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Zhong Jiang <zhongjiang@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Tanxiaojun <tanxiaojun@huawei.com>

On 2 June 2017 at 14:29, Dave Hansen <dave.hansen@intel.com> wrote:
> On 06/02/2017 04:27 AM, Ard Biesheuvel wrote:
>> +static struct page *vmalloc_to_pud_page(unsigned long addr, pud_t *pud)
>> +{
>> +     struct page *page = NULL;
>> +#ifdef CONFIG_HUGETLB_PAGE
>
> Do we really want this based on hugetlbfs?  Won't this be dead code on x86?
>

I don't see why one would follow from the other, but perhaps it is
better to make this depend on CONFIG_HAVE_ARCH_HUGE_VMAP instead,
which is already meant to imply that huge mappings may exist in the
vmalloc region.

> Also, don't we discourage #ifdefs in .c files?
>

Yes. But the alternative is to define a dummy huge_ptep_get(), which
is undefined otherwise. I am not sure that is better in this case. I
will try to address this more elegantly though, perhaps by folding the
huge_ptep_get() into the VIRTUAL_BUG_ON().

>> +     pte_t pte = huge_ptep_get((pte_t *)pud);
>> +
>> +     if (pte_present(pte))
>> +             page = pud_page(*pud) + ((addr & ~PUD_MASK) >> PAGE_SHIFT);
>
> x86 has pmd/pud_page().  Seems a bit silly to open-code it here.
>

So I should replace pud_page() with what exactly?

>> +#else
>> +     VIRTUAL_BUG_ON(1);
>> +#endif
>> +     return page;
>> +}
>
> So if somebody manages to call this function on a huge page table entry,
> but doesn't have hugetlbfs configured on, we kill the machine?

Yes. But only if you have CONFIG_DEBUG_VIRTUAL defined, in which case
it seems appropriate to signal a failure rather than proceed with
dereferencing the huge PMD entry as if it were a table entry.

-- 
Ard.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
