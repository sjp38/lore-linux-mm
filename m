Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 8EB2C6B0005
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 08:32:45 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id u188so23275567wmu.1
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 05:32:45 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dl6si152543341wjb.82.2016.01.05.05.32.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 05 Jan 2016 05:32:44 -0800 (PST)
Subject: Re: [PATCH 22/32] x86, pkeys: dump PTE pkey in /proc/pid/smaps
References: <20151214190542.39C4886D@viggo.jf.intel.com>
 <20151214190619.BA65327A@viggo.jf.intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <568BC5FA.2080800@suse.cz>
Date: Tue, 5 Jan 2016 14:32:42 +0100
MIME-Version: 1.0
In-Reply-To: <20151214190619.BA65327A@viggo.jf.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, dave.hansen@linux.intel.com

On 12/14/2015 08:06 PM, Dave Hansen wrote:
> From: Dave Hansen <dave.hansen@linux.intel.com>

$SUBJ is a bit confusing in that it's dumping stuff from VMA, not PTE's?

It could be also useful to extend dump_vma() appropriately. Currently 
there are no string translations for the new "flags" (but one can figure 
it out from the raw value). But maybe we should print pkey separately in 
dump_vma() as you do here. I have a series in flight [1] that touches 
dump_vma() and the flags printing in general, so to avoid conflicts, 
handling pkeys there could wait. But mentioning it now for less chance 
of being forgotten...

[1] https://lkml.org/lkml/2015/12/18/178 - a previous version is in 
mmotm and this should replace it after 4.5-rc1

> The protection key can now be just as important as read/write
> permissions on a VMA.  We need some debug mechanism to help
> figure out if it is in play.  smaps seems like a logical
> place to expose it.
>
> arch/x86/kernel/setup.c is a bit of a weirdo place to put
> this code, but it already had seq_file.h and there was not
> a much better existing place to put it.
>
> We also use no #ifdef.  If protection keys is .config'd out
> we will get the same function as if we used the weak generic
> function.
>
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
> ---
>
>   b/arch/x86/kernel/setup.c |    9 +++++++++
>   b/fs/proc/task_mmu.c      |   14 ++++++++++++++
>   2 files changed, 23 insertions(+)
>
> diff -puN arch/x86/kernel/setup.c~pkeys-40-smaps arch/x86/kernel/setup.c
> --- a/arch/x86/kernel/setup.c~pkeys-40-smaps	2015-12-14 10:42:48.777070739 -0800
> +++ b/arch/x86/kernel/setup.c	2015-12-14 10:42:48.782070963 -0800
> @@ -112,6 +112,7 @@
>   #include <asm/alternative.h>
>   #include <asm/prom.h>
>   #include <asm/microcode.h>
> +#include <asm/mmu_context.h>
>
>   /*
>    * max_low_pfn_mapped: highest direct mapped pfn under 4GB
> @@ -1282,3 +1283,11 @@ static int __init register_kernel_offset
>   	return 0;
>   }
>   __initcall(register_kernel_offset_dumper);
> +
> +void arch_show_smap(struct seq_file *m, struct vm_area_struct *vma)
> +{
> +	if (!boot_cpu_has(X86_FEATURE_OSPKE))
> +		return;
> +
> +	seq_printf(m, "ProtectionKey:  %8u\n", vma_pkey(vma));
> +}
> diff -puN fs/proc/task_mmu.c~pkeys-40-smaps fs/proc/task_mmu.c
> --- a/fs/proc/task_mmu.c~pkeys-40-smaps	2015-12-14 10:42:48.779070829 -0800
> +++ b/fs/proc/task_mmu.c	2015-12-14 10:42:48.783071008 -0800
> @@ -615,11 +615,20 @@ static void show_smap_vma_flags(struct s
>   		[ilog2(VM_MERGEABLE)]	= "mg",
>   		[ilog2(VM_UFFD_MISSING)]= "um",
>   		[ilog2(VM_UFFD_WP)]	= "uw",
> +#ifdef CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS
> +		/* These come out via ProtectionKey: */
> +		[ilog2(VM_PKEY_BIT0)]	= "",
> +		[ilog2(VM_PKEY_BIT1)]	= "",
> +		[ilog2(VM_PKEY_BIT2)]	= "",
> +		[ilog2(VM_PKEY_BIT3)]	= "",
> +#endif
>   	};
>   	size_t i;
>
>   	seq_puts(m, "VmFlags: ");
>   	for (i = 0; i < BITS_PER_LONG; i++) {
> +		if (!mnemonics[i][0])
> +			continue;
>   		if (vma->vm_flags & (1UL << i)) {
>   			seq_printf(m, "%c%c ",
>   				   mnemonics[i][0], mnemonics[i][1]);
> @@ -657,6 +666,10 @@ static int smaps_hugetlb_range(pte_t *pt
>   }
>   #endif /* HUGETLB_PAGE */
>
> +void __weak arch_show_smap(struct seq_file *m, struct vm_area_struct *vma)
> +{
> +}
> +
>   static int show_smap(struct seq_file *m, void *v, int is_pid)
>   {
>   	struct vm_area_struct *vma = v;
> @@ -713,6 +726,7 @@ static int show_smap(struct seq_file *m,
>   		   (vma->vm_flags & VM_LOCKED) ?
>   			(unsigned long)(mss.pss >> (10 + PSS_SHIFT)) : 0);
>
> +	arch_show_smap(m, vma);
>   	show_smap_vma_flags(m, vma);
>   	m_cache_vma(m, vma);
>   	return 0;
> _
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
