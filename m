Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 5E8BA6B002D
	for <linux-mm@kvack.org>; Tue,  8 Nov 2011 12:55:53 -0500 (EST)
Date: Tue, 8 Nov 2011 17:55:17 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [RFC 1/2] dma-buf: Introduce dma buffer sharing mechanismch
Message-ID: <20111108175517.GG12913@n2100.arm.linux.org.uk>
References: <1318325033-32688-1-git-send-email-sumit.semwal@ti.com> <1318325033-32688-2-git-send-email-sumit.semwal@ti.com> <4E98085A.8080803@samsung.com> <20111014152139.GA2908@phenom.ffwll.local> <000001cc99ff$47cfe960$d76fbc20$%szyprowski@samsung.com> <CAO8GWqnNMGwADVnO4-RfJu0TPzHhANBdyctv2RyhCxbBJ0beXw@mail.gmail.com> <20111108174122.GA4754@phenom.ffwll.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111108174122.GA4754@phenom.ffwll.local>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Vetter <daniel@ffwll.ch>
Cc: "Clark, Rob" <rob@ti.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Tomasz Stanislawski <t.stanislaws@samsung.com>, Sumit Semwal <sumit.semwal@ti.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, dri-devel@lists.freedesktop.org, linux-media@vger.kernel.org, arnd@arndb.de, jesse.barker@linaro.org, Sumit Semwal <sumit.semwal@linaro.org>

On Tue, Nov 08, 2011 at 06:42:27PM +0100, Daniel Vetter wrote:
> Actually I think the importer should get a _mapped_ scatterlist when it
> calls get_scatterlist. The simple reason is that for strange stuff like
> memory remapped into e.g. omaps TILER doesn't have any sensible notion of
> an address in physical memory. For the USB-example I think the right
> approach is to attach the usb hci to the dma_buf, after all that is the
> device that will read the data and move over the usb bus to the udl
> device. Similar for any other device that sits behind a bus that can't do
> dma (or it doesn't make sense to do dma).
> 
> Imo if there's a use-case where the client needs to frob the sg_list
> before calling dma_map_sg, we have an issue with the dma subsystem in
> general.

Let's clear something up about the DMA API, which I think is causing some
misunderstanding here.  For this purpose, I'm going to talk about
dma_map_single(), but the same applies to the scatterlist and _page
variants as well.

	dma = dma_map_single(dev, cpuaddr, size, dir);

dev := the device _performing_ the DMA operation.  You are quite correct
       that in the case of a USB peripheral device, the device is normally
       the USB HCI device.

dma := dma address to be programmed into 'dev' which corresponds (by some
       means) with 'cpuaddr'.  This may not be the physical address due
       to bus offset translations or mappings setup in IOMMUs.

Therefore, it is wrong to talk about a 'physical address' when talking
about the DMA API.

We can take this one step further.  Lets say that the USB HCI is not
capable of performing memory accesses itself, but it is connected to a
separate DMA engine device:

	mem <---> dma engine <---> usb hci <---> usb peripheral

(such setups do exist, but despite having such implementations I've never
tried to support it.)

In this case, the dma engine, in response to control signals from the
USB host controller, will generate the appropriate bus address to access
memory and transfer the data into the USB HCI device.

So, in this case, the struct device to be used for mapping memory for
transfers to the usb peripheral is the DMA engine device, not the USB HCI
device nor the USB peripheral device.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
