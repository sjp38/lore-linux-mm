Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 94C986B02A8
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 05:03:32 -0400 (EDT)
Date: Tue, 13 Jul 2010 10:02:23 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [RFC 3/3] mm: iommu: The Virtual Contiguous Memory Manager
Message-ID: <20100713090223.GB20590@n2100.arm.linux.org.uk>
References: <20100713092012.7c1fe53e@lxorguk.ukuu.org.uk> <20100713173028M.fujita.tomonori@lab.ntt.co.jp> <20100713094244.7eb84f1b@lxorguk.ukuu.org.uk> <20100713174519D.fujita.tomonori@lab.ntt.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100713174519D.fujita.tomonori@lab.ntt.co.jp>
Sender: owner-linux-mm@kvack.org
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc: alan@lxorguk.ukuu.org.uk, randy.dunlap@oracle.com, dwalker@codeaurora.org, mel@csn.ul.ie, linux-arm-msm@vger.kernel.org, joro@8bytes.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, andi@firstfloor.org, zpfeffer@codeaurora.org, linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 13, 2010 at 05:45:39PM +0900, FUJITA Tomonori wrote:
> Drivers can tell the USB layer that these are vmapped buffers? Adding
> something to struct urb? I might be totally wrong since I don't know
> anything about the USB layer.

With non-DMA coherent aliasing caches, you need to know where the page
is mapped into the virtual address space, so you can deal with aliases.

You'd need to tell the USB layer about the other mappings of the page
which you'd like to be coherent (such as the vmalloc area - and there's
also the possible userspace mapping to think about too, but that's
a separate issue.)

I wonder if we should have had:

	vmalloc_prepare_dma(void *, size_t, enum dma_direction)
	vmalloc_finish_dma(void *, size_t, enum dma_direction)

rather than flush_kernel_vmap_range and invalidate_kernel_vmap_range,
which'd make their use entirely obvious.

However, this brings up a question - how does the driver (eg, v4l, xfs)
which is preparing the buffer for another driver (eg, usb host, block
dev) know that DMA will be performed on the buffer rather than PIO?

That's a very relevant question, because for speculatively prefetching
CPUs, we need to invalidate caches after a DMA-from-device operation -
but if PIO-from-device happened, this would destroy data read from the
device.

That problem goes away if we decide that PIO drivers must have the same
apparant semantics as DMA drivers - in that data must end up beyond the
point of DMA coherency (eg, physical page) - but that's been proven to
be very hard to achieve, especially with block device drivers.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
