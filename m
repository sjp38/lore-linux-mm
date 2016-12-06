Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 326D86B0069
	for <linux-mm@kvack.org>; Tue,  6 Dec 2016 12:03:12 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id g186so29708999pgc.2
        for <linux-mm@kvack.org>; Tue, 06 Dec 2016 09:03:12 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id c3si20233678pld.29.2016.12.06.09.03.10
        for <linux-mm@kvack.org>;
        Tue, 06 Dec 2016 09:03:10 -0800 (PST)
Date: Tue, 6 Dec 2016 17:02:22 +0000
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCHv4 05/10] arm64: Use __pa_symbol for kernel symbols
Message-ID: <20161206170222.GE24177@leverpostej>
References: <1480445729-27130-1-git-send-email-labbott@redhat.com>
 <1480445729-27130-6-git-send-email-labbott@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1480445729-27130-6-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Christoffer Dall <christoffer.dall@linaro.org>, Marc Zyngier <marc.zyngier@arm.com>, Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-arm-kernel@lists.infradead.org

Hi,

As a heads-up, it looks like this got mangled somewhere. In the hunk at
arch/arm64/mm/kasan_init.c:68, 'do' in the context became 'edo'.
Deleting the 'e' makes it apply.

I think this is almost there; other than James's hibernate bug I only
see one real issue, and everything else is a minor nit.

On Tue, Nov 29, 2016 at 10:55:24AM -0800, Laura Abbott wrote:
> __pa_symbol is technically the marco that should be used for kernel
> symbols. Switch to this as a pre-requisite for DEBUG_VIRTUAL which
> will do bounds checking. As part of this, introduce lm_alias, a
> macro which wraps the __va(__pa(...)) idiom used a few places to
> get the alias.

I think the addition of the lm_alias() macro under include/mm should be
a separate preparatory patch. That way it's separate from the
arm64-specific parts, and more obvious to !arm64 people reviewing the
other parts.

> Signed-off-by: Laura Abbott <labbott@redhat.com>
> ---
> v4: Stop calling __va early, conversion of a few more sites. I decided against
> wrapping the __p*d_populate calls into new functions since the call sites
> should be limited.
> ---
>  arch/arm64/include/asm/kvm_mmu.h          |  4 ++--
>  arch/arm64/include/asm/memory.h           |  2 ++
>  arch/arm64/include/asm/mmu_context.h      |  6 +++---
>  arch/arm64/include/asm/pgtable.h          |  2 +-
>  arch/arm64/kernel/acpi_parking_protocol.c |  2 +-
>  arch/arm64/kernel/cpu-reset.h             |  2 +-
>  arch/arm64/kernel/cpufeature.c            |  2 +-
>  arch/arm64/kernel/hibernate.c             | 13 +++++--------
>  arch/arm64/kernel/insn.c                  |  2 +-
>  arch/arm64/kernel/psci.c                  |  2 +-
>  arch/arm64/kernel/setup.c                 |  8 ++++----
>  arch/arm64/kernel/smp_spin_table.c        |  2 +-
>  arch/arm64/kernel/vdso.c                  |  4 ++--
>  arch/arm64/mm/init.c                      | 11 ++++++-----
>  arch/arm64/mm/kasan_init.c                | 21 +++++++++++++-------
>  arch/arm64/mm/mmu.c                       | 32 +++++++++++++++++++------------
>  drivers/firmware/psci.c                   |  2 +-
>  include/linux/mm.h                        |  4 ++++
>  18 files changed, 70 insertions(+), 51 deletions(-)

It looks like we need to make sure these (directly) include <linux/mm.h>
for __pa_symbol() and lm_alias(), or there's some fragility, e.g.

[mark@leverpostej:~/src/linux]% uselinaro 15.08 make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j10 -s
arch/arm64/kernel/psci.c: In function 'cpu_psci_cpu_boot':
arch/arm64/kernel/psci.c:48:50: error: implicit declaration of function '__pa_symbol' [-Werror=implicit-function-declaration]
  int err = psci_ops.cpu_on(cpu_logical_map(cpu), __pa_symbol(secondary_entry));
                                                  ^
cc1: some warnings being treated as errors
make[1]: *** [arch/arm64/kernel/psci.o] Error 1
make: *** [arch/arm64/kernel] Error 2
make: *** Waiting for unfinished jobs....

> --- a/arch/arm64/include/asm/memory.h
> +++ b/arch/arm64/include/asm/memory.h
> @@ -205,6 +205,8 @@ static inline void *phys_to_virt(phys_addr_t x)
>  #define __va(x)			((void *)__phys_to_virt((phys_addr_t)(x)))
>  #define pfn_to_kaddr(pfn)	__va((pfn) << PAGE_SHIFT)
>  #define virt_to_pfn(x)      __phys_to_pfn(__virt_to_phys((unsigned long)(x)))
> +#define sym_to_pfn(x)	    __phys_to_pfn(__pa_symbol(x))
> +#define lm_alias(x)		__va(__pa_symbol(x))

As Catalin mentioned, we should be able to drop this copy of lm_alias(),
given we have the same in the core headers.

> diff --git a/arch/arm64/kernel/vdso.c b/arch/arm64/kernel/vdso.c
> index a2c2478..79cd86b 100644
> --- a/arch/arm64/kernel/vdso.c
> +++ b/arch/arm64/kernel/vdso.c
> @@ -140,11 +140,11 @@ static int __init vdso_init(void)
>  		return -ENOMEM;
>  
>  	/* Grab the vDSO data page. */
> -	vdso_pagelist[0] = pfn_to_page(PHYS_PFN(__pa(vdso_data)));
> +	vdso_pagelist[0] = phys_to_page(__pa_symbol(vdso_data));
>  
>  	/* Grab the vDSO code pages. */
>  	for (i = 0; i < vdso_pages; i++)
> -		vdso_pagelist[i + 1] = pfn_to_page(PHYS_PFN(__pa(&vdso_start)) + i);
> +		vdso_pagelist[i + 1] = pfn_to_page(PHYS_PFN(__pa_symbol(&vdso_start)) + i);

I see you added sym_to_pfn(), which we can use here to keep this short
and legible. It might also be worth using a temporary pfn_t, e.g.

	pfn = sym_to_pfn(&vdso_start);

	for (i = 0; i < vdso_pages; i++)
		vdso_pagelist[i + 1] = pfn_to_page(pfn + i);

> diff --git a/drivers/firmware/psci.c b/drivers/firmware/psci.c
> index 8263429..9defbe2 100644
> --- a/drivers/firmware/psci.c
> +++ b/drivers/firmware/psci.c
> @@ -383,7 +383,7 @@ static int psci_suspend_finisher(unsigned long index)
>  	u32 *state = __this_cpu_read(psci_power_state);
>  
>  	return psci_ops.cpu_suspend(state[index - 1],
> -				    virt_to_phys(cpu_resume));
> +				    __pa_symbol(cpu_resume));
>  }
>  
>  int psci_cpu_suspend_enter(unsigned long index)

This should probably be its own patch since it's not under arch/arm64/.

I'm happy for this to go via the arm64 tree with the rest regardless
(assuming Lorenzo has no objections).

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
