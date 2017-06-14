Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id A46D96B0279
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 12:50:56 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id s4so1673947wrc.15
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 09:50:56 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTP id k88si517604wmi.131.2017.06.14.09.50.55
        for <linux-mm@kvack.org>;
        Wed, 14 Jun 2017 09:50:55 -0700 (PDT)
Date: Wed, 14 Jun 2017 18:50:52 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v6 25/34] swiotlb: Add warnings for use of bounce buffers
 with SME
Message-ID: <20170614165052.fyn5t4gkq5leczcc@pd.tnic>
References: <20170607191309.28645.15241.stgit@tlendack-t1.amdoffice.net>
 <20170607191732.28645.42876.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20170607191732.28645.42876.stgit@tlendack-t1.amdoffice.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Wed, Jun 07, 2017 at 02:17:32PM -0500, Tom Lendacky wrote:
> Add warnings to let the user know when bounce buffers are being used for
> DMA when SME is active.  Since the bounce buffers are not in encrypted
> memory, these notifications are to allow the user to determine some
> appropriate action - if necessary.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---
>  arch/x86/include/asm/mem_encrypt.h |    8 ++++++++
>  include/asm-generic/mem_encrypt.h  |    5 +++++
>  include/linux/dma-mapping.h        |    9 +++++++++
>  lib/swiotlb.c                      |    3 +++
>  4 files changed, 25 insertions(+)
> 
> diff --git a/arch/x86/include/asm/mem_encrypt.h b/arch/x86/include/asm/mem_encrypt.h
> index f1215a4..c7a2525 100644
> --- a/arch/x86/include/asm/mem_encrypt.h
> +++ b/arch/x86/include/asm/mem_encrypt.h
> @@ -69,6 +69,14 @@ static inline bool sme_active(void)
>  	return !!sme_me_mask;
>  }
>  
> +static inline u64 sme_dma_mask(void)
> +{
> +	if (!sme_me_mask)
> +		return 0ULL;
> +
> +	return ((u64)sme_me_mask << 1) - 1;
> +}
> +
>  /*
>   * The __sme_pa() and __sme_pa_nodebug() macros are meant for use when
>   * writing to or comparing values from the cr3 register.  Having the
> diff --git a/include/asm-generic/mem_encrypt.h b/include/asm-generic/mem_encrypt.h
> index b55c3f9..fb02ff0 100644
> --- a/include/asm-generic/mem_encrypt.h
> +++ b/include/asm-generic/mem_encrypt.h
> @@ -22,6 +22,11 @@ static inline bool sme_active(void)
>  	return false;
>  }
>  
> +static inline u64 sme_dma_mask(void)
> +{
> +	return 0ULL;
> +}
> +
>  /*
>   * The __sme_set() and __sme_clr() macros are useful for adding or removing
>   * the encryption mask from a value (e.g. when dealing with pagetable
> diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
> index 4f3eece..e2c5fda 100644
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
> @@ -577,6 +578,10 @@ static inline int dma_set_mask(struct device *dev, u64 mask)
>  
>  	if (!dev->dma_mask || !dma_supported(dev, mask))
>  		return -EIO;
> +
> +	if (sme_active() && (mask < sme_dma_mask()))
> +		dev_warn(dev, "SME is active, device will require DMA bounce buffers\n");

Something looks strange here:

you're checking sme_active() before calling sme_dma_mask() and yet in
it, you're checking !sme_me_mask again. What gives?

Why not move the sme_active() check into sme_dma_mask() and thus
simplify callers?

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
