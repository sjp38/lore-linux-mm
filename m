Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id A71116B027A
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 03:59:04 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id b189so3085636oia.10
        for <linux-mm@kvack.org>; Thu, 12 Oct 2017 00:59:04 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id l32si7509067otb.27.2017.10.12.00.59.02
        for <linux-mm@kvack.org>;
        Thu, 12 Oct 2017 00:59:02 -0700 (PDT)
Subject: Re: [PATCH 01/11] Initialize the mapping of KASan shadow memory
References: <20171011082227.20546-1-liuwenliang@huawei.com>
 <20171011082227.20546-2-liuwenliang@huawei.com>
From: Marc Zyngier <marc.zyngier@arm.com>
Message-ID: <227e2c6e-f479-849d-8942-1d5ff4ccd440@arm.com>
Date: Thu, 12 Oct 2017 08:58:53 +0100
MIME-Version: 1.0
In-Reply-To: <20171011082227.20546-2-liuwenliang@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Abbott Liu <liuwenliang@huawei.com>, linux@armlinux.org.uk, aryabinin@virtuozzo.com, afzal.mohd.ma@gmail.com, f.fainelli@gmail.com, labbott@redhat.com, kirill.shutemov@linux.intel.com, mhocko@suse.com, cdall@linaro.org, catalin.marinas@arm.com, akpm@linux-foundation.org, mawilcox@microsoft.com, tglx@linutronix.de, thgarnie@google.com, keescook@chromium.org, arnd@arndb.de, vladimir.murzin@arm.com, tixy@linaro.org, ard.biesheuvel@linaro.org, robin.murphy@arm.com, mingo@kernel.org, grygorii.strashko@linaro.org
Cc: glider@google.com, dvyukov@google.com, opendmb@gmail.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, jiazhenghua@huawei.com, dylix.dailei@huawei.com, zengweilin@huawei.com, heshaoliang@huawei.com

