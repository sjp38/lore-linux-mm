Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 6D1616B006E
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 17:09:24 -0500 (EST)
Received: by wghn12 with SMTP id n12so9468426wgh.3
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 14:09:24 -0800 (PST)
Received: from mail-wg0-x230.google.com (mail-wg0-x230.google.com. [2a00:1450:400c:c00::230])
        by mx.google.com with ESMTPS id wq3si5751850wjc.212.2015.03.04.14.09.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Mar 2015 14:09:22 -0800 (PST)
Received: by wghl2 with SMTP id l2so5795016wgh.8
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 14:09:22 -0800 (PST)
Date: Wed, 4 Mar 2015 23:09:13 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v3 3/6] mm: Change ioremap to set up huge I/O mappings
Message-ID: <20150304220912.GA22518@gmail.com>
References: <1425404664-19675-1-git-send-email-toshi.kani@hp.com>
 <1425404664-19675-4-git-send-email-toshi.kani@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1425404664-19675-4-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, arnd@arndb.de, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com


* Toshi Kani <toshi.kani@hp.com> wrote:

> ioremap_pud_range() and ioremap_pmd_range() are changed to create 
> huge I/O mappings when their capability is enabled, and a request 
> meets required conditions -- both virtual & physical addresses are 
> aligned by their huge page size, and a requested range fufills their 
> huge page size.  When pud_set_huge() or pmd_set_huge() returns zero, 
> i.e. no-operation is performed, the code simply falls back to the 
> next level.
> 
> The changes are only enabled when CONFIG_HAVE_ARCH_HUGE_VMAP is
> defined on the architecture.
> 
> Signed-off-by: Toshi Kani <toshi.kani@hp.com>
> ---
>  include/asm-generic/pgtable.h |   15 +++++++++++++++
>  lib/ioremap.c                 |   16 ++++++++++++++++
>  2 files changed, 31 insertions(+)
> 
> diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
> index 4d46085..bf6e86c 100644
> --- a/include/asm-generic/pgtable.h
> +++ b/include/asm-generic/pgtable.h
> @@ -6,6 +6,7 @@
>  
>  #include <linux/mm_types.h>
>  #include <linux/bug.h>
> +#include <linux/errno.h>
>  
>  /*
>   * On almost all architectures and configurations, 0 can be used as the
> @@ -697,4 +698,18 @@ static inline int pmd_protnone(pmd_t pmd)
>  #define io_remap_pfn_range remap_pfn_range
>  #endif
>  
> +#ifdef CONFIG_HAVE_ARCH_HUGE_VMAP
> +int pud_set_huge(pud_t *pud, phys_addr_t addr, pgprot_t prot);
> +int pmd_set_huge(pmd_t *pmd, phys_addr_t addr, pgprot_t prot);
> +#else	/* !CONFIG_HAVE_ARCH_HUGE_VMAP */
> +static inline int pud_set_huge(pud_t *pud, phys_addr_t addr, pgprot_t prot)
> +{
> +	return 0;
> +}
> +static inline int pmd_set_huge(pmd_t *pmd, phys_addr_t addr, pgprot_t prot)
> +{
> +	return 0;
> +}
> +#endif	/* CONFIG_HAVE_ARCH_HUGE_VMAP */
> +
>  #endif /* _ASM_GENERIC_PGTABLE_H */
> diff --git a/lib/ioremap.c b/lib/ioremap.c
> index 0ce18aa..3055ada 100644
> --- a/lib/ioremap.c
> +++ b/lib/ioremap.c
> @@ -81,6 +81,14 @@ static inline int ioremap_pmd_range(pud_t *pud, unsigned long addr,
>  		return -ENOMEM;
>  	do {
>  		next = pmd_addr_end(addr, end);
> +
> +		if (ioremap_pmd_enabled() &&
> +		    ((next - addr) == PMD_SIZE) &&
> +		    IS_ALIGNED(phys_addr + addr, PMD_SIZE)) {
> +			if (pmd_set_huge(pmd, phys_addr + addr, prot))
> +				continue;
> +		}
> +
>  		if (ioremap_pte_range(pmd, addr, next, phys_addr + addr, prot))
>  			return -ENOMEM;
>  	} while (pmd++, addr = next, addr != end);
> @@ -99,6 +107,14 @@ static inline int ioremap_pud_range(pgd_t *pgd, unsigned long addr,
>  		return -ENOMEM;
>  	do {
>  		next = pud_addr_end(addr, end);
> +
> +		if (ioremap_pud_enabled() &&
> +		    ((next - addr) == PUD_SIZE) &&
> +		    IS_ALIGNED(phys_addr + addr, PUD_SIZE)) {
> +			if (pud_set_huge(pud, phys_addr + addr, prot))
> +				continue;
> +		}
> +
>  		if (ioremap_pmd_range(pud, addr, next, phys_addr + addr, prot))
>  			return -ENOMEM;
>  	} while (pud++, addr = next, addr != end);

Hm, so I don't see where you set the proper x86 PAT table attributes 
for the pmds.

MTRR's are basically a legacy mechanism, the proper way to set cache 
attribute is PAT and I don't see where this generic code does that, 
but I might be missing something?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
