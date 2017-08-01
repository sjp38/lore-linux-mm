Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 786126B056B
	for <linux-mm@kvack.org>; Tue,  1 Aug 2017 13:15:03 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id k68so3137631wmd.14
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 10:15:03 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w20si25063158wrc.519.2017.08.01.10.15.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 01 Aug 2017 10:15:01 -0700 (PDT)
Subject: Re: [PATCHv2 08/10] x86/mm: Replace compile-time checks for 5-level
 with runtime-time
References: <20170718141517.52202-1-kirill.shutemov@linux.intel.com>
 <20170718141517.52202-9-kirill.shutemov@linux.intel.com>
 <6841c4f3-6794-f0ac-9af9-0ceb56e49653@suse.com>
 <20170725090538.26sbgb4npkztsqj3@black.fi.intel.com>
 <39cb1e36-f94e-32ea-c94a-2daddcbf3408@suse.com>
 <20170726164335.xaajz5ltzhncju26@node.shutemov.name>
 <c450949e-bd79-c9c9-797e-be6b2c7b1e5f@suse.com>
 <20170801144414.rd67k2g2cz46nlow@black.fi.intel.com>
From: Juergen Gross <jgross@suse.com>
Message-ID: <d7d46a3c-1a01-1f35-99ed-6c1587275433@suse.com>
Date: Tue, 1 Aug 2017 19:14:57 +0200
MIME-Version: 1.0
In-Reply-To: <20170801144414.rd67k2g2cz46nlow@black.fi.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: de-DE
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 01/08/17 16:44, Kirill A. Shutemov wrote:
> On Tue, Aug 01, 2017 at 09:46:56AM +0200, Juergen Gross wrote:
>> On 26/07/17 18:43, Kirill A. Shutemov wrote:
>>> On Wed, Jul 26, 2017 at 09:28:16AM +0200, Juergen Gross wrote:
>>>> On 25/07/17 11:05, Kirill A. Shutemov wrote:
>>>>> On Tue, Jul 18, 2017 at 04:24:06PM +0200, Juergen Gross wrote:
>>>>>> Xen PV guests will never run with 5-level-paging enabled. So I guess you
>>>>>> can drop the complete if (IS_ENABLED(CONFIG_X86_5LEVEL)) {} block.
>>>>>
>>>>> There is more code to drop from mmu_pv.c.
>>>>>
>>>>> But while there, I thought if with boot-time 5-level paging switching we
>>>>> can allow kernel to compile with XEN_PV and XEN_PVH, so the kernel image
>>>>> can be used in these XEN modes with 4-level paging.
>>>>>
>>>>> Could you check if with the patch below we can boot in XEN_PV and XEN_PVH
>>>>> modes?
>>>>
>>>> We can't. I have used your branch:
>>>>
>>>> git://git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git
>>>> la57/boot-switching/v2
>>>>
>>>> with this patch applied on top.
>>>>
>>>> Doesn't boot PV guest with X86_5LEVEL configured (very early crash).
>>>
>>> Hm. Okay.
>>>
>>> Have you tried PVH?
>>>
>>>> Doesn't build with X86_5LEVEL not configured:
>>>>
>>>>   AS      arch/x86/kernel/head_64.o
>>>
>>> I've fixed the patch and split the patch into two parts: cleanup and
>>> re-enabling XEN_PV and XEN_PVH for X86_5LEVEL.
>>>
>>> There's chance that I screw somthing up in clenaup part. Could you check
>>> that?
>>
>> Build is working with and without X86_5LEVEL configured.
>>
>> PV domU boots without X86_5LEVEL configured.
>>
>> PV domU crashes with X86_5LEVEL configured:
>>
>> xen_start_kernel()
>>   x86_64_start_reservations()
>>     start_kernel()
>>       setup_arch()
>>         early_ioremap_init()
>>           early_ioremap_pmd()
>>
>> In early_ioremap_pmd() there seems to be a call to p4d_val() which is an
>> uninitialized paravirt operation in the Xen pv case.
> 
> Thanks for testing.
> 
> Could you check if patch below makes a difference?

