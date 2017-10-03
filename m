Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id F0C6F6B0038
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 10:50:20 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id u27so3449899pgn.3
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 07:50:20 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id m204si2874690oib.372.2017.10.03.07.50.19
        for <linux-mm@kvack.org>;
        Tue, 03 Oct 2017 07:50:19 -0700 (PDT)
Date: Tue, 3 Oct 2017 15:48:46 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH v9 09/12] mm/kasan: kasan specific map populate function
Message-ID: <20171003144845.GD4931@leverpostej>
References: <20170920201714.19817-1-pasha.tatashin@oracle.com>
 <20170920201714.19817-10-pasha.tatashin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170920201714.19817-10-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>, will.deacon@arm.com, catalin.marinas@arm.com
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, mhocko@kernel.org, ard.biesheuvel@linaro.org, sam@ravnborg.org, mgorman@techsingularity.net, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com

Hi Pavel,

On Wed, Sep 20, 2017 at 04:17:11PM -0400, Pavel Tatashin wrote:
> During early boot, kasan uses vmemmap_populate() to establish its shadow
> memory. But, that interface is intended for struct pages use.
> 
> Because of the current project, vmemmap won't be zeroed during allocation,
> but kasan expects that memory to be zeroed. We are adding a new
> kasan_map_populate() function to resolve this difference.

Thanks for putting this together.

I've given this a spin on arm64, and can confirm that it works.

Given that this involes redundant walking of page tables, I still think
it'd be preferable to have some common *_populate() helper that took a
gfp argument, but I guess it's not the end of the world.

I'll leave it to Will and Catalin to say whether they're happy with the
page table walking and the new p{u,m}d_large() helpers added to arm64.

Thanks,
Mark.

> 
> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
> ---
>  arch/arm64/include/asm/pgtable.h |  3 ++
>  include/linux/kasan.h            |  2 ++
>  mm/kasan/kasan_init.c            | 67 ++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 72 insertions(+)
> 
> diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
> index bc4e92337d16..d89713f04354 100644
> --- a/arch/arm64/include/asm/pgtable.h
> +++ b/arch/arm64/include/asm/pgtable.h
> @@ -381,6 +381,9 @@ extern pgprot_t phys_mem_access_prot(struct file *file, unsigned long pfn,
>  				 PUD_TYPE_TABLE)
>  #endif
>  
> +#define pmd_large(pmd)		pmd_sect(pmd)
> +#define pud_large(pud)		pud_sect(pud)
> +
>  static inline void set_pmd(pmd_t *pmdp, pmd_t pmd)
>  {
>  	*pmdp = pmd;
> diff --git a/include/linux/kasan.h b/include/linux/kasan.h
> index a5c7046f26b4..7e13df1722c2 100644
> --- a/include/linux/kasan.h
> +++ b/include/linux/kasan.h
> @@ -78,6 +78,8 @@ size_t kasan_metadata_size(struct kmem_cache *cache);
>  
>  bool kasan_save_enable_multi_shot(void);
>  void kasan_restore_multi_shot(bool enabled);
> +int __meminit kasan_map_populate(unsigned long start, unsigned long end,
> +				 int node);
>  
>  #else /* CONFIG_KASAN */
>  
> diff --git a/mm/kasan/kasan_init.c b/mm/kasan/kasan_init.c
> index 554e4c0f23a2..57a973f05f63 100644
> --- a/mm/kasan/kasan_init.c
> +++ b/mm/kasan/kasan_init.c
> @@ -197,3 +197,70 @@ void __init kasan_populate_zero_shadow(const void *shadow_start,
>  		zero_p4d_populate(pgd, addr, next);
>  	} while (pgd++, addr = next, addr != end);
>  }
> +
> +/* Creates mappings for kasan during early boot. The mapped memory is zeroed */
> +int __meminit kasan_map_populate(unsigned long start, unsigned long end,
> +				 int node)
> +{
> +	unsigned long addr, pfn, next;
> +	unsigned long long size;
> +	pgd_t *pgd;
> +	p4d_t *p4d;
> +	pud_t *pud;
> +	pmd_t *pmd;
> +	pte_t *pte;
> +	int ret;
> +
> +	ret = vmemmap_populate(start, end, node);
> +	/*
> +	 * We might have partially populated memory, so check for no entries,
> +	 * and zero only those that actually exist.
> +	 */
> +	for (addr = start; addr < end; addr = next) {
> +		pgd = pgd_offset_k(addr);
> +		if (pgd_none(*pgd)) {
> +			next = pgd_addr_end(addr, end);
> +			continue;
> +		}
> +
> +		p4d = p4d_offset(pgd, addr);
> +		if (p4d_none(*p4d)) {
> +			next = p4d_addr_end(addr, end);
> +			continue;
> +		}
> +
> +		pud = pud_offset(p4d, addr);
> +		if (pud_none(*pud)) {
> +			next = pud_addr_end(addr, end);
> +			continue;
> +		}
> +		if (pud_large(*pud)) {
> +			/* This is PUD size page */
> +			next = pud_addr_end(addr, end);
> +			size = PUD_SIZE;
> +			pfn = pud_pfn(*pud);
> +		} else {
> +			pmd = pmd_offset(pud, addr);
> +			if (pmd_none(*pmd)) {
> +				next = pmd_addr_end(addr, end);
> +				continue;
> +			}
> +			if (pmd_large(*pmd)) {
> +				/* This is PMD size page */
> +				next = pmd_addr_end(addr, end);
> +				size = PMD_SIZE;
> +				pfn = pmd_pfn(*pmd);
> +			} else {
> +				pte = pte_offset_kernel(pmd, addr);
> +				next = addr + PAGE_SIZE;
> +				if (pte_none(*pte))
> +					continue;
> +				/* This is base size page */
> +				size = PAGE_SIZE;
> +				pfn = pte_pfn(*pte);
> +			}
> +		}
> +		memset(phys_to_virt(PFN_PHYS(pfn)), 0, size);
> +	}
> +	return ret;
> +}
> -- 
> 2.14.1
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
