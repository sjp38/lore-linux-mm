Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 5B4B66B004F
	for <linux-mm@kvack.org>; Mon,  5 Dec 2011 04:48:22 -0500 (EST)
Received: by mail-gy0-f177.google.com with SMTP id r19so4904134ghr.36
        for <linux-mm@kvack.org>; Mon, 05 Dec 2011 01:48:21 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20111202171117.GA27322@phenom.dumpdata.com>
References: <1322816252-19955-1-git-send-email-sumit.semwal@ti.com>
 <1322816252-19955-2-git-send-email-sumit.semwal@ti.com> <20111202171117.GA27322@phenom.dumpdata.com>
From: "Semwal, Sumit" <sumit.semwal@ti.com>
Date: Mon, 5 Dec 2011 15:18:00 +0530
Message-ID: <CAB2ybb-G=4igL+XdRgH6oFSFdsBLuCoany4KeNaFfnLEaQzgdw@mail.gmail.com>
Subject: Re: [RFC v2 1/2] dma-buf: Introduce dma buffer sharing mechanism
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, dri-devel@lists.freedesktop.org, linux-media@vger.kernel.org, t.stanislaws@samsung.com, linux@arm.linux.org.uk, arnd@arndb.de, rob@ti.com, Sumit Semwal <sumit.semwal@linaro.org>, m.szyprowski@samsung.com

Hi Konrad,

On Fri, Dec 2, 2011 at 10:41 PM, Konrad Rzeszutek Wilk
<konrad.wilk@oracle.com> wrote:
> On Fri, Dec 02, 2011 at 02:27:31PM +0530, Sumit Semwal wrote:
>> This is the first step in defining a dma buffer sharing mechanism.
>>
<snip>
>>
>> [1]: https://wiki.linaro.org/OfficeofCTO/MemoryManagement
>> [2]: http://lwn.net/Articles/454389
>>
>> Signed-off-by: Sumit Semwal <sumit.semwal@linaro.org>
>> Signed-off-by: Sumit Semwal <sumit.semwal@ti.com>
>
> You have a clone? You only need one SOB.
:) Thanks for your review - Well, not a clone, but I have two 'employers' :=
))

I have a rather weird reason for this - I am employed with Texas
Instruments, but working with Linaro as well. And due to some
'non-technical' reasons, I need to send this work from @ti.com mail
ID. At the same time, I would like to acknowledge that this work was
done as part of the Linaro umbrella, so I put another SOB @linaro.org.

