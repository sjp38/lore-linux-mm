Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1F6572806D7
	for <linux-mm@kvack.org>; Thu, 30 Mar 2017 07:55:10 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id y77so9780236wrb.22
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 04:55:10 -0700 (PDT)
Received: from mail-wr0-f196.google.com (mail-wr0-f196.google.com. [209.85.128.196])
        by mx.google.com with ESMTPS id j197si11777054wmf.118.2017.03.30.04.55.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Mar 2017 04:55:08 -0700 (PDT)
Received: by mail-wr0-f196.google.com with SMTP id w43so11412114wrb.1
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 04:55:08 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 6/6] mm, memory_hotplug: remove unused cruft after memory hotplug rework
Date: Thu, 30 Mar 2017 13:54:54 +0200
Message-Id: <20170330115454.32154-7-mhocko@kernel.org>
In-Reply-To: <20170330115454.32154-1-mhocko@kernel.org>
References: <20170330115454.32154-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, Zhang Zhen <zhenzhang.zhang@huawei.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

arch_add_memory doesn't need for_device parameter anymore because
devm_memremap_pages already does all what it needs to.

zone_for_memory doesn't have any user anymore as well as the whole zone
shifting infrastructure so drop them as well.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 arch/ia64/mm/init.c            |   2 +-
 arch/powerpc/mm/mem.c          |   2 +-
 arch/s390/mm/init.c            |   2 +-
 arch/sh/mm/init.c              |   3 +-
 arch/x86/mm/init_32.c          |   2 +-
 arch/x86/mm/init_64.c          |   2 +-
 include/linux/memory_hotplug.h |   4 +-
 kernel/memremap.c              |   2 +-
 mm/memory_hotplug.c            | 209 +----------------------------------------
 9 files changed, 9 insertions(+), 219 deletions(-)

diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index 0fb7f3946785..6ebb570f1eae 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -645,7 +645,7 @@ mem_init (void)
 }
 
 #ifdef CONFIG_MEMORY_HOTPLUG
-int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
+int arch_add_memory(int nid, u64 start, u64 size)
 {
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
index db1369a7f69f..707a4146938b 100644
--- a/arch/powerpc/mm/mem.c
+++ b/arch/powerpc/mm/mem.c
@@ -126,7 +126,7 @@ int __weak remove_section_mapping(unsigned long start, unsigned long end)
 	return -ENODEV;
 }
 
