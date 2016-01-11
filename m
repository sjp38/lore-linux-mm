Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id CB4C4828F3
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 00:44:08 -0500 (EST)
Received: by mail-pf0-f175.google.com with SMTP id 65so39430046pff.2
        for <linux-mm@kvack.org>; Sun, 10 Jan 2016 21:44:08 -0800 (PST)
Received: from e28smtp07.in.ibm.com (e28smtp07.in.ibm.com. [125.16.236.7])
        by mx.google.com with ESMTPS id r72si25926591pfa.200.2016.01.10.21.44.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 10 Jan 2016 21:44:08 -0800 (PST)
Received: from localhost
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 11 Jan 2016 11:14:05 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 5AB2DE0054
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 11:15:19 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay03.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u0B5i1DI8454408
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 11:14:01 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u0B5hq9X015908
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 11:13:56 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH next] powerpc/mm: fix _PAGE_SWP_SOFT_DIRTY breaking swapoff
In-Reply-To: <alpine.LSU.2.11.1601091651130.9808@eggly.anvils>
References: <alpine.LSU.2.11.1601091651130.9808@eggly.anvils>
Date: Mon, 11 Jan 2016 11:13:49 +0530
Message-ID: <87mvscu0ve.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michael Ellerman <mpe@ellerman.id.au>, Cyrill Gorcunov <gorcunov@gmail.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

Hugh Dickins <hughd@google.com> writes:

> Swapoff after swapping hangs on the G5, when CONFIG_CHECKPOINT_RESTORE=y
> but CONFIG_MEM_SOFT_DIRTY is not set.  That's because the non-zero
> _PAGE_SWP_SOFT_DIRTY bit, added by CONFIG_HAVE_ARCH_SOFT_DIRTY=y, is not
> discounted when CONFIG_MEM_SOFT_DIRTY is not set: so swap ptes cannot be
> recognized.
>
> (I suspect that the peculiar dependence of HAVE_ARCH_SOFT_DIRTY on
> CHECKPOINT_RESTORE in arch/powerpc/Kconfig comes from an incomplete
> attempt to solve this problem.)
>
> It's true that the relationship between CONFIG_HAVE_ARCH_SOFT_DIRTY and
> and CONFIG_MEM_SOFT_DIRTY is too confusing, and it's true that swapoff
> should be made more robust; but nevertheless, fix up the powerpc ifdefs
> as x86_64 and s390 (which met the same problem) have them, defining the
> bits as 0 if CONFIG_MEM_SOFT_DIRTY is not set.

Do we need this patch, if we make the maybe_same_pte() more robust. The
#ifdef with pte bits is always a confusing one and IMHO, we should avoid
that if we can ?

>
> Signed-off-by: Hugh Dickins <hughd@google.com>
> ---
>
>  arch/powerpc/include/asm/book3s/64/hash.h    |    5 +++++
>  arch/powerpc/include/asm/book3s/64/pgtable.h |    9 ++++++---
>  2 files changed, 11 insertions(+), 3 deletions(-)
>
> --- 4.4-next/arch/powerpc/include/asm/book3s/64/hash.h	2016-01-06 11:54:01.377508976 -0800
> +++ linux/arch/powerpc/include/asm/book3s/64/hash.h	2016-01-09 13:54:24.410893347 -0800
> @@ -33,7 +33,12 @@
>  #define _PAGE_F_GIX_SHIFT	12
>  #define _PAGE_F_SECOND		0x08000 /* Whether to use secondary hash or not */
>  #define _PAGE_SPECIAL		0x10000 /* software: special page */
> +
> +#ifdef CONFIG_MEM_SOFT_DIRTY
>  #define _PAGE_SOFT_DIRTY	0x20000 /* software: software dirty tracking */
> +#else
> +#define _PAGE_SOFT_DIRTY	0x00000
> +#endif
>
>  /*
>   * We need to differentiate between explicit huge page and THP huge
> --- 4.4-next/arch/powerpc/include/asm/book3s/64/pgtable.h	2016-01-06 11:54:01.377508976 -0800
> +++ linux/arch/powerpc/include/asm/book3s/64/pgtable.h	2016-01-09 13:54:24.410893347 -0800
> @@ -162,8 +162,13 @@ static inline void pgd_set(pgd_t *pgdp,
>  #define __pte_to_swp_entry(pte)		((swp_entry_t) { pte_val((pte)) })
>  #define __swp_entry_to_pte(x)		__pte((x).val)
>
> -#ifdef CONFIG_HAVE_ARCH_SOFT_DIRTY
> +#ifdef CONFIG_MEM_SOFT_DIRTY
>  #define _PAGE_SWP_SOFT_DIRTY   (1UL << (SWP_TYPE_BITS + _PAGE_BIT_SWAP_TYPE))
> +#else
> +#define _PAGE_SWP_SOFT_DIRTY	0UL
> +#endif /* CONFIG_MEM_SOFT_DIRTY */
> +
> +#ifdef CONFIG_HAVE_ARCH_SOFT_DIRTY
>  static inline pte_t pte_swp_mksoft_dirty(pte_t pte)
>  {
>  	return __pte(pte_val(pte) | _PAGE_SWP_SOFT_DIRTY);
> @@ -176,8 +181,6 @@ static inline pte_t pte_swp_clear_soft_d
>  {
>  	return __pte(pte_val(pte) & ~_PAGE_SWP_SOFT_DIRTY);
>  }
> -#else
> -#define _PAGE_SWP_SOFT_DIRTY	0
>  #endif /* CONFIG_HAVE_ARCH_SOFT_DIRTY */
>
>  void pgtable_cache_add(unsigned shift, void (*ctor)(void *));

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
