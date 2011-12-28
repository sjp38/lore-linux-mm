Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 2CDED6B004D
	for <linux-mm@kvack.org>; Tue, 27 Dec 2011 21:27:32 -0500 (EST)
Received: by werf1 with SMTP id f1so7744664wer.14
        for <linux-mm@kvack.org>; Tue, 27 Dec 2011 18:27:30 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1324891397-10877-2-git-send-email-sumit.semwal@ti.com>
References: <1324891397-10877-1-git-send-email-sumit.semwal@ti.com>
	<1324891397-10877-2-git-send-email-sumit.semwal@ti.com>
Date: Wed, 28 Dec 2011 11:27:29 +0900
Message-ID: <CAAQKjZNCoEjNU1606ySpKNPdUvNU3Gg0uU+X-g1ejWZVtwf8=w@mail.gmail.com>
Subject: Re: [PATCH 1/3] dma-buf: Introduce dma buffer sharing mechanism
From: InKi Dae <daeinki@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sumit Semwal <sumit.semwal@ti.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, dri-devel@lists.freedesktop.org, linux-media@vger.kernel.org, arnd@arndb.de, airlied@redhat.com, linux@arm.linux.org.uk, jesse.barker@linaro.org, m.szyprowski@samsung.com, rob@ti.com, daniel@ffwll.ch, t.stanislaws@samsung.com, patches@linaro.org, Sumit Semwal <sumit.semwal@linaro.org>

2011/12/26 Sumit Semwal <sumit.semwal@ti.com>:
> This is the first step in defining a dma buffer sharing mechanism.
>
> A new buffer object dma_buf is added, with operations and API to allow ea=
sy
> sharing of this buffer object across devices.
>
> The framework allows:
> - creation of a buffer object, its association with a file pointer, and
> =A0 associated allocator-defined operations on that buffer. This operatio=
n is
> =A0 called the 'export' operation.
> - different devices to 'attach' themselves to this exported buffer object=
, to
> =A0facilitate backing storage negotiation, using dma_buf_attach() API.
> - the exported buffer object to be shared with the other entity by asking=
 for
