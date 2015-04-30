Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 97DD76B0032
	for <linux-mm@kvack.org>; Thu, 30 Apr 2015 09:30:45 -0400 (EDT)
Received: by wgyo15 with SMTP id o15so62460917wgy.2
        for <linux-mm@kvack.org>; Thu, 30 Apr 2015 06:30:45 -0700 (PDT)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id dl8si2866549wib.11.2015.04.30.06.30.43
        for <linux-mm@kvack.org>;
        Thu, 30 Apr 2015 06:30:44 -0700 (PDT)
Date: Thu, 30 Apr 2015 16:30:35 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC PATCH 1/3] mm/thp: Use pmdp_splitting_flush_notify to clear
 pmd on splitting
Message-ID: <20150430133035.GF15874@node.dhcp.inet.fi>
References: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1430382341-8316-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1430382341-8316-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1430382341-8316-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, paulus@samba.org, benh@kernel.crashing.org, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Apr 30, 2015 at 01:55:39PM +0530, Aneesh Kumar K.V wrote:
> Some arch may require an explicit IPI before a THP PMD split. This
> ensures that a local_irq_disable can prevent a parallel THP PMD split.
> So use new function which arch can override
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
>  include/asm-generic/pgtable.h |  5 +++++
>  mm/huge_memory.c              |  7 ++++---
>  mm/pgtable-generic.c          | 11 +++++++++++
>  3 files changed, 20 insertions(+), 3 deletions(-)
> 
> diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
> index fe617b7e4be6..d091a666f5b1 100644
> --- a/include/asm-generic/pgtable.h
> +++ b/include/asm-generic/pgtable.h
> @@ -184,6 +184,11 @@ static inline void pmdp_set_wrprotect(struct mm_struct *mm,
>  #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
>  #endif
>  
> +#ifndef __HAVE_ARCH_PMDP_SPLITTING_FLUSH_NOTIFY
> +extern void pmdp_splitting_flush_notify(struct vm_area_struct *vma,
> +					unsigned long address, pmd_t *pmdp);
> +#endif
> +
>  #ifndef __HAVE_ARCH_PGTABLE_DEPOSIT
>  extern void pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
>  				       pgtable_t pgtable);
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index cce4604c192f..81e9578bf43a 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -2606,9 +2606,10 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
>  
>  	write = pmd_write(*pmd);
>  	young = pmd_young(*pmd);
> -
> -	/* leave pmd empty until pte is filled */
> -	pmdp_clear_flush_notify(vma, haddr, pmd);
> +	/*
> +	 * leave pmd empty until pte is filled.
> +	 */
> +	pmdp_splitting_flush_notify(vma, haddr, pmd);
>  
>  	pgtable = pgtable_trans_huge_withdraw(mm, pmd);
>  	pmd_populate(mm, &_pmd, pgtable);
> diff --git a/mm/pgtable-generic.c b/mm/pgtable-generic.c
> index 2fe699cedd4d..0fc1f5a06979 100644
> --- a/mm/pgtable-generic.c
> +++ b/mm/pgtable-generic.c
> @@ -7,6 +7,7 @@
>   */
>  
>  #include <linux/pagemap.h>
> +#include <linux/mmu_notifier.h>
>  #include <asm/tlb.h>
>  #include <asm-generic/pgtable.h>
>  
> @@ -184,3 +185,13 @@ void pmdp_invalidate(struct vm_area_struct *vma, unsigned long address,
>  }
>  #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
>  #endif
> +
> +#ifndef __HAVE_ARCH_PMDP_SPLITTING_FLUSH_NOTIFY
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +void pmdp_splitting_flush_notify(struct vm_area_struct *vma,
> +				 unsigned long address, pmd_t *pmdp)
> +{
> +	pmdp_clear_flush_notify(vma, address, pmdp);
> +}
> +#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
> +#endif

I think it worth inlining. Let's put it to <asm-generic/pgtable.h>

It probably worth combining with collapse counterpart in the same patch.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
