Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id C288E8E0002
	for <linux-mm@kvack.org>; Sun, 13 Jan 2019 23:14:16 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id v4so8272064edm.18
        for <linux-mm@kvack.org>; Sun, 13 Jan 2019 20:14:16 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id j6-v6si2704967ejf.66.2019.01.13.20.14.14
        for <linux-mm@kvack.org>;
        Sun, 13 Jan 2019 20:14:15 -0800 (PST)
Subject: Re: [PATCH] mm: Introduce GFP_PGTABLE
References: <1547288798-10243-1-git-send-email-anshuman.khandual@arm.com>
 <CALvZod5euX2mW7qgL28YZrTVQ-gYYR83aGKfOyZ9=BEzHwyJOw@mail.gmail.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <5e87d900-9548-1782-6244-6dcf7339139d@arm.com>
Date: Mon, 14 Jan 2019 09:44:05 +0530
MIME-Version: 1.0
In-Reply-To: <CALvZod5euX2mW7qgL28YZrTVQ-gYYR83aGKfOyZ9=BEzHwyJOw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org, linux-sh@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux@armlinux.org.uk, catalin.marinas@arm.com, will.deacon@arm.com, mpe@ellerman.id.au, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, peterz@infradead.org, christoffer.dall@arm.com, marc.zyngier@arm.com, "Kirill A. Shutemov" <kirill@shutemov.name>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.com>, ard.biesheuvel@linaro.org, mark.rutland@arm.com, steve.capper@arm.com, james.morse@arm.com, robin.murphy@arm.com, aneesh.kumar@linux.ibm.com, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>



On 01/12/2019 10:18 PM, Shakeel Butt wrote:
>> --- a/arch/x86/kernel/espfix_64.c
>> +++ b/arch/x86/kernel/espfix_64.c
>> @@ -57,8 +57,6 @@
>>  # error "Need more virtual address space for the ESPFIX hack"
>>  #endif
>>
>> -#define PGALLOC_GFP (GFP_KERNEL | __GFP_ZERO)
>> -
>>  /* This contains the *bottom* address of the espfix stack */
>>  DEFINE_PER_CPU_READ_MOSTLY(unsigned long, espfix_stack);
>>  DEFINE_PER_CPU_READ_MOSTLY(unsigned long, espfix_waddr);
>> @@ -172,7 +170,7 @@ void init_espfix_ap(int cpu)
>>         pud_p = &espfix_pud_page[pud_index(addr)];
>>         pud = *pud_p;
>>         if (!pud_present(pud)) {
>> -               struct page *page = alloc_pages_node(node, PGALLOC_GFP, 0);
>> +               struct page *page = alloc_pages_node(node, GFP_PGTABLE, 0);
>>
>>                 pmd_p = (pmd_t *)page_address(page);
>>                 pud = __pud(__pa(pmd_p) | (PGTABLE_PROT & ptemask));
>> @@ -184,7 +182,7 @@ void init_espfix_ap(int cpu)
>>         pmd_p = pmd_offset(&pud, addr);
>>         pmd = *pmd_p;
>>         if (!pmd_present(pmd)) {
>> -               struct page *page = alloc_pages_node(node, PGALLOC_GFP, 0);
>> +               struct page *page = alloc_pages_node(node, GFP_PGTABLE, 0);
>>
>>                 pte_p = (pte_t *)page_address(page);
>>                 pmd = __pmd(__pa(pte_p) | (PGTABLE_PROT & ptemask));
>> diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
>> index 7bd0170..d608b03 100644
>> --- a/arch/x86/mm/pgtable.c
>> +++ b/arch/x86/mm/pgtable.c
>> @@ -13,19 +13,17 @@ phys_addr_t physical_mask __ro_after_init = (1ULL << __PHYSICAL_MASK_SHIFT) - 1;
>>  EXPORT_SYMBOL(physical_mask);
>>  #endif
>>
>> -#define PGALLOC_GFP (GFP_KERNEL_ACCOUNT | __GFP_ZERO)
>> -
> You have silently dropped __GFP_ACCOUNT from all the allocations in this file.

Right, they need to be added back explicitly after GFP_PGTABLE. Matthew had
pointed this earlier. Will fix it next time around.

> 
> BTW why other archs not using __GFP_ACCOUNT for the user page tables?
> 

Some archs do and some dont. User page tables pages should use __GFP_ACCOUNT
for allocation. I am working on fixing it for arm64.
