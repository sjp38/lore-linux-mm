Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 3A7496B0254
	for <linux-mm@kvack.org>; Fri, 25 Sep 2015 08:45:02 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so17956871wic.0
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 05:45:01 -0700 (PDT)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id p10si4475172wiv.26.2015.09.25.05.45.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 25 Sep 2015 05:45:01 -0700 (PDT)
Date: Fri, 25 Sep 2015 13:44:47 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH 4/4] dma-debug: Allow poisoning nonzero allocations
Message-ID: <20150925124447.GO21513@n2100.arm.linux.org.uk>
References: <cover.1443178314.git.robin.murphy@arm.com>
 <0405c6131def5aa179ff4ba5d4201ebde89cede3.1443178314.git.robin.murphy@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0405c6131def5aa179ff4ba5d4201ebde89cede3.1443178314.git.robin.murphy@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robin Murphy <robin.murphy@arm.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, arnd@arndb.de, linux-mm@kvack.org, sakari.ailus@iki.fi, sumit.semwal@linaro.org, linux-arm-kernel@lists.infradead.org, m.szyprowski@samsung.com

On Fri, Sep 25, 2015 at 01:15:46PM +0100, Robin Murphy wrote:
> Since some dma_alloc_coherent implementations return a zeroed buffer
> regardless of whether __GFP_ZERO is passed, there exist drivers which
> are implicitly dependent on this and pass otherwise uninitialised
> buffers to hardware. This can lead to subtle and awkward-to-debug issues
> using those drivers on different platforms, where nonzero uninitialised
> junk may for instance occasionally look like a valid command which
> causes the hardware to start misbehaving. To help with debugging such
> issues, add the option to make uninitialised buffers much more obvious.

The reason people started to do this is to stop a security leak in the
ALSA code: ALSA allocates the ring buffer with dma_alloc_coherent()
which used to grab pages and return them uninitialised.  These pages
could contain anything - including the contents of /etc/shadow, or
your bank details.

ALSA then lets userspace mmap() that memory, which means any user process
which has access to the sound devices can read data leaked from kernel
memory.

I think I did bring it up at the time I found it, and decided that the
safest thing to do was to always return an initialised buffer - short of
constantly auditing every dma_alloc_coherent() user which also mmap()s
the buffer into userspace, I couldn't convince myself that it was safe
to avoid initialising the buffer.

I don't know whether the original problem still exists in ALSA or not,
but I do know that there are dma_alloc_coherent() implementations out
there which do not initialise prior to returning memory.

> diff --git a/lib/dma-debug.c b/lib/dma-debug.c
> index 908fb35..40514ed 100644
> --- a/lib/dma-debug.c
> +++ b/lib/dma-debug.c
> @@ -30,6 +30,7 @@
>  #include <linux/sched.h>
>  #include <linux/ctype.h>
>  #include <linux/list.h>
> +#include <linux/poison.h>
>  #include <linux/slab.h>
>  
>  #include <asm/sections.h>
> @@ -1447,7 +1448,7 @@ void debug_dma_unmap_sg(struct device *dev, struct scatterlist *sglist,
>  EXPORT_SYMBOL(debug_dma_unmap_sg);
>  
>  void debug_dma_alloc_coherent(struct device *dev, size_t size,
> -			      dma_addr_t dma_addr, void *virt)
> +			      dma_addr_t dma_addr, void *virt, gfp_t flags)
>  {
>  	struct dma_debug_entry *entry;
>  
> @@ -1457,6 +1458,9 @@ void debug_dma_alloc_coherent(struct device *dev, size_t size,
>  	if (unlikely(virt == NULL))
>  		return;
>  
> +	if (IS_ENABLED(CONFIG_DMA_API_DEBUG_POISON) && !(flags & __GFP_ZERO))
> +		memset(virt, DMA_ALLOC_POISON, size);
> +

This is likely to be slow in the case of non-cached memory and large
allocations.  The config option should come with a warning.

-- 
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
