Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 856449003C7
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 21:33:41 -0400 (EDT)
Received: by pacdd16 with SMTP id dd16so142022389pac.2
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 18:33:41 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id dh8si35794510pad.230.2015.08.25.18.33.39
        for <linux-mm@kvack.org>;
        Tue, 25 Aug 2015 18:33:40 -0700 (PDT)
Subject: [PATCH v2 6/9] libnvdimm, pfn: 'struct page' provider infrastructure
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 25 Aug 2015 21:27:57 -0400
Message-ID: <20150826012756.8851.2002.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <20150826010220.8851.18077.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <20150826010220.8851.18077.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: boaz@plexistor.com, david@fromorbit.com, linux-kernel@vger.kernel.org, hch@lst.de, linux-mm@kvack.org, hpa@zytor.com, ross.zwisler@linux.intel.com, mingo@kernel.org

Implement the base infrastructure for libnvdimm PFN devices. Similar to
BTT devices they take a namespace as a backing device and layer
functionality on top. In this case the functionality is reserving space
for an array of 'struct page' entries to be handed out through
pfn_to_page(). For now this is just the basic libnvdimm-device-model for
configuring the base PFN device.

As the namespace claiming mechanism for PFN devices is mostly identical
to BTT devices drivers/nvdimm/claim.c is created to house the common
bits.

Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/nvdimm/Kconfig          |   22 +++
 drivers/nvdimm/Makefile         |    2 
 drivers/nvdimm/btt.c            |    6 -
 drivers/nvdimm/btt_devs.c       |  172 +-------------------
 drivers/nvdimm/claim.c          |  201 +++++++++++++++++++++++
 drivers/nvdimm/namespace_devs.c |   34 +++-
 drivers/nvdimm/nd-core.h        |    9 +
 drivers/nvdimm/nd.h             |   51 ++++++
 drivers/nvdimm/pfn.h            |   35 ++++
 drivers/nvdimm/pfn_devs.c       |  336 +++++++++++++++++++++++++++++++++++++++
 drivers/nvdimm/region.c         |    2 
 drivers/nvdimm/region_devs.c    |   19 ++
 tools/testing/nvdimm/Kbuild     |    2 
 13 files changed, 714 insertions(+), 177 deletions(-)
 create mode 100644 drivers/nvdimm/claim.c
 create mode 100644 drivers/nvdimm/pfn.h
 create mode 100644 drivers/nvdimm/pfn_devs.c

diff --git a/drivers/nvdimm/Kconfig b/drivers/nvdimm/Kconfig
index 72226acb5c0f..ace25b53b755 100644
--- a/drivers/nvdimm/Kconfig
+++ b/drivers/nvdimm/Kconfig
@@ -21,6 +21,7 @@ config BLK_DEV_PMEM
 	default LIBNVDIMM
 	depends on HAS_IOMEM
 	select ND_BTT if BTT
+	select ND_PFN if NVDIMM_PFN
 	help
 	  Memory ranges for PMEM are described by either an NFIT
 	  (NVDIMM Firmware Interface Table, see CONFIG_NFIT_ACPI), a
@@ -47,12 +48,16 @@ config ND_BLK
 	  (CONFIG_ACPI_NFIT), or otherwise exposes BLK-mode
 	  capabilities.
 
+config ND_CLAIM
+	bool
+
 config ND_BTT
 	tristate
 
 config BTT
 	bool "BTT: Block Translation Table (atomic sector updates)"
 	default y if LIBNVDIMM
+	select ND_CLAIM
 	help
 	  The Block Translation Table (BTT) provides atomic sector
 	  update semantics for persistent memory devices, so that
@@ -65,4 +70,21 @@ config BTT
 
 	  Select Y if unsure
 
+config ND_PFN
+	tristate
+
+config NVDIMM_PFN
+	bool "PFN: Map persistent (device) memory"
+	default LIBNVDIMM
+	select ND_CLAIM
+	help
+	  Map persistent memory, i.e. advertise it to the memory
+	  management sub-system.  By default persistent memory does
+	  not support direct I/O, RDMA, or any other usage that
+	  requires a 'struct page' to mediate an I/O request.  This
+	  driver allocates and initializes the infrastructure needed
+	  to support those use cases.
+
+	  Select Y if unsure
+
 endif
diff --git a/drivers/nvdimm/Makefile b/drivers/nvdimm/Makefile
index 9bf15db52dee..ea84d3c4e8e5 100644
--- a/drivers/nvdimm/Makefile
+++ b/drivers/nvdimm/Makefile
@@ -20,4 +20,6 @@ libnvdimm-y += region_devs.o
 libnvdimm-y += region.o
 libnvdimm-y += namespace_devs.o
 libnvdimm-y += label.o
+libnvdimm-$(CONFIG_ND_CLAIM) += claim.o
 libnvdimm-$(CONFIG_BTT) += btt_devs.o
