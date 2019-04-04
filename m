Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4D3C2C10F0C
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 05:39:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EF2AD2075E
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 05:39:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EF2AD2075E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8B4DE6B000D; Thu,  4 Apr 2019 01:39:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 865366B000E; Thu,  4 Apr 2019 01:39:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 72D586B0266; Thu,  4 Apr 2019 01:39:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 19D096B000D
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 01:39:31 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id k8so740293edl.22
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 22:39:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=5qrh7GruoCtv/pc/lvb9zht1sjrDm5cJOYSs1bqJ2p8=;
        b=MX139eCnJlHl19D0ytxiPIspJk7vjllHcOfMKXAojV0+nPNCBDf1du727Pg26nyJX0
         GSgIYyla1sJmgbwpmc/PE438rhFV3WfiGnAubfRHLA3bEwWLHQiYFhw4AE3L/f9BknaL
         loZNvGP+deaYH84ZhSa4vzk3++l8cF4gciiBB9Gv7nXj+GA11ecwSdkb//eAO22uIKii
         2Ks9MnCXQ9EBi5W70sd5eIljFBvSVPPxhzU1ZTvWLGftnqdjcId4rQXrIBNFl9ZKSvLt
         faz7y8kRe6zs4h6fZaeX9WQsYIuNnSZ3uch+P0VpOnbMmrorCEGyxM6iiJwSqRLl1yWh
         m+cQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAURGg1/m7J1/L/mPzssBjz15pu7ZITkEuKzwlVZzjn6TEEOFkq9
	l+TV7IZ5i4dfxe3QadE8TIMMs1MHPR3E3ZiWS1voetj32Jj8/e8haHregzzpkSF7L/c4rwamd+c
	asz03hCCTyy7HdRAEMPnGySotaqUmgCE9aRCoSNuX3QDmZgsILVPasyESjAqQp8Ea7w==
X-Received: by 2002:a50:b1fa:: with SMTP id n55mr2484404edd.34.1554356370622;
        Wed, 03 Apr 2019 22:39:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxZczMB8d7aguG9ZBAHyPel08xNIMaMPDeYxP/pSG3n4J4D6a8rmHP6na31XLiJqja9NOIs
X-Received: by 2002:a50:b1fa:: with SMTP id n55mr2484349edd.34.1554356369365;
        Wed, 03 Apr 2019 22:39:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554356369; cv=none;
        d=google.com; s=arc-20160816;
        b=h+U8nN92qD0qEbb3Tfplq4bkzJcgCyVOgpAbPlG4f1+TuaKHkj0eFCJ/DR4KPfXPt6
         P/CRoKiH+EYZclnaQU3s/q60HyQywuEJGHyZeMyPSCoDUwt3wlLW9qNYVHl2lE60KKcC
         5BeJg6aMV5YmRZIzDjerYjWvUWHeX2BZrkfgc/O2kVanSEIuXua+tBNmfc9kM0Z4n4WI
         M15Cb8PLwQkyfABeIG4Uk6hNI03IU57fK6Dv7YsiEOoa/kA5HVdFPSWE8opMj7k3qJoR
         IoJ0R0nFlvwha4CGEMFMzxIPHt4ezZl5+KBY6/VSdzIR0ykqCndjeZo4m82c80lit8RT
         MEag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=5qrh7GruoCtv/pc/lvb9zht1sjrDm5cJOYSs1bqJ2p8=;
        b=SWIWlHFZb5u/e6aihEbOiszV7si1Z/lvPvOcNBLyUsouuFLlfRc/byo/NcPIofuuw8
         oJHOT29ip4nVi2MAV4nr7+YP9tsrZifrSzhnTvqBPl151WNBU+Rt76x6l0meUUL4s/o8
         lxUDIjTGqhWl9txegYOprYok51RrO7yDBiHaURVpeG+Q91ctzMBQAHmVYUqM4KWAkkp7
         wh1VXVM7AQCu+RK1QifIWhnng0EX1HB0HyYj0LAgpXxuUQ/qS4Y3MtSNbPS0iNd4hruc
         /UqSjAelq2QmstNuUw9Y3Kbs+7FQ2neumc9be2XM6DonuqPPS8B5qkePIK0TMJ4RU6vY
         OQTA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id x7si6370167ejb.77.2019.04.03.22.39.27
        for <linux-mm@kvack.org>;
        Wed, 03 Apr 2019 22:39:28 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 368E780D;
	Wed,  3 Apr 2019 22:39:27 -0700 (PDT)
