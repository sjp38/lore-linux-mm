Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f44.google.com (mail-la0-f44.google.com [209.85.215.44])
	by kanga.kvack.org (Postfix) with ESMTP id 6C3596B0253
	for <linux-mm@kvack.org>; Mon, 27 Jul 2015 10:23:46 -0400 (EDT)
Received: by lagw2 with SMTP id w2so50044227lag.3
        for <linux-mm@kvack.org>; Mon, 27 Jul 2015 07:23:46 -0700 (PDT)
Received: from mail-la0-x22e.google.com (mail-la0-x22e.google.com. [2a00:1450:4010:c03::22e])
        by mx.google.com with ESMTPS id rv3si15361829lbb.151.2015.07.27.07.23.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Jul 2015 07:23:44 -0700 (PDT)
Received: by laah7 with SMTP id h7so50097507laa.0
        for <linux-mm@kvack.org>; Mon, 27 Jul 2015 07:23:43 -0700 (PDT)
Message-ID: <55B63EE3.6040104@gmail.com>
Date: Mon, 27 Jul 2015 17:23:31 +0300
From: Yury <yury.norov@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 2/7] mm: kasan: introduce generic kasan_populate_zero_shadow()
References: <1437756119-12817-1-git-send-email-a.ryabinin@samsung.com> <1437756119-12817-3-git-send-email-a.ryabinin@samsung.com>
In-Reply-To: <1437756119-12817-3-git-send-email-a.ryabinin@samsung.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Alexey Klimov <klimov.linux@gmail.com>, Arnd Bergmann <arnd@arndb.de>, linux-mm@kvack.org, Linus Walleij <linus.walleij@linaro.org>, x86@kernel.org, linux-kernel@vger.kernel.org, David Keitel <dkeitel@codeaurora.org>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

 > Introduce generic kasan_populate_zero_shadow(start, end).
 > This function maps kasan_zero_page to the [start, end] addresses.
 >
 > In follow on patches it will be used for ARMv8 (and maybe other
 > architectures) and will replace x86_64 specific populate_zero_shadow().
 >
 > Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
 > ---
 >  arch/x86/mm/kasan_init_64.c |  14 ----
 >  include/linux/kasan.h       |   8 +++
 >  mm/kasan/Makefile           |   2 +-
 >  mm/kasan/kasan_init.c       | 151 
