Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id EFE3E831F4
	for <linux-mm@kvack.org>; Mon, 22 May 2017 09:59:44 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id h4so165018191oib.5
        for <linux-mm@kvack.org>; Mon, 22 May 2017 06:59:44 -0700 (PDT)
Received: from mail-oi0-x243.google.com (mail-oi0-x243.google.com. [2607:f8b0:4003:c06::243])
        by mx.google.com with ESMTPS id j28si3266028oth.264.2017.05.22.06.59.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 May 2017 06:59:44 -0700 (PDT)
Received: by mail-oi0-x243.google.com with SMTP id w10so22831949oif.1
        for <linux-mm@kvack.org>; Mon, 22 May 2017 06:59:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170522133604.11392-5-punit.agrawal@arm.com>
References: <20170522133604.11392-1-punit.agrawal@arm.com> <20170522133604.11392-5-punit.agrawal@arm.com>
From: Arnd Bergmann <arnd@arndb.de>
Date: Mon, 22 May 2017 15:59:43 +0200
Message-ID: <CAK8P3a3d=Yx3_stYiz25Qeh8wfFr5EGuGYGfCoXqrQPxz6oUAQ@mail.gmail.com>
Subject: Re: [PATCH v3 4/6] mm/hugetlb: Allow architectures to override huge_pte_clear()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Punit Agrawal <punit.agrawal@arm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, n-horiguchi@ah.jp.nec.com, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, mike.kravetz@oracle.com, steve.capper@arm.com, Mark Rutland <mark.rutland@arm.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-arch <linux-arch@vger.kernel.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>

On Mon, May 22, 2017 at 3:36 PM, Punit Agrawal <punit.agrawal@arm.com> wrote:
> diff --git a/include/asm-generic/hugetlb.h b/include/asm-generic/hugetlb.h
> index 99b490b4d05a..3138e126f43b 100644
> --- a/include/asm-generic/hugetlb.h
> +++ b/include/asm-generic/hugetlb.h
> @@ -31,10 +31,7 @@ static inline pte_t huge_pte_modify(pte_t pte, pgprot_t newprot)
>         return pte_modify(pte, newprot);
>  }
>
> -static inline void huge_pte_clear(struct mm_struct *mm, unsigned long addr,
> -                                 pte_t *ptep)
> -{
> -       pte_clear(mm, addr, ptep);
> -}
> +void huge_pte_clear(struct mm_struct *mm, unsigned long addr,
> +                   pte_t *ptep, unsigned long sz);
>
>  #endif /* _ASM_GENERIC_HUGETLB_H */
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 0e4d1fb3122f..2b0f6f96f2c1 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -3289,6 +3289,12 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
>         return ret;
>  }
>
> +void __weak huge_pte_clear(struct mm_struct *mm, unsigned long addr,
> +                          pte_t *ptep, unsigned long sz)
> +{
> +       pte_clear(mm, addr, ptep);
> +}
> +
>  void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
>                             unsigned long start, unsigned long end,
>                             struct page *ref_page)

I don't really like how this moves the inline version from asm-generic into
a __weak function here. I think it would be better to either stop
using asm-generic/hugetlb.h
on s390, or enclose the generic definition in

#ifndef huge_pte_clear

and then override by defining a macro in s390 as we do in other files
in asm-generic.

       Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
