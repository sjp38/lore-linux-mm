Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 6D7AE6B0085
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 10:58:30 -0500 (EST)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from spt2.w1.samsung.com ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LC500IKW31DR120@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 19 Nov 2010 15:58:26 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LC5000HA31CCP@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 19 Nov 2010 15:58:25 +0000 (GMT)
Date: Fri, 19 Nov 2010 16:58:05 +0100
From: Michal Nazarewicz <m.nazarewicz@samsung.com>
Subject: [RFCv6 07/13] mm: cma: Test device and application added
In-reply-to: <cover.1290172312.git.m.nazarewicz@samsung.com>
Message-id: 
 <0bdca91a7f981e3d0061b26357bdbc17cc08cef0.1290172312.git.m.nazarewicz@samsung.com>
References: <cover.1290172312.git.m.nazarewicz@samsung.com>
Sender: owner-linux-mm@kvack.org
To: mina86@mina86.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Ankita Garg <ankita@in.ibm.com>, Bryan Huntsman <bryanh@codeaurora.org>, Daniel Walker <dwalker@codeaurora.org>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Hans Verkuil <hverkuil@xs4all.nl>, Johan Mossberg <johan.xx.mossberg@stericsson.com>, Jonathan Corbet <corbet@lwn.net>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Marcus LORENTZON <marcus.xm.lorentzon@stericsson.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mark Brown <broonie@opensource.wolfsonmicro.com>, Mel Gorman <mel@csn.ul.ie>, Pawel Osciak <pawel@osciak.com>, Russell King <linux@arm.linux.org.uk>, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, Zach Pfeffer <zpfeffer@codeaurora.org>, dipankar@in.ibm.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This patch adds a "cma" misc device which lets user space use the
CMA API.  This device is meant for testing.  A testing application
is also provided.

Signed-off-by: Michal Nazarewicz <m.nazarewicz@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 drivers/misc/Kconfig   |    8 +
 drivers/misc/Makefile  |    1 +
 drivers/misc/cma-dev.c |  263 +++++++++++++++++++++++++++
 include/linux/cma.h    |   40 +++++
 tools/cma/cma-test.c   |  459 ++++++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 771 insertions(+), 0 deletions(-)
 create mode 100644 drivers/misc/cma-dev.c
 create mode 100644 tools/cma/cma-test.c

diff --git a/drivers/misc/Kconfig b/drivers/misc/Kconfig
index 1e1a4be..519a291 100644
--- a/drivers/misc/Kconfig
+++ b/drivers/misc/Kconfig
@@ -458,4 +458,12 @@ source "drivers/misc/cb710/Kconfig"
 source "drivers/misc/iwmc3200top/Kconfig"
 source "drivers/misc/ti-st/Kconfig"
 
