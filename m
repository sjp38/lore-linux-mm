Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 365486B01FF
	for <linux-mm@kvack.org>; Fri, 14 Oct 2011 11:35:32 -0400 (EDT)
Received: by bkbzu5 with SMTP id zu5so2911888bkb.14
        for <linux-mm@kvack.org>; Fri, 14 Oct 2011 08:34:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4E98085A.8080803@samsung.com>
References: <1318325033-32688-1-git-send-email-sumit.semwal@ti.com>
	<1318325033-32688-2-git-send-email-sumit.semwal@ti.com>
	<4E98085A.8080803@samsung.com>
Date: Fri, 14 Oct 2011 10:34:40 -0500
Message-ID: <CAF6AEGv-YEs74Y3fcDmG=aqGaGAio8OQnheiddzNndEux1QC+w@mail.gmail.com>
Subject: Re: [RFC 1/2] dma-buf: Introduce dma buffer sharing mechanism
From: Rob Clark <rob@ti.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tomasz Stanislawski <t.stanislaws@samsung.com>
Cc: Sumit Semwal <sumit.semwal@ti.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, dri-devel@lists.freedesktop.org, linux-media@vger.kernel.org, linux@arm.linux.org.uk, arnd@arndb.de, jesse.barker@linaro.org, daniel@ffwll.ch, Sumit Semwal <sumit.semwal@linaro.org>, Marek Szyprowski <m.szyprowski@samsung.com>

On Fri, Oct 14, 2011 at 5:00 AM, Tomasz Stanislawski
<t.stanislaws@samsung.com> wrote:
>> + * @attach: allows different devices to 'attach' themselves to the give=
n
>> + * =A0 =A0 =A0 =A0 buffer. It might return -EBUSY to signal that backin=
g storage
>> + * =A0 =A0 =A0 =A0 is already allocated and incompatible with the requi=
rements
>> + * =A0 =A0 =A0 =A0 of requesting device. [optional]
>> + * @detach: detach a given device from this buffer. [optional]
>> + * @get_scatterlist: returns list of scatter pages allocated, increases
>> + * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0usecount of the buffer. Requires =
atleast one attach
>> to be
>> + * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0called before. Returned sg list s=
hould already be
>> mapped
>> + * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0into _device_ address space.
>
> You must add a comment that this call 'may sleep'.
>
> I like the get_scatterlist idea. It allows the exported to create a valid
> scatterlist for a client in a elegant way.
>
> I do not like this whole attachment idea. The problem is that currently
> there is no support in DMA framework for allocation for multiple devices.=
 As
> long as no such a support exists, there is no generic way to handle
> attribute negotiations and buffer allocations that involve multiple devic=
es.
> So the exporter drivers would have to implement more or less hacky soluti=
ons
> to handle memory requirements and choosing the device that allocated memo=
ry.
>
> Currently, AFAIK there is even no generic way for a driver to acquire its
> own DMA memory requirements.

dev->dma_params (struct device_dma_parameters).. for example

it would need to be expanded a bit to have a way to say "it needs to
be physically contiguous"..


> Therefore all logic hidden beneath 'attachment' is pointless. I think tha=
t
> support for attach/detach (and related stuff) should be postponed until
> support for multi-device allocation is added to DMA framework.
>
> I don't say the attachment list idea is wrong but adding attachment stuff
> creates an illusion that problem of multi-device allocations is somehow
> magically solved. We should not force the developers of exporter drivers =
to
> solve the problem that is not solvable yet.
>
> The other problem are the APIs. For example, the V4L2 subsystem assumes t=
hat
> memory is allocated after successful VIDIOC_REQBUFS with V4L2_MEMORY_MMAP
> memory type. Therefore attach would be automatically followed by
> get_scatterlist, blocking possibility of any buffer migrations in future.

But this problem really only applies if v4l is your buffer allocator.
I don't think a v4l limitation is a valid argument to remove the
attachment stuff.

> The same situation happens if buffer sharing is added to framebuffer API.
>
> The buffer sharing mechanism is dedicated to improve cooperation between
> multiple APIs. Therefore the common denominator strategy should be applie=
d
> that is buffer-creation =3D=3D buffer-allocation.

I think it would be sufficient if buffer creators that cannot defer
the allocation just take a worst-case approach and allocate physically
contiguous buffers.  No need to penalize other potential buffer
allocators.  This allows buffer creators with more flexibility the
option for deferring the allocation until it knows whether the buffer
really needs to be contiguous.

>> + * @put_scatterlist: decreases usecount of buffer, might deallocate
>> scatter
>> + * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pages.
>> + * @mmap: memory map this buffer - optional.
>> + * @release: release this buffer; to be called after the last
>> dma_buf_put.
>> + * @sync_sg_for_cpu: sync the sg list for cpu.
>> + * @sync_sg_for_device: synch the sg list for device.
>> + */
>> +struct dma_buf_ops {
>> + =A0 =A0 =A0 int (*attach)(struct dma_buf *, struct device *,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct dma_buf_attachment =
*);
>> +
>> + =A0 =A0 =A0 void (*detach)(struct dma_buf *, struct dma_buf_attachment=
 *);
>> +
>> + =A0 =A0 =A0 /* For {get,put}_scatterlist below, any specific buffer at=
tributes
>> + =A0 =A0 =A0 =A0* required should get added to device_dma_parameters ac=
cessible
>> + =A0 =A0 =A0 =A0* via dev->dma_params.
>> + =A0 =A0 =A0 =A0*/
>> + =A0 =A0 =A0 struct scatterlist * (*get_scatterlist)(struct dma_buf_att=
achment
>> *,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 enum dma_data_direction,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 int *nents);
>> + =A0 =A0 =A0 void (*put_scatterlist)(struct dma_buf_attachment *,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 struct scatterlist *,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 int nents);
>> + =A0 =A0 =A0 /* TODO: Add interruptible and interruptible_timeout versi=
ons */
>
> I don't agree the interruptible and interruptible_timeout versions are
> needed. I think that get_scatterlist should alway be interruptible. You c=
an
> add try_get_scatterlist callback that returns ERR_PTR(-EBUSY) if the call
> would be blocking.
>
>> +
>> + =A0 =A0 =A0 /* allow mmap optionally for devices that need it */
>> + =A0 =A0 =A0 int (*mmap)(struct dma_buf *, struct vm_area_struct *);
>
> The mmap is not needed for inital version. It could be added at any time =
in
> the future. The dmabuf client should not be allowed to create mapping of =
the
> dmabuf from the scatterlist.

fwiw, this wasn't intended for allowing the client to create the
mapping.. the intention was that the buffer creator always be the one
that implements the mmap'ing.  This was just to implement fops->mmap()
for the dmabuf handle, ie. so userspace could mmap the buffer without
having to know *who* allocated it.  Otherwise you have to also pass
around the fd of the allocator and an offset.

BR,
-R

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
