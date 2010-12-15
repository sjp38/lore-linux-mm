Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 5B0736B009D
	for <linux-mm@kvack.org>; Wed, 15 Dec 2010 15:38:42 -0500 (EST)
Received: from spt2.w1.samsung.com (mailout2.w1.samsung.com [210.118.77.12])
 by mailout2.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LDH00GQBLCDZR@mailout2.w1.samsung.com> for linux-mm@kvack.org;
 Wed, 15 Dec 2010 20:38:37 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LDH00HMELCCI7@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 15 Dec 2010 20:38:37 +0000 (GMT)
Date: Wed, 15 Dec 2010 21:34:31 +0100
From: Michal Nazarewicz <m.nazarewicz@samsung.com>
Subject: [PATCHv8 11/12] mm: cma: Test device and application added
In-reply-to: <cover.1292443200.git.m.nazarewicz@samsung.com>
Message-id: 
 <24ee8d41cc16cb5a0f1836754ca4d1c17abfb4d9.1292443200.git.m.nazarewicz@samsung.com>
MIME-version: 1.0
Content-type: TEXT/PLAIN
Content-transfer-encoding: 7BIT
References: <cover.1292443200.git.m.nazarewicz@samsung.com>
Sender: owner-linux-mm@kvack.org
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Johan MOSSBERG <johan.xx.mossberg@stericsson.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mel@csn.ul.ie>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This patch adds a "cma" misc device which lets user space use the
CMA API.  This device is meant for testing.  A testing application
is also provided.

Signed-off-by: Michal Nazarewicz <m.nazarewicz@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 drivers/misc/Kconfig   |   28 +++
 drivers/misc/Makefile  |    1 +
 drivers/misc/cma-dev.c |  238 +++++++++++++++++++++++++
 include/linux/cma.h    |   29 +++
 tools/cma/cma-test.c   |  457 ++++++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 753 insertions(+), 0 deletions(-)
 create mode 100644 drivers/misc/cma-dev.c
 create mode 100644 tools/cma/cma-test.c

diff --git a/drivers/misc/Kconfig b/drivers/misc/Kconfig
index 1e1a4be..b90e36b 100644
--- a/drivers/misc/Kconfig
+++ b/drivers/misc/Kconfig
@@ -458,4 +458,32 @@ source "drivers/misc/cb710/Kconfig"
 source "drivers/misc/iwmc3200top/Kconfig"
 source "drivers/misc/ti-st/Kconfig"
 
+# Selet this for platforms/machines that implemented code making
+# the CMA test device usable.
+config CMA_DEVICE_POSSIBLE
+	bool
+
+config CMA_DEVICE
+	tristate "CMA test device (DEVELOPEMENT)"
+	depends on CMA && CMA_DEVICE_POSSIBLE
+	help
+	  The CMA misc device allows allocating contiguous memory areas
+	  from user space.  This is for testing of the CMA framework.
+
+	  If unsure, say "n"
+
+# Selet this for platforms/machines that implemented code making
+# the CMA test device usable.
+config CMA_DEVICE_POSSIBLE
+	bool
+
+config CMA_DEVICE
+	tristate "CMA test device (DEVELOPEMENT)"
+	depends on CMA && CMA_DEVICE_POSSIBLE
+	help
+	  The CMA misc device allows allocating contiguous memory areas
+	  from user space.  This is for testing of the CMA framework.
+
+	  If unsure, say "n"
+
 endif # MISC_DEVICES
diff --git a/drivers/misc/Makefile b/drivers/misc/Makefile
index 98009cc..f8eadd4 100644
--- a/drivers/misc/Makefile
+++ b/drivers/misc/Makefile
@@ -42,3 +42,4 @@ obj-$(CONFIG_ARM_CHARLCD)	+= arm-charlcd.o
 obj-$(CONFIG_PCH_PHUB)		+= pch_phub.o
 obj-y				+= ti-st/
 obj-$(CONFIG_AB8500_PWM)	+= ab8500-pwm.o
