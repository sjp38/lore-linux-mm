Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 2A21D6B004D
	for <linux-mm@kvack.org>; Sun,  1 Jan 2012 18:02:59 -0500 (EST)
Received: by vcge1 with SMTP id e1so14211124vcg.14
        for <linux-mm@kvack.org>; Sun, 01 Jan 2012 15:02:58 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120101200951.GH3677@valkosipuli.localdomain>
References: <1324891397-10877-1-git-send-email-sumit.semwal@ti.com>
	<1324891397-10877-3-git-send-email-sumit.semwal@ti.com>
	<20120101200951.GH3677@valkosipuli.localdomain>
Date: Sun, 1 Jan 2012 17:02:57 -0600
Message-ID: <CAF6AEGt_YumXu6Pa3wqFVhCPctYEFBW83aSwEdT1yzrwRTE-Vw@mail.gmail.com>
Subject: Re: [PATCH 2/3] dma-buf: Documentation for buffer sharing framework
From: Rob Clark <rob@ti.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sakari Ailus <sakari.ailus@iki.fi>
Cc: Sumit Semwal <sumit.semwal@ti.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, dri-devel@lists.freedesktop.org, linux-media@vger.kernel.org, arnd@arndb.de, airlied@redhat.com, linux@arm.linux.org.uk, jesse.barker@linaro.org, m.szyprowski@samsung.com, daniel@ffwll.ch, t.stanislaws@samsung.com, patches@linaro.org, Sumit Semwal <sumit.semwal@linaro.org>

On Sun, Jan 1, 2012 at 2:09 PM, Sakari Ailus <sakari.ailus@iki.fi> wrote:
> Hi Sumit and Arnd,
>
> On Mon, Dec 26, 2011 at 02:53:16PM +0530, Sumit Semwal wrote:
>> Add documentation for dma buffer sharing framework, explaining the
>> various operations, members and API of the dma buffer sharing
>> framework.
>>
>> Signed-off-by: Sumit Semwal <sumit.semwal@linaro.org>
>> Signed-off-by: Sumit Semwal <sumit.semwal@ti.com>
>> Reviewed-by: Daniel Vetter <daniel.vetter@ffwll.ch>
>> ---
>> =A0Documentation/dma-buf-sharing.txt | =A0224 ++++++++++++++++++++++++++=
+++++++++++
>> =A01 files changed, 224 insertions(+), 0 deletions(-)
>> =A0create mode 100644 Documentation/dma-buf-sharing.txt
>>
>> diff --git a/Documentation/dma-buf-sharing.txt b/Documentation/dma-buf-s=
haring.txt
>> new file mode 100644
>> index 0000000..510eab3
>> --- /dev/null
>> +++ b/Documentation/dma-buf-sharing.txt
>> @@ -0,0 +1,224 @@
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0DMA Buffer Sharing API Guide
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0~~~~~~~~~~~~~~~~~~~~~~~~~~~~
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Sumit Semwal
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0<sumit dot semwal at linaro dot org>
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 <sumit dot semwal at ti dot com>
>> +
>> +This document serves as a guide to device-driver writers on what is the=
 dma-buf
>> +buffer sharing API, how to use it for exporting and using shared buffer=
s.
>> +
>> +Any device driver which wishes to be a part of DMA buffer sharing, can =
do so as
>> +either the 'exporter' of buffers, or the 'user' of buffers.
>> +
>> +Say a driver A wants to use buffers created by driver B, then we call B=
 as the
>> +exporter, and A as buffer-user.
>> +
>> +The exporter
>> +- implements and manages operations[1] for the buffer
>> +- allows other users to share the buffer by using dma_buf sharing APIs,
>> +- manages the details of buffer allocation,
>> +- decides about the actual backing storage where this allocation happen=
s,
>> +- takes care of any migration of scatterlist - for all (shared) users o=
f this
>> + =A0 buffer,
>> +
>> +The buffer-user
>> +- is one of (many) sharing users of the buffer.
>> +- doesn't need to worry about how the buffer is allocated, or where.
>> +- needs a mechanism to get access to the scatterlist that makes up this=
 buffer
