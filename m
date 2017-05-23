Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id E1D6D83292
	for <linux-mm@kvack.org>; Tue, 23 May 2017 06:40:50 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id k11so58155139qtk.4
        for <linux-mm@kvack.org>; Tue, 23 May 2017 03:40:50 -0700 (PDT)
Received: from mail-qk0-x244.google.com (mail-qk0-x244.google.com. [2607:f8b0:400d:c09::244])
        by mx.google.com with ESMTPS id h12si21220613qte.190.2017.05.23.03.40.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 May 2017 03:40:50 -0700 (PDT)
Received: by mail-qk0-x244.google.com with SMTP id k74so22339004qke.2
        for <linux-mm@kvack.org>; Tue, 23 May 2017 03:40:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170523040524.13717-4-oohall@gmail.com>
References: <20170523040524.13717-1-oohall@gmail.com> <20170523040524.13717-4-oohall@gmail.com>
From: Balbir Singh <bsingharora@gmail.com>
Date: Tue, 23 May 2017 20:40:48 +1000
Message-ID: <CAKTCnz=tbEYossD8X5z87UEYCLfz4ah+6hZSDRcnXbDmjRqN+Q@mail.gmail.com>
Subject: Re: [PATCH 4/6] powerpc/mm: Add devmap support for ppc64
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oliver O'Halloran <oohall@gmail.com>
Cc: "open list:LINUX FOR POWERPC (32-BIT AND 64-BIT)" <linuxppc-dev@lists.ozlabs.org>, linux-mm <linux-mm@kvack.org>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>

On Tue, May 23, 2017 at 2:05 PM, Oliver O'Halloran <oohall@gmail.com> wrote:
> Add support for the devmap bit on PTEs and PMDs for PPC64 Book3S.  This
> is used to differentiate device backed memory from transparent huge
> pages since they are handled in more or less the same manner by the core
> mm code.
>
> Cc: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> Signed-off-by: Oliver O'Halloran <oohall@gmail.com>
> ---
> v1 -> v2: Properly differentiate THP and PMD Devmap entries. The
> mm core assumes that pmd_trans_huge() and pmd_devmap() are mutually
> exclusive and v1 had pmd_trans_huge() being true on a devmap pmd.
>
> Aneesh, this has been fleshed out substantially since v1. Can you
> re-review it? Also no explicit gup support is required in this patch
> since devmap support was added generic GUP as a part of making x86 use
> the generic version.
> ---
>  arch/powerpc/include/asm/book3s/64/hash-64k.h |  2 +-
>  arch/powerpc/include/asm/book3s/64/pgtable.h  | 37 ++++++++++++++++++++++++++-
>  arch/powerpc/include/asm/book3s/64/radix.h    |  2 +-
>  arch/powerpc/mm/hugetlbpage.c                 |  2 +-
>  arch/powerpc/mm/pgtable-book3s64.c            |  4 +--
>  arch/powerpc/mm/pgtable-hash64.c              |  4 ++-
>  arch/powerpc/mm/pgtable-radix.c               |  3 ++-
>  arch/powerpc/mm/pgtable_64.c                  |  2 +-
>  8 files changed, 47 insertions(+), 9 deletions(-)
>
> diff --git a/arch/powerpc/include/asm/book3s/64/hash-64k.h b/arch/powerpc/include/asm/book3s/64/hash-64k.h
> index 9732837aaae8..eaaf613c5347 100644
> --- a/arch/powerpc/include/asm/book3s/64/hash-64k.h
> +++ b/arch/powerpc/include/asm/book3s/64/hash-64k.h
> @@ -180,7 +180,7 @@ static inline void mark_hpte_slot_valid(unsigned char *hpte_slot_array,
>   */
>  static inline int hash__pmd_trans_huge(pmd_t pmd)
>  {
> -       return !!((pmd_val(pmd) & (_PAGE_PTE | H_PAGE_THP_HUGE)) ==
> +       return !!((pmd_val(pmd) & (_PAGE_PTE | H_PAGE_THP_HUGE | _PAGE_DEVMAP)) ==
>                   (_PAGE_PTE | H_PAGE_THP_HUGE));
>  }

Like Aneesh suggested, I think we can probably skip this check here

>
> diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
> index 85bc9875c3be..24634e92dd0b 100644
> --- a/arch/powerpc/include/asm/book3s/64/pgtable.h
> +++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
> @@ -79,6 +79,9 @@
>
>  #define _PAGE_SOFT_DIRTY       _RPAGE_SW3 /* software: software dirty tracking */
>  #define _PAGE_SPECIAL          _RPAGE_SW2 /* software: special page */
> +#define _PAGE_DEVMAP           _RPAGE_SW1
> +#define __HAVE_ARCH_PTE_DEVMAP
> +
>  /*
>   * Drivers request for cache inhibited pte mapping using _PAGE_NO_CACHE
>   * Instead of fixing all of them, add an alternate define which
> @@ -599,6 +602,16 @@ static inline pte_t pte_mkhuge(pte_t pte)
>         return pte;
>  }
>
> +static inline pte_t pte_mkdevmap(pte_t pte)
> +{
> +       return __pte(pte_val(pte) | _PAGE_SPECIAL|_PAGE_DEVMAP);
> +}
> +
> +static inline int pte_devmap(pte_t pte)
> +{
> +       return !!(pte_raw(pte) & cpu_to_be64(_PAGE_DEVMAP));
> +}
> +
>  static inline pte_t pte_modify(pte_t pte, pgprot_t newprot)
>  {
>         /* FIXME!! check whether this need to be a conditional */
> @@ -963,6 +976,9 @@ static inline pte_t *pmdp_ptep(pmd_t *pmd)
>  #define pmd_mk_savedwrite(pmd) pte_pmd(pte_mk_savedwrite(pmd_pte(pmd)))
>  #define pmd_clear_savedwrite(pmd)      pte_pmd(pte_clear_savedwrite(pmd_pte(pmd)))
>
> +#define pud_pfn(...) (0)
> +#define pgd_pfn(...) (0)
> +

Don't get these bits.. why are they zero?

>  #ifdef CONFIG_HAVE_ARCH_SOFT_DIRTY
>  #define pmd_soft_dirty(pmd)    pte_soft_dirty(pmd_pte(pmd))
>  #define pmd_mksoft_dirty(pmd)  pte_pmd(pte_mksoft_dirty(pmd_pte(pmd)))
> @@ -1137,7 +1153,6 @@ static inline int pmd_move_must_withdraw(struct spinlock *new_pmd_ptl,
>         return true;
>  }
>
> -
>  #define arch_needs_pgtable_deposit arch_needs_pgtable_deposit
>  static inline bool arch_needs_pgtable_deposit(void)
>  {
> @@ -1146,6 +1161,26 @@ static inline bool arch_needs_pgtable_deposit(void)
>         return true;
>  }
>
> +static inline pmd_t pmd_mkdevmap(pmd_t pmd)
> +{
> +       return pte_pmd(pte_mkdevmap(pmd_pte(pmd)));
> +}
> +
> +static inline int pmd_devmap(pmd_t pmd)
> +{
> +       return pte_devmap(pmd_pte(pmd));
> +}

This should be defined only if #ifdef __HAVE_ARCH_PTE_DEVMAP

The rest looks OK

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
