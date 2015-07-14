Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 21CB7280246
	for <linux-mm@kvack.org>; Tue, 14 Jul 2015 11:04:52 -0400 (EDT)
Received: by pdbep18 with SMTP id ep18so7615137pdb.1
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 08:04:51 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id qa6si2249252pab.102.2015.07.14.08.04.50
        for <linux-mm@kvack.org>;
        Tue, 14 Jul 2015 08:04:51 -0700 (PDT)
Date: Tue, 14 Jul 2015 16:04:45 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v2 5/5] arm64: add KASan support
Message-ID: <20150714150445.GH13555@e104818-lin.cambridge.arm.com>
References: <1431698344-28054-1-git-send-email-a.ryabinin@samsung.com>
 <1431698344-28054-6-git-send-email-a.ryabinin@samsung.com>
 <20150708154803.GE6944@e104818-lin.cambridge.arm.com>
 <559FFCA7.4060008@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <559FFCA7.4060008@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: Arnd Bergmann <arnd@arndb.de>, David Keitel <dkeitel@codeaurora.org>, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-arm-kernel@lists.infradead.org

On Fri, Jul 10, 2015 at 08:11:03PM +0300, Andrey Ryabinin wrote:
> >> +#if CONFIG_PGTABLE_LEVELS > 3
> >> +pud_t kasan_zero_pud[PTRS_PER_PUD] __page_aligned_bss;
> >> +#endif
> >> +#if CONFIG_PGTABLE_LEVELS > 2
> >> +pmd_t kasan_zero_pmd[PTRS_PER_PMD] __page_aligned_bss;
> >> +#endif
> >> +pte_t kasan_zero_pte[PTRS_PER_PTE] __page_aligned_bss;
> >> +
> >> +static void __init kasan_early_pmd_populate(unsigned long start,
> >> +					unsigned long end, pud_t *pud)
> >> +{
> >> +	unsigned long addr;
> >> +	unsigned long next;
> >> +	pmd_t *pmd;
> >> +
> >> +	pmd = pmd_offset(pud, start);
> >> +	for (addr = start; addr < end; addr = next, pmd++) {
> >> +		pmd_populate_kernel(&init_mm, pmd, kasan_zero_pte);
> >> +		next = pmd_addr_end(addr, end);
> >> +	}
> >> +}
> >> +
> >> +static void __init kasan_early_pud_populate(unsigned long start,
> >> +					unsigned long end, pgd_t *pgd)
> >> +{
> >> +	unsigned long addr;
> >> +	unsigned long next;
> >> +	pud_t *pud;
> >> +
> >> +	pud = pud_offset(pgd, start);
> >> +	for (addr = start; addr < end; addr = next, pud++) {
> >> +		pud_populate(&init_mm, pud, kasan_zero_pmd);
> >> +		next = pud_addr_end(addr, end);
> >> +		kasan_early_pmd_populate(addr, next, pud);
> >> +	}
> >> +}
> >> +
> >> +static void __init kasan_map_early_shadow(pgd_t *pgdp)
> >> +{
> >> +	int i;
> >> +	unsigned long start = KASAN_SHADOW_START;
> >> +	unsigned long end = KASAN_SHADOW_END;
> >> +	unsigned long addr;
> >> +	unsigned long next;
> >> +	pgd_t *pgd;
> >> +
> >> +	for (i = 0; i < PTRS_PER_PTE; i++)
> >> +		set_pte(&kasan_zero_pte[i], pfn_pte(
> >> +				virt_to_pfn(kasan_zero_page), PAGE_KERNEL));
> >> +
> >> +	pgd = pgd_offset_k(start);
> >> +	for (addr = start; addr < end; addr = next, pgd++) {
> >> +		pgd_populate(&init_mm, pgd, kasan_zero_pud);
> >> +		next = pgd_addr_end(addr, end);
> >> +		kasan_early_pud_populate(addr, next, pgd);
> >> +	}
> > 
> > I prefer to use "do ... while" constructs similar to __create_mapping()
> > (or zero_{pgd,pud,pmd}_populate as you are more familiar with them).
> > 
> > But what I don't get here is that you repopulate the pud page for every
> > pgd (and so on for pmd). You don't need this recursive call all the way
> > to kasan_early_pmd_populate() but just sequential:
> 
> This repopulation needed for 3,2 level page tables configurations.
> 
> E.g. for 3-level page tables we need to call pud_populate(&init_mm,
> pud, kasan_zero_pmd) for each pud in [KASAN_SHADOW_START,
> KASAN_SHADOW_END] range, this causes repopopulation for 4-level page
> tables, since we need to pud_populate() only [KASAN_SHADOW_START,
> KASAN_SHADOW_START + PGDIR_SIZE] range.

I'm referring to writing the same information multiple times over the
same entry. kasan_map_early_shadow() goes over each pgd entry and writes
the address of kasan_zero_pud. That's fine so far. However, in the same
loop you call kasan_early_pud_populate(). The latter retrieves the pud
page via pud_offset(pgd, start) which would always be kasan_zero_pud
because that's what you wrote via pgd_populate() in each pgd entry. So
for each pgd entry, you keep populating the same kasan_zero_pud page
with pointers to kasan_zero_pmd. And so on for the pmd.

> > 	kasan_early_pte_populate();
> > 	kasan_early_pmd_populate(..., pte);
> > 	kasan_early_pud_populate(..., pmd);
> > 	kasan_early_pgd_populate(..., pud);
> > 
> > (or in reverse order)
> 
> Unless, I'm missing something, this will either work only with 4-level
> page tables. We could do this without repopulation by using
> CONFIG_PGTABLE_LEVELS ifdefs.

Or you could move kasan_early_*_populate outside the loop. You already
do this for the pte at the beginning of the kasan_map_early_shadow()
function (and it probably makes more sense to create a separate
kasan_early_pte_populate).

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
