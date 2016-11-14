Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id DA1556B0069
	for <linux-mm@kvack.org>; Mon, 14 Nov 2016 13:18:55 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id e9so81081508pgc.5
        for <linux-mm@kvack.org>; Mon, 14 Nov 2016 10:18:55 -0800 (PST)
Received: from NAM02-SN1-obe.outbound.protection.outlook.com (mail-sn1nam02on0084.outbound.protection.outlook.com. [104.47.36.84])
        by mx.google.com with ESMTPS id 76si23175454pfo.238.2016.11.14.10.18.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 14 Nov 2016 10:18:54 -0800 (PST)
Subject: Re: [RFC PATCH v3 06/20] x86: Add support to enable SME during early
 boot processing
References: <20161110003426.3280.2999.stgit@tlendack-t1.amdoffice.net>
 <20161110003543.3280.99623.stgit@tlendack-t1.amdoffice.net>
 <20161114172930.27z7p2kytmhtcbsb@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <178d7d21-ffbd-1083-9c64-f05378147e27@amd.com>
Date: Mon, 14 Nov 2016 12:18:44 -0600
MIME-Version: 1.0
In-Reply-To: <20161114172930.27z7p2kytmhtcbsb@pd.tnic>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 11/14/2016 11:29 AM, Borislav Petkov wrote:
> On Wed, Nov 09, 2016 at 06:35:43PM -0600, Tom Lendacky wrote:
>> This patch adds support to the early boot code to use Secure Memory
>> Encryption (SME).  Support is added to update the early pagetables with
>> the memory encryption mask and to encrypt the kernel in place.
>>
>> The routines to set the encryption mask and perform the encryption are
>> stub routines for now with full function to be added in a later patch.
>>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>> ---
>>  arch/x86/kernel/Makefile           |    2 ++
>>  arch/x86/kernel/head_64.S          |   35 ++++++++++++++++++++++++++++++++++-
>>  arch/x86/kernel/mem_encrypt_init.c |   29 +++++++++++++++++++++++++++++
>>  3 files changed, 65 insertions(+), 1 deletion(-)
>>  create mode 100644 arch/x86/kernel/mem_encrypt_init.c
>>
>> diff --git a/arch/x86/kernel/Makefile b/arch/x86/kernel/Makefile
>> index 45257cf..27e22f4 100644
>> --- a/arch/x86/kernel/Makefile
>> +++ b/arch/x86/kernel/Makefile
>> @@ -141,4 +141,6 @@ ifeq ($(CONFIG_X86_64),y)
>>  
>>  	obj-$(CONFIG_PCI_MMCONFIG)	+= mmconf-fam10h_64.o
>>  	obj-y				+= vsmp_64.o
>> +
>> +	obj-y				+= mem_encrypt_init.o
>>  endif
>> diff --git a/arch/x86/kernel/head_64.S b/arch/x86/kernel/head_64.S
>> index c98a559..9a28aad 100644
>> --- a/arch/x86/kernel/head_64.S
>> +++ b/arch/x86/kernel/head_64.S
>> @@ -95,6 +95,17 @@ startup_64:
>>  	jnz	bad_address
>>  
>>  	/*
>> +	 * Enable Secure Memory Encryption (if available).  Save the mask
>> +	 * in %r12 for later use and add the memory encryption mask to %rbp
>> +	 * to include it in the page table fixups.
>> +	 */
>> +	push	%rsi
>> +	call	sme_enable
>> +	pop	%rsi
> 
> Why %rsi?
> 
> sme_enable() is void so no args in registers and returns in %rax.
> 
> /me is confused.

The %rsi register can be clobbered by the called function so I'm saving
it since it points to the real mode data.  I might be able to look into
saving it earlier and restoring it before needed, but I though this
might be clearer.

