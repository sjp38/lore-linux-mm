Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id EC3BC28029C
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 12:37:38 -0400 (EDT)
Received: by pdbep18 with SMTP id ep18so28717634pdb.1
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 09:37:38 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id ue10si8417844pab.139.2015.07.15.09.37.37
        for <linux-mm@kvack.org>;
        Wed, 15 Jul 2015 09:37:38 -0700 (PDT)
Date: Wed, 15 Jul 2015 17:37:32 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v2 5/5] arm64: add KASan support
Message-ID: <20150715163732.GF20186@e104818-lin.cambridge.arm.com>
References: <1431698344-28054-1-git-send-email-a.ryabinin@samsung.com>
 <1431698344-28054-6-git-send-email-a.ryabinin@samsung.com>
 <20150708154803.GE6944@e104818-lin.cambridge.arm.com>
 <559FFCA7.4060008@samsung.com>
 <20150714150445.GH13555@e104818-lin.cambridge.arm.com>
 <55A61FF8.9000603@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55A61FF8.9000603@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: Arnd Bergmann <arnd@arndb.de>, linux-mm@kvack.org, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, David Keitel <dkeitel@codeaurora.org>, Alexander Potapenko <glider@google.com>, linux-arm-kernel@lists.infradead.org, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>

On Wed, Jul 15, 2015 at 11:55:20AM +0300, Andrey Ryabinin wrote:
> On 07/14/2015 06:04 PM, Catalin Marinas wrote:
> > On Fri, Jul 10, 2015 at 08:11:03PM +0300, Andrey Ryabinin wrote:
> >>> 	kasan_early_pte_populate();
> >>> 	kasan_early_pmd_populate(..., pte);
> >>> 	kasan_early_pud_populate(..., pmd);
> >>> 	kasan_early_pgd_populate(..., pud);
> >>>
> >>> (or in reverse order)
> >>
> >> Unless, I'm missing something, this will either work only with 4-level
> >> page tables. We could do this without repopulation by using
> >> CONFIG_PGTABLE_LEVELS ifdefs.
> > 
> > Or you could move kasan_early_*_populate outside the loop. You already
> > do this for the pte at the beginning of the kasan_map_early_shadow()
> > function (and it probably makes more sense to create a separate
> > kasan_early_pte_populate).
> 
> Ok, let's try to implement that.
> And for example, let's consider CONFIG_PGTABLE_LEVELS=3 case:
> 
>  * pgd_populate() is nop, so kasan_early_pgd_populate() won't do anything.
> 
>  * pud_populate() in kasan_early_pud_populate() actually will setup pgd entries in swapper_pg_dir,
>    so pud_populate() should be called for the whole shadow range: [KASAN_SHADOW_START, KASAN_SHADOW_END]
> 	IOW: kasan_early_pud_populate(KASAN_SHADOW_START, KASAN_SHADOW_END, kasan_zero_pmd);
> 	
> 	We will need to slightly change kasan_early_pud_populate() implementation for that
> 	(Current implementation implies that [start, end) addresses belong to one pgd)
> 
> 	void kasan_early_pud_populate(unsigned long start, unsigned long end, pmd_t *pmd)
> 	{
> 		unsigned long addr;
> 		long next;
> 
> 		for (addr = start; addr < end; addr = next) {
> 			pud_t *pud = pud_offset(pgd_offset_k(addr), addr);
> 			pud_populate(&init_mm, pud, pmd);
> 			next = pud_addr_end(addr, pgd_addr_end(addr, end));
> 		}
> 	}
> 
> 	But, wait! In 4-level page tables case this will be the same repopulation as we had before!

Ok, so simply taking the call out of the loop won't work unless we
conditionally define these functions (wouldn't be too bad since we have
some #if CONFIG_PGTABLE_LEVELS already introduced by this patch but it
would be nicer without).

Anyway, I think we can keep the current iterations but exit early if
!pud_none() because it means we already populated it (reworked to match
other such patterns throughout the kernel with pgd_populate called from
the pud function; and untested):

void kasan_early_pmd_populate(pud_t *pud, unsigned long addr, unsigned long end)
{
	pmd_t *pmd;
	unsigned long next;

	if (pud_none(*pud))
		pud_populate(&init_mm, pud, kasan_zero_pmd);

	pmd = pmd_offset(pud, addr);
	do {
		next = pmd_addr_end(addr, end);
		kasan_early_pte_populate(pmd, addr, next);
	} while (pmd++, addr = next, addr != end && pmd_none(*pmd));
}

void kasan_early_pud_populate(pgd_t *pgd, unsigned long addr, unsigned long end)
{
	pud_t *pud;
	unsigned long next;

	if (pgd_none(*pgd))
		pgd_populate(&init_mm, pgd, kasan_zero_pud);

	pud = pud_offset(pgd, addr);
	do {
		next = pud_addr_end(addr, end);
		kasan_early_pmd_populate(pud, addr, next);
	} while (pud++, addr = next, addr != end && pud_none(*pud));
}

Given that we check pud_none() after the first iterations, it covers the
lower levels if needed.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