A little bit better. I get a panic message with backtrace now:

(early) [    0.000000] random: get_random_bytes called from
start_kernel+0x33/0x495 with crng_init=0
(early) [    0.000000] Linux version 4.13.0-rc2-default+ (gross@g226)
(gcc version 4.8.5 (SUSE Linux)) #135 SMP PREEMPT Tue Aug 1 17:43:57
CEST 2017
(early) [    0.000000] Command line:
root=UUID=3fa1e04c-4741-46ca-a1cd-859cf0da92d0 resume=/dev/xvda1
splash=silent showopts earlyprintk=xen,keep
(early) [    0.000000] x86/fpu: Supporting XSAVE feature 0x001: 'x87
floating point registers'
(early) [    0.000000] x86/fpu: Supporting XSAVE feature 0x002: 'SSE
registers'
(early) [    0.000000] x86/fpu: Supporting XSAVE feature 0x004: 'AVX
registers'
(early) [    0.000000] x86/fpu: xstate_offset[2]:  576, xstate_sizes[2]:
 256
(early) [    0.000000] x86/fpu: Enabled xstate features 0x7, context
size is 832 bytes, using 'standard' format.
(early) [    0.000000] ACPI in unprivileged domain disabled
(early) [    0.000000] Released 0 page(s)
(early) [    0.000000] e820: BIOS-provided physical RAM map:
(early) [    0.000000] Xen: [mem 0x0000000000000000-0x000000000009ffff]
usable
(early) [    0.000000] Xen: [mem 0x00000000000a0000-0x00000000000fffff]
reserved
(early) [    0.000000] Xen: [mem 0x0000000000100000-0x000000001fffffff]
usable
(early) [    0.000000] console [xenboot0] enabled
(early) [    0.000000] NX (Execute Disable) protection: active
(early) [    0.000000] DMI not present or invalid.
(early) [    0.000000] Hypervisor detected: Xen PV
(early) [    0.000000] tsc: Fast TSC calibration failed
(early) [    0.000000] tsc: Unable to calibrate against PIT
(early) [    0.000000] tsc: No reference (HPET/PMTIMER) available
(early) [    0.000000] e820: last_pfn = 0x20000 max_arch_pfn = 0x400000000
(early) [    0.000000] MTRR: Disabled
(early) [    0.000000] x86/PAT: MTRRs disabled, skipping PAT
initialization too.
(early) [    0.000000] x86/PAT: Configuration [0-7]: WB  WT  UC- UC  WC
WP  UC  UC
(early) [    0.000000] Scanning 1 areas for low memory corruption
(early) [    0.000000] RAMDISK: [mem 0x021dd000-0x034e4fff]
(early) [    0.000000] NUMA turned off
(early) [    0.000000] Faking a node at [mem
0x0000000000000000-0x000000001fffffff]
(early) [    0.000000] NODE_DATA(0) allocated [mem 0x1ff07000-0x1ff1cfff]
(early) [    0.000000] Section 1 and 3 (node 0) have a circular
dependency on usemap and pgdat allocations
(early) [    0.000000] Kernel panic - not syncing:
memblock_virt_alloc_try_nid: Failed to allocate 268435456 bytes
align=0x0 nid=-1 from=0x0 max_addr=0x0
[    0.000000]
               (early) [    0.000000] CPU: 0 PID: 0 Comm: swapper Not
tainted 4.13.0-rc2-default+ #135
(early) [    0.000000] Call Trace:
(early) [    0.000000]  dump_stack+0x63/0x89
(early) [    0.000000]  panic+0xdb/0x235
(early) [    0.000000]  memblock_virt_alloc_try_nid+0x95/0xa2
(early) [    0.000000]  ? sparse_early_mem_maps_alloc_node+0x10/0x10
(early) [    0.000000]  sparse_init+0x5e/0x16f
(early) [    0.000000]  paging_init+0x18/0x37
(early) [    0.000000]  xen_pagetable_init+0x1b/0x55d
(early) [    0.000000]  setup_arch+0xbdb/0xc92
(early) [    0.000000]  start_kernel+0xaf/0x495
(early) [    0.000000]  x86_64_start_reservations+0x24/0x26
(early) [    0.000000]  xen_start_kernel+0x574/0x580

