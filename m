Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id D62A16B002D
	for <linux-mm@kvack.org>; Tue,  8 Nov 2011 11:59:59 -0500 (EST)
Received: by mail-qw0-f41.google.com with SMTP id c11so621346qad.7
        for <linux-mm@kvack.org>; Tue, 08 Nov 2011 08:59:56 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <000001cc99ff$47cfe960$d76fbc20$%szyprowski@samsung.com>
References: <1318325033-32688-1-git-send-email-sumit.semwal@ti.com>
	<1318325033-32688-2-git-send-email-sumit.semwal@ti.com>
	<4E98085A.8080803@samsung.com>
	<20111014152139.GA2908@phenom.ffwll.local>
	<000001cc99ff$47cfe960$d76fbc20$%szyprowski@samsung.com>
Date: Tue, 8 Nov 2011 10:59:56 -0600
Message-ID: <CAO8GWqnNMGwADVnO4-RfJu0TPzHhANBdyctv2RyhCxbBJ0beXw@mail.gmail.com>
Subject: Re: [RFC 1/2] dma-buf: Introduce dma buffer sharing mechanism
From: "Clark, Rob" <rob@ti.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Daniel Vetter <daniel@ffwll.ch>, Tomasz Stanislawski <t.stanislaws@samsung.com>, Sumit Semwal <sumit.semwal@ti.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, dri-devel@lists.freedesktop.org, linux-media@vger.kernel.org, linux@arm.linux.org.uk, arnd@arndb.de, jesse.barker@linaro.org, Sumit Semwal <sumit.semwal@linaro.org>

