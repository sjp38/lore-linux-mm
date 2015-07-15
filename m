Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 9CFE828027E
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 04:55:29 -0400 (EDT)
Received: by pachj5 with SMTP id hj5so20756545pac.3
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 01:55:29 -0700 (PDT)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id w10si6372376pdo.223.2015.07.15.01.55.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 15 Jul 2015 01:55:28 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NRI00E04U4B7B00@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 15 Jul 2015 09:55:24 +0100 (BST)
Message-id: <55A61FF8.9000603@samsung.com>
Date: Wed, 15 Jul 2015 11:55:20 +0300
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH v2 5/5] arm64: add KASan support
References: <1431698344-28054-1-git-send-email-a.ryabinin@samsung.com>
 <1431698344-28054-6-git-send-email-a.ryabinin@samsung.com>
 <20150708154803.GE6944@e104818-lin.cambridge.arm.com>
 <559FFCA7.4060008@samsung.com>
 <20150714150445.GH13555@e104818-lin.cambridge.arm.com>
In-reply-to: <20150714150445.GH13555@e104818-lin.cambridge.arm.com>
Content-type: text/plain; charset=windows-1252
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Arnd Bergmann <arnd@arndb.de>, David Keitel <dkeitel@codeaurora.org>, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-arm-kernel@lists.infradead.org

