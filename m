From: Michal Nazarewicz <m.nazarewicz@samsung.com>
Subject: [PATCH 3/4] mm: cma: Test device and application added
Date: Tue, 20 Jul 2010 17:51:26 +0200
Message-ID: <b356e2fbc65342d902ed67a5b0aa00459a04fe49.1279639238.git.m.nazarewicz@samsung.com>
References: <cover.1279639238.git.m.nazarewicz@samsung.com>
 <d6d104950c1391eaf3614d56615617cee5722fb4.1279639238.git.m.nazarewicz@samsung.com>
 <adceebd371e8a66a2c153f429b38068eca99e99f.1279639238.git.m.nazarewicz@samsung.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <adceebd371e8a66a2c153f429b38068eca99e99f.1279639238.git.m.nazarewicz@samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
To: linux-mm@kvack.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Pawel Osciak <p.osciak@samsung.com>, Xiaolin Zhang <xiaolin.zhang@intel.com>, Hiremath Vaibhav <hvaibhav@ti.com>, Robert Fekete <robert.fekete@stericsson.com>, Marcus Lorentzon <marcus.xm.lorentzon@stericsson.com>, linux-kernel@vger.kernel.org, Michal Nazarewicz <m.nazarewicz@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>
List-Id: linux-mm.kvack.org

This patch adds a "cma" misc device which lets user space use the
CMA API.  This device is meant for testing.  A testing application
is also provided.

Signed-off-by: Michal Nazarewicz <m.nazarewicz@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 drivers/misc/Kconfig   |    8 +
 drivers/misc/Makefile  |    1 +
 drivers/misc/cma-dev.c |  183 +++++++++++++++++++++++
 include/linux/cma.h    |   30 ++++
 tools/cma/cma-test.c   |  373 ++++++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 595 insertions(+), 0 deletions(-)
 create mode 100644 drivers/misc/cma-dev.c
 create mode 100644 tools/cma/cma-test.c

diff --git a/drivers/misc/Kconfig b/drivers/misc/Kconfig
index 26386a9..2db9d46 100644
--- a/drivers/misc/Kconfig
+++ b/drivers/misc/Kconfig
@@ -358,4 +358,12 @@ source "drivers/misc/eeprom/Kconfig"
 source "drivers/misc/cb710/Kconfig"
 source "drivers/misc/iwmc3200top/Kconfig"
 
+config CMA_DEVICE
+	tristate "CMA misc device (DEVELOPEMENT)"
+	depends on CMA
+	help
+	  The CMA misc device allows allocating contiguous memory areas
+	  from user space.  This is mostly for testing of the CMA
+	  framework.
+
 endif # MISC_DEVICES
diff --git a/drivers/misc/Makefile b/drivers/misc/Makefile
index 6ed06a1..6d0ef2b 100644
--- a/drivers/misc/Makefile
+++ b/drivers/misc/Makefile
@@ -31,3 +31,4 @@ obj-$(CONFIG_IWMC3200TOP)      += iwmc3200top/
 obj-y				+= eeprom/
 obj-y				+= cb710/
 obj-$(CONFIG_VMWARE_BALLOON)	+= vmware_balloon.o
+obj-$(CONFIG_CMA_DEVICE)	+= cma-dev.o
diff --git a/drivers/misc/cma-dev.c b/drivers/misc/cma-dev.c
new file mode 100644
index 0000000..c5247a7
--- /dev/null
+++ b/drivers/misc/cma-dev.c
@@ -0,0 +1,183 @@
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
+#define cma_file_start(file) (((unsigned long *)(file)->private_data)[0])
+#define cma_file_size(file) (((unsigned long *)(file)->private_data)[1])
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
+		cma_put(cma_file_start(file));
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
+	struct device fake_device;
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
+	/* May happen on 32 bit system. */
+	if (req.size > ULONG_MAX || req.alignment > ULONG_MAX)
+		return -EINVAL;
+
+	if (strnlen(req.name, sizeof req.name) >= sizeof req.name
+	 || strnlen(req.kind, sizeof req.kind) >= sizeof req.kind)
+		return -EINVAL;
+
+	file->private_data = kmalloc(2 * sizeof(unsigned long), GFP_KERNEL);
+	if (!file->private_data)
+		return -ENOMEM;
+
+	fake_device.init_name = req.name;
+	fake_device.kobj.name = req.name;
+	addr = cma_alloc(&fake_device, req.kind, req.size, req.alignment);
+	if (IS_ERR_VALUE(addr)) {
+		ret = addr;
+		goto error_priv;
+	}
+
+	if (put_user(addr, (typeof(req.start) *)(arg + offsetof(typeof(req), start)))) {
+		ret = -EFAULT;
+		goto error_put;
+	}
+
+	cma_file_start(file) = addr;
+	cma_file_size(file) = req.size;
+
+	dev_dbg(cma_dev, "allocated %p@%p\n",
+		(void *)(unsigned long) req.size, (void *)addr);
+
+	return 0;
+
+error_put:
+	cma_put(addr);
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
index aef8347..1bfffb2 100644
--- a/include/linux/cma.h
+++ b/include/linux/cma.h
@@ -11,6 +11,36 @@
  * See Documentation/cma.txt for documentation.
  */
 
