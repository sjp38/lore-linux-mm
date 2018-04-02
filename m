Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id ED4546B0009
	for <linux-mm@kvack.org>; Mon,  2 Apr 2018 17:12:52 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id j2so12012980qtl.1
        for <linux-mm@kvack.org>; Mon, 02 Apr 2018 14:12:52 -0700 (PDT)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0044.outbound.protection.outlook.com. [104.47.33.44])
        by mx.google.com with ESMTPS id h136si1406911qka.343.2018.04.02.14.12.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 02 Apr 2018 14:12:51 -0700 (PDT)
Subject: Re: [PATCHv2 01/14] x86/mm: Decouple dynamic __PHYSICAL_MASK from AMD
 SME
References: <20180328165540.648-1-kirill.shutemov@linux.intel.com>
 <20180328165540.648-2-kirill.shutemov@linux.intel.com>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <3513ea99-eb16-6538-ea3b-148fe5d85f21@amd.com>
Date: Mon, 2 Apr 2018 16:12:16 -0500
MIME-Version: 1.0
In-Reply-To: <20180328165540.648-2-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org



On 3/28/2018 11:55 AM, Kirill A. Shutemov wrote:
> AMD SME claims one bit from physical address to indicate whether the
> page is encrypted or not. To achieve that we clear out the bit from
> __PHYSICAL_MASK.
> 
> The capability to adjust __PHYSICAL_MASK is required beyond AMD SME.
> For instance for upcoming Intel Multi-Key Total Memory Encryption.
> 
> Factor it out into a separate feature with own Kconfig handle.
> 
> It also helps with overhead of AMD SME. It saves more than 3k in .text
> on defconfig + AMD_MEM_ENCRYPT:
> 
> 	add/remove: 3/2 grow/shrink: 5/110 up/down: 189/-3753 (-3564)
> 
> We would need to return to this once we have infrastructure to patch
> constants in code. That's good candidate for it.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Reviewed-by: Tom Lendacky <thomas.lendacky@amd.com>