>> + =A0 in memory, mapped into its own address space, so it can access the=
 same area
>> + =A0 of memory.
>> +
>> +*IMPORTANT*: [see https://lkml.org/lkml/2011/12/20/211 for more details=
]
>> +For this first version, A buffer shared using the dma_buf sharing API:
>> +- *may* be exported to user space using "mmap" *ONLY* by exporter, outs=
ide of
>> + =A0 this framework.
>> +- may be used *ONLY* by importers that do not need CPU access to the bu=
ffer.
>> +
>> +The dma_buf buffer sharing API usage contains the following steps:
>> +
>> +1. Exporter announces that it wishes to export a buffer
>> +2. Userspace gets the file descriptor associated with the exported buff=
er, and
>> + =A0 passes it around to potential buffer-users based on use case
>> +3. Each buffer-user 'connects' itself to the buffer
>> +4. When needed, buffer-user requests access to the buffer from exporter
>> +5. When finished with its use, the buffer-user notifies end-of-DMA to e=
xporter
>> +6. when buffer-user is done using this buffer completely, it 'disconnec=
ts'
>> + =A0 itself from the buffer.
>> +
>> +
>> +1. Exporter's announcement of buffer export
>> +
>> + =A0 The buffer exporter announces its wish to export a buffer. In this=
, it
>> + =A0 connects its own private buffer data, provides implementation for =
operations
>> + =A0 that can be performed on the exported dma_buf, and flags for the f=
ile
>> + =A0 associated with this buffer.
>> +
>> + =A0 Interface:
>> + =A0 =A0 =A0struct dma_buf *dma_buf_export(void *priv, struct dma_buf_o=
ps *ops,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0siz=
e_t size, int flags)
>> +
>> + =A0 If this succeeds, dma_buf_export allocates a dma_buf structure, an=
d returns a
>> + =A0 pointer to the same. It also associates an anonymous file with thi=
s buffer,
>> + =A0 so it can be exported. On failure to allocate the dma_buf object, =
it returns
>> + =A0 NULL.
>> +
>> +2. Userspace gets a handle to pass around to potential buffer-users
>> +
>> + =A0 Userspace entity requests for a file-descriptor (fd) which is a ha=
ndle to the
>> + =A0 anonymous file associated with the buffer. It can then share the f=
d with other
>> + =A0 drivers and/or processes.
>> +
>> + =A0 Interface:
>> + =A0 =A0 =A0int dma_buf_fd(struct dma_buf *dmabuf)
>> +
>> + =A0 This API installs an fd for the anonymous file associated with thi=
s buffer;
>> + =A0 returns either 'fd', or error.
>> +
>> +3. Each buffer-user 'connects' itself to the buffer
>> +
>> + =A0 Each buffer-user now gets a reference to the buffer, using the fd =
passed to
>> + =A0 it.
>> +
>> + =A0 Interface:
>> + =A0 =A0 =A0struct dma_buf *dma_buf_get(int fd)
>> +
>> + =A0 This API will return a reference to the dma_buf, and increment ref=
count for
>> + =A0 it.
>> +
>> + =A0 After this, the buffer-user needs to attach its device with the bu=
ffer, which
>> + =A0 helps the exporter to know of device buffer constraints.
>> +
>> + =A0 Interface:
>> + =A0 =A0 =A0struct dma_buf_attachment *dma_buf_attach(struct dma_buf *d=
mabuf,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0struct device *dev)
>> +
>> + =A0 This API returns reference to an attachment structure, which is th=
en used
>> + =A0 for scatterlist operations. It will optionally call the 'attach' d=
ma_buf
>> + =A0 operation, if provided by the exporter.
>> +
>> + =A0 The dma-buf sharing framework does the bookkeeping bits related to=
 managing
