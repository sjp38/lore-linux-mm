Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 23BE22802F9
	for <linux-mm@kvack.org>; Thu, 16 Jul 2015 11:30:22 -0400 (EDT)
Received: by pactm7 with SMTP id tm7so44833210pac.2
        for <linux-mm@kvack.org>; Thu, 16 Jul 2015 08:30:21 -0700 (PDT)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id v11si3900137pas.231.2015.07.16.08.30.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 16 Jul 2015 08:30:21 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NRL00MGL72GR240@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 16 Jul 2015 16:30:16 +0100 (BST)
Message-id: <55A7CE03.301@samsung.com>
Date: Thu, 16 Jul 2015 18:30:11 +0300
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH v2 5/5] arm64: add KASan support
References: <1431698344-28054-1-git-send-email-a.ryabinin@samsung.com>
 <1431698344-28054-6-git-send-email-a.ryabinin@samsung.com>
 <20150708154803.GE6944@e104818-lin.cambridge.arm.com>
 <559FFCA7.4060008@samsung.com>
 <20150714150445.GH13555@e104818-lin.cambridge.arm.com>
 <55A61FF8.9000603@samsung.com>
 <20150715163732.GF20186@e104818-lin.cambridge.arm.com>
In-reply-to: <20150715163732.GF20186@e104818-lin.cambridge.arm.com>
Content-type: text/plain; charset=windows-1252
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Arnd Bergmann <arnd@arndb.de>, linux-mm@kvack.org, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, David Keitel <dkeitel@codeaurora.org>, Alexander Potapenko <glider@google.com>, linux-arm-kernel@lists.infradead.org, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>

On 07/15/2015 07:37 PM, Catalin Marinas wrote:
> Ok, so simply taking the call out of the loop won't work unless we
> conditionally define these functions (wouldn't be too bad since we have
> some #if CONFIG_PGTABLE_LEVELS already introduced by this patch but it
> would be nicer without).
> 
> Anyway, I think we can keep the current iterations but exit early if
> !pud_none() because it means we already populated it (reworked to match
> other such patterns throughout the kernel with pgd_populate called from
> the pud function; and untested):
> 
> void kasan_early_pmd_populate(pud_t *pud, unsigned long addr, unsigned long end)
> {
> 	pmd_t *pmd;
> 	unsigned long next;
> 
> 	if (pud_none(*pud))
> 		pud_populate(&init_mm, pud, kasan_zero_pmd);
> 
> 	pmd = pmd_offset(pud, addr);
> 	do {
> 		next = pmd_addr_end(addr, end);
> 		kasan_early_pte_populate(pmd, addr, next);
> 	} while (pmd++, addr = next, addr != end && pmd_none(*pmd));
> }
> 
> void kasan_early_pud_populate(pgd_t *pgd, unsigned long addr, unsigned long end)
> {
> 	pud_t *pud;
> 	unsigned long next;
> 
> 	if (pgd_none(*pgd))
> 		pgd_populate(&init_mm, pgd, kasan_zero_pud);
> 
> 	pud = pud_offset(pgd, addr);
> 	do {
> 		next = pud_addr_end(addr, end);
> 		kasan_early_pmd_populate(pud, addr, next);
> 	} while (pud++, addr = next, addr != end && pud_none(*pud));
> }
> 
> Given that we check pud_none() after the first iterations, it covers the
> lower levels if needed.
> 

I think this may work, if pud_none(*pud) will be replaced with !pud_val(*pud).
We can't use pud_none() because with 2-level page tables it's always false, so
we will never go down to pmd level where swapper_pg_dir populated.

But you gave me another idea how we could use p?d_none() and avoid rewriting table entries:


void kasan_early_pmd_populate(unsigned long start, unsigned long end, pte_t *pte)
{
	unsigned long addr = start;
	long next;

	do {
		pgd_t *pgd = pgd_offset_k(addr);
		pud_t *pud = pud_offset(pgd, addr);
		pmd_t *pmd = pmd_offset(pud, addr);

		if (!pmd_none(*pmd))
			break;

		pmd_populate_kernel(&init_mm, pmd, pte);
		next = pgd_addr_end(addr, end);
		next = pud_addr_end(addr, next)
		next = pmd_addr_end(addr, next);
	} while(addr = next, addr != end);
}

void kasan_early_pud_populate(unsigned long start, unsigned long end, pmd_t *pmd)
{
	unsigned long addr = start;
	long next;

	do {
		pgd_t *pgd = pgd_offset_k(addr);
		pud_t *pud = pud_offset(pgd, addr);

		if (!pud_none(*pud))
			break;

		pud_populate(&init_mm, pud, pmd);
		next = pud_addr_end(addr, pgd_addr_end(addr, end));
	} while(addr = next, addr != end);
}


void kasan_early_pgd_populate(...)
{
	//something similar to above
	....
}

static void __init kasan_map_early_shadow(void)
{
	kasan_early_pgd_populate(KASAN_SHADOW_START, KASAN_SHADOW_END, kasan_zero_pud);
	kasan_early_pud_populate(KASAN_SHADOW_START, KASAN_SHADOW_END, kasan_zero_pmd);
	kasan_early_pmd_populate(KASAN_SHADOW_START, KASAN_SHADOW_END, kasan_zero_pte);
	kasan_early_pte_populate();
}





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
