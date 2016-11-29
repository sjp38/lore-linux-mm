Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id E26ED6B0038
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 13:40:26 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id v84so320293539oie.0
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 10:40:26 -0800 (PST)
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (mail-sn1nam01on0072.outbound.protection.outlook.com. [104.47.32.72])
        by mx.google.com with ESMTPS id k194si29520409oih.8.2016.11.29.10.40.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 29 Nov 2016 10:40:26 -0800 (PST)
Subject: Re: [RFC PATCH v3 19/20] x86: Add support to make use of Secure
 Memory Encryption
References: <20161110003426.3280.2999.stgit@tlendack-t1.amdoffice.net>
 <20161110003826.3280.5546.stgit@tlendack-t1.amdoffice.net>
 <20161124125038.j4wmtzgv2ju3v2ym@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <78d7ed9a-e709-86e3-dcde-1f67cfa7684c@amd.com>
Date: Tue, 29 Nov 2016 12:40:06 -0600
MIME-Version: 1.0
In-Reply-To: <20161124125038.j4wmtzgv2ju3v2ym@pd.tnic>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 11/24/2016 6:50 AM, Borislav Petkov wrote:
> On Wed, Nov 09, 2016 at 06:38:26PM -0600, Tom Lendacky wrote:
>> This patch adds the support to check if SME has been enabled and if the
>> mem_encrypt=on command line option is set. If both of these conditions
>> are true, then the encryption mask is set and the kernel is encrypted
>> "in place."
>>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>> ---
>>  arch/x86/kernel/Makefile           |    1 
>>  arch/x86/kernel/mem_encrypt_boot.S |  156 +++++++++++++++++++++++++++++
>>  arch/x86/kernel/mem_encrypt_init.c |  196 ++++++++++++++++++++++++++++++++++++
>>  3 files changed, 353 insertions(+)
>>  create mode 100644 arch/x86/kernel/mem_encrypt_boot.S
>>
>> diff --git a/arch/x86/kernel/Makefile b/arch/x86/kernel/Makefile
>> index 27e22f4..020759f 100644
>> --- a/arch/x86/kernel/Makefile
>> +++ b/arch/x86/kernel/Makefile
>> @@ -143,4 +143,5 @@ ifeq ($(CONFIG_X86_64),y)
>>  	obj-y				+= vsmp_64.o
>>  
>>  	obj-y				+= mem_encrypt_init.o
>> +	obj-y				+= mem_encrypt_boot.o
> 
> So there's a lot of ifdeffery below which is not really needed and those
> objects above get built-in by default.
> 
> So let's clean that up:
> 
> obj-$(CONFIG_AMD_MEM_ENCRYPT)		+= ...
> 
> for all .c files.
> 
> Then, put prototypes of all externally visible elements - functions,
> vars, etc - in include/linux/mem_encrypt.h in the
> 
> #else   /* !CONFIG_AMD_MEM_ENCRYPT */
> 
> branch so that the build works too for people who don't enable
> CONFIG_AMD_MEM_ENCRYPT. Much cleaner this way.

This was mainly done to avoid putting #ifdefs around the calls in
head_64.S.  I'll look closer as to what I can do to make this cleaner
but it may be a trade off on where the #ifdefs go when dealing with
assembler files.

> 
>>  endif
>> diff --git a/arch/x86/kernel/mem_encrypt_boot.S b/arch/x86/kernel/mem_encrypt_boot.S
>> new file mode 100644
>> index 0000000..d4917ba
>> --- /dev/null
>> +++ b/arch/x86/kernel/mem_encrypt_boot.S
>> @@ -0,0 +1,156 @@
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
> 
> sme_encrypt() looks perfectly fine to me.
> 
> Btw, is this the reason why this is still in asm:
> 
> "(not everything could be converted, e.g. the routine that does the
> actual encryption needs to be copied into a safe location and it is
> difficult to determine the actual length of the function in order to
> copy it)"
> 
> ?
> 
> If so, ELF symbols have sizes and you can query function sizes, perhaps
> lookup_symbol_attrs() in kernel/kallsyms.c which returns size in one of
> its args, etc.
> 
> Alternatively, we can have markers around the function if the kallsyms
> game doesn't work.

I'll look into that a bit more, but with the small assembler routines
it might be safer to stay with assembler rather than worrying about how
the compiler may do things in the future and what effects that might
have.