>> + =A0 the list of all attachments to a buffer.
>> +
>> +Until this stage, the buffer-exporter has the option to choose not to a=
ctually
>> +allocate the backing storage for this buffer, but wait for the first bu=
ffer-user
>> +to request use of buffer for allocation.
>> +
>> +
>> +4. When needed, buffer-user requests access to the buffer
>> +
>> + =A0 Whenever a buffer-user wants to use the buffer for any DMA, it ask=
s for
>> + =A0 access to the buffer using dma_buf_map_attachment API. At least on=
e attach to
>> + =A0 the buffer must have happened before map_dma_buf can be called.
>> +
>> + =A0 Interface:
>> + =A0 =A0 =A0struct sg_table * dma_buf_map_attachment(struct dma_buf_att=
achment *,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 enum dma_data_direction);
>> +
>> + =A0 This is a wrapper to dma_buf->ops->map_dma_buf operation, which hi=
des the
>> + =A0 "dma_buf->ops->" indirection from the users of this interface.
>> +
>> + =A0 In struct dma_buf_ops, map_dma_buf is defined as
>> + =A0 =A0 =A0struct sg_table * (*map_dma_buf)(struct dma_buf_attachment =
*,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0enum dma_data_direction);
>> +
>> + =A0 It is one of the buffer operations that must be implemented by the=
 exporter.
>> + =A0 It should return the sg_table containing scatterlist for this buff=
er, mapped
>> + =A0 into caller's address space.
>> +
>> + =A0 If this is being called for the first time, the exporter can now c=
hoose to
>> + =A0 scan through the list of attachments for this buffer, collate the =
requirements
>> + =A0 of the attached devices, and choose an appropriate backing storage=
 for the
>> + =A0 buffer.
>> +
>> + =A0 Based on enum dma_data_direction, it might be possible to have mul=
tiple users
>> + =A0 accessing at the same time (for reading, maybe), or any other kind=
 of sharing
>> + =A0 that the exporter might wish to make available to buffer-users.
>> +
>> + =A0 map_dma_buf() operation can return -EINTR if it is interrupted by =
a signal.
>> +
>> +
>> +5. When finished, the buffer-user notifies end-of-DMA to exporter
>> +
>> + =A0 Once the DMA for the current buffer-user is over, it signals 'end-=
of-DMA' to
>> + =A0 the exporter using the dma_buf_unmap_attachment API.
>> +
>> + =A0 Interface:
>> + =A0 =A0 =A0void dma_buf_unmap_attachment(struct dma_buf_attachment *,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0struct sg_table *);
>> +
>> + =A0 This is a wrapper to dma_buf->ops->unmap_dma_buf() operation, whic=
h hides the
>> + =A0 "dma_buf->ops->" indirection from the users of this interface.
>> +
>> + =A0 In struct dma_buf_ops, unmap_dma_buf is defined as
>> + =A0 =A0 =A0void (*unmap_dma_buf)(struct dma_buf_attachment *, struct s=
g_table *);
>> +
>> + =A0 unmap_dma_buf signifies the end-of-DMA for the attachment provided=
. Like
>> + =A0 map_dma_buf, this API also must be implemented by the exporter.
>
> How is this API expected to be used with user space APIs which use
> V4L2-style queueing of the buffers, i.e. several hardware devices may hav=
e a
> single buffer mapped at any given point of time and the user is responsib=
le
> for passing the buffer for processing between hardware devices?

The intention is that the v4l2 device would attach in when the dmabuf
descriptor is first seen, and then on subsequent QBUF/DQBUF (or maybe
just before/after DMA to/from buffer) would map/unmap.  It would be
the responsibility of the exporter to cache the mapping if appropriate
between map/unmap calls.  The importer should not care about this.

Have a look at https://github.com/robclark/kernel-omap4/commits/drmplane-dm=
abuf
(or I think sumit has some updated patches for vb2) for an example.

BR,
-R

