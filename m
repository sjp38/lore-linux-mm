Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 2285E6B002E
	for <linux-mm@kvack.org>; Tue, 11 Oct 2011 05:24:56 -0400 (EDT)
From: Sumit Semwal <sumit.semwal@ti.com>
Subject: [RFC 1/2] dma-buf: Introduce dma buffer sharing mechanism
Date: Tue, 11 Oct 2011 14:53:52 +0530
Message-ID: <1318325033-32688-2-git-send-email-sumit.semwal@ti.com>
In-Reply-To: <1318325033-32688-1-git-send-email-sumit.semwal@ti.com>
References: <1318325033-32688-1-git-send-email-sumit.semwal@ti.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, dri-devel@lists.freedesktop.org, linux-media@vger.kernel.org
Cc: linux@arm.linux.org.uk, arnd@arndb.de, jesse.barker@linaro.org, m.szyprowski@samsung.com, rob@ti.com, daniel@ffwll.ch, t.stanislaws@samsung.com, Sumit Semwal <sumit.semwal@ti.com>, Sumit Semwal <sumit.semwal@linaro.org>

This is the first step in defining a dma buffer sharing mechanism.

A new buffer object dma_buf is added, with operations and API to allow easy
sharing of this buffer object across devices.

The framework allows:
- a new buffer-object to be created with fixed size.
- different devices to 'attach' themselves to this buffer, to facilitate
  backing storage negotiation, using dma_buf_attach() API.
- association of a file pointer with each user-buffer and associated
   allocator-defined operations on that buffer. This operation is called the
   'export' operation.
- this exported buffer-object to be shared with the other entity by asking for
   its 'file-descriptor (fd)', and sharing the fd across.
- a received fd to get the buffer object back, where it can be accessed using
   the associated exporter-defined operations.
- the exporter and user to share the scatterlist using get_scatterlist and
   put_scatterlist operations.

Atleast one 'attach()' call is required to be made prior to calling the
get_scatterlist() operation.

Couple of building blocks in get_scatterlist() are added to ease introduction
of sync'ing across exporter and users, and late allocation by the exporter.

mmap() file operation is provided for the associated 'fd', as wrapper over the
optional allocator defined mmap(), to be used by devices that might need one.

More details are there in the documentation patch.

This is based on design suggestions from many people at the mini-summits[1],
most notably from Arnd Bergmann <arnd@arndb.de>, Rob Clark <rob@ti.com> and
Daniel Vetter <daniel@ffwll.ch>.

The implementation is inspired from proof-of-concept patch-set from
Tomasz Stanislawski <t.stanislaws@samsung.com>, who demonstrated buffer sharing
between two v4l2 devices. [2]

[1]: https://wiki.linaro.org/OfficeofCTO/MemoryManagement
[2]: http://lwn.net/Articles/454389

Signed-off-by: Sumit Semwal <sumit.semwal@linaro.org>
Signed-off-by: Sumit Semwal <sumit.semwal@ti.com>
---
 drivers/base/Kconfig    |   10 ++
 drivers/base/Makefile   |    1 +
 drivers/base/dma-buf.c  |  242 +++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/dma-buf.h |  162 +++++++++++++++++++++++++++++++
 4 files changed, 415 insertions(+), 0 deletions(-)
 create mode 100644 drivers/base/dma-buf.c
 create mode 100644 include/linux/dma-buf.h

diff --git a/drivers/base/Kconfig b/drivers/base/Kconfig
index 21cf46f..07d8095 100644
--- a/drivers/base/Kconfig
+++ b/drivers/base/Kconfig
@@ -174,4 +174,14 @@ config SYS_HYPERVISOR
 
 source "drivers/base/regmap/Kconfig"
 
+config DMA_SHARED_BUFFER
+	bool "Buffer framework to be shared between drivers"
+	default n
+	depends on ANON_INODES
+	help
+	  This option enables the framework for buffer-sharing between
+	  multiple drivers. A buffer is associated with a file using driver
+	  APIs extension; the file's descriptor can then be passed on to other
+	  driver.
+
 endmenu
diff --git a/drivers/base/Makefile b/drivers/base/Makefile
index 99a375a..d0df046 100644
--- a/drivers/base/Makefile
+++ b/drivers/base/Makefile
@@ -8,6 +8,7 @@ obj-$(CONFIG_DEVTMPFS)	+= devtmpfs.o
 obj-y			+= power/
 obj-$(CONFIG_HAS_DMA)	+= dma-mapping.o
 obj-$(CONFIG_HAVE_GENERIC_DMA_COHERENT) += dma-coherent.o
