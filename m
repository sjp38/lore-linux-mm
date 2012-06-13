Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 1C0086B005D
	for <linux-mm@kvack.org>; Wed, 13 Jun 2012 14:50:33 -0400 (EDT)
Received: by wgbdt14 with SMTP id dt14so851559wgb.26
        for <linux-mm@kvack.org>; Wed, 13 Jun 2012 11:50:31 -0700 (PDT)
Date: Wed, 13 Jun 2012 20:52:02 +0200
From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: [Linaro-mm-sig] [PATCHv2 1/6] common: DMA-mapping: add
 DMA_ATTR_NO_KERNEL_MAPPING attribute
Message-ID: <20120613185202.GM4829@phenom.ffwll.local>
References: <1339588218-24398-1-git-send-email-m.szyprowski@samsung.com>
 <1339588218-24398-2-git-send-email-m.szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1339588218-24398-2-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Abhinav Kochhar <abhinav.k@samsung.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Kyungmin Park <kyungmin.park@samsung.com>, Subash Patel <subash.ramaswamy@linaro.org>

On Wed, Jun 13, 2012 at 01:50:13PM +0200, Marek Szyprowski wrote:
> This patch adds DMA_ATTR_NO_KERNEL_MAPPING attribute which lets the
> platform to avoid creating a kernel virtual mapping for the allocated
> buffer. On some architectures creating such mapping is non-trivial task
> and consumes very limited resources (like kernel virtual address space
> or dma consistent address space). Buffers allocated with this attribute
> can be only passed to user space by calling dma_mmap_attrs().
> 
> Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> Reviewed-by: Kyungmin Park <kyungmin.park@samsung.com>

Looks like a nice little extension to support dma-buf for the common case,
so:

Reviewed-by: Daniel Vetter <daniel.vetter@ffwll.ch>

One question is whether we should go right ahead and add kmap support for
this, too (with a default implementation that simply returns a pointer to
the coherent&contigous dma mem), but I guess that can wait until a
use-case pops up.
-Daniel

> ---
>  Documentation/DMA-attributes.txt |   18 ++++++++++++++++++
>  include/linux/dma-attrs.h        |    1 +
>  2 files changed, 19 insertions(+), 0 deletions(-)
> 
> diff --git a/Documentation/DMA-attributes.txt b/Documentation/DMA-attributes.txt
> index 5c72eed..725580d 100644
> --- a/Documentation/DMA-attributes.txt
> +++ b/Documentation/DMA-attributes.txt
> @@ -49,3 +49,21 @@ DMA_ATTR_NON_CONSISTENT lets the platform to choose to return either
>  consistent or non-consistent memory as it sees fit.  By using this API,
>  you are guaranteeing to the platform that you have all the correct and
>  necessary sync points for this memory in the driver.
> +
> +DMA_ATTR_NO_KERNEL_MAPPING
> +--------------------------
> +
> +DMA_ATTR_NO_KERNEL_MAPPING lets the platform to avoid creating a kernel
> +virtual mapping for the allocated buffer. On some architectures creating
> +such mapping is non-trivial task and consumes very limited resources
> +(like kernel virtual address space or dma consistent address space).
> +Buffers allocated with this attribute can be only passed to user space
> +by calling dma_mmap_attrs(). By using this API, you are guaranteeing
> +that you won't dereference the pointer returned by dma_alloc_attr(). You
> +can threat it as a cookie that must be passed to dma_mmap_attrs() and
> +dma_free_attrs(). Make sure that both of these also get this attribute
> +set on each call.
> +
> +Since it is optional for platforms to implement
> +DMA_ATTR_NO_KERNEL_MAPPING, those that do not will simply ignore the
> +attribute and exhibit default behavior.
> diff --git a/include/linux/dma-attrs.h b/include/linux/dma-attrs.h
> index 547ab56..a37c10c 100644
> --- a/include/linux/dma-attrs.h
> +++ b/include/linux/dma-attrs.h
> @@ -15,6 +15,7 @@ enum dma_attr {
>  	DMA_ATTR_WEAK_ORDERING,
>  	DMA_ATTR_WRITE_COMBINE,
>  	DMA_ATTR_NON_CONSISTENT,
> +	DMA_ATTR_NO_KERNEL_MAPPING,
>  	DMA_ATTR_MAX,
>  };
>  
> -- 
> 1.7.1.569.g6f426
> 
> 
> _______________________________________________
> Linaro-mm-sig mailing list
> Linaro-mm-sig@lists.linaro.org
> http://lists.linaro.org/mailman/listinfo/linaro-mm-sig

-- 
Daniel Vetter
Mail: daniel@ffwll.ch
Mobile: +41 (0)79 365 57 48

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
