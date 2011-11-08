Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2AEBF6B002D
	for <linux-mm@kvack.org>; Tue,  8 Nov 2011 12:41:32 -0500 (EST)
Received: by wyg24 with SMTP id 24so1011856wyg.14
        for <linux-mm@kvack.org>; Tue, 08 Nov 2011 09:41:28 -0800 (PST)
Date: Tue, 8 Nov 2011 18:42:27 +0100
From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: [RFC 1/2] dma-buf: Introduce dma buffer sharing mechanismch
Message-ID: <20111108174122.GA4754@phenom.ffwll.local>
References: <1318325033-32688-1-git-send-email-sumit.semwal@ti.com>
 <1318325033-32688-2-git-send-email-sumit.semwal@ti.com>
 <4E98085A.8080803@samsung.com>
 <20111014152139.GA2908@phenom.ffwll.local>
 <000001cc99ff$47cfe960$d76fbc20$%szyprowski@samsung.com>
 <CAO8GWqnNMGwADVnO4-RfJu0TPzHhANBdyctv2RyhCxbBJ0beXw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAO8GWqnNMGwADVnO4-RfJu0TPzHhANBdyctv2RyhCxbBJ0beXw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Clark, Rob" <rob@ti.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Daniel Vetter <daniel@ffwll.ch>, Tomasz Stanislawski <t.stanislaws@samsung.com>, Sumit Semwal <sumit.semwal@ti.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, dri-devel@lists.freedesktop.org, linux-media@vger.kernel.org, linux@arm.linux.org.uk, arnd@arndb.de, jesse.barker@linaro.org, Sumit Semwal <sumit.semwal@linaro.org>

On Tue, Nov 08, 2011 at 10:59:56AM -0600, Clark, Rob wrote:
> On Thu, Nov 3, 2011 at 3:04 AM, Marek Szyprowski
> > 2. dma-mapping api is very limited in the area of the dynamic buffer management,
> > this API has been designed definitely for static buffer allocation and mapping.
> >
> > It looks that fully dynamic buffer management requires a complete change of
> > v4l2 api principles (V4L3?) and a completely new DMA API interface. That's
> > probably the reason by none of the GPU driver relies on the DMA-mapping API
> > and implements custom solution for managing the mappings.
> >
> > This reminds me one more issue I've noticed in the current dma buf proof-of-
> > concept. You assumed that the exporter will be responsible for mapping the
> > buffer into io address space of all the client devices. What if the device
> > needs additional custom hooks/hacks during the mappings? This will be a serious
> > problem for the current GPU drivers for example. IMHO the API will be much
> > clearer if each client driver will map the scatter list gathered from the
> > dma buf by itself. Only the client driver has the complete knowledge how
> > to do this correctly for this particular device. This way it will also work
> > with devices that don't do the real DMA (like for example USB devices that
> > copy all data from usb packets to the target buffer with the cpu).
> 
> The exporter doesn't map.. it returns a scatterlist to the importer.
> But the exporter does allocate and pin backing pages.  And it is
> preferable if the exporter has the opportunity to wait until as much
> is known about the various importing devices to know if it must
> allocate contiguous pages, or pages in a certain range.

Actually I think the importer should get a _mapped_ scatterlist when it
calls get_scatterlist. The simple reason is that for strange stuff like
memory remapped into e.g. omaps TILER doesn't have any sensible notion of
an address in physical memory. For the USB-example I think the right
approach is to attach the usb hci to the dma_buf, after all that is the
device that will read the data and move over the usb bus to the udl
device. Similar for any other device that sits behind a bus that can't do
dma (or it doesn't make sense to do dma).

Imo if there's a use-case where the client needs to frob the sg_list
before calling dma_map_sg, we have an issue with the dma subsystem in
general.

> That said, on a platform where everything had iommu's or somehow
> didn't have any particular memory requirements, or where the exporter
> had the strictest requirements (or at least knew of the strictest
> requirements), then the exporter is free to allocate/pin the backing
> pages earlier, such as even before the buffer is exported.

Yeah, I think the important thing is that the dma_buf api should allow
decent buffer management. If certain subsystems ignore that and just
allocate up-front, no problem for me. But given how all graphics drivers
for essentially all OS have moved to dynamic buffer management, I expect
decoders, encoders, v4l devices and whatever else might sit in a graphics
pipeline to follow.

Yours, Daniel
-- 
Daniel Vetter
Mail: daniel@ffwll.ch
Mobile: +41 (0)79 365 57 48

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