> 
> Below are just some small nits, I'll review this fully once we solve the
> in-asm question.
> 
>> diff --git a/arch/x86/kernel/mem_encrypt_init.c b/arch/x86/kernel/mem_encrypt_init.c
>> index 388d6fb..7bdd159 100644
>> --- a/arch/x86/kernel/mem_encrypt_init.c
>> +++ b/arch/x86/kernel/mem_encrypt_init.c
>> @@ -13,9 +13,205 @@
>>  #include <linux/linkage.h>
>>  #include <linux/init.h>
>>  #include <linux/mem_encrypt.h>
>> +#include <linux/mm.h>
>> +
>> +#include <asm/sections.h>
>> +
>> +#ifdef CONFIG_AMD_MEM_ENCRYPT
>> +
>> +extern void sme_encrypt_execute(unsigned long, unsigned long, unsigned long,
>> +				void *, pgd_t *);
>> +
>> +#define PGD_FLAGS	_KERNPG_TABLE_NO_ENC
>> +#define PUD_FLAGS	_KERNPG_TABLE_NO_ENC
>> +#define PMD_FLAGS	__PAGE_KERNEL_LARGE_EXEC
>> +
>> +static void __init *sme_pgtable_entry(pgd_t *pgd, void *next_page,
>> +				      void *vaddr, pmdval_t pmd_val)
>> +{
>> +	pud_t *pud;
>> +	pmd_t *pmd;
>> +
>> +	pgd += pgd_index((unsigned long)vaddr);
>> +	if (pgd_none(*pgd)) {
>> +		pud = next_page;
>> +		memset(pud, 0, sizeof(*pud) * PTRS_PER_PUD);
>> +		native_set_pgd(pgd,
>> +			       native_make_pgd((unsigned long)pud + PGD_FLAGS));
>> +		next_page += sizeof(*pud) * PTRS_PER_PUD;
>> +	} else {
>> +		pud = (pud_t *)(native_pgd_val(*pgd) & ~PTE_FLAGS_MASK);
>> +	}
>> +
>> +	pud += pud_index((unsigned long)vaddr);
>> +	if (pud_none(*pud)) {
>> +		pmd = next_page;
>> +		memset(pmd, 0, sizeof(*pmd) * PTRS_PER_PMD);
>> +		native_set_pud(pud,
>> +			       native_make_pud((unsigned long)pmd + PUD_FLAGS));
>> +		next_page += sizeof(*pmd) * PTRS_PER_PMD;
>> +	} else {
>> +		pmd = (pmd_t *)(native_pud_val(*pud) & ~PTE_FLAGS_MASK);
>> +	}
>> +
>> +	pmd += pmd_index((unsigned long)vaddr);
>> +	if (pmd_none(*pmd) || !pmd_large(*pmd))
>> +		native_set_pmd(pmd, native_make_pmd(pmd_val));
>> +
>> +	return next_page;
>> +}
>> +
>> +static unsigned long __init sme_pgtable_calc(unsigned long start,
>> +					     unsigned long end)
>> +{
>> +	unsigned long addr, total;
>> +
>> +	total = 0;
>> +	addr = start;
>> +	while (addr < end) {
>> +		unsigned long pgd_end;
>> +
>> +		pgd_end = (addr & PGDIR_MASK) + PGDIR_SIZE;
>> +		if (pgd_end > end)
>> +			pgd_end = end;
>> +
>> +		total += sizeof(pud_t) * PTRS_PER_PUD * 2;
>> +
>> +		while (addr < pgd_end) {
>> +			unsigned long pud_end;
>> +
>> +			pud_end = (addr & PUD_MASK) + PUD_SIZE;
>> +			if (pud_end > end)
>> +				pud_end = end;
>> +
>> +			total += sizeof(pmd_t) * PTRS_PER_PMD * 2;
>> +
>> +			addr = pud_end;
>> +		}
>> +
>> +		addr = pgd_end;
>> +	}
>> +	total += sizeof(pgd_t) * PTRS_PER_PGD;
>> +
>> +	return total;
>> +}
>> +#endif	/* CONFIG_AMD_MEM_ENCRYPT */
>>  
>>  void __init sme_encrypt_kernel(void)
>>  {
>> +#ifdef CONFIG_AMD_MEM_ENCRYPT
>> +	pgd_t *pgd;
>> +	void *workarea, *next_page, *vaddr;
>> +	unsigned long kern_start, kern_end, kern_len;
>> +	unsigned long index, paddr, pmd_flags;
>> +	unsigned long exec_size, full_size;
> 
> Args in reversed christmas tree order please:
> 
> 	unsigned long kern_start, kern_end, kern_len;
> 	unsigned long index, paddr, pmd_flags;
> 	void *workarea, *next_page, *vaddr;
> 	unsigned long exec_size, full_size;
> 	pgd_t *pgd;

Ok

> 
>> +
>> +	/* If SME is not active then no need to prepare */
>> +	if (!sme_me_mask)
>> +		return;
>> +
>> +	/* Set the workarea to be after the kernel */
>> +	workarea = (void *)ALIGN(__pa_symbol(_end), PMD_PAGE_SIZE);
>> +
>> +	/*
>> +	 * Prepare for encrypting the kernel by building new pagetables with
>> +	 * the necessary attributes needed to encrypt the kernel in place.
>> +	 *
>> +	 *   One range of virtual addresses will map the memory occupied
>> +	 *   by the kernel as encrypted.
>> +	 *
>> +	 *   Another range of virtual addresses will map the memory occupied
>> +	 *   by the kernel as un-encrypted and write-protected.
>> +	 *
>> +	 *     The use of write-protect attribute will prevent any of the
>> +	 *     memory from being cached.
>> +	 */
>> +
>> +	/* Physical address gives us the identity mapped virtual address */
>> +	kern_start = __pa_symbol(_text);
>> +	kern_end = ALIGN(__pa_symbol(_end), PMD_PAGE_SIZE) - 1;
>> +	kern_len = kern_end - kern_start + 1;
>> +
>> +	/*
>> +	 * Calculate required number of workarea bytes needed:
>> +	 *   executable encryption area size:
>> +	 *     stack page (PAGE_SIZE)
>> +	 *     encryption routine page (PAGE_SIZE)
>> +	 *     intermediate copy buffer (PMD_PAGE_SIZE)
>> +	 *   pagetable structures for workarea (in case not currently mapped)
>> +	 *   pagetable structures for the encryption of the kernel
>> +	 */
>> +	exec_size = (PAGE_SIZE * 2) + PMD_PAGE_SIZE;
>> +
>> +	full_size = exec_size;
>> +	full_size += ALIGN(exec_size, PMD_PAGE_SIZE) / PMD_PAGE_SIZE *
> 
> Is that a fancy way of saying "2"?
> 
> IOW, something like:
> 
> 	/* + 2 pmd_t pagetable pages for the executable encryption area size */
> 	full_size += 2 * PAGE_SIZE;
> 
> looks much more readable to me...

Given the current way it's implemented, yes, it's a fancy way of saying
2 * PAGE_SIZE.  I did it that way so that if exec_size changes then
nothing else would have to be changed.  I also used the "sizeof(pmd_t) *
PTRS_PER_PMD" to be consistent with where that is used elsewhere.

Thanks,
Tom

> 
>> +		     sizeof(pmd_t) * PTRS_PER_PMD;
>> +	full_size += sme_pgtable_calc(kern_start, kern_end + exec_size);
>> +
>> +	next_page = workarea + exec_size;
>> +
>> +	/* Make sure the current pagetables have entries for the workarea */
>> +	pgd = (pgd_t *)native_read_cr3();
>> +	paddr = (unsigned long)workarea;
>> +	while (paddr < (unsigned long)workarea + full_size) {
>> +		vaddr = (void *)paddr;
>> +		next_page = sme_pgtable_entry(pgd, next_page, vaddr,
>> +					      paddr + PMD_FLAGS);
>> +
>> +		paddr += PMD_PAGE_SIZE;
>> +	}
>> +	native_write_cr3(native_read_cr3());
>> +
>> +	/* Calculate a PGD index to be used for the un-encrypted mapping */
>> +	index = (pgd_index(kern_end + full_size) + 1) & (PTRS_PER_PGD - 1);
>> +	index <<= PGDIR_SHIFT;
>> +
>> +	/* Set and clear the PGD */
>> +	pgd = next_page;
>> +	memset(pgd, 0, sizeof(*pgd) * PTRS_PER_PGD);
>> +	next_page += sizeof(*pgd) * PTRS_PER_PGD;
>> +
>> +	/* Add encrypted (identity) mappings for the kernel */
>> +	pmd_flags = PMD_FLAGS | _PAGE_ENC;
>> +	paddr = kern_start;
>> +	while (paddr < kern_end) {
>> +		vaddr = (void *)paddr;
>> +		next_page = sme_pgtable_entry(pgd, next_page, vaddr,
>> +					      paddr + pmd_flags);
>> +
>> +		paddr += PMD_PAGE_SIZE;
>> +	}
>> +
>> +	/* Add un-encrypted (non-identity) mappings for the kernel */
>> +	pmd_flags = (PMD_FLAGS & ~_PAGE_CACHE_MASK) | (_PAGE_PAT | _PAGE_PWT);
>> +	paddr = kern_start;
>> +	while (paddr < kern_end) {
>> +		vaddr = (void *)(paddr + index);
>> +		next_page = sme_pgtable_entry(pgd, next_page, vaddr,
>> +					      paddr + pmd_flags);
>> +
>> +		paddr += PMD_PAGE_SIZE;
>> +	}
>> +
>> +	/* Add the workarea to both mappings */
>> +	paddr = kern_end + 1;
>> +	while (paddr < (kern_end + exec_size)) {
>> +		vaddr = (void *)paddr;
>> +		next_page = sme_pgtable_entry(pgd, next_page, vaddr,
>> +					      paddr + PMD_FLAGS);
>> +
>> +		vaddr = (void *)(paddr + index);
>> +		next_page = sme_pgtable_entry(pgd, next_page, vaddr,
>> +					      paddr + PMD_FLAGS);
>> +
>> +		paddr += PMD_PAGE_SIZE;
>> +	}
>> +
>> +	/* Perform the encryption */
>> +	sme_encrypt_execute(kern_start, kern_start + index, kern_len,
>> +			    workarea, pgd);
>> +
>> +#endif	/* CONFIG_AMD_MEM_ENCRYPT */
>>  }
>>  
>>  unsigned long __init sme_get_me_mask(void)
>>
>>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
