Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id EB6946B02F4
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 03:39:01 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id p190so14461709wme.3
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 00:39:01 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTP id a135si8888178wmd.2.2017.06.20.00.38.59
        for <linux-mm@kvack.org>;
        Tue, 20 Jun 2017 00:39:00 -0700 (PDT)
Date: Tue, 20 Jun 2017 09:38:45 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v7 08/36] x86/mm: Add support to enable SME in early boot
 processing
Message-ID: <20170620073845.nteivabsgcdy7gv4@pd.tnic>
References: <20170616184947.18967.84890.stgit@tlendack-t1.amdoffice.net>
 <20170616185115.18967.79622.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20170616185115.18967.79622.stgit@tlendack-t1.amdoffice.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, xen-devel@lists.xen.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Brijesh Singh <brijesh.singh@amd.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Matt Fleming <matt@codeblueprint.co.uk>, Alexander Potapenko <glider@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Larry Woodman <lwoodman@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, "Michael S. Tsirkin" <mst@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dave Young <dyoung@redhat.com>, Rik van Riel <riel@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dmitry Vyukov <dvyukov@google.com>, Juergen Gross <jgross@suse.com>, Thomas Gleixner <tglx@linutronix.de>, Paolo Bonzini <pbonzini@redhat.com>

On Fri, Jun 16, 2017 at 01:51:15PM -0500, Tom Lendacky wrote:
> Add support to the early boot code to use Secure Memory Encryption (SME).
> Since the kernel has been loaded into memory in a decrypted state, encrypt
> the kernel in place and update the early pagetables with the memory
> encryption mask so that new pagetable entries will use memory encryption.
> 
> The routines to set the encryption mask and perform the encryption are
> stub routines for now with functionality to be added in a later patch.
> 
> Because of the need to have the routines available to head_64.S, the
> mem_encrypt.c is always built and #ifdefs in mem_encrypt.c will provide
> functionality or stub routines depending on CONFIG_AMD_MEM_ENCRYPT.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---
>  arch/x86/include/asm/mem_encrypt.h |    8 +++++++
>  arch/x86/kernel/head64.c           |   33 +++++++++++++++++++++---------
>  arch/x86/kernel/head_64.S          |   39 ++++++++++++++++++++++++++++++++++--
>  arch/x86/mm/Makefile               |    4 +---
>  arch/x86/mm/mem_encrypt.c          |   24 ++++++++++++++++++++++
>  5 files changed, 93 insertions(+), 15 deletions(-)

...

> diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
> index b99d469..9a78277 100644
> --- a/arch/x86/mm/mem_encrypt.c
> +++ b/arch/x86/mm/mem_encrypt.c
> @@ -11,6 +11,9 @@
>   */
>  
>  #include <linux/linkage.h>
> +#include <linux/init.h>
> +
> +#ifdef CONFIG_AMD_MEM_ENCRYPT
>  
>  /*
>   * Since SME related variables are set early in the boot process they must
> @@ -19,3 +22,24 @@
>   */
>  unsigned long sme_me_mask __section(.data) = 0;
>  EXPORT_SYMBOL_GPL(sme_me_mask);
> +
> +void __init sme_encrypt_kernel(void)
> +{
> +}

Just the minor:

void __init sme_encrypt_kernel(void) { }

in case you have to respin.

Reviewed-by: Borislav Petkov <bp@suse.de>

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