+obj-$(CONFIG_DMA_SHARED_BUFFER) += dma-buf.o
 obj-$(CONFIG_ISA)	+= isa.o
 obj-$(CONFIG_FW_LOADER)	+= firmware_class.o
 obj-$(CONFIG_NUMA)	+= node.o
diff --git a/drivers/base/dma-buf.c b/drivers/base/dma-buf.c
new file mode 100644
index 0000000..58c51a0
--- /dev/null
+++ b/drivers/base/dma-buf.c
@@ -0,0 +1,242 @@
+/*
+ * Framework for buffer objects that can be shared across devices/subsystems.
+ *
+ * Copyright(C) 2011 Linaro Limited. All rights reserved.
+ * Author: Sumit Semwal <sumit.semwal@ti.com>
+ *
+ * Many thanks to linaro-mm-sig list, and specially
+ * Arnd Bergmann <arnd@arndb.de>, Rob Clark <rob@ti.com> and
+ * Daniel Vetter <daniel@ffwll.ch> for their support in creation and
+ * refining of this idea.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published by
+ * the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program.  If not, see <http://www.gnu.org/licenses/>.
+ */
+
+#include <linux/fs.h>
+#include <linux/slab.h>
+#include <linux/dma-buf.h>
+#include <linux/anon_inodes.h>
+
+static inline int is_dma_buf_file(struct file *);
+
+static int dma_buf_mmap(struct file *file, struct vm_area_struct *vma)
+{
+	struct dma_buf *dmabuf;
+
+	if (!is_dma_buf_file(file))
+		return -EINVAL;
+
+	dmabuf = file->private_data;
+
+	if (!dmabuf->ops->mmap)
+		return -EINVAL;
+
+	return dmabuf->ops->mmap(dmabuf, vma);
+}
+
+static int dma_buf_release(struct inode *inode, struct file *file)
+{
+	struct dma_buf *dmabuf;
+
+	if (!is_dma_buf_file(file))
+		return -EINVAL;
+
+	dmabuf = file->private_data;
+
+	dmabuf->ops->release(dmabuf);
+	kfree(dmabuf);
+	return 0;
+}
+
+static const struct file_operations dma_buf_fops = {
+	.mmap		= dma_buf_mmap,
+	.release	= dma_buf_release,
+};
+
+/*
+ * is_dma_buf_file - Check if struct file* is associated with dma_buf
+ */
+static inline int is_dma_buf_file(struct file *file)
+{
+	return file->f_op == &dma_buf_fops;
+}
+
+/**
+ * dma_buf_export - Creates a new dma_buf, and associates an anon file
+ * with this buffer,so it can be exported.
+ * Also connect the allocator specific data and ops to the buffer.
+ *
+ * @priv:	[in]	Attach private data of allocator to this buffer
+ * @ops:	[in]	Attach allocator-defined dma buf ops to the new buffer.
+ * @flags:	[in]	mode flags for the file.
+ *
+ * Returns, on success, a newly created dma_buf object, which wraps the
+ * supplied private data and operations for dma_buf_ops. On failure to
+ * allocate the dma_buf object, it can return NULL.
+ *
+ */
+struct dma_buf *dma_buf_export(void *priv, struct dma_buf_ops *ops,
+				int flags)
+{
+	struct dma_buf *dmabuf;
+	struct file *file;
+
+	BUG_ON(!priv || !ops);
+
+	dmabuf = kzalloc(sizeof(struct dma_buf), GFP_KERNEL);
+	if (dmabuf == NULL)
+		return dmabuf;
+
+	dmabuf->priv = priv;
+	dmabuf->ops = ops;
+
+	file = anon_inode_getfile("dmabuf", &dma_buf_fops, dmabuf, flags);
+
+	dmabuf->file = file;
+
+	mutex_init(&dmabuf->lock);
+	INIT_LIST_HEAD(&dmabuf->attachments);
+
+	return dmabuf;
+}
+EXPORT_SYMBOL(dma_buf_export);
+
+
+/**
+ * dma_buf_fd - returns a file descriptor for the given dma_buf
+ * @dmabuf:	[in]	pointer to dma_buf for which fd is required.
+ *
+ * On success, returns an associated 'fd'. Else, returns error.
+ */
+int dma_buf_fd(struct dma_buf *dmabuf)
+{
+	int error, fd;
+
+	if (!dmabuf->file)
+		return -EINVAL;
+
+	error = get_unused_fd_flags(0);
+	if (error < 0)
+		return error;
+	fd = error;
+
+	fd_install(fd, dmabuf->file);
+
+	return fd;
+}
+EXPORT_SYMBOL(dma_buf_fd);
+
+/**
+ * dma_buf_get - returns the dma_buf structure related to an fd
+ * @fd:	[in]	fd associated with the dma_buf to be returned
+ *
+ * On success, returns the dma_buf structure associated with an fd; uses
+ * file's refcounting done by fget to increase refcount. returns ERR_PTR
+ * otherwise.
+ */
+struct dma_buf *dma_buf_get(int fd)
+{
+	struct file *file;
+
+	file = fget(fd);
+
+	if (!file)
+		return ERR_PTR(-EBADF);
+
+	if (!is_dma_buf_file(file)) {
+		fput(file);
+		return ERR_PTR(-EINVAL);
+	}
+
+	return file->private_data;
+}
+EXPORT_SYMBOL(dma_buf_get);
+
+/**
+ * dma_buf_put - decreases refcount of the buffer
+ * @dmabuf:	[in]	buffer to reduce refcount of
+ *
+ * Uses file's refcounting done implicitly by fput()
+ */
+void dma_buf_put(struct dma_buf *dmabuf)
+{
+	BUG_ON(!dmabuf->file);
+
+	fput(dmabuf->file);
+
+	return;
+}
+EXPORT_SYMBOL(dma_buf_put);
+
+/**
+ * dma_buf_attach - Add the device to dma_buf's attachments list; optionally,
+ * calls attach() of dma_buf_ops to allow device-specific attach functionality
+ * @dmabuf:	[in]	buffer to attach device to.
+ * @dev:	[in]	device to be attached.
+ *
+ * Returns struct dma_buf_attachment * for this attachment; may return NULL.
+ *
+ */
+struct dma_buf_attachment *dma_buf_attach(struct dma_buf *dmabuf,
+						struct device *dev)
+{
+	struct dma_buf_attachment *attach;
+	int ret;
+
+	BUG_ON(!dmabuf || !dev);
+
+	mutex_lock(&dmabuf->lock);
+
+	attach = kzalloc(sizeof(struct dma_buf_attachment), GFP_KERNEL);
+	if (attach == NULL)
+		goto err_alloc;
+
+	attach->dev = dev;
+	if (dmabuf->ops->attach) {
+		ret = dmabuf->ops->attach(dmabuf, dev, attach);
+		if (!ret)
+			goto err_attach;
+	}
+	list_add(&attach->node, &dmabuf->attachments);
+
+err_alloc:
+	mutex_unlock(&dmabuf->lock);
+	return attach;
+err_attach:
+	kfree(attach);
+	mutex_unlock(&dmabuf->lock);
+	return ERR_PTR(ret);
+}
+EXPORT_SYMBOL(dma_buf_attach);
+
+/**
+ * dma_buf_detach - Remove the given attachment from dmabuf's attachments list;
+ * optionally calls detach() of dma_buf_ops for device-specific detach
+ * @dmabuf:	[in]	buffer to detach from.
+ * @attach:	[in]	attachment to be detached; is free'd after this call.
+ *
+ */
+void dma_buf_detach(struct dma_buf *dmabuf, struct dma_buf_attachment *attach)
+{
+	BUG_ON(!dmabuf || !attach);
+
+	mutex_lock(&dmabuf->lock);
+	list_del(&attach->node);
+	if (dmabuf->ops->detach)
+		dmabuf->ops->detach(dmabuf, attach);
+
+	kfree(attach);
+	mutex_unlock(&dmabuf->lock);
+	return;
+}
+EXPORT_SYMBOL(dma_buf_detach);
diff --git a/include/linux/dma-buf.h b/include/linux/dma-buf.h
new file mode 100644
index 0000000..5bdf16a
--- /dev/null
+++ b/include/linux/dma-buf.h
@@ -0,0 +1,162 @@
+/*
+ * Header file for dma buffer sharing framework.
+ *
+ * Copyright(C) 2011 Linaro Limited. All rights reserved.
+ * Author: Sumit Semwal <sumit.semwal@ti.com>
+ *
+ * Many thanks to linaro-mm-sig list, and specially
+ * Arnd Bergmann <arnd@arndb.de>, Rob Clark <rob@ti.com> and
+ * Daniel Vetter <daniel@ffwll.ch> for their support in creation and
+ * refining of this idea.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published by
+ * the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program.  If not, see <http://www.gnu.org/licenses/>.
+ */
+#ifndef __DMA_BUF_H__
+#define __DMA_BUF_H__
+
+#include <linux/file.h>
+#include <linux/err.h>
+#include <linux/device.h>
+#include <linux/scatterlist.h>
+#include <linux/list.h>
+#include <linux/dma-mapping.h>
+
+struct dma_buf;
+
+/**
+ * struct dma_buf_attachment - holds device-buffer attachment data
+ * @dmabuf: buffer for this attachment.
+ * @dev: device attached to the buffer.
+ * @node: list_head to allow manipulation of list of dma_buf_attachment.
+ * @priv: exporter-specific attachment data.
+ */
+struct dma_buf_attachment {
+	struct dma_buf *dmabuf;
+	struct device *dev;
+	struct list_head node;
+	void *priv;
+};
+
+/**
+ * struct dma_buf_ops - operations possible on struct dma_buf
+ * @create: creates a struct dma_buf of a fixed size. Actual allocation
+ *	    does not happen here.
+ * @attach: allows different devices to 'attach' themselves to the given
+ *	    buffer. It might return -EBUSY to signal that backing storage
+ *	    is already allocated and incompatible with the requirements
+ *	    of requesting device. [optional]
+ * @detach: detach a given device from this buffer. [optional]
+ * @get_scatterlist: returns list of scatter pages allocated, increases
+ *		     usecount of the buffer. Requires atleast one attach to be
+ *		     called before. Returned sg list should already be mapped
+ *		     into _device_ address space.
+ * @put_scatterlist: decreases usecount of buffer, might deallocate scatter
+ *		     pages.
+ * @mmap: memory map this buffer - optional.
+ * @release: release this buffer; to be called after the last dma_buf_put.
+ * @sync_sg_for_cpu: sync the sg list for cpu.
+ * @sync_sg_for_device: synch the sg list for device.
+ */
+struct dma_buf_ops {
+	int (*attach)(struct dma_buf *, struct device *,
+			struct dma_buf_attachment *);
+
+	void (*detach)(struct dma_buf *, struct dma_buf_attachment *);
+
+	/* For {get,put}_scatterlist below, any specific buffer attributes
+	 * required should get added to device_dma_parameters accessible
+	 * via dev->dma_params.
+	 */
+	struct scatterlist * (*get_scatterlist)(struct dma_buf_attachment *,
+						enum dma_data_direction,
+						int *nents);
+	void (*put_scatterlist)(struct dma_buf_attachment *,
+						struct scatterlist *,
+						int nents);
+	/* TODO: Add interruptible and interruptible_timeout versions */
+
+	/* allow mmap optionally for devices that need it */
+	int (*mmap)(struct dma_buf *, struct vm_area_struct *);
+	/* after final dma_buf_put() */
+	void (*release)(struct dma_buf *);
+
+	/* allow allocator to take care of cache ops */
+	void (*sync_sg_for_cpu) (struct dma_buf *, struct device *);
+	void (*sync_sg_for_device)(struct dma_buf *, struct device *);
+};
+
+/**
+ * struct dma_buf - shared buffer object
+ * @file: file pointer used for sharing buffers across, and for refcounting.
+ * @attachments: list of dma_buf_attachment that denotes all devices attached.
+ * @ops: dma_buf_ops associated with this buffer object
+ * @priv: user specific private data
+ */
+struct dma_buf {
+	size_t size;
+	struct file *file;
+	struct list_head attachments;
+	const struct dma_buf_ops *ops;
+	/* mutex to serialize list manipulation and other ops */
+	struct mutex lock;
+	void *priv;
+};
+
+#ifdef CONFIG_DMA_SHARED_BUFFER
+struct dma_buf_attachment *dma_buf_attach(struct dma_buf *dmabuf,
+							struct device *dev);
+void dma_buf_detach(struct dma_buf *dmabuf,
+				struct dma_buf_attachment *dmabuf_attach);
+struct dma_buf *dma_buf_export(void *priv, struct dma_buf_ops *ops, int flags);
+int dma_buf_fd(struct dma_buf *dmabuf);
+struct dma_buf *dma_buf_get(int fd);
+void dma_buf_put(struct dma_buf *dmabuf);
+
+#else
+
+static inline struct dma_buf_attachment *dma_buf_attach(struct dma_buf *dmabuf,
+							struct device *dev)
+{
+	return ERR_PTR(-ENODEV);
+}
+
+static inline void dma_buf_detach(struct dma_buf *dmabuf,
+				  struct dma_buf_attachment *dmabuf_attach)
+{
+	return;
+}
+
+static inline struct dma_buf *dma_buf_export(void *priv,
+						struct dma_buf_ops *ops,
+						int flags)
+{
+	return ERR_PTR(-ENODEV);
+}
+
+static inline int dma_buf_fd(struct dma_buf *dmabuf)
+{
+	return -ENODEV;
+}
+
+static inline struct dma_buf *dma_buf_get(int fd)
+{
+	return ERR_PTR(-ENODEV);
+}
+
+static inline void dma_buf_put(struct dma_buf *dmabuf)
+{
+	return;
+}
+#endif /* CONFIG_DMA_SHARED_BUFFER */
+
+#endif /* __DMA_BUF_H__ */
-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
