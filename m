Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id EFB056B0038
	for <linux-mm@kvack.org>; Tue, 16 May 2017 13:35:52 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id g67so24429211wrd.0
        for <linux-mm@kvack.org>; Tue, 16 May 2017 10:35:52 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTP id y16si2567089wry.218.2017.05.16.10.35.51
        for <linux-mm@kvack.org>;
        Tue, 16 May 2017 10:35:51 -0700 (PDT)
Date: Tue, 16 May 2017 19:35:41 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v5 26/32] x86, drm, fbdev: Do not specify encrypted
 memory for video mappings
Message-ID: <20170516173541.q2rbh5dhkluzsjae@pd.tnic>
References: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
 <20170418212056.10190.25468.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20170418212056.10190.25468.stgit@tlendack-t1.amdoffice.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Tue, Apr 18, 2017 at 04:20:56PM -0500, Tom Lendacky wrote:
> Since video memory needs to be accessed decrypted, be sure that the
> memory encryption mask is not set for the video ranges.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---
>  arch/x86/include/asm/vga.h       |   13 +++++++++++++
>  arch/x86/mm/pageattr.c           |    2 ++
>  drivers/gpu/drm/drm_gem.c        |    2 ++
>  drivers/gpu/drm/drm_vm.c         |    4 ++++
>  drivers/gpu/drm/ttm/ttm_bo_vm.c  |    7 +++++--
>  drivers/gpu/drm/udl/udl_fb.c     |    4 ++++
>  drivers/video/fbdev/core/fbmem.c |   12 ++++++++++++
>  7 files changed, 42 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/x86/include/asm/vga.h b/arch/x86/include/asm/vga.h
> index c4b9dc2..5c7567a 100644
> --- a/arch/x86/include/asm/vga.h
> +++ b/arch/x86/include/asm/vga.h
> @@ -7,12 +7,25 @@
>  #ifndef _ASM_X86_VGA_H
>  #define _ASM_X86_VGA_H
>  
> +#include <asm/cacheflush.h>
> +
>  /*
>   *	On the PC, we can just recalculate addresses and then
>   *	access the videoram directly without any black magic.
> + *	To support memory encryption however, we need to access
> + *	the videoram as decrypted memory.
>   */
>  
> +#ifdef CONFIG_AMD_MEM_ENCRYPT
> +#define VGA_MAP_MEM(x, s)					\
> +({								\
> +	unsigned long start = (unsigned long)phys_to_virt(x);	\
> +	set_memory_decrypted(start, (s) >> PAGE_SHIFT);		\
> +	start;							\
> +})
> +#else
>  #define VGA_MAP_MEM(x, s) (unsigned long)phys_to_virt(x)
> +#endif

Can we push the check in and save us the ifdeffery?

#define VGA_MAP_MEM(x, s)                                       \
({                                                              \
        unsigned long start = (unsigned long)phys_to_virt(x);   \
                                                                \
        if (IS_ENABLED(CONFIG_AMD_MEM_ENCRYPT))                 \
                set_memory_decrypted(start, (s) >> PAGE_SHIFT); \
                                                                \
        start;                                                  \
})

It does build here. :)

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
