Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 47EB2C10F06
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 12:38:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E9A852084C
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 12:38:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E9A852084C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 853F86B0008; Wed,  3 Apr 2019 08:38:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 803336B000A; Wed,  3 Apr 2019 08:38:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6F2526B000C; Wed,  3 Apr 2019 08:38:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1A29B6B0008
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 08:38:04 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id 41so7487328edq.0
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 05:38:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=KVoQ/lQZa4nvqmPOkmMONYpIn8a+dO6/NeedEs49mX0=;
        b=qWOtmZuI+UB569gpNzUY+qvSr+f1OysD6IIUMfJRH/3dmmQuLrs5Ct0WiNL3C1LdYk
         +AmuECBAiuDEtz6ixN1ZeWyI4l63RR1H/4zaRHBpidYddqfxhRVb5rZT1U9QijxQVsLz
         3rLfX2Qc+hfdloBO42M8UIeM5kyTe4MX/1ShE3TFDmA2yl2fwGyj8IhSs3zwztNmKlX7
         ET00l/0t79DXIx+QrJdCqTBNEj+nJrIRW8os4V6mCFukGiMQNuTgWMhTo1ypPjg+P6+S
         i68kTpGGgvJuds7f/vOCPHl2q39NvjZdq/3vkccbP7sa68xgiZENq0L8gty4OhtGD/W3
         tsWg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
X-Gm-Message-State: APjAAAWwkHV9fdEm9zYWrqG/6EGr/DFW0h2GN51F5aioNmV1XI+8jEuf
	OH8iLJL5YJmB9mEf4duycW04TnJ6woGkKpeQ/s3zbCepUBugRL3KBmm4JpYCxDcKATUbqH/tuwk
	PnhV6E/vZqLFYGWVy34tObkrf2XPZoMhUCMsdWLy7E8+u7Tp8QQca4KqalIaWMcJM6g==
X-Received: by 2002:a17:906:d0c5:: with SMTP id bq5mr30627924ejb.43.1554295083590;
        Wed, 03 Apr 2019 05:38:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz/xojMR+9QwDjwbnASZ6nfHyjF7833rzRCe64ah+ta34cVeqxL0iptwC2O4Sd9QtrMtq0i
X-Received: by 2002:a17:906:d0c5:: with SMTP id bq5mr30627853ejb.43.1554295082037;
        Wed, 03 Apr 2019 05:38:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554295082; cv=none;
        d=google.com; s=arc-20160816;
        b=hA7tRCAqFhegnyHI1EMeRH/7fPiSmPjUgX7eTAvG9ZEviWwr0cCclLZdn4Uk0xqUuR
         noiphjZtTHphon1XwHjzcbUFNYDbegGr0QDIkzo+v2UJWEenDs0LLllW0cJrNmIY0hMK
         2qmNdTzMZO9i+5KY4uUbCH1VZyDgKsm0/rRd2OHfjf9eheV1S2EUy7ci7NjTq573qb1i
         5fNfRpFDyCRnrysIhc4h9vPvii7narO7jq4rCdvJiYP+Spf/68Ibkg8ggpgOrp9uBqDb
         us7onHHc3yMyWfflHVzKy427Ar9gu7tbqPyMvvD4ooaNBuc7IGDyelzXu5zLkEf6AANQ
         n8AA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=KVoQ/lQZa4nvqmPOkmMONYpIn8a+dO6/NeedEs49mX0=;
        b=BTe77/FISrnwYqypeEJDkWoghf771l1wz3eidXlUgM8CBRodZqTjXTW9f2IJ6kg8ri
         ZWgBsCD9BVbXomMUGR3UaJW8ucJ8M8ATw7TFVaWkAn4qhMX4QnFit+f2FfzwbdI2B0Jc
         xFsEhAeJMz+kLlYd6gLv5FWc+ydlEjYUIMTOj2olA+USrYDDzffAodEj1INoRmf3lMMC
         qT1n+t4EJ55v5JRAmV5Yo2a0wD78WXqFwGcm4YkSsCILl0wYREHwYHpV7yYhi7ZeBBIi
         2/4+FfjDwcsmr4nbF5tszUVysi6pEEUO0LBvbm/Rx9KMXOzHgkf0Qh4xmVn1LFVOfLXQ
         n8ew==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id w1si4248425eju.88.2019.04.03.05.38.01
        for <linux-mm@kvack.org>;
        Wed, 03 Apr 2019 05:38:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 9CD35374;
	Wed,  3 Apr 2019 05:38:00 -0700 (PDT)
