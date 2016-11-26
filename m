Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4E3766B0069
	for <linux-mm@kvack.org>; Sat, 26 Nov 2016 15:47:08 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id jb2so14342994wjb.6
        for <linux-mm@kvack.org>; Sat, 26 Nov 2016 12:47:08 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id rb6si48369136wjb.250.2016.11.26.12.47.06
        for <linux-mm@kvack.org>;
        Sat, 26 Nov 2016 12:47:06 -0800 (PST)
Date: Sat, 26 Nov 2016 21:47:03 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [RFC PATCH v3 20/20] x86: Add support to make use of Secure
 Memory Encryption
Message-ID: <20161126204703.wlcd6cw7dxzvpxyc@pd.tnic>
References: <20161110003426.3280.2999.stgit@tlendack-t1.amdoffice.net>
 <20161110003838.3280.23327.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20161110003838.3280.23327.stgit@tlendack-t1.amdoffice.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Wed, Nov 09, 2016 at 06:38:38PM -0600, Tom Lendacky wrote:
> This patch adds the support to check if SME has been enabled and if the
> mem_encrypt=on command line option is set. If both of these conditions
> are true, then the encryption mask is set and the kernel is encrypted
> "in place."
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---
>  arch/x86/kernel/head_64.S          |    1 +
>  arch/x86/kernel/mem_encrypt_init.c |   60 +++++++++++++++++++++++++++++++++++-
>  arch/x86/mm/mem_encrypt.c          |    2 +
>  3 files changed, 62 insertions(+), 1 deletion(-)
> 
> diff --git a/arch/x86/kernel/head_64.S b/arch/x86/kernel/head_64.S
> index e8a7272..c225433 100644
> --- a/arch/x86/kernel/head_64.S
> +++ b/arch/x86/kernel/head_64.S
> @@ -100,6 +100,7 @@ startup_64:
>  	 * to include it in the page table fixups.
>  	 */
>  	push	%rsi
> +	movq	%rsi, %rdi
>  	call	sme_enable
>  	pop	%rsi
>  	movq	%rax, %r12
> diff --git a/arch/x86/kernel/mem_encrypt_init.c b/arch/x86/kernel/mem_encrypt_init.c
> index 7bdd159..c94ceb8 100644
> --- a/arch/x86/kernel/mem_encrypt_init.c
> +++ b/arch/x86/kernel/mem_encrypt_init.c
> @@ -16,9 +16,14 @@
>  #include <linux/mm.h>
>  
>  #include <asm/sections.h>
> +#include <asm/processor-flags.h>
> +#include <asm/msr.h>
> +#include <asm/cmdline.h>
>  
>  #ifdef CONFIG_AMD_MEM_ENCRYPT
>  
> +static char sme_cmdline_arg[] __initdata = "mem_encrypt=on";

One more thing: just like we're adding an =on switch, we'd need an =off
switch in case something's wrong with the SME code. IOW, if a user
supplies "mem_encrypt=off", we do not encrypt.

Thanks.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