-int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
+int arch_add_memory(int nid, u64 start, u64 size)
 {
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
index 9e8c515ee29f..7d7591b63b57 100644
--- a/arch/s390/mm/init.c
+++ b/arch/s390/mm/init.c
@@ -153,7 +153,7 @@ void __init free_initrd_mem(unsigned long start, unsigned long end)
 #endif
 
 #ifdef CONFIG_MEMORY_HOTPLUG
-int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
+int arch_add_memory(int nid, u64 start, u64 size)
 {
 	unsigned long start_pfn = PFN_DOWN(start);
 	unsigned long size_pages = PFN_DOWN(size);
diff --git a/arch/sh/mm/init.c b/arch/sh/mm/init.c
index 95261b66bcf3..4e4afa0ab3c3 100644
--- a/arch/sh/mm/init.c
+++ b/arch/sh/mm/init.c
@@ -485,13 +485,12 @@ void free_initrd_mem(unsigned long start, unsigned long end)
 #endif
 
 #ifdef CONFIG_MEMORY_HOTPLUG
-int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
+int arch_add_memory(int nid, u64 start, u64 size)
 {
 	unsigned long start_pfn = PFN_DOWN(start);
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 	int ret;
 
-
 	/* We only have ZONE_NORMAL, so this is easy.. */
 	ret = __add_pages(nid, start_pfn, nr_pages);
 	if (unlikely(ret))
diff --git a/arch/x86/mm/init_32.c b/arch/x86/mm/init_32.c
index 5de79aa7d6ce..b389f2ec75f9 100644
--- a/arch/x86/mm/init_32.c
+++ b/arch/x86/mm/init_32.c
@@ -816,7 +816,7 @@ void __init mem_init(void)
 }
 
 #ifdef CONFIG_MEMORY_HOTPLUG
-int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
+int arch_add_memory(int nid, u64 start, u64 size)
 {
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index bc53f24e6703..20f575333b08 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -637,7 +637,7 @@ static void  update_end_of_memory_vars(u64 start, u64 size)
 	}
 }
 
-int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
+int arch_add_memory(int nid, u64 start, u64 size)
 {
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 63577ce57028..d5adb7c468d1 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -274,9 +274,7 @@ extern int walk_memory_range(unsigned long start_pfn, unsigned long end_pfn,
 		void *arg, int (*func)(struct memory_block *, void *));
 extern int add_memory(int nid, u64 start, u64 size);
 extern int add_memory_resource(int nid, struct resource *resource, bool online);
-extern int zone_for_memory(int nid, u64 start, u64 size, int zone_default,
-		bool for_device);
-extern int arch_add_memory(int nid, u64 start, u64 size, bool for_device);
+extern int arch_add_memory(int nid, u64 start, u64 size);
 extern void move_pfn_range_to_zone(struct zone *zone, unsigned long start_pfn,
 		unsigned long nr_pages);
 extern int offline_pages(unsigned long start_pfn, unsigned long nr_pages);
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 1b137649cb82..808f7974918a 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -366,7 +366,7 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 
 	lock_device_hotplug();
 	mem_hotplug_begin();
-	error = arch_add_memory(nid, align_start, align_size, true);
+	error = arch_add_memory(nid, align_start, align_size);
 	if (!error)
 		move_pfn_range_to_zone(&NODE_DATA(nid)->node_zones[ZONE_DEVICE],
 				align_start, align_size);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index d7efa0191bb7..b9dc1c4e26c3 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -295,180 +295,6 @@ void __init register_page_bootmem_info_node(struct pglist_data *pgdat)
 }
 #endif /* CONFIG_HAVE_BOOTMEM_INFO_NODE */
 
-static void __meminit grow_zone_span(struct zone *zone, unsigned long start_pfn,
-				     unsigned long end_pfn)
-{
-	unsigned long old_zone_end_pfn;
-
-	zone_span_writelock(zone);
-
-	old_zone_end_pfn = zone_end_pfn(zone);
-	if (zone_is_empty(zone) || start_pfn < zone->zone_start_pfn)
-		zone->zone_start_pfn = start_pfn;
-
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
-}
-
-static void __ref ensure_zone_is_initialized(struct zone *zone,
-			unsigned long start_pfn, unsigned long num_pages)
-{
-	if (!zone_is_empty(zone))
-		init_currently_empty_zone(zone, start_pfn, num_pages);
-}
-
-static int __meminit move_pfn_range_left(struct zone *z1, struct zone *z2,
-		unsigned long start_pfn, unsigned long end_pfn)
-{
-	unsigned long flags;
-	unsigned long z1_start_pfn;
-
-	ensure_zone_is_initialized(z1, start_pfn, end_pfn - start_pfn);
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
-
-	return 0;
-out_fail:
-	pgdat_resize_unlock(z1->zone_pgdat, &flags);
-	return -1;
-}
-
-static int __meminit move_pfn_range_right(struct zone *z1, struct zone *z2,
-		unsigned long start_pfn, unsigned long end_pfn)
-{
-	unsigned long flags;
-	unsigned long z2_end_pfn;
-
-	ensure_zone_is_initialized(z2, start_pfn, end_pfn - start_pfn);
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
-
-static int __meminit __add_zone(struct zone *zone, unsigned long phys_start_pfn)
-{
-	struct pglist_data *pgdat = zone->zone_pgdat;
-	int nr_pages = PAGES_PER_SECTION;
-	int nid = pgdat->node_id;
-	int zone_type;
-	unsigned long flags, pfn;
-
-	zone_type = zone - pgdat->node_zones;
-	ensure_zone_is_initialized(zone, phys_start_pfn, nr_pages);
-
-	pgdat_resize_lock(zone->zone_pgdat, &flags);
-	grow_zone_span(zone, phys_start_pfn, phys_start_pfn + nr_pages);
-	grow_pgdat_span(zone->zone_pgdat, phys_start_pfn,
-			phys_start_pfn + nr_pages);
-	pgdat_resize_unlock(zone->zone_pgdat, &flags);
-	memmap_init_zone(nr_pages, nid, zone_type,
-			 phys_start_pfn, MEMMAP_HOTPLUG);
-
-	/* online_page_range is called later and expects pages reserved */
-	for (pfn = phys_start_pfn; pfn < phys_start_pfn + nr_pages; pfn++) {
-		if (!pfn_valid(pfn))
-			continue;
-
-		SetPageReserved(pfn_to_page(pfn));
-	}
-	return 0;
-}
-
 static int __meminit __add_section(int nid, unsigned long phys_start_pfn)
 {
 	int ret;
@@ -1332,39 +1158,6 @@ static int check_hotplug_memory_range(u64 start, u64 size)
 	return 0;
 }
 
-/*
- * If movable zone has already been setup, newly added memory should be check.
- * If its address is higher than movable zone, it should be added as movable.
- * Without this check, movable zone may overlap with other zone.
- */
-static int should_add_memory_movable(int nid, u64 start, u64 size)
-{
-	unsigned long start_pfn = start >> PAGE_SHIFT;
-	pg_data_t *pgdat = NODE_DATA(nid);
-	struct zone *movable_zone = pgdat->node_zones + ZONE_MOVABLE;
-
-	if (zone_is_empty(movable_zone))
-		return 0;
-
-	if (movable_zone->zone_start_pfn <= start_pfn)
-		return 1;
-
-	return 0;
-}
-
-int zone_for_memory(int nid, u64 start, u64 size, int zone_default,
-		bool for_device)
-{
-#ifdef CONFIG_ZONE_DEVICE
-	if (for_device)
-		return ZONE_DEVICE;
-#endif
-	if (should_add_memory_movable(nid, start, size))
-		return ZONE_MOVABLE;
-
-	return zone_default;
-}
-
 static int online_memory_block(struct memory_block *mem, void *arg)
 {
 	return device_online(&mem->dev);
@@ -1410,7 +1203,7 @@ int __ref add_memory_resource(int nid, struct resource *res, bool online)
 	}
 
 	/* call arch's memory hotadd */
-	ret = arch_add_memory(nid, start, size, false);
+	ret = arch_add_memory(nid, start, size);
 
 	if (ret < 0)
 		goto error;
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