This was with 5-level paging configured.


Juergen

> 
> diff --git a/arch/x86/include/asm/paravirt.h b/arch/x86/include/asm/paravirt.h
> index 8febaa318aa2..37e5ccc3890f 100644
> --- a/arch/x86/include/asm/paravirt.h
> +++ b/arch/x86/include/asm/paravirt.h
> @@ -604,12 +604,12 @@ static inline p4dval_t p4d_val(p4d_t p4d)
>  	return PVOP_CALLEE1(p4dval_t, pv_mmu_ops.p4d_val, p4d.p4d);
>  }
>  
> -static inline void set_pgd(pgd_t *pgdp, pgd_t pgd)
> -{
> -	pgdval_t val = native_pgd_val(pgd);
> -
> -	PVOP_VCALL2(pv_mmu_ops.set_pgd, pgdp, val);
> -}
> +#define set_pgd(pgdp, pgdval) do {						\
> +		if (p4d_folded)						\
> +			set_p4d((p4d_t *)(pgdp), (p4d_t) { (pgdval).pgd }); \
> +		else \
> +			PVOP_VCALL2(pv_mmu_ops.set_pgd, pgdp, native_pgd_val(pgdval)); \
> +	} while (0)
>  
>  #define pgd_clear(pgdp) do {				\
>                  if (!p4d_folded)			\
> @@ -834,6 +834,7 @@ static inline notrace unsigned long arch_local_irq_save(void)
>  }
>  
>  
> +#if 0
>  /* Make sure as little as possible of this mess escapes. */
>  #undef PARAVIRT_CALL
>  #undef __PVOP_CALL
> @@ -848,6 +849,7 @@ static inline notrace unsigned long arch_local_irq_save(void)
>  #undef PVOP_CALL3
>  #undef PVOP_VCALL4
>  #undef PVOP_CALL4
> +#endif
>  
>  extern void default_banner(void);
>  
> diff --git a/arch/x86/xen/mmu_pv.c b/arch/x86/xen/mmu_pv.c
> index 3116649302f2..ab1a4f0c65c5 100644
> --- a/arch/x86/xen/mmu_pv.c
> +++ b/arch/x86/xen/mmu_pv.c
> @@ -558,6 +558,22 @@ static void xen_set_p4d(p4d_t *ptr, p4d_t val)
>  
>  	xen_mc_issue(PARAVIRT_LAZY_MMU);
>  }
> +
> +#if CONFIG_PGTABLE_LEVELS >= 5
> +__visible p4dval_t xen_p4d_val(p4d_t p4d)
> +{
> +	return pte_mfn_to_pfn(p4d.p4d);
> +}
> +PV_CALLEE_SAVE_REGS_THUNK(xen_p4d_val);
> +
> +__visible p4d_t xen_make_p4d(p4dval_t p4d)
> +{
> +	p4d = pte_pfn_to_mfn(p4d);
> +
> +	return native_make_p4d(p4d);
> +}
> +PV_CALLEE_SAVE_REGS_THUNK(xen_make_p4d);
> +#endif  /* CONFIG_PGTABLE_LEVELS >= 5 */
>  #endif	/* CONFIG_X86_64 */
>  
>  static int xen_pmd_walk(struct mm_struct *mm, pmd_t *pmd,
> @@ -2431,6 +2447,11 @@ static const struct pv_mmu_ops xen_mmu_ops __initconst = {
>  
>  	.alloc_pud = xen_alloc_pmd_init,
>  	.release_pud = xen_release_pmd_init,
> +
> +#if CONFIG_PGTABLE_LEVELS >= 5
> +	.p4d_val = PV_CALLEE_SAVE(xen_p4d_val),
> +	.make_p4d = PV_CALLEE_SAVE(xen_make_p4d),
> +#endif
>  #endif	/* CONFIG_X86_64 */
>  
>  	.activate_mm = xen_activate_mm,
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
