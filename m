Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id AEA066B0279
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 12:45:57 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id n7so1711632wrb.0
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 09:45:57 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTP id r23si551587wra.40.2017.06.14.09.45.56
        for <linux-mm@kvack.org>;
        Wed, 14 Jun 2017 09:45:56 -0700 (PDT)
Date: Wed, 14 Jun 2017 18:45:53 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v6 24/34] x86, swiotlb: Add memory encryption support
Message-ID: <20170614164553.jwcfgugpizz5pc2e@pd.tnic>
References: <20170607191309.28645.15241.stgit@tlendack-t1.amdoffice.net>
 <20170607191721.28645.96519.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20170607191721.28645.96519.stgit@tlendack-t1.amdoffice.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Wed, Jun 07, 2017 at 02:17:21PM -0500, Tom Lendacky wrote:
> Since DMA addresses will effectively look like 48-bit addresses when the
> memory encryption mask is set, SWIOTLB is needed if the DMA mask of the
> device performing the DMA does not support 48-bits. SWIOTLB will be
> initialized to create decrypted bounce buffers for use by these devices.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---

...


> diff --git a/init/main.c b/init/main.c
> index df58a41..7125b5f 100644
> --- a/init/main.c
> +++ b/init/main.c
> @@ -488,6 +488,10 @@ void __init __weak thread_stack_cache_init(void)
>  }
>  #endif
>  
> +void __init __weak mem_encrypt_init(void)
> +{
> +}

void __init __weak mem_encrypt_init(void) { }

saves some real estate. Please do that for the rest of the stubs you're
adding, for the next version.

> +
>  /*
>   * Set up kernel memory allocators
>   */
> @@ -640,6 +644,15 @@ asmlinkage __visible void __init start_kernel(void)
>  	 */
>  	locking_selftest();
>  
> +	/*
> +	 * This needs to be called before any devices perform DMA
> +	 * operations that might use the SWIOTLB bounce buffers.
> +	 * This call will mark the bounce buffers as decrypted so
> +	 * that their usage will not cause "plain-text" data to be
> +	 * decrypted when accessed.

s/This call/It/

> +	 */
> +	mem_encrypt_init();
> +
>  #ifdef CONFIG_BLK_DEV_INITRD
>  	if (initrd_start && !initrd_below_start_ok &&
>  	    page_to_pfn(virt_to_page((void *)initrd_start)) < min_low_pfn) {
> diff --git a/lib/swiotlb.c b/lib/swiotlb.c
> index a8d74a7..74d6557 100644
> --- a/lib/swiotlb.c
> +++ b/lib/swiotlb.c
> @@ -30,6 +30,7 @@
>  #include <linux/highmem.h>
>  #include <linux/gfp.h>
>  #include <linux/scatterlist.h>
> +#include <linux/mem_encrypt.h>
>  
>  #include <asm/io.h>
>  #include <asm/dma.h>
> @@ -155,6 +156,17 @@ unsigned long swiotlb_size_or_default(void)
>  	return size ? size : (IO_TLB_DEFAULT_SIZE);
>  }
>  
> +void __weak swiotlb_set_mem_attributes(void *vaddr, unsigned long size)
> +{
> +}

As above.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
