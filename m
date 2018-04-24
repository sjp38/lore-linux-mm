Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9382E6B0008
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 19:43:17 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id y129so9572938pgb.5
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 16:43:17 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id b23si9914981pgw.529.2018.04.24.16.43.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Apr 2018 16:43:16 -0700 (PDT)
Subject: [PATCH v9 3/9] memremap: split devm_memremap_pages() and memremap()
 infrastructure
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 24 Apr 2018 16:33:19 -0700
Message-ID: <152461279892.17530.9006728553718402327.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <152461278149.17530.2867511144531572045.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <152461278149.17530.2867511144531572045.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, david@fromorbit.com, linux-fsdevel@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.orgjack@suse.czhch@lst.de

Currently, kernel/memremap.c contains generic code for supporting
memremap() (CONFIG_HAS_IOMEM) and devm_memremap_pages()
(CONFIG_ZONE_DEVICE). This causes ongoing build maintenance problems as
additions to memremap.c, especially for the ZONE_DEVICE case, need to be
careful about being placed in ifdef guards. Remove the need for these
ifdef guards by moving the ZONE_DEVICE support functions to their own
compilation unit.

Cc: Jan Kara <jack@suse.cz>
Cc: Christoph Hellwig <hch@lst.de>
Cc: "JA(C)rA'me Glisse" <jglisse@redhat.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 kernel/Makefile   |    3 +
 kernel/iomem.c    |  167 ++++++++++++++++++++++++++++++++++++++++++++++++++
 kernel/memremap.c |  178 +----------------------------------------------------
 3 files changed, 171 insertions(+), 177 deletions(-)
 create mode 100644 kernel/iomem.c

diff --git a/kernel/Makefile b/kernel/Makefile
index f85ae5dfa474..9b9241361311 100644
--- a/kernel/Makefile
+++ b/kernel/Makefile
@@ -112,7 +112,8 @@ obj-$(CONFIG_JUMP_LABEL) += jump_label.o
 obj-$(CONFIG_CONTEXT_TRACKING) += context_tracking.o
 obj-$(CONFIG_TORTURE_TEST) += torture.o
 
-obj-$(CONFIG_HAS_IOMEM) += memremap.o
+obj-$(CONFIG_HAS_IOMEM) += iomem.o
+obj-$(CONFIG_ZONE_DEVICE) += memremap.o
 
 $(obj)/configs.o: $(obj)/config_data.h
 
