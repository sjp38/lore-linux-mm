Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 5D09C9003C8
	for <linux-mm@kvack.org>; Wed, 22 Jul 2015 17:39:38 -0400 (EDT)
Received: by pabkd10 with SMTP id kd10so72842278pab.2
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 14:39:38 -0700 (PDT)
Received: from mail-pd0-x236.google.com (mail-pd0-x236.google.com. [2607:f8b0:400e:c02::236])
        by mx.google.com with ESMTPS id dn14si6571869pac.111.2015.07.22.14.39.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jul 2015 14:39:37 -0700 (PDT)
Received: by pdbbh15 with SMTP id bh15so99142060pdb.1
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 14:39:36 -0700 (PDT)
Date: Wed, 22 Jul 2015 14:39:34 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: Flush the TLB for a single address in a huge page
In-Reply-To: <1437585214-22481-1-git-send-email-catalin.marinas@arm.com>
Message-ID: <alpine.DEB.2.10.1507221436350.21468@chino.kir.corp.google.com>
References: <1437585214-22481-1-git-send-email-catalin.marinas@arm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>

On Wed, 22 Jul 2015, Catalin Marinas wrote:

> When the page table entry is a huge page (and not a table), there is no
> need to flush the TLB by range. This patch changes flush_tlb_range() to
> flush_tlb_page() in functions where we know the pmd entry is a huge
> page.
> 
> Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> ---
> 
> Hi,
> 
> That's just a minor improvement but it saves iterating over each small
> page in a huge page when a single TLB entry is used (we already have a
> similar assumption in __tlb_adjust_range).
> 

For x86 smp, this seems to mean the difference between unconditional 
flush_tlb_page() and local_flush_tlb() due to 
tlb_single_page_flush_ceiling, so I don't think this just removes the 
iteration.

> Thanks.
> 
>  mm/pgtable-generic.c | 10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/pgtable-generic.c b/mm/pgtable-generic.c
> index 6b674e00153c..ff17eca26211 100644
> --- a/mm/pgtable-generic.c
> +++ b/mm/pgtable-generic.c
> @@ -67,7 +67,7 @@ int pmdp_set_access_flags(struct vm_area_struct *vma,
>  	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
>  	if (changed) {
>  		set_pmd_at(vma->vm_mm, address, pmdp, entry);
> -		flush_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
> +		flush_tlb_page(vma, address);
>  	}
>  	return changed;
>  #else /* CONFIG_TRANSPARENT_HUGEPAGE */
> @@ -101,7 +101,7 @@ int pmdp_clear_flush_young(struct vm_area_struct *vma,
>  #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
>  	young = pmdp_test_and_clear_young(vma, address, pmdp);
>  	if (young)
> -		flush_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
> +		flush_tlb_page(vma, address);
>  	return young;
>  }
>  #endif
> @@ -128,7 +128,7 @@ pmd_t pmdp_huge_clear_flush(struct vm_area_struct *vma, unsigned long address,
>  	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
>  	VM_BUG_ON(!pmd_trans_huge(*pmdp));
>  	pmd = pmdp_huge_get_and_clear(vma->vm_mm, address, pmdp);
> -	flush_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
> +	flush_tlb_page(vma, address);
>  	return pmd;
>  }
>  #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
> @@ -143,7 +143,7 @@ void pmdp_splitting_flush(struct vm_area_struct *vma, unsigned long address,
>  	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
>  	set_pmd_at(vma->vm_mm, address, pmdp, pmd);
>  	/* tlb flush only to serialize against gup-fast */
> -	flush_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
> +	flush_tlb_page(vma, address);
>  }
>  #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
>  #endif
> @@ -195,7 +195,7 @@ void pmdp_invalidate(struct vm_area_struct *vma, unsigned long address,
>  {
>  	pmd_t entry = *pmdp;
>  	set_pmd_at(vma->vm_mm, address, pmdp, pmd_mknotpresent(entry));
> -	flush_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
> +	flush_tlb_page(vma, address);
>  }
>  #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
>  #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
