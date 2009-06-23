Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7806E6B004F
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 15:20:14 -0400 (EDT)
Date: Tue, 23 Jun 2009 21:20:41 +0200
From: Jesper Nilsson <Jesper.Nilsson@axis.com>
Subject: Re: [PATCH] cris: add pgprot_noncached
Message-ID: <20090623192041.GH12383@axis.com>
References: <20090614132845.17543.11882.sendpatchset@rx1.opensource.se> <20090615033240.GC31902@linux-sh.org> <20090622151537.2f8009f7.akpm@linux-foundation.org> <200906231455.31499.arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200906231455.31499.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
To: Arnd Bergmann <arnd@arndb.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Paul Mundt <lethal@linux-sh.org>, "magnus.damm@gmail.com" <magnus.damm@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jayakumar.lkml@gmail.com" <jayakumar.lkml@gmail.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 23, 2009 at 02:55:30PM +0200, Arnd Bergmann wrote:
> On cris, the high address bit controls caching, which means that
> we can add a pgprot_noncached() macro that sets this bit in the
> address.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Acked-by: Jesper Nilsson <jesper.nilsson@axis.com>

> ---
> 
> Jesper, does this patch make any sense to you? I could well
> be misunderstanding how cris works.

No, this looks good to me.
Do you want me to grab it for the CRIS tree or do you want
to keep it as a series?

>  arch/cris/include/arch-v10/arch/mmu.h |    9 +++++----
>  arch/cris/include/arch-v32/arch/mmu.h |   10 ++++++----
>  arch/cris/include/asm/pgtable.h       |    2 ++
>  3 files changed, 13 insertions(+), 8 deletions(-)
> 
> diff --git a/arch/cris/include/arch-v10/arch/mmu.h b/arch/cris/include/arch-v10/arch/mmu.h
> index df84f17..e829e5a 100644
> --- a/arch/cris/include/arch-v10/arch/mmu.h
> +++ b/arch/cris/include/arch-v10/arch/mmu.h
> @@ -33,10 +33,10 @@ typedef struct
>  
>  /* CRIS PTE bits (see R_TLB_LO in the register description)
>   *
> - *   Bit:  31-13 12-------4    3        2       1       0  
> - *         ________________________________________________
> - *        | pfn | reserved | global | valid | kernel | we  |
> - *        |_____|__________|________|_______|________|_____|
> + *   Bit:  31     30-13 12-------4    3        2       1       0
> + *         _______________________________________________________
> + *        | cache |pfn | reserved | global | valid | kernel | we  |
> + *        |_______|____|__________|________|_______|________|_____|
>   *
>   * (pfn = physical frame number)
>   */
> @@ -53,6 +53,7 @@ typedef struct
>  #define _PAGE_VALID	   (1<<2) /* page is valid */
>  #define _PAGE_SILENT_READ  (1<<2) /* synonym */
>  #define _PAGE_GLOBAL       (1<<3) /* global page - context is ignored */
> +#define _PAGE_NO_CACHE	   (1<<31) /* part of the uncached memory map */
>  
>  /* Bits the HW doesn't care about but the kernel uses them in SW */
>  
> diff --git a/arch/cris/include/arch-v32/arch/mmu.h b/arch/cris/include/arch-v32/arch/mmu.h
> index 6bcdc3f..a05b033 100644
> --- a/arch/cris/include/arch-v32/arch/mmu.h
> +++ b/arch/cris/include/arch-v32/arch/mmu.h
> @@ -28,10 +28,10 @@ typedef struct
>  /*
>   * CRISv32 PTE bits:
>   *
> - *  Bit:  31-13  12-5     4        3       2        1        0
> - *       +-----+------+--------+-------+--------+-------+---------+
> - *       | pfn | zero | global | valid | kernel | write | execute |
> - *       +-----+------+--------+-------+--------+-------+---------+
> + *  Bit:   31     30-13  12-5     4        3       2        1        0
> + *       +-------+-----+------+--------+-------+--------+-------+---------+
> + *       | cache | pfn | zero | global | valid | kernel | write | execute |
> + *       +-------+-----+------+--------+-------+--------+-------+---------+
>   */
>  
>  /*
> @@ -45,6 +45,8 @@ typedef struct
>  #define _PAGE_VALID         (1 << 3)	/* Page is valid. */
>  #define _PAGE_SILENT_READ   (1 << 3)	/* Same as above. */
>  #define _PAGE_GLOBAL        (1 << 4)	/* Global page. */
> +#define _PAGE_NO_CACHE	    (1 <<31)	/* part of the uncached memory map */
> +
>  
>  /*
>   * The hardware doesn't care about these bits, but the kernel uses them in
> diff --git a/arch/cris/include/asm/pgtable.h b/arch/cris/include/asm/pgtable.h
> index 50aa974..1fcce00 100644
> --- a/arch/cris/include/asm/pgtable.h
> +++ b/arch/cris/include/asm/pgtable.h
> @@ -197,6 +197,8 @@ static inline pte_t __mk_pte(void * page, pgprot_t pgprot)
>  static inline pte_t pte_modify(pte_t pte, pgprot_t newprot)
>  { pte_val(pte) = (pte_val(pte) & _PAGE_CHG_MASK) | pgprot_val(newprot); return pte; }
>  
> +#define pgprot_noncached(prot) __pgprot((pgprot_val(prot) | _PAGE_NO_CACHE))
> +
>  
>  /* pte_val refers to a page in the 0x4xxxxxxx physical DRAM interval
>   * __pte_page(pte_val) refers to the "virtual" DRAM interval
/^JN - Jesper Nilsson
-- 
               Jesper Nilsson -- jesper.nilsson@axis.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
