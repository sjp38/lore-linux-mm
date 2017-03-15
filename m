Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id A6AD56B0038
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 05:13:54 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id b140so3838165wme.3
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 02:13:54 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p51si1800358wrb.250.2017.03.15.02.13.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 15 Mar 2017 02:13:52 -0700 (PDT)
Date: Wed, 15 Mar 2017 10:13:48 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH] rework memory hotplug onlining
Message-ID: <20170315091347.GA32626@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Mel Gorman <mgorman@suse.de>, qiuxishi@huawei.com, toshi.kani@hpe.com, xieyisheng1@huawei.com, slaoub@gmail.com, iamjoonsoo.kim@lge.com, Zhang Zhen <zhenzhang.zhang@huawei.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, Andi Kleen <ak@linux.intel.com>

Hi,
this is a follow up for [1]. In short the current semantic of the memory
hotplug is awkward and hard/impossible to use from the udev to online
memory as movable. The main problem is that only the last memblock or
the adjacent to highest movable memblock can be onlined as movable:
: Let's simulate memory hot online manually
: # echo 0x100000000 > /sys/devices/system/memory/probe
: # grep . /sys/devices/system/memory/memory32/valid_zones
: Normal Movable
: 
: which looks reasonably right? Both Normal and Movable zones are allowed
: 
: # echo $((0x100000000+(128<<20))) > /sys/devices/system/memory/probe
: # grep . /sys/devices/system/memory/memory3?/valid_zones
: /sys/devices/system/memory/memory32/valid_zones:Normal
: /sys/devices/system/memory/memory33/valid_zones:Normal Movable
: 
: Huh, so our valid_zones have changed under our feet...
: 
: # echo $((0x100000000+2*(128<<20))) > /sys/devices/system/memory/probe
: # grep . /sys/devices/system/memory/memory3?/valid_zones
: /sys/devices/system/memory/memory32/valid_zones:Normal
: /sys/devices/system/memory/memory33/valid_zones:Normal
: /sys/devices/system/memory/memory34/valid_zones:Normal Movable
: 
: and again. So only the last memblock is considered movable. Let's try to
: online them now.
: 
: # echo online_movable > /sys/devices/system/memory/memory34/state
: # grep . /sys/devices/system/memory/memory3?/valid_zones
: /sys/devices/system/memory/memory32/valid_zones:Normal
: /sys/devices/system/memory/memory33/valid_zones:Normal Movable
: /sys/devices/system/memory/memory34/valid_zones:Movable Normal

Now consider that the userspace gets the notification when the memblock
is added. If the udev context tries to online it it will a) race with
new memblocks showing up which leads to undeterministic behavior and
b) it will see memblocks ordered in growing physical addresses while
the only reliable way to online blocks as movable is exactly from other
directions. This is just plain wrong!

It seems that all this is just started by the semantic introduced by
9d99aaa31f59 ("[PATCH] x86_64: Support memory hotadd without sparsemem")
quite some time ago. When the movable onlinining has been introduced it
just built on top of this. It seems that the requirement to have
freshly probed memory associated with the zone normal is no longer
necessary. HOTPLUG depends on CONFIG_SPARSEMEM these days.

The following blob [2] simply removes all the zone specific operations
from __add_pages (aka arch_add_memory) path.  Instead we do page->zone
association from move_pfn_range which is called from online_pages. The
criterion for movable/normal zone association is really simple now. We
just have to guarantee that zone Normal is always lower than zone
Movable. It would be actually sufficient to guarantee they do not
overlap and that is indeed trivial to implement now. I didn't do that
yet for simplicity of this change though.

I have lightly tested the patch and nothing really jumped at me. I
assume there will be some rough edges but it should be sufficient to
start the discussion at least. Please note the diffstat. We have added
a lot of code to tweak on top of the previous semantic which is just
sad. Instead of developing a robust solution the memory hotplug is full
of tweaks to satisfy particular usecase without longer term plans.

Please note that this is just for x86 now but I will address other
arches once there is an agreement this is the right approach.

Thoughts, objections?

