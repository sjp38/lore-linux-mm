Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 6FE116B0253
	for <linux-mm@kvack.org>; Wed, 12 Aug 2015 23:55:51 -0400 (EDT)
Received: by pacrr5 with SMTP id rr5so28369924pac.3
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 20:55:51 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id fb1si1505743pbb.110.2015.08.12.20.55.50
        for <linux-mm@kvack.org>;
        Wed, 12 Aug 2015 20:55:50 -0700 (PDT)
Subject: [RFC PATCH 1/7] x86, mm: ZONE_DEVICE for "device memory"
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 12 Aug 2015 23:50:05 -0400
Message-ID: <20150813035005.36913.77364.stgit@otcpl-skl-sds-2.jf.intel.com>
In-Reply-To: <20150813031253.36913.29580.stgit@otcpl-skl-sds-2.jf.intel.com>
References: <20150813031253.36913.29580.stgit@otcpl-skl-sds-2.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: boaz@plexistor.com, riel@redhat.com, linux-nvdimm@lists.01.org, Dave Hansen <dave.hansen@linux.intel.com>, david@fromorbit.com, mingo@kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, mgorman@suse.de, "H. Peter Anvin" <hpa@zytor.com>, ross.zwisler@linux.intel.com, torvalds@linux-foundation.org, hch@lst.de

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

arch_add_memory() is reorganized a bit in preparation for a new
arch_add_dev_memory() api, for now there is no functional change to the
memory hotplug code.

Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/x86/Kconfig       |   13 +++++++++++++
 arch/x86/mm/init_64.c  |   32 +++++++++++++++++++++-----------
 include/linux/mmzone.h |   23 +++++++++++++++++++++++
 mm/memory_hotplug.c    |    5 ++++-
 mm/page_alloc.c        |    3 +++
 5 files changed, 64 insertions(+), 12 deletions(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index b3a1a5d77d92..64829b17980b 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -308,6 +308,19 @@ config ZONE_DMA
 
 	  If unsure, say Y.
 
+config ZONE_DEVICE
+	bool "Device memory (pmem, etc...) hotplug support" if EXPERT
+	default !ZONE_DMA
+	depends on !ZONE_DMA
+	help
+	  Device memory hotplug support allows for establishing pmem,
+	  or other device driver discovered memory regions, in the
+	  memmap. This allows pfn_to_page() lookups of otherwise
+	  "device-physical" addresses which is needed for using a DAX
+	  mapping in an O_DIRECT operation, among other things.
+
+	  If FS_DAX is enabled, then say Y.
+
 config SMP
 	bool "Symmetric multi-processing support"
 	---help---
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 3fba623e3ba5..94f0fa56f0ed 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -683,15 +683,8 @@ static void  update_end_of_memory_vars(u64 start, u64 size)
 	}
 }
 
-/*
- * Memory is added always to NORMAL zone. This means you will never get
- * additional DMA/DMA32 memory.
- */
-int arch_add_memory(int nid, u64 start, u64 size)
+static int __arch_add_memory(int nid, u64 start, u64 size, struct zone *zone)
 {
-	struct pglist_data *pgdat = NODE_DATA(nid);
-	struct zone *zone = pgdat->node_zones +
-		zone_for_memory(nid, start, size, ZONE_NORMAL);
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 	int ret;
@@ -701,11 +694,28 @@ int arch_add_memory(int nid, u64 start, u64 size)
 	ret = __add_pages(nid, zone, start_pfn, nr_pages);
 	WARN_ON_ONCE(ret);
 
-	/* update max_pfn, max_low_pfn and high_memory */
-	update_end_of_memory_vars(start, size);
+	/*
+	 * Update max_pfn, max_low_pfn and high_memory, unless we added
+	 * "device memory" which should not effect max_pfn
+	 */
+	if (!is_dev_zone(zone))
+		update_end_of_memory_vars(start, size);
 
 	return ret;
 }
+
+/*
+ * Memory is added always to NORMAL zone. This means you will never get
+ * additional DMA/DMA32 memory.
+ */
+int arch_add_memory(int nid, u64 start, u64 size)
+{
+	struct pglist_data *pgdat = NODE_DATA(nid);
+	struct zone *zone = pgdat->node_zones +
+		zone_for_memory(nid, start, size, ZONE_NORMAL);
+
+	return __arch_add_memory(nid, start, size, zone);
+}
 EXPORT_SYMBOL_GPL(arch_add_memory);
 
 #define PAGE_INUSE 0xFD
@@ -1028,7 +1038,7 @@ int __ref arch_remove_memory(u64 start, u64 size)
 
 	return ret;
 }
-#endif
+#endif /* CONFIG_MEMORY_HOTREMOVE */
 #endif /* CONFIG_MEMORY_HOTPLUG */
 
 static struct kcore_list kcore_vsyscall;
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
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 26fbba7d888f..6bc5b755ce98 100644
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
