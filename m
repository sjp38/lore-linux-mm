Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4B3C16B0069
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 19:02:25 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id lj1so4653165pab.10
        for <linux-mm@kvack.org>; Wed, 22 Oct 2014 16:02:25 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id e10si113222pdm.49.2014.10.22.16.02.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Oct 2014 16:02:24 -0700 (PDT)
Date: Wed, 22 Oct 2014 16:02:24 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH V2 1/2] mm: Update generic gup implementation to handle
 hugepage directory
Message-Id: <20141022160224.9c2268795e55d5a2eff5b94d@linux-foundation.org>
In-Reply-To: <1413520687-31729-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1413520687-31729-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Steve Capper <steve.capper@linaro.org>, Andrea Arcangeli <aarcange@redhat.com>, benh@kernel.crashing.org, mpe@ellerman.id.au, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-arch@vger.kernel.org

On Fri, 17 Oct 2014 10:08:06 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:

> Update generic gup implementation with powerpc specific details.
> On powerpc at pmd level we can have hugepte, normal pmd pointer
> or a pointer to the hugepage directory.
> 
> ...
>
> --- a/arch/arm/include/asm/pgtable.h
> +++ b/arch/arm/include/asm/pgtable.h
> @@ -181,6 +181,8 @@ extern pgd_t swapper_pg_dir[PTRS_PER_PGD];
>  /* to find an entry in a kernel page-table-directory */
>  #define pgd_offset_k(addr)	pgd_offset(&init_mm, addr)
>  
> +#define pgd_huge(pgd)		(0)
> +
>  #define pmd_none(pmd)		(!pmd_val(pmd))
>  #define pmd_present(pmd)	(pmd_val(pmd))
>  
> diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
> index cefd3e825612..ed8f42497ac4 100644
> --- a/arch/arm64/include/asm/pgtable.h
> +++ b/arch/arm64/include/asm/pgtable.h
> @@ -464,6 +464,8 @@ static inline pmd_t pmd_modify(pmd_t pmd, pgprot_t newprot)
>  extern pgd_t swapper_pg_dir[PTRS_PER_PGD];
>  extern pgd_t idmap_pg_dir[PTRS_PER_PGD];
>  
> +#define pgd_huge(pgd)		(0)
> +

So only arm, arm64 and powerpc implement CONFIG_HAVE_GENERIC_RCU_GUP
and only powerpc impements pgd_huge().

Could we get a bit of documentation in place for pgd_huge() so that
people who aren't familiar with powerpc can understand what's going on?

>  /*
>   * Encode and decode a swap entry:
>   *	bits 0-1:	present (must be zero)
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 02d11ee7f19d..f97732412cb4 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1219,6 +1219,32 @@ long get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
>  		    struct vm_area_struct **vmas);
>  int get_user_pages_fast(unsigned long start, int nr_pages, int write,
>  			struct page **pages);
> +
> +#ifdef CONFIG_HAVE_GENERIC_RCU_GUP
> +#ifndef is_hugepd

And is_hugepd is a bit of a mystery.  Let's get some description in
place for this as well?  Why it exists, what its role is.  Also,
specifically which arch header file is responsible for defining it.

It takes a hugepd_t argument, but hugepd_t is defined later in this
header file.  This is weird because any preceding implementation of
is_hugepd() can't actually be implemented because it hasn't seen the
hugepd_t definition yet!  So any is_hugepd() implementation is forced
to be a simple macro which punts to a C function which *has* seen the
hugepd_t definition.  What a twisty maze.

It all seems messy, confusing and poorly documented.  Can we clean this
up?

> +/*
> + * Some architectures support hugepage directory format that is
> + * required to support different hugetlbfs sizes.
> + */
> +typedef struct { unsigned long pd; } hugepd_t;
> +#define is_hugepd(hugepd) (0)
> +#define __hugepd(x) ((hugepd_t) { (x) })

What's this.

> +static inline int gup_hugepd(hugepd_t hugepd, unsigned long addr,
> +			     unsigned pdshift, unsigned long end,
> +			     int write, struct page **pages, int *nr)
> +{
> +	return 0;
> +}
> +#else
> +extern int gup_hugepd(hugepd_t hugepd, unsigned long addr,
> +		      unsigned pdshift, unsigned long end,
> +		      int write, struct page **pages, int *nr);
> +#endif
> +extern int gup_huge_pte(pte_t orig, pte_t *ptep, unsigned long addr,
> +			unsigned long sz, unsigned long end, int write,
> +			struct page **pages, int *nr);
> +#endif
> +
>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
