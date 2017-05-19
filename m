Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8D6A028041F
	for <linux-mm@kvack.org>; Fri, 19 May 2017 07:27:06 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id y106so4580994wrb.14
        for <linux-mm@kvack.org>; Fri, 19 May 2017 04:27:06 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTP id j90si7518450edd.275.2017.05.19.04.27.04
        for <linux-mm@kvack.org>;
        Fri, 19 May 2017 04:27:05 -0700 (PDT)
Date: Fri, 19 May 2017 13:27:03 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v5 32/32] x86/mm: Add support to make use of Secure
 Memory Encryption
Message-ID: <20170519112703.voajtn4t7uy6nwa3@pd.tnic>
References: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
 <20170418212223.10190.85121.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20170418212223.10190.85121.stgit@tlendack-t1.amdoffice.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Tue, Apr 18, 2017 at 04:22:23PM -0500, Tom Lendacky wrote:
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

...

> +unsigned long __init sme_enable(struct boot_params *bp)
>  {
> +	const char *cmdline_ptr, *cmdline_arg, *cmdline_on, *cmdline_off;
> +	unsigned int eax, ebx, ecx, edx;
> +	unsigned long me_mask;
> +	bool active_by_default;
> +	char buffer[16];
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

<---- newline here.

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

Why doesn't simply

	if (!strncmp(buffer, "on", 2))
		...

work?

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
