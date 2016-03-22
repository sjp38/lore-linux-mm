Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 74B986B025F
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 08:53:31 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id e201so36521186wme.1
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 05:53:31 -0700 (PDT)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTP id cb2si4242729wjc.188.2016.04.27.05.53.30
        for <linux-mm@kvack.org>;
        Wed, 27 Apr 2016 05:53:30 -0700 (PDT)
Date: Tue, 22 Mar 2016 14:13:09 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [RFC PATCH v1 18/18] x86: Add support to turn on Secure Memory
 Encryption
Message-ID: <20160322131309.GD16528@xo-6d-61-c0.localdomain>
References: <20160426225553.13567.19459.stgit@tlendack-t1.amdoffice.net>
 <20160426225904.13567.538.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160426225904.13567.538.stgit@tlendack-t1.amdoffice.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

Hi!

> This patch adds the support to check for and enable SME when available
> on the processor and when the mem_encrypt=on command line option is set.
> This consists of setting the encryption mask, calculating the number of
> physical bits of addressing lost and encrypting the kernel "in place."
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---
>  Documentation/kernel-parameters.txt |    3 
>  arch/x86/kernel/asm-offsets.c       |    2 
>  arch/x86/kernel/mem_encrypt.S       |  306 +++++++++++++++++++++++++++++++++++
>  3 files changed, 311 insertions(+)
> 
> diff --git a/arch/x86/kernel/mem_encrypt.S b/arch/x86/kernel/mem_encrypt.S
> index f2e0536..4d3326d 100644
> --- a/arch/x86/kernel/mem_encrypt.S
> +++ b/arch/x86/kernel/mem_encrypt.S
> @@ -12,13 +12,236 @@
>  
>  #include <linux/linkage.h>
>  
> +#include <asm/processor-flags.h>
> +#include <asm/pgtable.h>
> +#include <asm/page.h>
> +#include <asm/msr.h>
> +#include <asm/asm-offsets.h>
> +
>  	.text
>  	.code64
>  ENTRY(sme_enable)
> +#ifdef CONFIG_AMD_MEM_ENCRYPT
> +	/* Check for AMD processor */
> +	xorl	%eax, %eax
> +	cpuid
> +	cmpl    $0x68747541, %ebx	# AuthenticAMD
> +	jne     .Lno_mem_encrypt
> +	cmpl    $0x69746e65, %edx
> +	jne     .Lno_mem_encrypt
> +	cmpl    $0x444d4163, %ecx
> +	jne     .Lno_mem_encrypt
> +
> +	/* Check for memory encryption leaf */
> +	movl	$0x80000000, %eax
> +	cpuid
> +	cmpl	$0x8000001f, %eax
> +	jb	.Lno_mem_encrypt
> +
> +	/*
> +	 * Check for memory encryption feature:
> +	 *   CPUID Fn8000_001F[EAX] - Bit 0
> +	 */
> +	movl	$0x8000001f, %eax
> +	cpuid
> +	bt	$0, %eax
> +	jnc	.Lno_mem_encrypt
> +
> +	/* Check for the mem_encrypt=on command line option */
> +	push	%rsi			/* Save RSI (real_mode_data) */
> +	movl	BP_ext_cmd_line_ptr(%rsi), %ecx
> +	shlq	$32, %rcx
> +	movl	BP_cmd_line_ptr(%rsi), %edi
> +	addq	%rcx, %rdi
> +	leaq	mem_encrypt_enable_option(%rip), %rsi
> +	call	cmdline_find_option_bool
> +	pop	%rsi			/* Restore RSI (real_mode_data) */
> +	testl	%eax, %eax
> +	jz	.Lno_mem_encrypt

Can you move parts to C here, so that it is more readable?

								Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
