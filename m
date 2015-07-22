Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 4AF3B6B0258
	for <linux-mm@kvack.org>; Wed, 22 Jul 2015 10:25:10 -0400 (EDT)
Received: by wibud3 with SMTP id ud3so175233594wib.0
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 07:25:09 -0700 (PDT)
Received: from mail-wi0-x22c.google.com (mail-wi0-x22c.google.com. [2a00:1450:400c:c05::22c])
        by mx.google.com with ESMTPS id bv5si3861128wib.114.2015.07.22.07.25.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jul 2015 07:25:08 -0700 (PDT)
Received: by wibud3 with SMTP id ud3so175232265wib.0
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 07:25:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1437561037-31995-2-git-send-email-a.ryabinin@samsung.com>
References: <1437561037-31995-1-git-send-email-a.ryabinin@samsung.com>
	<1437561037-31995-2-git-send-email-a.ryabinin@samsung.com>
Date: Wed, 22 Jul 2015 17:25:08 +0300
Message-ID: <CALW4P++z9oJhWNCLLOV0xChdbNVuqokEBmzut08XKfQe1viknw@mail.gmail.com>
Subject: Re: [PATCH v3 1/5] mm: kasan: introduce generic kasan_populate_zero_shadow()
From: Alexey Klimov <klimov.linux@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Arnd Bergmann <arnd@arndb.de>, linux-mm@kvack.org, Linus Walleij <linus.walleij@linaro.org>, x86@kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, David Keitel <dkeitel@codeaurora.org>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>, Yury Norov <yury.norov@gmail.com>

Hi Andrey,

Could you please check minor comments below?

On Wed, Jul 22, 2015 at 1:30 PM, Andrey Ryabinin <a.ryabinin@samsung.com> wrote:
> Introduce generic kasan_populate_zero_shadow(start, end).
> This function maps kasan_zero_page to the [start, end] addresses.
>
> In follow on patches it will be used for ARMv8 (and maybe other
> architectures) and will replace x86_64 specific populate_zero_shadow().
>
> Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
> ---
>  arch/x86/mm/kasan_init_64.c |   8 +--
>  include/linux/kasan.h       |   8 +++
>  mm/kasan/Makefile           |   2 +-
>  mm/kasan/kasan_init.c       | 142 ++++++++++++++++++++++++++++++++++++++++++++
>  4 files changed, 155 insertions(+), 5 deletions(-)
>  create mode 100644 mm/kasan/kasan_init.c
>

[..]

> diff --git a/mm/kasan/kasan_init.c b/mm/kasan/kasan_init.c
> new file mode 100644
> index 0000000..37fb46a
> --- /dev/null
> +++ b/mm/kasan/kasan_init.c
> @@ -0,0 +1,142 @@
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

Are you releasing code under GPL?
Shouldn't there be any license header in such new file?


