Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1024D6B03D8
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 06:50:44 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id 77so15688436wrb.11
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 03:50:44 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTP id i195si16721613wme.186.2017.06.21.03.50.42
        for <linux-mm@kvack.org>;
        Wed, 21 Jun 2017 03:50:42 -0700 (PDT)
Date: Wed, 21 Jun 2017 12:50:26 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v7 25/36] swiotlb: Add warnings for use of bounce buffers
 with SME
Message-ID: <20170621105026.lcbtkklaenyi2wqe@pd.tnic>
References: <20170616184947.18967.84890.stgit@tlendack-t1.amdoffice.net>
 <20170616185435.18967.26665.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20170616185435.18967.26665.stgit@tlendack-t1.amdoffice.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, xen-devel@lists.xen.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Brijesh Singh <brijesh.singh@amd.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Matt Fleming <matt@codeblueprint.co.uk>, Alexander Potapenko <glider@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Larry Woodman <lwoodman@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, "Michael S. Tsirkin" <mst@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dave Young <dyoung@redhat.com>, Rik van Riel <riel@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dmitry Vyukov <dvyukov@google.com>, Juergen Gross <jgross@suse.com>, Thomas Gleixner <tglx@linutronix.de>, Paolo Bonzini <pbonzini@redhat.com>

On Fri, Jun 16, 2017 at 01:54:36PM -0500, Tom Lendacky wrote:
> Add warnings to let the user know when bounce buffers are being used for
> DMA when SME is active.  Since the bounce buffers are not in encrypted
> memory, these notifications are to allow the user to determine some
> appropriate action - if necessary.  Actions can range from utilizing an
> IOMMU, replacing the device with another device that can support 64-bit
> DMA, ignoring the message if the device isn't used much, etc.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---
>  include/linux/dma-mapping.h |   11 +++++++++++
>  include/linux/mem_encrypt.h |    8 ++++++++
>  lib/swiotlb.c               |    3 +++
>  3 files changed, 22 insertions(+)
> 
> diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
> index 4f3eece..ee2307e 100644
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
> @@ -577,6 +578,11 @@ static inline int dma_set_mask(struct device *dev, u64 mask)
>  
>  	if (!dev->dma_mask || !dma_supported(dev, mask))
>  		return -EIO;
> +
> +	/* Since mask is unsigned, this can only be true if SME is active */
> +	if (mask < sme_dma_mask())
> +		dev_warn(dev, "SME is active, device will require DMA bounce buffers\n");
> +
>  	*dev->dma_mask = mask;
>  	return 0;
>  }
> @@ -596,6 +602,11 @@ static inline int dma_set_coherent_mask(struct device *dev, u64 mask)
>  {
>  	if (!dma_supported(dev, mask))
>  		return -EIO;
> +
> +	/* Since mask is unsigned, this can only be true if SME is active */
> +	if (mask < sme_dma_mask())
> +		dev_warn(dev, "SME is active, device will require DMA bounce buffers\n");

Looks to me like those two checks above need to be a:

void sme_check_mask(struct device *dev, u64 mask)
{
        if (!sme_me_mask)
                return;

        /* Since mask is unsigned, this can only be true if SME is active */
        if (mask < (((u64)sme_me_mask << 1) - 1))
                dev_warn(dev, "SME is active, device will require DMA bounce buffers\n");
}

which gets called and sme_dma_mask() is not really needed.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
