Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 30DAC6B009B
	for <linux-mm@kvack.org>; Tue,  3 Jan 2012 16:11:21 -0500 (EST)
Date: Tue, 3 Jan 2012 16:09:27 -0500
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [RFC v3 1/2] dma-buf: Introduce dma buffer sharing mechanism
Message-ID: <20120103210927.GJ17472@phenom.dumpdata.com>
References: <1324283611-18344-1-git-send-email-sumit.semwal@ti.com>
 <1324283611-18344-3-git-send-email-sumit.semwal@ti.com>
 <20111220163650.GB3964@phenom.dumpdata.com>
 <CAB2ybb_jZNgQma7dv2qojOf8K0-1wutfMkNr3xjqFvfpw2aNTQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <CAB2ybb_jZNgQma7dv2qojOf8K0-1wutfMkNr3xjqFvfpw2aNTQ@mail.gmail.com>
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Semwal, Sumit" <sumit.semwal@ti.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, dri-devel@lists.freedesktop.org, linux-media@vger.kernel.org, t.stanislaws@samsung.com, linux@arm.linux.org.uk, arnd@arndb.de, patches@linaro.org, rob@ti.com, Sumit Semwal <sumit.semwal@linaro.org>, m.szyprowski@samsung.com

On Fri, Dec 23, 2011 at 03:22:35PM +0530, Semwal, Sumit wrote:
> Hi Konrad,
>=20
> On Tue, Dec 20, 2011 at 10:06 PM, Konrad Rzeszutek Wilk
> <konrad.wilk@oracle.com> wrote:
> > On Mon, Dec 19, 2011 at 02:03:30PM +0530, Sumit Semwal wrote:
> >> This is the first step in defining a dma buffer sharing mechanism.
> >>
> >> A new buffer object dma_buf is added, with operations and API to all=
ow easy
> >> sharing of this buffer object across devices.
> >>
> >> The framework allows:
> >> - different devices to 'attach' themselves to this buffer, to facili=
tate
> >> =A0 backing storage negotiation, using dma_buf_attach() API.
> >
> > Any thoughts of adding facility to track them? So you can see who is =
using what?
> Not for version 1, but it would be a useful addition once we start
> using this mechanism.

OK. Looking forward to V2.
>=20
> >
> >> - association of a file pointer with each user-buffer and associated
> >> =A0 =A0allocator-defined operations on that buffer. This operation i=
s called the
> >> =A0 =A0'export' operation.
> >
> > =A0'create'? or 'alloc' ?
> >
> > export implies an import somwhere and I don't think that is the case =
here.
> I will rephrase it as suggested by Rob as well.
>=20
> >
> >> - this exported buffer-object to be shared with the other entity by =
asking for
> >> =A0 =A0its 'file-descriptor (fd)', and sharing the fd across.
> >> - a received fd to get the buffer object back, where it can be acces=
sed using
> >> =A0 =A0the associated exporter-defined operations.
> >> - the exporter and user to share the scatterlist using map_dma_buf a=
nd
> >> =A0 =A0unmap_dma_buf operations.
> >>
> >> Atleast one 'attach()' call is required to be made prior to calling =
the
> >> map_dma_buf() operation.
> >
> > for the whole memory region or just for the device itself?
> Rob has very eloquently and kindly explained it in his reply.

Can you include his words of wisdom in the git description?

>=20
> >
> >>
> <snip>
> >> +/*
> >> + * is_dma_buf_file - Check if struct file* is associated with dma_b=
uf
> >> + */
> >> +static inline int is_dma_buf_file(struct file *file)
> >> +{
> >> + =A0 =A0 return file->f_op =3D=3D &dma_buf_fops;
> >> +}
> >> +
> >> +/**
> >
> > Wrong kerneldoc.
> I looked into scripts/kernel-doc, and
> Documentation/kernel-doc-na-HOWTO.txt =3D> both these places mention
> that the kernel-doc comments have to start with /**, and I couldn't
> spot an error in what's wrong with my usage - would you please
> elaborate on what you think is not right?

The issue I had was with '/**' but let me double-check where I learned
that /** was a bad. Either way, it is a style-guide thing and the
Documentation/* trumps what I recall.

> >
> <snip>
> >> +/**
> >> + * struct dma_buf_attachment - holds device-buffer attachment data
> >
> > OK, but what is the purpose of it?
> I will add that in the comments.
> >
> >> + * @dmabuf: buffer for this attachment.
> >> + * @dev: device attached to the buffer.
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0^^^ th=
is
> >> + * @node: list_head to allow manipulation of list of dma_buf_attach=
ment.
> >
> > Just say: "list of dma_buf_attachment"'
> ok.
> >
> >> + * @priv: exporter-specific attachment data.
> >
> > That "exporter-specific.." brings to my mind custom decleration forms=
. But maybe that is me.
> :) well, in context of dma-buf 'exporter', it makes sense.

Or just private contents of the backend driver. But the naming is not tha=
t important
to inhibit this patch from being merged.
>=20
> >
> >> + */
> >> +struct dma_buf_attachment {
> >> + =A0 =A0 struct dma_buf *dmabuf;
> >> + =A0 =A0 struct device *dev;
> >> + =A0 =A0 struct list_head node;
> >> + =A0 =A0 void *priv;
> >> +};
> >
> > Why don't you move the decleration of this below 'struct dma_buf'?
> > It would easier than to read this structure..
> I could do that, but then anyways I will have to do a
> forward-declaration of dma_buf_attachment, since I have to use it in
> dma_buf_ops. If it improves readability, I am happy to move it below
> struct dma_buf

