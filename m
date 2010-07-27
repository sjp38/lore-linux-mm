Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B78E260080D
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 08:09:01 -0400 (EDT)
Date: Tue, 27 Jul 2010 13:08:41 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCHv2 2/4] mm: cma: Contiguous Memory Allocator added
Message-ID: <20100727120841.GC11468@n2100.arm.linux.org.uk>
References: <cover.1280151963.git.m.nazarewicz@samsung.com> <743102607e2c5fb20e3c0676fadbcb93d501a78e.1280151963.git.m.nazarewicz@samsung.com> <dc4bdf3e0b02c0ac4770927f72b6cbc3f0b486a2.1280151963.git.m.nazarewicz@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <dc4bdf3e0b02c0ac4770927f72b6cbc3f0b486a2.1280151963.git.m.nazarewicz@samsung.com>
Sender: owner-linux-mm@kvack.org
To: Michal Nazarewicz <m.nazarewicz@samsung.com>
Cc: linux-mm@kvack.org, Daniel Walker <dwalker@codeaurora.org>, Jonathan Corbet <corbet@lwn.net>, Pawel Osciak <p.osciak@samsung.com>, Mark Brown <broonie@opensource.wolfsonmicro.com>, linux-kernel@vger.kernel.org, Hiremath Vaibhav <hvaibhav@ti.com>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Kyungmin Park <kyungmin.park@samsung.com>, Zach Pfeffer <zpfeffer@codeaurora.org>, linux-media@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Marek Szyprowski <m.szyprowski@samsung.com>
List-ID: <linux-mm.kvack.org>

On Mon, Jul 26, 2010 at 04:40:30PM +0200, Michal Nazarewicz wrote:
> +** Why is it needed?
> +
> +    Various devices on embedded systems have no scatter-getter and/or
> +    IO map support and as such require contiguous blocks of memory to
> +    operate.  They include devices such as cameras, hardware video
> +    decoders and encoders, etc.

Yes, this is becoming quite a big problem - and many ARM SoCs suffer
from the existing memory allocators being extremely inadequate for
their use.

One of the areas I've been working on is sorting out the DMA coherent
allocator so we don't violate the architecture requirements for ARMv6
and ARMv7 CPUs (which basically prohibits multiple mappings of memory
with different attributes.)

One of the ideas that I've thought about for this is to reserve an
amount of contiguous memory at boot time to fill the entire DMA coherent
mapping, marking the memory in the main kernel memory map as 'no access',
and allocate directly from the DMA coherent region.

However, discussing this with people who have the problem you're trying
to solve indicates that they do not want to set aside an amount of
memory as they perceive this to be a waste of resources.

This concern also applies to 'cma'.

> +/*
> + * Don't call it directly, use cma_alloc(), cma_alloc_from() or
> + * cma_alloc_from_region().
> + */
> +dma_addr_t __must_check
> +__cma_alloc(const struct device *dev, const char *kind,
> +	    size_t size, dma_addr_t alignment);

Does this really always return DMA-able memory (memory which can be
DMA'd to/from without DMA-mapping etc?)

As it returns a dma_addr_t, it's returning a cookie for the memory which
will be suitable for writing directly to the device 'dev' doing the DMA.
(NB: DMA addresses may not be the same as physical addresses, especially
if the device is on a downstream bus.  We have ARM platforms which have
different bus offsets.)

How does one obtain the CPU address of this memory in order for the CPU
to access it?

> +static inline dma_addr_t __must_check
> +cma_alloc(const struct device *dev, const char *kind,
> +	  size_t size, dma_addr_t alignment)
> +{
> +	return dev ? -EINVAL : __cma_alloc(dev, kind, size, alignment);

So I can't use this to allocate memory for anything but a NULL device?

> +static inline int
> +cma_info(struct cma_info *info, const struct device *dev, const char *kind)
> +{
> +	return dev ? -EINVAL : __cma_info(info, dev, kind);

This won't return information for anything but a NULL device?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
