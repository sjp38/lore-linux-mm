Return-Path: <SRS0=vc3H=PU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B75ACC43612
	for <linux-mm@archiver.kernel.org>; Sat, 12 Jan 2019 16:48:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5084720870
	for <linux-mm@archiver.kernel.org>; Sat, 12 Jan 2019 16:48:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="MmoDdzRf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5084720870
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B09AF8E0003; Sat, 12 Jan 2019 11:48:32 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A92D28E0002; Sat, 12 Jan 2019 11:48:32 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 95A4E8E0003; Sat, 12 Jan 2019 11:48:32 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5AD5B8E0002
	for <linux-mm@kvack.org>; Sat, 12 Jan 2019 11:48:32 -0500 (EST)
Received: by mail-yw1-f70.google.com with SMTP id t205so9708952ywa.10
        for <linux-mm@kvack.org>; Sat, 12 Jan 2019 08:48:32 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=2kj6Y52tAq4MDG6VVcHL2+/gB3dlFeI6xLmbh8g3fpU=;
        b=UfGP2o1QpqfTAdiJ7KfxQ6CjeY6mjSA9om+spJ5LA361yCZ9W7PHArxWsi6COCMzwb
         6dgodZRIbOmW8Reh7ZH19bl6svuV0oQOZ5zu6AJBkxNcBr+BB+eO4jHCgWam45BgAysg
         V4HJTxRd2LfWF1i91ZRNOorUNr6OCh06uDO6DzjObrtKTSa1DBIxaE70pTXs6YplBBDm
         m0wu4zL0EzdNY0uROLHwoEg9bZMm7O68SFcNbFOsm2Xg9aMjxL5AVVKUqrDne3pI88m6
         nsmNNMO55eTGN2Lxqjn8H78yQfg6hRuQVmJzPhPHbJehAbC3v4y1KDab2CJyQHcdCzrw
         ktfQ==
X-Gm-Message-State: AJcUukcHCQYGVIBLyw5P0U1hNfTvxY0WUNkvGCCQBTjqa/cBA0wCtN04
	bByMiG6jNnPR7TCalzu6P9HV+PsB8F82Q0WFaXFLwPWOWwQ2O9MLWZvkrDw5ZQrHZ3dmSklO+6Q
	vqKwIz9vU7LUu6SncsSFjdILL/95kuJ8EcPQ8DPOmLnXUq+S6s6d/VXepKVjNsNi9rjguBnsZgD
	cmhjiWTly4xWfuujgi1yXfYAZ6/i/Ys9rQkmibCy596SlEcC5VBVBuOXMdWSrqHY3wVeGL8Vyiq
	iW4HM14eB3ko22n26C+jXgyn4Qpwz5dIOuOWp32SHxCpJA4YmtWyecztwylg/oTiptlI7CFhax+
	dywpdnese3YwSy+jP4qwRrJTMuvAItf3qCGl//kjzdl1WNEDk/VpDG2Un2d4FjZ3hjehoVBqiDx
	Q
X-Received: by 2002:a81:99d6:: with SMTP id q205mr18424257ywg.106.1547311711863;
        Sat, 12 Jan 2019 08:48:31 -0800 (PST)