It is more of just making the readability easier. As in reading from top =
bottom
one. But if it is too ugly, don't bother.
>=20
> >
> >> +
> >> +/**
> >> + * struct dma_buf_ops - operations possible on struct dma_buf
> >> + * @attach: allows different devices to 'attach' themselves to the =
given
> >
> > register?
> >> + * =A0 =A0 =A0 buffer. It might return -EBUSY to signal that backin=
g storage
> >> + * =A0 =A0 =A0 is already allocated and incompatible with the requi=
rements
> >
> > Wait.. allocated or attached?
> This and above comment on 'register' are already answered by Rob in
> his explanation of the sequence in earlier reply. [the Documentation
> patch [2/2] also tries to explain it]

OK. Might want to mention the user to look in the Documentation, in case =
you don't
already have it.
>=20
> >
> >> + * =A0 =A0 =A0 of requesting device. [optional]
> >
> > What is optional? The return value? Or the 'attach' call? If the late=
r , say
> > that in the first paragraph.
> >
> ok, sure. it is meant for the attach op.
> >
> >> + * @detach: detach a given device from this buffer. [optional]
> >> + * @map_dma_buf: returns list of scatter pages allocated, increases=
 usecount
> >> + * =A0 =A0 =A0 =A0 =A0 =A0of the buffer. Requires atleast one attac=
h to be called
> >> + * =A0 =A0 =A0 =A0 =A0 =A0before. Returned sg list should already b=
e mapped into
> >> + * =A0 =A0 =A0 =A0 =A0 =A0_device_ address space. This call may sle=
ep. May also return
> >
> > Ok, there is some __might_sleep macro you should put on the function.
> >
> That's a nice suggestion; I will add it to the wrapper function for
> map_dma_buf().
>=20
> >> + * =A0 =A0 =A0 =A0 =A0 =A0-EINTR.
> >
> > Ok. What is the return code if attach has _not_ been called?
> Will document it to return -EINVAL if atleast on attach() hasn't been c=
alled.
>=20
> >
> >> + * @unmap_dma_buf: decreases usecount of buffer, might deallocate s=
catter
> >> + * =A0 =A0 =A0 =A0 =A0 =A0 =A0pages.
> >> + * @release: release this buffer; to be called after the last dma_b=
uf_put.
> >> + * @sync_sg_for_cpu: sync the sg list for cpu.
> >> + * @sync_sg_for_device: synch the sg list for device.
> >
> > Not seeing those two.
> Oops; removed in v3 - will correct.
>=20
> >> + */
> <snip>
> >> + =A0 =A0 /* TODO: Add try_map_dma_buf version, to return immed with=
 -EBUSY
> >
> > Ewww. Why? Why not just just the 'map_dma_buf' and return that?
> Requirement is to allow for blocking and non-blocking versions of
> map_dma_buf. try_map_dma_buf could be used for the non-blocking
> version.

Ok. What about just adding that in as a nop function operation. And have =
an
initial implementation in the code base that does .. well, nothing except=
=20
return -ENOSPC and move the TODO to the code instead of it being in the h=
eader?

>=20
> >
> <snip>
> >> +/**
> >> + * struct dma_buf - shared buffer object
> >
> > Missing the 'size'.
> Will add.
> >
> >> + * @file: file pointer used for sharing buffers across, and for ref=
counting.
> >> + * @attachments: list of dma_buf_attachment that denotes all device=
s attached.
> >> + * @ops: dma_buf_ops associated with this buffer object
> >> + * @priv: user specific private data
> >
> >
> > Can you elaborate on this? Is this the "exporter" using this? Or is
> > it for the "user" using it? If so, why provide it? Wouldn't the
> > user of this have something like this:
> >
> > struct my_dma_bufs {
> > =A0 =A0 =A0 =A0struct dma_buf[20];
> > =A0 =A0 =A0 =A0void *priv;
> > }
> >
> > Anyhow?
> My bad - it is meant for the exporter - exporter gives this as one of
> the parameters to 'dma_buf_export()' API. I will correct the comment.
> >
> Thanks for your review!

Sure. And please put 'Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@ora=
cle.com>'.
> Best regards,
> ~Sumit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
