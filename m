Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id AE5626B0003
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 15:49:27 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id v74so17722286qkl.9
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 12:49:27 -0700 (PDT)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0058.outbound.protection.outlook.com. [104.47.38.58])
        by mx.google.com with ESMTPS id 64si7323128qkm.253.2018.04.05.12.49.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 05 Apr 2018 12:49:26 -0700 (PDT)
Subject: Re: [PATCH 05/11] x86/mm: do not auto-massage page protections
References: <20180404010946.6186729B@viggo.jf.intel.com>
 <20180404010958.44C7DE5F@viggo.jf.intel.com>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <32d28abb-a0f8-9a02-2b06-318a94e15a59@amd.com>
Date: Thu, 5 Apr 2018 14:49:19 -0500
MIME-Version: 1.0
In-Reply-To: <20180404010958.44C7DE5F@viggo.jf.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, aarcange@redhat.com, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, jgross@suse.com, x86@kernel.org, namit@vmware.com

On 4/3/2018 8:09 PM, Dave Hansen wrote:
> 
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> A PTE is constructed from a physical address and a pgprotval_t.
> __PAGE_KERNEL, for instance, is a pgprot_t and must be converted
> into a pgprotval_t before it can be used to create a PTE.  This is
> done implicitly within functions like pfn_pte() by massage_pgprot().
> 
> However, this makes it very challenging to set bits (and keep them
> set) if your bit is being filtered out by massage_pgprot().
> 
> This moves the bit filtering out of pfn_pte() and friends.  For
> users of PAGE_KERNEL*, filtering will be done automatically inside
> those macros but for users of __PAGE_KERNEL*, they need to do their
> own filtering now.
> 
> Note that we also just move pfn_pte/pmd/pud() over to check_pgprot()
> instead of massage_pgprot().  This way, we still *look* for
> unsupported bits and properly warn about them if we find them.  This
> might happen if an unfiltered __PAGE_KERNEL* value was passed in,
> for instance.
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Andy Lutomirski <luto@kernel.org>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Cc: Kees Cook <keescook@google.com>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Juergen Gross <jgross@suse.com>
> Cc: x86@kernel.org
> Cc: Nadav Amit <namit@vmware.com>
> ---
> 
>  b/arch/x86/include/asm/pgtable.h |   27 ++++++++++++++++++++++-----
>  b/arch/x86/kernel/head64.c       |    2 ++
>  b/arch/x86/kernel/ldt.c          |    6 +++++-
>  b/arch/x86/mm/ident_map.c        |    3 +++
>  b/arch/x86/mm/iomap_32.c         |    6 ++++++
>  b/arch/x86/mm/ioremap.c          |    3 +++
>  b/arch/x86/mm/kasan_init_64.c    |   14 +++++++++++++-
>  b/arch/x86/mm/pgtable.c          |    3 +++
>  b/arch/x86/power/hibernate_64.c  |   20 +++++++++++++++-----
>  9 files changed, 72 insertions(+), 12 deletions(-)
> 

This fails to build for me when I enable KASLR (RANDOMIZE_BASE), with the
following error:

arch/x86/boot/compressed/kaslr_64.o: In function `kernel_ident_mapping_init':
kaslr_64.c:(.text+0x245): undefined reference to `__default_kernel_pte_mask'
make[2]: *** [arch/x86/boot/compressed/vmlinux] Error 1
make[1]: *** [arch/x86/boot/compressed/vmlinux] Error 2
make: *** [bzImage] Error 2

Thanks,
Tom

