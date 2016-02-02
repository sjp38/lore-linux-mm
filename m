Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f169.google.com (mail-lb0-f169.google.com [209.85.217.169])
	by kanga.kvack.org (Postfix) with ESMTP id 6EB756B0254
	for <linux-mm@kvack.org>; Tue,  2 Feb 2016 11:12:01 -0500 (EST)
Received: by mail-lb0-f169.google.com with SMTP id x4so98688565lbm.0
        for <linux-mm@kvack.org>; Tue, 02 Feb 2016 08:12:01 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d141si1238910lfe.123.2016.02.02.08.11.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 02 Feb 2016 08:12:00 -0800 (PST)
Subject: Re: [PATCH 22/31] x86, pkeys: dump pkey from VMA in /proc/pid/smaps
References: <20160129181642.98E7D468@viggo.jf.intel.com>
 <20160129181713.3F22714C@viggo.jf.intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56B0D54C.3010901@suse.cz>
Date: Tue, 2 Feb 2016 17:11:56 +0100
MIME-Version: 1.0
In-Reply-To: <20160129181713.3F22714C@viggo.jf.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, torvalds@linux-foundation.org, dave.hansen@linux.intel.com

On 01/29/2016 07:17 PM, Dave Hansen wrote:
> From: Dave Hansen <dave.hansen@linux.intel.com>
>
> The protection key can now be just as important as read/write
> permissions on a VMA.  We need some debug mechanism to help
> figure out if it is in play.  smaps seems like a logical
> place to expose it.
>
> arch/x86/kernel/setup.c is a bit of a weirdo place to put
> this code, but it already had seq_file.h and there was not
> a much better existing place to put it.
>
> We also use no #ifdef.  If protection keys is .config'd out we
> will effectively get the same function as if we used the weak
> generic function.
>
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
> Cc: vbabka@suse.cz
> ---
>
>   b/arch/x86/kernel/setup.c |    9 +++++++++
>   b/fs/proc/task_mmu.c      |   14 ++++++++++++++
>   2 files changed, 23 insertions(+)
>
> diff -puN arch/x86/kernel/setup.c~pkeys-40-smaps arch/x86/kernel/setup.c
> --- a/arch/x86/kernel/setup.c~pkeys-40-smaps	2016-01-28 15:52:26.386680200 -0800
> +++ b/arch/x86/kernel/setup.c	2016-01-28 15:52:26.391680429 -0800
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
> --- a/fs/proc/task_mmu.c~pkeys-40-smaps	2016-01-28 15:52:26.387680246 -0800
> +++ b/fs/proc/task_mmu.c	2016-01-28 15:52:26.391680429 -0800
> @@ -668,11 +668,20 @@ static void show_smap_vma_flags(struct s
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
> @@ -710,6 +719,10 @@ static int smaps_hugetlb_range(pte_t *pt
>   }
>   #endif /* HUGETLB_PAGE */
>
> +void __weak arch_show_smap(struct seq_file *m, struct vm_area_struct *vma)
> +{
> +}

Is it valid that this serves also as a declaration? Or should it be also 
in some header?

> +
>   static int show_smap(struct seq_file *m, void *v, int is_pid)
>   {
>   	struct vm_area_struct *vma = v;
> @@ -791,6 +804,7 @@ static int show_smap(struct seq_file *m,
>   		   (vma->vm_flags & VM_LOCKED) ?
>   			(unsigned long)(mss.pss >> (10 + PSS_SHIFT)) : 0);
>
> +	arch_show_smap(m, vma);
>   	show_smap_vma_flags(m, vma);
>   	m_cache_vma(m, vma);
>   	return 0;
> _
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
