Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 960289003C7
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 21:33:29 -0400 (EDT)
Received: by pacdd16 with SMTP id dd16so142016797pac.2
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 18:33:29 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id yi1si3231852pab.68.2015.08.25.18.33.28
        for <linux-mm@kvack.org>;
        Tue, 25 Aug 2015 18:33:28 -0700 (PDT)
Subject: [PATCH v2 4/9] add devm_memremap_pages
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 25 Aug 2015 21:27:46 -0400
Message-ID: <20150826012746.8851.7835.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <20150826010220.8851.18077.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <20150826010220.8851.18077.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: boaz@plexistor.com, david@fromorbit.com, linux-kernel@vger.kernel.org, hch@lst.de, linux-mm@kvack.org, hpa@zytor.com, ross.zwisler@linux.intel.com, mingo@kernel.org

From: Christoph Hellwig <hch@lst.de>

This behaves like devm_memremap except that it ensures we have page
structures available that can back the region.

Signed-off-by: Christoph Hellwig <hch@lst.de>
[djbw: catch attempts to remap RAM, drop flags]
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/io.h |   20 ++++++++++++++++++++
 kernel/memremap.c  |   53 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 73 insertions(+)

diff --git a/include/linux/io.h b/include/linux/io.h
index d8d749abd665..de64c1e53612 100644
--- a/include/linux/io.h
+++ b/include/linux/io.h
@@ -20,10 +20,13 @@
 
 #include <linux/types.h>
 #include <linux/init.h>
+#include <linux/bug.h>
+#include <linux/err.h>
 #include <asm/io.h>
 #include <asm/page.h>
 
 struct device;
+struct resource;
 
 __visible void __iowrite32_copy(void __iomem *to, const void *from, size_t count);
 void __iowrite64_copy(void __iomem *to, const void *from, size_t count);
@@ -84,6 +87,23 @@ void *devm_memremap(struct device *dev, resource_size_t offset,
 		size_t size, unsigned long flags);
 void devm_memunmap(struct device *dev, void *addr);
 
+void *__devm_memremap_pages(struct device *dev, struct resource *res);
+
+#ifdef CONFIG_ZONE_DEVICE
+void *devm_memremap_pages(struct device *dev, struct resource *res);
+#else
+static inline void *devm_memremap_pages(struct device *dev, struct resource *res)
+{
+	/*
+	 * Fail attempts to call devm_memremap_pages() without
+	 * ZONE_DEVICE support enabled, this requires callers to fall
+	 * back to plain devm_memremap() based on config
+	 */
+	WARN_ON_ONCE(1);
+	return ERR_PTR(-ENXIO);
+}
+#endif
+
 /*
  * Some systems do not have legacy ISA devices.
  * /dev/port is not a valid interface on these systems.
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 5c9b55eaf121..72b0c66628b6 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -14,6 +14,7 @@
 #include <linux/types.h>
 #include <linux/io.h>
 #include <linux/mm.h>
+#include <linux/memory_hotplug.h>
 
 #ifndef ioremap_cache
 /* temporary while we convert existing ioremap_cache users to memremap */
@@ -135,3 +136,55 @@ void devm_memunmap(struct device *dev, void *addr)
 	memunmap(addr);
 }
 EXPORT_SYMBOL(devm_memunmap);
+
+#ifdef CONFIG_ZONE_DEVICE
+struct page_map {
+	struct resource res;
+};
+
+static void devm_memremap_pages_release(struct device *dev, void *res)
+{
+	struct page_map *page_map = res;
+
+	/* pages are dead and unused, undo the arch mapping */
+	arch_remove_memory(page_map->res.start, resource_size(&page_map->res));
+}
+
+void *devm_memremap_pages(struct device *dev, struct resource *res)
+{
+	int is_ram = region_intersects(res->start, resource_size(res),
+			"System RAM");
+	struct page_map *page_map;
+	int error, nid;
+
+	if (is_ram == REGION_MIXED) {
+		WARN_ONCE(1, "%s attempted on mixed region %pr\n",
+				__func__, res);
+		return ERR_PTR(-ENXIO);
+	}
+
+	if (is_ram == REGION_INTERSECTS)
+		return __va(res->start);
+
+	page_map = devres_alloc(devm_memremap_pages_release,
+			sizeof(*page_map), GFP_KERNEL);
+	if (!page_map)
+		return ERR_PTR(-ENOMEM);
+
+	memcpy(&page_map->res, res, sizeof(*res));
+
+	nid = dev_to_node(dev);
+	if (nid < 0)
+		nid = 0;
+
+	error = arch_add_memory(nid, res->start, resource_size(res), true);
+	if (error) {
+		devres_free(page_map);
+		return ERR_PTR(error);
+	}
+
+	devres_add(dev, page_map);
+	return __va(res->start);
+}
+EXPORT_SYMBOL(devm_memremap_pages);
+#endif /* CONFIG_ZONE_DEVICE */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