[1] http://lkml.kernel.org/r/20170310135807.GI3753@dhcp22.suse.cz
[2] I didn't get to split it out to proper patches yet because I would
like to hear back about potential issues which would basically block the
whole thing before I spend more time on this
---
 arch/x86/mm/init_32.c          |   4 +-
 arch/x86/mm/init_64.c          |   9 +-
 drivers/base/memory.c          |  52 +++---
 include/linux/memory_hotplug.h |  11 +-
 include/linux/mmzone.h         |  13 +-
 mm/memory_hotplug.c            | 360 +++++++++++------------------------------
 mm/page_alloc.c                |  11 +-
 mm/sparse.c                    |   3 +-
 8 files changed, 137 insertions(+), 326 deletions(-)

diff --git a/arch/x86/mm/init_32.c b/arch/x86/mm/init_32.c
index 928cfde76232..9deded3728bf 100644
--- a/arch/x86/mm/init_32.c
+++ b/arch/x86/mm/init_32.c
@@ -819,12 +819,10 @@ void __init mem_init(void)
 int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
 {
 	struct pglist_data *pgdata = NODE_DATA(nid);
-	struct zone *zone = pgdata->node_zones +
-		zone_for_memory(nid, start, size, ZONE_HIGHMEM, for_device);
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 
-	return __add_pages(nid, zone, start_pfn, nr_pages);
+	return __add_pages(nid, start_pfn, nr_pages);
 }
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 7eef17239378..bc53f24e6703 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -637,22 +637,15 @@ static void  update_end_of_memory_vars(u64 start, u64 size)
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
 
-	ret = __add_pages(nid, zone, start_pfn, nr_pages);
+	ret = __add_pages(nid, start_pfn, nr_pages);
 	WARN_ON_ONCE(ret);
 
 	/* update max_pfn, max_low_pfn and high_memory */
diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index cc4f1d0cbffe..3aea6a3b53e5 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -281,6 +281,7 @@ static int memory_subsys_online(struct device *dev)
 	 * If we are called from store_mem_state(), online_type will be
 	 * set >= 0 Otherwise we were called from the device online
 	 * attribute and need to set the online_type.
+	 * TODO WTF is this?
 	 */
 	if (mem->online_type < 0)
 		mem->online_type = MMOP_ONLINE_KEEP;
