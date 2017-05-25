Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 63C2B6B0292
	for <linux-mm@kvack.org>; Thu, 25 May 2017 18:24:42 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id h4so254884440oib.5
        for <linux-mm@kvack.org>; Thu, 25 May 2017 15:24:42 -0700 (PDT)
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (mail-cys01nam02on0049.outbound.protection.outlook.com. [104.47.37.49])
        by mx.google.com with ESMTPS id 65si4468044ott.203.2017.05.25.15.24.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 25 May 2017 15:24:40 -0700 (PDT)
Subject: Re: [PATCH v5 29/32] x86/mm: Add support to encrypt the kernel
 in-place
References: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
 <20170418212149.10190.70894.stgit@tlendack-t1.amdoffice.net>
 <20170518124626.hqyqqbjpy7hmlpqc@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <7e2ae014-525c-76f2-9fce-2124596db2d2@amd.com>
Date: Thu, 25 May 2017 17:24:27 -0500
MIME-Version: 1.0
In-Reply-To: <20170518124626.hqyqqbjpy7hmlpqc@pd.tnic>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S.
 Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 5/18/2017 7:46 AM, Borislav Petkov wrote:
> On Tue, Apr 18, 2017 at 04:21:49PM -0500, Tom Lendacky wrote:
>> Add the support to encrypt the kernel in-place. This is done by creating
>> new page mappings for the kernel - a decrypted write-protected mapping
>> and an encrypted mapping. The kernel is encrypted by copying it through
>> a temporary buffer.
>>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>> ---
>>  arch/x86/include/asm/mem_encrypt.h |    6 +
>>  arch/x86/mm/Makefile               |    2
>>  arch/x86/mm/mem_encrypt.c          |  262 ++++++++++++++++++++++++++++++++++++
>>  arch/x86/mm/mem_encrypt_boot.S     |  151 +++++++++++++++++++++
>>  4 files changed, 421 insertions(+)
>>  create mode 100644 arch/x86/mm/mem_encrypt_boot.S
>>
>> diff --git a/arch/x86/include/asm/mem_encrypt.h b/arch/x86/include/asm/mem_encrypt.h
>> index b406df2..8f6f9b4 100644
>> --- a/arch/x86/include/asm/mem_encrypt.h
>> +++ b/arch/x86/include/asm/mem_encrypt.h
>> @@ -31,6 +31,12 @@ static inline u64 sme_dma_mask(void)
>>  	return ((u64)sme_me_mask << 1) - 1;
>>  }
>>
>> +void sme_encrypt_execute(unsigned long encrypted_kernel_vaddr,
>> +			 unsigned long decrypted_kernel_vaddr,
>> +			 unsigned long kernel_len,
>> +			 unsigned long encryption_wa,
>> +			 unsigned long encryption_pgd);
>> +
>>  void __init sme_early_encrypt(resource_size_t paddr,
>>  			      unsigned long size);
>>  void __init sme_early_decrypt(resource_size_t paddr,
>> diff --git a/arch/x86/mm/Makefile b/arch/x86/mm/Makefile
>> index 9e13841..0633142 100644
>> --- a/arch/x86/mm/Makefile
>> +++ b/arch/x86/mm/Makefile
>> @@ -38,3 +38,5 @@ obj-$(CONFIG_NUMA_EMU)		+= numa_emulation.o
>>  obj-$(CONFIG_X86_INTEL_MPX)	+= mpx.o
>>  obj-$(CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS) += pkeys.o
>>  obj-$(CONFIG_RANDOMIZE_MEMORY) += kaslr.o
>> +
>> +obj-$(CONFIG_AMD_MEM_ENCRYPT)	+= mem_encrypt_boot.o
>> diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
>> index 30b07a3..0ff41a4 100644
>> --- a/arch/x86/mm/mem_encrypt.c
>> +++ b/arch/x86/mm/mem_encrypt.c
>> @@ -24,6 +24,7 @@
>>  #include <asm/setup.h>
>>  #include <asm/bootparam.h>
>>  #include <asm/cacheflush.h>
>> +#include <asm/sections.h>
>>
>>  /*
>>   * Since SME related variables are set early in the boot process they must
>> @@ -216,8 +217,269 @@ void swiotlb_set_mem_attributes(void *vaddr, unsigned long size)
>>  	set_memory_decrypted((unsigned long)vaddr, size >> PAGE_SHIFT);
>>  }
>>
>> +void __init sme_clear_pgd(pgd_t *pgd_base, unsigned long start,
>
> static

Yup.

>
>> +			  unsigned long end)
>> +{
>> +	unsigned long addr = start;
>> +	pgdval_t *pgd_p;
>> +
>> +	while (addr < end) {
>> +		unsigned long pgd_end;
>> +
>> +		pgd_end = (addr & PGDIR_MASK) + PGDIR_SIZE;
>> +		if (pgd_end > end)
>> +			pgd_end = end;
>> +
>> +		pgd_p = (pgdval_t *)pgd_base + pgd_index(addr);
>> +		*pgd_p = 0;
>
> Hmm, so this is a contiguous range from [start:end] which translates to
> 8-byte PGD pointers in the PGD page so you can simply memset that range,
> no?
>
> Instead of iterating over each one?

I guess I could do that, but this will probably only end up clearing a
single PGD entry anyway since it's highly doubtful the address range
would cross a 512GB boundary.

>
>> +
>> +		addr = pgd_end;
>> +	}
>> +}
>> +
>> +#define PGD_FLAGS	_KERNPG_TABLE_NOENC
>> +#define PUD_FLAGS	_KERNPG_TABLE_NOENC
>> +#define PMD_FLAGS	(__PAGE_KERNEL_LARGE_EXEC & ~_PAGE_GLOBAL)
>> +
>> +static void __init *sme_populate_pgd(pgd_t *pgd_base, void *pgtable_area,
>> +				     unsigned long vaddr, pmdval_t pmd_val)
>> +{
>> +	pgdval_t pgd, *pgd_p;
>> +	pudval_t pud, *pud_p;
>> +	pmdval_t pmd, *pmd_p;
>
> You should use the enclosing type, not the underlying one. I.e.,
>
> 	pgd_t *pgd;
> 	pud_t *pud;
> 	...
>
> and then the macros native_p*d_val(), p*d_offset() and so on. I say
> native_* because we don't want to have any paravirt nastyness here.
> I believe your previous version was using the proper interfaces.

I won't be able to use the p*d_offset() macros since they use __va()
and we're identity mapped during this time (which is why I would guess
the proposed changes for the 5-level pagetables in
arch/x86/kernel/head64.c, __startup_64, don't use these macros
either). I should be able to use the native_set_p*d() and others though,
I'll look into that.

>
> And the kernel has gotten 5-level pagetables support in
> the meantime, so this'll need to start at p4d AFAICT.
> arch/x86/mm/fault.c::dump_pagetable() looks like a good example to stare
> at.

Yeah, I accounted for that in the other parts of the code but I need
to do that here also.

>
>> +	pgd_p = (pgdval_t *)pgd_base + pgd_index(vaddr);
>> +	pgd = *pgd_p;
>> +	if (pgd) {
>> +		pud_p = (pudval_t *)(pgd & ~PTE_FLAGS_MASK);
>> +	} else {
>> +		pud_p = pgtable_area;
>> +		memset(pud_p, 0, sizeof(*pud_p) * PTRS_PER_PUD);
>> +		pgtable_area += sizeof(*pud_p) * PTRS_PER_PUD;
>> +
>> +		*pgd_p = (pgdval_t)pud_p + PGD_FLAGS;
>> +	}
>> +
>> +	pud_p += pud_index(vaddr);
>> +	pud = *pud_p;
>> +	if (pud) {
>> +		if (pud & _PAGE_PSE)
>> +			goto out;
>> +
>> +		pmd_p = (pmdval_t *)(pud & ~PTE_FLAGS_MASK);
>> +	} else {
>> +		pmd_p = pgtable_area;
>> +		memset(pmd_p, 0, sizeof(*pmd_p) * PTRS_PER_PMD);
>> +		pgtable_area += sizeof(*pmd_p) * PTRS_PER_PMD;
>> +
>> +		*pud_p = (pudval_t)pmd_p + PUD_FLAGS;
>> +	}
>> +
>> +	pmd_p += pmd_index(vaddr);
>> +	pmd = *pmd_p;
>> +	if (!pmd || !(pmd & _PAGE_PSE))
>> +		*pmd_p = pmd_val;
>> +
>> +out:
>> +	return pgtable_area;
>> +}
>> +
>> +static unsigned long __init sme_pgtable_calc(unsigned long len)
>> +{
>> +	unsigned long pud_tables, pmd_tables;
>> +	unsigned long total = 0;
>> +
>> +	/*
>> +	 * Perform a relatively simplistic calculation of the pagetable
>> +	 * entries that are needed. That mappings will be covered by 2MB
>> +	 * PMD entries so we can conservatively calculate the required
>> +	 * number of PUD and PMD structures needed to perform the mappings.
>> +	 * Incrementing the count for each covers the case where the
>> +	 * addresses cross entries.
>> +	 */
>> +	pud_tables = ALIGN(len, PGDIR_SIZE) / PGDIR_SIZE;
>> +	pud_tables++;
>> +	pmd_tables = ALIGN(len, PUD_SIZE) / PUD_SIZE;
>> +	pmd_tables++;
>> +
>> +	total += pud_tables * sizeof(pud_t) * PTRS_PER_PUD;
>> +	total += pmd_tables * sizeof(pmd_t) * PTRS_PER_PMD;
>> +
>> +	/*
>> +	 * Now calculate the added pagetable structures needed to populate
>> +	 * the new pagetables.
>> +	 */
>
> Nice commenting, helps following what's going on.
>
>> +	pud_tables = ALIGN(total, PGDIR_SIZE) / PGDIR_SIZE;
>> +	pmd_tables = ALIGN(total, PUD_SIZE) / PUD_SIZE;
>> +
>> +	total += pud_tables * sizeof(pud_t) * PTRS_PER_PUD;
>> +	total += pmd_tables * sizeof(pmd_t) * PTRS_PER_PMD;
>> +
>> +	return total;
>> +}
>> +
>>  void __init sme_encrypt_kernel(void)
>>  {
>> +	pgd_t *pgd;
>> +	void *pgtable_area;
>> +	unsigned long kernel_start, kernel_end, kernel_len;
>> +	unsigned long workarea_start, workarea_end, workarea_len;
>> +	unsigned long execute_start, execute_end, execute_len;
>> +	unsigned long pgtable_area_len;
>> +	unsigned long decrypted_base;
>> +	unsigned long paddr, pmd_flags;
>
>
> Please sort function local variables declaration in a reverse christmas
> tree order:
>
> 	<type> longest_variable_name;
> 	<type> shorter_var_name;
> 	<type> even_shorter;
> 	<type> i;
>

Will do.

>> +
>> +	if (!sme_active())
>> +		return;
>
> ...
>
>> diff --git a/arch/x86/mm/mem_encrypt_boot.S b/arch/x86/mm/mem_encrypt_boot.S
>> new file mode 100644
>> index 0000000..fb58f9f
>> --- /dev/null
>> +++ b/arch/x86/mm/mem_encrypt_boot.S
>> @@ -0,0 +1,151 @@
>> +/*
>> + * AMD Memory Encryption Support
>> + *
>> + * Copyright (C) 2016 Advanced Micro Devices, Inc.
>> + *
>> + * Author: Tom Lendacky <thomas.lendacky@amd.com>
>> + *
>> + * This program is free software; you can redistribute it and/or modify
>> + * it under the terms of the GNU General Public License version 2 as
>> + * published by the Free Software Foundation.
>> + */
>> +
>> +#include <linux/linkage.h>
>> +#include <asm/pgtable.h>
>> +#include <asm/page.h>
>> +#include <asm/processor-flags.h>
>> +#include <asm/msr-index.h>
>> +
>> +	.text
>> +	.code64
>> +ENTRY(sme_encrypt_execute)
>> +
>> +	/*
>> +	 * Entry parameters:
>> +	 *   RDI - virtual address for the encrypted kernel mapping
>> +	 *   RSI - virtual address for the decrypted kernel mapping
>> +	 *   RDX - length of kernel
>> +	 *   RCX - virtual address of the encryption workarea, including:
>> +	 *     - stack page (PAGE_SIZE)
>> +	 *     - encryption routine page (PAGE_SIZE)
>> +	 *     - intermediate copy buffer (PMD_PAGE_SIZE)
>> +	 *    R8 - physcial address of the pagetables to use for encryption
>> +	 */
>> +
>> +	push	%rbp
>> +	push	%r12
>> +
>> +	/* Set up a one page stack in the non-encrypted memory area */
>> +	movq	%rsp, %rbp		/* Save current stack pointer */
>> +	movq	%rcx, %rax		/* Workarea stack page */
>> +	movq	%rax, %rsp		/* Set new stack pointer */
>> +	addq	$PAGE_SIZE, %rsp	/* Stack grows from the bottom */
>> +	addq	$PAGE_SIZE, %rax	/* Workarea encryption routine */
>> +
>> +	movq	%rdi, %r10		/* Encrypted kernel */
>> +	movq	%rsi, %r11		/* Decrypted kernel */
>> +	movq	%rdx, %r12		/* Kernel length */
>> +
>> +	/* Copy encryption routine into the workarea */
>> +	movq	%rax, %rdi		/* Workarea encryption routine */
>> +	leaq	.Lenc_start(%rip), %rsi	/* Encryption routine */
>> +	movq	$(.Lenc_stop - .Lenc_start), %rcx	/* Encryption routine length */
>> +	rep	movsb
>> +
>> +	/* Setup registers for call */
>> +	movq	%r10, %rdi		/* Encrypted kernel */
>> +	movq	%r11, %rsi		/* Decrypted kernel */
>> +	movq	%r8, %rdx		/* Pagetables used for encryption */
>> +	movq	%r12, %rcx		/* Kernel length */
>> +	movq	%rax, %r8		/* Workarea encryption routine */
>> +	addq	$PAGE_SIZE, %r8		/* Workarea intermediate copy buffer */
>> +
>> +	call	*%rax			/* Call the encryption routine */
>> +
>> +	movq	%rbp, %rsp		/* Restore original stack pointer */
>> +
>> +	pop	%r12
>> +	pop	%rbp
>> +
>> +	ret
>> +ENDPROC(sme_encrypt_execute)
>> +
>> +.Lenc_start:
>> +ENTRY(sme_enc_routine)
>
> A function called a "routine"? Why do we need the global symbol?
> Nothing's referencing it AFAICT.

I can change the name. As for the use of ENTRY... without the
ENTRY/ENDPROC combination I was receiving a warning about a return
instruction outside of a callable function. It looks like I can just
define the "sme_enc_routine:" label with the ENDPROC and the warning
goes away and the global is avoided. It doesn't like the local labels
(.L...) so I'll use the new name.

>
>> +/*
>> + * Routine used to encrypt kernel.
>> + *   This routine must be run outside of the kernel proper since
>> + *   the kernel will be encrypted during the process. So this
>> + *   routine is defined here and then copied to an area outside
>> + *   of the kernel where it will remain and run decrypted
>> + *   during execution.
>> + *
>> + *   On entry the registers must be:
>> + *     RDI - virtual address for the encrypted kernel mapping
>> + *     RSI - virtual address for the decrypted kernel mapping
>> + *     RDX - address of the pagetables to use for encryption
>> + *     RCX - length of kernel
>> + *      R8 - intermediate copy buffer
>> + *
>> + *     RAX - points to this routine
>> + *
>> + * The kernel will be encrypted by copying from the non-encrypted
>> + * kernel space to an intermediate buffer and then copying from the
>> + * intermediate buffer back to the encrypted kernel space. The physical
>> + * addresses of the two kernel space mappings are the same which
>> + * results in the kernel being encrypted "in place".
>> + */
>> +	/* Enable the new page tables */
>> +	mov	%rdx, %cr3
>> +
>> +	/* Flush any global TLBs */
>> +	mov	%cr4, %rdx
>> +	andq	$~X86_CR4_PGE, %rdx
>> +	mov	%rdx, %cr4
>> +	orq	$X86_CR4_PGE, %rdx
>> +	mov	%rdx, %cr4
>> +
>> +	/* Set the PAT register PA5 entry to write-protect */
>> +	push	%rcx
>> +	movl	$MSR_IA32_CR_PAT, %ecx
>> +	rdmsr
>> +	push	%rdx			/* Save original PAT value */
>> +	andl	$0xffff00ff, %edx	/* Clear PA5 */
>> +	orl	$0x00000500, %edx	/* Set PA5 to WP */
>
> Maybe check first whether PA5 is already set correctly and avoid the
> WRMSR and the restoring below too?

In the overall scheme of things it's probably not that big a deal when
compared to everything that's about to happen below.

>
>> +	wrmsr
>> +	pop	%rdx			/* RDX contains original PAT value */
>> +	pop	%rcx
>> +
>> +	movq	%rcx, %r9		/* Save kernel length */
>> +	movq	%rdi, %r10		/* Save encrypted kernel address */
>> +	movq	%rsi, %r11		/* Save decrypted kernel address */
>> +
>> +	wbinvd				/* Invalidate any cache entries */
>> +
>> +	/* Copy/encrypt 2MB at a time */
>> +1:
>> +	movq	%r11, %rsi		/* Source - decrypted kernel */
>> +	movq	%r8, %rdi		/* Dest   - intermediate copy buffer */
>> +	movq	$PMD_PAGE_SIZE, %rcx	/* 2MB length */
>> +	rep	movsb
>
> not movsQ?

The hardware will try to optimize rep movsb into large chunks assuming
things are aligned, sizes are large enough, etc. so we don't have to
explicitly specify and setup for a rep movsq.

Thanks,
Tom

>
>> +	movq	%r8, %rsi		/* Source - intermediate copy buffer */
>> +	movq	%r10, %rdi		/* Dest   - encrypted kernel */
>> +	movq	$PMD_PAGE_SIZE, %rcx	/* 2MB length */
>> +	rep	movsb
>> +
>> +	addq	$PMD_PAGE_SIZE, %r11
>> +	addq	$PMD_PAGE_SIZE, %r10
>> +	subq	$PMD_PAGE_SIZE, %r9	/* Kernel length decrement */
>> +	jnz	1b			/* Kernel length not zero? */
>> +
>> +	/* Restore PAT register */
>> +	push	%rdx			/* Save original PAT value */
>> +	movl	$MSR_IA32_CR_PAT, %ecx
>> +	rdmsr
>> +	pop	%rdx			/* Restore original PAT value */
>> +	wrmsr
>> +
>> +	ret
>> +ENDPROC(sme_enc_routine)
>> +.Lenc_stop:
>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
