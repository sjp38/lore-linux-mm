Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id B11376B0085
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 10:58:29 -0500 (EST)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from spt2.w1.samsung.com ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LC500IKW31DR120@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 19 Nov 2010 15:58:26 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LC500EK431CR0@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 19 Nov 2010 15:58:25 +0000 (GMT)
Date: Fri, 19 Nov 2010 16:58:03 +0100
From: Michal Nazarewicz <m.nazarewicz@samsung.com>
Subject: [RFCv6 05/13] mm: cma: debugfs support added
In-reply-to: <cover.1290172312.git.m.nazarewicz@samsung.com>
Message-id: 
 <5b4b5dc196968bb3c4c28e3f91b0b9feab6a1c37.1290172312.git.m.nazarewicz@samsung.com>
References: <cover.1290172312.git.m.nazarewicz@samsung.com>
Sender: owner-linux-mm@kvack.org
To: mina86@mina86.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Ankita Garg <ankita@in.ibm.com>, Bryan Huntsman <bryanh@codeaurora.org>, Daniel Walker <dwalker@codeaurora.org>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Hans Verkuil <hverkuil@xs4all.nl>, Johan Mossberg <johan.xx.mossberg@stericsson.com>, Jonathan Corbet <corbet@lwn.net>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Marcus LORENTZON <marcus.xm.lorentzon@stericsson.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mark Brown <broonie@opensource.wolfsonmicro.com>, Mel Gorman <mel@csn.ul.ie>, Pawel Osciak <pawel@osciak.com>, Russell King <linux@arm.linux.org.uk>, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, Zach Pfeffer <zpfeffer@codeaurora.org>, dipankar@in.ibm.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The debugfs development interface lets one change the map attribute
at run time as well as observe what regions have been reserved.

Signed-off-by: Michal Nazarewicz <m.nazarewicz@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 Documentation/contiguous-memory.txt |    4 +
 include/linux/cma.h                 |   11 +
 mm/Kconfig                          |   25 ++-
 mm/cma.c                            |  501 ++++++++++++++++++++++++++++++++++-
 4 files changed, 537 insertions(+), 4 deletions(-)

diff --git a/Documentation/contiguous-memory.txt b/Documentation/contiguous-memory.txt
index f1715ba..ec09d8e 100644
--- a/Documentation/contiguous-memory.txt
+++ b/Documentation/contiguous-memory.txt
@@ -258,6 +258,10 @@
      iff it matched in previous pattern.  If the second part is
      omitted it will mach any type of memory requested by device.
 
+     If debugfs support is enabled, this attribute is accessible via
+     debugfs and can be changed at run-time by writing to
+     contiguous/map.
+
      Some examples (whitespace added for better readability):
 
          cma_map = foo/quaz = r1;
diff --git a/include/linux/cma.h b/include/linux/cma.h
index a6031a7..8437104 100644
--- a/include/linux/cma.h
+++ b/include/linux/cma.h
@@ -24,6 +24,7 @@
 
 struct device;
 struct cma_info;
