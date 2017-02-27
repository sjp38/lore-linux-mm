Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6B0C26B0038
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 12:53:36 -0500 (EST)
Received: by mail-lf0-f69.google.com with SMTP id a6so3176713lfa.1
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 09:53:36 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTP id n192si9224821lfn.1.2017.02.27.09.53.34
        for <linux-mm@kvack.org>;
        Mon, 27 Feb 2017 09:53:34 -0800 (PST)
Date: Mon, 27 Feb 2017 18:52:59 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [RFC PATCH v4 19/28] swiotlb: Add warnings for use of bounce
 buffers with SME
Message-ID: <20170227175259.whl75utazbzxp7jo@pd.tnic>
References: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
 <20170216154619.19244.76653.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20170216154619.19244.76653.stgit@tlendack-t1.amdoffice.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Larry Woodman <lwoodman@redhat.com>, Dmitry Vyukov <dvyukov@google.com>

On Thu, Feb 16, 2017 at 09:46:19AM -0600, Tom Lendacky wrote:
> Add warnings to let the user know when bounce buffers are being used for
> DMA when SME is active.  Since the bounce buffers are not in encrypted
> memory, these notifications are to allow the user to determine some
> appropriate action - if necessary.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---
>  arch/x86/include/asm/mem_encrypt.h |   11 +++++++++++
>  include/linux/dma-mapping.h        |   11 +++++++++++
>  include/linux/mem_encrypt.h        |    6 ++++++
>  lib/swiotlb.c                      |    3 +++
>  4 files changed, 31 insertions(+)
> 
> diff --git a/arch/x86/include/asm/mem_encrypt.h b/arch/x86/include/asm/mem_encrypt.h
> index 87e816f..5a17f1b 100644
> --- a/arch/x86/include/asm/mem_encrypt.h
> +++ b/arch/x86/include/asm/mem_encrypt.h
> @@ -26,6 +26,11 @@ static inline bool sme_active(void)
>  	return (sme_me_mask) ? true : false;
>  }
>  
> +static inline u64 sme_dma_mask(void)
> +{
> +	return ((u64)sme_me_mask << 1) - 1;
> +}
> +
>  void __init sme_early_encrypt(resource_size_t paddr,
>  			      unsigned long size);
>  void __init sme_early_decrypt(resource_size_t paddr,
> @@ -53,6 +58,12 @@ static inline bool sme_active(void)
>  {
>  	return false;
>  }
> +
> +static inline u64 sme_dma_mask(void)
> +{
> +	return 0ULL;
> +}
> +
>  #endif
>  
>  static inline void __init sme_early_encrypt(resource_size_t paddr,
> diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
> index 10c5a17..130bef7 100644
> --- a/include/linux/dma-mapping.h
> +++ b/include/linux/dma-mapping.h
> @@ -10,6 +10,7 @@
>  #include <linux/scatterlist.h>
>  #include <linux/kmemcheck.h>
>  #include <linux/bug.h>
> +#include <linux/mem_encrypt.h>
>  
>  /**
>   * List of possible attributes associated with a DMA mapping. The semantics
> @@ -557,6 +558,11 @@ static inline int dma_set_mask(struct device *dev, u64 mask)
>  
>  	if (!dev->dma_mask || !dma_supported(dev, mask))
>  		return -EIO;
> +
> +	if (sme_active() && (mask < sme_dma_mask()))
> +		dev_warn(dev,
> +			 "SME is active, device will require DMA bounce buffers\n");
> +

Yes, definitely _once() here.

It could be extended later to be per-device if the need arises.

Also, a bit above in this function, we test if (ops->set_dma_mask) so
device drivers which supply even an empty ->set_dma_mask will circumvent
this check.

It probably doesn't matter all that much right now because the
only driver I see right now defining this method, though, is
ethernet/intel/fm10k/fm10k_pf.c and some other arches' functionality
which is unrelated here.

But still...


-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