+#include <linux/ioctl.h>
+#include <linux/types.h>
+
+
+#define CMA_MAGIC (('c' << 24) | ('M' << 16) | ('a' << 8) | 0x42)
+
+/**
+ * An information about area exportable to user space.
+ * @magic: must always be CMA_MAGIC.
+ * @name:  name of the device to allocate as.
+ * @kind:  kind of the memory.
+ * @_pad:  reserved.
+ * @size:  size of the chunk to allocate.
+ * @alignment: desired alignment of the chunk (must be power of two or zero).
+ * @start: when ioctl() finishes this stores physical address of the chunk.
+ */
+struct cma_alloc_request {
+	__u32 magic;
+	char  name[17];
+	char  kind[17];
+	__u16 pad;
+	/* __u64 to be compatible accross 32 and 64 bit systems. */
+	__u64 size;
+	__u64 alignment;
+	__u64 start;
+};
+
+#define IOCTL_CMA_ALLOC    _IOWR('p', 0, struct cma_alloc_request)
+
+
 #ifdef __KERNEL__
 
 struct device;
diff --git a/tools/cma/cma-test.c b/tools/cma/cma-test.c
new file mode 100644
index 0000000..567c57b
--- /dev/null
+++ b/tools/cma/cma-test.c
@@ -0,0 +1,373 @@
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
+#include <linux/cma.h>
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
+	      " l or list                                list allocated chunks\n"
+	      " a or alloc  <name> <size>[/<alignment>]  allocate chunk\n"
+	      " f or free   [<num>]                      free an chunk\n"
+	      " # ...                                    comment\n"
+	      " <empty line>                             repeat previous\n"
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
+static void cmd_free(char *name, char *line);
+
+static const struct command {
+	const char name[8];
+	void (*handle)(char *name, char *line);
+} commands[] = {
+	{ "list",  cmd_list  },
+	{ "l",     cmd_list  },
+	{ "alloc", cmd_alloc },
+	{ "a",     cmd_alloc },
+	{ "free",  cmd_free  },
+	{ "f",     cmd_free  },
+	{ "",      NULL      }
+};
+
+
+#define SKIP_SPACE(ch) do while (isspace(*(ch))) ++(ch); while (0)
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
+static void cmd_alloc(char *name, char *line)
+{
+	unsigned long size, alignment = 0;
+	struct cma_alloc_request req;
+	char *dev, *kind = NULL;
+	struct chunk *chunk;
+	int ret;
+
+	SKIP_SPACE(line);
+	if (!*line) {
+		fprintf(stderr, "%s: expecting name\n", name);
+		return;
+	}
+
+	for (dev = line; *line && !isspace(*line); ++line)
+		if (*line == '/')
+			kind = line;
+
+	if (!*line) {
+		fprintf(stderr, "%s: expecting size after name\n", name);
+		return;
+	}
+
+	if (kind)
+		*kind++ = '\0';
+	*line++ = '\0';
+
+	if (( kind && (size_t)(kind - dev ) > sizeof req.name)
+	 || (!kind && (size_t)(line - dev ) > sizeof req.name)
+	 || ( kind && (size_t)(line - kind) > sizeof req.kind)) {
+		fprintf(stderr, "%s: name or kind too long\n", name);
+		return;
+	}
+
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
+		fprintf(stderr, "%s: unknown arguments at the end: %s\n",
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
+	req.size      = size;
+	req.alignment = alignment;
+
+	strcpy(req.name, dev);
+	if (kind)
+		strcpy(req.kind, kind);
+	else
+		req.kind[0] = '\0';
+
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
+			fprintf(stderr, "%s: unknown arguments at the end: %s\n",
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
