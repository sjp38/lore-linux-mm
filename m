Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5D7B26B0006
	for <linux-mm@kvack.org>; Thu, 26 Apr 2018 10:19:31 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id b192so3468080wmb.1
        for <linux-mm@kvack.org>; Thu, 26 Apr 2018 07:19:31 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [81.169.241.247])
        by mx.google.com with ESMTPS id h30si7814388edc.442.2018.04.26.07.19.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Apr 2018 07:19:27 -0700 (PDT)
Date: Thu, 26 Apr 2018 16:19:26 +0200
From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [PATCH v2 2/2] x86/mm: implement free pmd/pte page interfaces
Message-ID: <20180426141926.GN15462@8bytes.org>
References: <20180314180155.19492-1-toshi.kani@hpe.com>
 <20180314180155.19492-3-toshi.kani@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180314180155.19492-3-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hpe.com>
Cc: mhocko@suse.com, akpm@linux-foundation.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, bp@suse.de, catalin.marinas@arm.com, guohanjun@huawei.com, will.deacon@arm.com, wxf.wang@hisilicon.com, willy@infradead.org, cpandya@codeaurora.org, linux-mm@kvack.org, x86@kernel.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

Hi Toshi, Andrew,

this patch(-set) is broken in several ways, please see below.

On Wed, Mar 14, 2018 at 12:01:55PM -0600, Toshi Kani wrote:
> Implement pud_free_pmd_page() and pmd_free_pte_page() on x86, which
> clear a given pud/pmd entry and free up lower level page table(s).
> Address range associated with the pud/pmd entry must have been purged
> by INVLPG.

An INVLPG before actually unmapping the page is useless, as other cores
or even speculative instruction execution can bring the TLB entry back
before the code actually unmaps the page.

>  int pud_free_pmd_page(pud_t *pud)
>  {
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
> +			return 0;
> +
> +	pud_clear(pud);

TLB flush needed here, before the page is freed.

> +	free_page((unsigned long)pmd);
> +
> +	return 1;
>  }
>  
>  /**
> @@ -724,6 +739,15 @@ int pud_free_pmd_page(pud_t *pud)
>   */
>  int pmd_free_pte_page(pmd_t *pmd)
>  {
> -	return pmd_none(*pmd);
> +	pte_t *pte;
> +
> +	if (pmd_none(*pmd))
> +		return 1;
> +
> +	pte = (pte_t *)pmd_page_vaddr(*pmd);
> +	pmd_clear(pmd);

Same here, TLB flush needed.

Further this needs synchronization with other page-tables in the system
when the kernel PMDs are not shared between processes. In x86-32 with
PAE this causes a BUG_ON() being triggered at arch/x86/mm/fault.c:268
because the page-tables are not correctly synchronized.

> +	free_page((unsigned long)pte);
> +
> +	return 1;
>  }
>  #endif	/* CONFIG_HAVE_ARCH_HUGE_VMAP */