Received: from [10.1.196.75] (e110467-lin.cambridge.arm.com [10.1.196.75])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id E26993F59C;
	Wed,  3 Apr 2019 05:37:56 -0700 (PDT)
Subject: Re: [PATCH 2/6] arm64/mm: Enable memory hot remove
To: Anshuman Khandual <anshuman.khandual@arm.com>,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 linux-mm@kvack.org, akpm@linux-foundation.org, will.deacon@arm.com,
 catalin.marinas@arm.com
Cc: mhocko@suse.com, mgorman@techsingularity.net, james.morse@arm.com,
 mark.rutland@arm.com, cpandya@codeaurora.org, arunks@codeaurora.org,
 dan.j.williams@intel.com, osalvador@suse.de, logang@deltatee.com,
 pasha.tatashin@oracle.com, david@redhat.com, cai@lca.pw,
 Steven Price <steven.price@arm.com>
References: <1554265806-11501-1-git-send-email-anshuman.khandual@arm.com>
 <1554265806-11501-3-git-send-email-anshuman.khandual@arm.com>
From: Robin Murphy <robin.murphy@arm.com>
Message-ID: <ed4ceac4-b92c-47f4-33b0-ed1d0833b40d@arm.com>
Date: Wed, 3 Apr 2019 13:37:54 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <1554265806-11501-3-git-send-email-anshuman.khandual@arm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[ +Steve ]

Hi Anshuman,

On 03/04/2019 05:30, Anshuman Khandual wrote:
> Memory removal from an arch perspective involves tearing down two different
> kernel based mappings i.e vmemmap and linear while releasing related page
> table pages allocated for the physical memory range to be removed.
> 
> Define a common kernel page table tear down helper remove_pagetable() which
> can be used to unmap given kernel virtual address range. In effect it can
> tear down both vmemap or kernel linear mappings. This new helper is called
> from both vmemamp_free() and ___remove_pgd_mapping() during memory removal.
> The argument 'direct' here identifies kernel linear mappings.
> 
> Vmemmap mappings page table pages are allocated through sparse mem helper
> functions like vmemmap_alloc_block() which does not cycle the pages through
> pgtable_page_ctor() constructs. Hence while removing it skips corresponding
> destructor construct pgtable_page_dtor().
> 
> While here update arch_add_mempory() to handle __add_pages() failures by
> just unmapping recently added kernel linear mapping. Now enable memory hot
> remove on arm64 platforms by default with ARCH_ENABLE_MEMORY_HOTREMOVE.
> 
> This implementation is overall inspired from kernel page table tear down
> procedure on X86 architecture.

A bit of a nit, but since this depends on at least patch #4 to work 
properly, it would be good to reorder the series appropriately.
> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
> ---
>   arch/arm64/Kconfig               |   3 +
>   arch/arm64/include/asm/pgtable.h |  14 +++
>   arch/arm64/mm/mmu.c              | 227 ++++++++++++++++++++++++++++++++++++++-
>   3 files changed, 241 insertions(+), 3 deletions(-)
> 
> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> index a2418fb..db3e625 100644
> --- a/arch/arm64/Kconfig
> +++ b/arch/arm64/Kconfig
> @@ -266,6 +266,9 @@ config HAVE_GENERIC_GUP
>   config ARCH_ENABLE_MEMORY_HOTPLUG
>   	def_bool y
>   
> +config ARCH_ENABLE_MEMORY_HOTREMOVE
> +	def_bool y
> +
>   config ARCH_MEMORY_PROBE
>   	bool "Enable /sys/devices/system/memory/probe interface"
>   	depends on MEMORY_HOTPLUG
> diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
> index de70c1e..858098e 100644
> --- a/arch/arm64/include/asm/pgtable.h
> +++ b/arch/arm64/include/asm/pgtable.h
> @@ -355,6 +355,18 @@ static inline int pmd_protnone(pmd_t pmd)
>   }
>   #endif
>   
> +#if (CONFIG_PGTABLE_LEVELS > 2)
> +#define pmd_large(pmd)	(pmd_val(pmd) && !(pmd_val(pmd) & PMD_TABLE_BIT))
> +#else
> +#define pmd_large(pmd) 0
> +#endif
> +
> +#if (CONFIG_PGTABLE_LEVELS > 3)
> +#define pud_large(pud)	(pud_val(pud) && !(pud_val(pud) & PUD_TABLE_BIT))
> +#else
> +#define pud_large(pmd) 0
> +#endif