X-Received: by 2002:a81:99d6:: with SMTP id q205mr18424200ywg.106.1547311710513;
        Sat, 12 Jan 2019 08:48:30 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547311710; cv=none;
        d=google.com; s=arc-20160816;
        b=DEaYSgSW8RpPNVJgr48P3x3jXWgv2jhbPGXLhtM2rB0841ZORz8tmOmDAFJSfC/Z5H
         nl3b5xZAk1CQOlOu3Nn13IYjTuaybS9XzJq5JiJlRJ1llNJ9louKeLJlVdnL5tVou+6q
         L2e7JwIDHGZlxix1sKxq6rd2rVyatAXlOgyzQ4NWSTxNxQOn3p8QYl08CZsegyD0arZ8
         +X9yySphXObpo0lE6OWgW5m1VcmByaHpyhw78Cjy8OvCUWr+Cop/D0bu4OFILMgvBr09
         1E7DNVREUTCunS/RMMbIie/raLY8O+8PyVGyI1KAghIKgEx4BipLujLZ9n7TCUtdJLuC
         L4FA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=2kj6Y52tAq4MDG6VVcHL2+/gB3dlFeI6xLmbh8g3fpU=;
        b=SANzUGXNwKB90feAxoz61XdoTP/psDFDMK6VU6n5tr7yj33S7L/NyaRhEK/I6SbnNo
         o4UzmJkExyoICjeivx6zWbYTi3Ki0ga1CX7YMWE75+TEEwXXjj44J4AYGOxRq2othxwS
         BOONTdbt5MAZP0/Ot0uilYv0nT9oaXChQlixY2MfPO/NPol8LnLPsrIS9vpUjWKUnNgT
         hMZFaKUUofQAJpKxaG0GfVi2IsDEao8jDvgLd1YPKOzXgADJDVtjT3RE9hRy2gt3bQ2g
         PY95ItmJBRmqHMJESIQdJ6Uk0CJZB/kRWZRCMbPiCV1RXXExM0qbEFqhloVXZTn+ZuTM
         QXgQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=MmoDdzRf;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v4sor10931019ywd.1.2019.01.12.08.48.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 12 Jan 2019 08:48:30 -0800 (PST)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=MmoDdzRf;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=2kj6Y52tAq4MDG6VVcHL2+/gB3dlFeI6xLmbh8g3fpU=;
        b=MmoDdzRfJ6ZCTcJPXO2FBQl6G815Vasp0FtWGMAqzVQOV6z96WDis44Blrvf7L7uag
         teleuUsIfKSNhOgA18JVYmL1DulfWUN9hCoj789aacR0NZ9GzaXLaYyf3XU0rYhKdXMq
         QtpxP9FD13IIeBXUGN9+e0flVtSK0YZo9XonviMFLo3gGcM4/SC0sjheqTskpOIhjjfi
         bKzeArRefqjBczAC1ZhdWdPW557vTwM8k6WM+18Ub64EJFeasiYzQtQ79d9ti1AwZltm
         UZrVS3DwkRvIn6utEWT/Xm3SZq0V7uJlFgPS5qOQ5TLQxXdbTWKetw9whB4EGcL7ZE+f
         y1aQ==
X-Google-Smtp-Source: ALg8bN57tUgRDOU46hWHBNNh2iAa4DmgsLNcRosuqBpg2wOG++Z02RiVJ57M+wesreBfe7WJ7WVgBPe7NaKKwbQhLv0=
X-Received: by 2002:a81:c144:: with SMTP id e4mr18662792ywl.409.1547311709576;
 Sat, 12 Jan 2019 08:48:29 -0800 (PST)
MIME-Version: 1.0
References: <1547288798-10243-1-git-send-email-anshuman.khandual@arm.com>
In-Reply-To: <1547288798-10243-1-git-send-email-anshuman.khandual@arm.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Sat, 12 Jan 2019 08:48:18 -0800
Message-ID:
 <CALvZod5euX2mW7qgL28YZrTVQ-gYYR83aGKfOyZ9=BEzHwyJOw@mail.gmail.com>
Subject: Re: [PATCH] mm: Introduce GFP_PGTABLE
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, 
	LKML <linux-kernel@vger.kernel.org>, linuxppc-dev@lists.ozlabs.org, 
	linux-arm-kernel@lists.infradead.org, linux-sh@vger.kernel.org, 
	kvmarm@lists.cs.columbia.edu, linux@armlinux.org.uk, catalin.marinas@arm.com, 
	will.deacon@arm.com, mpe@ellerman.id.au, Thomas Gleixner <tglx@linutronix.de>, 
	Ingo Molnar <mingo@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, peterz@infradead.org, 
	christoffer.dall@arm.com, marc.zyngier@arm.com, 
	"Kirill A. Shutemov" <kirill@shutemov.name>, Mike Rapoport <rppt@linux.vnet.ibm.com>, 
	Michal Hocko <mhocko@suse.com>, ard.biesheuvel@linaro.org, mark.rutland@arm.com, 
	steve.capper@arm.com, james.morse@arm.com, robin.murphy@arm.com, 
	aneesh.kumar@linux.ibm.com, Vlastimil Babka <vbabka@suse.cz>, 
	David Rientjes <rientjes@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190112164818.JHr9y6raG9alJH97E9mZ_hUO0YlAujDkgib9mCxDsWY@z>