++++++++++++++++++++++++++++++++++++++++++++
 >  4 files changed, 160 insertions(+), 15 deletions(-)
 >  create mode 100644 mm/kasan/kasan_init.c
 >
 > diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
 > index e1840f3..812086c 100644
 > --- a/arch/x86/mm/kasan_init_64.c
 > +++ b/arch/x86/mm/kasan_init_64.c
 > @@ -12,20 +12,6 @@
 >  extern pgd_t early_level4_pgt[PTRS_PER_PGD];
 >  extern struct range pfn_mapped[E820_X_MAX];
 >
 > -static pud_t kasan_zero_pud[PTRS_PER_PUD] __page_aligned_bss;
 > -static pmd_t kasan_zero_pmd[PTRS_PER_PMD] __page_aligned_bss;
 > -static pte_t kasan_zero_pte[PTRS_PER_PTE] __page_aligned_bss;
 > -
 > -/*
 > - * This page used as early shadow. We don't use empty_zero_page
 > - * at early stages, stack instrumentation could write some garbage
 > - * to this page.
 > - * Latter we reuse it as zero shadow for large ranges of memory
 > - * that allowed to access, but not instrumented by kasan
 > - * (vmalloc/vmemmap ...).
 > - */
 > -static unsigned char kasan_zero_page[PAGE_SIZE] __page_aligned_bss;
 > -
 >  static int __init map_range(struct range *range)
 >  {
 >      unsigned long start;
 > diff --git a/include/linux/kasan.h b/include/linux/kasan.h
 > index 6fb1c7d..d795f53 100644
 > --- a/include/linux/kasan.h
 > +++ b/include/linux/kasan.h
 > @@ -12,8 +12,16 @@ struct vm_struct;
 >  #define KASAN_SHADOW_SCALE_SHIFT 3
 >
 >  #include <asm/kasan.h>
 > +#include <asm/pgtable.h>
 >  #include <linux/sched.h>
 >
 > +extern unsigned char kasan_zero_page[PAGE_SIZE];
 > +extern pte_t kasan_zero_pte[PTRS_PER_PTE];
 > +extern pmd_t kasan_zero_pmd[PTRS_PER_PMD];
 > +extern pud_t kasan_zero_pud[PTRS_PER_PUD];
 > +
 > +void kasan_populate_zero_shadow(const void *from, const void *to);
 > +
 >  static inline void *kasan_mem_to_shadow(const void *addr)
 >  {
 >      return (void *)((unsigned long)addr >> KASAN_SHADOW_SCALE_SHIFT)
 > diff --git a/mm/kasan/Makefile b/mm/kasan/Makefile
 > index bd837b8..6471014 100644
 > --- a/mm/kasan/Makefile
 > +++ b/mm/kasan/Makefile
 > @@ -5,4 +5,4 @@ CFLAGS_REMOVE_kasan.o = -pg
 >  # see: https://gcc.gnu.org/bugzilla/show_bug.cgi?id=63533
 >  CFLAGS_kasan.o := $(call cc-option, -fno-conserve-stack 
-fno-stack-protector)
 >
 > -obj-y := kasan.o report.o
 > +obj-y := kasan.o report.o kasan_init.o
 > diff --git a/mm/kasan/kasan_init.c b/mm/kasan/kasan_init.c
 > new file mode 100644
 > index 0000000..e276853
 > --- /dev/null
 > +++ b/mm/kasan/kasan_init.c
 > @@ -0,0 +1,151 @@
 > +/*
 > + * This file contains some kasan initialization code.
 > + *
 > + * Copyright (c) 2015 Samsung Electronics Co., Ltd.
 > + * Author: Andrey Ryabinin
 > + *
 > + * This program is free software; you can redistribute it and/or modify
 > + * it under the terms of the GNU General Public License version 2 as
 > + * published by the Free Software Foundation.
 > + *
 > + */
 > +
 > +#include <linux/bootmem.h>
 > +#include <linux/init.h>
 > +#include <linux/kasan.h>
 > +#include <linux/kernel.h>
 > +#include <linux/memblock.h>
 > +#include <linux/pfn.h>
 > +
 > +#include <asm/page.h>
 > +#include <asm/pgalloc.h>
 > +
 > +/*
 > + * This page serves two purposes:
 > + *   - It used as early shadow memory. The entire shadow region 
populated
 > + *     with this page, before we will be able to setup normal shadow 
memory.
 > + *   - Latter it reused it as zero shadow to cover large ranges of 
memory
 > + *     that allowed to access, but not handled by kasan 
(vmalloc/vmemmap ...).
 > + */
 > +unsigned char kasan_zero_page[PAGE_SIZE] __page_aligned_bss;
 > +
 > +#if CONFIG_PGTABLE_LEVELS > 3
 > +pud_t kasan_zero_pud[PTRS_PER_PUD] __page_aligned_bss;
 > +#endif
 > +#if CONFIG_PGTABLE_LEVELS > 2
 > +pmd_t kasan_zero_pmd[PTRS_PER_PMD] __page_aligned_bss;
 > +#endif

You declare kasan_zero_pud and kasan_zero_pmd conditionally now, but use
unconditionally, at least in kasan_init in patch #5. If I'm not missing
something, this is wrong...

 > +pte_t kasan_zero_pte[PTRS_PER_PTE] __page_aligned_bss;
 > +
 > +static __init void *early_alloc(size_t size, int node)
 > +{
 > +    return memblock_virt_alloc_try_nid(size, size, 
__pa(MAX_DMA_ADDRESS),
 > +                    BOOTMEM_ALLOC_ACCESSIBLE, node);
 > +}
 > +
 > +static void __init zero_pte_populate(pmd_t *pmd, unsigned long addr,
 > +                unsigned long end)
 > +{
 > +    pte_t *pte = pte_offset_kernel(pmd, addr);
 > +    pte_t zero_pte;
 > +
 > +    zero_pte = pfn_pte(PFN_DOWN(__pa(kasan_zero_page)), PAGE_KERNEL);
 > +    zero_pte = pte_wrprotect(zero_pte);
 > +
 > +    while (addr + PAGE_SIZE <= end) {
 > +        set_pte_at(&init_mm, addr, pte, zero_pte);
 > +        addr += PAGE_SIZE;
 > +        pte = pte_offset_kernel(pmd, addr);
 > +    }
 > +}
 > +
 > +static void __init zero_pmd_populate(pud_t *pud, unsigned long addr,
 > +                unsigned long end)

Functions zero_pmd_populate, zero_pud_populate and 
kasan_populate_zero_shadow
are suspiciously similar. I think we can isolate common pieces to helpers to
reduce code duplication and increase readability...

 > +{
 > +    pmd_t *pmd = pmd_offset(pud, addr);
 > +    unsigned long next;
 > +
 > +    do {
 > +        next = pmd_addr_end(addr, end);
 > +
 > +        if (IS_ALIGNED(addr, PMD_SIZE) && end - addr >= PMD_SIZE) {

This line is repeated 3 times. For me, it's more than enough to
wrap it to helper (if something similar does not exist somewhere):
static inline is_whole_entry(unsigned long start, unsigned long end, 
unsigned long size);

 > +            pmd_populate_kernel(&init_mm, pmd, kasan_zero_pte);
 > +            continue;
 > +        }
 > +
 > +        if (pmd_none(*pmd)) {
 > +            pmd_populate_kernel(&init_mm, pmd,
 > +                    early_alloc(PAGE_SIZE, NUMA_NO_NODE));
 > +        }
 > +        zero_pte_populate(pmd, addr, next);
 > +    } while (pmd++, addr = next, addr != end);
 > +}
 > +
 > +static void __init zero_pud_populate(pgd_t *pgd, unsigned long addr,
 > +                unsigned long end)
 > +{
 > +    pud_t *pud = pud_offset(pgd, addr);
 > +    unsigned long next;
 > +
 > +    do {
 > +        next = pud_addr_end(addr, end);
 > +        if (IS_ALIGNED(addr, PUD_SIZE) && end - addr >= PUD_SIZE) {
 > +            pmd_t *pmd;
 > +
 > +            pud_populate(&init_mm, pud, kasan_zero_pmd);
 > +            pmd = pmd_offset(pud, addr);
 > +            pmd_populate_kernel(&init_mm, pmd, kasan_zero_pte);

This three lines are repeated in kasan_populate_zero_shadow()
So, maybe you'd wrap it with some
'pud_zero_populate_whole_pmd(pud, addr)'?

 > +            continue;
 > +        }
 > +
 > +        if (pud_none(*pud)) {
 > +            pud_populate(&init_mm, pud,
 > +                early_alloc(PAGE_SIZE, NUMA_NO_NODE));
 > +        }
 > +        zero_pmd_populate(pud, addr, next);
 > +    } while (pud++, addr = next, addr != end);
 > +}
 > +
 > +/**
 > + * kasan_populate_zero_shadow - populate shadow memory region with
 > + *                               kasan_zero_page
 > + * @from - start of the memory range to populate
 > + * @to   - end of the memory range to populate

In description and here in comment you underline that 1st parameter is
start, and second is end. But you name them finally 'from' and 'to', and
for me this names are confusing. And for you too, in so far as you add
comment explaining it. I'm not insisting, but why don't you give parameters
more straight names? (If you are worrying about internal vars naming 
conflict,
just use '_start' and '_end' for them.)

 > + */
 > +void __init kasan_populate_zero_shadow(const void *from, const void *to)
 > +{
 > +    unsigned long addr = (unsigned long)from;
 > +    unsigned long end = (unsigned long)to;
 > +    pgd_t *pgd = pgd_offset_k(addr);
 > +    unsigned long next;
 > +
 > +    do {
 > +        next = pgd_addr_end(addr, end);
 > +
 > +        if (IS_ALIGNED(addr, PGDIR_SIZE) && end - addr >= PGDIR_SIZE) {
 > +            pud_t *pud;
 > +            pmd_t *pmd;
 > +
 > +            /*
 > +             * kasan_zero_pud should be populated with pmds
 > +             * at this moment.
 > +             * [pud,pmd]_populate*() below needed only for
 > +             * 3,2 - level page tables where we don't have
 > +             * puds,pmds, so pgd_populate(), pud_populate()
 > +             * is noops.
 > +             */
 > +            pgd_populate(&init_mm, pgd, kasan_zero_pud);
 > +            pud = pud_offset(pgd, addr);
 > +            pud_populate(&init_mm, pud, kasan_zero_pmd);
 > +            pmd = pmd_offset(pud, addr);
 > +            pmd_populate_kernel(&init_mm, pmd, kasan_zero_pte);
 > +            continue;
 > +        }
 > +
 > +        if (pgd_none(*pgd)) {
 > +            pgd_populate(&init_mm, pgd,
 > +                early_alloc(PAGE_SIZE, NUMA_NO_NODE));
 > +        }
 > +        zero_pud_populate(pgd, addr, next);
 > +    } while (pgd++, addr = next, addr != end);
 > +}
 > --
 > 2.4.5
 >

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
