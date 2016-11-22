From: Borislav Petkov <bp@alien8.de>
Subject: Re: [RFC PATCH v3 15/20] x86: Check for memory encryption on the APs
Date: Tue, 22 Nov 2016 20:25:26 +0100
Message-ID: <20161122192526.vg63jjhwsbjwex7i@pd.tnic>
References: <20161110003426.3280.2999.stgit@tlendack-t1.amdoffice.net>
 <20161110003740.3280.57300.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-doc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161110003740.3280.57300.stgit@tlendack-t1.amdoffice.net>
Sender: linux-doc-owner@vger.kernel.org
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>
List-Id: linux-mm.kvack.org

On Wed, Nov 09, 2016 at 06:37:40PM -0600, Tom Lendacky wrote:
> Add support to check if memory encryption is active in the kernel and that
> it has been enabled on the AP. If memory encryption is active in the kernel
> but has not been enabled on the AP then do not allow the AP to continue
> start up.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---
>  arch/x86/include/asm/realmode.h      |   12 ++++++++++++
>  arch/x86/realmode/init.c             |    4 ++++
>  arch/x86/realmode/rm/trampoline_64.S |   19 +++++++++++++++++++
>  3 files changed, 35 insertions(+)
> 
> diff --git a/arch/x86/include/asm/realmode.h b/arch/x86/include/asm/realmode.h
> index 230e190..850dbe0 100644
> --- a/arch/x86/include/asm/realmode.h
> +++ b/arch/x86/include/asm/realmode.h
> @@ -1,6 +1,15 @@
>  #ifndef _ARCH_X86_REALMODE_H
>  #define _ARCH_X86_REALMODE_H
>  
> +/*
> + * Flag bit definitions for use with the flags field of the trampoline header
> + * when configured for X86_64

Let's use kernel nomenclature: "... of the trampoline header in the
CONFIG_X86_64 variant."

> + */
> +#define TH_FLAGS_SME_ENABLE_BIT		0
> +#define TH_FLAGS_SME_ENABLE		BIT_ULL(TH_FLAGS_SME_ENABLE_BIT)

BIT() is the proper one for u32 flags variable.

> +
> +#ifndef __ASSEMBLY__
> +
>  #include <linux/types.h>
>  #include <asm/io.h>
>  
> @@ -38,6 +47,7 @@ struct trampoline_header {
>  	u64 start;
>  	u64 efer;
>  	u32 cr4;
> +	u32 flags;
>  #endif
>  };
>  
> @@ -69,4 +79,6 @@ static inline size_t real_mode_size_needed(void)
>  void set_real_mode_mem(phys_addr_t mem, size_t size);
>  void reserve_real_mode(void);
>  
> +#endif /* __ASSEMBLY__ */
> +
>  #endif /* _ARCH_X86_REALMODE_H */
> diff --git a/arch/x86/realmode/init.c b/arch/x86/realmode/init.c
> index 44ed32a..a8e7ebe 100644
> --- a/arch/x86/realmode/init.c
> +++ b/arch/x86/realmode/init.c
> @@ -101,6 +101,10 @@ static void __init setup_real_mode(void)
>  	trampoline_cr4_features = &trampoline_header->cr4;
>  	*trampoline_cr4_features = mmu_cr4_features;
>  
> +	trampoline_header->flags = 0;
> +	if (sme_me_mask)
> +		trampoline_header->flags |= TH_FLAGS_SME_ENABLE;
> +
>  	trampoline_pgd = (u64 *) __va(real_mode_header->trampoline_pgd);
>  	trampoline_pgd[0] = trampoline_pgd_entry.pgd;
>  	trampoline_pgd[511] = init_level4_pgt[511].pgd;
> diff --git a/arch/x86/realmode/rm/trampoline_64.S b/arch/x86/realmode/rm/trampoline_64.S
> index dac7b20..94e29f4 100644
> --- a/arch/x86/realmode/rm/trampoline_64.S
> +++ b/arch/x86/realmode/rm/trampoline_64.S
> @@ -30,6 +30,7 @@
>  #include <asm/msr.h>
>  #include <asm/segment.h>
>  #include <asm/processor-flags.h>
> +#include <asm/realmode.h>
>  #include "realmode.h"
>  
>  	.text
> @@ -92,6 +93,23 @@ ENTRY(startup_32)
>  	movl	%edx, %fs
>  	movl	%edx, %gs
>  
> +	/* Check for memory encryption support */
> +	bt	$TH_FLAGS_SME_ENABLE_BIT, pa_tr_flags
> +	jnc	.Ldone
> +	movl	$MSR_K8_SYSCFG, %ecx
> +	rdmsr
> +	bt	$MSR_K8_SYSCFG_MEM_ENCRYPT_BIT, %eax
> +	jc	.Ldone
> +
> +	/*
> +	 * Memory encryption is enabled but the MSR has not been set on this
> +	 * CPU so we can't continue

Can this ever happen?

I mean, we set TH_FLAGS_SME_ENABLE when sme_me_mask is set and this
would have happened only if the BSP has MSR_K8_SYSCFG[23] set.

How is it possible that that bit won't be set on some of the APs but set
on the BSP?

I'd assume the BIOS is doing a consistent setting everywhere...

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
