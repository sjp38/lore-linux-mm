Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 82BA6440CD7
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 05:11:02 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id n19so1354505ote.23
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 02:11:02 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id w108si3067926otb.83.2017.11.09.02.11.01
        for <linux-mm@kvack.org>;
        Thu, 09 Nov 2017 02:11:01 -0800 (PST)
Subject: Re: [PATCH 01/11] Initialize the mapping of KASan shadow memory
References: <20171011082227.20546-1-liuwenliang@huawei.com>
 <20171011082227.20546-2-liuwenliang@huawei.com>
 <227e2c6e-f479-849d-8942-1d5ff4ccd440@arm.com>
 <B8AC3E80E903784988AB3003E3E97330C0063172@dggemm510-mbs.china.huawei.com>
From: Marc Zyngier <marc.zyngier@arm.com>
Message-ID: <8e959f69-a578-793b-6c32-18b5b0cd08c2@arm.com>
Date: Thu, 9 Nov 2017 10:10:53 +0000
MIME-Version: 1.0
In-Reply-To: <B8AC3E80E903784988AB3003E3E97330C0063172@dggemm510-mbs.china.huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Liuwenliang (Abbott Liu)" <liuwenliang@huawei.com>, "linux@armlinux.org.uk" <linux@armlinux.org.uk>, "aryabinin@virtuozzo.com" <aryabinin@virtuozzo.com>, "afzal.mohd.ma@gmail.com" <afzal.mohd.ma@gmail.com>, "f.fainelli@gmail.com" <f.fainelli@gmail.com>, "labbott@redhat.com" <labbott@redhat.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "mhocko@suse.com" <mhocko@suse.com>, "cdall@linaro.org" <cdall@linaro.org>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "thgarnie@google.com" <thgarnie@google.com>, "keescook@chromium.org" <keescook@chromium.org>, "arnd@arndb.de" <arnd@arndb.de>, "vladimir.murzin@arm.com" <vladimir.murzin@arm.com>, "tixy@linaro.org" <tixy@linaro.org>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "robin.murphy@arm.com" <robin.murphy@arm.com>, "mingo@kernel.org" <mingo@kernel.org>, "grygorii.strashko@linaro.org" <grygorii.strashko@linaro.org>
Cc: "glider@google.com" <glider@google.com>, "dvyukov@google.com" <dvyukov@google.com>, "opendmb@gmail.com" <opendmb@gmail.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kasan-dev@googlegroups.com" <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Jiazhenghua <jiazhenghua@huawei.com>, Dailei <dylix.dailei@huawei.com>, Zengweilin <zengweilin@huawei.com>, Heshaoliang <heshaoliang@huawei.com>

On 09/11/17 07:46, Liuwenliang (Abbott Liu) wrote:
> On 12/10/17 15:59, Marc Zyngier [mailto:marc.zyngier@arm.com] wrote:
>> On 11/10/17 09:22, Abbott Liu wrote:
>>> diff --git a/arch/arm/include/asm/proc-fns.h b/arch/arm/include/asm/proc-fns.h
>>> index f2e1af4..6e26714 100644
>>> --- a/arch/arm/include/asm/proc-fns.h
>>> +++ b/arch/arm/include/asm/proc-fns.h
>>> @@ -131,6 +131,15 @@ extern void cpu_resume(void);
>>>  		pg &= ~(PTRS_PER_PGD*sizeof(pgd_t)-1);	\
>>>  		(pgd_t *)phys_to_virt(pg);		\
>>>  	})
>>> +
>>> +#define cpu_set_ttbr0(val)					\
>>> +	do {							\
>>> +		u64 ttbr = val;					\
>>> +		__asm__("mcrr	p15, 0, %Q0, %R0, c2"		\
>>> +			: : "r" (ttbr));	\
>>> +	} while (0)
>>> +
>>> +
>>>  #else
>>>  #define cpu_get_pgd()	\
>>>  	({						\
>>> @@ -140,6 +149,30 @@ extern void cpu_resume(void);
>>>  		pg &= ~0x3fff;				\
>>>  		(pgd_t *)phys_to_virt(pg);		\
>>>  	})
>>> +
>>> +#define cpu_set_ttbr(nr, val)					\
>>> +	do {							\
>>> +		u64 ttbr = val;					\
>>> +		__asm__("mcr	p15, 0, %0, c2, c0, 0"		\
>>> +			: : "r" (ttbr));			\
>>> +	} while (0)
>>> +
>>> +#define cpu_get_ttbr(nr)					\
>>> +	({							\
>>> +		unsigned long ttbr;				\
>>> +		__asm__("mrc	p15, 0, %0, c2, c0, 0"		\
>>> +			: "=r" (ttbr));				\
>>> +		ttbr;						\
>>> +	})
>>> +
>>> +#define cpu_set_ttbr0(val)					\
>>> +	do {							\
>>> +		u64 ttbr = val;					\
>>> +		__asm__("mcr	p15, 0, %0, c2, c0, 0"		\
>>> +			: : "r" (ttbr));			\
>>> +	} while (0)
>>> +
>>> +
>>
>> You could instead lift and extend the definitions provided in kvm_hyp.h,
>> and use the read_sysreg/write_sysreg helpers defined in cp15.h.
> 
> Thanks for your review. 
> I extend definitions of TTBR0/TTBR1/PAR in kvm_hyp.h when the CONFIG_ARM_LPAE is 
> not defined. 
> Because cortex A9 don't support virtualization, so use CONFIG_ARM_LPAE to exclude
> some functions and macros which are only used in virtualization.
> 
> Here is the code which I tested on vexpress_a15 and vexpress_a9:
> 
> diff --git a/arch/arm/include/asm/kvm_hyp.h b/arch/arm/include/asm/kvm_hyp.h
> index 14b5903..2592608 100644
> --- a/arch/arm/include/asm/kvm_hyp.h
> +++ b/arch/arm/include/asm/kvm_hyp.h
> @@ -19,12 +19,14 @@
>  #define __ARM_KVM_HYP_H__
> 
>  #include <linux/compiler.h>
> -#include <linux/kvm_host.h>
>  #include <asm/cp15.h>
> +
> +#ifdef CONFIG_ARM_LPAE
> +#include <linux/kvm_host.h>
>  #include <asm/kvm_mmu.h>
>  #include <asm/vfp.h>
> -
>  #define __hyp_text __section(.hyp.text) notrace
> +#endif
> 
>  #define __ACCESS_VFP(CRn)                      \
>         "mrc", "mcr", __stringify(p10, 7, %0, CRn, cr0, 0), u32
> @@ -37,12 +39,18 @@
>         __val;                                                  \
>  })
> 
> +#ifdef CONFIG_ARM_LPAE
>  #define TTBR0          __ACCESS_CP15_64(0, c2)
>  #define TTBR1          __ACCESS_CP15_64(1, c2)
>  #define VTTBR          __ACCESS_CP15_64(6, c2)
>  #define PAR            __ACCESS_CP15_64(0, c7)
>  #define CNTV_CVAL      __ACCESS_CP15_64(3, c14)
>  #define CNTVOFF                __ACCESS_CP15_64(4, c14)
> +#else
> +#define TTBR0           __ACCESS_CP15(c2, 0, c0, 0)
> +#define TTBR1           __ACCESS_CP15(c2, 0, c0, 1)
> +#define PAR          __ACCESS_CP15(c7, 0, c4, 0)
> +#endif

