Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id AF8766B007E
	for <linux-mm@kvack.org>; Tue, 19 Apr 2016 05:35:27 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id a125so10948682wmd.0
        for <linux-mm@kvack.org>; Tue, 19 Apr 2016 02:35:27 -0700 (PDT)
Received: from mail-lf0-x234.google.com (mail-lf0-x234.google.com. [2a00:1450:4010:c07::234])
        by mx.google.com with ESMTPS id k198si26105766lfe.167.2016.04.19.02.35.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Apr 2016 02:35:26 -0700 (PDT)
Received: by mail-lf0-x234.google.com with SMTP id c126so11957388lfb.2
        for <linux-mm@kvack.org>; Tue, 19 Apr 2016 02:35:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1460995497-24312-2-git-send-email-ard.biesheuvel@linaro.org>
References: <1460995497-24312-1-git-send-email-ard.biesheuvel@linaro.org>
	<1460995497-24312-2-git-send-email-ard.biesheuvel@linaro.org>
Date: Tue, 19 Apr 2016 17:35:25 +0800
Message-ID: <CAFiDJ58eUik19bLmP-rEjs5ohNm1BziuCX9815TEoWSCwgpyjQ@mail.gmail.com>
Subject: Re: [PATCH resend 1/3] nios2: use correct void* return type for page_to_virt()
From: Ley Foon Tan <lftan@altera.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Jonas Bonn <jonas@southpole.se>, will.deacon@arm.com

On Tue, Apr 19, 2016 at 12:04 AM, Ard Biesheuvel
<ard.biesheuvel@linaro.org> wrote:
>
> To align with other architectures, the expression produced by expanding
> the macro page_to_virt() should be of type void*, since it returns a
> virtual address. Fix that, and also fix up an instance where page_to_virt
> was expected to return 'unsigned long', and drop another instance that was
> entirely unused (page_to_bus)
>
> Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
> ---
>  arch/nios2/include/asm/io.h      | 1 -
>  arch/nios2/include/asm/page.h    | 2 +-
>  arch/nios2/include/asm/pgtable.h | 2 +-
>  3 files changed, 2 insertions(+), 3 deletions(-)
>
> diff --git a/arch/nios2/include/asm/io.h b/arch/nios2/include/asm/io.h
> index c5a62da22cd2..ce072ba0f8dd 100644
> --- a/arch/nios2/include/asm/io.h
> +++ b/arch/nios2/include/asm/io.h
> @@ -50,7 +50,6 @@ static inline void iounmap(void __iomem *addr)
>
>  /* Pages to physical address... */
>  #define page_to_phys(page)     virt_to_phys(page_to_virt(page))
> -#define page_to_bus(page)      page_to_virt(page)
>
>  /* Macros used for converting between virtual and physical mappings. */
>  #define phys_to_virt(vaddr)    \
> diff --git a/arch/nios2/include/asm/page.h b/arch/nios2/include/asm/page.h
> index 4b32d6fd9d98..c1683f51ad0f 100644
> --- a/arch/nios2/include/asm/page.h
> +++ b/arch/nios2/include/asm/page.h
> @@ -84,7 +84,7 @@ extern struct page *mem_map;
>         ((void *)((unsigned long)(x) + PAGE_OFFSET - PHYS_OFFSET))
>
>  #define page_to_virt(page)     \
> -       ((((page) - mem_map) << PAGE_SHIFT) + PAGE_OFFSET)
> +       ((void *)(((page) - mem_map) << PAGE_SHIFT) + PAGE_OFFSET)
>
>  # define pfn_to_kaddr(pfn)     __va((pfn) << PAGE_SHIFT)
>  # define pfn_valid(pfn)                ((pfn) >= ARCH_PFN_OFFSET &&    \
> diff --git a/arch/nios2/include/asm/pgtable.h b/arch/nios2/include/asm/pgtable.h
> index a213e8c9aad0..298393c3cb42 100644
> --- a/arch/nios2/include/asm/pgtable.h
> +++ b/arch/nios2/include/asm/pgtable.h
> @@ -209,7 +209,7 @@ static inline void set_pte(pte_t *ptep, pte_t pteval)
>  static inline void set_pte_at(struct mm_struct *mm, unsigned long addr,
>                               pte_t *ptep, pte_t pteval)
>  {
> -       unsigned long paddr = page_to_virt(pte_page(pteval));
> +       unsigned long paddr = (unsigned long)page_to_virt(pte_page(pteval));
>
>         flush_dcache_range(paddr, paddr + PAGE_SIZE);
>         set_pte(ptep, pteval);
> --
Acked-by: Ley Foon Tan <lftan@altera.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
