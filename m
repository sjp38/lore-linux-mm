Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id D2B7D600044
	for <linux-mm@kvack.org>; Fri,  6 Aug 2010 09:20:47 -0400 (EDT)
Received: from eu_spt2 (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0L6Q003ZJFQKQS@mailout1.w1.samsung.com> for linux-mm@kvack.org;
 Fri, 06 Aug 2010 14:20:44 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0L6Q00FAIFQJE3@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 06 Aug 2010 14:20:44 +0100 (BST)
Date: Fri, 06 Aug 2010 15:22:09 +0200
From: Michal Nazarewicz <m.nazarewicz@samsung.com>
Subject: [PATCH/RFCv3 3/6] mm: cma: Added SysFS support
In-reply-to: 
 <6a924738f412a7ad738e99123411b7a20f761ae1.1281100495.git.m.nazarewicz@samsung.com>
Message-id: 
 <a5061fdb8e8819f1cc281c4279c295146fab6d68.1281100495.git.m.nazarewicz@samsung.com>
MIME-version: 1.0
Content-type: TEXT/PLAIN
Content-transfer-encoding: 7BIT
References: <cover.1281100495.git.m.nazarewicz@samsung.com>
 <743102607e2c5fb20e3c0676fadbcb93d501a78e.1281100495.git.m.nazarewicz@samsung.com>
 <6a924738f412a7ad738e99123411b7a20f761ae1.1281100495.git.m.nazarewicz@samsung.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Hans Verkuil <hverkuil@xs4all.nl>, Marek Szyprowski <m.szyprowski@samsung.com>, Daniel Walker <dwalker@codeaurora.org>, Jonathan Corbet <corbet@lwn.net>, Pawel Osciak <p.osciak@samsung.com>, Mark Brown <broonie@opensource.wolfsonmicro.com>, Hiremath Vaibhav <hvaibhav@ti.com>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Kyungmin Park <kyungmin.park@samsung.com>, Zach Pfeffer <zpfeffer@codeaurora.org>, Russell King <linux@arm.linux.org.uk>, jaeryul.oh@samsung.com, kgene.kim@samsung.com, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-kernel@vger.kernel.org, Michal Nazarewicz <m.nazarewicz@samsung.com>
List-ID: <linux-mm.kvack.org>

The SysFS development interface lets one change the map attribute
at run time as well as observe what regions have been reserved.
---
 .../ABI/testing/sysfs-kernel-mm-contiguous         |   58 ++++
 Documentation/contiguous-memory.txt                |    4 +
 mm/Kconfig                                         |   18 +-
 mm/cma.c                                           |  349 +++++++++++++++++++-
 4 files changed, 425 insertions(+), 4 deletions(-)
 create mode 100644 Documentation/ABI/testing/sysfs-kernel-mm-contiguous

diff --git a/Documentation/ABI/testing/sysfs-kernel-mm-contiguous b/Documentation/ABI/testing/sysfs-kernel-mm-contiguous
new file mode 100644
index 0000000..0c22bf1
--- /dev/null
+++ b/Documentation/ABI/testing/sysfs-kernel-mm-contiguous
@@ -0,0 +1,58 @@
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
+Date:		August 201
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
+		* "asterisk" -- whether it is an asterisk region (0 or 1).
+		* "alloc" -- name of the allocator.
+
+		The "asterisk" file is writable and region's status
+		can be changed.
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
+
diff --git a/Documentation/contiguous-memory.txt b/Documentation/contiguous-memory.txt
index bee7d4f..8f1c7f2 100644
--- a/Documentation/contiguous-memory.txt
+++ b/Documentation/contiguous-memory.txt
@@ -288,6 +288,10 @@
      attribute is used as well (ie. a "*/*=*" rule is assumed at the
      end).
 
+     If SysFS support is enabled, this attribute is accessible via
+     SysFS and can be changed at run-time by writing to
+     /sys/kernel/mm/contiguous/map.
+
      Some examples (whitespace added for better readability):
 
          cma_map = foo = r1;
diff --git a/mm/Kconfig b/mm/Kconfig
index 3e9317c..ac0bb08 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -319,12 +319,26 @@ config CMA
 	  To make use of CMA you need to specify the regions and
 	  driver->region mapping on command line when booting the kernel.
 
-config CMA_DEBUG
-	bool "CMA debug messages (DEVELOPEMENT)"
+config CMA_DEVELOPEMENT
+	bool "Include CMA developement features"
 	depends on CMA
 	help
+	  This lets you enable some developement features of the CMA
+	  freamework.
+
+config CMA_DEBUG
+	bool "CMA debug messages"
+	depends on CMA_DEVELOPEMENT
+	help
 	  Enable debug messages in CMA code.
 
+config CMA_SYSFS
+	bool "CMA SysFS interface support"
+	depends on CMA_DEVELOPEMENT
+	help
+	  Enable support for SysFS interface.
+
+config CMA_CMDLINE
 config CMA_BEST_FIT
 	bool "CMA best-fit allocator"
 	depends on CMA
diff --git a/mm/cma.c b/mm/cma.c
index b305b28..92ee869 100644
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
 
@@ -164,6 +164,8 @@ int __init __must_check cma_early_region_register(struct cma_region *reg)
 
 /************************* Regions & Allocators *************************/
 
+static void __cma_sysfs_region_add(struct cma_region *reg);
+
 static int __cma_region_attach_alloc(struct cma_region *reg);
 static void __maybe_unused __cma_region_detach_alloc(struct cma_region *reg);
 
@@ -249,6 +251,8 @@ int __must_check cma_region_register(struct cma_region *reg)
 	else
 		list_add_tail(&reg->list, &cma_regions);
 
+	__cma_sysfs_region_add(reg);
+
 done:
 	mutex_unlock(&cma_mutex);
 
@@ -509,6 +513,347 @@ subsys_initcall(cma_init);
 
 
 
+/************************* SysFS *************************/
+
+#if defined CONFIG_CMA_SYSFS
+
+static struct kobject cma_sysfs_regions;
+static int cma_sysfs_regions_ready;
+
+
+#define CMA_ATTR_INLINE(_type, _name)					\
+	&((struct cma_ ## _type ## _attribute){				\
+		.attr	= {						\
+			.name	= __stringify(_name),			\
+			.mode	= 0644,					\
+		},							\
+		.show	= cma_sysfs_ ## _type ## _ ## _name ## _show,	\
+		.store	= cma_sysfs_ ## _type ## _ ## _name ## _store,	\
+	}).attr
+
+#define CMA_ATTR_RO_INLINE(_type, _name)				\
+	&((struct cma_ ## _type ## _attribute){				\
+		.attr	= {						\
+			.name	= __stringify(_name),			\
+			.mode	= 0444,					\
+		},							\
+		.show	= cma_sysfs_ ## _type ## _ ## _name ## _show,	\
+	}).attr
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
+	.default_attrs	= (struct attribute *[]) {
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
+__initcall(cma_sysfs_init);
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
+static ssize_t
+cma_sysfs_region_asterisk_show(struct cma_region *reg, char *page)
+{
+	page[0] = reg->asterisk ? '1' : '0';
+	page[1] = '\n';
+	return 2;
+}
+
+static int
+cma_sysfs_region_asterisk_store(struct cma_region *reg, const char *page)
+{
+	unsigned long val;
+	int ret = strict_strtoul(page, 0, &val);
+	if (ret >= 0)
+		reg->asterisk = !!val;
+	return ret;
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
+	.default_attrs	= (struct attribute *[]) {
+		CMA_ATTR_RO_INLINE(region, name),
+		CMA_ATTR_RO_INLINE(region, start),
+		CMA_ATTR_RO_INLINE(region, size),
+		CMA_ATTR_RO_INLINE(region, free),
+		CMA_ATTR_RO_INLINE(region, users),
+		CMA_ATTR_INLINE(region, asterisk),
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
+				   &cma_sysfs_regions, "%p", (void *)reg->start);
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
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