On Thu, Nov 3, 2011 at 3:04 AM, Marek Szyprowski
<m.szyprowski@samsung.com> wrote:
> Hello,
>
> I'm sorry for a late reply, but after Kernel Summit/ELC I have some comme=
nts.
>
> On Friday, October 14, 2011 5:35 PM Daniel Vetter wrote:
>
>> On Fri, Oct 14, 2011 at 12:00:58PM +0200, Tomasz Stanislawski wrote:
>> > >+/**
>> > >+ * struct dma_buf_ops - operations possible on struct dma_buf
>> > >+ * @create: creates a struct dma_buf of a fixed size. Actual allocat=
ion
>> > >+ * =A0 =A0 =A0 =A0 =A0 =A0does not happen here.
>> >
>> > The 'create' ops is not present in dma_buf_ops.
>> >
>> > >+ * @attach: allows different devices to 'attach' themselves to the g=
iven
>> > >+ * =A0 =A0 =A0 =A0 =A0 =A0buffer. It might return -EBUSY to signal t=
hat backing storage
>> > >+ * =A0 =A0 =A0 =A0 =A0 =A0is already allocated and incompatible with=
 the requirements
>> > >+ * =A0 =A0 =A0 =A0 =A0 =A0of requesting device. [optional]
>> > >+ * @detach: detach a given device from this buffer. [optional]
>> > >+ * @get_scatterlist: returns list of scatter pages allocated, increa=
ses
>> > >+ * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 usecount of the buffer. R=
equires atleast one attach to be
>> > >+ * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 called before. Returned s=
g list should already be mapped
>> > >+ * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 into _device_ address spa=
ce.
>> >
>> > You must add a comment that this call 'may sleep'.
>> >
>> > I like the get_scatterlist idea. It allows the exported to create a
>> > valid scatterlist for a client in a elegant way.
>> >
>> > I do not like this whole attachment idea. The problem is that
>> > currently there is no support in DMA framework for allocation for
>> > multiple devices. As long as no such a support exists, there is no
>> > generic way to handle attribute negotiations and buffer allocations
>> > that involve multiple devices. So the exporter drivers would have to
>> > implement more or less hacky solutions to handle memory requirements
>> > and choosing the device that allocated memory.
>> >
>> > Currently, AFAIK there is even no generic way for a driver to
>> > acquire its own DMA memory requirements.
>> >
>> > Therefore all logic hidden beneath 'attachment' is pointless. I
>> > think that support for attach/detach (and related stuff) should be
>> > postponed until support for multi-device allocation is added to DMA
>> > framework.
>>
>> Imo we clearly need this to make the multi-device-driver with insane dma
>> requirements work on arm. And rewriting the buffer handling in
>> participating subsystem twice isn't really a great plan. I envision that
>> on platforms where we need this madness, the driver must call back to th=
e
>> dma subsytem to create a dma_buf. The dma subsytem should be already awa=
re
>> of all the requirements and hence should be able to handle them..
>>
>> > I don't say the attachment list idea is wrong but adding attachment
>> > stuff creates an illusion that problem of multi-device allocations
>> > is somehow magically solved. We should not force the developers of
>> > exporter drivers to solve the problem that is not solvable yet.
>>
>> Well, this is why we need to create a decent support infrastructure for
>> platforms (=3D arm madness) that needs this, so that device drivers and
>> subsystem don't need to invent that wheel on their own. Which as you poi=
nt
>> out, they actually can't.
>
> The real question is whether it is possible to create any generic support
> infrastructure. I really doubt. IMHO this is something that will be hacke=
d for
> each 'product release' and will never read the mainline...
>
>> > The other problem are the APIs. For example, the V4L2 subsystem
>> > assumes that memory is allocated after successful VIDIOC_REQBUFS
>> > with V4L2_MEMORY_MMAP memory type. Therefore attach would be
>> > automatically followed by get_scatterlist, blocking possibility of
>> > any buffer migrations in future.
>>
>> Well, pardon to break the news, but v4l needs to rework the buffer
>> handling. If you want to share buffers with a gpu driver, you _have_ to
>> life with the fact that gpus do fully dynamic buffer management, meaning=
:
>> - buffers get allocated and destroyed on the fly, meaning static reqbuf
>> =A0 just went out the window (we obviously cache buffer objects and reus=
e
>> =A0 them for performance, as long as the processing pipeline doesn't rea=
lly
>> =A0 change).
>> - buffers get moved around in memory, meaning you either need full-blown
>> =A0 sync-objects with a callback to drivers to tear-down mappings on-dem=
and,
>> =A0 or every driver needs to guarnatee to call put_scatterlist in a
>> =A0 reasonable short time. The latter is probably the more natural thing=
 for
>> =A0 v4l devices.
>
> I'm really not convinced if it is possible to go for the completely dynam=
ic
> buffer management, especially if we are implementing a proof-of-concept
> solution. Please notice the following facts:
>
> 1. all v4l2 drivers do the 'static' buffer management - memory is being
> allocated on REQBUF() call and then mapped permanently into both userspac=
e
> and dma (io) address space.

Is this strictly true if we are introducing a new 'enum v4l2_memory'
for dmabuf's?  Shouldn't that give us some flexibility, especially if
the v4l2 device is only the importer, not the allocator, of the
memory.

and a couple more notes:
1) for V4L2_MEMORY_DMABUF we don't want the importing v4l2 device to
create a userspace memory mapping
2) there is nothing stopping a dmabuf exporter from being more strict
about static allocation of buffers..  we just want the API to be
flexible enough so that exporting devices which are more dynamic can
continue to do so.

> 2. dma-mapping api is very limited in the area of the dynamic buffer mana=
gement,
> this API has been designed definitely for static buffer allocation and ma=
pping.
>
> It looks that fully dynamic buffer management requires a complete change =
of
> v4l2 api principles (V4L3?) and a completely new DMA API interface. That'=
s
> probably the reason by none of the GPU driver relies on the DMA-mapping A=
PI
> and implements custom solution for managing the mappings.
>
> This reminds me one more issue I've noticed in the current dma buf proof-=
of-
> concept. You assumed that the exporter will be responsible for mapping th=
e
> buffer into io address space of all the client devices. What if the devic=
e
> needs additional custom hooks/hacks during the mappings? This will be a s=
erious
> problem for the current GPU drivers for example. IMHO the API will be muc=
h
> clearer if each client driver will map the scatter list gathered from the
> dma buf by itself. Only the client driver has the complete knowledge how
> to do this correctly for this particular device. This way it will also wo=
rk
> with devices that don't do the real DMA (like for example USB devices tha=
t
> copy all data from usb packets to the target buffer with the cpu).

The exporter doesn't map.. it returns a scatterlist to the importer.
But the exporter does allocate and pin backing pages.  And it is
preferable if the exporter has the opportunity to wait until as much
is known about the various importing devices to know if it must
allocate contiguous pages, or pages in a certain range.

That said, on a platform where everything had iommu's or somehow
didn't have any particular memory requirements, or where the exporter
had the strictest requirements (or at least knew of the strictest
requirements), then the exporter is free to allocate/pin the backing
pages earlier, such as even before the buffer is exported.

BR,
-R

> Best regards
> --
> Marek Szyprowski
> Samsung Poland R&D Center
>
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
