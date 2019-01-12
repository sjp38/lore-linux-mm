Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0308A8E0002
	for <linux-mm@kvack.org>; Sat, 12 Jan 2019 07:12:39 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id v2so9967937plg.6
        for <linux-mm@kvack.org>; Sat, 12 Jan 2019 04:12:38 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 89si29342798pfr.242.2019.01.12.04.12.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 12 Jan 2019 04:12:37 -0800 (PST)
Date: Sat, 12 Jan 2019 04:12:31 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: Introduce GFP_PGTABLE
Message-ID: <20190112121230.GQ6310@bombadil.infradead.org>
References: <1547288798-10243-1-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1547288798-10243-1-git-send-email-anshuman.khandual@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org, linux-sh@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux@armlinux.org.uk, catalin.marinas@arm.com, will.deacon@arm.com, mpe@ellerman.id.au, tglx@linutronix.de, mingo@redhat.com, dave.hansen@linux.intel.com, peterz@infradead.org, christoffer.dall@arm.com, marc.zyngier@arm.com, kirill@shutemov.name, rppt@linux.vnet.ibm.com, mhocko@suse.com, ard.biesheuvel@linaro.org, mark.rutland@arm.com, steve.capper@arm.com, james.morse@arm.com, robin.murphy@arm.com, aneesh.kumar@linux.ibm.com, vbabka@suse.cz, shakeelb@google.com, rientjes@google.com

On Sat, Jan 12, 2019 at 03:56:38PM +0530, Anshuman Khandual wrote:
> All architectures have been defining their own PGALLOC_GFP as (GFP_KERNEL |
> __GFP_ZERO) and using it for allocating page table pages.

Except that's not true.

> +++ b/arch/x86/mm/pgtable.c
> @@ -13,19 +13,17 @@ phys_addr_t physical_mask __ro_after_init = (1ULL << __PHYSICAL_MASK_SHIFT) - 1;
>  EXPORT_SYMBOL(physical_mask);
>  #endif
>  
> -#define PGALLOC_GFP (GFP_KERNEL_ACCOUNT | __GFP_ZERO)
> -
>  #ifdef CONFIG_HIGHPTE

...

>  pte_t *pte_alloc_one_kernel(struct mm_struct *mm)
>  {
> -	return (pte_t *)__get_free_page(PGALLOC_GFP & ~__GFP_ACCOUNT);
> +	return (pte_t *)__get_free_page(GFP_PGTABLE & ~__GFP_ACCOUNT);
>  }

I think x86 was the only odd one out here, but you'll need to try again ...