>
>
<snip>
>> + * Copyright(C) 2011 Linaro Limited. All rights reserved.
>> + * Author: Sumit Semwal <sumit.semwal@ti.com>
>
> OK, so the SOB should be from @ti.com then.
>
>> + *
<snip>
>> +static int dma_buf_mmap(struct file *file, struct vm_area_struct *vma)
>> +{
>> + =A0 =A0 struct dma_buf *dmabuf;
>> +
>> + =A0 =A0 if (!is_dma_buf_file(file))
>> + =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
>> +
>> + =A0 =A0 dmabuf =3D file->private_data;
>> +
>
> Should you check if dmabuf is NULL and or dmabuf->ops is NULL too?
>
> Hm, you probably don't need to check for dmabuf, but from
> looking at =A0dma_buf_export one could pass =A0a NULL for the ops.
see next comment
>
>> + =A0 =A0 if (!dmabuf->ops->mmap)
>> + =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
>> +
>> + =A0 =A0 return dmabuf->ops->mmap(dmabuf, vma);
>> +}
>> +
>> +static int dma_buf_release(struct inode *inode, struct file *file)
>> +{
>> + =A0 =A0 struct dma_buf *dmabuf;
>> +
>> + =A0 =A0 if (!is_dma_buf_file(file))
>> + =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
>> +
>> + =A0 =A0 dmabuf =3D file->private_data;
>> +
>
> No checking here for ops or ops->release?
Hmmm.. you're right, of course. for this common check in mmap and
release, I guess I'd add it to 'is_dma_buf_file()' helper [maybe call
it is_valid_dma_buf_file() or something similar]
>
<snip>
>> +
>> +/**
>
> I don't think the ** is anymore the current kernel doc format.
thanks for catching this :) - will correct.
>
>> + * dma_buf_export - Creates a new dma_buf, and associates an anon file
>> + * with this buffer,so it can be exported.
>
> Put a space there.
ok
>
>> + * Also connect the allocator specific data and ops to the buffer.
>> + *
>> + * @priv: =A0 =A0[in] =A0 =A0Attach private data of allocator to this b=
uffer
>> + * @ops: =A0 =A0 [in] =A0 =A0Attach allocator-defined dma buf ops to th=
e new buffer.
>> + * @flags: =A0 [in] =A0 =A0mode flags for the file.
>> + *
>> + * Returns, on success, a newly created dma_buf object, which wraps the
>> + * supplied private data and operations for dma_buf_ops. On failure to
>> + * allocate the dma_buf object, it can return NULL.
>
> "it can" I think the right word is "it will".
Right.
>
>> + *
>> + */
>> +struct dma_buf *dma_buf_export(void *priv, struct dma_buf_ops *ops,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int flags)
>> +{
>> + =A0 =A0 struct dma_buf *dmabuf;
>> + =A0 =A0 struct file *file;
>> +
>> + =A0 =A0 BUG_ON(!priv || !ops);
>
> Whoa. Crash the whole kernel b/c of this? No no. You should
> use WARN_ON and just return NULL.
ok
>
>> +
>> + =A0 =A0 dmabuf =3D kzalloc(sizeof(struct dma_buf), GFP_KERNEL);
>> + =A0 =A0 if (dmabuf =3D=3D NULL)
>> + =A0 =A0 =A0 =A0 =A0 =A0 return dmabuf;
>
> Hmm, why not return ERR_PTR(-ENOMEM); ?
ok
>
>> +
>> + =A0 =A0 dmabuf->priv =3D priv;
>> + =A0 =A0 dmabuf->ops =3D ops;
>> +
>> + =A0 =A0 file =3D anon_inode_getfile("dmabuf", &dma_buf_fops, dmabuf, f=
lags);
>> +
>> + =A0 =A0 dmabuf->file =3D file;
>> +
>> + =A0 =A0 mutex_init(&dmabuf->lock);
>> + =A0 =A0 INIT_LIST_HEAD(&dmabuf->attachments);
>> +
>> + =A0 =A0 return dmabuf;
>> +}
>> +EXPORT_SYMBOL(dma_buf_export);
>
> _GPL ?
sure; will change it.
>
>> +
>> +
>> +/**
>> + * dma_buf_fd - returns a file descriptor for the given dma_buf
>> + * @dmabuf: =A0[in] =A0 =A0pointer to dma_buf for which fd is required.
>> + *
>> + * On success, returns an associated 'fd'. Else, returns error.
>> + */
>> +int dma_buf_fd(struct dma_buf *dmabuf)
>> +{
>> + =A0 =A0 int error, fd;
>> +
>
> Should you check if dmabuf is NULL first?
yes.
>
>> + =A0 =A0 if (!dmabuf->file)
>> + =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
>> +
>> + =A0 =A0 error =3D get_unused_fd_flags(0);
>> + =A0 =A0 if (error < 0)
>> + =A0 =A0 =A0 =A0 =A0 =A0 return error;
>> + =A0 =A0 fd =3D error;
>> +
>> + =A0 =A0 fd_install(fd, dmabuf->file);
>> +
>> + =A0 =A0 return fd;
>> +}
>> +EXPORT_SYMBOL(dma_buf_fd);
>
> GPL?
sure; will change it.
>> +
>> +/**
>> + * dma_buf_get - returns the dma_buf structure related to an fd
>> + * @fd: =A0 =A0 =A0[in] =A0 =A0fd associated with the dma_buf to be ret=
urned
>> + *
>> + * On success, returns the dma_buf structure associated with an fd; use=
s
>> + * file's refcounting done by fget to increase refcount. returns ERR_PT=
R
>> + * otherwise.
>> + */
>> +struct dma_buf *dma_buf_get(int fd)
>> +{
>> + =A0 =A0 struct file *file;
>> +
>> + =A0 =A0 file =3D fget(fd);
>> +
>> + =A0 =A0 if (!file)
>> + =A0 =A0 =A0 =A0 =A0 =A0 return ERR_PTR(-EBADF);
>> +
>> + =A0 =A0 if (!is_dma_buf_file(file)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 fput(file);
>> + =A0 =A0 =A0 =A0 =A0 =A0 return ERR_PTR(-EINVAL);
>> + =A0 =A0 }
>> +
>> + =A0 =A0 return file->private_data;
>> +}
>> +EXPORT_SYMBOL(dma_buf_get);
>
> GPL
sure; will change it.
>> +
>> +/**
>> + * dma_buf_put - decreases refcount of the buffer
>> + * @dmabuf: =A0[in] =A0 =A0buffer to reduce refcount of
>> + *
>> + * Uses file's refcounting done implicitly by fput()
>> + */
>> +void dma_buf_put(struct dma_buf *dmabuf)
>> +{
>> + =A0 =A0 BUG_ON(!dmabuf->file);
>
> Yikes. BUG_ON? Can't you do WARN_ON and continue on without
> doing the refcounting?
ok
>
>> +
>> + =A0 =A0 fput(dmabuf->file);
>> +}
>> +EXPORT_SYMBOL(dma_buf_put);
>> +
>> +/**
>> + * dma_buf_attach - Add the device to dma_buf's attachments list; optio=
nally,
>> + * calls attach() of dma_buf_ops to allow device-specific attach functi=
onality
>> + * @dmabuf: =A0[in] =A0 =A0buffer to attach device to.
>> + * @dev: =A0 =A0 [in] =A0 =A0device to be attached.
>> + *
>> + * Returns struct dma_buf_attachment * for this attachment; may return =
NULL.
>> + *
>> + */
>> +struct dma_buf_attachment *dma_buf_attach(struct dma_buf *dmabuf,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 struct device *dev)
>
> 'struct device' should be at the same column as 'struct dma_buf' ..
>
>> +{
>> + =A0 =A0 struct dma_buf_attachment *attach;
>> + =A0 =A0 int ret;
>> +
>> + =A0 =A0 BUG_ON(!dmabuf || !dev);
>
> Again, BUG_ON...
will correct
>
>> +
>> + =A0 =A0 attach =3D kzalloc(sizeof(struct dma_buf_attachment), GFP_KERN=
EL);
>> + =A0 =A0 if (attach =3D=3D NULL)
>> + =A0 =A0 =A0 =A0 =A0 =A0 goto err_alloc;
>> +
>> + =A0 =A0 mutex_lock(&dmabuf->lock);
>> +
>> + =A0 =A0 attach->dev =3D dev;
>> + =A0 =A0 attach->dmabuf =3D dmabuf;
>> + =A0 =A0 if (dmabuf->ops->attach) {
>
> No checking first of dmabuf->ops?
Attach is told to be a mandatory operation for dmabuf exporter, but I
understand your point - checking for it won't hurt.
>
>> + =A0 =A0 =A0 =A0 =A0 =A0 ret =3D dmabuf->ops->attach(dmabuf, dev, attac=
h);
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (!ret)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err_attach;
>> + =A0 =A0 }
>> + =A0 =A0 list_add(&attach->node, &dmabuf->attachments);
>> +
>> + =A0 =A0 mutex_unlock(&dmabuf->lock);
>> +
>> +err_alloc:
>> + =A0 =A0 return attach;
>> +err_attach:
>> + =A0 =A0 kfree(attach);
>> + =A0 =A0 mutex_unlock(&dmabuf->lock);
>> + =A0 =A0 return ERR_PTR(ret);
>> +}
>> +EXPORT_SYMBOL(dma_buf_attach);
>
> GPL
sure; will change it.
<snip>

Thanks and regards,
~Sumit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
