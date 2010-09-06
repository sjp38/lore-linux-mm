Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 705AC6B0088
	for <linux-mm@kvack.org>; Mon,  6 Sep 2010 02:34:58 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from eu_spt2 ([210.118.77.14]) by mailout4.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0L8B005OGBM7J140@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 06 Sep 2010 07:34:55 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0L8B00EM3BM632@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 06 Sep 2010 07:34:55 +0100 (BST)
Date: Mon, 06 Sep 2010 08:33:55 +0200
From: Michal Nazarewicz <m.nazarewicz@samsung.com>
Subject: [RFCv5 5/9] mm: cma: Test device and application added
In-reply-to: <cover.1283749231.git.mina86@mina86.com>
Message-id: 
 <e0ba61dd4e2bbbd7e3aea28718f42350af414943.1283749231.git.mina86@mina86.com>
References: <cover.1283749231.git.mina86@mina86.com>
Sender: owner-linux-mm@kvack.org
To: linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Daniel Walker <dwalker@codeaurora.org>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Hans Verkuil <hverkuil@xs4all.nl>, Jonathan Corbet <corbet@lwn.net>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Kyungmin Park <kyungmin.park@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, Pawel Osciak <p.osciak@samsung.com>, Peter Zijlstra <peterz@infradead.org>, Russell King <linux@arm.linux.org.uk>, Zach Pfeffer <zpfeffer@codeaurora.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

This patch adds a "cma" misc device which lets user space use the
CMA API.  This device is meant for testing.  A testing application
is also provided.

Signed-off-by: Michal Nazarewicz <m.nazarewicz@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 drivers/misc/Kconfig   |    8 +
 drivers/misc/Makefile  |    1 +
 drivers/misc/cma-dev.c |  202 +++++++++++++++++++++++++
 include/linux/cma.h    |   38 +++++
 tools/cma/cma-test.c   |  386 ++++++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 635 insertions(+), 0 deletions(-)
 create mode 100644 drivers/misc/cma-dev.c
 create mode 100644 tools/cma/cma-test.c

diff --git a/drivers/misc/Kconfig b/drivers/misc/Kconfig
index 2c38d4e..ac1dd45 100644
--- a/drivers/misc/Kconfig
+++ b/drivers/misc/Kconfig
@@ -407,4 +407,12 @@ source "drivers/misc/eeprom/Kconfig"
 source "drivers/misc/cb710/Kconfig"
 source "drivers/misc/iwmc3200top/Kconfig"
 
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
index 21b4761..b08844a 100644
--- a/drivers/misc/Makefile
+++ b/drivers/misc/Makefile
@@ -36,3 +36,4 @@ obj-y				+= cb710/
 obj-$(CONFIG_VMWARE_BALLOON)	+= vmware_balloon.o
 obj-$(CONFIG_ARM_CHARLCD)	+= arm-charlcd.o
 obj-$(CONFIG_PCH_PHUB)		+= pch_phub.o
+obj-$(CONFIG_CMA_DEVICE)	+= cma-dev.o
diff --git a/drivers/misc/cma-dev.c b/drivers/misc/cma-dev.c
new file mode 100644
index 0000000..5ceb432
--- /dev/null
+++ b/drivers/misc/cma-dev.c
@@ -0,0 +1,202 @@
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
+
+#define cma_file_start(file) (((dma_addr_t *)(file)->private_data)[0])
+#define cma_file_size(file)  (((dma_addr_t *)(file)->private_data)[1])
+
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
+
+static int  cma_file_release(struct inode *inode, struct file *file)
+{
+	dev_dbg(cma_dev, "%s(%p)\n", __func__, (void *)file);
+
+	if (file->private_data) {
+		cma_free(cma_file_start(file));
+		kfree(file->private_data);
+	}
+
+	return 0;
+}
+
+
+static long cma_file_ioctl(struct file *file, unsigned cmd, unsigned long arg)
+{
+	struct cma_alloc_request req;
+	unsigned long addr;
+	long ret;
+
+	dev_dbg(cma_dev, "%s(%p)\n", __func__, (void *)file);
+
+	if (cmd != IOCTL_CMA_ALLOC)
+		return -ENOTTY;
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
+
+	file->private_data = kmalloc(2 * sizeof(dma_addr_t), GFP_KERNEL);
+	if (!file->private_data)
+		return -ENOSPC;
+
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
+		addr = cma_alloc(&fake_device, kind, req.size, req.alignment);
+	} else {
+		addr = cma_alloc_from(req.spec, req.size, req.alignment);
+	}
+
+	if (IS_ERR_VALUE(addr)) {
+		ret = addr;
+		goto error_priv;
+	}
+
+
+	if (put_user(addr, (typeof(req.start) *)(arg + offsetof(typeof(req),
+								start)))) {
+		ret = -EFAULT;
+		goto error_put;
+	}
+
+	cma_file_start(file) = addr;
+	cma_file_size(file) = req.size;
+
+	dev_dbg(cma_dev, "allocated %p@%p\n",
+		(void *)(dma_addr_t)req.size, (void *)addr);
+
+	return 0;
+
+error_put:
+	cma_free(addr);
+error_priv:
+	kfree(file->private_data);
+	file->private_data = NULL;
+	return ret;
+}
+
+
+static int  cma_file_mmap(struct file *file, struct vm_area_struct *vma)
+{
+	unsigned long pgoff, offset, length;
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
+	if (offset          >= cma_file_size(file)
+	 || length          >  cma_file_size(file)
+	 || offset + length >  cma_file_size(file))
+		return -ENOSPC;
+
+	return remap_pfn_range(vma, vma->vm_start,
+			       __phys_to_pfn(cma_file_start(file) + offset),
+			       length, vma->vm_page_prot);
+}
+
+
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
index d0f41f4..409bae4 100644
--- a/include/linux/cma.h
+++ b/include/linux/cma.h
@@ -11,6 +11,44 @@
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
+#define IOCTL_CMA_ALLOC    _IOWR('p', 0, struct cma_alloc_request)
+
+
 /***************************** Kernel level API *****************************/
 
 #ifdef __KERNEL__