Received: from [10.162.40.100] (p8cg001049571a15.blr.arm.com [10.162.40.100])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 2BC743F721;
	Wed,  3 Apr 2019 22:39:20 -0700 (PDT)
Subject: Re: [PATCH 2/6] arm64/mm: Enable memory hot remove
To: Robin Murphy <robin.murphy@arm.com>, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
 akpm@linux-foundation.org, will.deacon@arm.com, catalin.marinas@arm.com
Cc: mhocko@suse.com, mgorman@techsingularity.net, james.morse@arm.com,
 mark.rutland@arm.com, cpandya@codeaurora.org, arunks@codeaurora.org,
 dan.j.williams@intel.com, osalvador@suse.de, logang@deltatee.com,
 pasha.tatashin@oracle.com, david@redhat.com, cai@lca.pw,
 Steven Price <steven.price@arm.com>
References: <1554265806-11501-1-git-send-email-anshuman.khandual@arm.com>
 <1554265806-11501-3-git-send-email-anshuman.khandual@arm.com>
 <ed4ceac4-b92c-47f4-33b0-ed1d0833b40d@arm.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <55278a57-39bc-be27-5999-81d0da37b746@arm.com>
Date: Thu, 4 Apr 2019 11:09:22 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <ed4ceac4-b92c-47f4-33b0-ed1d0833b40d@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 04/03/2019 06:07 PM, Robin Murphy wrote:
> [ +Steve ]
> 
> Hi Anshuman,
> 
> On 03/04/2019 05:30, Anshuman Khandual wrote:
>> Memory removal from an arch perspective involves tearing down two different
>> kernel based mappings i.e vmemmap and linear while releasing related page
>> table pages allocated for the physical memory range to be removed.
>>
>> Define a common kernel page table tear down helper remove_pagetable() which
>> can be used to unmap given kernel virtual address range. In effect it can
>> tear down both vmemap or kernel linear mappings. This new helper is called
>> from both vmemamp_free() and ___remove_pgd_mapping() during memory removal.
>> The argument 'direct' here identifies kernel linear mappings.
>>
>> Vmemmap mappings page table pages are allocated through sparse mem helper
>> functions like vmemmap_alloc_block() which does not cycle the pages through
>> pgtable_page_ctor() constructs. Hence while removing it skips corresponding
>> destructor construct pgtable_page_dtor().
>>
>> While here update arch_add_mempory() to handle __add_pages() failures by
>> just unmapping recently added kernel linear mapping. Now enable memory hot
>> remove on arm64 platforms by default with ARCH_ENABLE_MEMORY_HOTREMOVE.
>>
>> This implementation is overall inspired from kernel page table tear down
>> procedure on X86 architecture.
> 
> A bit of a nit, but since this depends on at least patch #4 to work properly, it would be good to reorder the series appropriately.

Sure will move up the generic changes forward.

>> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
>> ---
>>   arch/arm64/Kconfig               |   3 +
>>   arch/arm64/include/asm/pgtable.h |  14 +++
>>   arch/arm64/mm/mmu.c              | 227 ++++++++++++++++++++++++++++++++++++++-
>>   3 files changed, 241 insertions(+), 3 deletions(-)
>>
>> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
>> index a2418fb..db3e625 100644
>> --- a/arch/arm64/Kconfig
>> +++ b/arch/arm64/Kconfig
>> @@ -266,6 +266,9 @@ config HAVE_GENERIC_GUP
>>   config ARCH_ENABLE_MEMORY_HOTPLUG
>>       def_bool y
>>   +config ARCH_ENABLE_MEMORY_HOTREMOVE
>> +    def_bool y
>> +
>>   config ARCH_MEMORY_PROBE
>>       bool "Enable /sys/devices/system/memory/probe interface"
>>       depends on MEMORY_HOTPLUG
>> diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
>> index de70c1e..858098e 100644
>> --- a/arch/arm64/include/asm/pgtable.h
>> +++ b/arch/arm64/include/asm/pgtable.h
>> @@ -355,6 +355,18 @@ static inline int pmd_protnone(pmd_t pmd)
>>   }
>>   #endif
>>   +#if (CONFIG_PGTABLE_LEVELS > 2)
>> +#define pmd_large(pmd)    (pmd_val(pmd) && !(pmd_val(pmd) & PMD_TABLE_BIT))
>> +#else
>> +#define pmd_large(pmd) 0
>> +#endif
>> +
>> +#if (CONFIG_PGTABLE_LEVELS > 3)
>> +#define pud_large(pud)    (pud_val(pud) && !(pud_val(pud) & PUD_TABLE_BIT))
>> +#else
>> +#define pud_large(pmd) 0
>> +#endif
> 
> These seem rather different from the versions that Steve is proposing in the generic pagewalk series - can you reach an agreement on which implementation is preferred?

Sure will take a look.

> 
>> +
>>   /*
>>    * THP definitions.
>>    */
>> @@ -555,6 +567,7 @@ static inline phys_addr_t pud_page_paddr(pud_t pud)
>>     #else
>>   +#define pmd_index(addr) 0
>>   #define pud_page_paddr(pud)    ({ BUILD_BUG(); 0; })
>>     /* Match pmd_offset folding in <asm/generic/pgtable-nopmd.h> */
>> @@ -612,6 +625,7 @@ static inline phys_addr_t pgd_page_paddr(pgd_t pgd)
>>     #else
>>   +#define pud_index(adrr)    0
>>   #define pgd_page_paddr(pgd)    ({ BUILD_BUG(); 0;})
>>     /* Match pud_offset folding in <asm/generic/pgtable-nopud.h> */
>> diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
>> index e97f018..ae0777b 100644
>> --- a/arch/arm64/mm/mmu.c
>> +++ b/arch/arm64/mm/mmu.c
>> @@ -714,6 +714,198 @@ int kern_addr_valid(unsigned long addr)
>>         return pfn_valid(pte_pfn(pte));
>>   }
>> +
>> +#ifdef CONFIG_MEMORY_HOTPLUG
>> +static void __meminit free_pagetable(struct page *page, int order)
> 
> Do these need to be __meminit? AFAICS it's effectively redundant with the containing #ifdef, and removal feels like it's inherently a later-than-init thing anyway.

I was confused here a bit but even X86 does exactly the same. All these functions
are still labeled __meminit and all wrapped under CONFIG_MEMORY_HOTPLUG. Is there
any concern to have __meminit here ?

