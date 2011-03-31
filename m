Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 932978D0049
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 09:16:19 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from spt2.w1.samsung.com ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LIX006AHBIYFT50@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 31 Mar 2011 14:16:13 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LIX00351BIYLP@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 31 Mar 2011 14:16:11 +0100 (BST)
Date: Thu, 31 Mar 2011 15:16:07 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH 11/12] v4l: videobuf2: add CMA allocator (for testing)
In-reply-to: <1301577368-16095-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1301577368-16095-12-git-send-email-m.szyprowski@samsung.com>
References: <1301577368-16095-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-samsung-soc@vger.kernel.org, linux-media@vger.kernel.org, linux-mm@kvack.org
Cc: Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Johan MOSSBERG <johan.xx.mossberg@stericsson.com>, Mel Gorman <mel@csn.ul.ie>, Pawel Osciak <pawel@osciak.com>

Add support for the CMA contiguous memory allocator to videobuf2.

Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
CC: Pawel Osciak <pawel@osciak.com>
CC: Michal Nazarewicz <mina86@mina86.com>
---
 drivers/media/video/Kconfig         |    6 +
 drivers/media/video/Makefile        |    1 +
 drivers/media/video/videobuf2-cma.c |  227 +++++++++++++++++++++++++++++++++++
 include/media/videobuf2-cma.h       |   40 ++++++
 4 files changed, 274 insertions(+), 0 deletions(-)
 create mode 100644 drivers/media/video/videobuf2-cma.c
 create mode 100644 include/media/videobuf2-cma.h

diff --git a/drivers/media/video/Kconfig b/drivers/media/video/Kconfig
index 4498b94..d80c9d6 100644
--- a/drivers/media/video/Kconfig
+++ b/drivers/media/video/Kconfig
@@ -66,6 +66,12 @@ config VIDEOBUF2_DMA_SG
 	select VIDEOBUF2_CORE
 	select VIDEOBUF2_MEMOPS
 	tristate
+
+config VIDEOBUF2_CMA
+	depends on CMA
+	select VIDEOBUF2_CORE
+	select VIDEOBUF2_MEMOPS
+	tristate
 #
 # Multimedia Video device configuration
 #
diff --git a/drivers/media/video/Makefile b/drivers/media/video/Makefile
index ace5d8b..86e98df 100644
--- a/drivers/media/video/Makefile
+++ b/drivers/media/video/Makefile
@@ -118,6 +118,7 @@ obj-$(CONFIG_VIDEOBUF2_MEMOPS)		+= videobuf2-memops.o
 obj-$(CONFIG_VIDEOBUF2_VMALLOC)		+= videobuf2-vmalloc.o
 obj-$(CONFIG_VIDEOBUF2_DMA_CONTIG)	+= videobuf2-dma-contig.o
 obj-$(CONFIG_VIDEOBUF2_DMA_SG)		+= videobuf2-dma-sg.o
+obj-$(CONFIG_VIDEOBUF2_CMA)		+= videobuf2-cma.o
 
 obj-$(CONFIG_V4L2_MEM2MEM_DEV) += v4l2-mem2mem.o
 