diff --git a/kernel/iomem.c b/kernel/iomem.c
new file mode 100644
index 000000000000..f7525e14ebc6
--- /dev/null
+++ b/kernel/iomem.c
@@ -0,0 +1,167 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+#include <linux/device.h>
+#include <linux/types.h>
+#include <linux/io.h>
+#include <linux/mm.h>
+
+#ifndef ioremap_cache
+/* temporary while we convert existing ioremap_cache users to memremap */
+__weak void __iomem *ioremap_cache(resource_size_t offset, unsigned long size)
+{
+	return ioremap(offset, size);
+}
+#endif
+
+#ifndef arch_memremap_wb
+static void *arch_memremap_wb(resource_size_t offset, unsigned long size)
+{
+	return (__force void *)ioremap_cache(offset, size);
+}
+#endif
+
+#ifndef arch_memremap_can_ram_remap
+static bool arch_memremap_can_ram_remap(resource_size_t offset, size_t size,
+					unsigned long flags)
+{
+	return true;
+}
+#endif
+
+static void *try_ram_remap(resource_size_t offset, size_t size,
+			   unsigned long flags)
+{
+	unsigned long pfn = PHYS_PFN(offset);
+
+	/* In the simple case just return the existing linear address */
+	if (pfn_valid(pfn) && !PageHighMem(pfn_to_page(pfn)) &&
+	    arch_memremap_can_ram_remap(offset, size, flags))
+		return __va(offset);
+
+	return NULL; /* fallback to arch_memremap_wb */
+}
+
+/**
+ * memremap() - remap an iomem_resource as cacheable memory
+ * @offset: iomem resource start address
+ * @size: size of remap
+ * @flags: any of MEMREMAP_WB, MEMREMAP_WT, MEMREMAP_WC,
+ *		  MEMREMAP_ENC, MEMREMAP_DEC
+ *
+ * memremap() is "ioremap" for cases where it is known that the resource
+ * being mapped does not have i/o side effects and the __iomem
+ * annotation is not applicable. In the case of multiple flags, the different
+ * mapping types will be attempted in the order listed below until one of
+ * them succeeds.
+ *
+ * MEMREMAP_WB - matches the default mapping for System RAM on
+ * the architecture.  This is usually a read-allocate write-back cache.
+ * Morever, if MEMREMAP_WB is specified and the requested remap region is RAM
+ * memremap() will bypass establishing a new mapping and instead return
+ * a pointer into the direct map.
+ *
+ * MEMREMAP_WT - establish a mapping whereby writes either bypass the
+ * cache or are written through to memory and never exist in a
+ * cache-dirty state with respect to program visibility.  Attempts to
+ * map System RAM with this mapping type will fail.
+ *
+ * MEMREMAP_WC - establish a writecombine mapping, whereby writes may
+ * be coalesced together (e.g. in the CPU's write buffers), but is otherwise
+ * uncached. Attempts to map System RAM with this mapping type will fail.
+ */
+void *memremap(resource_size_t offset, size_t size, unsigned long flags)
+{
+	int is_ram = region_intersects(offset, size,
+				       IORESOURCE_SYSTEM_RAM, IORES_DESC_NONE);
+	void *addr = NULL;
+
+	if (!flags)
+		return NULL;
+
+	if (is_ram == REGION_MIXED) {
+		WARN_ONCE(1, "memremap attempted on mixed range %pa size: %#lx\n",
+				&offset, (unsigned long) size);
+		return NULL;
+	}
+
+	/* Try all mapping types requested until one returns non-NULL */
+	if (flags & MEMREMAP_WB) {
+		/*
+		 * MEMREMAP_WB is special in that it can be satisifed
+		 * from the direct map.  Some archs depend on the
+		 * capability of memremap() to autodetect cases where
+		 * the requested range is potentially in System RAM.
+		 */
+		if (is_ram == REGION_INTERSECTS)
+			addr = try_ram_remap(offset, size, flags);
+		if (!addr)
+			addr = arch_memremap_wb(offset, size);
+	}
+
+	/*
+	 * If we don't have a mapping yet and other request flags are
+	 * present then we will be attempting to establish a new virtual
+	 * address mapping.  Enforce that this mapping is not aliasing
+	 * System RAM.
+	 */
+	if (!addr && is_ram == REGION_INTERSECTS && flags != MEMREMAP_WB) {
+		WARN_ONCE(1, "memremap attempted on ram %pa size: %#lx\n",
+				&offset, (unsigned long) size);
+		return NULL;
+	}
+
+	if (!addr && (flags & MEMREMAP_WT))
+		addr = ioremap_wt(offset, size);
+
+	if (!addr && (flags & MEMREMAP_WC))
+		addr = ioremap_wc(offset, size);
+
+	return addr;
+}
+EXPORT_SYMBOL(memremap);
+
+void memunmap(void *addr)
+{
+	if (is_vmalloc_addr(addr))
+		iounmap((void __iomem *) addr);
+}
+EXPORT_SYMBOL(memunmap);
+
+static void devm_memremap_release(struct device *dev, void *res)
+{
+	memunmap(*(void **)res);
+}
+
+static int devm_memremap_match(struct device *dev, void *res, void *match_data)
+{
+	return *(void **)res == match_data;
+}
+
+void *devm_memremap(struct device *dev, resource_size_t offset,
+		size_t size, unsigned long flags)
+{
+	void **ptr, *addr;
+
+	ptr = devres_alloc_node(devm_memremap_release, sizeof(*ptr), GFP_KERNEL,
+			dev_to_node(dev));
+	if (!ptr)
+		return ERR_PTR(-ENOMEM);
+
+	addr = memremap(offset, size, flags);
+	if (addr) {
+		*ptr = addr;
+		devres_add(dev, ptr);
+	} else {
+		devres_free(ptr);
+		return ERR_PTR(-ENXIO);
+	}
+
+	return addr;
+}
+EXPORT_SYMBOL(devm_memremap);
+
+void devm_memunmap(struct device *dev, void *addr)
+{
+	WARN_ON(devres_release(dev, devm_memremap_release,
+				devm_memremap_match, addr));
+}
+EXPORT_SYMBOL(devm_memunmap);
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 895e6b76b25e..37a9604133f6 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -1,15 +1,5 @@
-/*
- * Copyright(c) 2015 Intel Corporation. All rights reserved.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of version 2 of the GNU General Public License as
- * published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License for more details.
- */
+/* SPDX-License-Identifier: GPL-2.0 */
+/* Copyright(c) 2015 Intel Corporation. All rights reserved. */
 #include <linux/radix-tree.h>
 #include <linux/device.h>
 #include <linux/types.h>
