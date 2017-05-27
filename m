Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 37F6A6B0292
	for <linux-mm@kvack.org>; Sat, 27 May 2017 11:09:56 -0400 (EDT)
Received: by mail-ua0-f198.google.com with SMTP id x47so8739439uab.14
        for <linux-mm@kvack.org>; Sat, 27 May 2017 08:09:56 -0700 (PDT)
Received: from mail-ua0-x243.google.com (mail-ua0-x243.google.com. [2607:f8b0:400c:c08::243])
        by mx.google.com with ESMTPS id e17si1799474vkf.84.2017.05.27.08.09.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 27 May 2017 08:09:55 -0700 (PDT)
Received: by mail-ua0-x243.google.com with SMTP id j17so2443574uag.1
        for <linux-mm@kvack.org>; Sat, 27 May 2017 08:09:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170525203334.867-6-kirill.shutemov@linux.intel.com>
References: <20170525203334.867-1-kirill.shutemov@linux.intel.com> <20170525203334.867-6-kirill.shutemov@linux.intel.com>
From: Brian Gerst <brgerst@gmail.com>
Date: Sat, 27 May 2017 11:09:54 -0400
Message-ID: <CAMzpN2j+CMCn-5pgEVZBNm9JMK1GEodvXqEtpAB2NXwTTHSM6g@mail.gmail.com>
Subject: Re: [PATCHv1, RFC 5/8] x86/mm: Fold p4d page table layer at runtime
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, the arch/x86 maintainers <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch <linux-arch@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, May 25, 2017 at 4:33 PM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
> This patch changes page table helpers to fold p4d at runtime.
> The logic is the same as in <asm-generic/pgtable-nop4d.h>.
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  arch/x86/include/asm/paravirt.h |  3 ++-
>  arch/x86/include/asm/pgalloc.h  |  5 ++++-
>  arch/x86/include/asm/pgtable.h  | 10 +++++++++-
>  3 files changed, 15 insertions(+), 3 deletions(-)
>
> diff --git a/arch/x86/include/asm/paravirt.h b/arch/x86/include/asm/paravirt.h
> index 55fa56fe4e45..e934ed6dc036 100644
> --- a/arch/x86/include/asm/paravirt.h
> +++ b/arch/x86/include/asm/paravirt.h
> @@ -615,7 +615,8 @@ static inline void set_pgd(pgd_t *pgdp, pgd_t pgd)
>
>  static inline void pgd_clear(pgd_t *pgdp)
>  {
> -       set_pgd(pgdp, __pgd(0));
> +       if (!p4d_folded)
> +               set_pgd(pgdp, __pgd(0));
>  }
>
>  #endif  /* CONFIG_PGTABLE_LEVELS == 5 */
> diff --git a/arch/x86/include/asm/pgalloc.h b/arch/x86/include/asm/pgalloc.h
> index b2d0cd8288aa..5c42262169d0 100644
> --- a/arch/x86/include/asm/pgalloc.h
> +++ b/arch/x86/include/asm/pgalloc.h
> @@ -155,6 +155,8 @@ static inline void __pud_free_tlb(struct mmu_gather *tlb, pud_t *pud,
>  #if CONFIG_PGTABLE_LEVELS > 4
>  static inline void pgd_populate(struct mm_struct *mm, pgd_t *pgd, p4d_t *p4d)
>  {
> +       if (p4d_folded)
> +               return;
>         paravirt_alloc_p4d(mm, __pa(p4d) >> PAGE_SHIFT);
>         set_pgd(pgd, __pgd(_PAGE_TABLE | __pa(p4d)));
>  }
> @@ -179,7 +181,8 @@ extern void ___p4d_free_tlb(struct mmu_gather *tlb, p4d_t *p4d);
>  static inline void __p4d_free_tlb(struct mmu_gather *tlb, p4d_t *p4d,
>                                   unsigned long address)
>  {
> -       ___p4d_free_tlb(tlb, p4d);
> +       if (!p4d_folded)
> +               ___p4d_free_tlb(tlb, p4d);
>  }
>
>  #endif /* CONFIG_PGTABLE_LEVELS > 4 */
> diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
> index 77037b6f1caa..4516a1bdcc31 100644
> --- a/arch/x86/include/asm/pgtable.h
> +++ b/arch/x86/include/asm/pgtable.h
> @@ -53,7 +53,7 @@ extern struct mm_struct *pgd_page_get_mm(struct page *page);
>
>  #ifndef __PAGETABLE_P4D_FOLDED
>  #define set_pgd(pgdp, pgd)             native_set_pgd(pgdp, pgd)
> -#define pgd_clear(pgd)                 native_pgd_clear(pgd)
> +#define pgd_clear(pgd)                 (!p4d_folded ? native_pgd_clear(pgd) : 0)
>  #endif
>
>  #ifndef set_p4d
> @@ -847,6 +847,8 @@ static inline unsigned long p4d_index(unsigned long address)
>  #if CONFIG_PGTABLE_LEVELS > 4
>  static inline int pgd_present(pgd_t pgd)
>  {
> +       if (p4d_folded)
> +               return 1;
>         return pgd_flags(pgd) & _PAGE_PRESENT;
>  }
>
> @@ -864,16 +866,22 @@ static inline unsigned long pgd_page_vaddr(pgd_t pgd)
>  /* to find an entry in a page-table-directory. */
>  static inline p4d_t *p4d_offset(pgd_t *pgd, unsigned long address)
>  {
> +       if (p4d_folded)
> +               return (p4d_t *)pgd;
>         return (p4d_t *)pgd_page_vaddr(*pgd) + p4d_index(address);
>  }
>
>  static inline int pgd_bad(pgd_t pgd)
>  {
> +       if (p4d_folded)
> +               return 0;
>         return (pgd_flags(pgd) & ~_PAGE_USER) != _KERNPG_TABLE;
>  }
>
>  static inline int pgd_none(pgd_t pgd)
>  {
> +       if (p4d_folded)
> +               return 0;
>         /*
>          * There is no need to do a workaround for the KNL stray
>          * A/D bit erratum here.  PGDs only point to page tables

These should use static_cpu_has(X86_FEATURE_LA57), so that it gets
patched by alternatives.

--
Brian Gerst

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
