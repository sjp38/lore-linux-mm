Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 586B16B03CE
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 06:00:34 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id z1so11315452wrz.10
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 03:00:34 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTP id r132si3082079wme.119.2017.06.23.03.00.32
        for <linux-mm@kvack.org>;
        Fri, 23 Jun 2017 03:00:32 -0700 (PDT)
Date: Fri, 23 Jun 2017 12:00:13 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v7 34/36] x86/mm: Add support to encrypt the kernel
 in-place
Message-ID: <20170623100013.upd4or6esjvulmvg@pd.tnic>
References: <20170616184947.18967.84890.stgit@tlendack-t1.amdoffice.net>
 <20170616185619.18967.38945.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20170616185619.18967.38945.stgit@tlendack-t1.amdoffice.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, xen-devel@lists.xen.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Brijesh Singh <brijesh.singh@amd.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Matt Fleming <matt@codeblueprint.co.uk>, Alexander Potapenko <glider@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Larry Woodman <lwoodman@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, "Michael S. Tsirkin" <mst@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dave Young <dyoung@redhat.com>, Rik van Riel <riel@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dmitry Vyukov <dvyukov@google.com>, Juergen Gross <jgross@suse.com>, Thomas Gleixner <tglx@linutronix.de>, Paolo Bonzini <pbonzini@redhat.com>

On Fri, Jun 16, 2017 at 01:56:19PM -0500, Tom Lendacky wrote:
> Add the support to encrypt the kernel in-place. This is done by creating
> new page mappings for the kernel - a decrypted write-protected mapping
> and an encrypted mapping. The kernel is encrypted by copying it through
> a temporary buffer.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---
>  arch/x86/include/asm/mem_encrypt.h |    6 +
>  arch/x86/mm/Makefile               |    2 
>  arch/x86/mm/mem_encrypt.c          |  314 ++++++++++++++++++++++++++++++++++++
>  arch/x86/mm/mem_encrypt_boot.S     |  150 +++++++++++++++++
>  4 files changed, 472 insertions(+)
>  create mode 100644 arch/x86/mm/mem_encrypt_boot.S
> 
> diff --git a/arch/x86/include/asm/mem_encrypt.h b/arch/x86/include/asm/mem_encrypt.h
> index af835cf..7da6de3 100644
> --- a/arch/x86/include/asm/mem_encrypt.h
> +++ b/arch/x86/include/asm/mem_encrypt.h
> @@ -21,6 +21,12 @@
>  
>  extern unsigned long sme_me_mask;
>  
> +void sme_encrypt_execute(unsigned long encrypted_kernel_vaddr,
> +			 unsigned long decrypted_kernel_vaddr,
> +			 unsigned long kernel_len,
> +			 unsigned long encryption_wa,
> +			 unsigned long encryption_pgd);
> +
>  void __init sme_early_encrypt(resource_size_t paddr,
>  			      unsigned long size);
>  void __init sme_early_decrypt(resource_size_t paddr,
> diff --git a/arch/x86/mm/Makefile b/arch/x86/mm/Makefile
> index 9e13841..0633142 100644
> --- a/arch/x86/mm/Makefile
> +++ b/arch/x86/mm/Makefile
> @@ -38,3 +38,5 @@ obj-$(CONFIG_NUMA_EMU)		+= numa_emulation.o
>  obj-$(CONFIG_X86_INTEL_MPX)	+= mpx.o
>  obj-$(CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS) += pkeys.o
>  obj-$(CONFIG_RANDOMIZE_MEMORY) += kaslr.o
> +
> +obj-$(CONFIG_AMD_MEM_ENCRYPT)	+= mem_encrypt_boot.o
> diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
> index 842c8a6..6e87662 100644
> --- a/arch/x86/mm/mem_encrypt.c
> +++ b/arch/x86/mm/mem_encrypt.c
> @@ -24,6 +24,8 @@
>  #include <asm/setup.h>
>  #include <asm/bootparam.h>
>  #include <asm/set_memory.h>
> +#include <asm/cacheflush.h>
> +#include <asm/sections.h>
>  
>  /*
>   * Since SME related variables are set early in the boot process they must
> @@ -209,8 +211,320 @@ void swiotlb_set_mem_attributes(void *vaddr, unsigned long size)
>  	set_memory_decrypted((unsigned long)vaddr, size >> PAGE_SHIFT);
>  }
>  
> +static void __init sme_clear_pgd(pgd_t *pgd_base, unsigned long start,
> +				 unsigned long end)
> +{
> +	unsigned long pgd_start, pgd_end, pgd_size;
> +	pgd_t *pgd_p;
> +
> +	pgd_start = start & PGDIR_MASK;
> +	pgd_end = end & PGDIR_MASK;
> +
> +	pgd_size = (((pgd_end - pgd_start) / PGDIR_SIZE) + 1);
> +	pgd_size *= sizeof(pgd_t);
> +
> +	pgd_p = pgd_base + pgd_index(start);
> +
> +	memset(pgd_p, 0, pgd_size);
> +}
> +
> +#ifndef CONFIG_X86_5LEVEL
> +#define native_make_p4d(_x)	(p4d_t) { .pgd = native_make_pgd(_x) }
> +#endif

Huh, why isn't this in arch/x86/include/asm/pgtable_types.h in the #else
branch of #if CONFIG_PGTABLE_LEVELS > 4 ?

Also

ERROR: Macros with complex values should be enclosed in parentheses
#105: FILE: arch/x86/mm/mem_encrypt.c:232:
+#define native_make_p4d(_x)    (p4d_t) { .pgd = native_make_pgd(_x) }

so why isn't it a function?

> +
> +#define PGD_FLAGS	_KERNPG_TABLE_NOENC
> +#define P4D_FLAGS	_KERNPG_TABLE_NOENC
> +#define PUD_FLAGS	_KERNPG_TABLE_NOENC
> +#define PMD_FLAGS	(__PAGE_KERNEL_LARGE_EXEC & ~_PAGE_GLOBAL)
> +
> +static void __init *sme_populate_pgd(pgd_t *pgd_base, void *pgtable_area,
> +				     unsigned long vaddr, pmdval_t pmd_val)
> +{
> +	pgd_t *pgd_p;
> +	p4d_t *p4d_p;
> +	pud_t *pud_p;
> +	pmd_t *pmd_p;
> +
> +	pgd_p = pgd_base + pgd_index(vaddr);
> +	if (native_pgd_val(*pgd_p)) {
> +		if (IS_ENABLED(CONFIG_X86_5LEVEL))

Err, I don't understand: so this is a Kconfig symbol and when it is
enabled at build time, you do a 5level pagetable.

But you can't stick a 5level pagetable to a hardware which doesn't know
about it.

Or do you mean that p4d layer folding at runtime to happen? (I admit, I
haven't looked at that in detail.) But then I'd hope that the generic
macros/functions would give you the ability to not care whether we have
a p4d or not and not add a whole bunch of ifdeffery to this code.

Hmmm.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