These seem rather different from the versions that Steve is proposing in 
the generic pagewalk series - can you reach an agreement on which 
implementation is preferred?

> +
>   /*
>    * THP definitions.
>    */
> @@ -555,6 +567,7 @@ static inline phys_addr_t pud_page_paddr(pud_t pud)
>   
>   #else
>   
> +#define pmd_index(addr) 0
>   #define pud_page_paddr(pud)	({ BUILD_BUG(); 0; })
>   
>   /* Match pmd_offset folding in <asm/generic/pgtable-nopmd.h> */
> @@ -612,6 +625,7 @@ static inline phys_addr_t pgd_page_paddr(pgd_t pgd)
>   
>   #else
>   
> +#define pud_index(adrr)	0
>   #define pgd_page_paddr(pgd)	({ BUILD_BUG(); 0;})
>   
>   /* Match pud_offset folding in <asm/generic/pgtable-nopud.h> */
> diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
> index e97f018..ae0777b 100644
> --- a/arch/arm64/mm/mmu.c
> +++ b/arch/arm64/mm/mmu.c
> @@ -714,6 +714,198 @@ int kern_addr_valid(unsigned long addr)
>   
>   	return pfn_valid(pte_pfn(pte));
>   }
> +
> +#ifdef CONFIG_MEMORY_HOTPLUG
> +static void __meminit free_pagetable(struct page *page, int order)

Do these need to be __meminit? AFAICS it's effectively redundant with 
the containing #ifdef, and removal feels like it's inherently a 
later-than-init thing anyway.

