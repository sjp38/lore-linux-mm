Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6598C6B02B4
	for <linux-mm@kvack.org>; Fri,  9 Jun 2017 05:27:17 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id a133so18550445itd.9
        for <linux-mm@kvack.org>; Fri, 09 Jun 2017 02:27:17 -0700 (PDT)
Received: from mail-it0-x22f.google.com (mail-it0-x22f.google.com. [2607:f8b0:4001:c0b::22f])
        by mx.google.com with ESMTPS id f87si521029iod.231.2017.06.09.02.27.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Jun 2017 02:27:16 -0700 (PDT)
Received: by mail-it0-x22f.google.com with SMTP id m62so134667758itc.0
        for <linux-mm@kvack.org>; Fri, 09 Jun 2017 02:27:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170609092209.GA10665@leverpostej>
References: <20170609082226.26152-1-ard.biesheuvel@linaro.org> <20170609092209.GA10665@leverpostej>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Fri, 9 Jun 2017 09:27:15 +0000
Message-ID: <CAKv+Gu_te54d9VU9AKYevkOvSpCBBeDQy5PE+PhX-t=ka3L8JA@mail.gmail.com>
Subject: Re: [PATCH v5] mm: huge-vmap: fail gracefully on unexpected huge vmap mappings
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Zhong Jiang <zhongjiang@huawei.com>, Laura Abbott <labbott@fedoraproject.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Dave Hansen <dave.hansen@intel.com>

On 9 June 2017 at 09:22, Mark Rutland <mark.rutland@arm.com> wrote:
> On Fri, Jun 09, 2017 at 08:22:26AM +0000, Ard Biesheuvel wrote:
>> Existing code that uses vmalloc_to_page() may assume that any
>> address for which is_vmalloc_addr() returns true may be passed
>> into vmalloc_to_page() to retrieve the associated struct page.
>>
>> This is not un unreasonable assumption to make, but on architectures
>> that have CONFIG_HAVE_ARCH_HUGE_VMAP=y, it no longer holds, and we
>> need to ensure that vmalloc_to_page() does not go off into the weeds
>> trying to dereference huge PUDs or PMDs as table entries.
>>
>> Given that vmalloc() and vmap() themselves never create huge
>> mappings or deal with compound pages at all, there is no correct
>> answer in this case, so return NULL instead, and issue a warning.
>>
>> Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
>> ---
>> v5: - fix typo
>>
>> v4: - use pud_bad/pmd_bad instead of pud_huge/pmd_huge, which don't require
>>       changes to hugetlb.h, and give us what we need on all architectures
>>     - move WARN_ON_ONCE() calls out of conditionals

^^^

>>     - add explanatory comment
>>
>>  mm/vmalloc.c | 15 +++++++++++++--
>>  1 file changed, 13 insertions(+), 2 deletions(-)
>>
>> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
>> index 34a1c3e46ed7..0fcd371266a4 100644
>> --- a/mm/vmalloc.c
>> +++ b/mm/vmalloc.c
>> @@ -287,10 +287,21 @@ struct page *vmalloc_to_page(const void *vmalloc_addr)
>>       if (p4d_none(*p4d))
>>               return NULL;
>>       pud = pud_offset(p4d, addr);
>> -     if (pud_none(*pud))
>> +
>> +     /*
>> +      * Don't dereference bad PUD or PMD (below) entries. This will also
>> +      * identify huge mappings, which we may encounter on architectures
>> +      * that define CONFIG_HAVE_ARCH_HUGE_VMAP=y. Such regions will be
>> +      * identified as vmalloc addresses by is_vmalloc_addr(), but are
>> +      * not [unambiguously] associated with a struct page, so there is
>> +      * no correct value to return for them.
>> +      */
>> +     WARN_ON_ONCE(pud_bad(*pud));
>> +     if (pud_none(*pud) || pud_bad(*pud))
>>               return NULL;
>
> Nit: the WARN_ON_ONCE() can be folded into the conditional:
>
>         if (pud_none(*pud) || WARN_ON_ONCE(pud_bad(*pud)))
>                 reutrn NULL;
>
>>       pmd = pmd_offset(pud, addr);
>> -     if (pmd_none(*pmd))
>> +     WARN_ON_ONCE(pmd_bad(*pmd));
>> +     if (pmd_none(*pmd) || pmd_bad(*pmd))
>>               return NULL;
>
> Likewise here.
>

Actually, it was Dave who requested them to be taken out of the conditional.

> Otherwise, looks good to me. FWIW:
>
> Acked-by: Mark Rutland <mark.rutland@arm.com>
>

Thanks,
Ard.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
