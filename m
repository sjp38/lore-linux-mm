Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 0817E6B00F6
	for <linux-mm@kvack.org>; Mon,  6 May 2013 17:33:35 -0400 (EDT)
Date: Tue, 7 May 2013 01:27:19 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm/THP: Don't use HPAGE_SHIFT in transparent hugepage
 code
Message-ID: <20130506222719.GA23653@shutemov.name>
References: <1367873552-12904-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1367873552-12904-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: aarcange@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org

On Tue, May 07, 2013 at 02:22:32AM +0530, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> For architectures like powerpc that support multiple explicit hugepage
> sizes, HPAGE_SHIFT indicate the default explicit hugepage shift. For
> THP to work the hugepage size should be same as PMD_SIZE. So use
> PMD_SHIFT directly. So move the define outside CONFIG_TRANSPARENT_HUGEPAGE
> #ifdef because we want to use these defines in generic code with
> if (pmd_trans_huge()) conditional.
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
>  include/linux/huge_mm.h | 10 +++-------
>  1 file changed, 3 insertions(+), 7 deletions(-)
> 
> diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
> index 528454c..cc276d2 100644
> --- a/include/linux/huge_mm.h
> +++ b/include/linux/huge_mm.h
> @@ -58,12 +58,11 @@ extern pmd_t *page_check_address_pmd(struct page *page,
>  
>  #define HPAGE_PMD_ORDER (HPAGE_PMD_SHIFT-PAGE_SHIFT)
>  #define HPAGE_PMD_NR (1<<HPAGE_PMD_ORDER)
> +#define HPAGE_PMD_SHIFT PMD_SHIFT

What about:

#ifndef HPAGE_PMD_SHIFT
#define HPAGE_PMD_SHIFT HPAGE_SHIFT
#endif

And define HPAGE_PMD_SHIFT in arch code if HPAGE_SHIFT is not suitable?


> +#define HPAGE_PMD_SIZE	((1UL) << HPAGE_PMD_SHIFT)
> +#define HPAGE_PMD_MASK	(~(HPAGE_PMD_SIZE - 1))
>  
>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
> -#define HPAGE_PMD_SHIFT HPAGE_SHIFT
> -#define HPAGE_PMD_MASK HPAGE_MASK
> -#define HPAGE_PMD_SIZE HPAGE_SIZE
> -
>  extern bool is_vma_temporary_stack(struct vm_area_struct *vma);
>  
>  #define transparent_hugepage_enabled(__vma)				\
> @@ -181,9 +180,6 @@ extern int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vm
>  				unsigned long addr, pmd_t pmd, pmd_t *pmdp);
>  
>  #else /* CONFIG_TRANSPARENT_HUGEPAGE */
> -#define HPAGE_PMD_SHIFT ({ BUILD_BUG(); 0; })
> -#define HPAGE_PMD_MASK ({ BUILD_BUG(); 0; })
> -#define HPAGE_PMD_SIZE ({ BUILD_BUG(); 0; })
>  
>  #define hpage_nr_pages(x) 1
>  
> -- 
> 1.8.1.2
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