+libnvdimm-$(CONFIG_NVDIMM_PFN) += pfn_devs.o
diff --git a/drivers/nvdimm/btt.c b/drivers/nvdimm/btt.c
index 19588291550b..028d2d137bc5 100644
--- a/drivers/nvdimm/btt.c
+++ b/drivers/nvdimm/btt.c
@@ -731,6 +731,7 @@ static int create_arenas(struct btt *btt)
 static int btt_arena_write_layout(struct arena_info *arena)
 {
 	int ret;
+	u64 sum;
 	struct btt_sb *super;
 	struct nd_btt *nd_btt = arena->nd_btt;
 	const u8 *parent_uuid = nd_dev_to_uuid(&nd_btt->ndns->dev);
@@ -770,7 +771,8 @@ static int btt_arena_write_layout(struct arena_info *arena)
 	super->info2off = cpu_to_le64(arena->info2off - arena->infooff);
 
 	super->flags = 0;
-	super->checksum = cpu_to_le64(nd_btt_sb_checksum(super));
+	sum = nd_sb_checksum((struct nd_gen_sb *) super);
+	super->checksum = cpu_to_le64(sum);
 
 	ret = btt_info_write(arena, super);
 
@@ -1422,8 +1424,6 @@ static int __init nd_btt_init(void)
 {
 	int rc;
 
-	BUILD_BUG_ON(sizeof(struct btt_sb) != SZ_4K);
-
 	btt_major = register_blkdev(0, "btt");
 	if (btt_major < 0)
 		return btt_major;
diff --git a/drivers/nvdimm/btt_devs.c b/drivers/nvdimm/btt_devs.c
index 242ae1c550ad..59ad54a63d9f 100644
--- a/drivers/nvdimm/btt_devs.c
+++ b/drivers/nvdimm/btt_devs.c
@@ -21,63 +21,13 @@
 #include "btt.h"
 #include "nd.h"
 
-static void __nd_btt_detach_ndns(struct nd_btt *nd_btt)
-{
-	struct nd_namespace_common *ndns = nd_btt->ndns;
-
-	dev_WARN_ONCE(&nd_btt->dev, !mutex_is_locked(&ndns->dev.mutex)
-			|| ndns->claim != &nd_btt->dev,
-			"%s: invalid claim\n", __func__);
-	ndns->claim = NULL;
-	nd_btt->ndns = NULL;
-	put_device(&ndns->dev);
-}
-
-static void nd_btt_detach_ndns(struct nd_btt *nd_btt)
-{
-	struct nd_namespace_common *ndns = nd_btt->ndns;
-
-	if (!ndns)
-		return;
-	get_device(&ndns->dev);
-	device_lock(&ndns->dev);
-	__nd_btt_detach_ndns(nd_btt);
-	device_unlock(&ndns->dev);
-	put_device(&ndns->dev);
-}
-
-static bool __nd_btt_attach_ndns(struct nd_btt *nd_btt,
-		struct nd_namespace_common *ndns)
-{
-	if (ndns->claim)
-		return false;
-	dev_WARN_ONCE(&nd_btt->dev, !mutex_is_locked(&ndns->dev.mutex)
-			|| nd_btt->ndns,
-			"%s: invalid claim\n", __func__);
-	ndns->claim = &nd_btt->dev;
-	nd_btt->ndns = ndns;
-	get_device(&ndns->dev);
-	return true;
-}
-
-static bool nd_btt_attach_ndns(struct nd_btt *nd_btt,
-		struct nd_namespace_common *ndns)
-{
-	bool claimed;
-
-	device_lock(&ndns->dev);
-	claimed = __nd_btt_attach_ndns(nd_btt, ndns);
-	device_unlock(&ndns->dev);
-	return claimed;
-}
-
 static void nd_btt_release(struct device *dev)
 {
 	struct nd_region *nd_region = to_nd_region(dev->parent);
 	struct nd_btt *nd_btt = to_nd_btt(dev);
 
 	dev_dbg(dev, "%s\n", __func__);
-	nd_btt_detach_ndns(nd_btt);
+	nd_detach_ndns(&nd_btt->dev, &nd_btt->ndns);
 	ida_simple_remove(&nd_region->btt_ida, nd_btt->id);
 	kfree(nd_btt->uuid);
 	kfree(nd_btt);
@@ -172,104 +122,15 @@ static ssize_t namespace_show(struct device *dev,
 	return rc;
 }
 
-static int namespace_match(struct device *dev, void *data)
-{
-	char *name = data;
-
-	return strcmp(name, dev_name(dev)) == 0;
-}
-
-static bool is_nd_btt_idle(struct device *dev)
-{
-	struct nd_region *nd_region = to_nd_region(dev->parent);
-	struct nd_btt *nd_btt = to_nd_btt(dev);
-
-	if (nd_region->btt_seed == dev || nd_btt->ndns || dev->driver)
-		return false;
-	return true;
-}
-
-static ssize_t __namespace_store(struct device *dev,
-		struct device_attribute *attr, const char *buf, size_t len)
-{
-	struct nd_btt *nd_btt = to_nd_btt(dev);
-	struct nd_namespace_common *ndns;
-	struct device *found;
-	char *name;
-
-	if (dev->driver) {
-		dev_dbg(dev, "%s: -EBUSY\n", __func__);
-		return -EBUSY;
-	}
-
-	name = kstrndup(buf, len, GFP_KERNEL);
-	if (!name)
-		return -ENOMEM;
-	strim(name);
-
-	if (strncmp(name, "namespace", 9) == 0 || strcmp(name, "") == 0)
-		/* pass */;
-	else {
-		len = -EINVAL;
-		goto out;
-	}
-
-	ndns = nd_btt->ndns;
-	if (strcmp(name, "") == 0) {
-		/* detach the namespace and destroy / reset the btt device */
-		nd_btt_detach_ndns(nd_btt);
-		if (is_nd_btt_idle(dev))
-			nd_device_unregister(dev, ND_ASYNC);
-		else {
-			nd_btt->lbasize = 0;
-			kfree(nd_btt->uuid);
-			nd_btt->uuid = NULL;
-		}
-		goto out;
-	} else if (ndns) {
-		dev_dbg(dev, "namespace already set to: %s\n",
-				dev_name(&ndns->dev));
-		len = -EBUSY;
-		goto out;
-	}
-
-	found = device_find_child(dev->parent, name, namespace_match);
-	if (!found) {
-		dev_dbg(dev, "'%s' not found under %s\n", name,
-				dev_name(dev->parent));
-		len = -ENODEV;
-		goto out;
-	}
-
-	ndns = to_ndns(found);
-	if (__nvdimm_namespace_capacity(ndns) < SZ_16M) {
-		dev_dbg(dev, "%s too small to host btt\n", name);
-		len = -ENXIO;
-		goto out_attach;
-	}
-
-	WARN_ON_ONCE(!is_nvdimm_bus_locked(&nd_btt->dev));
-	if (!nd_btt_attach_ndns(nd_btt, ndns)) {
-		dev_dbg(dev, "%s already claimed\n",
-				dev_name(&ndns->dev));
-		len = -EBUSY;
-	}
-
- out_attach:
-	put_device(&ndns->dev); /* from device_find_child */
- out:
-	kfree(name);
-	return len;
-}
-
 static ssize_t namespace_store(struct device *dev,
 		struct device_attribute *attr, const char *buf, size_t len)
 {
+	struct nd_btt *nd_btt = to_nd_btt(dev);
 	ssize_t rc;
 
 	nvdimm_bus_lock(dev);
 	device_lock(dev);
-	rc = __namespace_store(dev, attr, buf, len);
+	rc = nd_namespace_store(dev, &nd_btt->ndns, buf, len);
 	dev_dbg(dev, "%s: result: %zd wrote: %s%s", __func__,
 			rc, buf, buf[len - 1] == '\n' ? "" : "\n");
 	device_unlock(dev);
@@ -324,7 +185,7 @@ static struct device *__nd_btt_create(struct nd_region *nd_region,
 	dev->type = &nd_btt_device_type;
 	dev->groups = nd_btt_attribute_groups;
 	device_initialize(&nd_btt->dev);
-	if (ndns && !__nd_btt_attach_ndns(nd_btt, ndns)) {
+	if (ndns && !__nd_attach_ndns(&nd_btt->dev, ndns, &nd_btt->ndns)) {
 		dev_dbg(&ndns->dev, "%s failed, already claimed by %s\n",
 				__func__, dev_name(ndns->claim));
 		put_device(dev);
@@ -375,7 +236,7 @@ bool nd_btt_arena_is_valid(struct nd_btt *nd_btt, struct btt_sb *super)
 
 	checksum = le64_to_cpu(super->checksum);
 	super->checksum = 0;
-	if (checksum != nd_btt_sb_checksum(super))
+	if (checksum != nd_sb_checksum((struct nd_gen_sb *) super))
 		return false;
 	super->checksum = cpu_to_le64(checksum);
 
@@ -387,25 +248,6 @@ bool nd_btt_arena_is_valid(struct nd_btt *nd_btt, struct btt_sb *super)
 }
 EXPORT_SYMBOL(nd_btt_arena_is_valid);
 
-/*
- * nd_btt_sb_checksum: compute checksum for btt info block
- *
- * Returns a fletcher64 checksum of everything in the given info block
- * except the last field (since that's where the checksum lives).
- */
-u64 nd_btt_sb_checksum(struct btt_sb *btt_sb)
-{
-	u64 sum;
-	__le64 sum_save;
-
-	sum_save = btt_sb->checksum;
-	btt_sb->checksum = 0;
-	sum = nd_fletcher64(btt_sb, sizeof(*btt_sb), 1);
-	btt_sb->checksum = sum_save;
-	return sum;
-}
-EXPORT_SYMBOL(nd_btt_sb_checksum);
-
 static int __nd_btt_probe(struct nd_btt *nd_btt,
 		struct nd_namespace_common *ndns, struct btt_sb *btt_sb)
 {
@@ -453,7 +295,9 @@ int nd_btt_probe(struct nd_namespace_common *ndns, void *drvdata)
 	dev_dbg(&ndns->dev, "%s: btt: %s\n", __func__,
 			rc == 0 ? dev_name(dev) : "<none>");
 	if (rc < 0) {
-		__nd_btt_detach_ndns(to_nd_btt(dev));
+		struct nd_btt *nd_btt = to_nd_btt(dev);
+
+		__nd_detach_ndns(dev, &nd_btt->ndns);
 		put_device(dev);
 	}
 
diff --git a/drivers/nvdimm/claim.c b/drivers/nvdimm/claim.c
new file mode 100644
index 000000000000..e8f03b0e95e4
--- /dev/null
+++ b/drivers/nvdimm/claim.c
@@ -0,0 +1,201 @@
+/*
+ * Copyright(c) 2013-2015 Intel Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+#include <linux/device.h>
+#include <linux/sizes.h>
+#include "nd-core.h"
+#include "pfn.h"
+#include "btt.h"
+#include "nd.h"
+
+void __nd_detach_ndns(struct device *dev, struct nd_namespace_common **_ndns)
+{
+	struct nd_namespace_common *ndns = *_ndns;
+
+	dev_WARN_ONCE(dev, !mutex_is_locked(&ndns->dev.mutex)
+			|| ndns->claim != dev,
+			"%s: invalid claim\n", __func__);
+	ndns->claim = NULL;
+	*_ndns = NULL;
+	put_device(&ndns->dev);
+}
+
+void nd_detach_ndns(struct device *dev,
+		struct nd_namespace_common **_ndns)
+{
+	struct nd_namespace_common *ndns = *_ndns;
+
+	if (!ndns)
+		return;
+	get_device(&ndns->dev);
+	device_lock(&ndns->dev);
+	__nd_detach_ndns(dev, _ndns);
+	device_unlock(&ndns->dev);
+	put_device(&ndns->dev);
+}
+
+bool __nd_attach_ndns(struct device *dev, struct nd_namespace_common *attach,
+		struct nd_namespace_common **_ndns)
+{
+	if (attach->claim)
+		return false;
+	dev_WARN_ONCE(dev, !mutex_is_locked(&attach->dev.mutex)
+			|| *_ndns,
+			"%s: invalid claim\n", __func__);
+	attach->claim = dev;
+	*_ndns = attach;
+	get_device(&attach->dev);
+	return true;
+}
+
+bool nd_attach_ndns(struct device *dev, struct nd_namespace_common *attach,
+		struct nd_namespace_common **_ndns)
+{
+	bool claimed;
+
+	device_lock(&attach->dev);
+	claimed = __nd_attach_ndns(dev, attach, _ndns);
+	device_unlock(&attach->dev);
+	return claimed;
+}
+
+static int namespace_match(struct device *dev, void *data)
+{
+	char *name = data;
+
+	return strcmp(name, dev_name(dev)) == 0;
+}
+
+static bool is_idle(struct device *dev, struct nd_namespace_common *ndns)
+{
+	struct nd_region *nd_region = to_nd_region(dev->parent);
+	struct device *seed = NULL;
+
+	if (is_nd_btt(dev))
+		seed = nd_region->btt_seed;
+	else if (is_nd_pfn(dev))
+		seed = nd_region->pfn_seed;
+
+	if (seed == dev || ndns || dev->driver)
+		return false;
+	return true;
+}
+
+static void nd_detach_and_reset(struct device *dev,
+		struct nd_namespace_common **_ndns)
+{
+	/* detach the namespace and destroy / reset the device */
+	nd_detach_ndns(dev, _ndns);
+	if (is_idle(dev, *_ndns)) {
+		nd_device_unregister(dev, ND_ASYNC);
+	} else if (is_nd_btt(dev)) {
+		struct nd_btt *nd_btt = to_nd_btt(dev);
+
+		nd_btt->lbasize = 0;
+		kfree(nd_btt->uuid);
+		nd_btt->uuid = NULL;
+	} else if (is_nd_pfn(dev)) {
+		struct nd_pfn *nd_pfn = to_nd_pfn(dev);
+
+		kfree(nd_pfn->uuid);
+		nd_pfn->uuid = NULL;
+		nd_pfn->mode = PFN_MODE_NONE;
+	}
+}
+
+ssize_t nd_namespace_store(struct device *dev,
+		struct nd_namespace_common **_ndns, const char *buf,
+		size_t len)
+{
+	struct nd_namespace_common *ndns;
+	struct device *found;
+	char *name;
+
+	if (dev->driver) {
+		dev_dbg(dev, "%s: -EBUSY\n", __func__);
+		return -EBUSY;
+	}
+
+	name = kstrndup(buf, len, GFP_KERNEL);
+	if (!name)
+		return -ENOMEM;
+	strim(name);
+
+	if (strncmp(name, "namespace", 9) == 0 || strcmp(name, "") == 0)
+		/* pass */;
+	else {
+		len = -EINVAL;
+		goto out;
+	}
+
+	ndns = *_ndns;
+	if (strcmp(name, "") == 0) {
+		nd_detach_and_reset(dev, _ndns);
+		goto out;
+	} else if (ndns) {
+		dev_dbg(dev, "namespace already set to: %s\n",
+				dev_name(&ndns->dev));
+		len = -EBUSY;
+		goto out;
+	}
+
+	found = device_find_child(dev->parent, name, namespace_match);
+	if (!found) {
+		dev_dbg(dev, "'%s' not found under %s\n", name,
+				dev_name(dev->parent));
+		len = -ENODEV;
+		goto out;
+	}
+
+	ndns = to_ndns(found);
+	if (__nvdimm_namespace_capacity(ndns) < SZ_16M) {
+		dev_dbg(dev, "%s too small to host\n", name);
+		len = -ENXIO;
+		goto out_attach;
+	}
+
+	WARN_ON_ONCE(!is_nvdimm_bus_locked(dev));
+	if (!nd_attach_ndns(dev, ndns, _ndns)) {
+		dev_dbg(dev, "%s already claimed\n",
+				dev_name(&ndns->dev));
+		len = -EBUSY;
+	}
+
+ out_attach:
+	put_device(&ndns->dev); /* from device_find_child */
+ out:
+	kfree(name);
+	return len;
+}
+
+/*
+ * nd_sb_checksum: compute checksum for a generic info block
+ *
+ * Returns a fletcher64 checksum of everything in the given info block
+ * except the last field (since that's where the checksum lives).
+ */
+u64 nd_sb_checksum(struct nd_gen_sb *nd_gen_sb)
+{
+	u64 sum;
+	__le64 sum_save;
+
+	BUILD_BUG_ON(sizeof(struct btt_sb) != SZ_4K);
+	BUILD_BUG_ON(sizeof(struct nd_pfn_sb) != SZ_4K);
+	BUILD_BUG_ON(sizeof(struct nd_gen_sb) != SZ_4K);
+
+	sum_save = nd_gen_sb->checksum;
+	nd_gen_sb->checksum = 0;
+	sum = nd_fletcher64(nd_gen_sb, sizeof(*nd_gen_sb), 1);
+	nd_gen_sb->checksum = sum_save;
+	return sum;
+}
+EXPORT_SYMBOL(nd_sb_checksum);
diff --git a/drivers/nvdimm/namespace_devs.c b/drivers/nvdimm/namespace_devs.c
index b18ffea9d85b..9303ca29be9b 100644
--- a/drivers/nvdimm/namespace_devs.c
+++ b/drivers/nvdimm/namespace_devs.c
@@ -82,8 +82,16 @@ const char *nvdimm_namespace_disk_name(struct nd_namespace_common *ndns,
 	struct nd_region *nd_region = to_nd_region(ndns->dev.parent);
 	const char *suffix = "";
 
-	if (ndns->claim && is_nd_btt(ndns->claim))
-		suffix = "s";
+	if (ndns->claim) {
+		if (is_nd_btt(ndns->claim))
+			suffix = "s";
+		else if (is_nd_pfn(ndns->claim))
+			suffix = "m";
+		else
+			dev_WARN_ONCE(&ndns->dev, 1,
+					"unknown claim type by %s\n",
+					dev_name(ndns->claim));
+	}
 
 	if (is_namespace_pmem(&ndns->dev) || is_namespace_io(&ndns->dev))
 		sprintf(name, "pmem%d%s", nd_region->id, suffix);
@@ -1255,12 +1263,22 @@ static const struct attribute_group *nd_namespace_attribute_groups[] = {
 struct nd_namespace_common *nvdimm_namespace_common_probe(struct device *dev)
 {
 	struct nd_btt *nd_btt = is_nd_btt(dev) ? to_nd_btt(dev) : NULL;
+	struct nd_pfn *nd_pfn = is_nd_pfn(dev) ? to_nd_pfn(dev) : NULL;
 	struct nd_namespace_common *ndns;
 	resource_size_t size;
 
-	if (nd_btt) {
-		ndns = nd_btt->ndns;
-		if (!ndns)
+	if (nd_btt || nd_pfn) {
+		struct device *host = NULL;
+
+		if (nd_btt) {
+			host = &nd_btt->dev;
+			ndns = nd_btt->ndns;
+		} else if (nd_pfn) {
+			host = &nd_pfn->dev;
+			ndns = nd_pfn->ndns;
+		}
+
+		if (!ndns || !host)
 			return ERR_PTR(-ENODEV);
 
 		/*
@@ -1271,12 +1289,12 @@ struct nd_namespace_common *nvdimm_namespace_common_probe(struct device *dev)
 		device_unlock(&ndns->dev);
 		if (ndns->dev.driver) {
 			dev_dbg(&ndns->dev, "is active, can't bind %s\n",
-					dev_name(&nd_btt->dev));
+					dev_name(host));
 			return ERR_PTR(-EBUSY);
 		}
-		if (dev_WARN_ONCE(&ndns->dev, ndns->claim != &nd_btt->dev,
+		if (dev_WARN_ONCE(&ndns->dev, ndns->claim != host,
 					"host (%s) vs claim (%s) mismatch\n",
-					dev_name(&nd_btt->dev),
+					dev_name(host),
 					dev_name(ndns->claim)))
 			return ERR_PTR(-ENXIO);
 	} else {
diff --git a/drivers/nvdimm/nd-core.h b/drivers/nvdimm/nd-core.h
index e1970c71ad1c..159aed532042 100644
--- a/drivers/nvdimm/nd-core.h
+++ b/drivers/nvdimm/nd-core.h
@@ -80,4 +80,13 @@ struct resource *nsblk_add_resource(struct nd_region *nd_region,
 int nvdimm_num_label_slots(struct nvdimm_drvdata *ndd);
 void get_ndd(struct nvdimm_drvdata *ndd);
 resource_size_t __nvdimm_namespace_capacity(struct nd_namespace_common *ndns);
+void nd_detach_ndns(struct device *dev, struct nd_namespace_common **_ndns);
+void __nd_detach_ndns(struct device *dev, struct nd_namespace_common **_ndns);
+bool nd_attach_ndns(struct device *dev, struct nd_namespace_common *attach,
+		struct nd_namespace_common **_ndns);
+bool __nd_attach_ndns(struct device *dev, struct nd_namespace_common *attach,
+		struct nd_namespace_common **_ndns);
+ssize_t nd_namespace_store(struct device *dev,
+		struct nd_namespace_common **_ndns, const char *buf,
+		size_t len);
 #endif /* __ND_CORE_H__ */
diff --git a/drivers/nvdimm/nd.h b/drivers/nvdimm/nd.h
index f9615824947b..95f7efc7fed9 100644
--- a/drivers/nvdimm/nd.h
+++ b/drivers/nvdimm/nd.h
@@ -29,6 +29,8 @@ enum {
 	ND_MAX_LANES = 256,
 	SECTOR_SHIFT = 9,
 	INT_LBASIZE_ALIGNMENT = 64,
+	ND_PFN_ALIGN = PAGES_PER_SECTION * PAGE_SIZE,
+	ND_PFN_MASK = ND_PFN_ALIGN - 1,
 };
 
 struct nvdimm_drvdata {
@@ -92,8 +94,10 @@ struct nd_region {
 	struct device dev;
 	struct ida ns_ida;
 	struct ida btt_ida;
+	struct ida pfn_ida;
 	struct device *ns_seed;
 	struct device *btt_seed;
+	struct device *pfn_seed;
 	u16 ndr_mappings;
 	u64 ndr_size;
 	u64 ndr_start;
@@ -133,6 +137,22 @@ struct nd_btt {
 	int id;
 };
 
+enum nd_pfn_mode {
+	PFN_MODE_NONE,
+	PFN_MODE_RAM,
+	PFN_MODE_PMEM,
+};
+
+struct nd_pfn {
+	int id;
+	u8 *uuid;
+	struct device dev;
+	unsigned long npfns;
+	enum nd_pfn_mode mode;
+	struct nd_pfn_sb *pfn_sb;
+	struct nd_namespace_common *ndns;
+};
+
 enum nd_async_mode {
 	ND_SYNC,
 	ND_ASYNC,
@@ -159,8 +179,13 @@ int nvdimm_init_config_data(struct nvdimm_drvdata *ndd);
 int nvdimm_set_config_data(struct nvdimm_drvdata *ndd, size_t offset,
 		void *buf, size_t len);
 struct nd_btt *to_nd_btt(struct device *dev);
-struct btt_sb;
-u64 nd_btt_sb_checksum(struct btt_sb *btt_sb);
+
+struct nd_gen_sb {
+	char reserved[SZ_4K - 8];
+	__le64 checksum;
+};
+
+u64 nd_sb_checksum(struct nd_gen_sb *sb);
 #if IS_ENABLED(CONFIG_BTT)
 int nd_btt_probe(struct nd_namespace_common *ndns, void *drvdata);
 bool is_nd_btt(struct device *dev);
@@ -180,8 +205,30 @@ static inline struct device *nd_btt_create(struct nd_region *nd_region)
 {
 	return NULL;
 }
+#endif
 
+struct nd_pfn *to_nd_pfn(struct device *dev);
+#if IS_ENABLED(CONFIG_NVDIMM_PFN)
+int nd_pfn_probe(struct nd_namespace_common *ndns, void *drvdata);
+bool is_nd_pfn(struct device *dev);
+struct device *nd_pfn_create(struct nd_region *nd_region);
+#else
+static inline int nd_pfn_probe(struct nd_namespace_common *ndns, void *drvdata)
+{
+	return -ENODEV;
+}
+
+static inline bool is_nd_pfn(struct device *dev)
+{
+	return false;
+}
+
+static inline struct device *nd_pfn_create(struct nd_region *nd_region)
+{
+	return NULL;
+}
 #endif
+
 struct nd_region *to_nd_region(struct device *dev);
 int nd_region_to_nstype(struct nd_region *nd_region);
 int nd_region_register_namespaces(struct nd_region *nd_region, int *err);
diff --git a/drivers/nvdimm/pfn.h b/drivers/nvdimm/pfn.h
new file mode 100644
index 000000000000..cc243754acef
--- /dev/null
+++ b/drivers/nvdimm/pfn.h
@@ -0,0 +1,35 @@
+/*
+ * Copyright (c) 2014-2015, Intel Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ */
+
+#ifndef __NVDIMM_PFN_H
+#define __NVDIMM_PFN_H
+
+#include <linux/types.h>
+
+#define PFN_SIG_LEN 16
+#define PFN_SIG "NVDIMM_PFN_INFO\0"
+
+struct nd_pfn_sb {
+	u8 signature[PFN_SIG_LEN];
+	u8 uuid[16];
+	u8 parent_uuid[16];
+	__le32 flags;
+	__le16 version_major;
+	__le16 version_minor;
+	__le64 dataoff;
+	__le64 npfns;
+	__le32 mode;
+	u8 padding[4012];
+	__le64 checksum;
+};
+#endif /* __NVDIMM_PFN_H */
diff --git a/drivers/nvdimm/pfn_devs.c b/drivers/nvdimm/pfn_devs.c
new file mode 100644
index 000000000000..f708d63709a5
--- /dev/null
+++ b/drivers/nvdimm/pfn_devs.c
@@ -0,0 +1,336 @@
+/*
+ * Copyright(c) 2013-2015 Intel Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+#include <linux/blkdev.h>
+#include <linux/device.h>
+#include <linux/genhd.h>
+#include <linux/sizes.h>
+#include <linux/slab.h>
+#include <linux/fs.h>
+#include <linux/mm.h>
+#include "nd-core.h"
+#include "pfn.h"
+#include "nd.h"
+
+static void nd_pfn_release(struct device *dev)
+{
+	struct nd_region *nd_region = to_nd_region(dev->parent);
+	struct nd_pfn *nd_pfn = to_nd_pfn(dev);
+
+	dev_dbg(dev, "%s\n", __func__);
+	nd_detach_ndns(&nd_pfn->dev, &nd_pfn->ndns);
+	ida_simple_remove(&nd_region->pfn_ida, nd_pfn->id);
+	kfree(nd_pfn->uuid);
+	kfree(nd_pfn);
+}
+
+static struct device_type nd_pfn_device_type = {
+	.name = "nd_pfn",
+	.release = nd_pfn_release,
+};
+
+bool is_nd_pfn(struct device *dev)
+{
+	return dev ? dev->type == &nd_pfn_device_type : false;
+}
+EXPORT_SYMBOL(is_nd_pfn);
+
+struct nd_pfn *to_nd_pfn(struct device *dev)
+{
+	struct nd_pfn *nd_pfn = container_of(dev, struct nd_pfn, dev);
+
+	WARN_ON(!is_nd_pfn(dev));
+	return nd_pfn;
+}
+EXPORT_SYMBOL(to_nd_pfn);
+
+static ssize_t mode_show(struct device *dev,
+		struct device_attribute *attr, char *buf)
+{
+	struct nd_pfn *nd_pfn = to_nd_pfn(dev);
+
+	switch (nd_pfn->mode) {
+	case PFN_MODE_RAM:
+		return sprintf(buf, "ram\n");
+	case PFN_MODE_PMEM:
+		return sprintf(buf, "pmem\n");
+	default:
+		return sprintf(buf, "none\n");
+	}
+}
+
+static ssize_t mode_store(struct device *dev,
+		struct device_attribute *attr, const char *buf, size_t len)
+{
+	struct nd_pfn *nd_pfn = to_nd_pfn(dev);
+	ssize_t rc = 0;
+
+	device_lock(dev);
+	nvdimm_bus_lock(dev);
+	if (dev->driver)
+		rc = -EBUSY;
+	else {
+		size_t n = len - 1;
+
+		if (strncmp(buf, "pmem\n", n) == 0
+				|| strncmp(buf, "pmem", n) == 0) {
+			/* TODO: allocate from PMEM support */
+			rc = -ENOTTY;
+		} else if (strncmp(buf, "ram\n", n) == 0
+				|| strncmp(buf, "ram", n) == 0)
+			nd_pfn->mode = PFN_MODE_RAM;
+		else if (strncmp(buf, "none\n", n) == 0
+				|| strncmp(buf, "none", n) == 0)
+			nd_pfn->mode = PFN_MODE_NONE;
+		else
+			rc = -EINVAL;
+	}
+	dev_dbg(dev, "%s: result: %zd wrote: %s%s", __func__,
+			rc, buf, buf[len - 1] == '\n' ? "" : "\n");
+	nvdimm_bus_unlock(dev);
+	device_unlock(dev);
+
+	return rc ? rc : len;
+}
+static DEVICE_ATTR_RW(mode);
+
+static ssize_t uuid_show(struct device *dev,
+		struct device_attribute *attr, char *buf)
+{
+	struct nd_pfn *nd_pfn = to_nd_pfn(dev);
+
+	if (nd_pfn->uuid)
+		return sprintf(buf, "%pUb\n", nd_pfn->uuid);
+	return sprintf(buf, "\n");
+}
+
+static ssize_t uuid_store(struct device *dev,
+		struct device_attribute *attr, const char *buf, size_t len)
+{
+	struct nd_pfn *nd_pfn = to_nd_pfn(dev);
+	ssize_t rc;
+
+	device_lock(dev);
+	rc = nd_uuid_store(dev, &nd_pfn->uuid, buf, len);
+	dev_dbg(dev, "%s: result: %zd wrote: %s%s", __func__,
+			rc, buf, buf[len - 1] == '\n' ? "" : "\n");
+	device_unlock(dev);
+
+	return rc ? rc : len;
+}
+static DEVICE_ATTR_RW(uuid);
+
+static ssize_t namespace_show(struct device *dev,
+		struct device_attribute *attr, char *buf)
+{
+	struct nd_pfn *nd_pfn = to_nd_pfn(dev);
+	ssize_t rc;
+
+	nvdimm_bus_lock(dev);
+	rc = sprintf(buf, "%s\n", nd_pfn->ndns
+			? dev_name(&nd_pfn->ndns->dev) : "");
+	nvdimm_bus_unlock(dev);
+	return rc;
+}
+
+static ssize_t namespace_store(struct device *dev,
+		struct device_attribute *attr, const char *buf, size_t len)
+{
+	struct nd_pfn *nd_pfn = to_nd_pfn(dev);
+	ssize_t rc;
+
+	nvdimm_bus_lock(dev);
+	device_lock(dev);
+	rc = nd_namespace_store(dev, &nd_pfn->ndns, buf, len);
+	dev_dbg(dev, "%s: result: %zd wrote: %s%s", __func__,
+			rc, buf, buf[len - 1] == '\n' ? "" : "\n");
+	device_unlock(dev);
+	nvdimm_bus_unlock(dev);
+
+	return rc;
+}
+static DEVICE_ATTR_RW(namespace);
+
+static struct attribute *nd_pfn_attributes[] = {
+	&dev_attr_mode.attr,
+	&dev_attr_namespace.attr,
+	&dev_attr_uuid.attr,
+	NULL,
+};
+
+static struct attribute_group nd_pfn_attribute_group = {
+	.attrs = nd_pfn_attributes,
+};
+
+static const struct attribute_group *nd_pfn_attribute_groups[] = {
+	&nd_pfn_attribute_group,
+	&nd_device_attribute_group,
+	&nd_numa_attribute_group,
+	NULL,
+};
+
+static struct device *__nd_pfn_create(struct nd_region *nd_region,
+		u8 *uuid, enum nd_pfn_mode mode,
+		struct nd_namespace_common *ndns)
+{
+	struct nd_pfn *nd_pfn;
+	struct device *dev;
+
+	/* we can only create pages for contiguous ranged of pmem */
+	if (!is_nd_pmem(&nd_region->dev))
+		return NULL;
+
+	nd_pfn = kzalloc(sizeof(*nd_pfn), GFP_KERNEL);
+	if (!nd_pfn)
+		return NULL;
+
+	nd_pfn->id = ida_simple_get(&nd_region->pfn_ida, 0, 0, GFP_KERNEL);
+	if (nd_pfn->id < 0) {
+		kfree(nd_pfn);
+		return NULL;
+	}
+
+	nd_pfn->mode = mode;
+	if (uuid)
+		uuid = kmemdup(uuid, 16, GFP_KERNEL);
+	nd_pfn->uuid = uuid;
+	dev = &nd_pfn->dev;
+	dev_set_name(dev, "pfn%d.%d", nd_region->id, nd_pfn->id);
+	dev->parent = &nd_region->dev;
+	dev->type = &nd_pfn_device_type;
+	dev->groups = nd_pfn_attribute_groups;
+	device_initialize(&nd_pfn->dev);
+	if (ndns && !__nd_attach_ndns(&nd_pfn->dev, ndns, &nd_pfn->ndns)) {
+		dev_dbg(&ndns->dev, "%s failed, already claimed by %s\n",
+				__func__, dev_name(ndns->claim));
+		put_device(dev);
+		return NULL;
+	}
+	return dev;
+}
+
+struct device *nd_pfn_create(struct nd_region *nd_region)
+{
+	struct device *dev = __nd_pfn_create(nd_region, NULL, PFN_MODE_NONE,
+			NULL);
+
+	if (dev)
+		__nd_device_register(dev);
+	return dev;
+}
+
+static int nd_pfn_validate(struct nd_pfn *nd_pfn)
+{
+	struct nd_namespace_common *ndns = nd_pfn->ndns;
+	struct nd_pfn_sb *pfn_sb = nd_pfn->pfn_sb;
+	struct nd_namespace_io *nsio;
+	u64 checksum, offset;
+
+	if (!pfn_sb || !ndns)
+		return -ENODEV;
+
+	if (!is_nd_pmem(nd_pfn->dev.parent))
+		return -ENODEV;
+
+	/* section alignment for simple hotplug */
+	if (nvdimm_namespace_capacity(ndns) < ND_PFN_ALIGN)
+		return -ENODEV;
+
+	if (nvdimm_read_bytes(ndns, SZ_4K, pfn_sb, sizeof(*pfn_sb)))
+		return -ENXIO;
+
+	if (memcmp(pfn_sb->signature, PFN_SIG, PFN_SIG_LEN) != 0)
+		return -ENODEV;
+
+	checksum = le64_to_cpu(pfn_sb->checksum);
+	pfn_sb->checksum = 0;
+	if (checksum != nd_sb_checksum((struct nd_gen_sb *) pfn_sb))
+		return -ENODEV;
+	pfn_sb->checksum = cpu_to_le64(checksum);
+
+	switch (le32_to_cpu(pfn_sb->mode)) {
+	case PFN_MODE_RAM:
+		break;
+	case PFN_MODE_PMEM:
+		/* TODO: allocate from PMEM support */
+		return -ENOTTY;
+	default:
+		return -ENXIO;
+	}
+
+	if (!nd_pfn->uuid) {
+		/* from probe we allocate */
+		nd_pfn->uuid = kmemdup(pfn_sb->uuid, 16, GFP_KERNEL);
+		if (!nd_pfn->uuid)
+			return -ENOMEM;
+	} else {
+		/* from init we validate */
+		if (memcmp(nd_pfn->uuid, pfn_sb->uuid, 16) != 0)
+			return -EINVAL;
+	}
+
+	/*
+	 * These warnings are verbose because they can only trigger in
+	 * the case where the physical address alignment of the
+	 * namespace has changed since the pfn superblock was
+	 * established.
+	 */
+	offset = le64_to_cpu(pfn_sb->dataoff);
+	nsio = to_nd_namespace_io(&ndns->dev);
+	if ((nsio->res.start + offset) & (ND_PFN_ALIGN - 1)) {
+		dev_err(&nd_pfn->dev,
+				"init failed: %s with offset %#llx not section aligned\n",
+				dev_name(&ndns->dev), offset);
+		return -EBUSY;
+	} else if (offset >= resource_size(&nsio->res)) {
+		dev_err(&nd_pfn->dev, "pfn array size exceeds capacity of %s\n",
+				dev_name(&ndns->dev));
+		return -EBUSY;
+	}
+
+	return 0;
+}
+
+int nd_pfn_probe(struct nd_namespace_common *ndns, void *drvdata)
+{
+	int rc;
+	struct device *dev;
+	struct nd_pfn *nd_pfn;
+	struct nd_pfn_sb *pfn_sb;
+	struct nd_region *nd_region = to_nd_region(ndns->dev.parent);
+
+	if (ndns->force_raw)
+		return -ENODEV;
+
+	nvdimm_bus_lock(&ndns->dev);
+	dev = __nd_pfn_create(nd_region, NULL, PFN_MODE_NONE, ndns);
+	nvdimm_bus_unlock(&ndns->dev);
+	if (!dev)
+		return -ENOMEM;
+	dev_set_drvdata(dev, drvdata);
+	pfn_sb = kzalloc(sizeof(*pfn_sb), GFP_KERNEL);
+	nd_pfn = to_nd_pfn(dev);
+	nd_pfn->pfn_sb = pfn_sb;
+	rc = nd_pfn_validate(nd_pfn);
+	nd_pfn->pfn_sb = NULL;
+	kfree(pfn_sb);
+	dev_dbg(&ndns->dev, "%s: pfn: %s\n", __func__,
+			rc == 0 ? dev_name(dev) : "<none>");
+	if (rc < 0) {
+		__nd_detach_ndns(dev, &nd_pfn->ndns);
+		put_device(dev);
+	} else
+		__nd_device_register(&nd_pfn->dev);
+
+	return rc;
+}
+EXPORT_SYMBOL(nd_pfn_probe);
diff --git a/drivers/nvdimm/region.c b/drivers/nvdimm/region.c
index f28f78ccff19..7da63eac78ee 100644
--- a/drivers/nvdimm/region.c
+++ b/drivers/nvdimm/region.c
@@ -53,6 +53,7 @@ static int nd_region_probe(struct device *dev)
 		return -ENODEV;
 
 	nd_region->btt_seed = nd_btt_create(nd_region);
+	nd_region->pfn_seed = nd_pfn_create(nd_region);
 	if (err == 0)
 		return 0;
 
@@ -84,6 +85,7 @@ static int nd_region_remove(struct device *dev)
 	nvdimm_bus_lock(dev);
 	nd_region->ns_seed = NULL;
 	nd_region->btt_seed = NULL;
+	nd_region->pfn_seed = NULL;
 	dev_set_drvdata(dev, NULL);
 	nvdimm_bus_unlock(dev);
 
diff --git a/drivers/nvdimm/region_devs.c b/drivers/nvdimm/region_devs.c
index 7384455792bf..da4338154ad2 100644
--- a/drivers/nvdimm/region_devs.c
+++ b/drivers/nvdimm/region_devs.c
@@ -345,6 +345,23 @@ static ssize_t btt_seed_show(struct device *dev,
 }
 static DEVICE_ATTR_RO(btt_seed);
 
+static ssize_t pfn_seed_show(struct device *dev,
+		struct device_attribute *attr, char *buf)
+{
+	struct nd_region *nd_region = to_nd_region(dev);
+	ssize_t rc;
+
+	nvdimm_bus_lock(dev);
+	if (nd_region->pfn_seed)
+		rc = sprintf(buf, "%s\n", dev_name(nd_region->pfn_seed));
+	else
+		rc = sprintf(buf, "\n");
+	nvdimm_bus_unlock(dev);
+
+	return rc;
+}
+static DEVICE_ATTR_RO(pfn_seed);
+
 static ssize_t read_only_show(struct device *dev,
 		struct device_attribute *attr, char *buf)
 {
@@ -373,6 +390,7 @@ static struct attribute *nd_region_attributes[] = {
 	&dev_attr_nstype.attr,
 	&dev_attr_mappings.attr,
 	&dev_attr_btt_seed.attr,
+	&dev_attr_pfn_seed.attr,
 	&dev_attr_read_only.attr,
 	&dev_attr_set_cookie.attr,
 	&dev_attr_available_size.attr,
@@ -744,6 +762,7 @@ static struct nd_region *nd_region_create(struct nvdimm_bus *nvdimm_bus,
 	nd_region->numa_node = ndr_desc->numa_node;
 	ida_init(&nd_region->ns_ida);
 	ida_init(&nd_region->btt_ida);
+	ida_init(&nd_region->pfn_ida);
 	dev = &nd_region->dev;
 	dev_set_name(dev, "region%d", nd_region->id);
 	dev->parent = &nvdimm_bus->dev;
diff --git a/tools/testing/nvdimm/Kbuild b/tools/testing/nvdimm/Kbuild
index e667579d38a0..22d4d19a49bc 100644
--- a/tools/testing/nvdimm/Kbuild
+++ b/tools/testing/nvdimm/Kbuild
@@ -41,7 +41,9 @@ libnvdimm-y += $(NVDIMM_SRC)/region_devs.o
 libnvdimm-y += $(NVDIMM_SRC)/region.o
 libnvdimm-y += $(NVDIMM_SRC)/namespace_devs.o
 libnvdimm-y += $(NVDIMM_SRC)/label.o
+libnvdimm-$(CONFIG_ND_CLAIM) += $(NVDIMM_SRC)/claim.o
 libnvdimm-$(CONFIG_BTT) += $(NVDIMM_SRC)/btt_devs.o
+libnvdimm-$(CONFIG_NVDIMM_PFN) += $(NVDIMM_SRC)/pfn_devs.o
 libnvdimm-y += config_check.o
 
 obj-m += test/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