+struct dentry;
 
 /**
  * struct cma - an allocated contiguous chunk of memory.
@@ -276,6 +277,11 @@ struct cma_region {
 	unsigned users;
 	struct list_head list;
 
+#if defined CONFIG_CMA_DEBUGFS
+	const char *to_alloc_link, *from_alloc_link;
+	struct dentry *dir, *to_alloc, *from_alloc;
+#endif
+
 	unsigned used:1;
 	unsigned registered:1;
 	unsigned reserved:1;
@@ -382,6 +388,11 @@ struct cma_allocator {
 	void (*unpin)(struct cma *chunk);
 
 	struct list_head list;
+
+#if defined CONFIG_CMA_DEBUGFS
+	const char *dir_name;
+	struct dentry *regs_dir;
+#endif
 };
 
 /**
diff --git a/mm/Kconfig b/mm/Kconfig
index c7eb1bc..a5480ea 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -351,16 +351,35 @@ config CMA
 	  For more information see <Documentation/contiguous-memory.txt>.
 	  If unsure, say "n".
 
-config CMA_DEBUG
-	bool "CMA debug messages (DEVELOPEMENT)"
+config CMA_DEVELOPEMENT
+	bool "Include CMA developement features"
 	depends on CMA
 	help
+	  This lets you enable some developement features of the CMA
+	  framework.  It does not add any code to the kernel.
+
+	  Those options are mostly usable during development and testing.
+	  If unsure, say "n".
+
+config CMA_DEBUG
+	bool "CMA debug messages"
+	depends on CMA_DEVELOPEMENT
+	help
 	  Turns on debug messages in CMA.  This produces KERN_DEBUG
 	  messages for every CMA call as well as various messages while
 	  processing calls such as cma_alloc().  This option does not
 	  affect warning and error messages.
 
-	  This is mostly used during development.  If unsure, say "n".
+config CMA_DEBUGFS
+	bool "CMA debugfs interface support"
+	depends on CMA_DEVELOPEMENT && DEBUG_FS
+	help
+	  Enable support for debugfs interface.  It is available under the
+	  "contiguous" directory in the debugfs root directory.  Each
+	  region and allocator is represented there.
+
+	  For more information consult
+	  <Documentation/contiguous-memory.txt>.
 
 config CMA_GENERIC_ALLOCATOR
 	bool "CMA generic allocator"
diff --git a/mm/cma.c b/mm/cma.c
index 17276b3..dfdeeb7 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -34,11 +34,16 @@
 #include <linux/slab.h>        /* kmalloc() */
 #include <linux/string.h>      /* str*() */
 #include <linux/genalloc.h>    /* gen_pool_*() */
+#include <linux/debugfs.h>     /* debugfs stuff */
+#include <linux/uaccess.h>     /* copy_{to,from}_user */
 
 #include <linux/cma.h>
 
 
-/* Protects cma_regions, cma_allocators, cma_map and cma_map_length. */
+/*
+ * Protects cma_regions, cma_allocators, cma_map, cma_map_length,
+ * cma_dfs_regions and cma_dfs_allocators.
+ */
 static DEFINE_MUTEX(cma_mutex);
 
 
@@ -139,7 +144,13 @@ int __init __must_check cma_early_region_register(struct cma_region *reg)
 
 /************************* Regions & Allocators *************************/
 
+static void __cma_dfs_region_add(struct cma_region *reg);
+static void __cma_dfs_region_alloc_update(struct cma_region *reg);
+static void __cma_dfs_allocator_add(struct cma_allocator *alloc);
+
 static int __cma_region_attach_alloc(struct cma_region *reg);
+static void __maybe_unused __cma_region_detach_alloc(struct cma_region *reg);
+
 
 /* List of all regions.  Named regions are kept before unnamed. */
 static LIST_HEAD(cma_regions);
@@ -222,6 +233,8 @@ int __must_check cma_region_register(struct cma_region *reg)
 	else
 		list_add_tail(&reg->list, &cma_regions);
 
+	__cma_dfs_region_add(reg);
+
 done:
 	mutex_unlock(&cma_mutex);
 
@@ -298,6 +311,8 @@ int cma_allocator_register(struct cma_allocator *alloc)
 		__cma_region_attach_alloc(reg);
 	}
 
+	__cma_dfs_allocator_add(alloc);
+
 	mutex_unlock(&cma_mutex);
 
 	pr_debug("%s: allocator registered\n", alloc->name ?: "(unnamed)");
@@ -481,6 +496,476 @@ static int __init cma_init(void)
 subsys_initcall(cma_init);
 
 