On 11/10/17 09:22, Abbott Liu wrote:
> From: Andrey Ryabinin <a.ryabinin@samsung.com>
> 
> This patch initializes KASan shadow region's page table and memory.
> There are two stage for KASan initializing:
> 1. At early boot stage the whole shadow region is mapped to just
>    one physical page (kasan_zero_page). It's finished by the function
>    kasan_early_init which is called by __mmap_switched(arch/arm/kernel/
>    head-common.S)
> 
> 2. After the calling of paging_init, we use kasan_zero_page as zero
>    shadow for some memory that KASan don't need to track, and we alloc
>    new shadow space for the other memory that KASan need to track. These
>    issues are finished by the function kasan_init which is call by setup_arch.
> 
> Cc: Andrey Ryabinin <a.ryabinin@samsung.com>
> Signed-off-by: Abbott Liu <liuwenliang@huawei.com>
> ---
>  arch/arm/include/asm/kasan.h       |  20 +++
>  arch/arm/include/asm/pgalloc.h     |   5 +-
>  arch/arm/include/asm/pgtable.h     |   1 +
>  arch/arm/include/asm/proc-fns.h    |  33 +++++
>  arch/arm/include/asm/thread_info.h |   4 +
>  arch/arm/kernel/head-common.S      |   4 +
>  arch/arm/kernel/setup.c            |   2 +
>  arch/arm/mm/Makefile               |   5 +
>  arch/arm/mm/kasan_init.c           | 257 +++++++++++++++++++++++++++++++++++++
>  mm/kasan/kasan.c                   |   2 +-
>  10 files changed, 331 insertions(+), 2 deletions(-)
>  create mode 100644 arch/arm/include/asm/kasan.h
>  create mode 100644 arch/arm/mm/kasan_init.c
> 
> diff --git a/arch/arm/include/asm/kasan.h b/arch/arm/include/asm/kasan.h
> new file mode 100644
> index 0000000..90ee60c
> --- /dev/null
> +++ b/arch/arm/include/asm/kasan.h
> @@ -0,0 +1,20 @@
> +#ifndef __ASM_KASAN_H
> +#define __ASM_KASAN_H
> +
> +#ifdef CONFIG_KASAN
> +
> +#include <asm/kasan_def.h>
> +/*
> + * Compiler uses shadow offset assuming that addresses start
> + * from 0. Kernel addresses don't start from 0, so shadow
> + * for kernel really starts from 'compiler's shadow offset' +
> + * ('kernel address space start' >> KASAN_SHADOW_SCALE_SHIFT)
> + */
> +
> +extern void kasan_init(void);
> +
> +#else
> +static inline void kasan_init(void) { }
> +#endif
> +
> +#endif
> diff --git a/arch/arm/include/asm/pgalloc.h b/arch/arm/include/asm/pgalloc.h
> index b2902a5..10cee6a 100644
> --- a/arch/arm/include/asm/pgalloc.h
> +++ b/arch/arm/include/asm/pgalloc.h
> @@ -50,8 +50,11 @@ static inline void pud_populate(struct mm_struct *mm, pud_t *pud, pmd_t *pmd)
>   */
>  #define pmd_alloc_one(mm,addr)		({ BUG(); ((pmd_t *)2); })
>  #define pmd_free(mm, pmd)		do { } while (0)
> +#ifndef CONFIG_KASAN
>  #define pud_populate(mm,pmd,pte)	BUG()
> -
> +#else
> +#define pud_populate(mm,pmd,pte)	do { } while (0)
> +#endif
>  #endif	/* CONFIG_ARM_LPAE */
>  
>  extern pgd_t *pgd_alloc(struct mm_struct *mm);
> diff --git a/arch/arm/include/asm/pgtable.h b/arch/arm/include/asm/pgtable.h
> index 1c46238..fdf343f 100644
> --- a/arch/arm/include/asm/pgtable.h
> +++ b/arch/arm/include/asm/pgtable.h
> @@ -97,6 +97,7 @@ extern pgprot_t		pgprot_s2_device;
>  #define PAGE_READONLY		_MOD_PROT(pgprot_user, L_PTE_USER | L_PTE_RDONLY | L_PTE_XN)
>  #define PAGE_READONLY_EXEC	_MOD_PROT(pgprot_user, L_PTE_USER | L_PTE_RDONLY)
>  #define PAGE_KERNEL		_MOD_PROT(pgprot_kernel, L_PTE_XN)
> +#define PAGE_KERNEL_RO		_MOD_PROT(pgprot_kernel, L_PTE_XN | L_PTE_RDONLY)
>  #define PAGE_KERNEL_EXEC	pgprot_kernel
>  #define PAGE_HYP		_MOD_PROT(pgprot_kernel, L_PTE_HYP | L_PTE_XN)
>  #define PAGE_HYP_EXEC		_MOD_PROT(pgprot_kernel, L_PTE_HYP | L_PTE_RDONLY)
> diff --git a/arch/arm/include/asm/proc-fns.h b/arch/arm/include/asm/proc-fns.h
> index f2e1af4..6e26714 100644
> --- a/arch/arm/include/asm/proc-fns.h
> +++ b/arch/arm/include/asm/proc-fns.h
> @@ -131,6 +131,15 @@ extern void cpu_resume(void);
>  		pg &= ~(PTRS_PER_PGD*sizeof(pgd_t)-1);	\
>  		(pgd_t *)phys_to_virt(pg);		\
>  	})
> +
> +#define cpu_set_ttbr0(val)					\
> +	do {							\
> +		u64 ttbr = val;					\
> +		__asm__("mcrr	p15, 0, %Q0, %R0, c2"		\
> +			: : "r" (ttbr));	\
> +	} while (0)
> +
> +
>  #else
>  #define cpu_get_pgd()	\
>  	({						\
> @@ -140,6 +149,30 @@ extern void cpu_resume(void);
>  		pg &= ~0x3fff;				\
>  		(pgd_t *)phys_to_virt(pg);		\
>  	})
> +
> +#define cpu_set_ttbr(nr, val)					\
> +	do {							\
> +		u64 ttbr = val;					\
> +		__asm__("mcr	p15, 0, %0, c2, c0, 0"		\
> +			: : "r" (ttbr));			\
> +	} while (0)
> +
> +#define cpu_get_ttbr(nr)					\
> +	({							\
> +		unsigned long ttbr;				\
> +		__asm__("mrc	p15, 0, %0, c2, c0, 0"		\
> +			: "=r" (ttbr));				\
> +		ttbr;						\
> +	})
> +
> +#define cpu_set_ttbr0(val)					\
> +	do {							\
> +		u64 ttbr = val;					\
> +		__asm__("mcr	p15, 0, %0, c2, c0, 0"		\
> +			: : "r" (ttbr));			\
> +	} while (0)
> +
> +

You could instead lift and extend the definitions provided in kvm_hyp.h,
and use the read_sysreg/write_sysreg helpers defined in cp15.h.

Thanks,

	M.
-- 
Jazz is not dead. It just smells funny...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
