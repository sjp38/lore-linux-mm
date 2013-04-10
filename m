Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 6C3C36B0005
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 03:21:27 -0400 (EDT)
Date: Wed, 10 Apr 2013 17:21:23 +1000
From: Michael Ellerman <michael@ellerman.id.au>
Subject: Re: [PATCH -V5 19/25] powerpc/THP: Differentiate THP PMD entries
 from HUGETLB PMD entries
Message-ID: <20130410072122.GC24786@concordia>
References: <1365055083-31956-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1365055083-31956-20-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1365055083-31956-20-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

On Thu, Apr 04, 2013 at 11:27:57AM +0530, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> HUGETLB clear the top bit of PMD entries and use that to indicate
> a HUGETLB page directory. Since we store pfns in PMDs for THP,
> we would have the top bit cleared by default. Add the top bit mask
> for THP PMD entries and clear that when we are looking for pmd_pfn.
> 
> @@ -44,6 +44,14 @@ struct mm_struct;
>  #define PMD_HUGE_RPN_SHIFT	PTE_RPN_SHIFT
>  #define HUGE_PAGE_SIZE		(ASM_CONST(1) << 24)
>  #define HUGE_PAGE_MASK		(~(HUGE_PAGE_SIZE - 1))
> +/*
> + * HugeTLB looks at the top bit of the Linux page table entries to
> + * decide whether it is a huge page directory or not. Mark HUGE
> + * PMD to differentiate
> + */
> +#define PMD_HUGE_NOT_HUGETLB	(ASM_CONST(1) << 63)
> +#define PMD_ISHUGE		(_PMD_ISHUGE | PMD_HUGE_NOT_HUGETLB)
> +#define PMD_HUGE_PROTBITS	(0xfff | PMD_HUGE_NOT_HUGETLB)
>  
>  #ifndef __ASSEMBLY__
>  extern void hpte_need_hugepage_flush(struct mm_struct *mm, unsigned long addr,
> @@ -84,7 +93,8 @@ static inline unsigned long pmd_pfn(pmd_t pmd)
>  	/*
>  	 * Only called for hugepage pmd
>  	 */
> -	return pmd_val(pmd) >> PMD_HUGE_RPN_SHIFT;
> +	unsigned long val = pmd_val(pmd) & ~PMD_HUGE_PROTBITS;
> +	return val  >> PMD_HUGE_RPN_SHIFT;
>  }

This is breaking the 32-bit build for me (pmac32_defconfig):

arch/powerpc/include/asm/pgtable.h:123:2: error: left shift count >= width of type [-Werror]

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
