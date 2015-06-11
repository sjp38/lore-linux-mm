Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f177.google.com (mail-ob0-f177.google.com [209.85.214.177])
	by kanga.kvack.org (Postfix) with ESMTP id 2B6326B006C
	for <linux-mm@kvack.org>; Thu, 11 Jun 2015 09:39:08 -0400 (EDT)
Received: by obbgp2 with SMTP id gp2so4386675obb.2
        for <linux-mm@kvack.org>; Thu, 11 Jun 2015 06:39:07 -0700 (PDT)
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com. [209.85.214.174])
        by mx.google.com with ESMTPS id k9si475938oet.61.2015.06.11.06.39.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jun 2015 06:39:07 -0700 (PDT)
Received: by obbqz1 with SMTP id qz1so4381527obb.3
        for <linux-mm@kvack.org>; Thu, 11 Jun 2015 06:39:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1431698344-28054-6-git-send-email-a.ryabinin@samsung.com>
References: <1431698344-28054-1-git-send-email-a.ryabinin@samsung.com>
	<1431698344-28054-6-git-send-email-a.ryabinin@samsung.com>
Date: Thu, 11 Jun 2015 15:39:06 +0200
Message-ID: <CACRpkdaRJJjCXR=vK1M2YhR26JZfGoBB+jcqz8r2MhERfxRzqA@mail.gmail.com>
Subject: Re: [PATCH v2 5/5] arm64: add KASan support
From: Linus Walleij <linus.walleij@linaro.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>, David Keitel <dkeitel@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, linux-mm@kvack.org

On Fri, May 15, 2015 at 3:59 PM, Andrey Ryabinin <a.ryabinin@samsung.com> wrote:

> This patch adds arch specific code for kernel address sanitizer
> (see Documentation/kasan.txt).

I looked closer at this again ... I am trying to get KASan up for
ARM(32) with some tricks and hacks.

> +config KASAN_SHADOW_OFFSET
> +       hex
> +       default 0xdfff200000000000 if ARM64_VA_BITS_48
> +       default 0xdffffc8000000000 if ARM64_VA_BITS_42
> +       default 0xdfffff9000000000 if ARM64_VA_BITS_39

So IIUC these offsets are simply chosen to satisfy the equation

        SHADOW = (void *)((unsigned long)addr >> KASAN_SHADOW_SCALE_SHIFT)
                + KASAN_SHADOW_OFFSET;

For all memory that needs to be covered, i.e. kernel text+data,
modules text+data, any other kernel-mode running code+data.

And it needs to be statically assigned like this because the offset
is used at compile time.

Atleast that is how I understood it... correct me if wrong.
(Dunno if all is completely obvious to everyone else in the world...)

> +/*
> + * KASAN_SHADOW_START: beginning of the kernel virtual addresses.
> + * KASAN_SHADOW_END: KASAN_SHADOW_START + 1/8 of kernel virtual addresses.
> + */
> +#define KASAN_SHADOW_START      (UL(0xffffffffffffffff) << (VA_BITS))
> +#define KASAN_SHADOW_END        (KASAN_SHADOW_START + (1UL << (VA_BITS - 3)))

Will this not mean that shadow start to end actually covers *all*
virtual addresses including userspace and what not? However a
large portion of this shadow memory will be unused because the
SHADOW_OFFSET only works for code compiled for the kernel
anyway.

When working on ARM32 I certainly could not map
(1UL << (VA_BITS -3)) i.e. for 32 bit (1UL << 29) bytes (512 MB) of
virtual memory for shadow, instead I had to restrict it to the size that
actually maps the memory used by the kernel.

I tried shrinking it down but it crashed on me so tell me how
wrong I am ... :)

But here comes the real tricks, where I need some help to
understand the patch set, maybe some comments should be
inserted here and there to ease understanding:

> +++ b/arch/arm64/mm/kasan_init.c
> @@ -0,0 +1,143 @@
> +#include <linux/kasan.h>
> +#include <linux/kernel.h>
> +#include <linux/memblock.h>
> +#include <linux/start_kernel.h>
> +
> +#include <asm/page.h>
> +#include <asm/pgalloc.h>
> +#include <asm/pgtable.h>
> +#include <asm/tlbflush.h>
> +
> +unsigned char kasan_zero_page[PAGE_SIZE] __page_aligned_bss;
> +static pgd_t tmp_page_table[PTRS_PER_PGD] __initdata __aligned(PAGE_SIZE);
> +
> +#if CONFIG_PGTABLE_LEVELS > 3
> +pud_t kasan_zero_pud[PTRS_PER_PUD] __page_aligned_bss;
> +#endif
> +#if CONFIG_PGTABLE_LEVELS > 2
> +pmd_t kasan_zero_pmd[PTRS_PER_PMD] __page_aligned_bss;
> +#endif
> +pte_t kasan_zero_pte[PTRS_PER_PTE] __page_aligned_bss;
> +
> +static void __init kasan_early_pmd_populate(unsigned long start,
> +                                       unsigned long end, pud_t *pud)
> +{
> +       unsigned long addr;
> +       unsigned long next;
> +       pmd_t *pmd;
> +
> +       pmd = pmd_offset(pud, start);
> +       for (addr = start; addr < end; addr = next, pmd++) {
> +               pmd_populate_kernel(&init_mm, pmd, kasan_zero_pte);
> +               next = pmd_addr_end(addr, end);
> +       }
> +}
> +
> +static void __init kasan_early_pud_populate(unsigned long start,
> +                                       unsigned long end, pgd_t *pgd)
> +{
> +       unsigned long addr;
> +       unsigned long next;
> +       pud_t *pud;
> +
> +       pud = pud_offset(pgd, start);
> +       for (addr = start; addr < end; addr = next, pud++) {
> +               pud_populate(&init_mm, pud, kasan_zero_pmd);
> +               next = pud_addr_end(addr, end);
> +               kasan_early_pmd_populate(addr, next, pud);
> +       }
> +}
> +
> +static void __init kasan_map_early_shadow(pgd_t *pgdp)
> +{
> +       int i;
> +       unsigned long start = KASAN_SHADOW_START;
> +       unsigned long end = KASAN_SHADOW_END;
> +       unsigned long addr;
> +       unsigned long next;
> +       pgd_t *pgd;
> +
> +       for (i = 0; i < PTRS_PER_PTE; i++)
> +               set_pte(&kasan_zero_pte[i], pfn_pte(
> +                               virt_to_pfn(kasan_zero_page), PAGE_KERNEL));
> +
> +       pgd = pgd_offset_k(start);
> +       for (addr = start; addr < end; addr = next, pgd++) {
> +               pgd_populate(&init_mm, pgd, kasan_zero_pud);
> +               next = pgd_addr_end(addr, end);
> +               kasan_early_pud_populate(addr, next, pgd);
> +       }
> +}
> +
> +void __init kasan_early_init(void)
> +{
> +       kasan_map_early_shadow(swapper_pg_dir);
> +       start_kernel();
> +}

So as far as I can see, kasan_early_init() needs to be called before
we even run start_kernel() because every memory access would
crash unless the MMU is set up for the shadow memory.

Is it correct that when the pte's, pgd's and pud's are populated
KASan really doesn't kick in, it's just done to have some scratch
memory with whatever contents so as to do dummy updates
for the __asan_loadN() and __asan_storeN() calls, and no checks
start until the shadow memory is populated in kasan_init()
i.e. there are no KASan checks for any code executing up
to that point, just random writes and reads?

Also, this code under kasan_early_init(), must that not be
written extremely carefully to avoid any loads and stores?
I.e. even if this file is obviously compiled with
KASAN_SANITIZE_kasan_init.o := n so that it is not
instrumented, I'm thinking about the functions it is calling,
like set_pte(), pgd_populate(), pmd_offset() etc etc.

Are we just lucky that these functions never do any loads
and stores?

Yours,
Linus Walleij

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