> ---
>  arch/x86/Kconfig                    | 4 ++++
>  arch/x86/boot/compressed/kaslr_64.c | 5 +++++
>  arch/x86/include/asm/page_types.h   | 8 +++++++-
>  arch/x86/mm/mem_encrypt_identity.c  | 3 +++
>  arch/x86/mm/pgtable.c               | 5 +++++
>  5 files changed, 24 insertions(+), 1 deletion(-)
> 
> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> index 27fede438959..bf68138662c8 100644
> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -332,6 +332,9 @@ config ARCH_SUPPORTS_UPROBES
>  config FIX_EARLYCON_MEM
>  	def_bool y
>  
> +config DYNAMIC_PHYSICAL_MASK
> +	bool
> +
>  config PGTABLE_LEVELS
>  	int
>  	default 5 if X86_5LEVEL
> @@ -1503,6 +1506,7 @@ config ARCH_HAS_MEM_ENCRYPT
>  config AMD_MEM_ENCRYPT
>  	bool "AMD Secure Memory Encryption (SME) support"
>  	depends on X86_64 && CPU_SUP_AMD
> +	select DYNAMIC_PHYSICAL_MASK
>  	---help---
>  	  Say yes to enable support for the encryption of system memory.
>  	  This requires an AMD processor that supports Secure Memory
> diff --git a/arch/x86/boot/compressed/kaslr_64.c b/arch/x86/boot/compressed/kaslr_64.c
> index 522d11431433..748456c365f4 100644
> --- a/arch/x86/boot/compressed/kaslr_64.c
> +++ b/arch/x86/boot/compressed/kaslr_64.c
> @@ -69,6 +69,8 @@ static struct alloc_pgt_data pgt_data;
>  /* The top level page table entry pointer. */
>  static unsigned long top_level_pgt;
>  
> +phys_addr_t physical_mask = (1ULL << __PHYSICAL_MASK_SHIFT) - 1;
> +
>  /*
>   * Mapping information structure passed to kernel_ident_mapping_init().
>   * Due to relocation, pointers must be assigned at run time not build time.
> @@ -81,6 +83,9 @@ void initialize_identity_maps(void)
>  	/* If running as an SEV guest, the encryption mask is required. */
>  	set_sev_encryption_mask();
>  
> +	/* Exclude the encryption mask from __PHYSICAL_MASK */
> +	physical_mask &= ~sme_me_mask;
> +
>  	/* Init mapping_info with run-time function/buffer pointers. */
>  	mapping_info.alloc_pgt_page = alloc_pgt_page;
>  	mapping_info.context = &pgt_data;
> diff --git a/arch/x86/include/asm/page_types.h b/arch/x86/include/asm/page_types.h
> index 1e53560a84bb..c85e15010f48 100644
> --- a/arch/x86/include/asm/page_types.h
> +++ b/arch/x86/include/asm/page_types.h
> @@ -17,7 +17,6 @@
>  #define PUD_PAGE_SIZE		(_AC(1, UL) << PUD_SHIFT)
>  #define PUD_PAGE_MASK		(~(PUD_PAGE_SIZE-1))
>  
> -#define __PHYSICAL_MASK		((phys_addr_t)(__sme_clr((1ULL << __PHYSICAL_MASK_SHIFT) - 1)))
>  #define __VIRTUAL_MASK		((1UL << __VIRTUAL_MASK_SHIFT) - 1)
>  
>  /* Cast *PAGE_MASK to a signed type so that it is sign-extended if
> @@ -55,6 +54,13 @@
>  
>  #ifndef __ASSEMBLY__
>  
> +#ifdef CONFIG_DYNAMIC_PHYSICAL_MASK
> +extern phys_addr_t physical_mask;
> +#define __PHYSICAL_MASK		physical_mask
> +#else
> +#define __PHYSICAL_MASK		((phys_addr_t)((1ULL << __PHYSICAL_MASK_SHIFT) - 1))
> +#endif
> +
>  extern int devmem_is_allowed(unsigned long pagenr);
>  
>  extern unsigned long max_low_pfn_mapped;
> diff --git a/arch/x86/mm/mem_encrypt_identity.c b/arch/x86/mm/mem_encrypt_identity.c
> index 1b2197d13832..7ae36868aed2 100644
> --- a/arch/x86/mm/mem_encrypt_identity.c
> +++ b/arch/x86/mm/mem_encrypt_identity.c
> @@ -527,6 +527,7 @@ void __init sme_enable(struct boot_params *bp)
>  		/* SEV state cannot be controlled by a command line option */
>  		sme_me_mask = me_mask;
>  		sev_enabled = true;
> +		physical_mask &= ~sme_me_mask;
>  		return;
>  	}
>  
> @@ -561,4 +562,6 @@ void __init sme_enable(struct boot_params *bp)
>  		sme_me_mask = 0;
>  	else
>  		sme_me_mask = active_by_default ? me_mask : 0;
> +
> +	physical_mask &= ~sme_me_mask;
>  }
> diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
> index 34cda7e0551b..0199b94e6b40 100644
> --- a/arch/x86/mm/pgtable.c
> +++ b/arch/x86/mm/pgtable.c
> @@ -7,6 +7,11 @@
>  #include <asm/fixmap.h>
>  #include <asm/mtrr.h>
>  
> +#ifdef CONFIG_DYNAMIC_PHYSICAL_MASK
> +phys_addr_t physical_mask __ro_after_init = (1ULL << __PHYSICAL_MASK_SHIFT) - 1;
> +EXPORT_SYMBOL(physical_mask);
> +#endif
> +
>  #define PGALLOC_GFP (GFP_KERNEL_ACCOUNT | __GFP_ZERO)
>  
>  #ifdef CONFIG_HIGHPTE
> 
