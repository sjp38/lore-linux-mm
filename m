Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 9E9BB82F65
	for <linux-mm@kvack.org>; Fri,  9 Oct 2015 05:54:02 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so59762857wic.1
        for <linux-mm@kvack.org>; Fri, 09 Oct 2015 02:54:02 -0700 (PDT)
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com. [209.85.212.179])
        by mx.google.com with ESMTPS id hg7si3428150wib.23.2015.10.09.02.54.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Oct 2015 02:54:01 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so59762372wic.1
        for <linux-mm@kvack.org>; Fri, 09 Oct 2015 02:54:01 -0700 (PDT)
Date: Fri, 9 Oct 2015 12:53:59 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v2 09/12] mm,thp: reduce ifdef'ery for THP in generic code
Message-ID: <20151009095359.GA7971@node>
References: <1442918096-17454-1-git-send-email-vgupta@synopsys.com>
 <1442918096-17454-10-git-send-email-vgupta@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1442918096-17454-10-git-send-email-vgupta@synopsys.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Minchan Kim <minchan@kernel.org>, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Sep 22, 2015 at 04:04:53PM +0530, Vineet Gupta wrote:
> - pgtable-generic.c: Fold individual #ifdef for each helper into a top
>   level #ifdef. Makes code more readable

Makes sense.

> - Per Andrew's suggestion removed the dummy implementations for !THP
>   in asm-generic/page-table.h to have build time failures vs. runtime.

I'm not sure it's a good idea. This can lead to unnecessary #ifdefs where
otherwise call to helper would be eliminated by compiler as dead code.

What about dummy helpers with BUILD_BUG()?

> Signed-off-by: Vineet Gupta <vgupta@synopsys.com>
> ---
>  include/asm-generic/pgtable.h | 49 ++++++++++++++++---------------------------
>  mm/pgtable-generic.c          | 24 +++------------------
>  2 files changed, 21 insertions(+), 52 deletions(-)
> 
> diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
> index 29c57b2cb344..2112f4147816 100644
> --- a/include/asm-generic/pgtable.h
> +++ b/include/asm-generic/pgtable.h
> @@ -30,9 +30,12 @@ extern int ptep_set_access_flags(struct vm_area_struct *vma,
>  #endif
>  
>  #ifndef __HAVE_ARCH_PMDP_SET_ACCESS_FLAGS
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
>  extern int pmdp_set_access_flags(struct vm_area_struct *vma,
>  				 unsigned long address, pmd_t *pmdp,
>  				 pmd_t entry, int dirty);
> +
> +#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
>  #endif
>  
>  #ifndef __HAVE_ARCH_PTEP_TEST_AND_CLEAR_YOUNG
> @@ -64,14 +67,6 @@ static inline int pmdp_test_and_clear_young(struct vm_area_struct *vma,
>  		set_pmd_at(vma->vm_mm, address, pmdp, pmd_mkold(pmd));
>  	return r;
>  }
> -#else /* CONFIG_TRANSPARENT_HUGEPAGE */
> -static inline int pmdp_test_and_clear_young(struct vm_area_struct *vma,
> -					    unsigned long address,
> -					    pmd_t *pmdp)
> -{
> -	BUG();
> -	return 0;
> -}
>  #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
>  #endif
>  
> @@ -81,8 +76,21 @@ int ptep_clear_flush_young(struct vm_area_struct *vma,
>  #endif
>  
>  #ifndef __HAVE_ARCH_PMDP_CLEAR_YOUNG_FLUSH
> -int pmdp_clear_flush_young(struct vm_area_struct *vma,
> -			   unsigned long address, pmd_t *pmdp);
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +extern int pmdp_clear_flush_young(struct vm_area_struct *vma,
> +				  unsigned long address, pmd_t *pmdp);
> +#else
> +/*
> + * Despite relevant to THP only, this API is called from generic rmap code
> + * under PageTransHuge(), hence needs a dummy implementation for !THP
> + */

Looks like a case I described above. BUILD_BUG_ON() should work fine here.

> +static inline int pmdp_clear_flush_young(struct vm_area_struct *vma,
> +					 unsigned long address, pmd_t *pmdp)
> +{
> +	BUG();
> +	return 0;
> +}
> +#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
>  #endif

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