diff --git a/tools/cma/cma-test.c b/tools/cma/cma-test.c
new file mode 100644
index 0000000..4aa6c5c
--- /dev/null
+++ b/tools/cma/cma-test.c
@@ -0,0 +1,386 @@
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
+static void handle_command(char *line);
+
+int main(void)
+{
+	unsigned no = 1;
+	char line[1024];
+	int skip = 0;
+
+	fputs("commands:\n"
+	      " l or list                                      list allocated chunks\n"
+	      " a or alloc  <dev>/<kind> <size>[/<alignment>]  allocate chunk\n"
+	      " A or afrom  <regions>    <size>[/<alignment>]  allocate from region(s)\n"
+	      " f or free   [<num>]                            free an chunk\n"
+	      " # ...                                          comment\n"
+	      " <empty line>                                   repeat previous\n"
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
+
+
+
+static void cmd_list(char *name, char *line);
+static void cmd_alloc(char *name, char *line);
+static void cmd_alloc_from(char *name, char *line);
+static void cmd_free(char *name, char *line);
+
+static const struct command {
+	const char name[8];
+	void (*handle)(char *name, char *line);
+} commands[] = {
+	{ "list",  cmd_list },
+	{ "l",     cmd_list },
+	{ "alloc", cmd_alloc },
+	{ "a",     cmd_alloc },
+	{ "afrom", cmd_alloc_from },
+	{ "A",     cmd_alloc_from },
+	{ "free",  cmd_free },
+	{ "f",     cmd_free },
+	{ "",      NULL }
+};
+
+
+#define SKIP_SPACE(ch) do { while (isspace(*(ch))) ++(ch); } while (0)
+
+
+static void handle_command(char *line)
+{
+	static char last_line[1024];
+
+	const struct command *cmd;
+	char *name;
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
+	for (cmd = commands; *(cmd->name); ++cmd)
+		if (!strcmp(name, cmd->name)) {
+			cmd->handle(name, line);
+			return;
+		}
+
+	fprintf(stderr, "%s: unknown command\n", name);
+}
+
+
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
+static struct chunk *chunk_create(const char *prefix);
+static void chunk_destroy(struct chunk *chunk);
+static void chunk_add(struct chunk *chunk);
+
+static int memparse(char *ptr, char **retptr, unsigned long *ret);
+
+
+static void cmd_list(char *name, char *line)
+{
+	struct chunk *chunk;
+
+	(void)name; (void)line;
+
+	for_each(chunk)
+		printf("%3d: %p@%p\n", chunk->fd,
+		       (void *)chunk->size, (void *)chunk->start);
+}
+
+
+static void __cma_alloc(char *name, char *line, int from);
+
+static void cmd_alloc(char *name, char *line)
+{
+	__cma_alloc(name, line, 0);
+}
+
+static void cmd_alloc_from(char *name, char *line)
+{
+	__cma_alloc(name, line, 1);
+}
+
+static void __cma_alloc(char *name, char *line, int from)
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
+
+static void cmd_free(char *name, char *line)
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
+			return;
+		}
+
+		SKIP_SPACE(line);
+		if (*line) {
+			fprintf(stderr,
+				"%s: unknown arguments at the end: %s\n",
+				name, line);
+			return;
+		}
+
+		for_each(chunk)
+			if (chunk->fd == (int)num)
+				goto ok;
+		fprintf(stderr, "%s: no chunk %3lu\n", name, num);
+		return;
+
+	} else {
+		chunk = root.prev;
+		if (chunk == &root) {
+			fprintf(stderr, "%s: no chunks\n", name);
+			return;
+		}
+	}
+
+ok:
+	fprintf(stderr, "%s: freeing %p@%p\n", name,
+		(void *)chunk->size, (void *)chunk->start);
+	chunk_destroy(chunk);
+}
+
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
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