+obj-$(CONFIG_CMA_DEVICE)	+= cma-dev.o
diff --git a/drivers/misc/cma-dev.c b/drivers/misc/cma-dev.c
new file mode 100644
index 0000000..6c36064
--- /dev/null
+++ b/drivers/misc/cma-dev.c
@@ -0,0 +1,238 @@
+/*
+ * Contiguous Memory Allocator userspace driver
+ * Copyright (c) 2010 by Samsung Electronics.
+ * Written by Michal Nazarewicz (m.nazarewicz@samsung.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License as
+ * published by the Free Software Foundation; either version 2 of the
+ * License or (at your optional) any later version of the license.
+ */
+
+#define pr_fmt(fmt) "cma: " fmt
+
+#ifdef CONFIG_CMA_DEBUG
+#  define DEBUG
+#endif
+
+#include <linux/errno.h>       /* Error numbers */
+#include <linux/err.h>         /* IS_ERR_VALUE() */
+#include <linux/fs.h>          /* struct file */
+#include <linux/mm.h>          /* Memory stuff */
+#include <linux/mman.h>
+#include <linux/slab.h>
+#include <linux/module.h>      /* Standard module stuff */
+#include <linux/device.h>      /* struct device, dev_dbg() */
+#include <linux/types.h>       /* Just to be safe ;) */
+#include <linux/uaccess.h>     /* __copy_{to,from}_user */
+#include <linux/miscdevice.h>  /* misc_register() and company */
+
+#include <linux/cma.h>
+
+#include <plat/cma-stub.h>
+
+static int  cma_file_open(struct inode *inode, struct file *file);
+static int  cma_file_release(struct inode *inode, struct file *file);
+static long cma_file_ioctl(struct file *file, unsigned cmd, unsigned long arg);
+static int  cma_file_mmap(struct file *file, struct vm_area_struct *vma);
+
+static struct miscdevice cma_miscdev = {
+	.minor = MISC_DYNAMIC_MINOR,
+	.name  = "cma",
+	.fops  = &(const struct file_operations) {
+		.owner          = THIS_MODULE,
+		.open           = cma_file_open,
+		.release        = cma_file_release,
+		.unlocked_ioctl = cma_file_ioctl,
+		.mmap           = cma_file_mmap,
+	},
+};
+#define cma_dev (cma_miscdev.this_device)
+
+struct cma_private_data {
+	struct cm	*cm;
+	unsigned long	size;
+	unsigned long	phys;
+};
+
+static int  cma_file_open(struct inode *inode, struct file *file)
+{
+	struct cma_private_data *prv;
+
+	dev_dbg(cma_dev, "%s(%p)\n", __func__, (void *)file);
+
+	if (!cma_ctx)
+		return -EOPNOTSUPP;
+
+	prv = kzalloc(sizeof *prv, GFP_KERNEL);
+	if (!prv)
+		return -ENOMEM;
+
+	file->private_data = prv;
+
+	return 0;
+}
+
+static int  cma_file_release(struct inode *inode, struct file *file)
+{
+	struct cma_private_data *prv = file->private_data;
+
+	dev_dbg(cma_dev, "%s(%p)\n", __func__, (void *)file);
+
+	if (prv->cm) {
+		cm_unpin(prv->cm);
+		cm_free(prv->cm);
+	}
+	kfree(prv);
+
+	return 0;
+}
+
+static long cma_file_ioctl_req(struct cma_private_data *prv, unsigned long arg)
+{
+	struct cma_alloc_request req;
+	struct cm *cm;
+
+	dev_dbg(cma_dev, "%s()\n", __func__);
+
+	if (!arg)
+		return -EINVAL;
+
+	if (copy_from_user(&req, (void *)arg, sizeof req))
+		return -EFAULT;
+
+	if (req.magic != CMA_MAGIC)
+		return -ENOTTY;
+
+	/* May happen on 32 bit system. */
+	if (req.size > ~(unsigned long)0 || req.alignment > ~(unsigned long)0)
+		return -EINVAL;
+
+	req.size = PAGE_ALIGN(req.size);
+	if (req.size > ~(unsigned long)0)
+		return -EINVAL;
+
+	cm = cm_alloc(cma_ctx, req.size, req.alignment);
+	if (IS_ERR(cm))
+		return PTR_ERR(cm);
+
+	prv->phys = cm_pin(cm);
+	prv->size = req.size;
+	req.start = prv->phys;
+	if (copy_to_user((void *)arg, &req, sizeof req)) {
+		cm_free(cm);
+		return -EFAULT;
+	}
+	prv->cm    = cm;
+
+	dev_dbg(cma_dev, "allocated %p@%p\n",
+		(void *)prv->size, (void *)prv->phys);
+
+	return 0;
+}
+
+static long
+cma_file_ioctl_pattern(struct cma_private_data *prv, unsigned long arg)
+{
+	unsigned long *_it, *it, *end, v;
+
+	dev_dbg(cma_dev, "%s(%s)\n", __func__, arg ? "fill" : "verify");
+
+	_it = phys_to_virt(prv->phys);
+	end = _it + prv->size / sizeof *_it;
+
+	if (arg)
+		for (v = 0, it = _it; it != end; ++v, ++it)
+			*it = v;
+
+	for (v = 0, it = _it; it != end; ++v, ++it)
+		if (*it != v)
+			goto error;
+
+	return prv->size;
+
+error:
+	dev_dbg(cma_dev, "at %p + %x got %lx, expected %lx\n",
+		(void *)_it, (it - _it) * sizeof *it, *it, v);
+	print_hex_dump(KERN_DEBUG, "cma: ", DUMP_PREFIX_ADDRESS,
+		       16, sizeof *it, it,
+		       min_t(size_t, 128, (end - it) * sizeof *it), 0);
+	return (it - _it) * sizeof *it;
+}
+
+static long cma_file_ioctl_dump(struct cma_private_data *prv, unsigned long len)
+{
+	unsigned long *it;
+
+	dev_dbg(cma_dev, "%s(%p)\n", __func__, (void *)len);
+
+	it    = phys_to_virt(prv->phys);
+	len   = min(len & ~(sizeof *it - 1), prv->size);
+	print_hex_dump(KERN_DEBUG, "cma: ", DUMP_PREFIX_ADDRESS,
+		       16, sizeof *it, it, len, 0);
+
+	return 0;
+}
+
+static long cma_file_ioctl(struct file *file, unsigned cmd, unsigned long arg)
+{
+	struct cma_private_data *prv = file->private_data;
+
+	dev_dbg(cma_dev, "%s(%p)\n", __func__, (void *)file);
+
+	if ((cmd == IOCTL_CMA_ALLOC) != !prv->cm)
+		return -EBADFD;
+
+	switch (cmd) {
+	case IOCTL_CMA_ALLOC:
+		return cma_file_ioctl_req(prv, arg);
+
+	case IOCTL_CMA_PATTERN:
+		return cma_file_ioctl_pattern(prv, arg);
+
+	case IOCTL_CMA_DUMP:
+		return cma_file_ioctl_dump(prv, arg);
+
+	default:
+		return -ENOTTY;
+	}
+}
+
+static int  cma_file_mmap(struct file *file, struct vm_area_struct *vma)
+{
+	struct cma_private_data *prv = file->private_data;
+	unsigned long pgoff, offset, length;
+
+	dev_dbg(cma_dev, "%s(%p)\n", __func__, (void *)file);
+
+	if (!prv->cm)
+		return -EBADFD;
+
+	pgoff  = vma->vm_pgoff;
+	offset = pgoff << PAGE_SHIFT;
+	length = vma->vm_end - vma->vm_start;
+
+	if (offset          >= prv->size
+	 || length          >  prv->size
+	 || offset + length >  prv->size)
+		return -ENOSPC;
+
+	return remap_pfn_range(vma, vma->vm_start,
+			       __phys_to_pfn(prv->phys) + pgoff,
+			       length, vma->vm_page_prot);
+}
+
+static int __init cma_dev_init(void)
+{
+	int ret = misc_register(&cma_miscdev);
+	pr_debug("miscdev: register returned: %d\n", ret);
+	return ret;
+}
+module_init(cma_dev_init);
+
+static void __exit cma_dev_exit(void)
+{
+	dev_dbg(cma_dev, "deregisterring\n");
+	misc_deregister(&cma_miscdev);
+}
+module_exit(cma_dev_exit);
diff --git a/include/linux/cma.h b/include/linux/cma.h
index 8952531..fe5d2ba 100644
--- a/include/linux/cma.h
+++ b/include/linux/cma.h
@@ -89,6 +89,35 @@
  *   to be called after SLAB is initialised.
  */
 
