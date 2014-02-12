Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f182.google.com (mail-we0-f182.google.com [74.125.82.182])
	by kanga.kvack.org (Postfix) with ESMTP id 7E9356B0031
	for <linux-mm@kvack.org>; Wed, 12 Feb 2014 11:59:31 -0500 (EST)
Received: by mail-we0-f182.google.com with SMTP id u57so6344091wes.27
        for <linux-mm@kvack.org>; Wed, 12 Feb 2014 08:59:30 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cp4si1848116wib.20.2014.02.12.08.59.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 12 Feb 2014 08:59:29 -0800 (PST)
Date: Wed, 12 Feb 2014 17:59:27 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm, thp: fix infinite loop on memcg OOM
Message-ID: <20140212165927.GE28085@dhcp22.suse.cz>
References: <1392139451-15446-1-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1392139451-15446-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, m.mizuma@jp.fujitsu.com, aarcange@redhat.com, linux-mm@kvack.org

On Tue 11-02-14 19:24:11, Kirill A. Shutemov wrote:
> Masayoshi Mizuma has reported bug with hung of application under memcg
> limit. It happens on write-protection fault to huge zero page
> 
> If we successfully allocate huge page to replace zero page, but hit
> memcg limit we need to split zero page with split_huge_page_pmd() and
> fallback to small pages.
> 
> Other part problem is that VM_FAULT_OOM has special meaning in
> do_huge_pmd_wp_page() context. __handle_mm_fault() expects the page to
> be split if it see VM_FAULT_OOM and it will will retry page fault
> handling. It causes infinite loop if the page was not split.
> 
> do_huge_pmd_wp_zero_page_fallback() can return VM_FAULT_OOM if it failed
> to allocat one small page, so fallback to small pages will not help.
> 
> The solution for this part is to replace VM_FAULT_OOM with
> VM_FAULT_FALLBACK is fallback required.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Reported-by: Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>

FWIW
Reviewed-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/huge_memory.c |  9 ++++++---
>  mm/memory.c      | 14 +++-----------
>  2 files changed, 9 insertions(+), 14 deletions(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 82166bf974e1..65a88bef8694 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1166,8 +1166,10 @@ alloc:
>  		} else {
>  			ret = do_huge_pmd_wp_page_fallback(mm, vma, address,
>  					pmd, orig_pmd, page, haddr);
> -			if (ret & VM_FAULT_OOM)
> +			if (ret & VM_FAULT_OOM) {
>  				split_huge_page(page);
> +				ret |= VM_FAULT_FALLBACK;
> +			}
>  			put_page(page);
>  		}
>  		count_vm_event(THP_FAULT_FALLBACK);
> @@ -1179,9 +1181,10 @@ alloc:
>  		if (page) {
>  			split_huge_page(page);
>  			put_page(page);
> -		}
> +		} else
> +			split_huge_page_pmd(vma, address, pmd);
> +		ret |= VM_FAULT_FALLBACK;
>  		count_vm_event(THP_FAULT_FALLBACK);
> -		ret |= VM_FAULT_OOM;
>  		goto out;
>  	}
>  
> diff --git a/mm/memory.c b/mm/memory.c
> index be6a0c0d4ae0..3b57b7864667 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -3703,7 +3703,6 @@ static int __handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  	if (unlikely(is_vm_hugetlb_page(vma)))
>  		return hugetlb_fault(mm, vma, address, flags);
>  
> -retry:
>  	pgd = pgd_offset(mm, address);
>  	pud = pud_alloc(mm, pgd, address);
>  	if (!pud)
> @@ -3741,20 +3740,13 @@ retry:
>  			if (dirty && !pmd_write(orig_pmd)) {
>  				ret = do_huge_pmd_wp_page(mm, vma, address, pmd,
>  							  orig_pmd);
> -				/*
> -				 * If COW results in an oom, the huge pmd will
> -				 * have been split, so retry the fault on the
> -				 * pte for a smaller charge.
> -				 */
> -				if (unlikely(ret & VM_FAULT_OOM))
> -					goto retry;
> -				return ret;
> +				if (!(ret & VM_FAULT_FALLBACK))
> +					return ret;
>  			} else {
>  				huge_pmd_set_accessed(mm, vma, address, pmd,
>  						      orig_pmd, dirty);
> +				return 0;
>  			}
> -
> -			return 0;
>  		}
>  	}
>  
> -- 
> 1.8.5.2
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