> 
>> +	movq	%rax, %r12
>> +	addq	%r12, %rbp
>> +
>> +	/*
>>  	 * Fixup the physical addresses in the page table
>>  	 */
>>  	addq	%rbp, early_level4_pgt + (L4_START_KERNEL*8)(%rip)
>> @@ -117,6 +128,7 @@ startup_64:
>>  	shrq	$PGDIR_SHIFT, %rax
>>  
>>  	leaq	(4096 + _KERNPG_TABLE)(%rbx), %rdx
>> +	addq	%r12, %rdx
>>  	movq	%rdx, 0(%rbx,%rax,8)
>>  	movq	%rdx, 8(%rbx,%rax,8)
>>  
>> @@ -133,6 +145,7 @@ startup_64:
>>  	movq	%rdi, %rax
>>  	shrq	$PMD_SHIFT, %rdi
>>  	addq	$(__PAGE_KERNEL_LARGE_EXEC & ~_PAGE_GLOBAL), %rax
>> +	addq	%r12, %rax
>>  	leaq	(_end - 1)(%rip), %rcx
>>  	shrq	$PMD_SHIFT, %rcx
>>  	subq	%rdi, %rcx
>> @@ -163,9 +176,21 @@ startup_64:
>>  	cmp	%r8, %rdi
>>  	jne	1b
>>  
>> -	/* Fixup phys_base */
>> +	/*
>> +	 * Fixup phys_base, remove the memory encryption mask from %rbp
>> +	 * to obtain the true physical address.
>> +	 */
>> +	subq	%r12, %rbp
>>  	addq	%rbp, phys_base(%rip)
>>  
>> +	/*
>> +	 * The page tables have been updated with the memory encryption mask,
>> +	 * so encrypt the kernel if memory encryption is active
>> +	 */
>> +	push	%rsi
>> +	call	sme_encrypt_kernel
>> +	pop	%rsi
> 
> Ditto.
> 
>> +
>>  	movq	$(early_level4_pgt - __START_KERNEL_map), %rax
>>  	jmp 1f
>>  ENTRY(secondary_startup_64)
>> @@ -186,9 +211,17 @@ ENTRY(secondary_startup_64)
>>  	/* Sanitize CPU configuration */
>>  	call verify_cpu
>>  
>> +	push	%rsi
>> +	call	sme_get_me_mask
>> +	pop	%rsi
> 
> Ditto.
> 
>> +	movq	%rax, %r12
>> +
>>  	movq	$(init_level4_pgt - __START_KERNEL_map), %rax
>>  1:
>>  
>> +	/* Add the memory encryption mask to RAX */
> 
> I think that should say something like:
> 
> 	/*
> 	 * Add the memory encryption mask to init_level4_pgt's physical address
> 	 */
> 
> or so...

Yup, I'll expand on the comment for this.

> 
>> +	addq	%r12, %rax
>> +
>>  	/* Enable PAE mode and PGE */
>>  	movl	$(X86_CR4_PAE | X86_CR4_PGE), %ecx
>>  	movq	%rcx, %cr4
>> diff --git a/arch/x86/kernel/mem_encrypt_init.c b/arch/x86/kernel/mem_encrypt_init.c
>> new file mode 100644
>> index 0000000..388d6fb
>> --- /dev/null
>> +++ b/arch/x86/kernel/mem_encrypt_init.c
> 
> So nothing in the commit message explains why we need a separate
> mem_encrypt_init.c file when we already have arch/x86/mm/mem_encrypt.c
> for all memory encryption code...

I can expand on the commit message about that.  I was trying to keep the
early boot-related code separate from the main code in arch/x86/mm dir.

Thanks,
Tom

> 
>> @@ -0,0 +1,29 @@
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
>> +#include <linux/init.h>
>> +#include <linux/mem_encrypt.h>
>> +
>> +void __init sme_encrypt_kernel(void)
>> +{
>> +}
>> +
>> +unsigned long __init sme_get_me_mask(void)
>> +{
>> +	return sme_me_mask;
>> +}
>> +
>> +unsigned long __init sme_enable(void)
>> +{
>> +	return sme_me_mask;
>> +}
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