> 
>> +{
>> +    unsigned long magic;
>> +    unsigned int nr_pages = 1 << order;
>> +
>> +    if (PageReserved(page)) {
>> +        __ClearPageReserved(page);
>> +
>> +        magic = (unsigned long)page->freelist;
>> +        if (magic == SECTION_INFO || magic == MIX_SECTION_INFO) {
>> +            while (nr_pages--)
>> +                put_page_bootmem(page++);
>> +        } else
>> +            while (nr_pages--)
>> +                free_reserved_page(page++);
>> +    } else
>> +        free_pages((unsigned long)page_address(page), order);
>> +}
>> +
>> +#if (CONFIG_PGTABLE_LEVELS > 2)
>> +static void __meminit free_pte_table(pte_t *pte_start, pmd_t *pmd, bool direct)
>> +{
>> +    pte_t *pte;
>> +    int i;
>> +
>> +    for (i = 0; i < PTRS_PER_PTE; i++) {
>> +        pte = pte_start + i;
>> +        if (!pte_none(*pte))
>> +            return;
>> +    }
>> +
>> +    if (direct)
>> +        pgtable_page_dtor(pmd_page(*pmd));
>> +    free_pagetable(pmd_page(*pmd), 0);
>> +    spin_lock(&init_mm.page_table_lock);
>> +    pmd_clear(pmd);
>> +    spin_unlock(&init_mm.page_table_lock);
>> +}
>> +#else
>> +static void __meminit free_pte_table(pte_t *pte_start, pmd_t *pmd, bool direct)
>> +{
>> +}
>> +#endif
>> +
>> +#if (CONFIG_PGTABLE_LEVELS > 3)
>> +static void __meminit free_pmd_table(pmd_t *pmd_start, pud_t *pud, bool direct)
>> +{
>> +    pmd_t *pmd;
>> +    int i;
>> +
>> +    for (i = 0; i < PTRS_PER_PMD; i++) {
>> +        pmd = pmd_start + i;
>> +        if (!pmd_none(*pmd))
>> +            return;
>> +    }
>> +
>> +    if (direct)
>> +        pgtable_page_dtor(pud_page(*pud));
>> +    free_pagetable(pud_page(*pud), 0);
>> +    spin_lock(&init_mm.page_table_lock);
>> +    pud_clear(pud);
>> +    spin_unlock(&init_mm.page_table_lock);
>> +}
>> +
>> +static void __meminit free_pud_table(pud_t *pud_start, pgd_t *pgd, bool direct)
>> +{
>> +    pud_t *pud;
>> +    int i;
>> +
>> +    for (i = 0; i < PTRS_PER_PUD; i++) {
>> +        pud = pud_start + i;
>> +        if (!pud_none(*pud))
>> +            return;
>> +    }
>> +
>> +    if (direct)
>> +        pgtable_page_dtor(pgd_page(*pgd));
>> +    free_pagetable(pgd_page(*pgd), 0);
>> +    spin_lock(&init_mm.page_table_lock);
>> +    pgd_clear(pgd);
>> +    spin_unlock(&init_mm.page_table_lock);
>> +}
>> +#else
>> +static void __meminit free_pmd_table(pmd_t *pmd_start, pud_t *pud, bool direct)
>> +{
>> +}
>> +
>> +static void __meminit free_pud_table(pud_t *pud_start, pgd_t *pgd, bool direct)
>> +{
>> +}
>> +#endif
>> +
>> +static void __meminit
>> +remove_pte_table(pte_t *pte_start, unsigned long addr,
>> +            unsigned long end, bool direct)
>> +{
>> +    pte_t *pte;
>> +
>> +    pte = pte_start + pte_index(addr);
>> +    for (; addr < end; addr += PAGE_SIZE, pte++) {
>> +        if (!pte_present(*pte))
>> +            continue;
>> +
>> +        if (!direct)
>> +            free_pagetable(pte_page(*pte), 0);
>> +        spin_lock(&init_mm.page_table_lock);
>> +        pte_clear(&init_mm, addr, pte);
>> +        spin_unlock(&init_mm.page_table_lock);
>> +    }
>> +}
>> +
>> +static void __meminit
>> +remove_pmd_table(pmd_t *pmd_start, unsigned long addr,
>> +            unsigned long end, bool direct)
>> +{
>> +    unsigned long next;
>> +    pte_t *pte_base;
>> +    pmd_t *pmd;
>> +
>> +    pmd = pmd_start + pmd_index(addr);
>> +    for (; addr < end; addr = next, pmd++) {
>> +        next = pmd_addr_end(addr, end);
>> +        if (!pmd_present(*pmd))
>> +            continue;
>> +
>> +        if (pmd_large(*pmd)) {
>> +            if (!direct)
>> +                free_pagetable(pmd_page(*pmd),
>> +                        get_order(PMD_SIZE));
>> +            spin_lock(&init_mm.page_table_lock);
>> +            pmd_clear(pmd);
>> +            spin_unlock(&init_mm.page_table_lock);
>> +            continue;
>> +        }
>> +        pte_base = pte_offset_kernel(pmd, 0UL);
>> +        remove_pte_table(pte_base, addr, next, direct);
>> +        free_pte_table(pte_base, pmd, direct);
>> +    }
>> +}
>> +
>> +static void __meminit
>> +remove_pud_table(pud_t *pud_start, unsigned long addr,
>> +            unsigned long end, bool direct)
>> +{
>> +    unsigned long next;
>> +    pmd_t *pmd_base;
>> +    pud_t *pud;
>> +
>> +    pud = pud_start + pud_index(addr);
>> +    for (; addr < end; addr = next, pud++) {
>> +        next = pud_addr_end(addr, end);
>> +        if (!pud_present(*pud))
>> +            continue;
>> +
>> +        if (pud_large(*pud)) {
>> +            if (!direct)
>> +                free_pagetable(pud_page(*pud),
>> +                        get_order(PUD_SIZE));
>> +            spin_lock(&init_mm.page_table_lock);
>> +            pud_clear(pud);
>> +            spin_unlock(&init_mm.page_table_lock);
>> +            continue;
>> +        }
>> +        pmd_base = pmd_offset(pud, 0UL);
>> +        remove_pmd_table(pmd_base, addr, next, direct);
>> +        free_pmd_table(pmd_base, pud, direct);
>> +    }
>> +}
>> +
>> +static void __meminit
>> +remove_pagetable(unsigned long start, unsigned long end, bool direct)
>> +{
>> +    unsigned long addr, next;
>> +    pud_t *pud_base;
>> +    pgd_t *pgd;
>> +
>> +    for (addr = start; addr < end; addr = next) {
>> +        next = pgd_addr_end(addr, end);
>> +        pgd = pgd_offset_k(addr);
>> +        if (!pgd_present(*pgd))
>> +            continue;
>> +
>> +        pud_base = pud_offset(pgd, 0UL);
>> +        remove_pud_table(pud_base, addr, next, direct);
>> +        free_pud_table(pud_base, pgd, direct);
>> +    }
>> +    flush_tlb_kernel_range(start, end);
>> +}
>> +#endif
>> +
>>   #ifdef CONFIG_SPARSEMEM_VMEMMAP
>>   #if !ARM64_SWAPPER_USES_SECTION_MAPS
>>   int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node,
>> @@ -758,9 +950,12 @@ int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node,
>>       return 0;
>>   }
>>   #endif    /* CONFIG_ARM64_64K_PAGES */
>> -void vmemmap_free(unsigned long start, unsigned long end,
>> +void __ref vmemmap_free(unsigned long start, unsigned long end,
> 
> Why is the __ref needed? Presumably it's avoidable by addressing the __meminit thing above.

Right.

> 
>>           struct vmem_altmap *altmap)
>>   {
>> +#ifdef CONFIG_MEMORY_HOTPLUG
>> +    remove_pagetable(start, end, false);
>> +#endif
>>   }
>>   #endif    /* CONFIG_SPARSEMEM_VMEMMAP */
>>   @@ -1046,10 +1241,16 @@ int p4d_free_pud_page(p4d_t *p4d, unsigned long addr)
>>   }
>>     #ifdef CONFIG_MEMORY_HOTPLUG
>> +static void __remove_pgd_mapping(pgd_t *pgdir, unsigned long start, u64 size)
>> +{
>> +    WARN_ON(pgdir != init_mm.pgd);
>> +    remove_pagetable(start, start + size, true);
>> +}
>> +
>>   int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
>>               bool want_memblock)
>>   {
>> -    int flags = 0;
>> +    int flags = 0, ret = 0;
> 
> Initialising ret here is unnecessary.

Sure. Will change.

