Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9693B6B0279
	for <linux-mm@kvack.org>; Thu,  8 Jun 2017 09:12:20 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id p77so11408376ioe.11
        for <linux-mm@kvack.org>; Thu, 08 Jun 2017 06:12:20 -0700 (PDT)
Received: from mail-it0-x22b.google.com (mail-it0-x22b.google.com. [2607:f8b0:4001:c0b::22b])
        by mx.google.com with ESMTPS id 86si5198818iok.178.2017.06.08.06.12.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Jun 2017 06:12:19 -0700 (PDT)
Received: by mail-it0-x22b.google.com with SMTP id m62so124118274itc.0
        for <linux-mm@kvack.org>; Thu, 08 Jun 2017 06:12:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170608125946.GD5765@leverpostej>
References: <20170608113548.24905-1-ard.biesheuvel@linaro.org> <20170608125946.GD5765@leverpostej>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Thu, 8 Jun 2017 13:12:18 +0000
Message-ID: <CAKv+Gu-vNAHwWJZoN9w3ABDu2--8KWZtv5OPxFP5sDeJeZm-xw@mail.gmail.com>
Subject: Re: [PATCH v3] mm: huge-vmap: fail gracefully on unexpected huge vmap mappings
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Zhong Jiang <zhongjiang@huawei.com>, Laura Abbott <labbott@fedoraproject.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On 8 June 2017 at 12:59, Mark Rutland <mark.rutland@arm.com> wrote:
> On Thu, Jun 08, 2017 at 11:35:48AM +0000, Ard Biesheuvel wrote:
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
>> value to return in this case, so return NULL instead, and issue a
>> warning.
>>
>> Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
>> ---
>> This is a followup to '[PATCH v2] mm: vmalloc: make vmalloc_to_page()
>> deal with PMD/PUD mappings', hence the v3. The root issue with /proc/kcore
>> on arm64 is now handled by '[PATCH] mm: vmalloc: simplify vread/vwrite to
>> use existing mappings' [1], and this patch now only complements it by
>> taking care of other vmalloc_to_page() users.
>>
>> [0] http://marc.info/?l=linux-mm&m=149641886821855&w=2
>> [1] http://marc.info/?l=linux-mm&m=149685966530180&w=2
>>
>>  include/linux/hugetlb.h | 13 +++++++++----
>>  mm/vmalloc.c            |  5 +++--
>>  2 files changed, 12 insertions(+), 6 deletions(-)
>>
>> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
>> index b857fc8cc2ec..b7166e5426b6 100644
>> --- a/include/linux/hugetlb.h
>> +++ b/include/linux/hugetlb.h
>> @@ -121,8 +121,6 @@ struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
>>                               pmd_t *pmd, int flags);
>>  struct page *follow_huge_pud(struct mm_struct *mm, unsigned long address,
>>                               pud_t *pud, int flags);
>> -int pmd_huge(pmd_t pmd);
>> -int pud_huge(pud_t pud);
>>  unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
>>               unsigned long address, unsigned long end, pgprot_t newprot);
>>
>> @@ -150,8 +148,6 @@ static inline void hugetlb_show_meminfo(void)
>>  #define follow_huge_pmd(mm, addr, pmd, flags)        NULL
>>  #define follow_huge_pud(mm, addr, pud, flags)        NULL
>>  #define prepare_hugepage_range(file, addr, len)      (-EINVAL)
>> -#define pmd_huge(x)  0
>> -#define pud_huge(x)  0
>>  #define is_hugepage_only_range(mm, addr, len)        0
>>  #define hugetlb_free_pgd_range(tlb, addr, end, floor, ceiling) ({BUG(); 0; })
>>  #define hugetlb_fault(mm, vma, addr, flags)  ({ BUG(); 0; })
>> @@ -190,6 +186,15 @@ static inline void __unmap_hugepage_range(struct mmu_gather *tlb,
>>  }
>>
>>  #endif /* !CONFIG_HUGETLB_PAGE */
>> +
>> +#if defined(CONFIG_HUGETLB_PAGE) || defined(CONFIG_HAVE_ARCH_HUGE_VMAP)
>> +int pmd_huge(pmd_t pmd);
>> +int pud_huge(pud_t pud);
>> +#else
>> +#define pmd_huge(x)  0
>> +#define pud_huge(x)  0
>> +#endif
>> +
>>  /*
>>   * hugepages at page global directory. If arch support
>>   * hugepages at pgd level, they need to define this.
>> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
>> index 982d29511f92..67e1a304c467 100644
>> --- a/mm/vmalloc.c
>> +++ b/mm/vmalloc.c
>> @@ -12,6 +12,7 @@
>>  #include <linux/mm.h>
>>  #include <linux/module.h>
>>  #include <linux/highmem.h>
>> +#include <linux/hugetlb.h>
>>  #include <linux/sched/signal.h>
>>  #include <linux/slab.h>
>>  #include <linux/spinlock.h>
>> @@ -287,10 +288,10 @@ struct page *vmalloc_to_page(const void *vmalloc_addr)
>>       if (p4d_none(*p4d))
>>               return NULL;
>>       pud = pud_offset(p4d, addr);
>> -     if (pud_none(*pud))
>> +     if (pud_none(*pud) || WARN_ON_ONCE(pud_huge(*pud)))
>>               return NULL;
>>       pmd = pmd_offset(pud, addr);
>> -     if (pmd_none(*pmd))
>> +     if (pmd_none(*pmd) || WARN_ON_ONCE(pmd_huge(*pmd)))
>>               return NULL;
>
> I think it might be better to use p*d_bad() here, since that doesn't
> depend on CONFIG_HUGETLB_PAGE.
>
> While the cross-arch semantics are a little fuzzy, my understanding is
> those should return true if an entry is not a pointer to a next level of
> table (so pXd_huge(p) implies pXd_bad(p)).
>

Fair enough. It is slightly counter intuitive, but I guess this is due
to historical reasons, and is unlikely to change in the future.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
