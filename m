Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f180.google.com (mail-qk0-f180.google.com [209.85.220.180])
	by kanga.kvack.org (Postfix) with ESMTP id 527A92802F9
	for <linux-mm@kvack.org>; Thu, 16 Jul 2015 12:03:20 -0400 (EDT)
Received: by qkdv3 with SMTP id v3so53032524qkd.3
        for <linux-mm@kvack.org>; Thu, 16 Jul 2015 09:03:19 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id j63si10075088qgd.48.2015.07.16.09.03.19
        for <linux-mm@kvack.org>;
        Thu, 16 Jul 2015 09:03:19 -0700 (PDT)
Date: Thu, 16 Jul 2015 17:03:13 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v2 5/5] arm64: add KASan support
Message-ID: <20150716160313.GC26865@e104818-lin.cambridge.arm.com>
References: <1431698344-28054-1-git-send-email-a.ryabinin@samsung.com>
 <1431698344-28054-6-git-send-email-a.ryabinin@samsung.com>
 <20150708154803.GE6944@e104818-lin.cambridge.arm.com>
 <559FFCA7.4060008@samsung.com>
 <20150714150445.GH13555@e104818-lin.cambridge.arm.com>
 <55A61FF8.9000603@samsung.com>
 <20150715163732.GF20186@e104818-lin.cambridge.arm.com>
 <55A7CE03.301@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55A7CE03.301@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: Arnd Bergmann <arnd@arndb.de>, David Keitel <dkeitel@codeaurora.org>, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-arm-kernel@lists.infradead.org

On Thu, Jul 16, 2015 at 06:30:11PM +0300, Andrey Ryabinin wrote:
> On 07/15/2015 07:37 PM, Catalin Marinas wrote:
> > Ok, so simply taking the call out of the loop won't work unless we
> > conditionally define these functions (wouldn't be too bad since we have
> > some #if CONFIG_PGTABLE_LEVELS already introduced by this patch but it
> > would be nicer without).
> > 
> > Anyway, I think we can keep the current iterations but exit early if
> > !pud_none() because it means we already populated it (reworked to match
> > other such patterns throughout the kernel with pgd_populate called from
> > the pud function; and untested):
> > 
> > void kasan_early_pmd_populate(pud_t *pud, unsigned long addr, unsigned long end)
> > {
> > 	pmd_t *pmd;
> > 	unsigned long next;
> > 
> > 	if (pud_none(*pud))
> > 		pud_populate(&init_mm, pud, kasan_zero_pmd);
> > 
> > 	pmd = pmd_offset(pud, addr);
> > 	do {
> > 		next = pmd_addr_end(addr, end);
> > 		kasan_early_pte_populate(pmd, addr, next);
> > 	} while (pmd++, addr = next, addr != end && pmd_none(*pmd));
> > }
> > 
> > void kasan_early_pud_populate(pgd_t *pgd, unsigned long addr, unsigned long end)
> > {
> > 	pud_t *pud;
> > 	unsigned long next;
> > 
> > 	if (pgd_none(*pgd))
> > 		pgd_populate(&init_mm, pgd, kasan_zero_pud);
> > 
> > 	pud = pud_offset(pgd, addr);
> > 	do {
> > 		next = pud_addr_end(addr, end);
> > 		kasan_early_pmd_populate(pud, addr, next);
> > 	} while (pud++, addr = next, addr != end && pud_none(*pud));
> > }
> > 
> > Given that we check pud_none() after the first iterations, it covers the
> > lower levels if needed.
> 
> I think this may work, if pud_none(*pud) will be replaced with !pud_val(*pud).
> We can't use pud_none() because with 2-level page tables it's always false, so
> we will never go down to pmd level where swapper_pg_dir populated.

The reason I used "do ... while" vs "while" or "for" is so that it gets
down to the pmd level. The iteration over pgd is always done in the top
loop via pgd_addr_end while the loops for missing levels (nopud, nopmd)
are always a single iteration whether we check for pud_none or not. But
when the level is present, we avoid looping when !pud_none().

> But you gave me another idea how we could use p?d_none() and avoid rewriting table entries:
> 
> 
> void kasan_early_pmd_populate(unsigned long start, unsigned long end, pte_t *pte)
> {
> 	unsigned long addr = start;
> 	long next;
> 
> 	do {
> 		pgd_t *pgd = pgd_offset_k(addr);
> 		pud_t *pud = pud_offset(pgd, addr);
> 		pmd_t *pmd = pmd_offset(pud, addr);
> 
> 		if (!pmd_none(*pmd))
> 			break;
> 
> 		pmd_populate_kernel(&init_mm, pmd, pte);
> 		next = pgd_addr_end(addr, end);
> 		next = pud_addr_end(addr, next)
> 		next = pmd_addr_end(addr, next);
> 	} while(addr = next, addr != end);
> }
> 
> void kasan_early_pud_populate(unsigned long start, unsigned long end, pmd_t *pmd)
> {
> 	unsigned long addr = start;
> 	long next;
> 
> 	do {
> 		pgd_t *pgd = pgd_offset_k(addr);
> 		pud_t *pud = pud_offset(pgd, addr);
> 
> 		if (!pud_none(*pud))
> 			break;
> 
> 		pud_populate(&init_mm, pud, pmd);
> 		next = pud_addr_end(addr, pgd_addr_end(addr, end));
> 	} while(addr = next, addr != end);
> }
> 
> 
> void kasan_early_pgd_populate(...)
> {
> 	//something similar to above
> 	....
> }
> 
> static void __init kasan_map_early_shadow(void)
> {
> 	kasan_early_pgd_populate(KASAN_SHADOW_START, KASAN_SHADOW_END, kasan_zero_pud);
> 	kasan_early_pud_populate(KASAN_SHADOW_START, KASAN_SHADOW_END, kasan_zero_pmd);
> 	kasan_early_pmd_populate(KASAN_SHADOW_START, KASAN_SHADOW_END, kasan_zero_pte);
> 	kasan_early_pte_populate();
> }

While this would probably work, you still need #ifdef's since
kasan_zero_pud is not defined with 2 and 3 levels. That's what I
initially thought we should do but since you didn't like the #ifdef's, I
came up with another proposal.

So, I still prefer my suggestion above unless you find a problem with
it.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