diff --git a/drivers/media/video/videobuf2-cma.c b/drivers/media/video/videobuf2-cma.c
new file mode 100644
index 0000000..5dc7e89
--- /dev/null
+++ b/drivers/media/video/videobuf2-cma.c
@@ -0,0 +1,227 @@
+/*
+ * videobuf2-cma.c - CMA memory allocator for videobuf2
+ *
+ * Copyright (C) 2010-2011 Samsung Electronics
+ *
+ * Author: Pawel Osciak <p.osciak@samsung.com>
+ *	   Marek Szyprowski <m.szyprowski@samsung.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation.
+ */
+
+#include <linux/module.h>
+#include <linux/slab.h>
+#include <linux/cma.h>
+#include <linux/mm.h>
+#include <linux/sched.h>
+#include <linux/file.h>
+
+#include <media/videobuf2-core.h>
+#include <media/videobuf2-memops.h>
+
+#include <asm/io.h>
+
+struct vb2_cma_conf {
+	struct device		*dev;
+	const char		*type;
+	unsigned long		alignment;
+};
+
+struct vb2_cma_buf {
+	struct vb2_cma_conf		*conf;
+	struct cm			*cm;
+	dma_addr_t			paddr;
+	unsigned long			size;
+	struct vm_area_struct		*vma;
+	atomic_t			refcount;
+	struct vb2_vmarea_handler	handler;
+};
+
+static void vb2_cma_put(void *buf_priv);
+
+static void *vb2_cma_alloc(void *alloc_ctx, unsigned long size)
+{
+	struct vb2_cma_conf *conf = alloc_ctx;
+	struct vb2_cma_buf *buf;
+
+	buf = kzalloc(sizeof *buf, GFP_KERNEL);
+	if (!buf)
+		return ERR_PTR(-ENOMEM);
+
+	buf->cm = cma_alloc(conf->dev, conf->type, size, conf->alignment);
+	if (IS_ERR(buf->cm)) {
+		printk(KERN_ERR "cma_alloc of size %ld failed\n", size);
+		kfree(buf);
+		return ERR_PTR(-ENOMEM);
+	}
+	buf->paddr = cm_pin(buf->cm);
+	buf->conf = conf;
+	buf->size = size;
+
+	buf->handler.refcount = &buf->refcount;
+	buf->handler.put = vb2_cma_put;
+	buf->handler.arg = buf;
+
+	atomic_inc(&buf->refcount);
+
+	return buf;
+}
+
+static void vb2_cma_put(void *buf_priv)
+{
+	struct vb2_cma_buf *buf = buf_priv;
+
+	if (atomic_dec_and_test(&buf->refcount)) {
+		cm_unpin(buf->cm);
+		cma_free(buf->cm);
+		kfree(buf);
+	}
+}
+
+static void *vb2_cma_cookie(void *buf_priv)
+{
+	struct vb2_cma_buf *buf = buf_priv;
+
+	return (void *)buf->paddr;
+}
+
+static unsigned int vb2_cma_num_users(void *buf_priv)
+{
+	struct vb2_cma_buf *buf = buf_priv;
+
+	return atomic_read(&buf->refcount);
+}
+
+static int vb2_cma_mmap(void *buf_priv, struct vm_area_struct *vma)
+{
+	struct vb2_cma_buf *buf = buf_priv;
+
+	if (!buf) {
+		printk(KERN_ERR "No buffer to map\n");
+		return -EINVAL;
+	}
+
+	return vb2_mmap_pfn_range(vma, buf->paddr, buf->size,
+				  &vb2_common_vm_ops, &buf->handler);
+}
+
+static void *vb2_cma_get_userptr(void *alloc_ctx, unsigned long vaddr,
+				 unsigned long size, int write)
+{
+	struct vb2_cma_buf *buf;
+	struct vm_area_struct *vma;
+	dma_addr_t paddr = 0;
+	int ret;
+
+	buf = kzalloc(sizeof *buf, GFP_KERNEL);
+	if (!buf)
+		return ERR_PTR(-ENOMEM);
+
+	ret = vb2_get_contig_userptr(vaddr, size, &vma, &paddr);
+	if (ret) {
+		printk(KERN_ERR "Failed acquiring VMA for vaddr 0x%08lx\n",
+				vaddr);
+		kfree(buf);
+		return ERR_PTR(ret);
+	}
+
+	buf->size = size;
+	buf->paddr = paddr;
+	buf->vma = vma;
+
+	return buf;
+}
+
+static void vb2_cma_put_userptr(void *mem_priv)
+{
+	struct vb2_cma_buf *buf = mem_priv;
+
+	if (!buf)
+		return;
+
+	vb2_put_vma(buf->vma);
+	kfree(buf);
+}
+
+static void *vb2_cma_vaddr(void *mem_priv)
+{
+	struct vb2_cma_buf *buf = mem_priv;
+	if (!buf)
+		return 0;
+
+	return phys_to_virt(buf->paddr);
+}
+
+const struct vb2_mem_ops vb2_cma_memops = {
+	.alloc		= vb2_cma_alloc,
+	.put		= vb2_cma_put,
+	.cookie		= vb2_cma_cookie,
+	.mmap		= vb2_cma_mmap,
+	.get_userptr	= vb2_cma_get_userptr,
+	.put_userptr	= vb2_cma_put_userptr,
+	.num_users	= vb2_cma_num_users,
+	.vaddr		= vb2_cma_vaddr,
+};
+EXPORT_SYMBOL_GPL(vb2_cma_memops);
+
+void *vb2_cma_init(struct device *dev, const char *type,
+					unsigned long alignment)
+{
+	struct vb2_cma_conf *conf;
+
+	conf = kzalloc(sizeof *conf, GFP_KERNEL);
+	if (!conf)
+		return ERR_PTR(-ENOMEM);
+
+	conf->dev = dev;
+	conf->type = type;
+	conf->alignment = alignment;
+
+	return conf;
+}
+EXPORT_SYMBOL_GPL(vb2_cma_init);
+
+void vb2_cma_cleanup(void *conf)
+{
+	kfree(conf);
+}
+EXPORT_SYMBOL_GPL(vb2_cma_cleanup);
+
+void **vb2_cma_init_multi(struct device *dev,
+					  unsigned int num_planes,
+					  const char *types[],
+					  unsigned long alignments[])
+{
+	struct vb2_cma_conf *cma_conf;
+	void **alloc_ctxes;
+	unsigned int i;
+
+	alloc_ctxes = kzalloc((sizeof *alloc_ctxes + sizeof *cma_conf)
+				* num_planes, GFP_KERNEL);
+	if (!alloc_ctxes)
+		return ERR_PTR(-ENOMEM);
+
+	cma_conf = (void *)(alloc_ctxes + num_planes);
+
+	for (i = 0; i < num_planes; ++i, ++cma_conf) {
+		alloc_ctxes[i] = cma_conf;
+		cma_conf->dev = dev;
+		cma_conf->type = types[i];
+		cma_conf->alignment = alignments[i];
+	}
+
+	return alloc_ctxes;
+}
+EXPORT_SYMBOL_GPL(vb2_cma_init_multi);
+
+void vb2_cma_cleanup_multi(void **alloc_ctxes)
+{
+	kfree(alloc_ctxes);
+}
+EXPORT_SYMBOL_GPL(vb2_cma_cleanup_multi);
+
+MODULE_DESCRIPTION("CMA allocator handling routines for videobuf2");
+MODULE_AUTHOR("Pawel Osciak");
+MODULE_LICENSE("GPL");
diff --git a/include/media/videobuf2-cma.h b/include/media/videobuf2-cma.h
new file mode 100644
index 0000000..ba8dad5
--- /dev/null
+++ b/include/media/videobuf2-cma.h
@@ -0,0 +1,40 @@
+/*
+ * videobuf2-cma.h - CMA memory allocator for videobuf2
+ *
+ * Copyright (C) 2010-2011 Samsung Electronics
+ *
+ * Author: Pawel Osciak <p.osciak@samsung.com>
+ *	   Marek Szyprowski <m.szyprowski@samsung.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation.
+ */
+
+#ifndef _MEDIA_VIDEOBUF2_CMA_H
+#define _MEDIA_VIDEOBUF2_CMA_H
+
+#include <media/videobuf2-core.h>
+
+static inline unsigned long vb2_cma_plane_paddr(struct vb2_buffer *vb,
+						unsigned int plane_no)
+{
+	return (unsigned long)vb2_plane_cookie(vb, plane_no);
+}
+
+struct vb2_alloc_ctx *vb2_cma_init(struct device *dev, const char *type,
+					unsigned long alignment);
+void vb2_cma_cleanup(struct vb2_alloc_ctx *alloc_ctx);
+
+struct vb2_alloc_ctx **vb2_cma_init_multi(struct device *dev,
+				  unsigned int num_planes, const char *types[],
+				  unsigned long alignments[]);
+void vb2_cma_cleanup_multi(struct vb2_alloc_ctx **alloc_ctxes);
+
+struct vb2_alloc_ctx *vb2_cma_init(struct device *dev, const char *type,
+					unsigned long alignment);
+void vb2_cma_cleanup(struct vb2_alloc_ctx *alloc_ctx);
+
+extern const struct vb2_mem_ops vb2_cma_memops;
+
+#endif
-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