There is no reason for this LPAE vs non LPAE dichotomy. Both registers
do exist if your system supports LPAE. So you can either suffix the
64bit version with an _64 (and change the KVM code), or suffix the bit
version with _32.

> 
>  #define MIDR           __ACCESS_CP15(c0, 0, c0, 0)
>  #define CSSELR         __ACCESS_CP15(c0, 2, c0, 0)
> @@ -98,6 +106,7 @@
>  #define cntvoff_el2                    CNTVOFF
>  #define cnthctl_el2                    CNTHCTL
> 
> +#ifdef CONFIG_ARM_LPAE
>  void __timer_save_state(struct kvm_vcpu *vcpu);
>  void __timer_restore_state(struct kvm_vcpu *vcpu);
> 
> @@ -123,5 +132,6 @@ void __hyp_text __banked_restore_state(struct kvm_cpu_context *ctxt);
>  asmlinkage int __guest_enter(struct kvm_vcpu *vcpu,
>                              struct kvm_cpu_context *host);
>  asmlinkage int __hyp_do_panic(const char *, int, u32);
> +#endif
> 
>  #endif /* __ARM_KVM_HYP_H__ */
> diff --git a/arch/arm/mm/kasan_init.c b/arch/arm/mm/kasan_init.c
> index 049ee0a..359a782 100644
> --- a/arch/arm/mm/kasan_init.c
> +++ b/arch/arm/mm/kasan_init.c
> @@ -15,6 +15,7 @@
>  #include <asm/proc-fns.h>
>  #include <asm/tlbflush.h>
>  #include <asm/cp15.h>
> +#include <asm/kvm_hyp.h>

No, please don't do that. You shouldn't have to include KVM stuff in
unrelated code. Instead of adding stuff to kvm_hyp.h, move all the
__ACCESS_CP15* to cp15.h, and it will be obvious to everyone that this
is where new definition should be added.

>  #include <linux/sched/task.h>
> 
>  #include "mm.h"
> @@ -203,16 +204,16 @@ void __init kasan_init(void)
>         u64 orig_ttbr0;
>         int i;
> 
> -   orig_ttbr0 = cpu_get_ttbr(0);
> + orig_ttbr0 = read_sysreg(TTBR0);
> 
>  #ifdef CONFIG_ARM_LPAE
>         memcpy(tmp_pmd_table, pgd_page_vaddr(*pgd_offset_k(KASAN_SHADOW_START)), sizeof(tmp_pmd_table));
>         memcpy(tmp_page_table, swapper_pg_dir, sizeof(tmp_page_table));
>         set_pgd(&tmp_page_table[pgd_index(KASAN_SHADOW_START)], __pgd(__pa(tmp_pmd_table) | PMD_TYPE_TABLE | L_PGD_SWAPPER));
> -   cpu_set_ttbr0(__pa(tmp_page_table));
> + write_sysreg(__pa(tmp_page_table), TTBR0);
>  #else
>         memcpy(tmp_page_table, swapper_pg_dir, sizeof(tmp_page_table));
> -   cpu_set_ttbr0(__pa(tmp_page_table));
> + write_sysreg(__pa(tmp_page_table),TTBR0);
>  #endif
>         flush_cache_all();
>         local_flush_bp_all();
> @@ -257,7 +258,7 @@ void __init kasan_init(void)
>                                  /*__pgprot(_L_PTE_DEFAULT | L_PTE_DIRTY | L_PTE_XN | L_PTE_RDONLY))*/
>                                 __pgprot(pgprot_val(PAGE_KERNEL) | L_PTE_RDONLY)));
>         memset(kasan_zero_page, 0, PAGE_SIZE);
> -   cpu_set_ttbr0(orig_ttbr0);
> + write_sysreg(orig_ttbr0 ,TTBR0);
>         flush_cache_all();
>         local_flush_bp_all();
>         local_flush_tlb_all();
> 

Thanks,

	M.
-- 
Jazz is not dead. It just smells funny...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
