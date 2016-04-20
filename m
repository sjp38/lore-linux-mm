Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id B796F6B029B
	for <linux-mm@kvack.org>; Wed, 20 Apr 2016 17:00:15 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 203so31847132pfy.2
        for <linux-mm@kvack.org>; Wed, 20 Apr 2016 14:00:15 -0700 (PDT)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id 21si1896590pfv.71.2016.04.20.14.00.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Apr 2016 14:00:13 -0700 (PDT)
Received: by mail-pa0-x22c.google.com with SMTP id zm5so21340836pac.0
        for <linux-mm@kvack.org>; Wed, 20 Apr 2016 14:00:13 -0700 (PDT)
Subject: Re: [PATCH] mm: move huge_pmd_set_accessed out of huge_memory.c
References: <1461176698-9714-1-git-send-email-yang.shi@linaro.org>
From: "Shi, Yang" <yang.shi@linaro.org>
Message-ID: <5717EDDB.1060704@linaro.org>
Date: Wed, 20 Apr 2016 14:00:11 -0700
MIME-Version: 1.0
In-Reply-To: <1461176698-9714-1-git-send-email-yang.shi@linaro.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, aarcange@redhat.com, hughd@google.com, mgorman@suse.de
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org

Hi folks,

I didn't realize pmd_* functions are protected by 
CONFIG_TRANSPARENT_HUGEPAGE on the most architectures before I made this 
change.

Before I fix all the affected architectures code, I want to check if you 
guys think this change is worth or not?

Thanks,
Yang

On 4/20/2016 11:24 AM, Yang Shi wrote:
> huge_pmd_set_accessed is only called by __handle_mm_fault from memory.c,
> move the definition to memory.c and make it static like create_huge_pmd and
> wp_huge_pmd.
>
> Signed-off-by: Yang Shi <yang.shi@linaro.org>
> ---
>   include/linux/huge_mm.h |  4 ----
>   mm/huge_memory.c        | 23 -----------------------
>   mm/memory.c             | 23 +++++++++++++++++++++++
>   3 files changed, 23 insertions(+), 27 deletions(-)
>
> diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
> index 7008623..c218ab7b 100644
> --- a/include/linux/huge_mm.h
> +++ b/include/linux/huge_mm.h
> @@ -8,10 +8,6 @@ extern int do_huge_pmd_anonymous_page(struct mm_struct *mm,
>   extern int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
>   			 pmd_t *dst_pmd, pmd_t *src_pmd, unsigned long addr,
>   			 struct vm_area_struct *vma);
> -extern void huge_pmd_set_accessed(struct mm_struct *mm,
> -				  struct vm_area_struct *vma,
> -				  unsigned long address, pmd_t *pmd,
> -				  pmd_t orig_pmd, int dirty);
>   extern int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
>   			       unsigned long address, pmd_t *pmd,
>   			       pmd_t orig_pmd);
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index fecbbc5..6c14cb6 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1137,29 +1137,6 @@ out:
>   	return ret;
>   }
>
> -void huge_pmd_set_accessed(struct mm_struct *mm,
> -			   struct vm_area_struct *vma,
> -			   unsigned long address,
> -			   pmd_t *pmd, pmd_t orig_pmd,
> -			   int dirty)
> -{
> -	spinlock_t *ptl;
> -	pmd_t entry;
> -	unsigned long haddr;
> -
> -	ptl = pmd_lock(mm, pmd);
> -	if (unlikely(!pmd_same(*pmd, orig_pmd)))
> -		goto unlock;
> -
> -	entry = pmd_mkyoung(orig_pmd);
> -	haddr = address & HPAGE_PMD_MASK;
> -	if (pmdp_set_access_flags(vma, haddr, pmd, entry, dirty))
> -		update_mmu_cache_pmd(vma, address, pmd);
> -
> -unlock:
> -	spin_unlock(ptl);
> -}
> -
>   static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
>   					struct vm_area_struct *vma,
>   					unsigned long address,
> diff --git a/mm/memory.c b/mm/memory.c
> index 93897f2..6ced4eb 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -3287,6 +3287,29 @@ static int wp_huge_pmd(struct mm_struct *mm, struct vm_area_struct *vma,
>   	return VM_FAULT_FALLBACK;
>   }
>
> +static void huge_pmd_set_accessed(struct mm_struct *mm,
> +				  struct vm_area_struct *vma,
> +				  unsigned long address,
> +				  pmd_t *pmd, pmd_t orig_pmd,
> +				  int dirty)
> +{
> +	spinlock_t *ptl;
> +	pmd_t entry;
> +	unsigned long haddr;
> +
> +	ptl = pmd_lock(mm, pmd);
> +	if (unlikely(!pmd_same(*pmd, orig_pmd)))
> +		goto unlock;
> +
> +	entry = pmd_mkyoung(orig_pmd);
> +	haddr = address & HPAGE_PMD_MASK;
> +	if (pmdp_set_access_flags(vma, haddr, pmd, entry, dirty))
> +		update_mmu_cache_pmd(vma, address, pmd);
> +
> +unlock:
> +	spin_unlock(ptl);
> +}
> +
>   /*
>    * These routines also need to handle stuff like marking pages dirty
>    * and/or accessed for architectures that don't do it in hardware (most
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
