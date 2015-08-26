Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id A36AB9003C7
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 21:33:25 -0400 (EDT)
Received: by pacgr6 with SMTP id gr6so8841718pac.3
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 18:33:25 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id yi1si3231852pab.68.2015.08.25.18.33.23
        for <linux-mm@kvack.org>;
        Tue, 25 Aug 2015 18:33:23 -0700 (PDT)
Subject: [PATCH v2 3/9] mm: ZONE_DEVICE for "device memory"
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 25 Aug 2015 21:27:41 -0400
Message-ID: <20150826012740.8851.52436.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <20150826010220.8851.18077.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <20150826010220.8851.18077.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: boaz@plexistor.com, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, david@fromorbit.com, linux-kernel@vger.kernel.org, mingo@kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Mel Gorman <mgorman@suse.de>, hpa@zytor.com, Jerome Glisse <j.glisse@gmail.com>, ross.zwisler@linux.intel.com, hch@lst.de

While pmem is usable as a block device or via DAX mappings to userspace
there are several usage scenarios that can not target pmem due to its
lack of struct page coverage. In preparation for "hot plugging" pmem
into the vmemmap add ZONE_DEVICE as a new zone to tag these pages
separately from the ones that are subject to standard page allocations.
Importantly "device memory" can be removed at will by userspace
unbinding the driver of the device.

Having a separate zone prevents allocation and otherwise marks these
pages that are distinct from typical uniform memory.  Device memory has
different lifetime and performance characteristics than RAM.  However,
since we have run out of ZONES_SHIFT bits this functionality currently
depends on sacrificing ZONE_DMA.

Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Jerome Glisse <j.glisse@gmail.com>
[hch: various simplifications in the arch interface]
Signed-off-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/ia64/mm/init.c            |    4 ++--
 arch/powerpc/mm/mem.c          |    4 ++--
 arch/s390/mm/init.c            |    2 +-
 arch/sh/mm/init.c              |    5 +++--
 arch/tile/mm/init.c            |    2 +-
 arch/x86/mm/init_32.c          |    4 ++--
 arch/x86/mm/init_64.c          |    4 ++--
 include/linux/memory_hotplug.h |    5 +++--
 include/linux/mmzone.h         |   23 +++++++++++++++++++++++
 mm/Kconfig                     |   17 +++++++++++++++++
 mm/memory_hotplug.c            |   14 +++++++++++---
 mm/page_alloc.c                |    3 +++
 12 files changed, 70 insertions(+), 17 deletions(-)

diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index 97e48b0eefc7..1841ef69183d 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -645,7 +645,7 @@ mem_init (void)
 }
 
 #ifdef CONFIG_MEMORY_HOTPLUG
-int arch_add_memory(int nid, u64 start, u64 size)
+int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
 {
 	pg_data_t *pgdat;
 	struct zone *zone;
@@ -656,7 +656,7 @@ int arch_add_memory(int nid, u64 start, u64 size)
 	pgdat = NODE_DATA(nid);
 
 	zone = pgdat->node_zones +
-		zone_for_memory(nid, start, size, ZONE_NORMAL);
+		zone_for_memory(nid, start, size, ZONE_NORMAL, for_device);
 	ret = __add_pages(nid, zone, start_pfn, nr_pages);
 
 	if (ret)
diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
index 0f11819d8f1d..6571cfb05668 100644
--- a/arch/powerpc/mm/mem.c
+++ b/arch/powerpc/mm/mem.c
@@ -113,7 +113,7 @@ int memory_add_physaddr_to_nid(u64 start)
 }
 #endif
 
-int arch_add_memory(int nid, u64 start, u64 size)
+int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
 {
 	struct pglist_data *pgdata;
 	struct zone *zone;
@@ -128,7 +128,7 @@ int arch_add_memory(int nid, u64 start, u64 size)
 
 	/* this should work for most non-highmem platforms */
 	zone = pgdata->node_zones +
-		zone_for_memory(nid, start, size, 0);
+		zone_for_memory(nid, start, size, 0, for_device);
 
 	return __add_pages(nid, zone, start_pfn, nr_pages);
 }
diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
index 76e873748b56..48ee78be88ba 100644
--- a/arch/s390/mm/init.c
+++ b/arch/s390/mm/init.c
@@ -168,7 +168,7 @@ void __init free_initrd_mem(unsigned long start, unsigned long end)
 #endif
 
 #ifdef CONFIG_MEMORY_HOTPLUG
