Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id F12386B0035
	for <linux-mm@kvack.org>; Wed,  6 Aug 2014 03:15:02 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id et14so2899158pad.23
        for <linux-mm@kvack.org>; Wed, 06 Aug 2014 00:15:02 -0700 (PDT)
Received: from e23smtp05.au.ibm.com (e23smtp05.au.ibm.com. [202.81.31.147])
        by mx.google.com with ESMTPS id c4si54208pdk.312.2014.08.06.00.15.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 06 Aug 2014 00:15:01 -0700 (PDT)
Received: from /spool/local
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 6 Aug 2014 17:14:57 +1000
Received: from d23relay08.au.ibm.com (d23relay08.au.ibm.com [9.185.71.33])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 48C762CE8056
	for <linux-mm@kvack.org>; Wed,  6 Aug 2014 17:14:53 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay08.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s767FPt914024874
	for <linux-mm@kvack.org>; Wed, 6 Aug 2014 17:15:26 +1000
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s767Ep2M021374
	for <linux-mm@kvack.org>; Wed, 6 Aug 2014 17:14:52 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: mm: BUG in unmap_page_range
In-Reply-To: <20140805144439.GW10819@suse.de>
References: <53DD5F20.8010507@oracle.com> <alpine.LSU.2.11.1408040418500.3406@eggly.anvils> <20140805144439.GW10819@suse.de>
Date: Wed, 06 Aug 2014 12:44:45 +0530
Message-ID: <871tsudr8a.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, LKML <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Cyrill Gorcunov <gorcunov@gmail.com>, linuxppc-dev@ozlabs.org

Mel Gorman <mgorman@suse.de> writes:

> From d0c77a2b497da46c52792ead066d461e5111a594 Mon Sep 17 00:00:00 2001
> From: Mel Gorman <mgorman@suse.de>
> Date: Tue, 5 Aug 2014 12:06:50 +0100
> Subject: [PATCH] mm: Remove misleading ARCH_USES_NUMA_PROT_NONE
>
> ARCH_USES_NUMA_PROT_NONE was defined for architectures that implemented
> _PAGE_NUMA using _PROT_NONE. This saved using an additional PTE bit and
> relied on the fact that PROT_NONE vmas were skipped by the NUMA hinting
> fault scanner. This was found to be conceptually confusing with a lot of
> implicit assumptions and it was asked that an alternative be found.
>
> Commit c46a7c81 "x86: define _PAGE_NUMA by reusing software bits on the
> PMD and PTE levels" redefined _PAGE_NUMA on x86 to be one of the swap
> PTE bits and shrunk the maximum possible swap size but it did not go far
> enough. There are no architectures that reuse _PROT_NONE as _PROT_NUMA
> but the relics still exist.
>
> This patch removes ARCH_USES_NUMA_PROT_NONE and removes some unnecessary
> duplication in powerpc vs the generic implementation by defining the types
> the core NUMA helpers expected to exist from x86 with their ppc64 equivalent.
> The unification for ppc64 is less than ideal because types do not exist
> that the "generic" code expects to. This patch works around the problem
> but it would be preferred if the powerpc people would look at this to see
> if they have opinions on what might suit them better.
>
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
>  arch/powerpc/include/asm/pgtable.h | 55 ++++++++------------------------------
>  arch/x86/Kconfig                   |  1 -
>  include/asm-generic/pgtable.h      | 35 ++++++++++++------------
>  init/Kconfig                       | 11 --------
>  4 files changed, 29 insertions(+), 73 deletions(-)
>

....

> -
>  #define pmdp_set_numa pmdp_set_numa
>  static inline void pmdp_set_numa(struct mm_struct *mm, unsigned long addr,
>  				 pmd_t *pmdp)
> @@ -109,16 +71,21 @@ static inline void pmdp_set_numa(struct mm_struct *mm, unsigned long addr,
>  	return;
>  }
>  
> -#define pmd_mknonnuma pmd_mknonnuma
> -static inline pmd_t pmd_mknonnuma(pmd_t pmd)
> +/*
> + * Generic NUMA pte helpers expect pteval_t and pmdval_t types to exist
> + * which was inherited from x86. For the purposes of powerpc pte_basic_t is
> + * equivalent
> + */
> +#define pteval_t pte_basic_t
> +#define pmdval_t pmd_t
> +static inline pteval_t pte_flags(pte_t pte)
>  {
> -	return pte_pmd(pte_mknonnuma(pmd_pte(pmd)));
> +	return pte_val(pte) & PAGE_PROT_BITS;

PAGE_PROT_BITS don't get the _PAGE_NUMA and _PAGE_PRESENT. I will have
to check further to find out why the mask doesn't include
_PAGE_PRESENT. 


>  }
>  
> -#define pmd_mknuma pmd_mknuma
> -static inline pmd_t pmd_mknuma(pmd_t pmd)
> +static inline pteval_t pmd_flags(pte_t pte)
>  {


static inline pmdval_t ?

> -	return pte_pmd(pte_mknuma(pmd_pte(pmd)));
> +	return pmd_val(pte) & PAGE_PROT_BITS;
>  }
>  

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
