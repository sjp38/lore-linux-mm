From: Borislav Petkov <bp@alien8.de>
Subject: [PATCH 12/17] memremap: Change region_intersects() to take @flags and @desc
Date: Tue, 26 Jan 2016 21:57:28 +0100
Message-ID: <1453841853-11383-13-git-send-email-bp@alien8.de>
References: <1453841853-11383-1-git-send-email-bp@alien8.de>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <1453841853-11383-1-git-send-email-bp@alien8.de>
Sender: linux-arch-owner@vger.kernel.org
To: Ingo Molnar <mingo@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Dan Williams <dan.j.williams@intel.com>, Jakub Sitnicki <jsitnicki@gmail.com>, Jan Kara <jack@suse.cz>, Jiang Liu <jiang.liu@linux.intel.com>, Kees Cook <keescook@chromium.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, linux-arch@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Tejun Heo <tj@kernel.org>, Vlastimil Babka <vbabka@suse.cz>
List-Id: linux-mm.kvack.org

From: Toshi Kani <toshi.kani@hpe.com>

Change region_intersects() to identify a target with @flags and @desc,
instead of @name with strcmp().

Change the callers of region_intersects(), memremap() and
devm_memremap(), to set IORESOURCE_SYSTEM_RAM in @flags and
IORES_DESC_NONE in @desc when searching System RAM.

Also, export region_intersects() so that the ACPI EINJ error injection
driver can call this function in a later patch.

Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Jakub Sitnicki <jsitnicki@gmail.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Jiang Liu <jiang.liu@linux.intel.com>
Cc: Kees Cook <keescook@chromium.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: linux-arch@vger.kernel.org
Cc: linux-mm <linux-mm@kvack.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Tejun Heo <tj@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>
Link: http://lkml.kernel.org/r/1452020081-26534-12-git-send-email-toshi.kani@hpe.com
Signed-off-by: Borislav Petkov <bp@suse.de>
---
 include/linux/mm.h |  3 ++-
 kernel/memremap.c  | 13 +++++++------
 kernel/resource.c  | 26 +++++++++++++++-----------
 3 files changed, 24 insertions(+), 18 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index f1cd22f2df1a..cd5a300d3397 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -385,7 +385,8 @@ enum {
 	REGION_MIXED,
 };
 
-int region_intersects(resource_size_t offset, size_t size, const char *type);
+int region_intersects(resource_size_t offset, size_t size, unsigned long flags,
+		      unsigned long desc);
 
 /* Support for virtually mapped pages */
 struct page *vmalloc_to_page(const void *addr);
diff --git a/kernel/memremap.c b/kernel/memremap.c
index e517a16cb426..293309cac061 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -47,7 +47,7 @@ static void *try_ram_remap(resource_size_t offset, size_t size)
  * being mapped does not have i/o side effects and the __iomem
  * annotation is not applicable.
  *
- * MEMREMAP_WB - matches the default mapping for "System RAM" on
+ * MEMREMAP_WB - matches the default mapping for System RAM on
  * the architecture.  This is usually a read-allocate write-back cache.
  * Morever, if MEMREMAP_WB is specified and the requested remap region is RAM
  * memremap() will bypass establishing a new mapping and instead return