> +static __init void *early_alloc(size_t size, int node)
> +{
> +       return memblock_virt_alloc_try_nid(size, size, __pa(MAX_DMA_ADDRESS),
> +                                       BOOTMEM_ALLOC_ACCESSIBLE, node);
> +}
> +
> +static int __init zero_pte_populate(pmd_t *pmd, unsigned long addr,
> +                               unsigned long end)
> +{
> +       pte_t *pte = pte_offset_kernel(pmd, addr);
> +       pte_t zero_pte;
> +
> +       zero_pte = pfn_pte(PFN_DOWN(__pa(kasan_zero_page)), PAGE_KERNEL);
> +       zero_pte = pte_wrprotect(zero_pte);
> +
> +       while (addr + PAGE_SIZE <= end) {
> +               set_pte_at(&init_mm, addr, pte, zero_pte);
> +               addr += PAGE_SIZE;
> +               pte = pte_offset_kernel(pmd, addr);
> +       }
> +       return 0;
> +}
> +
> +static int __init zero_pmd_populate(pud_t *pud, unsigned long addr,
> +                               unsigned long end)
> +{
> +       int ret = 0;
> +       pmd_t *pmd = pmd_offset(pud, addr);
> +       unsigned long next;
> +
> +       do {
> +               next = pmd_addr_end(addr, end);
> +
> +               if (IS_ALIGNED(addr, PMD_SIZE) && end - addr >= PMD_SIZE) {
> +                       pmd_populate_kernel(&init_mm, pmd, kasan_zero_pte);
> +                       continue;
> +               }
> +
> +               if (pmd_none(*pmd)) {
> +                       void *p = early_alloc(PAGE_SIZE, NUMA_NO_NODE);
> +                       if (!p)
> +                               return -ENOMEM;
> +                       pmd_populate_kernel(&init_mm, pmd, p);
> +               }
> +               zero_pte_populate(pmd, addr, pmd_addr_end(addr, end));
> +       } while (pmd++, addr = next, addr != end);
> +
> +       return ret;

In zero_{pgd, pud, pmd}_populate you're not resetting ret variable
used as return value inside function so maybe you don't need ret
variable at all. What about return 0 in the end and -ENOMEM in error
case?



> +}
> +
> +static int __init zero_pud_populate(pgd_t *pgd, unsigned long addr,
> +                               unsigned long end)
> +{
> +       int ret = 0;
> +       pud_t *pud = pud_offset(pgd, addr);
> +       unsigned long next;
> +
> +       do {
> +               next = pud_addr_end(addr, end);
> +               if (IS_ALIGNED(addr, PUD_SIZE) && end - addr >= PUD_SIZE) {
> +                       pmd_t *pmd;
> +
> +                       pud_populate(&init_mm, pud, kasan_zero_pmd);
> +                       pmd = pmd_offset(pud, addr);
> +                       pmd_populate_kernel(&init_mm, pmd, kasan_zero_pte);
> +                       continue;
> +               }
> +
> +               if (pud_none(*pud)) {
> +                       void *p = early_alloc(PAGE_SIZE, NUMA_NO_NODE);
> +                       if (!p)
> +                               return -ENOMEM;
> +                       pud_populate(&init_mm, pud, p);
> +               }
> +               zero_pmd_populate(pud, addr, pud_addr_end(addr, end));
> +       } while (pud++, addr = next, addr != end);
> +
> +       return ret;
> +}
> +
> +static int __init zero_pgd_populate(unsigned long addr, unsigned long end)
> +{
> +       int ret = 0;
> +       pgd_t *pgd = pgd_offset_k(addr);
> +       unsigned long next;
> +
> +       do {
> +               next = pgd_addr_end(addr, end);
> +
> +               if (IS_ALIGNED(addr, PGDIR_SIZE) && end - addr >= PGDIR_SIZE) {
> +                       pud_t *pud;
> +                       pmd_t *pmd;
> +
> +                       /*
> +                        * kasan_zero_pud should be populated with pmds
> +                        * at this moment.
> +                        * [pud,pmd]_populate*() bellow needed only for
> +                        * 3,2 - level page tables where we don't have
> +                        * puds,pmds, so pgd_populate(), pud_populate()
> +                        * is noops.
> +                        */
> +                       pgd_populate(&init_mm, pgd, kasan_zero_pud);
> +                       pud = pud_offset(pgd, addr);
> +                       pud_populate(&init_mm, pud, kasan_zero_pmd);
> +                       pmd = pmd_offset(pud, addr);
> +                       pmd_populate_kernel(&init_mm, pmd, kasan_zero_pte);
> +                       continue;
> +               }
> +
> +               if (pgd_none(*pgd)) {
> +                       void *p = early_alloc(PAGE_SIZE, NUMA_NO_NODE);
> +                       if (!p)
> +                               return -ENOMEM;
> +                       pgd_populate(&init_mm, pgd, p);
> +               }
> +               zero_pud_populate(pgd, addr, next);

But you're not checking return value after zero_pud_populate() and
zero_pmd_populate() that might fail with ENOMEM.
Is it critical here on init or can they be converted to return void?


> +/**
> + * kasan_populate_zero_shadow - populate shadow memory region with
> + *                               kasan_zero_page
> + * @start - start of the memory range to populate
> + * @end   - end of the memory range to populate
> + */
> +void __init kasan_populate_zero_shadow(const void *start, const void *end)
> +{
> +       if (zero_pgd_populate((unsigned long)start, (unsigned long)end))
> +               panic("kasan: unable to map zero shadow!");
> +}
> --
> 2.4.5
>
>
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel



-- 
Best regards, Klimov Alexey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