@@ -388,39 +389,44 @@ static ssize_t show_valid_zones(struct device *dev,
 				struct device_attribute *attr, char *buf)
 {
 	struct memory_block *mem = to_memory_block(dev);
-	unsigned long start_pfn, end_pfn;
-	unsigned long valid_start, valid_end, valid_pages;
-	unsigned long nr_pages = PAGES_PER_SECTION * sections_per_block;
+	unsigned long start_pfn, nr_pages;
+	bool append = false;
 	struct zone *zone;
-	int zone_shift = 0;
+	int nid;
 
 	start_pfn = section_nr_to_pfn(mem->start_section_nr);
-	end_pfn = start_pfn + nr_pages;
+	zone = page_zone(pfn_to_page(start_pfn));
+	nr_pages = PAGES_PER_SECTION * sections_per_block;
 
-	/* The block contains more than one zone can not be offlined. */
-	if (!test_pages_in_a_zone(start_pfn, end_pfn, &valid_start, &valid_end))
+	/*
+	 * The block contains more than one zone can not be offlined.
+	 * This can happen e.g. for ZONE_DMA and ZONE_DMA32
+	 */
+	if (!test_pages_in_a_zone(start_pfn, start_pfn + nr_pages, NULL, NULL))
 		return sprintf(buf, "none\n");
 
-	zone = page_zone(pfn_to_page(valid_start));
-	valid_pages = valid_end - valid_start;
-
-	/* MMOP_ONLINE_KEEP */
-	sprintf(buf, "%s", zone->name);
-
-	/* MMOP_ONLINE_KERNEL */
-	zone_can_shift(valid_start, valid_pages, ZONE_NORMAL, &zone_shift);
-	if (zone_shift) {
-		strcat(buf, " ");
-		strcat(buf, (zone + zone_shift)->name);
+	/*
+	 * Check the existing zone. Page which is not online will point to zone 0
+	 * so double check it belongs to that zone
+	 * TODO should we add ZONE_UNINITIALIZED?
+	 */
+	if (zone_spans_pfn(zone, start_pfn)) {
+		strcat(buf, zone->name);
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
index 134a2f69c21a..375f6e152649 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -109,8 +109,8 @@ extern int __remove_pages(struct zone *zone, unsigned long start_pfn,
 	unsigned long nr_pages);
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 
-/* reasonably generic interface to expand the physical pages in a zone  */
-extern int __add_pages(int nid, struct zone *zone, unsigned long start_pfn,
+/* reasonably generic interface to expand the physical pages */
+extern int __add_pages(int nid, unsigned long start_pfn,
 	unsigned long nr_pages);
 
 #ifdef CONFIG_NUMA
@@ -280,12 +280,11 @@ extern int arch_add_memory(int nid, u64 start, u64 size, bool for_device);
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
index 618499159a7c..c86c78617d17 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -442,8 +442,6 @@ struct zone {
 	seqlock_t		span_seqlock;
 #endif
 
-	int initialized;
-
 	/* Write-intensive fields used from the page allocator */
 	ZONE_PADDING(_pad1_)
 
@@ -520,14 +518,15 @@ static inline bool zone_spans_pfn(const struct zone *zone, unsigned long pfn)
 	return zone->zone_start_pfn <= pfn && pfn < zone_end_pfn(zone);
 }
 
-static inline bool zone_is_initialized(struct zone *zone)
+static inline bool zone_is_empty(struct zone *zone)
 {
-	return zone->initialized;
+	return zone->spanned_pages == 0;
 }
 
-static inline bool zone_is_empty(struct zone *zone)
+static inline bool zone_spans_range(const struct zone *zone, unsigned long start_pfn,
+		unsigned long nr_pages)
 {
-	return zone->spanned_pages == 0;
+	return zone->zone_start_pfn <= start_pfn && start_pfn + nr_pages < zone_end_pfn(zone);
 }
 
 /*
@@ -769,7 +768,7 @@ enum memmap_context {
 	MEMMAP_EARLY,
 	MEMMAP_HOTPLUG,
 };
-extern int init_currently_empty_zone(struct zone *zone, unsigned long start_pfn,
+extern void init_currently_empty_zone(struct zone *zone, unsigned long start_pfn,
 				     unsigned long size);
 
 extern void lruvec_init(struct lruvec *lruvec);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 6fb6bd2df787..4dbed7dc66a1 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -295,229 +295,98 @@ void __init register_page_bootmem_info_node(struct pglist_data *pgdat)
 }
 #endif /* CONFIG_HAVE_BOOTMEM_INFO_NODE */
 
-static void __meminit grow_zone_span(struct zone *zone, unsigned long start_pfn,
-				     unsigned long end_pfn)
+static void __meminit resize_zone(struct zone *zone, unsigned long start_pfn,
+		unsigned long nr_pages)
 {
-	unsigned long old_zone_end_pfn;
-
-	zone_span_writelock(zone);
+	unsigned long old_end_pfn = zone_end_pfn(zone);
 
-	old_zone_end_pfn = zone_end_pfn(zone);
-	if (zone_is_empty(zone) || start_pfn < zone->zone_start_pfn)
+	if (start_pfn < zone->zone_start_pfn)
 		zone->zone_start_pfn = start_pfn;
 
-	zone->spanned_pages = max(old_zone_end_pfn, end_pfn) -
-				zone->zone_start_pfn;
-
-	zone_span_writeunlock(zone);
-}
-
-static void resize_zone(struct zone *zone, unsigned long start_pfn,
-		unsigned long end_pfn)
-{
-	zone_span_writelock(zone);
-
-	if (end_pfn - start_pfn) {
-		zone->zone_start_pfn = start_pfn;
-		zone->spanned_pages = end_pfn - start_pfn;
-	} else {
-		/*
-		 * make it consist as free_area_init_core(),
-		 * if spanned_pages = 0, then keep start_pfn = 0
-		 */
-		zone->zone_start_pfn = 0;
-		zone->spanned_pages = 0;
-	}
-
-	zone_span_writeunlock(zone);
-}
-
-static void fix_zone_id(struct zone *zone, unsigned long start_pfn,
-		unsigned long end_pfn)
-{
-	enum zone_type zid = zone_idx(zone);
-	int nid = zone->zone_pgdat->node_id;
-	unsigned long pfn;
-
-	for (pfn = start_pfn; pfn < end_pfn; pfn++)
-		set_page_links(pfn_to_page(pfn), zid, nid, pfn);
+	zone->spanned_pages = max(start_pfn + nr_pages, old_end_pfn) - zone->zone_start_pfn;
 }
 
-/* Can fail with -ENOMEM from allocating a wait table with vmalloc() or
- * alloc_bootmem_node_nopanic()/memblock_virt_alloc_node_nopanic() */
-static int __ref ensure_zone_is_initialized(struct zone *zone,
-			unsigned long start_pfn, unsigned long num_pages)
+static void __meminit resize_pgdat(struct pglist_data *pgdat, unsigned long start_pfn,
+                                     unsigned long nr_pages)
 {
-	if (!zone_is_initialized(zone))
-		return init_currently_empty_zone(zone, start_pfn, num_pages);
-
-	return 0;
-}
-
-static int __meminit move_pfn_range_left(struct zone *z1, struct zone *z2,
-		unsigned long start_pfn, unsigned long end_pfn)
-{
-	int ret;
-	unsigned long flags;
-	unsigned long z1_start_pfn;
-
-	ret = ensure_zone_is_initialized(z1, start_pfn, end_pfn - start_pfn);
-	if (ret)
-		return ret;
-
-	pgdat_resize_lock(z1->zone_pgdat, &flags);
-
-	/* can't move pfns which are higher than @z2 */
-	if (end_pfn > zone_end_pfn(z2))
-		goto out_fail;
-	/* the move out part must be at the left most of @z2 */
-	if (start_pfn > z2->zone_start_pfn)
-		goto out_fail;
-	/* must included/overlap */
-	if (end_pfn <= z2->zone_start_pfn)
-		goto out_fail;
-
-	/* use start_pfn for z1's start_pfn if z1 is empty */
-	if (!zone_is_empty(z1))
-		z1_start_pfn = z1->zone_start_pfn;
-	else
-		z1_start_pfn = start_pfn;
-
-	resize_zone(z1, z1_start_pfn, end_pfn);
-	resize_zone(z2, end_pfn, zone_end_pfn(z2));
-
-	pgdat_resize_unlock(z1->zone_pgdat, &flags);
-
-	fix_zone_id(z1, start_pfn, end_pfn);
+	unsigned long old_end_pfn = pgdat_end_pfn(pgdat);
+	if (start_pfn < pgdat->node_start_pfn)
+		pgdat->node_start_pfn = start_pfn;
 
-	return 0;
-out_fail:
-	pgdat_resize_unlock(z1->zone_pgdat, &flags);
-	return -1;
+	pgdat->node_spanned_pages = max(start_pfn + nr_pages, old_end_pfn) - pgdat->node_start_pfn;
 }
 
-static int __meminit move_pfn_range_right(struct zone *z1, struct zone *z2,
-		unsigned long start_pfn, unsigned long end_pfn)
+/*
+ * Associates the given pfn range with the given node and the zone appropriate
+ * for the given online type.
+ */
+static struct zone * __meminit move_pfn_range(int online_type, int nid,
+		unsigned long start_pfn, unsigned long nr_pages)
 {
-	int ret;
+	struct pglist_data *pgdat = NODE_DATA(nid);
+	struct zone *zone = &pgdat->node_zones[ZONE_NORMAL];
 	unsigned long flags;
-	unsigned long z2_end_pfn;
-
-	ret = ensure_zone_is_initialized(z2, start_pfn, end_pfn - start_pfn);
-	if (ret)
-		return ret;
-
-	pgdat_resize_lock(z1->zone_pgdat, &flags);
-
-	/* can't move pfns which are lower than @z1 */
-	if (z1->zone_start_pfn > start_pfn)
-		goto out_fail;
-	/* the move out part mast at the right most of @z1 */
-	if (zone_end_pfn(z1) >  end_pfn)
-		goto out_fail;
-	/* must included/overlap */
-	if (start_pfn >= zone_end_pfn(z1))
-		goto out_fail;
-
-	/* use end_pfn for z2's end_pfn if z2 is empty */
-	if (!zone_is_empty(z2))
-		z2_end_pfn = zone_end_pfn(z2);
-	else
-		z2_end_pfn = end_pfn;
-
-	resize_zone(z1, z1->zone_start_pfn, start_pfn);
-	resize_zone(z2, start_pfn, z2_end_pfn);
-
-	pgdat_resize_unlock(z1->zone_pgdat, &flags);
-
-	fix_zone_id(z2, start_pfn, end_pfn);
-
-	return 0;
-out_fail:
-	pgdat_resize_unlock(z1->zone_pgdat, &flags);
-	return -1;
-}
-
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
-static void __meminit grow_pgdat_span(struct pglist_data *pgdat, unsigned long start_pfn,
-				      unsigned long end_pfn)
-{
-	unsigned long old_pgdat_end_pfn = pgdat_end_pfn(pgdat);
-
-	if (!pgdat->node_spanned_pages || start_pfn < pgdat->node_start_pfn)
-		pgdat->node_start_pfn = start_pfn;
-
-	pgdat->node_spanned_pages = max(old_pgdat_end_pfn, end_pfn) -
-					pgdat->node_start_pfn;
-}
+	unsigned long i;
 
-static int __meminit __add_zone(struct zone *zone, unsigned long phys_start_pfn)
-{
-	struct pglist_data *pgdat = zone->zone_pgdat;
-	int nr_pages = PAGES_PER_SECTION;
-	int nid = pgdat->node_id;
-	int zone_type;
-	unsigned long flags, pfn;
-	int ret;
+	if (online_type == MMOP_ONLINE_KEEP) {
+		/*
+		 * MMOP_ONLINE_KEEP inherits the current zone which is
+		 * ZONE_NORMAL by default but we might be within ZONE_MOVABLE
+		 * already.
+		 */
+		if (zone_spans_range(&pgdat->node_zones[ZONE_MOVABLE], start_pfn, nr_pages))
+			zone = &pgdat->node_zones[ZONE_MOVABLE];
+	} else if (online_type == MMOP_ONLINE_MOVABLE) {
+		zone = &pgdat->node_zones[ZONE_MOVABLE];
+	}
 
-	zone_type = zone - pgdat->node_zones;
-	ret = ensure_zone_is_initialized(zone, phys_start_pfn, nr_pages);
-	if (ret)
-		return ret;
+	if (zone_is_empty(zone))
+		init_currently_empty_zone(zone, start_pfn, nr_pages);
 
-	pgdat_resize_lock(zone->zone_pgdat, &flags);
-	grow_zone_span(zone, phys_start_pfn, phys_start_pfn + nr_pages);
-	grow_pgdat_span(zone->zone_pgdat, phys_start_pfn,
-			phys_start_pfn + nr_pages);
-	pgdat_resize_unlock(zone->zone_pgdat, &flags);
-	memmap_init_zone(nr_pages, nid, zone_type,
-			 phys_start_pfn, MEMMAP_HOTPLUG);
+	clear_zone_contiguous(zone);
 
-	/* online_page_range is called later and expects pages reserved */
-	for (pfn = phys_start_pfn; pfn < phys_start_pfn + nr_pages; pfn++) {
-		if (!pfn_valid(pfn))
-			continue;
+	/* TODO Huh pgdat is irqsave while zone is not. It used to be like that before */
+	pgdat_resize_lock(pgdat, &flags);
+	zone_span_writelock(zone);
+	resize_zone(zone, start_pfn, nr_pages);
+	zone_span_writeunlock(zone);
+	resize_pgdat(pgdat, start_pfn, nr_pages);
+	pgdat_resize_unlock(pgdat, &flags);
 
-		SetPageReserved(pfn_to_page(pfn));
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
-	return 0;
+
+	set_zone_contiguous(zone);
+	return zone;
 }
 
-static int __meminit __add_section(int nid, struct zone *zone,
-					unsigned long phys_start_pfn)
+static int __meminit __add_section(int nid, unsigned long phys_start_pfn)
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
-
-	if (ret < 0)
-		return ret;
+	/*
+	 * Make all the pages reserved so that nobody will stumble over half
+	 * initialized state.
+	 */
+	for (i = 0; i < PAGES_PER_SECTION; i++)
+		SetPageReserved(pfn_to_page(phys_start_pfn + i));
 
 	return register_new_memory(nid, __pfn_to_section(phys_start_pfn));
 }
@@ -528,7 +397,7 @@ static int __meminit __add_section(int nid, struct zone *zone,
  * call this function after deciding the zone to which to
  * add the new pages.
  */
-int __ref __add_pages(int nid, struct zone *zone, unsigned long phys_start_pfn,
+int __ref __add_pages(int nid, unsigned long phys_start_pfn,
 			unsigned long nr_pages)
 {
 	unsigned long i;
@@ -536,8 +405,6 @@ int __ref __add_pages(int nid, struct zone *zone, unsigned long phys_start_pfn,
 	int start_sec, end_sec;
 	struct vmem_altmap *altmap;
 
-	clear_zone_contiguous(zone);
-
 	/* during initialize mem_map, align hot-added range to section */
 	start_sec = pfn_to_section_nr(phys_start_pfn);
 	end_sec = pfn_to_section_nr(phys_start_pfn + nr_pages - 1);
@@ -557,7 +424,7 @@ int __ref __add_pages(int nid, struct zone *zone, unsigned long phys_start_pfn,
 	}
 
 	for (i = start_sec; i <= end_sec; i++) {
-		err = __add_section(nid, zone, section_nr_to_pfn(i));
+		err = __add_section(nid, section_nr_to_pfn(i));
 
 		/*
 		 * EEXIST is finally dealt with by ioresource collision
@@ -570,7 +437,6 @@ int __ref __add_pages(int nid, struct zone *zone, unsigned long phys_start_pfn,
 	}
 	vmemmap_populate_print_last();
 out:
-	set_zone_contiguous(zone);
 	return err;
 }
 EXPORT_SYMBOL_GPL(__add_pages);
@@ -944,23 +810,6 @@ static int online_pages_range(unsigned long start_pfn, unsigned long nr_pages,
 	return 0;
 }
 
-#ifdef CONFIG_MOVABLE_NODE
-/*
- * When CONFIG_MOVABLE_NODE, we permit onlining of a node which doesn't have
- * normal memory.
- */
-static bool can_online_high_movable(struct zone *zone)
-{
-	return true;
-}
-#else /* CONFIG_MOVABLE_NODE */
-/* ensure every online node has NORMAL memory */
-static bool can_online_high_movable(struct zone *zone)
-{
-	return node_state(zone_to_nid(zone), N_NORMAL_MEMORY);
-}
-#endif /* CONFIG_MOVABLE_NODE */
-
 /* check which state of node_states will be changed when online memory */
 static void node_states_check_changes_online(unsigned long nr_pages,
 	struct zone *zone, struct memory_notify *arg)
@@ -1035,39 +884,28 @@ static void node_states_set_node(int node, struct memory_notify *arg)
 	node_set_state(node, N_MEMORY);
 }
 
-bool zone_can_shift(unsigned long pfn, unsigned long nr_pages,
-		   enum zone_type target, int *zone_shift)
+bool allow_online_pfn_range(int nid, unsigned long pfn, unsigned long nr_pages, int online_type)
 {
-	struct zone *zone = page_zone(pfn_to_page(pfn));
-	enum zone_type idx = zone_idx(zone);
-	int i;
-
-	*zone_shift = 0;
-
-	if (idx < target) {
-		/* pages must be at end of current zone */
-		if (pfn + nr_pages != zone_end_pfn(zone))
-			return false;
+	struct pglist_data *pgdat = NODE_DATA(nid);
+	struct zone *movable_zone = &pgdat->node_zones[ZONE_MOVABLE];
+	struct zone *normal_zone =  &pgdat->node_zones[ZONE_NORMAL];
 
-		/* no zones in use between current zone and target */
-		for (i = idx + 1; i < target; i++)
-			if (zone_is_initialized(zone - idx + i))
-				return false;
-	}
-
-	if (target < idx) {
-		/* pages must be at beginning of current zone */
-		if (pfn != zone->zone_start_pfn)
-			return false;
-
-		/* no zones in use between current zone and target */
-		for (i = target + 1; i < idx; i++)
-			if (zone_is_initialized(zone - idx + i))
-				return false;
+	/*
+	 * TODO there shouldn't be any inherent reason to have ZONE_NORMAL
+	 * physically before ZONE_MOVABLE. All we need is they do not
+	 * overlap. Historically we didn't allow ZONE_NORMAL after ZONE_MOVABLE
+	 * though so let's stick with it for simplicity for now.
+	 */
+	if (online_type == MMOP_ONLINE_KERNEL) {
+		if (!populated_zone(movable_zone))
+			return true;
+		return movable_zone->zone_start_pfn >= pfn + nr_pages;
+	} else if (online_type == MMOP_ONLINE_MOVABLE) {
+		return zone_end_pfn(normal_zone) <= pfn;
 	}
 
-	*zone_shift = target - idx;
-	return true;
+	/* MMOP_ONLINE_KEEP will always succeed and inherits the current zone */
+	return online_type == MMOP_ONLINE_KEEP;
 }
 
 /* Must be protected by mem_hotplug_begin() */
@@ -1080,29 +918,13 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
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
-	    !can_online_high_movable(zone))
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
+	/* assiciate pfn range with the zone */
+	zone = move_pfn_range(online_type, nid, pfn, nr_pages);
 	if (!zone)
 		return -EINVAL;
 
@@ -1110,8 +932,6 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 	arg.nr_pages = nr_pages;
 	node_states_check_changes_online(nr_pages, zone, &arg);
 
-	nid = zone_to_nid(zone);
-
 	ret = memory_notify(MEM_GOING_ONLINE, &arg);
 	ret = notifier_to_errno(ret);
 	if (ret)
@@ -1522,8 +1342,10 @@ int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn,
 	}
 
 	if (zone) {
-		*valid_start = start;
-		*valid_end = min(end, end_pfn);
+		if (valid_start)
+			*valid_start = start;
+		if (valid_end)
+			*valid_end = min(end, end_pfn);
 		return 1;
 	} else {
 		return 0;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5ee8a26fa383..c6127f1a62e9 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -795,7 +795,7 @@ static inline void __free_one_page(struct page *page,
 
 	max_order = min_t(unsigned int, MAX_ORDER, pageblock_order + 1);
 
-	VM_BUG_ON(!zone_is_initialized(zone));
+	VM_BUG_ON(zone_is_empty(zone));
 	VM_BUG_ON_PAGE(page->flags & PAGE_FLAGS_CHECK_AT_PREP, page);
 
 	VM_BUG_ON(migratetype == -1);
@@ -5518,7 +5518,7 @@ static __meminit void zone_pcp_init(struct zone *zone)
 					 zone_batchsize(zone));
 }
 
-int __meminit init_currently_empty_zone(struct zone *zone,
+void __meminit init_currently_empty_zone(struct zone *zone,
 					unsigned long zone_start_pfn,
 					unsigned long size)
 {
@@ -5535,9 +5535,6 @@ int __meminit init_currently_empty_zone(struct zone *zone,
 			zone_start_pfn, (zone_start_pfn + size));
 
 	zone_init_free_lists(zone);
-	zone->initialized = 1;
-
-	return 0;
 }
 
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
@@ -6000,7 +5997,6 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
 {
 	enum zone_type j;
 	int nid = pgdat->node_id;
-	int ret;
 
 	pgdat_resize_init(pgdat);
 #ifdef CONFIG_NUMA_BALANCING
@@ -6082,8 +6078,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
 
 		set_pageblock_order();
 		setup_usemap(pgdat, zone, zone_start_pfn, size);
-		ret = init_currently_empty_zone(zone, zone_start_pfn, size);
-		BUG_ON(ret);
+		init_currently_empty_zone(zone, zone_start_pfn, size);
 		memmap_init(size, nid, j, zone_start_pfn);
 	}
 }
diff --git a/mm/sparse.c b/mm/sparse.c
index db6bf3c97ea2..94072c0d8952 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -689,10 +689,9 @@ static void free_map_bootmem(struct page *memmap)
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
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