On 07/14/2015 06:04 PM, Catalin Marinas wrote:
> On Fri, Jul 10, 2015 at 08:11:03PM +0300, Andrey Ryabinin wrote:
>>>> +#if CONFIG_PGTABLE_LEVELS > 3
>>>> +pud_t kasan_zero_pud[PTRS_PER_PUD] __page_aligned_bss;
>>>> +#endif
>>>> +#if CONFIG_PGTABLE_LEVELS > 2
>>>> +pmd_t kasan_zero_pmd[PTRS_PER_PMD] __page_aligned_bss;
>>>> +#endif
>>>> +pte_t kasan_zero_pte[PTRS_PER_PTE] __page_aligned_bss;
>>>> +
>>>> +static void __init kasan_early_pmd_populate(unsigned long start,
>>>> +					unsigned long end, pud_t *pud)
>>>> +{
>>>> +	unsigned long addr;
>>>> +	unsigned long next;
>>>> +	pmd_t *pmd;
>>>> +
>>>> +	pmd = pmd_offset(pud, start);
>>>> +	for (addr = start; addr < end; addr = next, pmd++) {
>>>> +		pmd_populate_kernel(&init_mm, pmd, kasan_zero_pte);
>>>> +		next = pmd_addr_end(addr, end);
>>>> +	}
>>>> +}
>>>> +
>>>> +static void __init kasan_early_pud_populate(unsigned long start,
>>>> +					unsigned long end, pgd_t *pgd)
>>>> +{
>>>> +	unsigned long addr;
>>>> +	unsigned long next;
>>>> +	pud_t *pud;
>>>> +
>>>> +	pud = pud_offset(pgd, start);
>>>> +	for (addr = start; addr < end; addr = next, pud++) {
>>>> +		pud_populate(&init_mm, pud, kasan_zero_pmd);
>>>> +		next = pud_addr_end(addr, end);
>>>> +		kasan_early_pmd_populate(addr, next, pud);
>>>> +	}
>>>> +}
>>>> +
>>>> +static void __init kasan_map_early_shadow(pgd_t *pgdp)
>>>> +{
>>>> +	int i;
>>>> +	unsigned long start = KASAN_SHADOW_START;
>>>> +	unsigned long end = KASAN_SHADOW_END;
>>>> +	unsigned long addr;
>>>> +	unsigned long next;
>>>> +	pgd_t *pgd;
>>>> +
>>>> +	for (i = 0; i < PTRS_PER_PTE; i++)
>>>> +		set_pte(&kasan_zero_pte[i], pfn_pte(
>>>> +				virt_to_pfn(kasan_zero_page), PAGE_KERNEL));
>>>> +
>>>> +	pgd = pgd_offset_k(start);
>>>> +	for (addr = start; addr < end; addr = next, pgd++) {
>>>> +		pgd_populate(&init_mm, pgd, kasan_zero_pud);
>>>> +		next = pgd_addr_end(addr, end);
>>>> +		kasan_early_pud_populate(addr, next, pgd);
>>>> +	}
>>>
>>> I prefer to use "do ... while" constructs similar to __create_mapping()
>>> (or zero_{pgd,pud,pmd}_populate as you are more familiar with them).
>>>
>>> But what I don't get here is that you repopulate the pud page for every
>>> pgd (and so on for pmd). You don't need this recursive call all the way
>>> to kasan_early_pmd_populate() but just sequential:
>>
>> This repopulation needed for 3,2 level page tables configurations.
>>
>> E.g. for 3-level page tables we need to call pud_populate(&init_mm,
>> pud, kasan_zero_pmd) for each pud in [KASAN_SHADOW_START,
>> KASAN_SHADOW_END] range, this causes repopopulation for 4-level page
>> tables, since we need to pud_populate() only [KASAN_SHADOW_START,
>> KASAN_SHADOW_START + PGDIR_SIZE] range.
> 
> I'm referring to writing the same information multiple times over the
> same entry. kasan_map_early_shadow() goes over each pgd entry and writes
> the address of kasan_zero_pud. That's fine so far. However, in the same
> loop you call kasan_early_pud_populate(). The latter retrieves the pud
> page via pud_offset(pgd, start) which would always be kasan_zero_pud

Not always. E.g. if we have 3-level page tables pud = pgd, pgd_populate() is nop, and
pud_populate in fact populates pgd.

pud_offset(pgd, start) will return (swapper_pg_dir + pgd_index(start)) and pud_populate()
will fill that entry with the address of kasan_zero_pmd. So we need to pud_populate() for
each pgd.

> because that's what you wrote via pgd_populate() in each pgd entry. So
> for each pgd entry, you keep populating the same kasan_zero_pud page
> with pointers to kasan_zero_pmd. And so on for the pmd.
> 

Yes, I'm perfectly understand that. And this was done intentionally since I don't
see the way to make this work for all possible CONFIG_PGTABLE_LEVELS without rewrites
or without #ifdefs (and you didn't like them in v1).


>>> 	kasan_early_pte_populate();
>>> 	kasan_early_pmd_populate(..., pte);
>>> 	kasan_early_pud_populate(..., pmd);
>>> 	kasan_early_pgd_populate(..., pud);
>>>
>>> (or in reverse order)
>>
>> Unless, I'm missing something, this will either work only with 4-level
>> page tables. We could do this without repopulation by using
>> CONFIG_PGTABLE_LEVELS ifdefs.
> 
> Or you could move kasan_early_*_populate outside the loop. You already
> do this for the pte at the beginning of the kasan_map_early_shadow()
> function (and it probably makes more sense to create a separate
> kasan_early_pte_populate).
> 


Ok, let's try to implement that.
And for example, let's consider CONFIG_PGTABLE_LEVELS=3 case:

 * pgd_populate() is nop, so kasan_early_pgd_populate() won't do anything.

 * pud_populate() in kasan_early_pud_populate() actually will setup pgd entries in swapper_pg_dir,
   so pud_populate() should be called for the whole shadow range: [KASAN_SHADOW_START, KASAN_SHADOW_END]
	IOW: kasan_early_pud_populate(KASAN_SHADOW_START, KASAN_SHADOW_END, kasan_zero_pmd);
	
	We will need to slightly change kasan_early_pud_populate() implementation for that
	(Current implementation implies that [start, end) addresses belong to one pgd)

	void kasan_early_pud_populate(unsigned long start, unsigned long end, pmd_t *pmd)
	{
		unsigned long addr;
		long next;

		for (addr = start; addr < end; addr = next) {
			pud_t *pud = pud_offset(pgd_offset_k(addr), addr);
			pud_populate(&init_mm, pud, pmd);
			next = pud_addr_end(addr, pgd_addr_end(addr, end));
		}
	}

	But, wait! In 4-level page tables case this will be the same repopulation as we had before!

See? The problem here is that pud_populate() but not pgd_populate() populates pgds (3-level page tables case).
So I still don't see the way to avoid repopulation without ifdefs.
Did I miss anything?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
