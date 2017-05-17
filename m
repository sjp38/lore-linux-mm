Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id DF0786B0038
	for <linux-mm@kvack.org>; Wed, 17 May 2017 15:18:09 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id b84so4566714wmh.0
        for <linux-mm@kvack.org>; Wed, 17 May 2017 12:18:09 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTP id w2si3208992wrc.330.2017.05.17.12.18.07
        for <linux-mm@kvack.org>;
        Wed, 17 May 2017 12:18:08 -0700 (PDT)
Date: Wed, 17 May 2017 21:17:55 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v5 28/32] x86/mm, kexec: Allow kexec to be used with SME
Message-ID: <20170517191755.h2xluopk2p6suw32@pd.tnic>
References: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
 <20170418212121.10190.94885.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20170418212121.10190.94885.stgit@tlendack-t1.amdoffice.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Tue, Apr 18, 2017 at 04:21:21PM -0500, Tom Lendacky wrote:
> Provide support so that kexec can be used to boot a kernel when SME is
> enabled.
> 
> Support is needed to allocate pages for kexec without encryption.  This
> is needed in order to be able to reboot in the kernel in the same manner
> as originally booted.
> 
> Additionally, when shutting down all of the CPUs we need to be sure to
> flush the caches and then halt. This is needed when booting from a state
> where SME was not active into a state where SME is active (or vice-versa).
> Without these steps, it is possible for cache lines to exist for the same
> physical location but tagged both with and without the encryption bit. This
> can cause random memory corruption when caches are flushed depending on
> which cacheline is written last.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---
>  arch/x86/include/asm/init.h          |    1 +
>  arch/x86/include/asm/irqflags.h      |    5 +++++
>  arch/x86/include/asm/kexec.h         |    8 ++++++++
>  arch/x86/include/asm/pgtable_types.h |    1 +
>  arch/x86/kernel/machine_kexec_64.c   |   35 +++++++++++++++++++++++++++++++++-
>  arch/x86/kernel/process.c            |   26 +++++++++++++++++++++++--
>  arch/x86/mm/ident_map.c              |   11 +++++++----
>  include/linux/kexec.h                |   14 ++++++++++++++
>  kernel/kexec_core.c                  |    7 +++++++
>  9 files changed, 101 insertions(+), 7 deletions(-)

...

