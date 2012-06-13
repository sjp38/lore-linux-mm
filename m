Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id BAE5B6B005D
	for <linux-mm@kvack.org>; Wed, 13 Jun 2012 14:44:20 -0400 (EDT)
Received: by wibhr14 with SMTP id hr14so810521wib.8
        for <linux-mm@kvack.org>; Wed, 13 Jun 2012 11:44:19 -0700 (PDT)
Date: Wed, 13 Jun 2012 20:45:49 +0200
From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: [Linaro-mm-sig] [PATCHv2 5/6] common: DMA-mapping: add
 DMA_ATTR_SKIP_CPU_SYNC attribute
Message-ID: <20120613184549.GL4829@phenom.ffwll.local>
References: <1339588218-24398-1-git-send-email-m.szyprowski@samsung.com>
 <1339588218-24398-6-git-send-email-m.szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1339588218-24398-6-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Abhinav Kochhar <abhinav.k@samsung.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Kyungmin Park <kyungmin.park@samsung.com>, Subash Patel <subash.ramaswamy@linaro.org>

On Wed, Jun 13, 2012 at 01:50:17PM +0200, Marek Szyprowski wrote:
> This patch adds DMA_ATTR_SKIP_CPU_SYNC attribute to the DMA-mapping
> subsystem.
> 
> By default dma_map_{single,page,sg} functions family transfer a given
> buffer from CPU domain to device domain. Some advanced use cases might
> require sharing a buffer between more than one device. This requires
> having a mapping created separately for each device and is usually
> performed by calling dma_map_{single,page,sg} function more than once
> for the given buffer with device pointer to each device taking part in
> the buffer sharing. The first call transfers a buffer from 'CPU' domain
> to 'device' domain, what synchronizes CPU caches for the given region
> (usually it means that the cache has been flushed or invalidated
> depending on the dma direction). However, next calls to
> dma_map_{single,page,sg}() for other devices will perform exactly the
> same sychronization operation on the CPU cache. CPU cache sychronization
> might be a time consuming operation, especially if the buffers are
> large, so it is highly recommended to avoid it if possible.
> DMA_ATTR_SKIP_CPU_SYNC allows platform code to skip synchronization of
> the CPU cache for the given buffer assuming that it has been already
> transferred to 'device' domain. This attribute can be also used for
> dma_unmap_{single,page,sg} functions family to force buffer to stay in
> device domain after releasing a mapping for it. Use this attribute with
> care!
> 
> Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> Reviewed-by: Kyungmin Park <kyungmin.park@samsung.com>

Curious question: What's the use-case for this? Is this just to
work-around the fact that dma-buf atm doesn't support streaming dma so
that we could optimize this all (and keep around the mappings)? Or is
there a different use-case that I don't see?
-Daniel

> ---
>  Documentation/DMA-attributes.txt |   24 ++++++++++++++++++++++++
>  include/linux/dma-attrs.h        |    1 +
>  2 files changed, 25 insertions(+), 0 deletions(-)
> 
> diff --git a/Documentation/DMA-attributes.txt b/Documentation/DMA-attributes.txt
> index 725580d..f503090 100644
> --- a/Documentation/DMA-attributes.txt
> +++ b/Documentation/DMA-attributes.txt
> @@ -67,3 +67,27 @@ set on each call.
>  Since it is optional for platforms to implement
>  DMA_ATTR_NO_KERNEL_MAPPING, those that do not will simply ignore the
>  attribute and exhibit default behavior.
> +
> +DMA_ATTR_SKIP_CPU_SYNC
> +----------------------
> +
> +By default dma_map_{single,page,sg} functions family transfer a given
> +buffer from CPU domain to device domain. Some advanced use cases might
> +require sharing a buffer between more than one device. This requires
> +having a mapping created separately for each device and is usually
> +performed by calling dma_map_{single,page,sg} function more than once
> +for the given buffer with device pointer to each device taking part in
> +the buffer sharing. The first call transfers a buffer from 'CPU' domain
> +to 'device' domain, what synchronizes CPU caches for the given region
> +(usually it means that the cache has been flushed or invalidated
> +depending on the dma direction). However, next calls to
> +dma_map_{single,page,sg}() for other devices will perform exactly the
> +same sychronization operation on the CPU cache. CPU cache sychronization
> +might be a time consuming operation, especially if the buffers are
> +large, so it is highly recommended to avoid it if possible.
> +DMA_ATTR_SKIP_CPU_SYNC allows platform code to skip synchronization of
> +the CPU cache for the given buffer assuming that it has been already
> +transferred to 'device' domain. This attribute can be also used for
> +dma_unmap_{single,page,sg} functions family to force buffer to stay in
> +device domain after releasing a mapping for it. Use this attribute with
> +care!
> diff --git a/include/linux/dma-attrs.h b/include/linux/dma-attrs.h
> index a37c10c..f83f793 100644
> --- a/include/linux/dma-attrs.h
> +++ b/include/linux/dma-attrs.h
> @@ -16,6 +16,7 @@ enum dma_attr {
>  	DMA_ATTR_WRITE_COMBINE,
>  	DMA_ATTR_NON_CONSISTENT,
>  	DMA_ATTR_NO_KERNEL_MAPPING,
> +	DMA_ATTR_SKIP_CPU_SYNC,
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