-int arch_add_memory(int nid, u64 start, u64 size)
+int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
 {
 	unsigned long zone_start_pfn, zone_end_pfn, nr_pages;
 	unsigned long start_pfn = PFN_DOWN(start);
diff --git a/arch/sh/mm/init.c b/arch/sh/mm/init.c
index 2790b6a64157..c1490096b863 100644
--- a/arch/sh/mm/init.c
+++ b/arch/sh/mm/init.c
@@ -485,7 +485,7 @@ void free_initrd_mem(unsigned long start, unsigned long end)
 #endif
 
 #ifdef CONFIG_MEMORY_HOTPLUG
-int arch_add_memory(int nid, u64 start, u64 size)
+int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
 {
 	pg_data_t *pgdat;
 	unsigned long start_pfn = start >> PAGE_SHIFT;
@@ -496,7 +496,8 @@ int arch_add_memory(int nid, u64 start, u64 size)
 
 	/* We only have ZONE_NORMAL, so this is easy.. */
 	ret = __add_pages(nid, pgdat->node_zones +
-			zone_for_memory(nid, start, size, ZONE_NORMAL),
+			zone_for_memory(nid, start, size, ZONE_NORMAL,
+			for_device),
 			start_pfn, nr_pages);
 	if (unlikely(ret))
 		printk("%s: Failed, __add_pages() == %d\n", __func__, ret);
diff --git a/arch/tile/mm/init.c b/arch/tile/mm/init.c
index 5bd252e3fdc5..d4e1fc41d06d 100644
--- a/arch/tile/mm/init.c
+++ b/arch/tile/mm/init.c
@@ -863,7 +863,7 @@ void __init mem_init(void)
  * memory to the highmem for now.
  */
 #ifndef CONFIG_NEED_MULTIPLE_NODES
-int arch_add_memory(u64 start, u64 size)
+int arch_add_memory(u64 start, u64 size, bool for_device)
 {
 	struct pglist_data *pgdata = &contig_page_data;
 	struct zone *zone = pgdata->node_zones + MAX_NR_ZONES-1;
diff --git a/arch/x86/mm/init_32.c b/arch/x86/mm/init_32.c
index 8340e45c891a..2a9237d20a70 100644
--- a/arch/x86/mm/init_32.c
+++ b/arch/x86/mm/init_32.c
@@ -822,11 +822,11 @@ void __init mem_init(void)
 }
 
 #ifdef CONFIG_MEMORY_HOTPLUG
-int arch_add_memory(int nid, u64 start, u64 size)
+int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
 {
 	struct pglist_data *pgdata = NODE_DATA(nid);
 	struct zone *zone = pgdata->node_zones +
-		zone_for_memory(nid, start, size, ZONE_HIGHMEM);
+		zone_for_memory(nid, start, size, ZONE_HIGHMEM, for_device);
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 3fba623e3ba5..30564e2752d3 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -687,11 +687,11 @@ static void  update_end_of_memory_vars(u64 start, u64 size)
  * Memory is added always to NORMAL zone. This means you will never get
  * additional DMA/DMA32 memory.
  */
-int arch_add_memory(int nid, u64 start, u64 size)
+int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
 {
 	struct pglist_data *pgdat = NODE_DATA(nid);
 	struct zone *zone = pgdat->node_zones +
-		zone_for_memory(nid, start, size, ZONE_NORMAL);
+		zone_for_memory(nid, start, size, ZONE_NORMAL, for_device);
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 	int ret;
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 6ffa0ac7f7d6..8f60e899b33c 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -266,8 +266,9 @@ static inline void remove_memory(int nid, u64 start, u64 size) {}
 extern int walk_memory_range(unsigned long start_pfn, unsigned long end_pfn,
 		void *arg, int (*func)(struct memory_block *, void *));
 extern int add_memory(int nid, u64 start, u64 size);
-extern int zone_for_memory(int nid, u64 start, u64 size, int zone_default);
-extern int arch_add_memory(int nid, u64 start, u64 size);
+extern int zone_for_memory(int nid, u64 start, u64 size, int zone_default,
+		bool for_device);
+extern int arch_add_memory(int nid, u64 start, u64 size, bool for_device);
 extern int offline_pages(unsigned long start_pfn, unsigned long nr_pages);
 extern bool is_memblock_offlined(struct memory_block *mem);
 extern void remove_memory(int nid, u64 start, u64 size);
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 754c25966a0a..9217fd93c25b 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -319,7 +319,11 @@ enum zone_type {
 	ZONE_HIGHMEM,
 #endif
 	ZONE_MOVABLE,
+#ifdef CONFIG_ZONE_DEVICE
+	ZONE_DEVICE,
+#endif
 	__MAX_NR_ZONES
+
 };
 
 #ifndef __GENERATING_BOUNDS_H
@@ -794,6 +798,25 @@ static inline bool pgdat_is_empty(pg_data_t *pgdat)
 	return !pgdat->node_start_pfn && !pgdat->node_spanned_pages;
 }
 
+static inline int zone_id(const struct zone *zone)
+{
+	struct pglist_data *pgdat = zone->zone_pgdat;
+
+	return zone - pgdat->node_zones;
+}
+
+#ifdef CONFIG_ZONE_DEVICE
+static inline bool is_dev_zone(const struct zone *zone)
+{
+	return zone_id(zone) == ZONE_DEVICE;
+}
+#else
+static inline bool is_dev_zone(const struct zone *zone)
+{
+	return false;
+}
+#endif
+
 #include <linux/memory_hotplug.h>
 
 extern struct mutex zonelists_mutex;
diff --git a/mm/Kconfig b/mm/Kconfig
index e79de2bd12cd..a0cd086df16b 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -654,3 +654,20 @@ config DEFERRED_STRUCT_PAGE_INIT
 	  when kswapd starts. This has a potential performance impact on
 	  processes running early in the lifetime of the systemm until kswapd
 	  finishes the initialisation.
+
+config ZONE_DEVICE
+	bool "Device memory (pmem, etc...) hotplug support" if EXPERT
+	default !ZONE_DMA
+	depends on !ZONE_DMA
+	depends on MEMORY_HOTPLUG
+	depends on MEMORY_HOTREMOVE
+	depends on X86_64 #arch_add_memory() comprehends device memory
+
+	help
+	  Device memory hotplug support allows for establishing pmem,
+	  or other device driver discovered memory regions, in the
+	  memmap. This allows pfn_to_page() lookups of otherwise
+	  "device-physical" addresses which is needed for using a DAX
+	  mapping in an O_DIRECT operation, among other things.
+
+	  If FS_DAX is enabled, then say Y.
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 26fbba7d888f..24e4c76c951b 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -770,7 +770,10 @@ int __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
 
 	start = phys_start_pfn << PAGE_SHIFT;
 	size = nr_pages * PAGE_SIZE;
-	ret = release_mem_region_adjustable(&iomem_resource, start, size);
+
+	/* in the ZONE_DEVICE case device driver owns the memory region */
+	if (!is_dev_zone(zone))
+		ret = release_mem_region_adjustable(&iomem_resource, start, size);
 	if (ret) {
 		resource_size_t endres = start + size - 1;
 
@@ -1207,8 +1210,13 @@ static int should_add_memory_movable(int nid, u64 start, u64 size)
 	return 0;
 }
 
-int zone_for_memory(int nid, u64 start, u64 size, int zone_default)
+int zone_for_memory(int nid, u64 start, u64 size, int zone_default,
+		bool for_device)
 {
+#ifdef CONFIG_ZONE_DEVICE
+	if (for_device)
+		return ZONE_DEVICE;
+#endif
 	if (should_add_memory_movable(nid, start, size))
 		return ZONE_MOVABLE;
 
@@ -1249,7 +1257,7 @@ int __ref add_memory(int nid, u64 start, u64 size)
 	}
 
 	/* call arch's memory hotadd */
-	ret = arch_add_memory(nid, start, size);
+	ret = arch_add_memory(nid, start, size, false);
 
 	if (ret < 0)
 		goto error;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ef19f22b2b7d..0f19b4e18233 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -207,6 +207,9 @@ static char * const zone_names[MAX_NR_ZONES] = {
 	 "HighMem",
 #endif
 	 "Movable",
+#ifdef CONFIG_ZONE_DEVICE
+	 "Device",
+#endif
 };
 
 int min_free_kbytes = 1024;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