+/************************* Debugfs *************************/
+
+#if defined CONFIG_CMA_DEBUGFS
+
+static struct dentry *cma_dfs_regions, *cma_dfs_allocators;
+
+struct cma_dfs_file {
+	const char *name;
+	const struct file_operations *ops;
+};
+
+static struct dentry *
+cma_dfs_create_file(const char *name, struct dentry *parent,
+		    void *priv, const struct file_operations *ops)
+{
+	struct dentry *d;
+	d = debugfs_create_file(name, ops->write ? 0644 : 0444,
+				parent, priv, ops);
+	if (IS_ERR_OR_NULL(d)) {
+		pr_err("debugfs: %s: %s: unable to create\n",
+		       parent->d_iname, name);
+		return NULL;
+	}
+
+	return d;
+}
+
+static void cma_dfs_create_files(const struct cma_dfs_file *files,
+				 struct dentry *parent, void *priv)
+{
+	while (files->name
+	    && cma_dfs_create_file(files->name, parent, priv, files->ops))
+		++files;
+}
+
+static struct dentry *
+cma_dfs_create_dir(const char *name, struct dentry *parent)
+{
+	struct dentry *d = debugfs_create_dir(name, parent);
+
+	if (IS_ERR_OR_NULL(d)) {
+		pr_err("debugfs: %s: %s: unable to create\n",
+		       parent ? (const char *)parent->d_iname : "<root>", name);
+		return NULL;
+	}
+
+	return d;
+}
+
+static struct dentry *
+cma_dfs_create_lnk(const char *name, struct dentry *parent, const char *target)
+{
+	struct dentry *d = debugfs_create_symlink(name, parent, target);
+
+	if (IS_ERR_OR_NULL(d)) {
+		pr_err("debugfs: %s: %s: unable to create\n",
+		       parent->d_iname, name);
+		return NULL;
+	}
+
+	return d;
+}
+
+static int cma_dfs_open(struct inode *inode, struct file *file)
+{
+	file->private_data = inode->i_private;
+	return 0;
+}
+
+static ssize_t cma_dfs_map_read(struct file *file, char __user *buf,
+				size_t size, loff_t *offp)
+{
+	ssize_t len;
+
+	if (!cma_map_length || *offp)
+		return 0;
+
+	mutex_lock(&cma_mutex);
+
+	/* may have changed */
+	len = cma_map_length;
+	if (!len)
+		goto done;
+
+	len = min_t(size_t, size, len);
+	if (copy_to_user(buf, cma_map, len))
+		len = -EFAULT;
+	else if ((size_t)len < size && put_user('\n', buf + len++))
+		len = -EFAULT;
+
+done:
+	mutex_unlock(&cma_mutex);
+
+	if (len > 0)
+		*offp = len;
+
+	return len;
+}
+
+static ssize_t cma_dfs_map_write(struct file *file, const char __user *buf,
+				 size_t size, loff_t *offp)
+{
+	char *val, *v;
+	ssize_t len;
+
+	if (size >= PAGE_SIZE || *offp)
+		return -ENOSPC;
+
+	val = kmalloc(size + 1, GFP_KERNEL);
+	if (!val)
+		return -ENOMEM;
+
+	if (copy_from_user(val, buf, size)) {
+		len = -EFAULT;
+		goto done;
+	}
+	val[size] = '\0';
+
+	len = cma_map_validate(val);
+	if (len < 0)
+		goto done;
+	val[len] = '\0';
+
+	mutex_lock(&cma_mutex);
+	v = (char *)cma_map;
+	cma_map = val;
+	val = v;
+	cma_map_length = len;
+	mutex_unlock(&cma_mutex);
+
+done:
+	kfree(val);
+
+	if (len > 0)
+		*offp = len;
+
+	return len;
+}
+
+static int __init cma_dfs_init(void)
+{
+	static const struct file_operations map_ops = {
+		.read = cma_dfs_map_read,
+		.write = cma_dfs_map_write,
+	};
+
+	struct dentry *root, *a, *r;
+
+	root = cma_dfs_create_dir("contiguous", NULL);
+	if (!root)
+		return 0;
+
+	if (!cma_dfs_create_file("map", root, NULL, &map_ops))
+		goto error;
+
+	a = cma_dfs_create_dir("allocators", root);
+	if (!a)
+		goto error;
+
+	r = cma_dfs_create_dir("regions", root);
+	if (!r)
+		goto error;
+
+	mutex_lock(&cma_mutex);
+	{
+		struct cma_allocator *alloc;
+		cma_dfs_allocators = a;
+		cma_foreach_allocator(alloc)
+			__cma_dfs_allocator_add(alloc);
+	}
+
+	{
+		struct cma_region *reg;
+		cma_dfs_regions = r;
+		cma_foreach_region(reg)
+			__cma_dfs_region_add(reg);
+	}
+	mutex_unlock(&cma_mutex);
+
+	return 0;
+
+error:
+	debugfs_remove_recursive(root);
+	return 0;
+}
+device_initcall(cma_dfs_init);
+
+static ssize_t cma_dfs_region_name_read(struct file *file, char __user *buf,
+					size_t size, loff_t *offp)
+{
+	struct cma_region *reg = file->private_data;
+	size_t len;
+
+	if (!reg->name || *offp)
+		return 0;
+
+	len = min(strlen(reg->name), size);
+	if (copy_to_user(buf, reg->name, len))
+		return -EFAULT;
+	if (len < size && put_user('\n', buf + len++))
+		return -EFAULT;
+
+	*offp = len;
+	return len;
+}
+
+static ssize_t cma_dfs_region_info_read(struct file *file, char __user *buf,
+					size_t size, loff_t *offp)
+{
+	struct cma_region *reg = file->private_data;
+	char str[min((size_t)63, size) + 1];
+	int len;
+
+	if (*offp)
+		return 0;
+
+	len = snprintf(str, sizeof str, "%p %p %p\n",
+		       (void *)reg->start, (void *)reg->size,
+		       (void *)reg->free_space);
+
+	if (copy_to_user(buf, str, len))
+		return -EFAULT;
+
+	*offp = len;
+	return len;
+}
+
+static ssize_t cma_dfs_region_alloc_read(struct file *file, char __user *buf,
+					 size_t size, loff_t *offp)
+{
+	struct cma_region *reg = file->private_data;
+	char str[min((size_t)63, size) + 1];
+	const char *fmt;
+	const void *arg;
+	int len = 0;
+
+	if (*offp)
+		return 0;
+
+	mutex_lock(&cma_mutex);
+
+	if (reg->alloc) {
+		if (reg->alloc->name) {
+			fmt = "%s\n";
+			arg = reg->alloc->name;
+		} else {
+			fmt = "0x%p\n";
+			arg = (void *)reg->alloc;
+		}
+	} else if (reg->alloc_name) {
+		fmt = "[%s]\n";
+		arg = reg->alloc_name;
+	} else {
+		goto done;
+	}
+
+	len = snprintf(str, sizeof str, fmt, arg);
+
+done:
+	mutex_unlock(&cma_mutex);
+
+	if (len) {
+		if (copy_to_user(buf, str, len))
+			return -EFAULT;
+		*offp = len;
+	}
+	return len;
+}
+
+static ssize_t
+cma_dfs_region_alloc_write(struct file *file, const char __user *buf,
+			   size_t size, loff_t *offp)
+{
+	struct cma_region *reg = file->private_data;
+	ssize_t ret;
+	char *s, *t;
+
+	if (size > 64 || *offp)
+		return -ENOSPC;
+
+	if (reg->alloc && reg->users)
+		return -EBUSY;
+
+	s = kmalloc(size + 1, GFP_KERNEL);
+	if (!s)
+		return -ENOMEM;
+
+	if (copy_from_user(s, buf, size)) {
+		ret = -EFAULT;
+		goto done_free;
+	}
+
+	s[size] = '\0';
+	t = strchr(s, '\n');
+	if (t == s) {
+		kfree(s);
+		s = NULL;
+	}
+	if (t)
+		*t = '\0';
+
+	mutex_lock(&cma_mutex);
+
+	/* things may have changed while we were acquiring lock */
+	if (reg->alloc && reg->users) {
+		ret = -EBUSY;
+	} else {
+		if (reg->alloc)
+			__cma_region_detach_alloc(reg);
+
+		t = s;
+		s = reg->free_alloc_name ? (char *)reg->alloc_name : NULL;
+
+		reg->alloc_name = t;
+		reg->free_alloc_name = 1;
+
+		ret = size;
+	}
+
+	mutex_unlock(&cma_mutex);
+
+done_free:
+	kfree(s);
+
+	if (ret > 0)
+		*offp = ret;
+	return ret;
+}
+
+static const struct cma_dfs_file __cma_dfs_region_files[] = {
+	{
+		"name", &(const struct file_operations){
+			.open = cma_dfs_open,
+			.read = cma_dfs_region_name_read,
+		},
+	},
+	{
+		"info", &(const struct file_operations){
+			.open = cma_dfs_open,
+			.read = cma_dfs_region_info_read,
+		},
+	},
+	{
+		"alloc", &(const struct file_operations){
+			.open = cma_dfs_open,
+			.read = cma_dfs_region_alloc_read,
+			.write = cma_dfs_region_alloc_write,
+		},
+	},
+	{ }
+};
+
+static void __cma_dfs_region_add(struct cma_region *reg)
+{
+	struct dentry *d;
+
+	if (!cma_dfs_regions || reg->dir)
+		return;
+
+	/* Region's directory */
+	reg->from_alloc_link = kasprintf(GFP_KERNEL, "../../regions/0x%p",
+					 (void *)reg->start);
+	if (!reg->from_alloc_link)
+		return;
+
+	d = cma_dfs_create_dir(reg->from_alloc_link + 14, cma_dfs_regions);
+	if (!d) {
+		kfree(reg->from_alloc_link);
+		return;
+	}
+
+	if (reg->name)
+		cma_dfs_create_lnk(reg->name, cma_dfs_regions,
+				   reg->from_alloc_link + 14);
+
+	reg->dir = d;
+
+	/* Files */
+	cma_dfs_create_files(__cma_dfs_region_files, d, reg);
+
+	/* Link to allocator */
+	__cma_dfs_region_alloc_update(reg);
+}
+
+static void __cma_dfs_region_alloc_update(struct cma_region *reg)
+{
+	if (!cma_dfs_regions || !cma_dfs_allocators || !reg->dir)
+		return;
+
+	/* Remove stall links */
+	if (reg->to_alloc) {
+		debugfs_remove(reg->to_alloc);
+		reg->to_alloc = NULL;
+	}
+
+	if (reg->from_alloc) {
+		debugfs_remove(reg->from_alloc);
+		reg->from_alloc = NULL;
+	}
+
+	if (reg->to_alloc_link) {
+		kfree(reg->to_alloc_link);
+		reg->to_alloc_link = NULL;
+	}
+
+	if (!reg->alloc)
+		return;
+
+	/* Create new links */
+	if (reg->alloc->regs_dir)
+		reg->from_alloc =
+			cma_dfs_create_lnk(reg->from_alloc_link + 14,
+					   reg->alloc->regs_dir,
+					   reg->from_alloc_link);
+
+	if (!reg->alloc->dir_name)
+		return;
+
+	reg->to_alloc_link = kasprintf(GFP_KERNEL, "../allocators/%s",
+				       reg->alloc->dir_name);
+	if (reg->to_alloc_link &&
+	    !cma_dfs_create_lnk("allocator", reg->dir, reg->to_alloc_link)) {
+		kfree(reg->to_alloc_link);
+		reg->to_alloc_link = NULL;
+	}
+}
+
+static inline void __cma_dfs_allocator_add(struct cma_allocator *alloc)
+{
+	struct dentry *d;
+
+	if (!cma_dfs_allocators || alloc->dir_name)
+		return;
+
+	alloc->dir_name = alloc->name ?:
+		kasprintf(GFP_KERNEL, "0x%p", (void *)alloc);
+	if (!alloc->dir_name)
+		return;
+
+	d = cma_dfs_create_dir(alloc->dir_name, cma_dfs_allocators);
+	if (!d) {
+		if (!alloc->name)
+			kfree(alloc->dir_name);
+		alloc->dir_name = NULL;
+		return;
+	}
+
+	alloc->regs_dir = cma_dfs_create_dir("regions", d);
+}
+
+#else
+
+static inline void __cma_dfs_region_add(struct cma_region *reg)
+{
+	/* nop */
+}
+
+static inline void __cma_dfs_allocator_add(struct cma_allocator *alloc)
+{
+	/* nop */
+}
+
+static inline void __cma_dfs_region_alloc_update(struct cma_region *reg)
+{
+	/* nop */
+}
+
+#endif
+
+
 /************************* The Device API *************************/
 
 static const char *__must_check
@@ -731,10 +1216,24 @@ static int __cma_region_attach_alloc(struct cma_region *reg)
 		reg->alloc = alloc;
 		pr_debug("init: %s: %s: initialised allocator\n",
 			 reg->name ?: "(private)", alloc->name ?: "(unnamed)");
+		__cma_dfs_region_alloc_update(reg);
 	}
 	return ret;
 }
 
+static void __cma_region_detach_alloc(struct cma_region *reg)
+{
+	if (!reg->alloc)
+		return;
+
+	if (reg->alloc->cleanup)
+		reg->alloc->cleanup(reg);
+
+	reg->alloc = NULL;
+	reg->used = 1;
+	__cma_dfs_region_alloc_update(reg);
+}
+
 
 /*
  * s            ::= rules
-- 
1.7.2.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
