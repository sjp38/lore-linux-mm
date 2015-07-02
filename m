Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id A49D19003CE
	for <linux-mm@kvack.org>; Thu,  2 Jul 2015 03:26:26 -0400 (EDT)
Received: by wgck11 with SMTP id k11so55252165wgc.0
        for <linux-mm@kvack.org>; Thu, 02 Jul 2015 00:26:26 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z12si7371609wjw.88.2015.07.02.00.26.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 02 Jul 2015 00:26:24 -0700 (PDT)
Date: Thu, 2 Jul 2015 09:26:21 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm:Make the function zap_huge_pmd bool
Message-ID: <20150702072621.GB12547@dhcp22.suse.cz>
References: <1435775277-27381-1-git-send-email-xerofoify@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1435775277-27381-1-git-send-email-xerofoify@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Krause <xerofoify@gmail.com>
Cc: akpm@linux-foundation.org, mgorman@suse.de, n-horiguchi@ah.jp.nec.com, sasha.levin@oracle.com, Yalin.Wang@sonymobile.com, jmarchan@redhat.com, kirill@shutemov.name, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, ebru.akagunduz@gmail.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed 01-07-15 14:27:57, Nicholas Krause wrote:
> This makes the function zap_huge_pmd have a return type of bool
> now due to this particular function always returning one or zero
> as its return value.

How does this help anything? IMO this just generates a pointless churn
in the code without a good reason.

> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
> ---
>  include/linux/huge_mm.h | 2 +-
>  mm/huge_memory.c        | 6 +++---
>  2 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
> index f10b20f..e83174e 100644
> --- a/include/linux/huge_mm.h
> +++ b/include/linux/huge_mm.h
> @@ -19,7 +19,7 @@ extern struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
>  					  unsigned long addr,
>  					  pmd_t *pmd,
>  					  unsigned int flags);
> -extern int zap_huge_pmd(struct mmu_gather *tlb,
> +extern bool zap_huge_pmd(struct mmu_gather *tlb,
>  			struct vm_area_struct *vma,
>  			pmd_t *pmd, unsigned long addr);
>  extern int mincore_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index c107094..32b1993 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1384,11 +1384,11 @@ out:
>  	return 0;
>  }
>  
> -int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
> +bool zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
>  		 pmd_t *pmd, unsigned long addr)
>  {
>  	spinlock_t *ptl;
> -	int ret = 0;
> +	int ret = false;
>  
>  	if (__pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
>  		struct page *page;
> @@ -1419,7 +1419,7 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
>  			tlb_remove_page(tlb, page);
>  		}
>  		pte_free(tlb->mm, pgtable);
> -		ret = 1;
> +		ret = true;
>  	}
>  	return ret;
>  }
> -- 
> 2.1.4
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
