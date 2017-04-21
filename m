Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 92A236B039F
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 08:30:31 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id l196so128862920ioe.19
        for <linux-mm@kvack.org>; Fri, 21 Apr 2017 05:30:31 -0700 (PDT)
Received: from mail-io0-f194.google.com (mail-io0-f194.google.com. [209.85.223.194])
        by mx.google.com with ESMTPS id c65si2324253itb.88.2017.04.21.05.30.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Apr 2017 05:30:25 -0700 (PDT)
Received: by mail-io0-f194.google.com with SMTP id h41so29889342ioi.1
        for <linux-mm@kvack.org>; Fri, 21 Apr 2017 05:30:25 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 10/13] mm, memory_hotplug: do not associate hotadded memory to zones until online
Date: Fri, 21 Apr 2017 14:30:03 +0200
Message-Id: <20170421123003.25937-1-mhocko@kernel.org>
In-Reply-To: <20170421120512.23960-1-mhocko@kernel.org>
References: <20170421120512.23960-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Dan Williams <dan.j.williams@gmail.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

From: Michal Hocko <mhocko@suse.com>

The current memory hotplug implementation relies on having all the
struct pages associate with a zone/node during the physical hotplug phase
(arch_add_memory->__add_pages->__add_section->__add_zone). In the vast
majority of cases this means that they are added to ZONE_NORMAL. This
has been so since 9d99aaa31f59 ("[PATCH] x86_64: Support memory hotadd
without sparsemem") and it wasn't a big deal back then because movable
onlining didn't exist yet.

Much later memory hotplug wanted to (ab)use ZONE_MOVABLE for movable
onlining 511c2aba8f07 ("mm, memory-hotplug: dynamic configure movable
memory and portion memory") and then things got more complicated. Rather
than reconsidering the zone association which was no longer needed
(because the memory hotplug already depended on SPARSEMEM) a convoluted
semantic of zone shifting has been developed. Only the currently last
memblock or the one adjacent to the zone_movable can be onlined movable.
This essentially means that the online type changes as the new memblocks
are added.

Let's simulate memory hot online manually
$ echo 0x100000000 > /sys/devices/system/memory/probe
$ grep . /sys/devices/system/memory/memory32/valid_zones
Normal Movable

$ echo $((0x100000000+(128<<20))) > /sys/devices/system/memory/probe
$ grep . /sys/devices/system/memory/memory3?/valid_zones
/sys/devices/system/memory/memory32/valid_zones:Normal
/sys/devices/system/memory/memory33/valid_zones:Normal Movable

$ echo $((0x100000000+2*(128<<20))) > /sys/devices/system/memory/probe
$ grep . /sys/devices/system/memory/memory3?/valid_zones
/sys/devices/system/memory/memory32/valid_zones:Normal
/sys/devices/system/memory/memory33/valid_zones:Normal
/sys/devices/system/memory/memory34/valid_zones:Normal Movable

$ echo online_movable > /sys/devices/system/memory/memory34/state
$ grep . /sys/devices/system/memory/memory3?/valid_zones
/sys/devices/system/memory/memory32/valid_zones:Normal
/sys/devices/system/memory/memory33/valid_zones:Normal Movable
/sys/devices/system/memory/memory34/valid_zones:Movable Normal

This is an awkward semantic because an udev event is sent as soon as the
block is onlined and an udev handler might want to online it based on
some policy (e.g. association with a node) but it will inherently race
with new blocks showing up.

This patch changes the physical online phase to not associate pages
with any zone at all. All the pages are just marked reserved and wait
for the onlining phase to be associated with the zone as per the online
request. There are only two requirements
	- existing ZONE_NORMAL and ZONE_MOVABLE cannot overlap
	- ZONE_NORMAL precedes ZONE_MOVABLE in physical addresses
the later on is not an inherent requirement and can be changed in the
future. It preserves the current behavior and made the code slightly
simpler. This is subject to change in future.

This means that the same physical online steps as above will lead to the
following state:
Normal Movable

/sys/devices/system/memory/memory32/valid_zones:Normal Movable
/sys/devices/system/memory/memory33/valid_zones:Normal Movable

/sys/devices/system/memory/memory32/valid_zones:Normal Movable
/sys/devices/system/memory/memory33/valid_zones:Normal Movable
/sys/devices/system/memory/memory34/valid_zones:Normal Movable

/sys/devices/system/memory/memory32/valid_zones:Normal Movable
/sys/devices/system/memory/memory33/valid_zones:Normal Movable
/sys/devices/system/memory/memory34/valid_zones:Movable

Implementation:
The current move_pfn_range is reimplemented to check the above
requirements (allow_online_pfn_range) and then updates the respective
zone (move_pfn_range_to_zone), the pgdat and links all the pages in the
pfn range with the zone/node. __add_pages is updated to not require the
zone and only initializes sections in the range. This allowed to
simplify the arch_add_memory code (s390 could get rid of quite some
of code).

devm_memremap_pages is the only user of arch_add_memory which relies
on the zone association because it only hooks into the memory hotplug
only half way. It uses it to associate the new memory with ZONE_DEVICE
but doesn't allow it to be {on,off}lined via sysfs. This means that this
particular code path has to call move_pfn_range_to_zone explicitly.

The original zone shifting code is kept in place and will be removed in
the follow up patch for an easier review.

Please note that this patch also changes the original behavior when
offlining a memory block adjacent to another zone (Normal vs. Movable)
used to allow to change its movable type. This will be handled later.

Changes since v1
- we have to associate the page with the node early (in __add_section),
  because pfn_to_node depends on struct page containing this
  information - based on testing by Reza Arbab
- resize_{zone,pgdat}_range has to check whether they are popoulated -
  Reza Arbab
- fix devm_memremap_pages to use pfn rather than physical address -
  JA(C)rA'me Glisse
- move_pfn_range has to check for intersection with zone_movable rather
  than to rely on allow_online_pfn_range(MMOP_ONLINE_MOVABLE) for
  MMOP_ONLINE_KEEP

Changes since v2
- fix show_valid_zones nr_pages calculation
- allow_online_pfn_range has to check managed pages rather than present
- zone_intersects fix bogus check
- fix zone_intersects + few nits as per Vlastimil

Cc: Dan Williams <dan.j.williams@gmail.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: linux-arch@vger.kernel.org
Acked-by: Heiko Carstens <heiko.carstens@de.ibm.com> # For s390 bits
Tested-by: Reza Arbab <arbab@linux.vnet.ibm.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 arch/ia64/mm/init.c            |   9 +-
 arch/powerpc/mm/mem.c          |  10 +-
 arch/s390/mm/init.c            |  30 +-----
 arch/sh/mm/init.c              |   8 +-
 arch/x86/mm/init_32.c          |   5 +-
 arch/x86/mm/init_64.c          |   9 +-
 drivers/base/memory.c          |  52 ++++++-----
 include/linux/memory_hotplug.h |  13 +--
 include/linux/mmzone.h         |  20 ++++
 kernel/memremap.c              |   4 +
 mm/memory_hotplug.c            | 204 +++++++++++++++++++++++++----------------
 mm/sparse.c                    |   3 +-
 12 files changed, 193 insertions(+), 174 deletions(-)

diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index 39e2aeb4669d..80db57d063d0 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -648,18 +648,11 @@ mem_init (void)
 #ifdef CONFIG_MEMORY_HOTPLUG
 int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
 {
-	pg_data_t *pgdat;
-	struct zone *zone;
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 	int ret;
 
-	pgdat = NODE_DATA(nid);
-
-	zone = pgdat->node_zones +
-		zone_for_memory(nid, start, size, ZONE_NORMAL, for_device);
-	ret = __add_pages(nid, zone, start_pfn, nr_pages, !for_device);
-
+	ret = __add_pages(nid, start_pfn, nr_pages, !for_device);
 	if (ret)
 		printk("%s: Problem encountered in __add_pages() as ret=%d\n",
 		       __func__,  ret);
diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
index e6b2e6618b6c..72c46eb53215 100644
--- a/arch/powerpc/mm/mem.c
+++ b/arch/powerpc/mm/mem.c
@@ -128,16 +128,12 @@ int __weak remove_section_mapping(unsigned long start, unsigned long end)
 
 int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
 {
-	struct pglist_data *pgdata;
-	struct zone *zone;
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 	int rc;
 
 	resize_hpt_for_hotplug(memblock_phys_mem_size());
 
-	pgdata = NODE_DATA(nid);
-
 	start = (unsigned long)__va(start);
 	rc = create_section_mapping(start, start + size);
 	if (rc) {
@@ -147,11 +143,7 @@ int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
 		return -EFAULT;
 	}
 
-	/* this should work for most non-highmem platforms */
-	zone = pgdata->node_zones +
-		zone_for_memory(nid, start, size, 0, for_device);
-
-	return __add_pages(nid, zone, start_pfn, nr_pages, !for_device);
+	return __add_pages(nid, start_pfn, nr_pages, !for_device);
 }
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
index 893cf88cf02d..862824924ba6 100644
--- a/arch/s390/mm/init.c
+++ b/arch/s390/mm/init.c
@@ -164,41 +164,15 @@ unsigned long memory_block_size_bytes(void)
 #ifdef CONFIG_MEMORY_HOTPLUG
 int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
 {
-	unsigned long zone_start_pfn, zone_end_pfn, nr_pages;
 	unsigned long start_pfn = PFN_DOWN(start);
 	unsigned long size_pages = PFN_DOWN(size);
-	pg_data_t *pgdat = NODE_DATA(nid);
-	struct zone *zone;
-	int rc, i;
+	int rc;
 
 	rc = vmem_add_mapping(start, size);
 	if (rc)
 		return rc;
 
-	for (i = 0; i < MAX_NR_ZONES; i++) {
-		zone = pgdat->node_zones + i;
-		if (zone_idx(zone) != ZONE_MOVABLE) {
-			/* Add range within existing zone limits, if possible */
-			zone_start_pfn = zone->zone_start_pfn;
-			zone_end_pfn = zone->zone_start_pfn +
-				       zone->spanned_pages;
-		} else {
-			/* Add remaining range to ZONE_MOVABLE */
-			zone_start_pfn = start_pfn;
-			zone_end_pfn = start_pfn + size_pages;
-		}
-		if (start_pfn < zone_start_pfn || start_pfn >= zone_end_pfn)
-			continue;
-		nr_pages = (start_pfn + size_pages > zone_end_pfn) ?
-			   zone_end_pfn - start_pfn : size_pages;
-		rc = __add_pages(nid, zone, start_pfn, nr_pages, !for_device);
-		if (rc)
-			break;
-		start_pfn += nr_pages;
-		size_pages -= nr_pages;
-		if (!size_pages)
-			break;
-	}
+	rc = __add_pages(nid, start_pfn, size_pages, !for_device);
 	if (rc)
 		vmem_remove_mapping(start, size);
 	return rc;
diff --git a/arch/sh/mm/init.c b/arch/sh/mm/init.c
index a9d57f75ae8c..3813a610a2bb 100644
--- a/arch/sh/mm/init.c
+++ b/arch/sh/mm/init.c
@@ -487,18 +487,12 @@ void free_initrd_mem(unsigned long start, unsigned long end)
 #ifdef CONFIG_MEMORY_HOTPLUG
 int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
 {
-	pg_data_t *pgdat;
 	unsigned long start_pfn = PFN_DOWN(start);
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 	int ret;
 
-	pgdat = NODE_DATA(nid);
-
 	/* We only have ZONE_NORMAL, so this is easy.. */
-	ret = __add_pages(nid, pgdat->node_zones +
-			zone_for_memory(nid, start, size, ZONE_NORMAL,
-			for_device),
-			start_pfn, nr_pages, !for_device);
+	ret = __add_pages(nid, start_pfn, nr_pages, !for_device);
 	if (unlikely(ret))
 		printk("%s: Failed, __add_pages() == %d\n", __func__, ret);
 
diff --git a/arch/x86/mm/init_32.c b/arch/x86/mm/init_32.c
index 94594b889144..a424066d0552 100644
--- a/arch/x86/mm/init_32.c
+++ b/arch/x86/mm/init_32.c
@@ -825,13 +825,10 @@ void __init mem_init(void)
 #ifdef CONFIG_MEMORY_HOTPLUG
 int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
 {
-	struct pglist_data *pgdata = NODE_DATA(nid);
-	struct zone *zone = pgdata->node_zones +
-		zone_for_memory(nid, start, size, ZONE_HIGHMEM, for_device);
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 
-	return __add_pages(nid, zone, start_pfn, nr_pages, !for_device);
+	return __add_pages(nid, start_pfn, nr_pages, !for_device);
 }
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 53eeb01b7888..f07c850efa30 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -682,22 +682,15 @@ static void  update_end_of_memory_vars(u64 start, u64 size)
 	}
 }
 
-/*
- * Memory is added always to NORMAL zone. This means you will never get
- * additional DMA/DMA32 memory.
- */
 int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
 {
-	struct pglist_data *pgdat = NODE_DATA(nid);
-	struct zone *zone = pgdat->node_zones +
-		zone_for_memory(nid, start, size, ZONE_NORMAL, for_device);
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 	int ret;
 
 	init_memory_mapping(start, start + size);
 
-	ret = __add_pages(nid, zone, start_pfn, nr_pages, !for_device);
+	ret = __add_pages(nid, start_pfn, nr_pages, !for_device);
 	WARN_ON_ONCE(ret);
 
 	/* update max_pfn, max_low_pfn and high_memory */
diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index ea838f8114b4..5ae81617f11d 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -392,39 +392,43 @@ static ssize_t show_valid_zones(struct device *dev,
 				struct device_attribute *attr, char *buf)
 {
 	struct memory_block *mem = to_memory_block(dev);
-	unsigned long start_pfn, end_pfn;
-	unsigned long valid_start, valid_end, valid_pages;
+	unsigned long start_pfn = section_nr_to_pfn(mem->start_section_nr);
 	unsigned long nr_pages = PAGES_PER_SECTION * sections_per_block;
-	struct zone *zone;
-	int zone_shift = 0;
+	unsigned long valid_start_pfn, valid_end_pfn;
+	bool append = false;
+	int nid;
 
-	start_pfn = section_nr_to_pfn(mem->start_section_nr);
-	end_pfn = start_pfn + nr_pages;
-
-	/* The block contains more than one zone can not be offlined. */
-	if (!test_pages_in_a_zone(start_pfn, end_pfn, &valid_start, &valid_end))
+	/*
+	 * The block contains more than one zone can not be offlined.
+	 * This can happen e.g. for ZONE_DMA and ZONE_DMA32
+	 */
+	if (!test_pages_in_a_zone(start_pfn, start_pfn + nr_pages, &valid_start_pfn, &valid_end_pfn))
 		return sprintf(buf, "none\n");
 
-	zone = page_zone(pfn_to_page(valid_start));
-	valid_pages = valid_end - valid_start;
-
-	/* MMOP_ONLINE_KEEP */
-	sprintf(buf, "%s", zone->name);
+	start_pfn = valid_start_pfn;
+	nr_pages = valid_end_pfn - start_pfn;
 
-	/* MMOP_ONLINE_KERNEL */
-	zone_can_shift(valid_start, valid_pages, ZONE_NORMAL, &zone_shift);
-	if (zone_shift) {
-		strcat(buf, " ");
-		strcat(buf, (zone + zone_shift)->name);
+	/*
+	 * Check the existing zone. Make sure that we do that only on the
+	 * online nodes otherwise the page_zone is not reliable
+	 */
+	if (mem->state == MEM_ONLINE) {
+		strcat(buf, page_zone(pfn_to_page(start_pfn))->name);
+		goto out;
 	}
 
-	/* MMOP_ONLINE_MOVABLE */
-	zone_can_shift(valid_start, valid_pages, ZONE_MOVABLE, &zone_shift);
-	if (zone_shift) {
-		strcat(buf, " ");
-		strcat(buf, (zone + zone_shift)->name);
+	nid = pfn_to_nid(start_pfn);
+	if (allow_online_pfn_range(nid, start_pfn, nr_pages, MMOP_ONLINE_KERNEL)) {
+		strcat(buf, NODE_DATA(nid)->node_zones[ZONE_NORMAL].name);
+		append = true;
 	}
 
+	if (allow_online_pfn_range(nid, start_pfn, nr_pages, MMOP_ONLINE_MOVABLE)) {
+		if (append)
+			strcat(buf, " ");
+		strcat(buf, NODE_DATA(nid)->node_zones[ZONE_MOVABLE].name);
+	}
+out:
 	strcat(buf, "\n");
 
 	return strlen(buf);
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index fc1c873504eb..9cd76ff7b0c5 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -122,8 +122,8 @@ extern int __remove_pages(struct zone *zone, unsigned long start_pfn,
 	unsigned long nr_pages);
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 
-/* reasonably generic interface to expand the physical pages in a zone  */
-extern int __add_pages(int nid, struct zone *zone, unsigned long start_pfn,
+/* reasonably generic interface to expand the physical pages */
+extern int __add_pages(int nid, unsigned long start_pfn,
 	unsigned long nr_pages, bool want_memblock);
 
 #ifdef CONFIG_NUMA
@@ -298,15 +298,16 @@ extern int add_memory_resource(int nid, struct resource *resource, bool online);
 extern int zone_for_memory(int nid, u64 start, u64 size, int zone_default,
 		bool for_device);
 extern int arch_add_memory(int nid, u64 start, u64 size, bool for_device);
+extern void move_pfn_range_to_zone(struct zone *zone, unsigned long start_pfn,
+		unsigned long nr_pages);
 extern int offline_pages(unsigned long start_pfn, unsigned long nr_pages);
 extern bool is_memblock_offlined(struct memory_block *mem);
 extern void remove_memory(int nid, u64 start, u64 size);
-extern int sparse_add_one_section(struct zone *zone, unsigned long start_pfn);
+extern int sparse_add_one_section(struct pglist_data *pgdat, unsigned long start_pfn);
 extern void sparse_remove_one_section(struct zone *zone, struct mem_section *ms,
 		unsigned long map_offset);
 extern struct page *sparse_decode_mem_map(unsigned long coded_mem_map,
 					  unsigned long pnum);
-extern bool zone_can_shift(unsigned long pfn, unsigned long nr_pages,
-			  enum zone_type target, int *zone_shift);
-
+extern bool allow_online_pfn_range(int nid, unsigned long pfn, unsigned long nr_pages,
+		int online_type);
 #endif /* __LINUX_MEMORY_HOTPLUG_H */
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index aa8cc03287b0..c412e6a3a1e9 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -533,6 +533,26 @@ static inline bool zone_is_empty(struct zone *zone)
 }
 
 /*
+ * Return true if [start_pfn, start_pfn + nr_pages) range has a non-empty
+ * intersection with the given zone
+ */
+static inline bool zone_intersects(struct zone *zone,
+		unsigned long start_pfn, unsigned long nr_pages)
+{
+	if (zone_is_empty(zone))
+		return false;
+	if (start_pfn >= zone_end_pfn(zone))
+		return false;
+
+	if (zone->zone_start_pfn <= start_pfn)
+		return true;
+	if (start_pfn + nr_pages > zone->zone_start_pfn)
+		return true;
+
+	return false;
+}
+
+/*
  * The "priority" of VM scanning is how much of the queues we will scan in one
  * go. A value of 12 for DEF_PRIORITY implies that we will scan 1/4096th of the
  * queues ("queue_length >> 12") during an aging round.
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 07e85e5229da..61aaa41f4e18 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -364,6 +364,10 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 
 	mem_hotplug_begin();
 	error = arch_add_memory(nid, align_start, align_size, true);
+	if (!error)
+		move_pfn_range_to_zone(&NODE_DATA(nid)->node_zones[ZONE_DEVICE],
+					align_start >> PAGE_SHIFT,
+					align_size >> PAGE_SHIFT);
 	mem_hotplug_done();
 	if (error)
 		goto err_add_memory;
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 98f565c279bf..64b5b5b191a0 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -433,25 +433,6 @@ static int __meminit move_pfn_range_right(struct zone *z1, struct zone *z2,
 	return -1;
 }
 
-static struct zone * __meminit move_pfn_range(int zone_shift,
-		unsigned long start_pfn, unsigned long end_pfn)
-{
-	struct zone *zone = page_zone(pfn_to_page(start_pfn));
-	int ret = 0;
-
-	if (zone_shift < 0)
-		ret = move_pfn_range_left(zone + zone_shift, zone,
-					  start_pfn, end_pfn);
-	else if (zone_shift)
-		ret = move_pfn_range_right(zone, zone + zone_shift,
-					   start_pfn, end_pfn);
-
-	if (ret)
-		return NULL;
-
-	return zone + zone_shift;
-}
-
 static void __meminit grow_pgdat_span(struct pglist_data *pgdat, unsigned long start_pfn,
 				      unsigned long end_pfn)
 {
@@ -493,23 +474,35 @@ static int __meminit __add_zone(struct zone *zone, unsigned long phys_start_pfn)
 	return 0;
 }
 
-static int __meminit __add_section(int nid, struct zone *zone,
-		unsigned long phys_start_pfn, bool want_memblock)
+static int __meminit __add_section(int nid, unsigned long phys_start_pfn,
+		bool want_memblock)
 {
 	int ret;
+	int i;
 
 	if (pfn_valid(phys_start_pfn))
 		return -EEXIST;
 
-	ret = sparse_add_one_section(zone, phys_start_pfn);
-
+	ret = sparse_add_one_section(NODE_DATA(nid), phys_start_pfn);
 	if (ret < 0)
 		return ret;
 
-	ret = __add_zone(zone, phys_start_pfn);
+	/*
+	 * Make all the pages reserved so that nobody will stumble over half
+	 * initialized state.
+	 * FIXME: We also have to associate it with a node because pfn_to_node
+	 * relies on having page with the proper node.
+	 */
+	for (i = 0; i < PAGES_PER_SECTION; i++) {
+		unsigned long pfn = phys_start_pfn + i;
+		struct page *page;
+		if (!pfn_valid(pfn))
+			continue;
 
-	if (ret < 0)
-		return ret;
+		page = pfn_to_page(pfn);
+		set_page_node(page, nid);
+		SetPageReserved(page);
+	}
 
 	if (!want_memblock)
 		return 0;
@@ -523,7 +516,7 @@ static int __meminit __add_section(int nid, struct zone *zone,
  * call this function after deciding the zone to which to
  * add the new pages.
  */
-int __ref __add_pages(int nid, struct zone *zone, unsigned long phys_start_pfn,
+int __ref __add_pages(int nid, unsigned long phys_start_pfn,
 			unsigned long nr_pages, bool want_memblock)
 {
 	unsigned long i;
@@ -531,8 +524,6 @@ int __ref __add_pages(int nid, struct zone *zone, unsigned long phys_start_pfn,
 	int start_sec, end_sec;
 	struct vmem_altmap *altmap;
 
-	clear_zone_contiguous(zone);
-
 	/* during initialize mem_map, align hot-added range to section */
 	start_sec = pfn_to_section_nr(phys_start_pfn);
 	end_sec = pfn_to_section_nr(phys_start_pfn + nr_pages - 1);
@@ -552,7 +543,7 @@ int __ref __add_pages(int nid, struct zone *zone, unsigned long phys_start_pfn,
 	}
 
 	for (i = start_sec; i <= end_sec; i++) {
-		err = __add_section(nid, zone, section_nr_to_pfn(i), want_memblock);
+		err = __add_section(nid, section_nr_to_pfn(i), want_memblock);
 
 		/*
 		 * EEXIST is finally dealt with by ioresource collision
@@ -565,7 +556,6 @@ int __ref __add_pages(int nid, struct zone *zone, unsigned long phys_start_pfn,
 	}
 	vmemmap_populate_print_last();
 out:
-	set_zone_contiguous(zone);
 	return err;
 }
 EXPORT_SYMBOL_GPL(__add_pages);
@@ -1033,39 +1023,114 @@ static void node_states_set_node(int node, struct memory_notify *arg)
 	node_set_state(node, N_MEMORY);
 }
 
-bool zone_can_shift(unsigned long pfn, unsigned long nr_pages,
-		   enum zone_type target, int *zone_shift)
+bool allow_online_pfn_range(int nid, unsigned long pfn, unsigned long nr_pages, int online_type)
 {
-	struct zone *zone = page_zone(pfn_to_page(pfn));
-	enum zone_type idx = zone_idx(zone);
-	int i;
+	struct pglist_data *pgdat = NODE_DATA(nid);
+	struct zone *movable_zone = &pgdat->node_zones[ZONE_MOVABLE];
+	struct zone *normal_zone =  &pgdat->node_zones[ZONE_NORMAL];
 
-	*zone_shift = 0;
+	/*
+	 * TODO there shouldn't be any inherent reason to have ZONE_NORMAL
+	 * physically before ZONE_MOVABLE. All we need is they do not
+	 * overlap. Historically we didn't allow ZONE_NORMAL after ZONE_MOVABLE
+	 * though so let's stick with it for simplicity for now.
+	 * TODO make sure we do not overlap with ZONE_DEVICE
+	 */
+	if (online_type == MMOP_ONLINE_KERNEL) {
+		if (zone_is_empty(movable_zone))
+			return true;
+		return movable_zone->zone_start_pfn >= pfn + nr_pages;
+	} else if (online_type == MMOP_ONLINE_MOVABLE) {
+		return zone_end_pfn(normal_zone) <= pfn;
+	}
 
-	if (idx < target) {
-		/* pages must be at end of current zone */
-		if (pfn + nr_pages != zone_end_pfn(zone))
-			return false;
+	/* MMOP_ONLINE_KEEP will always succeed and inherits the current zone */
+	return online_type == MMOP_ONLINE_KEEP;
+}
+
+static void __meminit resize_zone_range(struct zone *zone, unsigned long start_pfn,
+		unsigned long nr_pages)
+{
+	unsigned long old_end_pfn = zone_end_pfn(zone);
+
+	if (zone_is_empty(zone) || start_pfn < zone->zone_start_pfn)
+		zone->zone_start_pfn = start_pfn;
+
+	zone->spanned_pages = max(start_pfn + nr_pages, old_end_pfn) - zone->zone_start_pfn;
+}
+
+static void __meminit resize_pgdat_range(struct pglist_data *pgdat, unsigned long start_pfn,
+                                     unsigned long nr_pages)
+{
+	unsigned long old_end_pfn = pgdat_end_pfn(pgdat);
 
-		/* no zones in use between current zone and target */
-		for (i = idx + 1; i < target; i++)
-			if (zone_is_initialized(zone - idx + i))
-				return false;
+	if (!pgdat->node_spanned_pages || start_pfn < pgdat->node_start_pfn)
+		pgdat->node_start_pfn = start_pfn;
+
+	pgdat->node_spanned_pages = max(start_pfn + nr_pages, old_end_pfn) - pgdat->node_start_pfn;
+}
+
+void move_pfn_range_to_zone(struct zone *zone,
+		unsigned long start_pfn, unsigned long nr_pages)
+{
+	struct pglist_data *pgdat = zone->zone_pgdat;
+	int nid = pgdat->node_id;
+	unsigned long flags;
+	unsigned long i;
+
+	if (zone_is_empty(zone))
+		init_currently_empty_zone(zone, start_pfn, nr_pages);
+
+	clear_zone_contiguous(zone);
+
+	/* TODO Huh pgdat is irqsave while zone is not. It used to be like that before */
+	pgdat_resize_lock(pgdat, &flags);
+	zone_span_writelock(zone);
+	resize_zone_range(zone, start_pfn, nr_pages);
+	zone_span_writeunlock(zone);
+	resize_pgdat_range(pgdat, start_pfn, nr_pages);
+	pgdat_resize_unlock(pgdat, &flags);
+
+	/*
+	 * TODO now we have a visible range of pages which are not associated
+	 * with their zone properly. Not nice but set_pfnblock_flags_mask
+	 * expects the zone spans the pfn range. All the pages in the range
+	 * are reserved so nobody should be touching them so we should be safe
+	 */
+	memmap_init_zone(nr_pages, nid, zone_idx(zone), start_pfn, MEMMAP_HOTPLUG);
+	for (i = 0; i < nr_pages; i++) {
+		unsigned long pfn = start_pfn + i;
+		set_page_links(pfn_to_page(pfn), zone_idx(zone), nid, pfn);
 	}
 
-	if (target < idx) {
-		/* pages must be at beginning of current zone */
-		if (pfn != zone->zone_start_pfn)
-			return false;
+	set_zone_contiguous(zone);
+}
+
+/*
+ * Associates the given pfn range with the given node and the zone appropriate
+ * for the given online type.
+ */
+static struct zone * __meminit move_pfn_range(int online_type, int nid,
+		unsigned long start_pfn, unsigned long nr_pages)
+{
+	struct pglist_data *pgdat = NODE_DATA(nid);
+	struct zone *zone = &pgdat->node_zones[ZONE_NORMAL];
 
-		/* no zones in use between current zone and target */
-		for (i = target + 1; i < idx; i++)
-			if (zone_is_initialized(zone - idx + i))
-				return false;
+	if (online_type == MMOP_ONLINE_KEEP) {
+		struct zone *movable_zone = &pgdat->node_zones[ZONE_MOVABLE];
+		/*
+		 * MMOP_ONLINE_KEEP inherits the current zone which is
+		 * ZONE_NORMAL by default but we might be within ZONE_MOVABLE
+		 * already.
+		 */
+		if (zone_intersects(movable_zone, start_pfn, nr_pages))
+			zone = movable_zone;
+	} else if (online_type == MMOP_ONLINE_MOVABLE) {
+		zone = &pgdat->node_zones[ZONE_MOVABLE];
 	}
 
-	*zone_shift = target - idx;
-	return true;
+	move_pfn_range_to_zone(zone, start_pfn, nr_pages);
+	return zone;
 }
 
 /* Must be protected by mem_hotplug_begin() */
@@ -1078,38 +1143,21 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 	int nid;
 	int ret;
 	struct memory_notify arg;
-	int zone_shift = 0;
 
-	/*
-	 * This doesn't need a lock to do pfn_to_page().
-	 * The section can't be removed here because of the
-	 * memory_block->state_mutex.
-	 */
-	zone = page_zone(pfn_to_page(pfn));
-
-	if ((zone_idx(zone) > ZONE_NORMAL ||
-	    online_type == MMOP_ONLINE_MOVABLE) &&
-	    !can_online_high_movable(pfn_to_nid(pfn)))
+	nid = pfn_to_nid(pfn);
+	if (!allow_online_pfn_range(nid, pfn, nr_pages, online_type))
 		return -EINVAL;
 
-	if (online_type == MMOP_ONLINE_KERNEL) {
-		if (!zone_can_shift(pfn, nr_pages, ZONE_NORMAL, &zone_shift))
-			return -EINVAL;
-	} else if (online_type == MMOP_ONLINE_MOVABLE) {
-		if (!zone_can_shift(pfn, nr_pages, ZONE_MOVABLE, &zone_shift))
-			return -EINVAL;
-	}
-
-	zone = move_pfn_range(zone_shift, pfn, pfn + nr_pages);
-	if (!zone)
+	if (online_type == MMOP_ONLINE_MOVABLE && !can_online_high_movable(nid))
 		return -EINVAL;
 
+	/* associate pfn range with the zone */
+	zone = move_pfn_range(online_type, nid, pfn, nr_pages);
+
 	arg.start_pfn = pfn;
 	arg.nr_pages = nr_pages;
 	node_states_check_changes_online(nr_pages, zone, &arg);
 
-	nid = zone_to_nid(zone);
-
 	ret = memory_notify(MEM_GOING_ONLINE, &arg);
 	ret = notifier_to_errno(ret);
 	if (ret)
diff --git a/mm/sparse.c b/mm/sparse.c
index 79017f90d8fc..ea6d03a52858 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -729,10 +729,9 @@ static void free_map_bootmem(struct page *memmap)
  * set.  If this is <=0, then that means that the passed-in
  * map was not consumed and must be freed.
  */
-int __meminit sparse_add_one_section(struct zone *zone, unsigned long start_pfn)
+int __meminit sparse_add_one_section(struct pglist_data *pgdat, unsigned long start_pfn)
 {
 	unsigned long section_nr = pfn_to_section_nr(start_pfn);
-	struct pglist_data *pgdat = zone->zone_pgdat;
 	struct mem_section *ms;
 	struct page *memmap;
 	unsigned long *usemap;
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