@@ -56,11 +56,12 @@ static void *try_ram_remap(resource_size_t offset, size_t size)
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
+				       IORESOURCE_SYSTEM_RAM, IORES_DESC_NONE);
 	void *addr = NULL;
 
 	if (is_ram == REGION_MIXED) {
@@ -76,7 +77,7 @@ void *memremap(resource_size_t offset, size_t size, unsigned long flags)
 		 * MEMREMAP_WB is special in that it can be satisifed
 		 * from the direct map.  Some archs depend on the
 		 * capability of memremap() to autodetect cases where
-		 * the requested range is potentially in "System RAM"
+		 * the requested range is potentially in System RAM.
 		 */
 		if (is_ram == REGION_INTERSECTS)
 			addr = try_ram_remap(offset, size);
@@ -88,7 +89,7 @@ void *memremap(resource_size_t offset, size_t size, unsigned long flags)
 	 * If we don't have a mapping yet and more request flags are
 	 * pending then we will be attempting to establish a new virtual
 	 * address mapping.  Enforce that this mapping is not aliasing
-	 * "System RAM"
+	 * System RAM.
 	 */
 	if (!addr && is_ram == REGION_INTERSECTS && flags) {
 		WARN_ONCE(1, "memremap attempted on ram %pa size: %#lx\n",
@@ -266,7 +267,7 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 		struct percpu_ref *ref, struct vmem_altmap *altmap)
 {
 	int is_ram = region_intersects(res->start, resource_size(res),
-			"System RAM");
+				       IORESOURCE_SYSTEM_RAM, IORES_DESC_NONE);
 	resource_size_t key, align_start, align_size;
 	struct dev_pagemap *pgmap;
 	struct page_map *page_map;
diff --git a/kernel/resource.c b/kernel/resource.c
index 994f1e41269b..0041cedc47d6 100644
--- a/kernel/resource.c
+++ b/kernel/resource.c
@@ -496,31 +496,34 @@ EXPORT_SYMBOL_GPL(page_is_ram);
  * region_intersects() - determine intersection of region with known resources
  * @start: region start address
  * @size: size of region
- * @name: name of resource (in iomem_resource)
+ * @flags: flags of resource (in iomem_resource)
+ * @desc: descriptor of resource (in iomem_resource) or IORES_DESC_NONE
  *
  * Check if the specified region partially overlaps or fully eclipses a
- * resource identified by @name.  Return REGION_DISJOINT if the region
- * does not overlap @name, return REGION_MIXED if the region overlaps
- * @type and another resource, and return REGION_INTERSECTS if the
- * region overlaps @type and no other defined resource. Note, that
- * REGION_INTERSECTS is also returned in the case when the specified
- * region overlaps RAM and undefined memory holes.
+ * resource identified by @flags and @desc (optional with IORES_DESC_NONE).
+ * Return REGION_DISJOINT if the region does not overlap @flags/@desc,
+ * return REGION_MIXED if the region overlaps @flags/@desc and another
+ * resource, and return REGION_INTERSECTS if the region overlaps @flags/@desc
+ * and no other defined resource. Note that REGION_INTERSECTS is also
+ * returned in the case when the specified region overlaps RAM and undefined
+ * memory holes.
  *
  * region_intersect() is used by memory remapping functions to ensure
  * the user is not remapping RAM and is a vast speed up over walking
  * through the resource table page by page.
  */
-int region_intersects(resource_size_t start, size_t size, const char *name)
+int region_intersects(resource_size_t start, size_t size, unsigned long flags,
+		      unsigned long desc)
 {
-	unsigned long flags = IORESOURCE_MEM | IORESOURCE_BUSY;
 	resource_size_t end = start + size - 1;
 	int type = 0; int other = 0;
 	struct resource *p;
 
 	read_lock(&resource_lock);
 	for (p = iomem_resource.child; p ; p = p->sibling) {
-		bool is_type = strcmp(p->name, name) == 0 &&
-				((p->flags & flags) == flags);
+		bool is_type = (((p->flags & flags) == flags) &&
+				((desc == IORES_DESC_NONE) ||
+				 (desc == p->desc)));
 
 		if (start >= p->start && start <= p->end)
 			is_type ? type++ : other++;
@@ -539,6 +542,7 @@ int region_intersects(resource_size_t start, size_t size, const char *name)
 
 	return REGION_DISJOINT;
 }
+EXPORT_SYMBOL_GPL(region_intersects);
 
 void __weak arch_remove_reservations(struct resource *avail)
 {
-- 
2.3.5
