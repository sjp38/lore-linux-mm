Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id B3A8B6B02C1
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 14:56:28 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id s85so153054841ios.1
        for <linux-mm@kvack.org>; Fri, 21 Apr 2017 11:56:28 -0700 (PDT)
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-by2nam01on0058.outbound.protection.outlook.com. [104.47.34.58])
        by mx.google.com with ESMTPS id y127si11023376pgy.49.2017.04.21.11.56.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 21 Apr 2017 11:56:27 -0700 (PDT)
Subject: Re: [PATCH v5 32/32] x86/mm: Add support to make use of Secure Memory
 Encryption
References: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
 <20170418212223.10190.85121.stgit@tlendack-t1.amdoffice.net>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <c29edaff-24f2-ee9b-4142-bdbf8c42083f@amd.com>
Date: Fri, 21 Apr 2017 13:56:13 -0500
MIME-Version: 1.0
In-Reply-To: <20170418212223.10190.85121.stgit@tlendack-t1.amdoffice.net>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 4/18/2017 4:22 PM, Tom Lendacky wrote:
> Add support to check if SME has been enabled and if memory encryption
> should be activated (checking of command line option based on the
> configuration of the default state).  If memory encryption is to be
> activated, then the encryption mask is set and the kernel is encrypted
> "in place."
>
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---
>  arch/x86/kernel/head_64.S |    1 +
>  arch/x86/mm/mem_encrypt.c |   83 +++++++++++++++++++++++++++++++++++++++++++--
>  2 files changed, 80 insertions(+), 4 deletions(-)
>

...

>
> -unsigned long __init sme_enable(void)
> +unsigned long __init sme_enable(struct boot_params *bp)
>  {
> +	const char *cmdline_ptr, *cmdline_arg, *cmdline_on, *cmdline_off;
> +	unsigned int eax, ebx, ecx, edx;
> +	unsigned long me_mask;
> +	bool active_by_default;
> +	char buffer[16];

So it turns out that when KASLR is enabled (CONFIG_RAMDOMIZE_BASE=y)
the stack-protector support causes issues with this function because
it is called so early. I can get past it by adding:

CFLAGS_mem_encrypt.o := $(nostackp)

in the arch/x86/mm/Makefile, but that obviously eliminates the support
for the whole file.  Would it be better to split out the sme_enable()
and other boot routines into a separate file or just apply the
$(nostackp) to the whole file?

Thanks,
Tom

> +	u64 msr;
> +
> +	/* Check for the SME support leaf */
> +	eax = 0x80000000;
> +	ecx = 0;
> +	native_cpuid(&eax, &ebx, &ecx, &edx);
> +	if (eax < 0x8000001f)
> +		goto out;
> +
> +	/*
> +	 * Check for the SME feature:
> +	 *   CPUID Fn8000_001F[EAX] - Bit 0
> +	 *     Secure Memory Encryption support
> +	 *   CPUID Fn8000_001F[EBX] - Bits 5:0
> +	 *     Pagetable bit position used to indicate encryption
> +	 */
> +	eax = 0x8000001f;
> +	ecx = 0;
> +	native_cpuid(&eax, &ebx, &ecx, &edx);
> +	if (!(eax & 1))
> +		goto out;
> +	me_mask = 1UL << (ebx & 0x3f);
> +
> +	/* Check if SME is enabled */
> +	msr = __rdmsr(MSR_K8_SYSCFG);
> +	if (!(msr & MSR_K8_SYSCFG_MEM_ENCRYPT))
> +		goto out;
> +
> +	/*
> +	 * Fixups have not been applied to phys_base yet, so we must obtain
> +	 * the address to the SME command line option data in the following
> +	 * way.
> +	 */
> +	asm ("lea sme_cmdline_arg(%%rip), %0"
> +	     : "=r" (cmdline_arg)
> +	     : "p" (sme_cmdline_arg));
> +	asm ("lea sme_cmdline_on(%%rip), %0"
> +	     : "=r" (cmdline_on)
> +	     : "p" (sme_cmdline_on));
> +	asm ("lea sme_cmdline_off(%%rip), %0"
> +	     : "=r" (cmdline_off)
> +	     : "p" (sme_cmdline_off));
> +
> +	if (IS_ENABLED(CONFIG_AMD_MEM_ENCRYPT_ACTIVE_BY_DEFAULT))
> +		active_by_default = true;
> +	else
> +		active_by_default = false;
> +
> +	cmdline_ptr = (const char *)((u64)bp->hdr.cmd_line_ptr |
> +				     ((u64)bp->ext_cmd_line_ptr << 32));
> +
> +	cmdline_find_option(cmdline_ptr, cmdline_arg, buffer, sizeof(buffer));
> +
> +	if (strncmp(buffer, cmdline_on, sizeof(buffer)) == 0)
> +		sme_me_mask = me_mask;
> +	else if (strncmp(buffer, cmdline_off, sizeof(buffer)) == 0)
> +		sme_me_mask = 0;
> +	else
> +		sme_me_mask = active_by_default ? me_mask : 0;
> +
> +out:
>  	return sme_me_mask;
>  }
>
> @@ -543,9 +618,9 @@ unsigned long sme_get_me_mask(void)
>
>  #else	/* !CONFIG_AMD_MEM_ENCRYPT */
>
> -void __init sme_encrypt_kernel(void)	{ }
> -unsigned long __init sme_enable(void)	{ return 0; }
> +void __init sme_encrypt_kernel(void)			{ }
> +unsigned long __init sme_enable(struct boot_params *bp)	{ return 0; }
>
> -unsigned long sme_get_me_mask(void)	{ return 0; }
> +unsigned long sme_get_me_mask(void)			{ return 0; }
>
>  #endif	/* CONFIG_AMD_MEM_ENCRYPT */
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