On Sat, Jan 12, 2019 at 2:27 AM Anshuman Khandual
<anshuman.khandual@arm.com> wrote:
>
> All architectures have been defining their own PGALLOC_GFP as (GFP_KERNEL |
> __GFP_ZERO) and using it for allocating page table pages. This causes some
> code duplication which can be easily avoided. GFP_KERNEL allocated and
> cleared out pages (__GFP_ZERO) are required for page tables on any given
> architecture. This creates a new generic GFP flag flag which can be used
> for any page table page allocation. Does not cause any functional change.
>
> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
> ---
>  arch/arm/include/asm/pgalloc.h               |  8 +++-----
>  arch/arm/mm/mmu.c                            |  2 +-
>  arch/arm64/include/asm/pgalloc.h             |  9 ++++-----
>  arch/arm64/mm/mmu.c                          |  2 +-
>  arch/arm64/mm/pgd.c                          |  4 ++--
>  arch/powerpc/include/asm/book3s/64/pgalloc.h |  4 ++--
>  arch/powerpc/include/asm/pgalloc.h           |  2 --
>  arch/powerpc/mm/pgtable-frag.c               |  4 ++--
>  arch/sh/mm/pgtable.c                         |  6 ++----
>  arch/unicore32/include/asm/pgalloc.h         |  6 ++----
>  arch/x86/kernel/espfix_64.c                  |  6 ++----
>  arch/x86/mm/pgtable.c                        | 14 ++++++--------
>  include/linux/gfp.h                          |  1 +
>  virt/kvm/arm/mmu.c                           |  2 +-
>  14 files changed, 29 insertions(+), 41 deletions(-)
>
> diff --git a/arch/arm/include/asm/pgalloc.h b/arch/arm/include/asm/pgalloc.h
> index 17ab72f..72be6f5 100644
> --- a/arch/arm/include/asm/pgalloc.h
> +++ b/arch/arm/include/asm/pgalloc.h
> @@ -57,8 +57,6 @@ static inline void pud_populate(struct mm_struct *mm, pud_t *pud, pmd_t *pmd)
>  extern pgd_t *pgd_alloc(struct mm_struct *mm);
>  extern void pgd_free(struct mm_struct *mm, pgd_t *pgd);
>
> -#define PGALLOC_GFP    (GFP_KERNEL | __GFP_ZERO)
> -
>  static inline void clean_pte_table(pte_t *pte)
>  {
>         clean_dcache_area(pte + PTE_HWTABLE_PTRS, PTE_HWTABLE_SIZE);
> @@ -85,7 +83,7 @@ pte_alloc_one_kernel(struct mm_struct *mm)
>  {
>         pte_t *pte;
>
> -       pte = (pte_t *)__get_free_page(PGALLOC_GFP);
> +       pte = (pte_t *)__get_free_page(GFP_PGTABLE);
>         if (pte)
>                 clean_pte_table(pte);
>
> @@ -98,9 +96,9 @@ pte_alloc_one(struct mm_struct *mm)
>         struct page *pte;
>
>  #ifdef CONFIG_HIGHPTE
> -       pte = alloc_pages(PGALLOC_GFP | __GFP_HIGHMEM, 0);
> +       pte = alloc_pages(GFP_PGTABLE | __GFP_HIGHMEM, 0);
>  #else
> -       pte = alloc_pages(PGALLOC_GFP, 0);
> +       pte = alloc_pages(GFP_PGTABLE, 0);
>  #endif
>         if (!pte)
>                 return NULL;
> diff --git a/arch/arm/mm/mmu.c b/arch/arm/mm/mmu.c
> index f5cc1cc..6d47784 100644
> --- a/arch/arm/mm/mmu.c
> +++ b/arch/arm/mm/mmu.c
> @@ -733,7 +733,7 @@ static void __init *early_alloc(unsigned long sz)
>
>  static void *__init late_alloc(unsigned long sz)
>  {
> -       void *ptr = (void *)__get_free_pages(PGALLOC_GFP, get_order(sz));
> +       void *ptr = (void *)__get_free_pages(GFP_PGTABLE, get_order(sz));
>
>         if (!ptr || !pgtable_page_ctor(virt_to_page(ptr)))
>                 BUG();
> diff --git a/arch/arm64/include/asm/pgalloc.h b/arch/arm64/include/asm/pgalloc.h
> index 52fa47c..d5c75bf 100644
> --- a/arch/arm64/include/asm/pgalloc.h
> +++ b/arch/arm64/include/asm/pgalloc.h
> @@ -26,14 +26,13 @@
>
>  #define check_pgt_cache()              do { } while (0)
>
> -#define PGALLOC_GFP    (GFP_KERNEL | __GFP_ZERO)
>  #define PGD_SIZE       (PTRS_PER_PGD * sizeof(pgd_t))
>
>  #if CONFIG_PGTABLE_LEVELS > 2
>
>  static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
>  {
> -       return (pmd_t *)__get_free_page(PGALLOC_GFP);
> +       return (pmd_t *)__get_free_page(GFP_PGTABLE);
>  }
>
>  static inline void pmd_free(struct mm_struct *mm, pmd_t *pmdp)
> @@ -62,7 +61,7 @@ static inline void __pud_populate(pud_t *pudp, phys_addr_t pmdp, pudval_t prot)
>
>  static inline pud_t *pud_alloc_one(struct mm_struct *mm, unsigned long addr)
>  {
> -       return (pud_t *)__get_free_page(PGALLOC_GFP);
> +       return (pud_t *)__get_free_page(GFP_PGTABLE);
>  }
>
>  static inline void pud_free(struct mm_struct *mm, pud_t *pudp)
> @@ -93,7 +92,7 @@ extern void pgd_free(struct mm_struct *mm, pgd_t *pgdp);
>  static inline pte_t *
>  pte_alloc_one_kernel(struct mm_struct *mm)
>  {
> -       return (pte_t *)__get_free_page(PGALLOC_GFP);
> +       return (pte_t *)__get_free_page(GFP_PGTABLE);
>  }
>
>  static inline pgtable_t
> @@ -101,7 +100,7 @@ pte_alloc_one(struct mm_struct *mm)
>  {
>         struct page *pte;
>
> -       pte = alloc_pages(PGALLOC_GFP, 0);
> +       pte = alloc_pages(GFP_PGTABLE, 0);
>         if (!pte)
>                 return NULL;
>         if (!pgtable_page_ctor(pte)) {
> diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
> index b6f5aa5..07b1c0f 100644
> --- a/arch/arm64/mm/mmu.c
> +++ b/arch/arm64/mm/mmu.c
> @@ -372,7 +372,7 @@ static void __create_pgd_mapping(pgd_t *pgdir, phys_addr_t phys,
>
>  static phys_addr_t pgd_pgtable_alloc(void)
>  {
> -       void *ptr = (void *)__get_free_page(PGALLOC_GFP);
> +       void *ptr = (void *)__get_free_page(GFP_PGTABLE);
>         if (!ptr || !pgtable_page_ctor(virt_to_page(ptr)))
>                 BUG();
>
> diff --git a/arch/arm64/mm/pgd.c b/arch/arm64/mm/pgd.c
> index 289f911..5b28e2b 100644
> --- a/arch/arm64/mm/pgd.c
> +++ b/arch/arm64/mm/pgd.c
> @@ -31,9 +31,9 @@ static struct kmem_cache *pgd_cache __ro_after_init;
>  pgd_t *pgd_alloc(struct mm_struct *mm)
>  {
>         if (PGD_SIZE == PAGE_SIZE)
> -               return (pgd_t *)__get_free_page(PGALLOC_GFP);
> +               return (pgd_t *)__get_free_page(GFP_PGTABLE);
>         else
> -               return kmem_cache_alloc(pgd_cache, PGALLOC_GFP);
> +               return kmem_cache_alloc(pgd_cache, GFP_PGTABLE);
>  }
>
>  void pgd_free(struct mm_struct *mm, pgd_t *pgd)
> diff --git a/arch/powerpc/include/asm/book3s/64/pgalloc.h b/arch/powerpc/include/asm/book3s/64/pgalloc.h
> index 9c11732..8a7235e 100644
> --- a/arch/powerpc/include/asm/book3s/64/pgalloc.h
> +++ b/arch/powerpc/include/asm/book3s/64/pgalloc.h
> @@ -52,10 +52,10 @@ void pte_frag_destroy(void *pte_frag);
>  static inline pgd_t *radix__pgd_alloc(struct mm_struct *mm)
>  {
>  #ifdef CONFIG_PPC_64K_PAGES
> -       return (pgd_t *)__get_free_page(pgtable_gfp_flags(mm, PGALLOC_GFP));
> +       return (pgd_t *)__get_free_page(pgtable_gfp_flags(mm, GFP_PGTABLE));
>  #else
>         struct page *page;
> -       page = alloc_pages(pgtable_gfp_flags(mm, PGALLOC_GFP | __GFP_RETRY_MAYFAIL),
> +       page = alloc_pages(pgtable_gfp_flags(mm, GFP_PGTABLE | __GFP_RETRY_MAYFAIL),
>                                 4);
>         if (!page)
>                 return NULL;
> diff --git a/arch/powerpc/include/asm/pgalloc.h b/arch/powerpc/include/asm/pgalloc.h
> index e11f030..3b11e8b 100644
> --- a/arch/powerpc/include/asm/pgalloc.h
> +++ b/arch/powerpc/include/asm/pgalloc.h
> @@ -18,8 +18,6 @@ static inline gfp_t pgtable_gfp_flags(struct mm_struct *mm, gfp_t gfp)
>  }
>  #endif /* MODULE */
>
> -#define PGALLOC_GFP (GFP_KERNEL | __GFP_ZERO)
> -
>  #ifdef CONFIG_PPC_BOOK3S
>  #include <asm/book3s/pgalloc.h>
>  #else
> diff --git a/arch/powerpc/mm/pgtable-frag.c b/arch/powerpc/mm/pgtable-frag.c
> index a7b0521..211aaa7 100644
> --- a/arch/powerpc/mm/pgtable-frag.c
> +++ b/arch/powerpc/mm/pgtable-frag.c
> @@ -58,7 +58,7 @@ static pte_t *__alloc_for_ptecache(struct mm_struct *mm, int kernel)
>         struct page *page;
>
>         if (!kernel) {
> -               page = alloc_page(PGALLOC_GFP | __GFP_ACCOUNT);
> +               page = alloc_page(GFP_PGTABLE | __GFP_ACCOUNT);
>                 if (!page)
>                         return NULL;
>                 if (!pgtable_page_ctor(page)) {
> @@ -66,7 +66,7 @@ static pte_t *__alloc_for_ptecache(struct mm_struct *mm, int kernel)
>                         return NULL;
>                 }
>         } else {
> -               page = alloc_page(PGALLOC_GFP);
> +               page = alloc_page(GFP_PGTABLE);
>                 if (!page)
>                         return NULL;
>         }
> diff --git a/arch/sh/mm/pgtable.c b/arch/sh/mm/pgtable.c
> index 5c8f924..324732dc5 100644
> --- a/arch/sh/mm/pgtable.c
> +++ b/arch/sh/mm/pgtable.c
> @@ -2,8 +2,6 @@
>  #include <linux/mm.h>
>  #include <linux/slab.h>
>
> -#define PGALLOC_GFP GFP_KERNEL | __GFP_ZERO
> -
>  static struct kmem_cache *pgd_cachep;
>  #if PAGETABLE_LEVELS > 2
>  static struct kmem_cache *pmd_cachep;
> @@ -32,7 +30,7 @@ void pgtable_cache_init(void)
>
>  pgd_t *pgd_alloc(struct mm_struct *mm)
>  {
> -       return kmem_cache_alloc(pgd_cachep, PGALLOC_GFP);
> +       return kmem_cache_alloc(pgd_cachep, GFP_PGTABLE);
>  }
>
>  void pgd_free(struct mm_struct *mm, pgd_t *pgd)
> @@ -48,7 +46,7 @@ void pud_populate(struct mm_struct *mm, pud_t *pud, pmd_t *pmd)
>
>  pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long address)
>  {
> -       return kmem_cache_alloc(pmd_cachep, PGALLOC_GFP);
> +       return kmem_cache_alloc(pmd_cachep, GFP_PGTABLE);
>  }
>
>  void pmd_free(struct mm_struct *mm, pmd_t *pmd)
> diff --git a/arch/unicore32/include/asm/pgalloc.h b/arch/unicore32/include/asm/pgalloc.h
> index 7cceabe..a3506e5 100644
> --- a/arch/unicore32/include/asm/pgalloc.h
> +++ b/arch/unicore32/include/asm/pgalloc.h
> @@ -28,8 +28,6 @@ extern void free_pgd_slow(struct mm_struct *mm, pgd_t *pgd);
>  #define pgd_alloc(mm)                  get_pgd_slow(mm)
>  #define pgd_free(mm, pgd)              free_pgd_slow(mm, pgd)
>
> -#define PGALLOC_GFP    (GFP_KERNEL | __GFP_ZERO)
> -
>  /*
>   * Allocate one PTE table.
>   */
> @@ -38,7 +36,7 @@ pte_alloc_one_kernel(struct mm_struct *mm)
>  {
>         pte_t *pte;
>
> -       pte = (pte_t *)__get_free_page(PGALLOC_GFP);
> +       pte = (pte_t *)__get_free_page(GFP_PGTABLE);
>         if (pte)
>                 clean_dcache_area(pte, PTRS_PER_PTE * sizeof(pte_t));
>
> @@ -50,7 +48,7 @@ pte_alloc_one(struct mm_struct *mm)
>  {
>         struct page *pte;
>
> -       pte = alloc_pages(PGALLOC_GFP, 0);
> +       pte = alloc_pages(GFP_PGTABLE, 0);
>         if (!pte)
>                 return NULL;
>         if (!PageHighMem(pte)) {
> diff --git a/arch/x86/kernel/espfix_64.c b/arch/x86/kernel/espfix_64.c
> index aebd0d5..dae28cc 100644
> --- a/arch/x86/kernel/espfix_64.c
> +++ b/arch/x86/kernel/espfix_64.c
> @@ -57,8 +57,6 @@
>  # error "Need more virtual address space for the ESPFIX hack"
>  #endif
>
> -#define PGALLOC_GFP (GFP_KERNEL | __GFP_ZERO)
> -
>  /* This contains the *bottom* address of the espfix stack */
>  DEFINE_PER_CPU_READ_MOSTLY(unsigned long, espfix_stack);
>  DEFINE_PER_CPU_READ_MOSTLY(unsigned long, espfix_waddr);
> @@ -172,7 +170,7 @@ void init_espfix_ap(int cpu)
>         pud_p = &espfix_pud_page[pud_index(addr)];
>         pud = *pud_p;
>         if (!pud_present(pud)) {
> -               struct page *page = alloc_pages_node(node, PGALLOC_GFP, 0);
> +               struct page *page = alloc_pages_node(node, GFP_PGTABLE, 0);
>
>                 pmd_p = (pmd_t *)page_address(page);
>                 pud = __pud(__pa(pmd_p) | (PGTABLE_PROT & ptemask));
> @@ -184,7 +182,7 @@ void init_espfix_ap(int cpu)
>         pmd_p = pmd_offset(&pud, addr);
>         pmd = *pmd_p;
>         if (!pmd_present(pmd)) {
> -               struct page *page = alloc_pages_node(node, PGALLOC_GFP, 0);
> +               struct page *page = alloc_pages_node(node, GFP_PGTABLE, 0);
>
>                 pte_p = (pte_t *)page_address(page);
>                 pmd = __pmd(__pa(pte_p) | (PGTABLE_PROT & ptemask));
> diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
> index 7bd0170..d608b03 100644
> --- a/arch/x86/mm/pgtable.c
> +++ b/arch/x86/mm/pgtable.c
> @@ -13,19 +13,17 @@ phys_addr_t physical_mask __ro_after_init = (1ULL << __PHYSICAL_MASK_SHIFT) - 1;
>  EXPORT_SYMBOL(physical_mask);
>  #endif
>
> -#define PGALLOC_GFP (GFP_KERNEL_ACCOUNT | __GFP_ZERO)
> -

You have silently dropped __GFP_ACCOUNT from all the allocations in this file.

BTW why other archs not using __GFP_ACCOUNT for the user page tables?

>  #ifdef CONFIG_HIGHPTE
>  #define PGALLOC_USER_GFP __GFP_HIGHMEM
>  #else
>  #define PGALLOC_USER_GFP 0
>  #endif
>
> -gfp_t __userpte_alloc_gfp = PGALLOC_GFP | PGALLOC_USER_GFP;
> +gfp_t __userpte_alloc_gfp = GFP_PGTABLE | PGALLOC_USER_GFP;
>
>  pte_t *pte_alloc_one_kernel(struct mm_struct *mm)
>  {
> -       return (pte_t *)__get_free_page(PGALLOC_GFP & ~__GFP_ACCOUNT);
> +       return (pte_t *)__get_free_page(GFP_PGTABLE & ~__GFP_ACCOUNT);
>  }
>
>  pgtable_t pte_alloc_one(struct mm_struct *mm)
> @@ -235,7 +233,7 @@ static int preallocate_pmds(struct mm_struct *mm, pmd_t *pmds[], int count)
>  {
>         int i;
>         bool failed = false;
> -       gfp_t gfp = PGALLOC_GFP;
> +       gfp_t gfp = GFP_PGTABLE;
>
>         if (mm == &init_mm)
>                 gfp &= ~__GFP_ACCOUNT;
> @@ -401,14 +399,14 @@ static inline pgd_t *_pgd_alloc(void)
>          * We allocate one page for pgd.
>          */
>         if (!SHARED_KERNEL_PMD)
> -               return (pgd_t *)__get_free_pages(PGALLOC_GFP,
> +               return (pgd_t *)__get_free_pages(GFP_PGTABLE,
>                                                  PGD_ALLOCATION_ORDER);
>
>         /*
>          * Now PAE kernel is not running as a Xen domain. We can allocate
>          * a 32-byte slab for pgd to save memory space.
>          */
> -       return kmem_cache_alloc(pgd_cache, PGALLOC_GFP);
> +       return kmem_cache_alloc(pgd_cache, GFP_PGTABLE);
>  }
>
>  static inline void _pgd_free(pgd_t *pgd)
> @@ -422,7 +420,7 @@ static inline void _pgd_free(pgd_t *pgd)
>
>  static inline pgd_t *_pgd_alloc(void)
>  {
> -       return (pgd_t *)__get_free_pages(PGALLOC_GFP, PGD_ALLOCATION_ORDER);
> +       return (pgd_t *)__get_free_pages(GFP_PGTABLE, PGD_ALLOCATION_ORDER);
>  }
>
>  static inline void _pgd_free(pgd_t *pgd)
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 5f5e25f..a8414be 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -300,6 +300,7 @@ struct vm_area_struct;
>  #define GFP_TRANSHUGE_LIGHT    ((GFP_HIGHUSER_MOVABLE | __GFP_COMP | \
>                          __GFP_NOMEMALLOC | __GFP_NOWARN) & ~__GFP_RECLAIM)
>  #define GFP_TRANSHUGE  (GFP_TRANSHUGE_LIGHT | __GFP_DIRECT_RECLAIM)
> +#define GFP_PGTABLE    (GFP_KERNEL | __GFP_ZERO)
>
>  /* Convert GFP flags to their corresponding migrate type */
>  #define GFP_MOVABLE_MASK (__GFP_RECLAIMABLE|__GFP_MOVABLE)
> diff --git a/virt/kvm/arm/mmu.c b/virt/kvm/arm/mmu.c
> index fbdf3ac..f60a5b8 100644
> --- a/virt/kvm/arm/mmu.c
> +++ b/virt/kvm/arm/mmu.c
> @@ -143,7 +143,7 @@ static int mmu_topup_memory_cache(struct kvm_mmu_memory_cache *cache,
>         if (cache->nobjs >= min)
>                 return 0;
>         while (cache->nobjs < max) {
> -               page = (void *)__get_free_page(PGALLOC_GFP);
> +               page = (void *)__get_free_page(GFP_PGTABLE);
>                 if (!page)
>                         return -ENOMEM;
>                 cache->objects[cache->nobjs++] = page;
> --
> 2.7.4
>