> +{
> +	unsigned long magic;
> +	unsigned int nr_pages = 1 << order;
> +
> +	if (PageReserved(page)) {
> +		__ClearPageReserved(page);
> +
> +		magic = (unsigned long)page->freelist;
> +		if (magic == SECTION_INFO || magic == MIX_SECTION_INFO) {
> +			while (nr_pages--)
> +				put_page_bootmem(page++);
> +		} else
> +			while (nr_pages--)
> +				free_reserved_page(page++);
> +	} else
> +		free_pages((unsigned long)page_address(page), order);
> +}
> +
> +#if (CONFIG_PGTABLE_LEVELS > 2)
> +static void __meminit free_pte_table(pte_t *pte_start, pmd_t *pmd, bool direct)
> +{
> +	pte_t *pte;
> +	int i;
> +
> +	for (i = 0; i < PTRS_PER_PTE; i++) {
> +		pte = pte_start + i;
> +		if (!pte_none(*pte))
> +			return;
> +	}
> +
> +	if (direct)
> +		pgtable_page_dtor(pmd_page(*pmd));
> +	free_pagetable(pmd_page(*pmd), 0);
> +	spin_lock(&init_mm.page_table_lock);
> +	pmd_clear(pmd);
> +	spin_unlock(&init_mm.page_table_lock);
> +}
> +#else
> +static void __meminit free_pte_table(pte_t *pte_start, pmd_t *pmd, bool direct)
> +{
> +}
> +#endif
> +
> +#if (CONFIG_PGTABLE_LEVELS > 3)
> +static void __meminit free_pmd_table(pmd_t *pmd_start, pud_t *pud, bool direct)
> +{
> +	pmd_t *pmd;
> +	int i;
> +
> +	for (i = 0; i < PTRS_PER_PMD; i++) {
> +		pmd = pmd_start + i;
> +		if (!pmd_none(*pmd))
> +			return;
> +	}
> +
> +	if (direct)
> +		pgtable_page_dtor(pud_page(*pud));
> +	free_pagetable(pud_page(*pud), 0);
> +	spin_lock(&init_mm.page_table_lock);
> +	pud_clear(pud);
> +	spin_unlock(&init_mm.page_table_lock);
> +}
> +
> +static void __meminit free_pud_table(pud_t *pud_start, pgd_t *pgd, bool direct)
> +{
> +	pud_t *pud;
> +	int i;
> +
> +	for (i = 0; i < PTRS_PER_PUD; i++) {
> +		pud = pud_start + i;
> +		if (!pud_none(*pud))
> +			return;
> +	}
> +
> +	if (direct)
> +		pgtable_page_dtor(pgd_page(*pgd));
> +	free_pagetable(pgd_page(*pgd), 0);
> +	spin_lock(&init_mm.page_table_lock);
> +	pgd_clear(pgd);
> +	spin_unlock(&init_mm.page_table_lock);
> +}
> +#else
> +static void __meminit free_pmd_table(pmd_t *pmd_start, pud_t *pud, bool direct)
> +{
> +}
> +
> +static void __meminit free_pud_table(pud_t *pud_start, pgd_t *pgd, bool direct)
> +{
> +}
> +#endif
> +
> +static void __meminit
> +remove_pte_table(pte_t *pte_start, unsigned long addr,
> +			unsigned long end, bool direct)
> +{
> +	pte_t *pte;
> +
> +	pte = pte_start + pte_index(addr);
> +	for (; addr < end; addr += PAGE_SIZE, pte++) {
> +		if (!pte_present(*pte))
> +			continue;
> +
> +		if (!direct)
> +			free_pagetable(pte_page(*pte), 0);
> +		spin_lock(&init_mm.page_table_lock);
> +		pte_clear(&init_mm, addr, pte);
> +		spin_unlock(&init_mm.page_table_lock);
> +	}
> +}
> +
> +static void __meminit
> +remove_pmd_table(pmd_t *pmd_start, unsigned long addr,
> +			unsigned long end, bool direct)
> +{
> +	unsigned long next;
> +	pte_t *pte_base;
> +	pmd_t *pmd;
> +
> +	pmd = pmd_start + pmd_index(addr);
> +	for (; addr < end; addr = next, pmd++) {
> +		next = pmd_addr_end(addr, end);
> +		if (!pmd_present(*pmd))
> +			continue;
> +
> +		if (pmd_large(*pmd)) {
> +			if (!direct)
> +				free_pagetable(pmd_page(*pmd),
> +						get_order(PMD_SIZE));
> +			spin_lock(&init_mm.page_table_lock);
> +			pmd_clear(pmd);
> +			spin_unlock(&init_mm.page_table_lock);
> +			continue;
> +		}
> +		pte_base = pte_offset_kernel(pmd, 0UL);
> +		remove_pte_table(pte_base, addr, next, direct);
> +		free_pte_table(pte_base, pmd, direct);
> +	}
> +}
> +
> +static void __meminit
> +remove_pud_table(pud_t *pud_start, unsigned long addr,
> +			unsigned long end, bool direct)
> +{
> +	unsigned long next;
> +	pmd_t *pmd_base;
> +	pud_t *pud;
> +
> +	pud = pud_start + pud_index(addr);
> +	for (; addr < end; addr = next, pud++) {
> +		next = pud_addr_end(addr, end);
> +		if (!pud_present(*pud))
> +			continue;
> +
> +		if (pud_large(*pud)) {
> +			if (!direct)
> +				free_pagetable(pud_page(*pud),
> +						get_order(PUD_SIZE));
> +			spin_lock(&init_mm.page_table_lock);
> +			pud_clear(pud);
> +			spin_unlock(&init_mm.page_table_lock);
> +			continue;
> +		}
> +		pmd_base = pmd_offset(pud, 0UL);
> +		remove_pmd_table(pmd_base, addr, next, direct);
> +		free_pmd_table(pmd_base, pud, direct);
> +	}
> +}
> +
> +static void __meminit
> +remove_pagetable(unsigned long start, unsigned long end, bool direct)
> +{
> +	unsigned long addr, next;
> +	pud_t *pud_base;
> +	pgd_t *pgd;
> +
> +	for (addr = start; addr < end; addr = next) {
> +		next = pgd_addr_end(addr, end);
> +		pgd = pgd_offset_k(addr);
> +		if (!pgd_present(*pgd))
> +			continue;
> +
> +		pud_base = pud_offset(pgd, 0UL);
> +		remove_pud_table(pud_base, addr, next, direct);
> +		free_pud_table(pud_base, pgd, direct);
> +	}
> +	flush_tlb_kernel_range(start, end);
> +}
> +#endif
> +
>   #ifdef CONFIG_SPARSEMEM_VMEMMAP
>   #if !ARM64_SWAPPER_USES_SECTION_MAPS
>   int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node,
> @@ -758,9 +950,12 @@ int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node,
>   	return 0;
>   }
>   #endif	/* CONFIG_ARM64_64K_PAGES */
> -void vmemmap_free(unsigned long start, unsigned long end,
> +void __ref vmemmap_free(unsigned long start, unsigned long end,

Why is the __ref needed? Presumably it's avoidable by addressing the 
__meminit thing above.

>   		struct vmem_altmap *altmap)
>   {
> +#ifdef CONFIG_MEMORY_HOTPLUG
> +	remove_pagetable(start, end, false);
> +#endif
>   }
>   #endif	/* CONFIG_SPARSEMEM_VMEMMAP */
>   
> @@ -1046,10 +1241,16 @@ int p4d_free_pud_page(p4d_t *p4d, unsigned long addr)
>   }
>   
>   #ifdef CONFIG_MEMORY_HOTPLUG
> +static void __remove_pgd_mapping(pgd_t *pgdir, unsigned long start, u64 size)
> +{
> +	WARN_ON(pgdir != init_mm.pgd);
> +	remove_pagetable(start, start + size, true);
> +}
> +
>   int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
>   		    bool want_memblock)
>   {
> -	int flags = 0;
> +	int flags = 0, ret = 0;

Initialising ret here is unnecessary.

Robin.

>   
>   	if (rodata_full || debug_pagealloc_enabled())
>   		flags = NO_BLOCK_MAPPINGS | NO_CONT_MAPPINGS;
> @@ -1057,7 +1258,27 @@ int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
>   	__create_pgd_mapping(swapper_pg_dir, start, __phys_to_virt(start),
>   			     size, PAGE_KERNEL, pgd_pgtable_alloc, flags);
>   
> -	return __add_pages(nid, start >> PAGE_SHIFT, size >> PAGE_SHIFT,
> +	ret = __add_pages(nid, start >> PAGE_SHIFT, size >> PAGE_SHIFT,
>   			   altmap, want_memblock);
> +	if (ret)
> +		__remove_pgd_mapping(swapper_pg_dir,
> +					__phys_to_virt(start), size);
> +	return ret;
>   }
> +
> +#ifdef CONFIG_MEMORY_HOTREMOVE
> +int arch_remove_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap)
> +{
> +	unsigned long start_pfn = start >> PAGE_SHIFT;
> +	unsigned long nr_pages = size >> PAGE_SHIFT;
> +	struct zone *zone = page_zone(pfn_to_page(start_pfn));
> +	int ret;
> +
> +	ret = __remove_pages(zone, start_pfn, nr_pages, altmap);
> +	if (!ret)
> +		__remove_pgd_mapping(swapper_pg_dir,
> +					__phys_to_virt(start), size);
> +	return ret;
> +}
> +#endif
>   #endif
> 

