Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f179.google.com (mail-ob0-f179.google.com [209.85.214.179])
	by kanga.kvack.org (Postfix) with ESMTP id 95CEB6B0254
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 16:38:32 -0500 (EST)
Received: by obdgf3 with SMTP id gf3so24498038obd.3
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 13:38:32 -0800 (PST)
Received: from g4t3428.houston.hp.com (g4t3428.houston.hp.com. [15.201.208.56])
        by mx.google.com with ESMTPS id oh10si13355650obb.52.2015.11.24.13.38.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Nov 2015 13:38:31 -0800 (PST)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH v3 1/3] resource: Add @flags to region_intersects()
Date: Tue, 24 Nov 2015 15:33:36 -0700
Message-Id: <1448404418-28800-2-git-send-email-toshi.kani@hpe.com>
In-Reply-To: <1448404418-28800-1-git-send-email-toshi.kani@hpe.com>
References: <1448404418-28800-1-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, rjw@rjwysocki.net, dan.j.williams@intel.com
Cc: tony.luck@intel.com, bp@alien8.de, vishal.l.verma@intel.com, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, Toshi Kani <toshi.kani@hpe.com>

region_intersects() checks if a specified region partially overlaps
or fully eclipses a resource identified by @name.  It currently sets
resource flags statically, which prevents the caller from specifying
a non-RAM region, such as persistent memory.  Add @flags so that
any region can be specified to the function.

A helper function, region_intersects_ram(), is added so that the
callers that check a RAM region do not have to specify its iomem
resource name and flags.  This interface is exported for modules,
such as the EINJ driver.

Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
Reviewed-by: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Vishal Verma <vishal.l.verma@intel.com>
---
 include/linux/mm.h |    4 +++-
 kernel/memremap.c  |    5 ++---
 kernel/resource.c  |   23 ++++++++++++++++-------
 3 files changed, 21 insertions(+), 11 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 00bad77..c776af3 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -362,7 +362,9 @@ enum {
 	REGION_MIXED,
 };
 
-int region_intersects(resource_size_t offset, size_t size, const char *type);
+int region_intersects(resource_size_t offset, size_t size, const char *type,
+			unsigned long flags);
+int region_intersects_ram(resource_size_t offset, size_t size);
 
 /* Support for virtually mapped pages */
 struct page *vmalloc_to_page(const void *addr);
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 7658d32..98f52f1 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -57,7 +57,7 @@ static void *try_ram_remap(resource_size_t offset, size_t size)
  */
 void *memremap(resource_size_t offset, size_t size, unsigned long flags)
 {
-	int is_ram = region_intersects(offset, size, "System RAM");
+	int is_ram = region_intersects_ram(offset, size);
 	void *addr = NULL;
 
 	if (is_ram == REGION_MIXED) {
@@ -162,8 +162,7 @@ static void devm_memremap_pages_release(struct device *dev, void *res)
 
 void *devm_memremap_pages(struct device *dev, struct resource *res)
 {
-	int is_ram = region_intersects(res->start, resource_size(res),
-			"System RAM");
+	int is_ram = region_intersects_ram(res->start, resource_size(res));
 	struct page_map *page_map;
 	int error, nid;
 
diff --git a/kernel/resource.c b/kernel/resource.c
index f150dbb..15c133e 100644
--- a/kernel/resource.c
+++ b/kernel/resource.c
@@ -497,6 +497,7 @@ EXPORT_SYMBOL_GPL(page_is_ram);
  * @start: region start address
  * @size: size of region
  * @name: name of resource (in iomem_resource)
+ * @flags: flags of resource (in iomem_resource)
  *
  * Check if the specified region partially overlaps or fully eclipses a
  * resource identified by @name.  Return REGION_DISJOINT if the region
@@ -504,15 +505,11 @@ EXPORT_SYMBOL_GPL(page_is_ram);
  * @type and another resource, and return REGION_INTERSECTS if the
  * region overlaps @type and no other defined resource. Note, that
  * REGION_INTERSECTS is also returned in the case when the specified
- * region overlaps RAM and undefined memory holes.
- *
- * region_intersect() is used by memory remapping functions to ensure
- * the user is not remapping RAM and is a vast speed up over walking
- * through the resource table page by page.
+ * region overlaps with undefined memory holes.
  */
-int region_intersects(resource_size_t start, size_t size, const char *name)
+int region_intersects(resource_size_t start, size_t size, const char *name,
+			unsigned long flags)
 {
-	unsigned long flags = IORESOURCE_MEM | IORESOURCE_BUSY;
 	resource_size_t end = start + size - 1;
 	int type = 0; int other = 0;
 	struct resource *p;
@@ -539,6 +536,18 @@ int region_intersects(resource_size_t start, size_t size, const char *name)
 	return REGION_DISJOINT;
 }
 
+/*
+ * region_intersect_ram() is used by memory remapping functions to ensure
+ * the user is not remapping RAM and is a vast speed up over walking
+ * through the resource table page by page.
+ */
+int region_intersects_ram(resource_size_t start, size_t size)
+{
+	return region_intersects(start, size, "System RAM",
+				 IORESOURCE_MEM | IORESOURCE_BUSY);
+}
+EXPORT_SYMBOL_GPL(region_intersects_ram);
+
 void __weak arch_remove_reservations(struct resource *avail)
 {
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