+config CMA_DEVICE
+	tristate "CMA misc device (DEVELOPEMENT)"
+	depends on CMA_DEVELOPEMENT
+	help
+	  The CMA misc device allows allocating contiguous memory areas
+	  from user space.  This is mostly for testing of the CMA
+	  framework.
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
index 0000000..dce418a
--- /dev/null
+++ b/drivers/misc/cma-dev.c
@@ -0,0 +1,263 @@
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
+static int  cma_file_open(struct inode *inode, struct file *file)
+{
+	dev_dbg(cma_dev, "%s(%p)\n", __func__, (void *)file);
+
+	file->private_data = NULL;
+
+	return 0;
+}
+
+static int  cma_file_release(struct inode *inode, struct file *file)
+{
+	dev_dbg(cma_dev, "%s(%p)\n", __func__, (void *)file);
+
+	if (file->private_data) {
+		cma_unpin(file->private_data);
+		cma_free(file->private_data);
+	}
+
+	return 0;
+}
+
+static long cma_file_ioctl_req(struct file *file, unsigned long arg)
+{
+	struct cma_alloc_request req;
+	const struct cma *chunk;
+
+	dev_dbg(cma_dev, "%s(%p)\n", __func__, (void *)file);
+
+	if (!arg)
+		return -EINVAL;
+
+	if (file->private_data) /* Already allocated */
+		return -EBADFD;
+
+	if (copy_from_user(&req, (void *)arg, sizeof req))
+		return -EFAULT;
+
+	if (req.magic != CMA_MAGIC)
+		return -ENOTTY;
+
+	if (req.type != CMA_REQ_DEV_KIND && req.type != CMA_REQ_FROM_REG)
+		return -EINVAL;
+
+	/* May happen on 32 bit system. */
+	if (req.size > ~(typeof(req.size))0 ||
+	    req.alignment > ~(typeof(req.alignment))0)
+		return -EINVAL;
+
+	if (strnlen(req.spec, sizeof req.spec) >= sizeof req.spec)
+		return -EINVAL;
+
+	if (req.type == CMA_REQ_DEV_KIND) {
+		struct device fake_device;
+		char *kind;
+
+		fake_device.init_name = req.spec;
+		fake_device.kobj.name = req.spec;
+
+		kind = strrchr(req.spec, '/');
+		if (kind)
+			*kind++ = '\0';
+
+		chunk = cma_alloc(&fake_device, kind, req.size, req.alignment);
+	} else {
+		chunk = cma_alloc_from(req.spec, req.size, req.alignment);
+	}
+
+	if (IS_ERR(chunk))
+		return PTR_ERR(chunk);
+
+	req.start = cma_pin(chunk);
+	if (put_user(req.start,
+		     (typeof(req.start) *)
+		     (arg + offsetof(typeof(req), start)))) {
+		cma_free(chunk);
+		return -EFAULT;
+	}
+
+	file->private_data = (void *)chunk;
+
+	dev_dbg(cma_dev, "allocated %p@%p\n",
+		(void *)(unsigned long)req.size,
+		(void *)(unsigned long)req.start);
+
+	return 0;
+}
+
+#ifdef DEBUG
+
+static long __cma_pattern_failed(unsigned long *_it, unsigned long *it,
+				 unsigned long *end, unsigned long v)
+{
+	dev_dbg(cma_dev, "at %p + %x got %lx, expected %lx\n",
+		(void *)_it, (it - _it) * sizeof *it, *it, v);
+	print_hex_dump(KERN_DEBUG, "cma: ", DUMP_PREFIX_ADDRESS,
+		       16, sizeof *it, it,
+		       min_t(size_t, 128, (end - it) * sizeof *it), 0);
+	return (it - _it) * sizeof *it;
+}
+
+#else
+
+static long __cma_pattern_failed(unsigned long *_it, unsigned long *it,
+				 unsigned long *end, unsigned long v)
+{
+	return (it - _it) * sizeof *it;
+}
+
+#endif
+
+static long cma_file_ioctl_pattern(struct file *file, unsigned long arg)
+{
+	const struct cma *chunk;
+	unsigned long *_it, *it, *end, v;
+
+	dev_dbg(cma_dev, "%s(%p, %s)\n", __func__, (void *)file,
+		arg ? "fill" : "verify");
+
+	if (!file->private_data)
+		return -EBADFD;
+
+	chunk = file->private_data;
+	_it = phys_to_virt(cma_phys(chunk));
+	end = _it + cma_size(chunk);
+
+	if (arg)
+		for (v = 0, it = _it; it != end; ++v, ++it)
+			*it = v;
+
+	for (v = 0, it = _it; it != end; ++v, ++it)
+		if (*it != v)
+			return __cma_pattern_failed(_it, it, end, v);
+
+	return cma_size(chunk);
+}
+
+static long cma_file_ioctl_dump(struct file *file, unsigned long len)
+{
+	const struct cma *chunk;
+	unsigned long *it;
+
+	dev_dbg(cma_dev, "%s(%p, %p)\n", __func__, (void *)file, (void *)len);
+
+	if (!file->private_data)
+		return -EBADFD;
+
+	chunk = file->private_data;
+	it    = phys_to_virt(cma_phys(chunk));
+	len   = min(len & ~(sizeof *it - 1), (unsigned long)cma_size(chunk));
+	print_hex_dump(KERN_DEBUG, "cma: ", DUMP_PREFIX_ADDRESS,
+		       16, sizeof *it, it, len, 0);
+
+	return 0;
+}
+
+static long cma_file_ioctl(struct file *file, unsigned cmd, unsigned long arg)
+{
+	dev_dbg(cma_dev, "%s(%p)\n", __func__, (void *)file);
+
+	switch (cmd) {
+	case IOCTL_CMA_ALLOC:
+		return cma_file_ioctl_req(file, arg);
+
+	case IOCTL_CMA_PATTERN:
+		return cma_file_ioctl_pattern(file, arg);
+
+	case IOCTL_CMA_DUMP:
+		return cma_file_ioctl_dump(file, arg);
+
+	default:
+		/* Dead code */
+		return -ENOTTY;
+	}
+}
+
+static int  cma_file_mmap(struct file *file, struct vm_area_struct *vma)
+{
+	unsigned long pgoff, offset, length;
+	const struct cma *chunk;
+
+	dev_dbg(cma_dev, "%s(%p)\n", __func__, (void *)file);
+
+	if (!file->private_data)
+		return -EBADFD;
+
+	pgoff  = vma->vm_pgoff;
+	offset = pgoff << PAGE_SHIFT;
+	length = vma->vm_end - vma->vm_start;
+
+	chunk = file->private_data;
+	if (offset          >= cma_size(chunk)
+	 || length          >  cma_size(chunk)
+	 || offset + length >  cma_size(chunk))
+		return -ENOSPC;
+
+	return remap_pfn_range(vma, vma->vm_start,
+			       __phys_to_pfn(cma_phys(chunk)) + pgoff,
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
index 8437104..56ed021 100644
--- a/include/linux/cma.h
+++ b/include/linux/cma.h
@@ -11,6 +11,46 @@
  * See Documentation/contiguous-memory.txt for details.
  */
 
+#include <linux/ioctl.h>
+#include <linux/types.h>
+
+
+#define CMA_MAGIC (('c' << 24) | ('M' << 16) | ('a' << 8) | 0x42)
+
+enum {
+	CMA_REQ_DEV_KIND,
+	CMA_REQ_FROM_REG
+};
+
+/**
+ * An information about area exportable to user space.
+ * @magic:	must always be CMA_MAGIC.
+ * @type:	type of the request.
+ * @spec:	either "dev/kind\0" or "regions\0" depending on @type.
+ *		In any case, the string must be NUL terminated.
+ *		additionally, in the latter case scanning stops at
+ *		semicolon (';').
+ * @size:	size of the chunk to allocate.
+ * @alignment:	desired alignment of the chunk (must be power of two or zero).
+ * @start:	when ioctl() finishes this stores physical address of the chunk.
+ */
+struct cma_alloc_request {
+	__u32 magic;
+	__u32 type;
+
+	/* __u64 to be compatible accross 32 and 64 bit systems. */
+	__u64 size;
+	__u64 alignment;
+	__u64 start;
+
+	char spec[32];
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
index 0000000..6de155f
--- /dev/null
+++ b/tools/cma/cma-test.c
@@ -0,0 +1,459 @@
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
+
+#include <linux/cma.h>
+
+
+/****************************** Chunks management ******************************/
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
+
+/****************************** Commands ******************************/
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
+static void cmd_alloc(char *name, char *line, int from)
+{
+	static const char *what[2] = { "dev/kind", "regions" };
+
+	unsigned long size, alignment = 0;
+	struct cma_alloc_request req;
+	struct chunk *chunk;
+	char *spec;
+	size_t n;
+	int ret;
+
+	SKIP_SPACE(line);
+	if (!*line) {
+		fprintf(stderr, "%s: expecting %s\n", name, what[from]);
+		return;
+	}
+
+	for (spec = line; *line && !isspace(*line); ++line)
+		/* nothing */;
+
+	if (!*line) {
+		fprintf(stderr, "%s: expecting size after %s\n",
+			name, what[from]);
+		return;
+	}
+
+	*line++ = '\0';
+	n = line - spec;
+	if (n > sizeof req.spec) {
+		fprintf(stderr, "%s: %s too long\n", name, what[from]);
+		return;
+	}
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
+	req.type      = from ? CMA_REQ_FROM_REG : CMA_REQ_DEV_KIND;
+	req.size      = size;
+	req.alignment = alignment;
+	req.start     = 0;
+
+	memcpy(req.spec, spec, n);
+	memset(req.spec + n, '\0', sizeof req.spec - n);
+
+	ret = ioctl(chunk->fd, IOCTL_CMA_ALLOC, &req);
+	if (ret < 0) {
+		fprintf(stderr, "%s: cma_alloc: %s\n", name, strerror(errno));
+		chunk_destroy(chunk);
+	} else {
+		chunk_add(chunk);
+		chunk->size  = req.size;
+		chunk->start = req.start;
+
+		printf("%3d: %p@%p\n", chunk->fd,
+		       (void *)chunk->size, (void *)chunk->start);
+	}
+}
+
+static struct chunk *__cmd_numbered(char *name, char *line)
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
+	struct chunk *chunk = __cmd_numbered(name, line);
+	(void)arg;
+	if (chunk) {
+		fprintf(stderr, "%s: freeing %p@%p\n", name,
+			(void *)chunk->size, (void *)chunk->start);
+		chunk_destroy(chunk);
+	}
+}
+
+static void cmd_mapped(char *name, char *line, int arg)
+{
+	struct chunk *chunk = __cmd_numbered(name, line);
+	unsigned long *ptr, *it, *end, v;
+
+	if (!chunk)
+		return;
+
+	ptr = mmap(NULL, chunk->size, PROT_READ | PROT_WRITE,
+		  MAP_SHARED, chunk->fd, 0);
+
+	if (ptr == (void *)-1) {
+		fprintf(stderr, "%s: mapping failed: %s\n", name,
+			strerror(errno));
+		return;
+	}
+
+	end = ptr + chunk->size / sizeof *it;
+
+	if (arg)
+		for (v = 0, it = ptr; it != end; ++v, ++it)
+			*it = v;
+
+	for (v = 0, it = ptr; it != end && *it == v; ++v, ++it)
+		/* nop */;
+
+	if (it != end)
+		fprintf(stderr, "%s: at +[%x] got %lx, expected %lx\n",
+			name, (it - ptr) * sizeof *it, *it, v);
+	else
+		fprintf(stderr, "%s: done\n", name);
+
+	munmap(it, chunk->size);
+}
+
+static void cmd_pattern(char *name, char *line, int arg)
+{
+	struct chunk *chunk = __cmd_numbered(name, line);
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
+	struct chunk *chunk = __cmd_numbered(name, line);
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
+	{ 'l', "list",    cmd_list,    0,
+	  "", "list allocated chunks" },
+	{ 'a', "alloc",   cmd_alloc,   0,
+	  "<dev>/<kind> <size>[/<alignment>]", "allocate chunk" },
+	{ 'A', "afrom",   cmd_alloc,   1,
+	  "<regions>    <size>[/<alignment>]", "allocate from region(s)" },
+	{ 'f', "free",    cmd_free,    0,
+	  "[<num>]", "free an chunk" },
+	{ 'w', "write",   cmd_mapped,  1,
+	  "[<num>]", "write data to chunk" },
+	{ 'W', "kwrite",  cmd_pattern, 1,
+	  "[<num>]", "verify chunk's contet" },
+	{ 'v', "verify",  cmd_mapped,  0,
+	  "[<num>]", "let kernel write data to chunk" },
+	{ 'V', "kverify", cmd_pattern, 0,
+	  "[<num>]", "let kernel verify verify chunk's contet" },
+	{ 'D', "kdump",   cmd_kdump,   0,
+	  "[<num>]", "make kernel dump content" },
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
+
+/****************************** Main ******************************/
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