> =A0 its 'file-descriptor (fd)', and sharing the fd across.
> - a received fd to get the buffer object back, where it can be accessed u=
sing
> =A0 the associated exporter-defined operations.
> - the exporter and user to share the scatterlist associated with this buf=
fer
> =A0 object using map_dma_buf and unmap_dma_buf operations.
>
> Atleast one 'attach()' call is required to be made prior to calling the
> map_dma_buf() operation.
>
> Couple of building blocks in map_dma_buf() are added to ease introduction
> of sync'ing across exporter and users, and late allocation by the exporte=
r.
>
> For this first version, this framework will work with certain conditions:
> - *ONLY* exporter will be allowed to mmap to userspace (outside of this
> =A0 framework - mmap is not a buffer object operation),
> - currently, *ONLY* users that do not need CPU access to the buffer are
> =A0 allowed.
>
> More details are there in the documentation patch.
>
> This is based on design suggestions from many people at the mini-summits[=
1],
> most notably from Arnd Bergmann <arnd@arndb.de>, Rob Clark <rob@ti.com> a=
nd
> Daniel Vetter <daniel@ffwll.ch>.
>
> The implementation is inspired from proof-of-concept patch-set from
> Tomasz Stanislawski <t.stanislaws@samsung.com>, who demonstrated buffer s=
haring
> between two v4l2 devices. [2]
>
> [1]: https://wiki.linaro.org/OfficeofCTO/MemoryManagement
> [2]: http://lwn.net/Articles/454389
>
> Signed-off-by: Sumit Semwal <sumit.semwal@linaro.org>
> Signed-off-by: Sumit Semwal <sumit.semwal@ti.com>
> Reviewed-by: Daniel Vetter <daniel.vetter@ffwll.ch>
> Reviewed-by: Dave Airlie <airlied@redhat.com>
> Reviewed-and-Tested-by: Rob Clark <rob.clark@linaro.org>
> ---
> =A0drivers/base/Kconfig =A0 =A0| =A0 10 ++
> =A0drivers/base/Makefile =A0 | =A0 =A01 +
> =A0drivers/base/dma-buf.c =A0| =A0291 +++++++++++++++++++++++++++++++++++=
++++++++++++
> =A0include/linux/dma-buf.h | =A0176 ++++++++++++++++++++++++++++
> =A04 files changed, 478 insertions(+), 0 deletions(-)
> =A0create mode 100644 drivers/base/dma-buf.c
> =A0create mode 100644 include/linux/dma-buf.h
>
> diff --git a/drivers/base/Kconfig b/drivers/base/Kconfig
> index 21cf46f..8a0e87f 100644
> --- a/drivers/base/Kconfig
> +++ b/drivers/base/Kconfig
> @@ -174,4 +174,14 @@ config SYS_HYPERVISOR
>
> =A0source "drivers/base/regmap/Kconfig"
>
> +config DMA_SHARED_BUFFER
> + =A0 =A0 =A0 bool "Buffer framework to be shared between drivers"
> + =A0 =A0 =A0 default n
> + =A0 =A0 =A0 select ANON_INODES
> + =A0 =A0 =A0 help
> + =A0 =A0 =A0 =A0 This option enables the framework for buffer-sharing be=
tween
> + =A0 =A0 =A0 =A0 multiple drivers. A buffer is associated with a file us=
ing driver
> + =A0 =A0 =A0 =A0 APIs extension; the file's descriptor can then be passe=
d on to other
> + =A0 =A0 =A0 =A0 driver.
> +
> =A0endmenu
> diff --git a/drivers/base/Makefile b/drivers/base/Makefile
> index 99a375a..d0df046 100644
> --- a/drivers/base/Makefile
> +++ b/drivers/base/Makefile
> @@ -8,6 +8,7 @@ obj-$(CONFIG_DEVTMPFS) =A0+=3D devtmpfs.o
> =A0obj-y =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0+=3D power/
> =A0obj-$(CONFIG_HAS_DMA) =A0+=3D dma-mapping.o
> =A0obj-$(CONFIG_HAVE_GENERIC_DMA_COHERENT) +=3D dma-coherent.o
> +obj-$(CONFIG_DMA_SHARED_BUFFER) +=3D dma-buf.o
> =A0obj-$(CONFIG_ISA) =A0 =A0 =A0+=3D isa.o
> =A0obj-$(CONFIG_FW_LOADER) =A0 =A0 =A0 =A0+=3D firmware_class.o
> =A0obj-$(CONFIG_NUMA) =A0 =A0 +=3D node.o
> diff --git a/drivers/base/dma-buf.c b/drivers/base/dma-buf.c
> new file mode 100644
> index 0000000..e38ad24
> --- /dev/null
> +++ b/drivers/base/dma-buf.c
> @@ -0,0 +1,291 @@
> +/*
> + * Framework for buffer objects that can be shared across devices/subsys=
tems.
> + *
> + * Copyright(C) 2011 Linaro Limited. All rights reserved.
> + * Author: Sumit Semwal <sumit.semwal@ti.com>
> + *
> + * Many thanks to linaro-mm-sig list, and specially
> + * Arnd Bergmann <arnd@arndb.de>, Rob Clark <rob@ti.com> and
> + * Daniel Vetter <daniel@ffwll.ch> for their support in creation and
> + * refining of this idea.
> + *
> + * This program is free software; you can redistribute it and/or modify =
it
> + * under the terms of the GNU General Public License version 2 as publis=
hed by
> + * the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful, but W=
ITHOUT
> + * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
> + * FITNESS FOR A PARTICULAR PURPOSE. =A0See the GNU General Public Licen=
se for
> + * more details.
> + *
> + * You should have received a copy of the GNU General Public License alo=
ng with
> + * this program. =A0If not, see <http://www.gnu.org/licenses/>.
> + */
> +
> +#include <linux/fs.h>
> +#include <linux/slab.h>
> +#include <linux/dma-buf.h>
> +#include <linux/anon_inodes.h>
> +#include <linux/export.h>
> +
> +static inline int is_dma_buf_file(struct file *);
> +
> +static int dma_buf_release(struct inode *inode, struct file *file)
> +{
> + =A0 =A0 =A0 struct dma_buf *dmabuf;
> +
> + =A0 =A0 =A0 if (!is_dma_buf_file(file))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> +
> + =A0 =A0 =A0 dmabuf =3D file->private_data;
> +
> + =A0 =A0 =A0 dmabuf->ops->release(dmabuf);
> + =A0 =A0 =A0 kfree(dmabuf);
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static const struct file_operations dma_buf_fops =3D {
> + =A0 =A0 =A0 .release =A0 =A0 =A0 =A0=3D dma_buf_release,
> +};
> +
> +/*
> + * is_dma_buf_file - Check if struct file* is associated with dma_buf
> + */
> +static inline int is_dma_buf_file(struct file *file)
> +{
> + =A0 =A0 =A0 return file->f_op =3D=3D &dma_buf_fops;
> +}
> +
> +/**
> + * dma_buf_export - Creates a new dma_buf, and associates an anon file
> + * with this buffer, so it can be exported.
> + * Also connect the allocator specific data and ops to the buffer.
> + *
> + * @priv: =A0 =A0 =A0[in] =A0 =A0Attach private data of allocator to thi=
s buffer
> + * @ops: =A0 =A0 =A0 [in] =A0 =A0Attach allocator-defined dma buf ops to=
 the new buffer.
> + * @size: =A0 =A0 =A0[in] =A0 =A0Size of the buffer
> + * @flags: =A0 =A0 [in] =A0 =A0mode flags for the file.
> + *
> + * Returns, on success, a newly created dma_buf object, which wraps the
> + * supplied private data and operations for dma_buf_ops. On either missi=
ng
> + * ops, or error in allocating struct dma_buf, will return negative erro=
r.
> + *
> + */
> +struct dma_buf *dma_buf_export(void *priv, struct dma_buf_ops *ops,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 size_t size=
, int flags)
> +{
> + =A0 =A0 =A0 struct dma_buf *dmabuf;
> + =A0 =A0 =A0 struct file *file;
> +
> + =A0 =A0 =A0 if (WARN_ON(!priv || !ops
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 || !ops->map_dma_buf
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 || !ops->unmap_dma_buf
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 || !ops->release)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ERR_PTR(-EINVAL);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 dmabuf =3D kzalloc(sizeof(struct dma_buf), GFP_KERNEL);
> + =A0 =A0 =A0 if (dmabuf =3D=3D NULL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ERR_PTR(-ENOMEM);
> +
> + =A0 =A0 =A0 dmabuf->priv =3D priv;
> + =A0 =A0 =A0 dmabuf->ops =3D ops;
> + =A0 =A0 =A0 dmabuf->size =3D size;
> +
> + =A0 =A0 =A0 file =3D anon_inode_getfile("dmabuf", &dma_buf_fops, dmabuf=
, flags);
> +
> + =A0 =A0 =A0 dmabuf->file =3D file;
> +
> + =A0 =A0 =A0 mutex_init(&dmabuf->lock);
> + =A0 =A0 =A0 INIT_LIST_HEAD(&dmabuf->attachments);
> +
> + =A0 =A0 =A0 return dmabuf;
> +}
> +EXPORT_SYMBOL_GPL(dma_buf_export);
> +
> +
> +/**
> + * dma_buf_fd - returns a file descriptor for the given dma_buf
> + * @dmabuf: =A0 =A0[in] =A0 =A0pointer to dma_buf for which fd is requir=
ed.
> + *
> + * On success, returns an associated 'fd'. Else, returns error.
> + */
> +int dma_buf_fd(struct dma_buf *dmabuf)
> +{
> + =A0 =A0 =A0 int error, fd;
> +
> + =A0 =A0 =A0 if (!dmabuf || !dmabuf->file)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> +
> + =A0 =A0 =A0 error =3D get_unused_fd();
> + =A0 =A0 =A0 if (error < 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return error;
> + =A0 =A0 =A0 fd =3D error;
> +
> + =A0 =A0 =A0 fd_install(fd, dmabuf->file);
> +
> + =A0 =A0 =A0 return fd;
> +}
> +EXPORT_SYMBOL_GPL(dma_buf_fd);
> +
> +/**
> + * dma_buf_get - returns the dma_buf structure related to an fd
> + * @fd: =A0 =A0 =A0 =A0[in] =A0 =A0fd associated with the dma_buf to be =
returned
> + *
> + * On success, returns the dma_buf structure associated with an fd; uses
> + * file's refcounting done by fget to increase refcount. returns ERR_PTR
> + * otherwise.
> + */
> +struct dma_buf *dma_buf_get(int fd)
> +{
> + =A0 =A0 =A0 struct file *file;
> +
> + =A0 =A0 =A0 file =3D fget(fd);
> +
> + =A0 =A0 =A0 if (!file)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ERR_PTR(-EBADF);
> +
> + =A0 =A0 =A0 if (!is_dma_buf_file(file)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 fput(file);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ERR_PTR(-EINVAL);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 return file->private_data;
> +}
> +EXPORT_SYMBOL_GPL(dma_buf_get);
> +
> +/**
> + * dma_buf_put - decreases refcount of the buffer
> + * @dmabuf: =A0 =A0[in] =A0 =A0buffer to reduce refcount of
> + *
> + * Uses file's refcounting done implicitly by fput()
> + */
> +void dma_buf_put(struct dma_buf *dmabuf)
> +{
> + =A0 =A0 =A0 if (WARN_ON(!dmabuf || !dmabuf->file))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> +
> + =A0 =A0 =A0 fput(dmabuf->file);
> +}
> +EXPORT_SYMBOL_GPL(dma_buf_put);
> +
> +/**
> + * dma_buf_attach - Add the device to dma_buf's attachments list; option=
ally,
> + * calls attach() of dma_buf_ops to allow device-specific attach functio=
nality
> + * @dmabuf: =A0 =A0[in] =A0 =A0buffer to attach device to.
> + * @dev: =A0 =A0 =A0 [in] =A0 =A0device to be attached.
> + *
> + * Returns struct dma_buf_attachment * for this attachment; may return n=
egative
> + * error codes.
> + *
> + */
> +struct dma_buf_attachment *dma_buf_attach(struct dma_buf *dmabuf,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 struct device *dev)
> +{
> + =A0 =A0 =A0 struct dma_buf_attachment *attach;
> + =A0 =A0 =A0 int ret;
> +
> + =A0 =A0 =A0 if (WARN_ON(!dmabuf || !dev || !dmabuf->ops))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ERR_PTR(-EINVAL);
> +
> + =A0 =A0 =A0 attach =3D kzalloc(sizeof(struct dma_buf_attachment), GFP_K=
ERNEL);
> + =A0 =A0 =A0 if (attach =3D=3D NULL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err_alloc;
> +
> + =A0 =A0 =A0 mutex_lock(&dmabuf->lock);
> +
> + =A0 =A0 =A0 attach->dev =3D dev;
> + =A0 =A0 =A0 attach->dmabuf =3D dmabuf;
> + =A0 =A0 =A0 if (dmabuf->ops->attach) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D dmabuf->ops->attach(dmabuf, dev, at=
tach);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ret)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err_attach;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 list_add(&attach->node, &dmabuf->attachments);
> +
> + =A0 =A0 =A0 mutex_unlock(&dmabuf->lock);
> + =A0 =A0 =A0 return attach;
> +
> +err_alloc:
> + =A0 =A0 =A0 return ERR_PTR(-ENOMEM);
> +err_attach:
> + =A0 =A0 =A0 kfree(attach);
> + =A0 =A0 =A0 mutex_unlock(&dmabuf->lock);
> + =A0 =A0 =A0 return ERR_PTR(ret);
> +}
> +EXPORT_SYMBOL_GPL(dma_buf_attach);
> +
> +/**
> + * dma_buf_detach - Remove the given attachment from dmabuf's attachment=
s list;
> + * optionally calls detach() of dma_buf_ops for device-specific detach
> + * @dmabuf: =A0 =A0[in] =A0 =A0buffer to detach from.
> + * @attach: =A0 =A0[in] =A0 =A0attachment to be detached; is free'd afte=
r this call.
> + *
> + */
> +void dma_buf_detach(struct dma_buf *dmabuf, struct dma_buf_attachment *a=
ttach)
> +{
> + =A0 =A0 =A0 if (WARN_ON(!dmabuf || !attach || !dmabuf->ops))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> +
> + =A0 =A0 =A0 mutex_lock(&dmabuf->lock);
> + =A0 =A0 =A0 list_del(&attach->node);
> + =A0 =A0 =A0 if (dmabuf->ops->detach)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dmabuf->ops->detach(dmabuf, attach);
> +
> + =A0 =A0 =A0 mutex_unlock(&dmabuf->lock);
> + =A0 =A0 =A0 kfree(attach);
> +}
> +EXPORT_SYMBOL_GPL(dma_buf_detach);
> +
> +/**
> + * dma_buf_map_attachment - Returns the scatterlist table of the attachm=
ent;
> + * mapped into _device_ address space. Is a wrapper for map_dma_buf() of=
 the
> + * dma_buf_ops.
> + * @attach: =A0 =A0[in] =A0 =A0attachment whose scatterlist is to be ret=
urned
> + * @direction: [in] =A0 =A0direction of DMA transfer
> + *
> + * Returns sg_table containing the scatterlist to be returned; may retur=
n NULL
> + * or ERR_PTR.
> + *
> + */
> +struct sg_table *dma_buf_map_attachment(struct dma_buf_attachment *attac=
h,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 enum dma_data_direction direction)
> +{
> + =A0 =A0 =A0 struct sg_table *sg_table =3D ERR_PTR(-EINVAL);
> +
> + =A0 =A0 =A0 might_sleep();
> +
> + =A0 =A0 =A0 if (WARN_ON(!attach || !attach->dmabuf || !attach->dmabuf->=
ops))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ERR_PTR(-EINVAL);
> +
> + =A0 =A0 =A0 mutex_lock(&attach->dmabuf->lock);
> + =A0 =A0 =A0 if (attach->dmabuf->ops->map_dma_buf)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sg_table =3D attach->dmabuf->ops->map_dma_b=
uf(attach, direction);
> + =A0 =A0 =A0 mutex_unlock(&attach->dmabuf->lock);
> +
> + =A0 =A0 =A0 return sg_table;
> +}
> +EXPORT_SYMBOL_GPL(dma_buf_map_attachment);
> +
> +/**
> + * dma_buf_unmap_attachment - unmaps and decreases usecount of the buffe=
r;might
> + * deallocate the scatterlist associated. Is a wrapper for unmap_dma_buf=
() of
> + * dma_buf_ops.
> + * @attach: =A0 =A0[in] =A0 =A0attachment to unmap buffer from
> + * @sg_table: =A0[in] =A0 =A0scatterlist info of the buffer to unmap
> + *
> + */
> +void dma_buf_unmap_attachment(struct dma_buf_attachment *attach,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct sg_t=
able *sg_table)
> +{
> + =A0 =A0 =A0 if (WARN_ON(!attach || !attach->dmabuf || !sg_table
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 || !attach->dmabuf-=
>ops))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> +
> + =A0 =A0 =A0 mutex_lock(&attach->dmabuf->lock);
> + =A0 =A0 =A0 if (attach->dmabuf->ops->unmap_dma_buf)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 attach->dmabuf->ops->unmap_dma_buf(attach, =
sg_table);
> + =A0 =A0 =A0 mutex_unlock(&attach->dmabuf->lock);
> +
> +}
> +EXPORT_SYMBOL_GPL(dma_buf_unmap_attachment);
> diff --git a/include/linux/dma-buf.h b/include/linux/dma-buf.h
> new file mode 100644
> index 0000000..f8ac076
> --- /dev/null
> +++ b/include/linux/dma-buf.h
> @@ -0,0 +1,176 @@
> +/*
> + * Header file for dma buffer sharing framework.
> + *
> + * Copyright(C) 2011 Linaro Limited. All rights reserved.
> + * Author: Sumit Semwal <sumit.semwal@ti.com>
> + *
> + * Many thanks to linaro-mm-sig list, and specially
> + * Arnd Bergmann <arnd@arndb.de>, Rob Clark <rob@ti.com> and
> + * Daniel Vetter <daniel@ffwll.ch> for their support in creation and
> + * refining of this idea.
> + *
> + * This program is free software; you can redistribute it and/or modify =
it
> + * under the terms of the GNU General Public License version 2 as publis=
hed by
> + * the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful, but W=
ITHOUT
> + * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
> + * FITNESS FOR A PARTICULAR PURPOSE. =A0See the GNU General Public Licen=
se for
> + * more details.
> + *
> + * You should have received a copy of the GNU General Public License alo=
ng with
> + * this program. =A0If not, see <http://www.gnu.org/licenses/>.
> + */
> +#ifndef __DMA_BUF_H__
> +#define __DMA_BUF_H__
> +
> +#include <linux/file.h>
> +#include <linux/err.h>
> +#include <linux/device.h>
> +#include <linux/scatterlist.h>
> +#include <linux/list.h>
> +#include <linux/dma-mapping.h>
> +
> +struct dma_buf;
> +struct dma_buf_attachment;
> +
> +/**
> + * struct dma_buf_ops - operations possible on struct dma_buf
> + * @attach: [optional] allows different devices to 'attach' themselves t=
o the
> + * =A0 =A0 =A0 =A0 given buffer. It might return -EBUSY to signal that b=
acking storage
> + * =A0 =A0 =A0 =A0 is already allocated and incompatible with the requir=
ements
> + * =A0 =A0 =A0 =A0 of requesting device.
> + * @detach: [optional] detach a given device from this buffer.
> + * @map_dma_buf: returns list of scatter pages allocated, increases usec=
ount
> + * =A0 =A0 =A0 =A0 =A0 =A0 =A0of the buffer. Requires atleast one attach=
 to be called
> + * =A0 =A0 =A0 =A0 =A0 =A0 =A0before. Returned sg list should already be=
 mapped into
> + * =A0 =A0 =A0 =A0 =A0 =A0 =A0_device_ address space. This call may slee=
p. May also return
> + * =A0 =A0 =A0 =A0 =A0 =A0 =A0-EINTR. Should return -EINVAL if attach ha=
sn't been called yet.
> + * @unmap_dma_buf: decreases usecount of buffer, might deallocate scatte=
r
> + * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pages.
> + * @release: release this buffer; to be called after the last dma_buf_pu=
t.
> + */
> +struct dma_buf_ops {
> + =A0 =A0 =A0 int (*attach)(struct dma_buf *, struct device *,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct dma_buf_attachment *=
);
> +
> + =A0 =A0 =A0 void (*detach)(struct dma_buf *, struct dma_buf_attachment =
*);
> +
> + =A0 =A0 =A0 /* For {map,unmap}_dma_buf below, any specific buffer attri=
butes
> + =A0 =A0 =A0 =A0* required should get added to device_dma_parameters acc=
essible
> + =A0 =A0 =A0 =A0* via dev->dma_params.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 struct sg_table * (*map_dma_buf)(struct dma_buf_attachment =
*,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 enum dma_data_direction);
> + =A0 =A0 =A0 void (*unmap_dma_buf)(struct dma_buf_attachment *,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 struct sg_table *);
> + =A0 =A0 =A0 /* TODO: Add try_map_dma_buf version, to return immed with =
-EBUSY
> + =A0 =A0 =A0 =A0* if the call would block.
> + =A0 =A0 =A0 =A0*/
> +
> + =A0 =A0 =A0 /* after final dma_buf_put() */
> + =A0 =A0 =A0 void (*release)(struct dma_buf *);
> +
> +};
> +
> +/**
> + * struct dma_buf - shared buffer object
> + * @size: size of the buffer
> + * @file: file pointer used for sharing buffers across, and for refcount=
ing.
> + * @attachments: list of dma_buf_attachment that denotes all devices att=
ached.
> + * @ops: dma_buf_ops associated with this buffer object.
> + * @priv: exporter specific private data for this buffer object.
> + */
> +struct dma_buf {
> + =A0 =A0 =A0 size_t size;
> + =A0 =A0 =A0 struct file *file;
> + =A0 =A0 =A0 struct list_head attachments;
> + =A0 =A0 =A0 const struct dma_buf_ops *ops;

how about having sg_table here also? like this, struct sg_table *sgt;
now dmabuf->priv could have duplicated values.
I know that a private buffer object is set to dmabuf->priv when
dma_buf_export function is called. but when  xxx_acquire_dmabuf
callback of vb2 side is called dmabuf->priv would have sg_table object
returned from dmabuf->ops->map_dma_buf() again to release the sg_table
with dmabuf->ops->unmap_dma_buf(). I'm not sure that this situation
could induce some problem but anyway confusing.

> + =A0 =A0 =A0 /* mutex to serialize list manipulation and other ops */
> + =A0 =A0 =A0 struct mutex lock;
> + =A0 =A0 =A0 void *priv;
> +};
> +
> +/**
> + * struct dma_buf_attachment - holds device-buffer attachment data
> + * @dmabuf: buffer for this attachment.
> + * @dev: device attached to the buffer.
> + * @node: list of dma_buf_attachment.
> + * @priv: exporter specific attachment data.
> + *
> + * This structure holds the attachment information between the dma_buf b=
uffer
> + * and its user device(s). The list contains one attachment struct per d=
evice
> + * attached to the buffer.
> + */
> +struct dma_buf_attachment {
> + =A0 =A0 =A0 struct dma_buf *dmabuf;
> + =A0 =A0 =A0 struct device *dev;
> + =A0 =A0 =A0 struct list_head node;
> + =A0 =A0 =A0 void *priv;
> +};
> +
> +#ifdef CONFIG_DMA_SHARED_BUFFER
> +struct dma_buf_attachment *dma_buf_attach(struct dma_buf *dmabuf,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct device *dev);
> +void dma_buf_detach(struct dma_buf *dmabuf,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct dma_=
buf_attachment *dmabuf_attach);
> +struct dma_buf *dma_buf_export(void *priv, struct dma_buf_ops *ops,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 size_t size, int flags);
> +int dma_buf_fd(struct dma_buf *dmabuf);
> +struct dma_buf *dma_buf_get(int fd);
> +void dma_buf_put(struct dma_buf *dmabuf);
> +
> +struct sg_table *dma_buf_map_attachment(struct dma_buf_attachment *,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 enum dma_data_direction);
> +void dma_buf_unmap_attachment(struct dma_buf_attachment *, struct sg_tab=
le *);
> +#else
> +
> +static inline struct dma_buf_attachment *dma_buf_attach(struct dma_buf *=
dmabuf,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct device *dev)
> +{
> + =A0 =A0 =A0 return ERR_PTR(-ENODEV);
> +}
> +
> +static inline void dma_buf_detach(struct dma_buf *dmabuf,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct =
dma_buf_attachment *dmabuf_attach)
> +{
> + =A0 =A0 =A0 return;
> +}
> +
> +static inline struct dma_buf *dma_buf_export(void *priv,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 struct dma_buf_ops *ops,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 size_t size, int flags)
> +{
> + =A0 =A0 =A0 return ERR_PTR(-ENODEV);
> +}
> +
> +static inline int dma_buf_fd(struct dma_buf *dmabuf)
> +{
> + =A0 =A0 =A0 return -ENODEV;
> +}
> +
> +static inline struct dma_buf *dma_buf_get(int fd)
> +{
> + =A0 =A0 =A0 return ERR_PTR(-ENODEV);
> +}
> +
> +static inline void dma_buf_put(struct dma_buf *dmabuf)
> +{
> + =A0 =A0 =A0 return;
> +}
> +
> +static inline struct sg_table *dma_buf_map_attachment(
> + =A0 =A0 =A0 struct dma_buf_attachment *attach, enum dma_data_direction =
write)
> +{
> + =A0 =A0 =A0 return ERR_PTR(-ENODEV);
> +}
> +
> +static inline void dma_buf_unmap_attachment(struct dma_buf_attachment *a=
ttach,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 struct sg_table *sg)
> +{
> + =A0 =A0 =A0 return;
> +}
> +
> +#endif /* CONFIG_DMA_SHARED_BUFFER */
> +
> +#endif /* __DMA_BUF_H__ */
> --
> 1.7.5.4
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