> @@ -86,7 +86,7 @@ static int init_transition_pgtable(struct kimage *image, pgd_t *pgd)
>  		set_pmd(pmd, __pmd(__pa(pte) | _KERNPG_TABLE));
>  	}
>  	pte = pte_offset_kernel(pmd, vaddr);
> -	set_pte(pte, pfn_pte(paddr >> PAGE_SHIFT, PAGE_KERNEL_EXEC));
> +	set_pte(pte, pfn_pte(paddr >> PAGE_SHIFT, PAGE_KERNEL_EXEC_NOENC));
>  	return 0;
>  err:
>  	free_transition_pgtable(image);
> @@ -114,6 +114,7 @@ static int init_pgtable(struct kimage *image, unsigned long start_pgtable)
>  		.alloc_pgt_page	= alloc_pgt_page,
>  		.context	= image,
>  		.pmd_flag	= __PAGE_KERNEL_LARGE_EXEC,
> +		.kernpg_flag	= _KERNPG_TABLE_NOENC,
>  	};
>  	unsigned long mstart, mend;
>  	pgd_t *level4p;
> @@ -597,3 +598,35 @@ void arch_kexec_unprotect_crashkres(void)
>  {
>  	kexec_mark_crashkres(false);
>  }
> +
> +int arch_kexec_post_alloc_pages(void *vaddr, unsigned int pages, gfp_t gfp)
> +{
> +	int ret;
> +
> +	if (sme_active()) {

	if (!sme_active())
		return 0;

	/*
	 * If SME...


> +		/*
> +		 * If SME is active we need to be sure that kexec pages are
> +		 * not encrypted because when we boot to the new kernel the
> +		 * pages won't be accessed encrypted (initially).
> +		 */
> +		ret = set_memory_decrypted((unsigned long)vaddr, pages);
> +		if (ret)
> +			return ret;
> +
> +		if (gfp & __GFP_ZERO)
> +			memset(vaddr, 0, pages * PAGE_SIZE);

This function is called after alloc_pages() which already zeroes memory
when __GFP_ZERO is supplied.

If you need to clear the memory *after* set_memory_encrypted() happens,
then you should probably mask out __GFP_ZERO before the alloc_pages()
call so as not to do it twice.

> +	}
> +
> +	return 0;
> +}
> +
> +void arch_kexec_pre_free_pages(void *vaddr, unsigned int pages)
> +{
> +	if (sme_active()) {
> +		/*
> +		 * If SME is active we need to reset the pages back to being
> +		 * an encrypted mapping before freeing them.
> +		 */
> +		set_memory_encrypted((unsigned long)vaddr, pages);
> +	}
> +}
> diff --git a/arch/x86/kernel/process.c b/arch/x86/kernel/process.c
> index 0bb8842..f4e5de6 100644
> --- a/arch/x86/kernel/process.c
> +++ b/arch/x86/kernel/process.c
> @@ -24,6 +24,7 @@
>  #include <linux/cpuidle.h>
>  #include <trace/events/power.h>
>  #include <linux/hw_breakpoint.h>
> +#include <linux/kexec.h>
>  #include <asm/cpu.h>
>  #include <asm/apic.h>
>  #include <asm/syscalls.h>
> @@ -355,8 +356,25 @@ bool xen_set_default_idle(void)
>  	return ret;
>  }
>  #endif
> +
>  void stop_this_cpu(void *dummy)
>  {
> +	bool do_wbinvd_halt = false;
> +
> +	if (kexec_in_progress && boot_cpu_has(X86_FEATURE_SME)) {
> +		/*
> +		 * If we are performing a kexec and the processor supports
> +		 * SME then we need to clear out cache information before
> +		 * halting. With kexec, going from SME inactive to SME active
> +		 * requires clearing cache entries so that addresses without
> +		 * the encryption bit set don't corrupt the same physical
> +		 * address that has the encryption bit set when caches are
> +		 * flushed. Perform a wbinvd followed by a halt to achieve
> +		 * this.
> +		 */
> +		do_wbinvd_halt = true;
> +	}
> +
>  	local_irq_disable();
>  	/*
>  	 * Remove this CPU:
> @@ -365,8 +383,12 @@ void stop_this_cpu(void *dummy)
>  	disable_local_APIC();
>  	mcheck_cpu_clear(this_cpu_ptr(&cpu_info));
>  
> -	for (;;)
> -		halt();
> +	for (;;) {
> +		if (do_wbinvd_halt)
> +			native_wbinvd_halt();

No need for that native_wbinvd_halt() thing:

	for (;;) {
		if (do_wbinvd)
			wbinvd();

		halt();
	}

>  /*
> diff --git a/arch/x86/mm/ident_map.c b/arch/x86/mm/ident_map.c
> index 04210a2..2c9fd3e 100644
> --- a/arch/x86/mm/ident_map.c
> +++ b/arch/x86/mm/ident_map.c
> @@ -20,6 +20,7 @@ static void ident_pmd_init(struct x86_mapping_info *info, pmd_t *pmd_page,
>  static int ident_pud_init(struct x86_mapping_info *info, pud_t *pud_page,
>  			  unsigned long addr, unsigned long end)
>  {
> +	unsigned long kernpg_flag = info->kernpg_flag ? : _KERNPG_TABLE;

You're already supplying a x86_mapping_info and thus you can init
kernpg_flag to default _KERNPG_TABLE and override it in the SME+kexec
case, as you already do. And this way you can simply do:

	set_pud(pud, __pud(__pa(pmd) | info->kernpg_flag));

here and in the other pagetable functions I've snipped below, and save
yourself some lines.

...

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
