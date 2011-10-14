Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id C430E6B01F3
	for <linux-mm@kvack.org>; Fri, 14 Oct 2011 10:14:05 -0400 (EDT)
Received: by vws16 with SMTP id 16so787593vws.14
        for <linux-mm@kvack.org>; Fri, 14 Oct 2011 07:14:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4E98085A.8080803@samsung.com>
References: <1318325033-32688-1-git-send-email-sumit.semwal@ti.com>
 <1318325033-32688-2-git-send-email-sumit.semwal@ti.com> <4E98085A.8080803@samsung.com>
From: Sumit Semwal <sumit.semwal@linaro.org>
Date: Fri, 14 Oct 2011 19:43:42 +0530
Message-ID: <CAO_48GHDpeMjbo10LnY4W6mwGKXiLJfh+xD4+1R53k_86Cgc0A@mail.gmail.com>
Subject: Re: [RFC 1/2] dma-buf: Introduce dma buffer sharing mechanism
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tomasz Stanislawski <t.stanislaws@samsung.com>
Cc: Sumit Semwal <sumit.semwal@ti.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, dri-devel@lists.freedesktop.org, linux-media@vger.kernel.org, linux@arm.linux.org.uk, arnd@arndb.de, jesse.barker@linaro.org, rob@ti.com, daniel@ffwll.ch, Marek Szyprowski <m.szyprowski@samsung.com>

On 14 October 2011 15:30, Tomasz Stanislawski <t.stanislaws@samsung.com> wr=
ote:
> Hi Mr. Sumit Semwal,
Hello Mr. Tomasz Stanislawski :),

