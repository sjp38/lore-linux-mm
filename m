Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7A8D56B0038
	for <linux-mm@kvack.org>; Wed, 14 Sep 2016 10:31:51 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id fu12so30610974pac.1
        for <linux-mm@kvack.org>; Wed, 14 Sep 2016 07:31:51 -0700 (PDT)
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (mail-co1nam03on0058.outbound.protection.outlook.com. [104.47.40.58])
        by mx.google.com with ESMTPS id f8si5056257pad.9.2016.09.14.07.31.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 14 Sep 2016 07:31:50 -0700 (PDT)
Subject: Re: [RFC PATCH v2 20/20] x86: Add support to make use of Secure
 Memory Encryption
References: <20160822223529.29880.50884.stgit@tlendack-t1.amdoffice.net>
 <20160822223908.29880.50365.stgit@tlendack-t1.amdoffice.net>
 <20160912170856.2uklaoc4vxmkgnkq@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <11306db6-fec1-db98-5e1b-400f7d828f7e@amd.com>
Date: Wed, 14 Sep 2016 09:31:42 -0500
MIME-Version: 1.0
In-Reply-To: <20160912170856.2uklaoc4vxmkgnkq@pd.tnic>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Paolo Bonzini <pbonzini@redhat.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 09/12/2016 12:08 PM, Borislav Petkov wrote:
> On Mon, Aug 22, 2016 at 05:39:08PM -0500, Tom Lendacky wrote:
>> This patch adds the support to check if SME has been enabled and if the
>> mem_encrypt=on command line option is set. If both of these conditions
>> are true, then the encryption mask is set and the kernel is encrypted
>> "in place."
>>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>> ---
>>  Documentation/kernel-parameters.txt |    3 
>>  arch/x86/kernel/asm-offsets.c       |    2 
>>  arch/x86/kernel/mem_encrypt.S       |  302 +++++++++++++++++++++++++++++++++++
>>  arch/x86/mm/mem_encrypt.c           |    2 
>>  4 files changed, 309 insertions(+)
>>
>> diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
>> index 46c030a..a1986c8 100644
>> --- a/Documentation/kernel-parameters.txt
>> +++ b/Documentation/kernel-parameters.txt
>> @@ -2268,6 +2268,9 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
>>  			memory contents and reserves bad memory
>>  			regions that are detected.
>>  
>> +	mem_encrypt=on	[X86_64] Enable memory encryption on processors
>> +			that support this feature.
>> +
>>  	meye.*=		[HW] Set MotionEye Camera parameters
>>  			See Documentation/video4linux/meye.txt.
>>  
>> diff --git a/arch/x86/kernel/asm-offsets.c b/arch/x86/kernel/asm-offsets.c
>> index 2bd5c6f..e485ada 100644
>> --- a/arch/x86/kernel/asm-offsets.c
>> +++ b/arch/x86/kernel/asm-offsets.c
>> @@ -85,6 +85,8 @@ void common(void) {
>>  	OFFSET(BP_init_size, boot_params, hdr.init_size);
>>  	OFFSET(BP_pref_address, boot_params, hdr.pref_address);
>>  	OFFSET(BP_code32_start, boot_params, hdr.code32_start);
>> +	OFFSET(BP_cmd_line_ptr, boot_params, hdr.cmd_line_ptr);
>> +	OFFSET(BP_ext_cmd_line_ptr, boot_params, ext_cmd_line_ptr);
>>  
>>  	BLANK();
>>  	DEFINE(PTREGS_SIZE, sizeof(struct pt_regs));
>> diff --git a/arch/x86/kernel/mem_encrypt.S b/arch/x86/kernel/mem_encrypt.S
>> index f2e0536..bf9f6a9 100644
>> --- a/arch/x86/kernel/mem_encrypt.S
>> +++ b/arch/x86/kernel/mem_encrypt.S
>> @@ -12,13 +12,230 @@
>>  
>>  #include <linux/linkage.h>
>>  
>> +#include <asm/processor-flags.h>
>> +#include <asm/pgtable.h>
>> +#include <asm/page.h>
>> +#include <asm/msr.h>
>> +#include <asm/asm-offsets.h>
>> +
>>  	.text
>>  	.code64
>>  ENTRY(sme_enable)
>> +#ifdef CONFIG_AMD_MEM_ENCRYPT
>> +	/* Check for AMD processor */
>> +	xorl	%eax, %eax
>> +	cpuid
>> +	cmpl    $0x68747541, %ebx	# AuthenticAMD
>> +	jne     .Lmem_encrypt_exit
>> +	cmpl    $0x69746e65, %edx
>> +	jne     .Lmem_encrypt_exit
>> +	cmpl    $0x444d4163, %ecx
>> +	jne     .Lmem_encrypt_exit
>> +
>> +	/* Check for memory encryption leaf */
>> +	movl	$0x80000000, %eax
>> +	cpuid
>> +	cmpl	$0x8000001f, %eax
>> +	jb	.Lmem_encrypt_exit
>> +
>> +	/*
>> +	 * Check for memory encryption feature:
>> +	 *   CPUID Fn8000_001F[EAX] - Bit 0
>> +	 *     Secure Memory Encryption support
>> +	 *   CPUID Fn8000_001F[EBX] - Bits 5:0
>> +	 *     Pagetable bit position used to indicate encryption
>> +	 *   CPUID Fn8000_001F[EBX] - Bits 11:6
>> +	 *     Reduction in physical address space (in bits) when enabled
>> +	 */
>> +	movl	$0x8000001f, %eax
>> +	cpuid
>> +	bt	$0, %eax
>> +	jnc	.Lmem_encrypt_exit
>> +
>> +	/* Check if BIOS/UEFI has allowed memory encryption */
>> +	movl	$MSR_K8_SYSCFG, %ecx
>> +	rdmsr
>> +	bt	$MSR_K8_SYSCFG_MEM_ENCRYPT_BIT, %eax
>> +	jnc	.Lmem_encrypt_exit
> 
> Like other people suggested, it would be great if this were in C. Should be
> actually readable :)

