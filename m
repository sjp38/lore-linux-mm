Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id B34A49000BD
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 10:43:05 -0400 (EDT)
Date: Mon, 20 Jun 2011 15:42:47 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH 5/8] ARM: dma-mapping: move all dma bounce code to
	separate dma ops structure
Message-ID: <20110620144247.GF26089@n2100.arm.linux.org.uk>
References: <1308556213-24970-1-git-send-email-m.szyprowski@samsung.com> <1308556213-24970-6-git-send-email-m.szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1308556213-24970-6-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>, Joerg Roedel <joro@8bytes.org>, Arnd Bergmann <arnd@arndb.de>

On Mon, Jun 20, 2011 at 09:50:10AM +0200, Marek Szyprowski wrote:
> This patch removes dma bounce hooks from the common dma mapping
> implementation on ARM architecture and creates a separate set of
> dma_map_ops for dma bounce devices.

Why all this additional indirection for no gain?

> @@ -278,7 +278,7 @@ static inline dma_addr_t map_single(struct device *dev, void *ptr, size_t size,
>  		 * We don't need to sync the DMA buffer since
>  		 * it was allocated via the coherent allocators.
>  		 */
> -		__dma_single_cpu_to_dev(ptr, size, dir);
> +		dma_ops.sync_single_for_device(dev, dma_addr, size, dir);
>  	}
>  
>  	return dma_addr;
> @@ -317,7 +317,7 @@ static inline void unmap_single(struct device *dev, dma_addr_t dma_addr,
>  		}
>  		free_safe_buffer(dev->archdata.dmabounce, buf);
>  	} else {
> -		__dma_single_dev_to_cpu(dma_to_virt(dev, dma_addr), size, dir);
> +		dma_ops.sync_single_for_cpu(dev, dma_addr, size, dir);
>  	}
>  }
>  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