+#include <linux/ioctl.h>
+#include <linux/types.h>
+
+
+#define CMA_MAGIC (('c' << 24) | ('M' << 16) | ('a' << 8) | 0x42)
+
+/**
+ * An information about area exportable to user space.
+ * @magic:	must always be CMA_MAGIC.
+ * @_pad:	padding (ignored).
+ * @size:	size of the chunk to allocate.
+ * @alignment:	desired alignment of the chunk (must be power of two or zero).
+ * @start:	when ioctl() finishes this stores physical address of the chunk.
+ */
+struct cma_alloc_request {
+	__u32 magic;
+	__u32 _pad;
+
+	/* __u64 to be compatible accross 32 and 64 bit systems. */
+	__u64 size;
+	__u64 alignment;
+	__u64 start;
+};
+
+#define IOCTL_CMA_ALLOC     _IOWR('p', 0, struct cma_alloc_request)
+#define IOCTL_CMA_PATTERN   _IO('p', 1)
+#define IOCTL_CMA_DUMP      _IO('p', 2)
+
+
 /***************************** Kernel level API *****************************/
 
 #if defined __KERNEL__ && defined CONFIG_CMA
diff --git a/tools/cma/cma-test.c b/tools/cma/cma-test.c
new file mode 100644
index 0000000..6275ef5
--- /dev/null
+++ b/tools/cma/cma-test.c
@@ -0,0 +1,457 @@
+/*
+ * cma-test.c -- CMA testing application
+ *
+ * Copyright (C) 2010 Samsung Electronics
+ *                    Author: Michal Nazarewicz <m.nazarewicz@samsung.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+/* $(CROSS_COMPILE)gcc -Wall -Wextra -g -o cma-test cma-test.c  */
+
+#include <sys/ioctl.h>
+#include <sys/stat.h>
+#include <sys/types.h>
+#include <sys/mman.h>
+
+#include <fcntl.h>
+#include <unistd.h>
+
+#include <ctype.h>
+#include <errno.h>
+#include <limits.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <stdint.h>
+
+#include <linux/cma.h>
+
+struct chunk {
+	struct chunk *next, *prev;
+	int fd;
+	unsigned long size;
+	unsigned long start;
+};
+
+static struct chunk root = {
+	.next = &root,
+	.prev = &root,
+};
+
+#define for_each(a) for (a = root.next; a != &root; a = a->next)
+
+static struct chunk *chunk_create(const char *prefix)
+{
+	struct chunk *chunk;
+	int fd;
+
+	chunk = malloc(sizeof *chunk);
+	if (!chunk) {
+		fprintf(stderr, "%s: %s\n", prefix, strerror(errno));
+		return NULL;
+	}
+
+	fd = open("/dev/cma", O_RDWR);
+	if (fd < 0) {
+		fprintf(stderr, "%s: /dev/cma: %s\n", prefix, strerror(errno));
+		return NULL;
+	}
+
+	chunk->prev = chunk;
+	chunk->next = chunk;
+	chunk->fd   = fd;
+	return chunk;
+}
+
+static void chunk_destroy(struct chunk *chunk)
+{
+	chunk->prev->next = chunk->next;
+	chunk->next->prev = chunk->prev;
+	close(chunk->fd);
+}
+
+static void chunk_add(struct chunk *chunk)
+{
+	chunk->next = &root;
+	chunk->prev = root.prev;
+	root.prev->next = chunk;
+	root.prev = chunk;
+}
+
+/* Parsing helpers  */
+#define SKIP_SPACE(ch) do { while (isspace(*(ch))) ++(ch); } while (0)
+
+static int memparse(char *ptr, char **retptr, unsigned long *ret)
+{
+	unsigned long val;
+
+	SKIP_SPACE(ptr);
+
+	errno = 0;
+	val = strtoul(ptr, &ptr, 0);
+	if (errno)
+		return -1;
+
+	switch (*ptr) {
+	case 'G':
+	case 'g':
+		val <<= 10;
+	case 'M':
+	case 'm':
+		val <<= 10;
+	case 'K':
+	case 'k':
+		val <<= 10;
+		++ptr;
+	}
+
+	if (retptr) {
+		SKIP_SPACE(ptr);
+		*retptr = ptr;
+	}
+
+	*ret = val;
+	return 0;
+}
+
+static void cmd_list(char *name, char *line, int arg)
+{
+	struct chunk *chunk;
+
+	(void)name; (void)line; (void)arg;
+
+	for_each(chunk)
+		printf("%3d: %p@%p\n", chunk->fd,
+		       (void *)chunk->size, (void *)chunk->start);
+}
+
+static void cmd_alloc(char *name, char *line, int arg)
+{
+	unsigned long size, alignment = 0;
+	struct cma_alloc_request req;
+	struct chunk *chunk;
+	int ret;
+
+	(void)arg;
+
+	if (memparse(line, &line, &size) < 0 || !size) {
+		fprintf(stderr, "%s: invalid size\n", name);
+		return;
+	}
+
+	if (*line == '/')
+		if (memparse(line, &line, &alignment) < 0) {
+			fprintf(stderr, "%s: invalid alignment\n", name);
+			return;
+		}
+
+	SKIP_SPACE(line);
+	if (*line) {
+		fprintf(stderr, "%s: unknown argument(s) at the end: %s\n",
+			name, line);
+		return;
+	}
+
+	chunk = chunk_create(name);
+	if (!chunk)
+		return;
+
+	fprintf(stderr, "%s: allocating %p/%p\n", name,
+		(void *)size, (void *)alignment);
+
+	req.magic     = CMA_MAGIC;
+	req.size      = size;
+	req.alignment = alignment;
+	req.start     = 0;
+
+	ret = ioctl(chunk->fd, IOCTL_CMA_ALLOC, &req);
+	if (ret < 0) {
+		fprintf(stderr, "%s: cma_alloc: %s\n", name, strerror(errno));
+		chunk_destroy(chunk);
+	} else {
+		chunk->size  = req.size;
+		chunk->start = req.start;
+		chunk_add(chunk);
+
+		printf("%3d: %p@%p\n", chunk->fd,
+		       (void *)chunk->size, (void *)chunk->start);
+	}
+}
+
+static struct chunk *_cmd_numbered(char *name, char *line)
+{
+	struct chunk *chunk;
+
+	SKIP_SPACE(line);
+
+	if (*line) {
+		unsigned long num;
+
+		errno = 0;
+		num = strtoul(line, &line, 10);
+
+		if (errno || num > INT_MAX) {
+			fprintf(stderr, "%s: invalid number\n", name);
+			return NULL;
+		}
+
+		SKIP_SPACE(line);
+		if (*line) {
+			fprintf(stderr,
+				"%s: unknown arguments at the end: %s\n",
+				name, line);
+			return NULL;
+		}
+
+		for_each(chunk)
+			if (chunk->fd == (int)num)
+				return chunk;
+		fprintf(stderr, "%s: no chunk %3lu\n", name, num);
+		return NULL;
+
+	} else {
+		chunk = root.prev;
+		if (chunk == &root) {
+			fprintf(stderr, "%s: no chunks\n", name);
+			return NULL;
+		}
+		return chunk;
+	}
+}
+
+static void cmd_free(char *name, char *line, int arg)
+{
+	struct chunk *chunk = _cmd_numbered(name, line);
+	(void)arg;
+	if (chunk) {
+		fprintf(stderr, "%s: freeing %p@%p\n", name,
+			(void *)chunk->size, (void *)chunk->start);
+		chunk_destroy(chunk);
+	}
+}
+
+static void _cmd_pattern(char *name, unsigned long *ptr, unsigned long size,
+			  int arg)
+{
+	unsigned long *end = ptr + size / sizeof *ptr, *it, v;
+
+	if (arg)
+		for (v = 0, it = ptr; it != end; ++v, ++it)
+			*it = v;
+
+	for (v = 0, it = ptr; it != end && *it == v; ++v, ++it)
+		/* nop */;
+
+	if (it != end)
+		fprintf(stderr, "%s: at +[%lx] got %lx, expected %lx\n",
+			name, (unsigned long)(it - ptr) * sizeof *it, *it, v);
+	else
+		fprintf(stderr, "%s: done\n", name);
+}
+
+static void _cmd_dump(char *name, uint32_t *ptr)
+{
+	unsigned lines = 32, groups;
+	uint32_t *it = ptr;
+
+	do {
+		printf("%s: %04lx:", name,
+		       (unsigned long)(it - ptr) * sizeof *it);
+
+		groups = 4;
+		do {
+			printf(" %08lx", (unsigned long)*it);
+			++it;
+		} while (--groups);
+
+		putchar('\n');
+	} while (--lines);
+}
+
+static void cmd_mapped(char *name, char *line, int arg)
+{
+	struct chunk *chunk = _cmd_numbered(name, line);
+	void *ptr;
+
+	if (!chunk)
+		return;
+
+	ptr = mmap(NULL, chunk->size,
+		   arg != 2 ? PROT_READ | PROT_WRITE : PROT_READ,
+		   MAP_SHARED, chunk->fd, 0);
+
+	if (ptr == (void *)-1) {
+		fprintf(stderr, "%s: mapping failed: %s\n", name,
+			strerror(errno));
+		return;
+	}
+
+	switch (arg) {
+	case 0:
+	case 1:
+		_cmd_pattern(name, ptr, chunk->size, arg);
+		break;
+
+	case 2:
+		_cmd_dump(name, ptr);
+	}
+
+	munmap(ptr, chunk->size);
+}
+
+static void cmd_kpattern(char *name, char *line, int arg)
+{
+	struct chunk *chunk = _cmd_numbered(name, line);
+	if (chunk) {
+		int ret;
+
+		fprintf(stderr, "%s: requesting kernel to %s %p@%p\n",
+			name, arg ? "fill" : "verify",
+			(void *)chunk->size, (void *)chunk->start);
+
+		ret = ioctl(chunk->fd, IOCTL_CMA_PATTERN, arg);
+		if (ret < 0)
+			fprintf(stderr, "%s: %s\n", name, strerror(errno));
+		else if ((unsigned long)ret < chunk->size)
+			fprintf(stderr, "%s: failed at +[%x]\n", name, ret);
+		else
+			fprintf(stderr, "%s: done\n", name);
+	}
+}
+
+static void cmd_kdump(char *name, char *line, int arg)
+{
+	struct chunk *chunk = _cmd_numbered(name, line);
+
+	(void)arg;
+
+	if (chunk) {
+		int ret;
+
+		fprintf(stderr, "%s: requesting kernel to dump 256B@%p\n",
+			name, (void *)chunk->start);
+
+		ret = ioctl(chunk->fd, IOCTL_CMA_DUMP, 256);
+		if (ret < 0)
+			fprintf(stderr, "%s: %s\n", name, strerror(errno));
+		else
+			fprintf(stderr, "%s: done\n", name);
+	}
+}
+
+static const struct command {
+	const char short_name;
+	const char name[8];
+	void (*handle)(char *name, char *line, int arg);
+	int arg;
+	const char *help_args, *help;
+} commands[] = {
+	{ 'l', "list",    cmd_list,     0,
+	  "", "list allocated chunks" },
+	{ 'a', "alloc",   cmd_alloc,    0,
+	  "<size>[/<alignment>]", "allocate chunk" },
+	{ 'f', "free",    cmd_free,     0,
+	  "[<num>]", "free an chunk" },
+	{ 'w', "write",   cmd_mapped,   1,
+	  "[<num>]", "write data to chunk" },
+	{ 'W', "kwrite",  cmd_kpattern, 1,
+	  "[<num>]", "let kernel write data to chunk" },
+	{ 'v', "verify",  cmd_mapped,   0,
+	  "[<num>]", "verify chunk's content" },
+	{ 'V', "kverify", cmd_kpattern, 0,
+	  "[<num>]", "let kernel verify chunk's contet" },
+	{ 'd', "dump",    cmd_mapped,   2,
+	  "[<num>]", "dump (some) content" },
+	{ 'D', "kdump",   cmd_kdump,    0,
+	  "[<num>]", "let kernel dump (some) content" },
+	{ '\0', "", NULL, 0, NULL, NULL }
+};
+
+static void handle_command(char *line)
+{
+	static char last_line[1024];
+
+	const struct command *cmd;
+	char *name, short_name = '\0';
+
+	SKIP_SPACE(line);
+	if (*line == '#')
+		return;
+
+	if (!*line)
+		strcpy(line, last_line);
+	else
+		strcpy(last_line, line);
+
+	name = line;
+	while (*line && !isspace(*line))
+		++line;
+
+	if (*line) {
+		*line = '\0';
+		++line;
+	}
+
+	if (!name[1])
+		short_name = name[0];
+
+	for (cmd = commands; *(cmd->name); ++cmd)
+		if (short_name
+		  ? short_name == cmd->short_name
+		  : !strcmp(name, cmd->name)) {
+			cmd->handle(name, line, cmd->arg);
+			return;
+		}
+
+	fprintf(stderr, "%s: unknown command\n", name);
+}
+
+int main(void)
+{
+	const struct command *cmd = commands;
+	unsigned no = 1;
+	char line[1024];
+	int skip = 0;
+
+	fputs("commands:\n", stderr);
+	do {
+		fprintf(stderr, " %c or %-7s  %-10s  %s\n",
+			cmd->short_name, cmd->name, cmd->help_args, cmd->help);
+	} while ((++cmd)->handle);
+	fputs(" # ...                        comment\n"
+	      " <empty line>                 repeat previous\n"
+	      "\n", stderr);
+
+	while (fgets(line, sizeof line, stdin)) {
+		char *nl = strchr(line, '\n');
+		if (nl) {
+			if (skip) {
+				fprintf(stderr, "cma: %d: line too long\n", no);
+				skip = 0;
+			} else {
+				*nl = '\0';
+				handle_command(line);
+			}
+			++no;
+		} else {
+			skip = 1;
+		}
+	}
+
+	if (skip)
+		fprintf(stderr, "cma: %d: no new line at EOF\n", no);
+	return 0;
+}
-- 
1.7.2.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