Yup, working on that.  I'll try and make it all completely C.

> 
>> +
>> +	/* Check for the mem_encrypt=on command line option */
>> +	push	%rsi			/* Save RSI (real_mode_data) */
>> +	push	%rbx			/* Save CPUID information */
>> +	movl	BP_ext_cmd_line_ptr(%rsi), %ecx
>> +	shlq	$32, %rcx
>> +	movl	BP_cmd_line_ptr(%rsi), %edi
>> +	addq	%rcx, %rdi
>> +	leaq	mem_encrypt_enable_option(%rip), %rsi
>> +	call	cmdline_find_option_bool
>> +	pop	%rbx			/* Restore CPUID information */
>> +	pop	%rsi			/* Restore RSI (real_mode_data) */
>> +	testl	%eax, %eax
>> +	jz	.Lno_mem_encrypt
> 
> This too.
> 
>> +
>> +	/* Set memory encryption mask */
>> +	movl	%ebx, %ecx
>> +	andl	$0x3f, %ecx
>> +	bts	%ecx, sme_me_mask(%rip)
>> +
>> +.Lno_mem_encrypt:
>> +	/*
>> +	 * BIOS/UEFI has allowed memory encryption so we need to set
>> +	 * the amount of physical address space reduction even if
>> +	 * the user decides not to use memory encryption.
>> +	 */
>> +	movl	%ebx, %ecx
>> +	shrl	$6, %ecx
>> +	andl	$0x3f, %ecx
>> +	movb	%cl, sme_me_loss(%rip)
>> +
>> +.Lmem_encrypt_exit:
>> +#endif	/* CONFIG_AMD_MEM_ENCRYPT */
>> +
>>  	ret
>>  ENDPROC(sme_enable)
>>  
>>  ENTRY(sme_encrypt_kernel)
> 
> This should be doable too but I guess you'll have to try it to see.
> 
> ...
> 
>> diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
>> index 2f28d87..1154353 100644
>> --- a/arch/x86/mm/mem_encrypt.c
>> +++ b/arch/x86/mm/mem_encrypt.c
>> @@ -183,6 +183,8 @@ void __init mem_encrypt_init(void)
>>  
>>  	/* Make SWIOTLB use an unencrypted DMA area */
>>  	swiotlb_clear_encryption();
>> +
>> +	pr_info("memory encryption active\n");
> 
> Let's make it more official with nice caps and so on...
> 
> 	pr_info("AMD Secure Memory Encryption active.\n");

Will do.

Thanks,
Tom

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