> diff -puN arch/x86/include/asm/pgtable.h~x86-no-auto-massage arch/x86/include/asm/pgtable.h
> --- a/arch/x86/include/asm/pgtable.h~x86-no-auto-massage	2018-04-02 16:41:14.811605173 -0700
> +++ b/arch/x86/include/asm/pgtable.h	2018-04-02 16:41:14.829605173 -0700
> @@ -526,22 +526,39 @@ static inline pgprotval_t massage_pgprot
>  	return protval;
>  }
>  
> +static inline pgprotval_t check_pgprot(pgprot_t pgprot)
> +{
> +	pgprotval_t massaged_val = massage_pgprot(pgprot);
> +
> +	/* mmdebug.h can not be included here because of dependencies */
> +#ifdef CONFIG_DEBUG_VM
> +	WARN_ONCE(pgprot_val(pgprot) != massaged_val,
> +		  "attempted to set unsupported pgprot: %016lx "
> +		  "bits: %016lx supported: %016lx\n",
> +		  pgprot_val(pgprot),
> +		  pgprot_val(pgprot) ^ massaged_val,
> +		  __supported_pte_mask);
> +#endif
> +
> +	return massaged_val;
> +}
> +
>  static inline pte_t pfn_pte(unsigned long page_nr, pgprot_t pgprot)
>  {
>  	return __pte(((phys_addr_t)page_nr << PAGE_SHIFT) |
> -		     massage_pgprot(pgprot));
> +		     check_pgprot(pgprot));
>  }
>  
>  static inline pmd_t pfn_pmd(unsigned long page_nr, pgprot_t pgprot)
>  {
>  	return __pmd(((phys_addr_t)page_nr << PAGE_SHIFT) |
> -		     massage_pgprot(pgprot));
> +		     check_pgprot(pgprot));
>  }
>  
>  static inline pud_t pfn_pud(unsigned long page_nr, pgprot_t pgprot)
>  {
>  	return __pud(((phys_addr_t)page_nr << PAGE_SHIFT) |
> -		     massage_pgprot(pgprot));
> +		     check_pgprot(pgprot));
>  }
>  
>  static inline pte_t pte_modify(pte_t pte, pgprot_t newprot)
> @@ -553,7 +570,7 @@ static inline pte_t pte_modify(pte_t pte
>  	 * the newprot (if present):
>  	 */
>  	val &= _PAGE_CHG_MASK;
> -	val |= massage_pgprot(newprot) & ~_PAGE_CHG_MASK;
> +	val |= check_pgprot(newprot) & ~_PAGE_CHG_MASK;
>  
>  	return __pte(val);
>  }
> @@ -563,7 +580,7 @@ static inline pmd_t pmd_modify(pmd_t pmd
>  	pmdval_t val = pmd_val(pmd);
>  
>  	val &= _HPAGE_CHG_MASK;
> -	val |= massage_pgprot(newprot) & ~_HPAGE_CHG_MASK;
> +	val |= check_pgprot(newprot) & ~_HPAGE_CHG_MASK;
>  
>  	return __pmd(val);
>  }
> diff -puN arch/x86/kernel/head64.c~x86-no-auto-massage arch/x86/kernel/head64.c
> --- a/arch/x86/kernel/head64.c~x86-no-auto-massage	2018-04-02 16:41:14.813605173 -0700
> +++ b/arch/x86/kernel/head64.c	2018-04-02 16:41:14.830605173 -0700
> @@ -195,6 +195,8 @@ unsigned long __head __startup_64(unsign
>  	pud[i + 1] = (pudval_t)pmd + pgtable_flags;
>  
>  	pmd_entry = __PAGE_KERNEL_LARGE_EXEC & ~_PAGE_GLOBAL;
> +	/* Filter out unsupported __PAGE_KERNEL_* bits: */
> +	pmd_entry &= __supported_pte_mask;
>  	pmd_entry += sme_get_me_mask();
>  	pmd_entry +=  physaddr;
>  
> diff -puN arch/x86/kernel/ldt.c~x86-no-auto-massage arch/x86/kernel/ldt.c
> --- a/arch/x86/kernel/ldt.c~x86-no-auto-massage	2018-04-02 16:41:14.815605173 -0700
> +++ b/arch/x86/kernel/ldt.c	2018-04-02 16:41:14.830605173 -0700
> @@ -145,6 +145,7 @@ map_ldt_struct(struct mm_struct *mm, str
>  		unsigned long offset = i << PAGE_SHIFT;
>  		const void *src = (char *)ldt->entries + offset;
>  		unsigned long pfn;
> +		pgprot_t pte_prot;
>  		pte_t pte, *ptep;
>  
>  		va = (unsigned long)ldt_slot_va(slot) + offset;
> @@ -163,7 +164,10 @@ map_ldt_struct(struct mm_struct *mm, str
>  		 * target via some kernel interface which misses a
>  		 * permission check.
>  		 */
> -		pte = pfn_pte(pfn, __pgprot(__PAGE_KERNEL_RO & ~_PAGE_GLOBAL));
> +	       	pte_prot = __pgprot(__PAGE_KERNEL_RO & ~_PAGE_GLOBAL);
> +		/* Filter out unsuppored __PAGE_KERNEL* bits: */
> +		pgprot_val(pte_prot) |= __supported_pte_mask;
> +		pte = pfn_pte(pfn, pte_prot);
>  		set_pte_at(mm, va, ptep, pte);
>  		pte_unmap_unlock(ptep, ptl);
>  	}
> diff -puN arch/x86/mm/ident_map.c~x86-no-auto-massage arch/x86/mm/ident_map.c
> --- a/arch/x86/mm/ident_map.c~x86-no-auto-massage	2018-04-02 16:41:14.817605173 -0700
> +++ b/arch/x86/mm/ident_map.c	2018-04-02 16:41:14.830605173 -0700
> @@ -98,6 +98,9 @@ int kernel_ident_mapping_init(struct x86
>  	if (!info->kernpg_flag)
>  		info->kernpg_flag = _KERNPG_TABLE;
>  
> +	/* Filter out unsupported __PAGE_KERNEL_* bits: */
> +	info->kernpg_flag &= __default_kernel_pte_mask;
> +
>  	for (; addr < end; addr = next) {
>  		pgd_t *pgd = pgd_page + pgd_index(addr);
>  		p4d_t *p4d;
> diff -puN arch/x86/mm/iomap_32.c~x86-no-auto-massage arch/x86/mm/iomap_32.c
> --- a/arch/x86/mm/iomap_32.c~x86-no-auto-massage	2018-04-02 16:41:14.818605173 -0700
> +++ b/arch/x86/mm/iomap_32.c	2018-04-02 16:41:14.830605173 -0700
> @@ -44,6 +44,9 @@ int iomap_create_wc(resource_size_t base
>  		return ret;
>  
>  	*prot = __pgprot(__PAGE_KERNEL | cachemode2protval(pcm));
> +	/* Filter out unsupported __PAGE_KERNEL* bits: */
> +	pgprot_val(*prot) &= __default_kernel_pte_mask;
> +
>  	return 0;
>  }
>  EXPORT_SYMBOL_GPL(iomap_create_wc);
> @@ -88,6 +91,9 @@ iomap_atomic_prot_pfn(unsigned long pfn,
>  		prot = __pgprot(__PAGE_KERNEL |
>  				cachemode2protval(_PAGE_CACHE_MODE_UC_MINUS));
>  
> +	/* Filter out unsupported __PAGE_KERNEL* bits: */
> +	pgprot_val(prot) &= __default_kernel_pte_mask;
> +
>  	return (void __force __iomem *) kmap_atomic_prot_pfn(pfn, prot);
>  }
>  EXPORT_SYMBOL_GPL(iomap_atomic_prot_pfn);
> diff -puN arch/x86/mm/ioremap.c~x86-no-auto-massage arch/x86/mm/ioremap.c
> --- a/arch/x86/mm/ioremap.c~x86-no-auto-massage	2018-04-02 16:41:14.820605173 -0700
> +++ b/arch/x86/mm/ioremap.c	2018-04-02 16:41:14.831605173 -0700
> @@ -816,6 +816,9 @@ void __init __early_set_fixmap(enum fixe
>  	}
>  	pte = early_ioremap_pte(addr);
>  
> +        /* Sanitize 'prot' against any unsupported bits: */
> +        pgprot_val(flags) &= __default_kernel_pte_mask;
> +
>  	if (pgprot_val(flags))
>  		set_pte(pte, pfn_pte(phys >> PAGE_SHIFT, flags));
>  	else
> diff -puN arch/x86/mm/kasan_init_64.c~x86-no-auto-massage arch/x86/mm/kasan_init_64.c
> --- a/arch/x86/mm/kasan_init_64.c~x86-no-auto-massage	2018-04-02 16:41:14.822605173 -0700
> +++ b/arch/x86/mm/kasan_init_64.c	2018-04-02 16:41:14.831605173 -0700
> @@ -269,6 +269,12 @@ void __init kasan_early_init(void)
>  	pudval_t pud_val = __pa_nodebug(kasan_zero_pmd) | _KERNPG_TABLE;
>  	p4dval_t p4d_val = __pa_nodebug(kasan_zero_pud) | _KERNPG_TABLE;
>  
> +	/* Mask out unsupported __PAGE_KERNEL bits: */
> +	pte_val &= __default_kernel_pte_mask;
> +	pmd_val &= __default_kernel_pte_mask;
> +	pud_val &= __default_kernel_pte_mask;
> +	p4d_val &= __default_kernel_pte_mask;
> +
>  	for (i = 0; i < PTRS_PER_PTE; i++)
>  		kasan_zero_pte[i] = __pte(pte_val);
>  
> @@ -371,7 +377,13 @@ void __init kasan_init(void)
>  	 */
>  	memset(kasan_zero_page, 0, PAGE_SIZE);
>  	for (i = 0; i < PTRS_PER_PTE; i++) {
> -		pte_t pte = __pte(__pa(kasan_zero_page) | __PAGE_KERNEL_RO | _PAGE_ENC);
> +		pte_t pte;
> +		pgprot_t prot;
> +
> +		prot = __pgprot(__PAGE_KERNEL_RO | _PAGE_ENC);
> +		pgprot_val(prot) &= __default_kernel_pte_mask;
> +
> +		pte = __pte(__pa(kasan_zero_page) | pgprot_val(prot));
>  		set_pte(&kasan_zero_pte[i], pte);
>  	}
>  	/* Flush TLBs again to be sure that write protection applied. */
> diff -puN arch/x86/mm/pgtable.c~x86-no-auto-massage arch/x86/mm/pgtable.c
> --- a/arch/x86/mm/pgtable.c~x86-no-auto-massage	2018-04-02 16:41:14.824605173 -0700
> +++ b/arch/x86/mm/pgtable.c	2018-04-02 16:41:14.831605173 -0700
> @@ -583,6 +583,9 @@ void __native_set_fixmap(enum fixed_addr
>  void native_set_fixmap(enum fixed_addresses idx, phys_addr_t phys,
>  		       pgprot_t flags)
>  {
> +	/* Sanitize 'prot' against any unsupported bits: */
> +	pgprot_val(flags) &= __default_kernel_pte_mask;
> +
>  	__native_set_fixmap(idx, pfn_pte(phys >> PAGE_SHIFT, flags));
>  }
>  
> diff -puN arch/x86/power/hibernate_64.c~x86-no-auto-massage arch/x86/power/hibernate_64.c
> --- a/arch/x86/power/hibernate_64.c~x86-no-auto-massage	2018-04-02 16:41:14.826605173 -0700
> +++ b/arch/x86/power/hibernate_64.c	2018-04-02 16:41:14.831605173 -0700
> @@ -51,6 +51,12 @@ static int set_up_temporary_text_mapping
>  	pmd_t *pmd;
>  	pud_t *pud;
>  	p4d_t *p4d = NULL;
> +	pgprot_t pgtable_prot = __pgprot(_KERNPG_TABLE);
> +	pgprot_t pmd_text_prot = __pgprot(__PAGE_KERNEL_LARGE_EXEC);
> +
> +	/* Filter out unsupported __PAGE_KERNEL* bits: */
> +	pgprot_val(pmd_text_prot) &= __default_kernel_pte_mask;
> +	pgprot_val(pgtable_prot)  &= __default_kernel_pte_mask;
>  
>  	/*
>  	 * The new mapping only has to cover the page containing the image
> @@ -81,15 +87,19 @@ static int set_up_temporary_text_mapping
>  		return -ENOMEM;
>  
>  	set_pmd(pmd + pmd_index(restore_jump_address),
> -		__pmd((jump_address_phys & PMD_MASK) | __PAGE_KERNEL_LARGE_EXEC));
> +		__pmd((jump_address_phys & PMD_MASK) | pgprot_val(pmd_text_prot)));
>  	set_pud(pud + pud_index(restore_jump_address),
> -		__pud(__pa(pmd) | _KERNPG_TABLE));
> +		__pud(__pa(pmd) | pgprot_val(pgtable_prot)));
>  	if (p4d) {
> -		set_p4d(p4d + p4d_index(restore_jump_address), __p4d(__pa(pud) | _KERNPG_TABLE));
> -		set_pgd(pgd + pgd_index(restore_jump_address), __pgd(__pa(p4d) | _KERNPG_TABLE));
> +		p4d_t new_p4d = __p4d(__pa(pud) | pgprot_val(pgtable_prot));
> +		pgd_t new_pgd = __pgd(__pa(p4d) | pgprot_val(pgtable_prot));
> +
> +		set_p4d(p4d + p4d_index(restore_jump_address), new_p4d);
> +		set_pgd(pgd + pgd_index(restore_jump_address), new_pgd);
>  	} else {
>  		/* No p4d for 4-level paging: point the pgd to the pud page table */
> -		set_pgd(pgd + pgd_index(restore_jump_address), __pgd(__pa(pud) | _KERNPG_TABLE));
> +		pgd_t new_pgd = __pgd(__pa(p4d) | pgprot_val(pgtable_prot));
> +		set_pgd(pgd + pgd_index(restore_jump_address), new_pgd);
>  	}
>  
>  	return 0;
> _
> 
