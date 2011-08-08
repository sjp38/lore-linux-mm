Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 794356B0169
	for <linux-mm@kvack.org>; Mon,  8 Aug 2011 11:05:02 -0400 (EDT)
Received: by mail-vw0-f43.google.com with SMTP id 10so1599312vws.30
        for <linux-mm@kvack.org>; Mon, 08 Aug 2011 08:04:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <000301cc4dc4$31b53630$951fa290$%szyprowski@samsung.com>
References: <CAB-zwWjb+2ExjNDB3OtHmRmgaHMnO-VgEe9VZk_wU=ryrq_AGw@mail.gmail.com>
	<000301cc4dc4$31b53630$951fa290$%szyprowski@samsung.com>
Date: Mon, 8 Aug 2011 10:04:58 -0500
Message-ID: <CAB-zwWhh=ZTvheTebKhz55rr1=WFD8R=+BWZ8mwYiO_25mjpYA@mail.gmail.com>
Subject: Re: [RFC] ARM: dma_map|unmap_sg plus iommu
From: "Ramirez Luna, Omar" <omar.ramirez@ti.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Joerg Roedel <joro@8bytes.org>, Arnd Bergmann <arnd@arndb.de>, Ohad Ben-Cohen <ohad@wizery.com>

Hi,

On Fri, Jul 29, 2011 at 2:50 AM, Marek Szyprowski
<m.szyprowski@samsung.com> wrote:
>> 1. There is no way to keep track of what virtual address are being mappe=
d
>> in the scatterlist, which we need to propagate to the dsp, in order that=
 it
>> knows where does the buffers start and end on its virtual address space.
>> I ended up adding an iov_address to scatterlist which if accepted should=
 be
>> toggled/affected by the selection of CONFIG_IOMMU_API.
>
> Sorry, but your patch is completely wrong. You should not add any additio=
nal
> entries to scatterlist.

At the time it was the easiest way for me to keep track of both
virtual and physical addresses, without doing a page_to_phys every
time on unmap. I understand that it might fall out of the scope of the
scatterlist struct.

> dma_addr IS the virtual address in the device's io
> address space, so the dma_addr is a value that your device should put int=
o
> it's own registers to start dma transfer to provided memory pages.

I also wanted to keep the same part as the original arm_dma_map_sg:

s->dma_address =3D __dma_map_page...

Where the dma_address was the "clean" (from cache) physical address.
But if desired, I guess this value can be replaced for the iommu va.

>> 2. tidspbridge driver sometimes needs to map a physical address into a
>> fixed virtual address (i.e. the start of a firmware section is expected =
to
>> be at dsp va 0x20000000), there is no straight forward way to do this wi=
th
>> the dma api given that it only expects to receive a cpu_addr, a sg or a
>> page, by adding iov_address I could pass phys and iov addresses in a sg
>> and overcome this limitation, but, these addresses belong to:
>
> We also encountered the problem of fixed firmware address. We addressed i=
s by
> setting io address space start to this address and letting device driver =
to
> rely on the fact that the first call to dma_alloc() will match this addre=
ss.

Indeed, however in my case, I need sections at (I might have
approximated the numbers to the real ones):

0x11000000 for dsp shared memory
0x11800000 for peripherals
0x20000000 for dsp external code
0x21000000 for mapped buffers

The end of a section and start of the other usually have a gap, so the
exact address needs to be specified by the firmware. So, this won't
work with just letting the pool manager to provide the virtual
address.

>> =A0 2a. Shared memory between ARM and DSP: this memory is allocated thro=
ugh
>> =A0 =A0 =A0 memblock API which takes it out of kernel control to be late=
r
>> =A0 =A0 =A0 ioremap'd and iommu map'd to the dsp (this because a non-cac=
heable
>> =A0 =A0 =A0 requirement), so, these physical addresses doesn't have a li=
near
>> =A0 =A0 =A0 virtual address translation, which is what dma api expects.
>
> I hope that the issue with page cache attributes can be resolved if we al=
ways
> allocate memory from CMA (see the latest CMAv12 patches:
> http://www.spinics.net/lists/linux-media/msg35674.html )

I'll take a look more closely and will be trying them if possible.

>> =A0 2b. Bus addresses: of dsp peripherals which are also ioremap'd and
>> =A0 =A0 =A0 affected by the same thing.
>
> Right now I have no idea how to handle ioremapped areas in dma-mapping
> framework, but do we really need to support them?

It would be good to know if this is expected to be handled by
dma-mapping, otherwise it can be dealt by iommu api as Joerg pointed
out.

Thanks for your comments,

Omar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
