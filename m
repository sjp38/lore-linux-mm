Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com [209.85.214.174])
	by kanga.kvack.org (Postfix) with ESMTP id 7F8DC6B025C
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 18:38:08 -0500 (EST)
Received: by obcno2 with SMTP id no2so25859597obc.3
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 15:38:08 -0800 (PST)
Received: from g9t5009.houston.hp.com (g9t5009.houston.hp.com. [15.240.92.67])
        by mx.google.com with ESMTPS id ea8si1632593obb.107.2015.12.14.15.38.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Dec 2015 15:38:07 -0800 (PST)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH 08/11] memremap: Change region_intersects() to use System RAM type
Date: Mon, 14 Dec 2015 16:37:23 -0700
Message-Id: <1450136246-17053-8-git-send-email-toshi.kani@hpe.com>
In-Reply-To: <1450136246-17053-1-git-send-email-toshi.kani@hpe.com>
References: <1450136246-17053-1-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, bp@alien8.de
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dan Williams <dan.j.williams@intel.com>, Toshi Kani <toshi.kani@hpe.com>

Change region_intersects() to add @flags, and make @name optinal
with NULL.  When NULL is set to @name, it skips strcmp().

Change the callers of region_intersects(), memremap() and
devm_memremap(), to set IORESOURCE_SYSTEM_RAM to @flags for
searching System RAM.

Also, export region_intersects() so that the EINJ driver can
call this function in a later patch.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Dan Williams <dan.j.williams@intel.com>
Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
---
 include/linux/mm.h |    3 ++-
 kernel/memremap.c  |   13 +++++++------
 kernel/resource.c  |   25 ++++++++++++++-----------
 3 files changed, 23 insertions(+), 18 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 00bad77..d2ee94a 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -362,7 +362,8 @@ enum {
 	REGION_MIXED,
 };
 
-int region_intersects(resource_size_t offset, size_t size, const char *type);
+int region_intersects(resource_size_t offset, size_t size, unsigned long flags,
+			const char *name);
 
 /* Support for virtually mapped pages */
 struct page *vmalloc_to_page(const void *addr);
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 7658d32..cefd382 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -44,7 +44,7 @@ static void *try_ram_remap(resource_size_t offset, size_t size)
  * being mapped does not have i/o side effects and the __iomem
  * annotation is not applicable.
  *
- * MEMREMAP_WB - matches the default mapping for "System RAM" on
+ * MEMREMAP_WB - matches the default mapping for System RAM on
  * the architecture.  This is usually a read-allocate write-back cache.
  * Morever, if MEMREMAP_WB is specified and the requested remap region is RAM
  * memremap() will bypass establishing a new mapping and instead return
@@ -53,11 +53,12 @@ static void *try_ram_remap(resource_size_t offset, size_t size)
  * MEMREMAP_WT - establish a mapping whereby writes either bypass the
  * cache or are written through to memory and never exist in a
  * cache-dirty state with respect to program visibility.  Attempts to
- * map "System RAM" with this mapping type will fail.
+ * map System RAM with this mapping type will fail.
  */
 void *memremap(resource_size_t offset, size_t size, unsigned long flags)
 {
-	int is_ram = region_intersects(offset, size, "System RAM");
+	int is_ram = region_intersects(offset, size,
+					IORESOURCE_SYSTEM_RAM, NULL);
 	void *addr = NULL;
 
 	if (is_ram == REGION_MIXED) {
@@ -73,7 +74,7 @@ void *memremap(resource_size_t offset, size_t size, unsigned long flags)
 		 * MEMREMAP_WB is special in that it can be satisifed
 		 * from the direct map.  Some archs depend on the
 		 * capability of memremap() to autodetect cases where
-		 * the requested range is potentially in "System RAM"
+		 * the requested range is potentially in System RAM.
 		 */
 		if (is_ram == REGION_INTERSECTS)
 			addr = try_ram_remap(offset, size);
@@ -85,7 +86,7 @@ void *memremap(resource_size_t offset, size_t size, unsigned long flags)
 	 * If we don't have a mapping yet and more request flags are
 	 * pending then we will be attempting to establish a new virtual
 	 * address mapping.  Enforce that this mapping is not aliasing
-	 * "System RAM"
+	 * System RAM.
 	 */
 	if (!addr && is_ram == REGION_INTERSECTS && flags) {
 		WARN_ONCE(1, "memremap attempted on ram %pa size: %#lx\n",
@@ -163,7 +164,7 @@ static void devm_memremap_pages_release(struct device *dev, void *res)
 void *devm_memremap_pages(struct device *dev, struct resource *res)
 {
 	int is_ram = region_intersects(res->start, resource_size(res),
-			"System RAM");
+					IORESOURCE_SYSTEM_RAM, NULL);
 	struct page_map *page_map;
 	int error, nid;
 
diff --git a/kernel/resource.c b/kernel/resource.c
index d30a175..56bed6d 100644
--- a/kernel/resource.c
+++ b/kernel/resource.c
@@ -496,31 +496,33 @@ EXPORT_SYMBOL_GPL(page_is_ram);
  * region_intersects() - determine intersection of region with known resources
  * @start: region start address
  * @size: size of region
- * @name: name of resource (in iomem_resource)
+ * @flags: flags of resource (in iomem_resource)
+ * @name: name of resource (in iomem_resource) or NULL
  *
  * Check if the specified region partially overlaps or fully eclipses a
- * resource identified by @name.  Return REGION_DISJOINT if the region
- * does not overlap @name, return REGION_MIXED if the region overlaps
- * @type and another resource, and return REGION_INTERSECTS if the
- * region overlaps @type and no other defined resource. Note, that
- * REGION_INTERSECTS is also returned in the case when the specified
- * region overlaps RAM and undefined memory holes.
+ * resource identified by @flags and @name (optinal with NULL).  Return
+ * REGION_DISJOINT if the region does not overlap @flags/@name, return
+ * REGION_MIXED if the region overlaps @flags/@name and another resource,
+ * and return REGION_INTERSECTS if the region overlaps @flags/@name and
+ * no other defined resource. Note, that REGION_INTERSECTS is also returned
+ * in the case when the specified region overlaps RAM and undefined memory
+ * holes.
  *
  * region_intersect() is used by memory remapping functions to ensure
  * the user is not remapping RAM and is a vast speed up over walking
  * through the resource table page by page.
  */
-int region_intersects(resource_size_t start, size_t size, const char *name)
+int region_intersects(resource_size_t start, size_t size, unsigned long flags,
+			const char *name)
 {
-	unsigned long flags = IORESOURCE_MEM | IORESOURCE_BUSY;
 	resource_size_t end = start + size - 1;
 	int type = 0; int other = 0;
 	struct resource *p;
 
 	read_lock(&resource_lock);
 	for (p = iomem_resource.child; p ; p = p->sibling) {
-		bool is_type = strcmp(p->name, name) == 0 &&
-				((p->flags & flags) == flags);
+		bool is_type = ((p->flags & flags) == flags) &&
+				(!name || strcmp(p->name, name) == 0);
 
 		if (start >= p->start && start <= p->end)
 			is_type ? type++ : other++;
@@ -539,6 +541,7 @@ int region_intersects(resource_size_t start, size_t size, const char *name)
 
 	return REGION_DISJOINT;
 }
+EXPORT_SYMBOL_GPL(region_intersects);
 
 void __weak arch_remove_reservations(struct resource *avail)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
