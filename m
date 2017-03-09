Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2ED632808A4
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 09:08:15 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id d66so20760953wmi.2
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 06:08:15 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f72si4426434wmh.18.2017.03.09.06.08.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 09 Mar 2017 06:08:13 -0800 (PST)
Date: Thu, 9 Mar 2017 15:07:48 +0100
From: Borislav Petkov <bp@suse.de>
Subject: Re: [RFC PATCH v2 12/32] x86: Add early boot support when running
 with SEV active
Message-ID: <20170309140748.tg67yo2jmc5ahck3@pd.tnic>
References: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
 <148846768878.2349.15757532025749214650.stgit@brijesh-build-machine>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <148846768878.2349.15757532025749214650.stgit@brijesh-build-machine>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brijesh Singh <brijesh.singh@amd.com>
Cc: simon.guinot@sequanux.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linux-pci@vger.kernel.org, linus.walleij@linaro.org, gary.hook@amd.com, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, cl@linux.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, peterz@infradead.org, piotr.luc@intel.com, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, arnd@arndb.de, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, luto@kernel.org, devel@linuxdriverproject.org, bhelgaas@google.com, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, mst@redhat.com, linux-crypto@vger.kernel.org, tj@kernel.org, pbonzini@redhat.com, akpm@linux-foundation.org, davem@davemloft.net

On Thu, Mar 02, 2017 at 10:14:48AM -0500, Brijesh Singh wrote:
> From: Tom Lendacky <thomas.lendacky@amd.com>
> 
> Early in the boot process, add checks to determine if the kernel is
> running with Secure Encrypted Virtualization (SEV) active by issuing
> a CPUID instruction.
> 
> During early compressed kernel booting, if SEV is active the pagetables are
> updated so that data is accessed and decompressed with encryption.
> 
> During uncompressed kernel booting, if SEV is the memory encryption mask is
> set and a flag is set to indicate that SEV is enabled.

I don't know how many times I have to say this but I'm going to keep
doing it until it sticks: :-)

Please, no "WHAT" in the commit messages - I can see the "WHAT - but
"WHY".

Ok?

> diff --git a/arch/x86/boot/compressed/mem_encrypt.S b/arch/x86/boot/compressed/mem_encrypt.S
> new file mode 100644
> index 0000000..8313c31
> --- /dev/null
> +++ b/arch/x86/boot/compressed/mem_encrypt.S
> @@ -0,0 +1,75 @@
> +/*
> + * AMD Memory Encryption Support
> + *
> + * Copyright (C) 2016 Advanced Micro Devices, Inc.
> + *
> + * Author: Tom Lendacky <thomas.lendacky@amd.com>
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2 as
> + * published by the Free Software Foundation.
> + */
> +
> +#include <linux/linkage.h>
> +
> +#include <asm/processor-flags.h>
> +#include <asm/msr.h>
> +#include <asm/asm-offsets.h>
> +#include <uapi/asm/kvm_para.h>
> +
> +	.text
> +	.code32
> +ENTRY(sev_enabled)
> +	xor	%eax, %eax
> +
> +#ifdef CONFIG_AMD_MEM_ENCRYPT
> +	push	%ebx
> +	push	%ecx
> +	push	%edx
> +
> +	/* Check if running under a hypervisor */
> +	movl	$0x40000000, %eax
> +	cpuid
> +	cmpl	$0x40000001, %eax
> +	jb	.Lno_sev
> +
> +	movl	$0x40000001, %eax
> +	cpuid
> +	bt	$KVM_FEATURE_SEV, %eax
> +	jnc	.Lno_sev
> +
> +	/*
> +	 * Check for memory encryption feature:
> +	 *   CPUID Fn8000_001F[EAX] - Bit 0
> +	 */
> +	movl	$0x8000001f, %eax
> +	cpuid
> +	bt	$0, %eax
> +	jnc	.Lno_sev
> +
> +	/*
> +	 * Get memory encryption information:
> +	 *   CPUID Fn8000_001F[EBX] - Bits 5:0
> +	 *     Pagetable bit position used to indicate encryption
> +	 */
> +	movl	%ebx, %eax
> +	andl	$0x3f, %eax
> +	movl	%eax, sev_enc_bit(%ebp)
> +	jmp	.Lsev_exit
> +
> +.Lno_sev:
> +	xor	%eax, %eax
> +
> +.Lsev_exit:
> +	pop	%edx
> +	pop	%ecx
> +	pop	%ebx
> +
> +#endif	/* CONFIG_AMD_MEM_ENCRYPT */
> +
> +	ret
> +ENDPROC(sev_enabled)

Right, as said in another mail earlier, this could be written in C. And
then the sme_enable() piece below looks the same as this one above. So
since you want to run it before kernel decompression and after, you
could extract this code into a separate .c file which you can link in
both places, similar to what we do with verify_cpu with the difference
that verify_cpu is getting included.

Alternatively, we still have some room in setup_header.xloadflags to
pass boot info to kernel proper from before the decompression stage.

But I'd prefer linking with both stages as it is cheaper and those flags
we can use for something which really wants to use a flag like that.

> diff --git a/arch/x86/kernel/mem_encrypt_init.c b/arch/x86/kernel/mem_encrypt_init.c
> index 35c5e3d..5d514e6 100644
> --- a/arch/x86/kernel/mem_encrypt_init.c
> +++ b/arch/x86/kernel/mem_encrypt_init.c
> @@ -22,6 +22,7 @@
>  #include <asm/processor-flags.h>
>  #include <asm/msr.h>
>  #include <asm/cmdline.h>
> +#include <asm/kvm_para.h>
>  
>  static char sme_cmdline_arg_on[] __initdata = "mem_encrypt=on";
>  static char sme_cmdline_arg_off[] __initdata = "mem_encrypt=off";
> @@ -232,6 +233,29 @@ unsigned long __init sme_enable(void *boot_data)
>  	void *cmdline_arg;
>  	u64 msr;
>  
> +	/* Check if running under a hypervisor */
> +	eax = 0x40000000;
> +	ecx = 0;
> +	native_cpuid(&eax, &ebx, &ecx, &edx);
> +	if (eax > 0x40000000) {
> +		eax = 0x40000001;
> +		ecx = 0;
> +		native_cpuid(&eax, &ebx, &ecx, &edx);
> +		if (!(eax & BIT(KVM_FEATURE_SEV)))
> +			goto out;
> +
> +		eax = 0x8000001f;
> +		ecx = 0;
> +		native_cpuid(&eax, &ebx, &ecx, &edx);
> +		if (!(eax & 1))
> +			goto out;
> +
> +		sme_me_mask = 1UL << (ebx & 0x3f);
> +		sev_enabled = 1;
> +
> +		goto out;
> +	}
> +
>  	/* Check for an AMD processor */
>  	eax = 0;
>  	ecx = 0;
> 

-- 
Regards/Gruss,
    Boris.

SUSE Linux GmbH, GF: Felix ImendA?rffer, Jane Smithard, Graham Norton, HRB 21284 (AG NA 1/4 rnberg)
-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