@@ -20,169 +10,6 @@
 #include <linux/swap.h>
 #include <linux/swapops.h>
 
-#ifndef ioremap_cache
-/* temporary while we convert existing ioremap_cache users to memremap */
-__weak void __iomem *ioremap_cache(resource_size_t offset, unsigned long size)
-{
-	return ioremap(offset, size);
-}
-#endif
-
-#ifndef arch_memremap_wb
-static void *arch_memremap_wb(resource_size_t offset, unsigned long size)
-{
-	return (__force void *)ioremap_cache(offset, size);
-}
-#endif
-
-#ifndef arch_memremap_can_ram_remap
-static bool arch_memremap_can_ram_remap(resource_size_t offset, size_t size,
-					unsigned long flags)
-{
-	return true;
-}
-#endif
-
-static void *try_ram_remap(resource_size_t offset, size_t size,
-			   unsigned long flags)
-{
-	unsigned long pfn = PHYS_PFN(offset);
-
-	/* In the simple case just return the existing linear address */
-	if (pfn_valid(pfn) && !PageHighMem(pfn_to_page(pfn)) &&
-	    arch_memremap_can_ram_remap(offset, size, flags))
-		return __va(offset);
-
-	return NULL; /* fallback to arch_memremap_wb */
-}
-
-/**
- * memremap() - remap an iomem_resource as cacheable memory
- * @offset: iomem resource start address
- * @size: size of remap
- * @flags: any of MEMREMAP_WB, MEMREMAP_WT, MEMREMAP_WC,
- *		  MEMREMAP_ENC, MEMREMAP_DEC
- *
- * memremap() is "ioremap" for cases where it is known that the resource
- * being mapped does not have i/o side effects and the __iomem
- * annotation is not applicable. In the case of multiple flags, the different
- * mapping types will be attempted in the order listed below until one of
- * them succeeds.
- *
- * MEMREMAP_WB - matches the default mapping for System RAM on
- * the architecture.  This is usually a read-allocate write-back cache.
- * Morever, if MEMREMAP_WB is specified and the requested remap region is RAM
- * memremap() will bypass establishing a new mapping and instead return
- * a pointer into the direct map.
- *
- * MEMREMAP_WT - establish a mapping whereby writes either bypass the
- * cache or are written through to memory and never exist in a
- * cache-dirty state with respect to program visibility.  Attempts to
- * map System RAM with this mapping type will fail.
- *
- * MEMREMAP_WC - establish a writecombine mapping, whereby writes may
- * be coalesced together (e.g. in the CPU's write buffers), but is otherwise
- * uncached. Attempts to map System RAM with this mapping type will fail.
- */
-void *memremap(resource_size_t offset, size_t size, unsigned long flags)
-{
-	int is_ram = region_intersects(offset, size,
-				       IORESOURCE_SYSTEM_RAM, IORES_DESC_NONE);
-	void *addr = NULL;
-
-	if (!flags)
-		return NULL;
-
-	if (is_ram == REGION_MIXED) {
-		WARN_ONCE(1, "memremap attempted on mixed range %pa size: %#lx\n",
-				&offset, (unsigned long) size);
-		return NULL;
-	}
-
-	/* Try all mapping types requested until one returns non-NULL */
-	if (flags & MEMREMAP_WB) {
-		/*
-		 * MEMREMAP_WB is special in that it can be satisifed
-		 * from the direct map.  Some archs depend on the
-		 * capability of memremap() to autodetect cases where
-		 * the requested range is potentially in System RAM.
-		 */
-		if (is_ram == REGION_INTERSECTS)
-			addr = try_ram_remap(offset, size, flags);
-		if (!addr)
-			addr = arch_memremap_wb(offset, size);
-	}
-
-	/*
-	 * If we don't have a mapping yet and other request flags are
-	 * present then we will be attempting to establish a new virtual
-	 * address mapping.  Enforce that this mapping is not aliasing
-	 * System RAM.
-	 */
-	if (!addr && is_ram == REGION_INTERSECTS && flags != MEMREMAP_WB) {
-		WARN_ONCE(1, "memremap attempted on ram %pa size: %#lx\n",
-				&offset, (unsigned long) size);
-		return NULL;
-	}
-
-	if (!addr && (flags & MEMREMAP_WT))
-		addr = ioremap_wt(offset, size);
-
-	if (!addr && (flags & MEMREMAP_WC))
-		addr = ioremap_wc(offset, size);
-
-	return addr;
-}
-EXPORT_SYMBOL(memremap);
-
-void memunmap(void *addr)
-{
-	if (is_vmalloc_addr(addr))
-		iounmap((void __iomem *) addr);
-}
-EXPORT_SYMBOL(memunmap);
-
-static void devm_memremap_release(struct device *dev, void *res)
-{
-	memunmap(*(void **)res);
-}
-
-static int devm_memremap_match(struct device *dev, void *res, void *match_data)
-{
-	return *(void **)res == match_data;
-}
-
-void *devm_memremap(struct device *dev, resource_size_t offset,
-		size_t size, unsigned long flags)
-{
-	void **ptr, *addr;
-
-	ptr = devres_alloc_node(devm_memremap_release, sizeof(*ptr), GFP_KERNEL,
-			dev_to_node(dev));
-	if (!ptr)
-		return ERR_PTR(-ENOMEM);
-
-	addr = memremap(offset, size, flags);
-	if (addr) {
-		*ptr = addr;
-		devres_add(dev, ptr);
-	} else {
-		devres_free(ptr);
-		return ERR_PTR(-ENXIO);
-	}
-
-	return addr;
-}
-EXPORT_SYMBOL(devm_memremap);
-
-void devm_memunmap(struct device *dev, void *addr)
-{
-	WARN_ON(devres_release(dev, devm_memremap_release,
-				devm_memremap_match, addr));
-}
-EXPORT_SYMBOL(devm_memunmap);
-
-#ifdef CONFIG_ZONE_DEVICE
 static DEFINE_MUTEX(pgmap_lock);
 static RADIX_TREE(pgmap_radix, GFP_KERNEL);
 #define SECTION_MASK ~((1UL << PA_SECTION_SHIFT) - 1)
@@ -473,7 +300,6 @@ struct dev_pagemap *get_dev_pagemap(unsigned long pfn,
 
 	return pgmap;
 }
-#endif /* CONFIG_ZONE_DEVICE */
 
 #if IS_ENABLED(CONFIG_DEVICE_PRIVATE) ||  IS_ENABLED(CONFIG_DEVICE_PUBLIC)
 void put_zone_device_private_or_public_page(struct page *page)