> In that case also cache handling would need to be performed explicitly by
> drivers --- the V4L2 API already provides a way to tell drivers to skip
> cache cleaning or invalidation if the user does not intend to touch the
> buffer between passing it between two separate devices.
>
>> +
>> +6. when buffer-user is done using this buffer, it 'disconnects' itself =
from the
>> + =A0 buffer.
>> +
>> + =A0 After the buffer-user has no more interest in using this buffer, i=
t should
>> + =A0 disconnect itself from the buffer:
>> +
>> + =A0 - it first detaches itself from the buffer.
>> +
>> + =A0 Interface:
>> + =A0 =A0 =A0void dma_buf_detach(struct dma_buf *dmabuf,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct dma_buf_atta=
chment *dmabuf_attach);
>> +
>> + =A0 This API removes the attachment from the list in dmabuf, and optio=
nally calls
>> + =A0 dma_buf->ops->detach(), if provided by exporter, for any housekeep=
ing bits.
>> +
>> + =A0 - Then, the buffer-user returns the buffer reference to exporter.
>> +
>> + =A0 Interface:
>> + =A0 =A0 void dma_buf_put(struct dma_buf *dmabuf);
>> +
>> + =A0 This API then reduces the refcount for this buffer.
>> +
>> + =A0 If, as a result of this call, the refcount becomes 0, the 'release=
' file
>> + =A0 operation related to this fd is called. It calls the dmabuf->ops->=
release()
>> + =A0 operation in turn, and frees the memory allocated for dmabuf when =
exported.
>> +
>> +NOTES:
>> +- Importance of attach-detach and {map,unmap}_dma_buf operation pairs
>> + =A0 The attach-detach calls allow the exporter to figure out backing-s=
torage
>> + =A0 constraints for the currently-interested devices. This allows pref=
erential
>> + =A0 allocation, and/or migration of pages across different types of st=
orage
>> + =A0 available, if possible.
>> +
>> + =A0 Bracketing of DMA access with {map,unmap}_dma_buf operations is es=
sential
>> + =A0 to allow just-in-time backing of storage, and migration mid-way th=
rough a
>> + =A0 use-case.
>> +
>> +- Migration of backing storage if needed
>> + =A0 If after
>> + =A0 - at least one map_dma_buf has happened,
>> + =A0 - and the backing storage has been allocated for this buffer,
>> + =A0 another new buffer-user intends to attach itself to this buffer, i=
t might
>> + =A0 be allowed, if possible for the exporter.
>> +
>> + =A0 In case it is allowed by the exporter:
>> + =A0 =A0if the new buffer-user has stricter 'backing-storage constraint=
s', and the
>> + =A0 =A0exporter can handle these constraints, the exporter can just st=
all on the
>> + =A0 =A0map_dma_buf until all outstanding access is completed (as signa=
lled by
>> + =A0 =A0unmap_dma_buf).
>
> I would expect this to take place in V4L2 context when streaming is
> disabled; it would make sense to return EBUSY instead since it's not know=
n
> when the unmapping will be done.
>
>> + =A0 =A0Once all users have finished accessing and have unmapped this b=
uffer, the
>> + =A0 =A0exporter could potentially move the buffer to the stricter back=
ing-storage,
>> + =A0 =A0and then allow further {map,unmap}_dma_buf operations from any =
buffer-user
>> + =A0 =A0from the migrated backing-storage.
>> +
>> + =A0 If the exporter cannot fulfil the backing-storage constraints of t=
he new
>> + =A0 buffer-user device as requested, dma_buf_attach() would return an =
error to
>> + =A0 denote non-compatibility of the new buffer-sharing request with th=
e current
>> + =A0 buffer.
>> +
>> + =A0 If the exporter chooses not to allow an attach() operation once a
>> + =A0 map_dma_buf() API has been called, it simply returns an error.
>> +
>> +References:
>> +[1] struct dma_buf_ops in include/linux/dma-buf.h
>> +[2] All interfaces mentioned above defined in include/linux/dma-buf.h
>
> Kind regards,
>
> --
> Sakari Ailus
> e-mail: sakari.ailus@iki.fi =A0 =A0 jabber/XMPP/Gmail: sailus@retiisi.org=
.uk
> --
> To unsubscribe from this list: send the line "unsubscribe linux-media" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
