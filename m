Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id B031B6B0005
	for <linux-mm@kvack.org>; Wed, 10 Feb 2016 11:14:23 -0500 (EST)
Received: by mail-qg0-f53.google.com with SMTP id y9so17121991qgd.3
        for <linux-mm@kvack.org>; Wed, 10 Feb 2016 08:14:23 -0800 (PST)
Received: from e17.ny.us.ibm.com (e17.ny.us.ibm.com. [129.33.205.207])
        by mx.google.com with ESMTPS id 19si4290076qgf.103.2016.02.10.08.14.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 10 Feb 2016 08:14:22 -0800 (PST)
Received: from localhost
	by e17.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 10 Feb 2016 11:14:22 -0500
Received: from b01cxnp23033.gho.pok.ibm.com (b01cxnp23033.gho.pok.ibm.com [9.57.198.28])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id ED67B6E804A
	for <linux-mm@kvack.org>; Wed, 10 Feb 2016 11:01:10 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by b01cxnp23033.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u1AGEI0925165828
	for <linux-mm@kvack.org>; Wed, 10 Feb 2016 16:14:18 GMT
Received: from d01av04.pok.ibm.com (localhost [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u1AGEIRX021305
	for <linux-mm@kvack.org>; Wed, 10 Feb 2016 11:14:18 -0500
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH V2] mm/thp/migration: switch from flush_tlb_range to flush_pmd_tlb_range
In-Reply-To: <1455118510-15031-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1455118510-15031-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Date: Wed, 10 Feb 2016 21:44:07 +0530
Message-ID: <87vb5wwnjk.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, Mel Gorman <mgorman@techsingularity.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vineet Gupta <Vineet.Gupta1@synopsys.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> writes:

> We remove one instace of flush_tlb_range here. That was added by
> f714f4f20e59ea6eea264a86b9a51fd51b88fc54 ("mm: numa: call MMU notifiers
> on THP migration"). But the pmdp_huge_clear_flush_notify should have
> done the require flush for us. Hence remove the extra flush.
>
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
> Changes from V1:
> * fix build error
>
>  include/asm-generic/pgtable.h | 17 +++++++++++++++++
>  mm/migrate.c                  |  8 +++++---
>  mm/pgtable-generic.c          | 14 --------------
>  3 files changed, 22 insertions(+), 17 deletions(-)
>
> diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
> index c370b261c720..9401f4819891 100644
> --- a/include/asm-generic/pgtable.h
> +++ b/include/asm-generic/pgtable.h
> @@ -783,6 +783,23 @@ static inline int pmd_clear_huge(pmd_t *pmd)
>  }
>  #endif	/* CONFIG_HAVE_ARCH_HUGE_VMAP */
>
> +#ifndef __HAVE_ARCH_FLUSH_PMD_TLB_RANGE
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +/*
> + * ARCHes with special requirements for evicting THP backing TLB entries can
> + * implement this. Otherwise also, it can help optimize normal TLB flush in
> + * THP regime. stock flush_tlb_range() typically has optimization to nuke the
> + * entire TLB TLB if flush span is greater than a threshold, which will
> + * likely be true for a single huge page. Thus a single thp flush will
> + * invalidate the entire TLB which is not desitable.
> + * e.g. see arch/arc: flush_pmd_tlb_range
> + */
> +#define flush_pmd_tlb_range(vma, addr, end)	flush_tlb_range(vma, addr, end)
> +#else
> +#define flush_pmd_tlb_range(vma, addr, end)	BUILD_BUG()
> +#endif
> +#endif
> +
>  #endif /* !__ASSEMBLY__ */
>
>  #ifndef io_remap_pfn_range
> diff --git a/mm/migrate.c b/mm/migrate.c
> index b1034f9c77e7..c079c115d038 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -1767,7 +1767,10 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
>  		put_page(new_page);
>  		goto out_fail;
>  	}
> -
> +	/*
> +	 * We are not sure a pending tlb flush here is for a huge page
> +	 * mapping or not. Hence use the tlb range variant
> +	 */
>  	if (mm_tlb_flush_pending(mm))
>  		flush_tlb_range(vma, mmun_start, mmun_end);
>

I was thinking we should be able to switch this flush_pmd_tlb_range. But
Kirill was not sure when we discussed this last time. Can we have a
pending tlb flush with PAGE_SIZE page translation, when we are parallely
trying to handle a autonuma fault on that ?


> @@ -1823,12 +1826,11 @@ fail_putback:
>  	page_add_anon_rmap(new_page, vma, mmun_start, true);
>  	pmdp_huge_clear_flush_notify(vma, mmun_start, pmd);
>  	set_pmd_at(mm, mmun_start, pmd, entry);
> -	flush_tlb_range(vma, mmun_start, mmun_end);
>  	update_mmu_cache_pmd(vma, address, &entry);
>
>  	if (page_count(page) != 2) {
>  		set_pmd_at(mm, mmun_start, pmd, orig_entry);
> -		flush_tlb_range(vma, mmun_start, mmun_end);
> +		flush_pmd_tlb_range(vma, mmun_start, mmun_end);
>  		mmu_notifier_invalidate_range(mm, mmun_start, mmun_end);
>  		update_mmu_cache_pmd(vma, address, &entry);
>  		page_remove_rmap(new_page, true);
> diff --git a/mm/pgtable-generic.c b/mm/pgtable-generic.c
> index 9d4767698a1c..3c9c78400300 100644
> --- a/mm/pgtable-generic.c
> +++ b/mm/pgtable-generic.c
> @@ -84,20 +84,6 @@ pte_t ptep_clear_flush(struct vm_area_struct *vma, unsigned long address,
>
>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
>
> -#ifndef __HAVE_ARCH_FLUSH_PMD_TLB_RANGE
> -
> -/*
> - * ARCHes with special requirements for evicting THP backing TLB entries can
> - * implement this. Otherwise also, it can help optimize normal TLB flush in
> - * THP regime. stock flush_tlb_range() typically has optimization to nuke the
> - * entire TLB TLB if flush span is greater than a threshhold, which will
> - * likely be true for a single huge page. Thus a single thp flush will
> - * invalidate the entire TLB which is not desitable.
> - * e.g. see arch/arc: flush_pmd_tlb_range
> - */
> -#define flush_pmd_tlb_range(vma, addr, end)	flush_tlb_range(vma, addr, end)
> -#endif
> -
>  #ifndef __HAVE_ARCH_PMDP_SET_ACCESS_FLAGS
>  int pmdp_set_access_flags(struct vm_area_struct *vma,
>  			  unsigned long address, pmd_t *pmdp,
> -- 
> 2.5.0

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
