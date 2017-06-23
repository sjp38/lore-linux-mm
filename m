Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id D25196B02FA
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 13:39:59 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z1so14568271wrz.10
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 10:39:59 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTP id a3si4570046wmi.183.2017.06.23.10.39.58
        for <linux-mm@kvack.org>;
        Fri, 23 Jun 2017 10:39:58 -0700 (PDT)
Date: Fri, 23 Jun 2017 19:39:37 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v7 36/36] x86/mm: Add support to make use of Secure
 Memory Encryption
Message-ID: <20170623173937.erotfiemyidyvarn@pd.tnic>
References: <20170616184947.18967.84890.stgit@tlendack-t1.amdoffice.net>
 <20170616185639.18967.41488.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20170616185639.18967.41488.stgit@tlendack-t1.amdoffice.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, xen-devel@lists.xen.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Brijesh Singh <brijesh.singh@amd.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Matt Fleming <matt@codeblueprint.co.uk>, Alexander Potapenko <glider@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Larry Woodman <lwoodman@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, "Michael S. Tsirkin" <mst@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dave Young <dyoung@redhat.com>, Rik van Riel <riel@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dmitry Vyukov <dvyukov@google.com>, Juergen Gross <jgross@suse.com>, Thomas Gleixner <tglx@linutronix.de>, Paolo Bonzini <pbonzini@redhat.com>

On Fri, Jun 16, 2017 at 01:56:39PM -0500, Tom Lendacky wrote:
> Add support to check if SME has been enabled and if memory encryption
> should be activated (checking of command line option based on the
> configuration of the default state).  If memory encryption is to be
> activated, then the encryption mask is set and the kernel is encrypted
> "in place."
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---
>  arch/x86/include/asm/mem_encrypt.h |    6 ++-
>  arch/x86/kernel/head64.c           |    4 +-
>  arch/x86/mm/mem_encrypt.c          |   86 +++++++++++++++++++++++++++++++++++-
>  3 files changed, 90 insertions(+), 6 deletions(-)

...

> +/*
> + * Some SME functions run very early causing issues with the stack-protector
> + * support. Provide a way to turn off this support on a per-function basis.
> + */
> +#define SME_NOSTACKP __attribute__((__optimize__("no-stack-protector")))

__nostackp

just like the others in include/linux/compiler-gcc.h.

> +
> +static char sme_cmdline_arg[] __initdata = "mem_encrypt";
> +static char sme_cmdline_on[]  __initdata = "on";
> +static char sme_cmdline_off[] __initdata = "off";
>  
>  /*
>   * Since SME related variables are set early in the boot process they must
> @@ -200,6 +215,8 @@ void __init mem_encrypt_init(void)
>  
>  	/* Call into SWIOTLB to update the SWIOTLB DMA buffers */
>  	swiotlb_update_mem_attributes();
> +
> +	pr_info("AMD Secure Memory Encryption (SME) active\n");
>  }
>  
>  void swiotlb_set_mem_attributes(void *vaddr, unsigned long size)
> @@ -527,8 +544,73 @@ void __init sme_encrypt_kernel(void)
>  	native_write_cr3(__native_read_cr3());
>  }
>  
> -void __init sme_enable(void)
> +void __init SME_NOSTACKP sme_enable(struct boot_params *bp)
>  {
> +	const char *cmdline_ptr, *cmdline_arg, *cmdline_on, *cmdline_off;
> +	unsigned int eax, ebx, ecx, edx;
> +	bool active_by_default;
> +	unsigned long me_mask;
> +	char buffer[16];
> +	u64 msr;
> +
> +	/* Check for the SME support leaf */
> +	eax = 0x80000000;
> +	ecx = 0;
> +	native_cpuid(&eax, &ebx, &ecx, &edx);
> +	if (eax < 0x8000001f)
> +		return;
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
> +		return;
> +
> +	me_mask = 1UL << (ebx & 0x3f);
> +
> +	/* Check if SME is enabled */
> +	msr = __rdmsr(MSR_K8_SYSCFG);
> +	if (!(msr & MSR_K8_SYSCFG_MEM_ENCRYPT))
> +		return;
> +
> +	/*
> +	 * Fixups have not been applied to phys_base yet and we're running
> +	 * identity mapped, so we must obtain the address to the SME command
> +	 * line argument data using rip-relative addressing.
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

	if (!strncmp(...

> +		sme_me_mask = me_mask;
> +	else if (strncmp(buffer, cmdline_off, sizeof(buffer)) == 0)

	else if (!strncmp(...

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
