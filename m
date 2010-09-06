Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 7BA696B0082
	for <linux-mm@kvack.org>; Mon,  6 Sep 2010 02:34:44 -0400 (EDT)
Received: from eu_spt1 (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0L8B002XLBLT60@mailout1.w1.samsung.com> for linux-mm@kvack.org;
 Mon, 06 Sep 2010 07:34:41 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0L8B00LBHBLSQN@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 06 Sep 2010 07:34:41 +0100 (BST)
Date: Mon, 06 Sep 2010 08:33:53 +0200
From: Michal Nazarewicz <m.nazarewicz@samsung.com>
Subject: [RFCv5 3/9] mm: cma: Added SysFS support
In-reply-to: <cover.1283749231.git.mina86@mina86.com>
Message-id: 
 <9771a9c07874a642bb587f4c0ebf886d720332b6.1283749231.git.mina86@mina86.com>
MIME-version: 1.0
Content-type: TEXT/PLAIN
Content-transfer-encoding: 7BIT
References: <cover.1283749231.git.mina86@mina86.com>
Sender: owner-linux-mm@kvack.org
To: linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Daniel Walker <dwalker@codeaurora.org>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Hans Verkuil <hverkuil@xs4all.nl>, Jonathan Corbet <corbet@lwn.net>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Kyungmin Park <kyungmin.park@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, Pawel Osciak <p.osciak@samsung.com>, Peter Zijlstra <peterz@infradead.org>, Russell King <linux@arm.linux.org.uk>, Zach Pfeffer <zpfeffer@codeaurora.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

The SysFS development interface lets one change the map attribute
at run time as well as observe what regions have been reserved.

Signed-off-by: Michal Nazarewicz <m.nazarewicz@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 .../ABI/testing/sysfs-kernel-mm-contiguous         |   53 +++
 Documentation/contiguous-memory.txt                |    4 +
 include/linux/cma.h                                |    7 +
 mm/Kconfig                                         |   26 ++-
 mm/cma.c                                           |  345 +++++++++++++++++++-
 5 files changed, 430 insertions(+), 5 deletions(-)
 create mode 100644 Documentation/ABI/testing/sysfs-kernel-mm-contiguous

diff --git a/Documentation/ABI/testing/sysfs-kernel-mm-contiguous b/Documentation/ABI/testing/sysfs-kernel-mm-contiguous
new file mode 100644
index 0000000..8df15bc
--- /dev/null
+++ b/Documentation/ABI/testing/sysfs-kernel-mm-contiguous
@@ -0,0 +1,53 @@
+What:		/sys/kernel/mm/contiguous/
+Date:		August 2010
+Contact:	Michal Nazarewicz <m.nazarewicz@samsung.com>
+Description:
+		If CMA has been built with SysFS support,
+		/sys/kernel/mm/contiguous/ contains a file called
+		"map", a file called "allocators" and a directory
+		called "regions".
+
+		The "map" file lets one change the CMA's map attribute
+		at run-time.
+
+		The "allocators" file list all registered allocators.
+		Allocators with no name are listed as a single minus
+		sign.
+
+		The "regions" directory list all reserved regions.
+
+		For more details see
+		Documentation/contiguous-memory.txt.
+
+What:		/sys/kernel/mm/contiguous/regions/
+Date:		August 2010
+Contact:	Michal Nazarewicz <m.nazarewicz@samsung.com>
+Description:
+		The /sys/kernel/mm/contiguous/regions/ directory
+		contain directories for each registered CMA region.
+		The name of the directory is the same as the start
+		address of the region.
+
+		If region is named there is also a symbolic link named
+		like the region pointing to the region's directory.
+
+		Such directory contains the following files:
+
+		* "name"  -- the name of the region or an empty file
+		* "start" -- starting address of the region (formatted
+		            with %p, ie. hex).
+		* "size"  -- size of the region (in bytes).
+		* "free"  -- free space in the region (in bytes).
+		* "users" -- number of chunks allocated in the region.
+		* "alloc" -- name of the allocator.
+
+		If allocator is not attached to the region, "alloc" is
+		either the name of desired allocator in square
+		brackets (ie. "[foo]") or an empty file if region is
+		to be attached to default allocator.  If an allocator
+		is attached to the region. "alloc" is either its name
+		or "-" if attached allocator has no name.
+
+		If there are no chunks allocated in given region
+		("users" is "0") then a name of desired allocator can
+		be written to "alloc".
diff --git a/Documentation/contiguous-memory.txt b/Documentation/contiguous-memory.txt
index e470c6f..15aff7a 100644
--- a/Documentation/contiguous-memory.txt
+++ b/Documentation/contiguous-memory.txt
@@ -256,6 +256,10 @@
      iff it matched in previous pattern.  If the second part is
      omitted it will mach any type of memory requested by device.
 
+     If SysFS support is enabled, this attribute is accessible via
+     SysFS and can be changed at run-time by writing to
+     /sys/kernel/mm/contiguous/map.
+
      Some examples (whitespace added for better readability):
 
          cma_map = foo/quaz = r1;
diff --git a/include/linux/cma.h b/include/linux/cma.h
index f6f9cb5..d0f41f4 100644
--- a/include/linux/cma.h
+++ b/include/linux/cma.h
@@ -18,6 +18,9 @@
 #include <linux/rbtree.h>
 #include <linux/list.h>
 #include <linux/init.h>
+#if defined CONFIG_CMA_SYSFS
+#  include <linux/kobject.h>
+#endif
 
 
 struct device;
@@ -204,6 +207,10 @@ struct cma_region {
 	unsigned users;
 	struct list_head list;
 
+#if defined CONFIG_CMA_SYSFS
+	struct kobject kobj;
+#endif
+
 	unsigned used:1;
 	unsigned registered:1;
 	unsigned reserved:1;
diff --git a/mm/Kconfig b/mm/Kconfig
index 86043a3..8bed799 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -322,16 +322,36 @@ config CMA
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
+config CMA_SYSFS
+	bool "CMA SysFS interface support"
+	depends on CMA_DEVELOPEMENT
+	help
+	  Enable support for SysFS interface.  The interface is available
+	  under /sys/kernel/mm/contiguous.  Each region and allocator is
+	  represented there.
+
+	  For more information consult
+	  <Documentation/contiguous-memory.txt> and
+	  <Documentation/ABI/testing/sysfs-kernel-mm-contiguous> files.
 
 config CMA_BEST_FIT
 	bool "CMA best-fit allocator"
diff --git a/mm/cma.c b/mm/cma.c
index 06d0d5a..955f08c 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -38,8 +38,8 @@
 
 
 /*
- * Protects cma_regions, cma_allocators, cma_map, cma_map_length, and
- * cma_chunks_by_start.
+ * Protects cma_regions, cma_allocators, cma_map, cma_map_length,
+ * cma_kobj, cma_sysfs_regions and cma_chunks_by_start.
  */
 static DEFINE_MUTEX(cma_mutex);
 
@@ -143,7 +143,11 @@ int __init __must_check cma_early_region_register(struct cma_region *reg)
 
 /************************* Regions & Allocators *************************/
 
+static void __cma_sysfs_region_add(struct cma_region *reg);
+
 static int __cma_region_attach_alloc(struct cma_region *reg);
+static void __maybe_unused __cma_region_detach_alloc(struct cma_region *reg);
+
 
 /* List of all regions.  Named regions are kept before unnamed. */
 static LIST_HEAD(cma_regions);
@@ -226,6 +230,8 @@ int __must_check cma_region_register(struct cma_region *reg)
 	else
 		list_add_tail(&reg->list, &cma_regions);
 
+	__cma_sysfs_region_add(reg);
+
 done:
 	mutex_unlock(&cma_mutex);
 
@@ -482,6 +488,329 @@ subsys_initcall(cma_init);
 
 
 
+/************************* SysFS *************************/
+
+#if defined CONFIG_CMA_SYSFS
+
+static struct kobject cma_sysfs_regions;
+static int cma_sysfs_regions_ready;
+
+
+#define CMA_ATTR_INLINE(_type, _name)					\
+	(&((struct cma_ ## _type ## _attribute){			\
+		.attr	= {						\
+			.name	= __stringify(_name),			\
+			.mode	= 0644,					\
+		},							\
+		.show	= cma_sysfs_ ## _type ## _ ## _name ## _show,	\
+		.store	= cma_sysfs_ ## _type ## _ ## _name ## _store,	\
+	}).attr)
+
+#define CMA_ATTR_RO_INLINE(_type, _name)				\
+	(&((struct cma_ ## _type ## _attribute){			\
+		.attr	= {						\
+			.name	= __stringify(_name),			\
+			.mode	= 0444,					\
+		},							\
+		.show	= cma_sysfs_ ## _type ## _ ## _name ## _show,	\
+	}).attr)
+
+
+struct cma_root_attribute {
+	struct attribute attr;
+	ssize_t (*show)(char *buf);
+	int (*store)(const char *buf);
+};
+
+static ssize_t cma_sysfs_root_map_show(char *page)
+{
+	ssize_t len;
+
+	len = cma_map_length;
+	if (!len) {
+		*page = 0;
+		len = 0;
+	} else {
+		if (len > (size_t)PAGE_SIZE - 1)
+			len = (size_t)PAGE_SIZE - 1;
+		memcpy(page, cma_map, len);
+		page[len++] = '\n';
+	}
+
+	return len;
+}
+
+static int cma_sysfs_root_map_store(const char *page)
+{
+	ssize_t len = cma_map_validate(page);
+	char *val = NULL;
+
+	if (len < 0)
+		return len;
+
+	if (len) {
+		val = kmemdup(page, len + 1, GFP_KERNEL);
+		if (!val)
+			return -ENOMEM;
+		val[len] = '\0';
+	}
+
+	kfree(cma_map);
+	cma_map = val;
+	cma_map_length = len;
+
+	return 0;
+}
+
+static ssize_t cma_sysfs_root_allocators_show(char *page)
+{
+	struct cma_allocator *alloc;
+	size_t left = PAGE_SIZE;
+	char *ch = page;
+
+	cma_foreach_allocator(alloc) {
+		ssize_t l = snprintf(ch, left, "%s ", alloc->name ?: "-");
+		ch   += l;
+		left -= l;
+	}
+
+	if (ch != page)
+		ch[-1] = '\n';
+	return ch - page;
+}
+
+static ssize_t
+cma_sysfs_root_show(struct kobject *kobj, struct attribute *attr, char *buf)
+{
+	struct cma_root_attribute *rattr =
+		container_of(attr, struct cma_root_attribute, attr);
+	ssize_t ret;
+
+	mutex_lock(&cma_mutex);
+	ret = rattr->show(buf);
+	mutex_unlock(&cma_mutex);
+
+	return ret;
+}
+
+static ssize_t
+cma_sysfs_root_store(struct kobject *kobj, struct attribute *attr,
+		       const char *buf, size_t count)
+{
+	struct cma_root_attribute *rattr =
+		container_of(attr, struct cma_root_attribute, attr);
+	int ret;
+
+	mutex_lock(&cma_mutex);
+	ret = rattr->store(buf);
+	mutex_unlock(&cma_mutex);
+
+	return ret < 0 ? ret : count;
+}
+
+static struct kobj_type cma_sysfs_root_type = {
+	.sysfs_ops	= &(const struct sysfs_ops){
+		.show	= cma_sysfs_root_show,
+		.store	= cma_sysfs_root_store,
+	},
+	.default_attrs	= (struct attribute * []) {
+		CMA_ATTR_INLINE(root, map),
+		CMA_ATTR_RO_INLINE(root, allocators),
+		NULL
+	},
+};
+
+static int __init cma_sysfs_init(void)
+{
+	static struct kobject root;
+	static struct kobj_type fake_type;
+
+	struct cma_region *reg;
+	int ret;
+
+	/* Root */
+	ret = kobject_init_and_add(&root, &cma_sysfs_root_type,
+				   mm_kobj, "contiguous");
+	if (unlikely(ret < 0)) {
+		pr_err("init: unable to add root kobject: %d\n", ret);
+		return ret;
+	}
+
+	/* Regions */
+	ret = kobject_init_and_add(&cma_sysfs_regions, &fake_type,
+				   &root, "regions");
+	if (unlikely(ret < 0)) {
+		pr_err("init: unable to add regions kobject: %d\n", ret);
+		return ret;
+	}
+
+	mutex_lock(&cma_mutex);
+	cma_sysfs_regions_ready = 1;
+	cma_foreach_region(reg)
+		__cma_sysfs_region_add(reg);
+	mutex_unlock(&cma_mutex);
+
+	return 0;
+}
+device_initcall(cma_sysfs_init);
+
+
+
+struct cma_region_attribute {
+	struct attribute attr;
+	ssize_t (*show)(struct cma_region *reg, char *buf);
+	int (*store)(struct cma_region *reg, const char *buf);
+};
+
+
+static ssize_t cma_sysfs_region_name_show(struct cma_region *reg, char *page)
+{
+	return reg->name ? snprintf(page, PAGE_SIZE, "%s\n", reg->name) : 0;
+}
+
+static ssize_t cma_sysfs_region_start_show(struct cma_region *reg, char *page)
+{
+	return snprintf(page, PAGE_SIZE, "%p\n", (void *)reg->start);
+}
+
+static ssize_t cma_sysfs_region_size_show(struct cma_region *reg, char *page)
+{
+	return snprintf(page, PAGE_SIZE, "%zu\n", reg->size);
+}
+
+static ssize_t cma_sysfs_region_free_show(struct cma_region *reg, char *page)
+{
+	return snprintf(page, PAGE_SIZE, "%zu\n", reg->free_space);
+}
+
+static ssize_t cma_sysfs_region_users_show(struct cma_region *reg, char *page)
+{
+	return snprintf(page, PAGE_SIZE, "%u\n", reg->users);
+}
+
+static ssize_t cma_sysfs_region_alloc_show(struct cma_region *reg, char *page)
+{
+	if (reg->alloc)
+		return snprintf(page, PAGE_SIZE, "%s\n",
+				reg->alloc->name ?: "-");
+	else if (reg->alloc_name)
+		return snprintf(page, PAGE_SIZE, "[%s]\n", reg->alloc_name);
+	else
+		return 0;
+}
+
+static int
+cma_sysfs_region_alloc_store(struct cma_region *reg, const char *page)
+{
+	char *s;
+
+	if (reg->alloc && reg->users)
+		return -EBUSY;
+
+	if (!*page || *page == '\n') {
+		s = NULL;
+	} else {
+		size_t len;
+
+		for (s = (char *)page; *++s && *s != '\n'; )
+			/* nop */;
+
+		len = s - page;
+		s = kmemdup(page, len + 1, GFP_KERNEL);
+		if (!s)
+			return -ENOMEM;
+		s[len] = '\0';
+	}
+
+	if (reg->alloc)
+		__cma_region_detach_alloc(reg);
+
+	if (reg->free_alloc_name)
+		kfree(reg->alloc_name);
+
+	reg->alloc_name = s;
+	reg->free_alloc_name = !!s;
+
+	return 0;
+}
+
+
+static ssize_t
+cma_sysfs_region_show(struct kobject *kobj, struct attribute *attr,
+		      char *buf)
+{
+	struct cma_region *reg = container_of(kobj, struct cma_region, kobj);
+	struct cma_region_attribute *rattr =
+		container_of(attr, struct cma_region_attribute, attr);
+	ssize_t ret;
+
+	mutex_lock(&cma_mutex);
+	ret = rattr->show(reg, buf);
+	mutex_unlock(&cma_mutex);
+
+	return ret;
+}
+
+static int
+cma_sysfs_region_store(struct kobject *kobj, struct attribute *attr,
+		       const char *buf, size_t count)
+{
+	struct cma_region *reg = container_of(kobj, struct cma_region, kobj);
+	struct cma_region_attribute *rattr =
+		container_of(attr, struct cma_region_attribute, attr);
+	int ret;
+
+	mutex_lock(&cma_mutex);
+	ret = rattr->store(reg, buf);
+	mutex_unlock(&cma_mutex);
+
+	return ret < 0 ? ret : count;
+}
+
+static struct kobj_type cma_sysfs_region_type = {
+	.sysfs_ops	= &(const struct sysfs_ops){
+		.show	= cma_sysfs_region_show,
+		.store	= cma_sysfs_region_store,
+	},
+	.default_attrs	= (struct attribute * []) {
+		CMA_ATTR_RO_INLINE(region, name),
+		CMA_ATTR_RO_INLINE(region, start),
+		CMA_ATTR_RO_INLINE(region, size),
+		CMA_ATTR_RO_INLINE(region, free),
+		CMA_ATTR_RO_INLINE(region, users),
+		CMA_ATTR_INLINE(region, alloc),
+		NULL
+	},
+};
+
+static void __cma_sysfs_region_add(struct cma_region *reg)
+{
+	int ret;
+
+	if (!cma_sysfs_regions_ready)
+		return;
+
+	memset(&reg->kobj, 0, sizeof reg->kobj);
+
+	ret = kobject_init_and_add(&reg->kobj, &cma_sysfs_region_type,
+				   &cma_sysfs_regions,
+				   "%p", (void *)reg->start);
+
+	if (reg->name &&
+	    sysfs_create_link(&cma_sysfs_regions, &reg->kobj, reg->name) < 0)
+		/* Ignore any errors. */;
+}
+
+#else
+
+static void __cma_sysfs_region_add(struct cma_region *reg)
+{
+	/* nop */
+}
+
+#endif
+
+
 /************************* Chunks *************************/
 
 /* All chunks sorted by start address. */
@@ -785,6 +1114,18 @@ static int __cma_region_attach_alloc(struct cma_region *reg)
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
+}
+
 
 /*
  * s            ::= rules
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
