Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8E5F66B0006
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 03:39:38 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id f4-v6so2739417plr.11
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 00:39:38 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id b22si3412376pfi.244.2018.03.15.00.39.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Mar 2018 00:39:37 -0700 (PDT)
Subject: Re: [PATCH v2 2/2] x86/mm: implement free pmd/pte page interfaces
References: <20180314180155.19492-1-toshi.kani@hpe.com>
 <20180314180155.19492-3-toshi.kani@hpe.com>
From: Chintan Pandya <cpandya@codeaurora.org>
Message-ID: <14cb9fdf-25de-6519-2200-43f585b64cdd@codeaurora.org>
Date: Thu, 15 Mar 2018 13:09:10 +0530
MIME-Version: 1.0
In-Reply-To: <20180314180155.19492-3-toshi.kani@hpe.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hpe.com>, mhocko@suse.com, akpm@linux-foundation.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, bp@suse.de, catalin.marinas@arm.com
Cc: x86@kernel.org, wxf.wang@hisilicon.com, guohanjun@huawei.com, will.deacon@arm.com, linux-kernel@vger.kernel.org, willy@infradead.org, linux-mm@kvack.org, stable@vger.kernel.org, linux-arm-kernel@lists.infradead.org



On 3/14/2018 11:31 PM, Toshi Kani wrote:
> Implement pud_free_pmd_page() and pmd_free_pte_page() on x86, which
> clear a given pud/pmd entry and free up lower level page table(s).
> Address range associated with the pud/pmd entry must have been purged
> by INVLPG.
> 
> fixes: e61ce6ade404e ("mm: change ioremap to set up huge I/O mappings")
> Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: "H. Peter Anvin" <hpa@zytor.com>
> Cc: Borislav Petkov <bp@suse.de>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: <stable@vger.kernel.org>
> ---
>   arch/x86/mm/pgtable.c |   28 ++++++++++++++++++++++++++--
>   1 file changed, 26 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
> index 1eed7ed518e6..34cda7e0551b 100644
> --- a/arch/x86/mm/pgtable.c
> +++ b/arch/x86/mm/pgtable.c
> @@ -712,7 +712,22 @@ int pmd_clear_huge(pmd_t *pmd)
>    */
>   int pud_free_pmd_page(pud_t *pud)
>   {
> -	return pud_none(*pud);
> +	pmd_t *pmd;
> +	int i;
> +
> +	if (pud_none(*pud))
> +		return 1;
> +
> +	pmd = (pmd_t *)pud_page_vaddr(*pud);
> +
> +	for (i = 0; i < PTRS_PER_PMD; i++)
> +		if (!pmd_free_pte_page(&pmd[i]))

This is forced action and no optional. Also, pmd_free_pte_page()
doesn't return 0 in any case. So, you may remove _if_ ?

> +			return 0;
> +
> +	pud_clear(pud);
> +	free_page((unsigned long)pmd);
> +
> +	return 1;
>   }
>   
>   /**
> @@ -724,6 +739,15 @@ int pud_free_pmd_page(pud_t *pud)
>    */
>   int pmd_free_pte_page(pmd_t *pmd)
>   {
> -	return pmd_none(*pmd);
> +	pte_t *pte;
> +
> +	if (pmd_none(*pmd))

This should also check if pmd is already huge. Same for pud ?

> +		return 1;
> +
> +	pte = (pte_t *)pmd_page_vaddr(*pmd);
> +	pmd_clear(pmd);
> +	free_page((unsigned long)pte);
> +
> +	return 1;
>   }
>   #endif	/* CONFIG_HAVE_ARCH_HUGE_VMAP */
> 
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
> 

Chintan
-- 
Qualcomm India Private Limited, on behalf of Qualcomm Innovation Center,
Inc. is a member of the Code Aurora Forum, a Linux Foundation
Collaborative Project