> Thank you for taking care of the framework for buffer sharing.
> The support of buffer sharing in V4L2, both exporting and importing was
> posted in shrbuf proof-of-concept patch. It should be easy to port it to
> dmabuf.
>
> http://lists.linaro.org/pipermail/linaro-mm-sig/2011-August/000485.html
I should thank you for the wonderful proof-of-concept patch, and the
idea behind it! I am currently working on the V4L2 side patch for it,
and would send out the RFC soon.
Also, thanks for a good review and some pertinent points; replies inline.
>
> Please refer to the comments below:
>
> On 10/11/2011 11:23 AM, Sumit Semwal wrote:
>>
<snip>
>> +/**
>> + * dma_buf_export - Creates a new dma_buf, and associates an anon file
>> + * with this buffer,so it can be exported.
>> + * Also connect the allocator specific data and ops to the buffer.
>> + *
>> + * @priv: =C2=A0 =C2=A0 =C2=A0[in] =C2=A0 =C2=A0Attach private data of =
allocator to this buffer
>> + * @ops: =C2=A0 =C2=A0 =C2=A0 [in] =C2=A0 =C2=A0Attach allocator-define=
d dma buf ops to the new
>> buffer.
>> + * @flags: =C2=A0 =C2=A0 [in] =C2=A0 =C2=A0mode flags for the file.
>
> What is the purpose of these flags? The file is not visible to any proces=
s
> by any file system, is it?
These are the standard file mode flags, which can be used to do
file-level access-type control by the exporter, so for example
write-access can be denied for  a buffer exported as a read-only
buffer.
>
>> + *
>> + * Returns, on success, a newly created dma_buf object, which wraps the
>> + * supplied private data and operations for dma_buf_ops. On failure to
>> + * allocate the dma_buf object, it can return NULL.
>> + *
>> + */
>> +struct dma_buf *dma_buf_export(void *priv, struct dma_buf_ops *ops,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int flags)
>> +{
>> + =C2=A0 =C2=A0 =C2=A0 struct dma_buf *dmabuf;
>> + =C2=A0 =C2=A0 =C2=A0 struct file *file;
>> +
>
> why priv is not allowed to be NULL?
priv will be used by the exporter to attach its own context to the dma
buf; I couldn't think of any case where it could be NULL?
>
>> + =C2=A0 =C2=A0 =C2=A0 BUG_ON(!priv || !ops);
>> +
<snip>
>> + =C2=A0 =C2=A0 =C2=A0 BUG_ON(!dmabuf->file);
>> +
>> + =C2=A0 =C2=A0 =C2=A0 fput(dmabuf->file);
>> +
>
> return is not needed
Right; will correct this.
>
>> + =C2=A0 =C2=A0 =C2=A0 return;
>> +}
>> +EXPORT_SYMBOL(dma_buf_put);
>> +
>> +/**
>> + * dma_buf_attach - Add the device to dma_buf's attachments list;
>> optionally,
>> + * calls attach() of dma_buf_ops to allow device-specific attach
>> functionality
>> + * @dmabuf: =C2=A0 =C2=A0[in] =C2=A0 =C2=A0buffer to attach device to.
>> + * @dev: =C2=A0 =C2=A0 =C2=A0 [in] =C2=A0 =C2=A0device to be attached.
>> + *
>> + * Returns struct dma_buf_attachment * for this attachment; may return
>> NULL.
>> + *
>> + */
>> +struct dma_buf_attachment *dma_buf_attach(struct dma_buf *dmabuf,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 struct device *dev)
>> +{
>> + =C2=A0 =C2=A0 =C2=A0 struct dma_buf_attachment *attach;
>> + =C2=A0 =C2=A0 =C2=A0 int ret;
>> +
>> + =C2=A0 =C2=A0 =C2=A0 BUG_ON(!dmabuf || !dev);
>> +
>> + =C2=A0 =C2=A0 =C2=A0 mutex_lock(&dmabuf->lock);
>> +
>
> There is no need to call kzalloc inside critical section protected by
> dmabuf->lock. The code would be simpler if the allocation is moved outsid=
e
> the section.
Yes, you're right; will correct it.
>
>> + =C2=A0 =C2=A0 =C2=A0 attach =3D kzalloc(sizeof(struct dma_buf_attachme=
nt), GFP_KERNEL);
>> + =C2=A0 =C2=A0 =C2=A0 if (attach =3D=3D NULL)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto err_alloc;
>> +
>> + =C2=A0 =C2=A0 =C2=A0 attach->dev =3D dev;
>> + =C2=A0 =C2=A0 =C2=A0 if (dmabuf->ops->attach) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D dmabuf->ops->=
attach(dmabuf, dev, attach);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!ret)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 goto err_attach;
>> + =C2=A0 =C2=A0 =C2=A0 }
>> + =C2=A0 =C2=A0 =C2=A0 list_add(&attach->node,&dmabuf->attachments);
>> +
>> +err_alloc:
>> + =C2=A0 =C2=A0 =C2=A0 mutex_unlock(&dmabuf->lock);
>> + =C2=A0 =C2=A0 =C2=A0 return attach;
>> +err_attach:
>> + =C2=A0 =C2=A0 =C2=A0 kfree(attach);
>> + =C2=A0 =C2=A0 =C2=A0 mutex_unlock(&dmabuf->lock);
>> + =C2=A0 =C2=A0 =C2=A0 return ERR_PTR(ret);
>> +}
>> +EXPORT_SYMBOL(dma_buf_attach);
>> +
>> +/**
>> + * dma_buf_detach - Remove the given attachment from dmabuf's attachmen=
ts
>> list;
>> + * optionally calls detach() of dma_buf_ops for device-specific detach
>> + * @dmabuf: =C2=A0 =C2=A0[in] =C2=A0 =C2=A0buffer to detach from.
>> + * @attach: =C2=A0 =C2=A0[in] =C2=A0 =C2=A0attachment to be detached; i=
s free'd after this
>> call.
>> + *
>> + */
>> +void dma_buf_detach(struct dma_buf *dmabuf, struct dma_buf_attachment
>> *attach)
>> +{
>> + =C2=A0 =C2=A0 =C2=A0 BUG_ON(!dmabuf || !attach);
>> +
>> + =C2=A0 =C2=A0 =C2=A0 mutex_lock(&dmabuf->lock);
>> + =C2=A0 =C2=A0 =C2=A0 list_del(&attach->node);
>> + =C2=A0 =C2=A0 =C2=A0 if (dmabuf->ops->detach)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dmabuf->ops->detach(d=
mabuf, attach);
>> +
>
> [as above]
Ok.
>>
>> + =C2=A0 =C2=A0 =C2=A0 kfree(attach);
>> + =C2=A0 =C2=A0 =C2=A0 mutex_unlock(&dmabuf->lock);
>> + =C2=A0 =C2=A0 =C2=A0 return;
>> +}
>> +EXPORT_SYMBOL(dma_buf_detach);
>> diff --git a/include/linux/dma-buf.h b/include/linux/dma-buf.h
>> new file mode 100644
>> index 0000000..5bdf16a
>> --- /dev/null
>> +++ b/include/linux/dma-buf.h
>> @@ -0,0 +1,162 @@
>> +/*
>> + * Header file for dma buffer sharing framework.
>> + *
>> + * Copyright(C) 2011 Linaro Limited. All rights reserved.
>> + * Author: Sumit Semwal<sumit.semwal@ti.com>
>> + *
>> + * Many thanks to linaro-mm-sig list, and specially
>> + * Arnd Bergmann<arnd@arndb.de>, Rob Clark<rob@ti.com> =C2=A0and
>> + * Daniel Vetter<daniel@ffwll.ch> =C2=A0for their support in creation a=
nd
>> + * refining of this idea.
>> + *
>> + * This program is free software; you can redistribute it and/or modify
>> it
>> + * under the terms of the GNU General Public License version 2 as
>> published by
>> + * the Free Software Foundation.
>> + *
>> + * This program is distributed in the hope that it will be useful, but
>> WITHOUT
>> + * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY o=
r
>> + * FITNESS FOR A PARTICULAR PURPOSE. =C2=A0See the GNU General Public L=
icense
>> for
>> + * more details.
>> + *
>> + * You should have received a copy of the GNU General Public License
>> along with
>> + * this program. =C2=A0If not, see<http://www.gnu.org/licenses/>.
>> + */
>> +#ifndef __DMA_BUF_H__
>> +#define __DMA_BUF_H__
>> +
>> +#include<linux/file.h>
>> +#include<linux/err.h>
>> +#include<linux/device.h>
>> +#include<linux/scatterlist.h>
>> +#include<linux/list.h>
>> +#include<linux/dma-mapping.h>
>> +
>> +struct dma_buf;
>> +
>> +/**
>> + * struct dma_buf_attachment - holds device-buffer attachment data
>> + * @dmabuf: buffer for this attachment.
>> + * @dev: device attached to the buffer.
>> + * @node: list_head to allow manipulation of list of dma_buf_attachment=
.
>> + * @priv: exporter-specific attachment data.
>> + */
>> +struct dma_buf_attachment {
>> + =C2=A0 =C2=A0 =C2=A0 struct dma_buf *dmabuf;
>> + =C2=A0 =C2=A0 =C2=A0 struct device *dev;
>> + =C2=A0 =C2=A0 =C2=A0 struct list_head node;
>> + =C2=A0 =C2=A0 =C2=A0 void *priv;
>> +};
>> +
>> +/**
>> + * struct dma_buf_ops - operations possible on struct dma_buf
>> + * @create: creates a struct dma_buf of a fixed size. Actual allocation
>> + * =C2=A0 =C2=A0 =C2=A0 =C2=A0 does not happen here.
>
> The 'create' ops is not present in dma_buf_ops.
Yes, this is a copy-paste mistake; will correct.
>> + * @attach: allows different devices to 'attach' themselves to the give=
n
>> + * =C2=A0 =C2=A0 =C2=A0 =C2=A0 buffer. It might return -EBUSY to signal=
 that backing storage
>> + * =C2=A0 =C2=A0 =C2=A0 =C2=A0 is already allocated and incompatible wi=
th the requirements
>> + * =C2=A0 =C2=A0 =C2=A0 =C2=A0 of requesting device. [optional]
>> + * @detach: detach a given device from this buffer. [optional]
>> + * @get_scatterlist: returns list of scatter pages allocated, increases
>> + * =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0usecou=
nt of the buffer. Requires atleast one attach
>> to be
>> + * =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0called=
 before. Returned sg list should already be
>> mapped
>> + * =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0into _=
device_ address space.
>
> You must add a comment that this call 'may sleep'.
Thanks, I will add this.
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

You are right, there is currently no generic way for attribute
negotiation for buffers of multiple devices. However, since buffer
sharing idea itself is about allowing for buffer allocation and
migration based on 'some' negotiation, the attachment idea makes it
easier to do so.

What you choose to call 'more or less hacky solution', I would call
'platform-specific mechanism' for negotiation, allocation (and
migration if possible and required). :)
>
> Currently, AFAIK there is even no generic way for a driver to acquire its
> own DMA memory requirements.
>
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

I quite like what you said - the problem of having a 'generic'
mechanism of DMA attribute negotiation might not have been solved yet,
and so the exporter drivers shouldn't need to try to do that.
However, exporter drivers would most likely know about the negotiation
etc needed and possible on their given platform - and the attachment
mechanism gives them a way to gather requirements from participating
DMA users, and use it for such decisions.

>
> The other problem are the APIs. For example, the V4L2 subsystem assumes t=
hat
> memory is allocated after successful VIDIOC_REQBUFS with V4L2_MEMORY_MMAP
> memory type. Therefore attach would be automatically followed by
> get_scatterlist, blocking possibility of any buffer migrations in future.
That is correct for V4L2_MEMORY_MMAP; should that need to be a
requirement even for V4L2_MEMORY_DMABUF_USER memory type? [I am
deliberately distinguishing a V4L2 driver which is a shared buffer
exporter from a V4L2 shared-buffer-user driver] - could we not do a
get_scatterlist on each VIDIOC_QBUF, and put_scatterlist on each
VIDIOC_DQBUF?
>
> The same situation happens if buffer sharing is added to framebuffer API.
>
> The buffer sharing mechanism is dedicated to improve cooperation between
> multiple APIs. Therefore the common denominator strategy should be applie=
d
> that is buffer-creation =3D=3D buffer-allocation.

It might be prudent to do so in the media drivers. But the buffer
sharing mechanism is also useful for other, non-media usecases? I
would say that we should be able to leave enough flexibility.
>
>> + * @put_scatterlist: decreases usecount of buffer, might deallocate
>> scatter
>> + * =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pages.
>> + * @mmap: memory map this buffer - optional.
>> + * @release: release this buffer; to be called after the last
>> dma_buf_put.
>> + * @sync_sg_for_cpu: sync the sg list for cpu.
>> + * @sync_sg_for_device: synch the sg list for device.
>> + */
>> +struct dma_buf_ops {
>> + =C2=A0 =C2=A0 =C2=A0 int (*attach)(struct dma_buf *, struct device *,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 struct dma_buf_attachment *);
>> +
>> + =C2=A0 =C2=A0 =C2=A0 void (*detach)(struct dma_buf *, struct dma_buf_a=
ttachment *);
>> +
>> + =C2=A0 =C2=A0 =C2=A0 /* For {get,put}_scatterlist below, any specific =
buffer attributes
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* required should get added to device_dma_p=
arameters accessible
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* via dev->dma_params.
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>> + =C2=A0 =C2=A0 =C2=A0 struct scatterlist * (*get_scatterlist)(struct dm=
a_buf_attachment
>> *,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 enum dma_data_direction,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 int *nents);
>> + =C2=A0 =C2=A0 =C2=A0 void (*put_scatterlist)(struct dma_buf_attachment=
 *,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 struct scatterlist *,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 int nents);
>> + =C2=A0 =C2=A0 =C2=A0 /* TODO: Add interruptible and interruptible_time=
out versions */
>
> I don't agree the interruptible and interruptible_timeout versions are
> needed. I think that get_scatterlist should alway be interruptible. You c=
an
> add try_get_scatterlist callback that returns ERR_PTR(-EBUSY) if the call
> would be blocking.
Sure, that's a good idea - I could do that.
>
>> +
>> + =C2=A0 =C2=A0 =C2=A0 /* allow mmap optionally for devices that need it=
 */
>> + =C2=A0 =C2=A0 =C2=A0 int (*mmap)(struct dma_buf *, struct vm_area_stru=
ct *);
>
> The mmap is not needed for inital version. It could be added at any time =
in
> the future. The dmabuf client should not be allowed to create mapping of =
the
> dmabuf from the scatterlist.
There's already a discussion between Rob and David on this mail-chain
earlier; I guess we'll need to wait a little before deciding to remove
this.
>
<snip>
>
> I hope you find my comments useful.
Like I said Tomasz, I thank you for a very good review! Hope my
replies satisfy some of the concerns you raised?
>
> Yours sincerely,
> Tomasz Stanislawski
>

--=20
Thanks and regards,
Sumit Semwal
Linaro Kernel Engineer - Graphics working group
Linaro.org=C2=A0=E2=94=82=C2=A0Open source software for ARM SoCs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
