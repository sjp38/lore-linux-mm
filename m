Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 281CE6B006C
	for <linux-mm@kvack.org>; Tue,  6 Nov 2012 14:41:38 -0500 (EST)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Wed, 7 Nov 2012 05:37:55 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qA6JV9rL5505364
	for <linux-mm@kvack.org>; Wed, 7 Nov 2012 06:31:09 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qA6JfVVs017344
	for <linux-mm@kvack.org>; Wed, 7 Nov 2012 06:41:32 +1100
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH 03/10] mm: Init zones inside memory regions
Date: Wed, 07 Nov 2012 01:10:25 +0530
Message-ID: <20121106194014.6560.1012.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20121106193650.6560.71366.stgit@srivatsabhat.in.ibm.com>
References: <20121106193650.6560.71366.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, mjg59@srcf.ucam.org, paulmck@linux.vnet.ibm.com, dave@linux.vnet.ibm.com, maxime.coquelin@stericsson.com, loic.pallardy@stericsson.com, arjan@linux.intel.com, kmpark@infradead.org, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, amit.kachhap@linaro.org, svaidy@linux.vnet.ibm.com, thomas.abraham@linaro.org, santosh.shilimkar@ti.com, srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Ankita Garg <gargankita@gmail.com>

This patch initializes zones inside memory regions. Each memory region is
scanned for the pfns present in it. The intersection of the range with that of
a zone is setup as the amount of memory present in the zone in that region.
Most of the other setup related steps continue to be unmodified.

Signed-off-by: Ankita Garg <gargankita@gmail.com>
Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 include/linux/mm.h |    2 +
 mm/page_alloc.c    |  175 ++++++++++++++++++++++++++++++++++------------------
 2 files changed, 118 insertions(+), 59 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 70f1009..f57eef0 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1320,6 +1320,8 @@ extern unsigned long absent_pages_in_range(unsigned long start_pfn,
 						unsigned long end_pfn);
 extern void get_pfn_range_for_nid(unsigned int nid,
 			unsigned long *start_pfn, unsigned long *end_pfn);
+extern void get_pfn_range_for_region(int nid, int region,
+			unsigned long *start_pfn, unsigned long *end_pfn);
 extern unsigned long find_min_pfn_with_active_regions(void);
 extern void free_bootmem_with_active_regions(int nid,
 						unsigned long max_low_pfn);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index bb90971..c807272 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4321,6 +4321,7 @@ static unsigned long __meminit zone_absent_pages_in_node(int nid,
 }
 
 #else /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
+
 static inline unsigned long __meminit zone_spanned_pages_in_node(int nid,
 					unsigned long zone_type,
 					unsigned long *zones_size)
@@ -4340,6 +4341,48 @@ static inline unsigned long __meminit zone_absent_pages_in_node(int nid,
 
 #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
 
+void __meminit get_pfn_range_for_region(int nid, int region,
+			unsigned long *start_pfn, unsigned long *end_pfn)
+{
+	struct mem_region *mem_region;
+
+	mem_region = &NODE_DATA(nid)->node_regions[region];
+	*start_pfn = mem_region->start_pfn;
+	*end_pfn = *start_pfn + mem_region->spanned_pages;
+}
+
+static inline unsigned long __meminit zone_spanned_pages_in_node_region(int nid,
+					int region,
+					unsigned long zone_start_pfn,
+					unsigned long zone_type,
+					unsigned long *zones_size)
+{
+	unsigned long start_pfn, end_pfn;
+	unsigned long zone_end_pfn, spanned_pages;
+
+	get_pfn_range_for_region(nid, region, &start_pfn, &end_pfn);
+
+	spanned_pages = zone_spanned_pages_in_node(nid, zone_type, zones_size);
+
+	zone_end_pfn = zone_start_pfn + spanned_pages;
+
+	zone_end_pfn = min(zone_end_pfn, end_pfn);
+	zone_start_pfn = max(start_pfn, zone_start_pfn);
+
+	/* Detect if region and zone don't intersect */
+	if (zone_end_pfn < zone_start_pfn)
+		return 0;
+
+	return zone_end_pfn - zone_start_pfn;
+}
+
+static inline unsigned long __meminit zone_absent_pages_in_node_region(int nid,
+					unsigned long zone_start_pfn,
+					unsigned long zone_end_pfn)
+{
+	return __absent_pages_in_range(nid, zone_start_pfn, zone_end_pfn);
+}
+
 static void __meminit calculate_node_totalpages(struct pglist_data *pgdat,
 		unsigned long *zones_size, unsigned long *zholes_size)
 {
@@ -4446,6 +4489,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 	enum zone_type j;
 	int nid = pgdat->node_id;
 	unsigned long zone_start_pfn = pgdat->node_start_pfn;
+	struct mem_region *region;
 	int ret;
 
 	pgdat_resize_init(pgdat);
@@ -4454,68 +4498,77 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 	pgdat_page_cgroup_init(pgdat);
 
 	for (j = 0; j < MAX_NR_ZONES; j++) {
-		struct zone *zone = pgdat->node_zones + j;
-		unsigned long size, realsize, memmap_pages;
+		for_each_mem_region_in_node(region, pgdat->node_id) {
+			struct zone *zone = region->region_zones + j;
+			unsigned long size, realsize = 0, memmap_pages;
 
-		size = zone_spanned_pages_in_node(nid, j, zones_size);
-		realsize = size - zone_absent_pages_in_node(nid, j,
-								zholes_size);
+			size = zone_spanned_pages_in_node_region(nid,
+								 region->region,
+								 zone_start_pfn,
+								 j, zones_size);
 
-		/*
-		 * Adjust realsize so that it accounts for how much memory
-		 * is used by this zone for memmap. This affects the watermark
-		 * and per-cpu initialisations
-		 */
-		memmap_pages =
-			PAGE_ALIGN(size * sizeof(struct page)) >> PAGE_SHIFT;
-		if (realsize >= memmap_pages) {
-			realsize -= memmap_pages;
-			if (memmap_pages)
-				printk(KERN_DEBUG
-				       "  %s zone: %lu pages used for memmap\n",
-				       zone_names[j], memmap_pages);
-		} else
-			printk(KERN_WARNING
-				"  %s zone: %lu pages exceeds realsize %lu\n",
-				zone_names[j], memmap_pages, realsize);
-
-		/* Account for reserved pages */
-		if (j == 0 && realsize > dma_reserve) {
-			realsize -= dma_reserve;
-			printk(KERN_DEBUG "  %s zone: %lu pages reserved\n",
-					zone_names[0], dma_reserve);
-		}
+			realsize = size -
+					zone_absent_pages_in_node_region(nid,
+								zone_start_pfn,
+								zone_start_pfn + size);
 
-		if (!is_highmem_idx(j))
-			nr_kernel_pages += realsize;
-		nr_all_pages += realsize;
+			/*
+			 * Adjust realsize so that it accounts for how much memory
+			 * is used by this zone for memmap. This affects the watermark
+			 * and per-cpu initialisations
+			 */
+			memmap_pages =
+				PAGE_ALIGN(size * sizeof(struct page)) >> PAGE_SHIFT;
+			if (realsize >= memmap_pages) {
+				realsize -= memmap_pages;
+				if (memmap_pages)
+					printk(KERN_DEBUG
+					       "  %s zone: %lu pages used for memmap\n",
+					       zone_names[j], memmap_pages);
+			} else
+				printk(KERN_WARNING
+					"  %s zone: %lu pages exceeds realsize %lu\n",
+					zone_names[j], memmap_pages, realsize);
+
+			/* Account for reserved pages */
+			if (j == 0 && realsize > dma_reserve) {
+				realsize -= dma_reserve;
+				printk(KERN_DEBUG "  %s zone: %lu pages reserved\n",
+						zone_names[0], dma_reserve);
+			}
 
-		zone->spanned_pages = size;
-		zone->present_pages = realsize;
+			if (!is_highmem_idx(j))
+				nr_kernel_pages += realsize;
+			nr_all_pages += realsize;
+
+			zone->spanned_pages = size;
+			zone->present_pages = realsize;
 #ifdef CONFIG_NUMA
-		zone->node = nid;
-		zone->min_unmapped_pages = (realsize*sysctl_min_unmapped_ratio)
-						/ 100;
-		zone->min_slab_pages = (realsize * sysctl_min_slab_ratio) / 100;
+			zone->node = nid;
+			zone->min_unmapped_pages = (realsize*sysctl_min_unmapped_ratio)
+							/ 100;
+			zone->min_slab_pages = (realsize * sysctl_min_slab_ratio) / 100;
 #endif
-		zone->name = zone_names[j];
-		spin_lock_init(&zone->lock);
-		spin_lock_init(&zone->lru_lock);
-		zone_seqlock_init(zone);
-		zone->zone_pgdat = pgdat;
-
-		zone_pcp_init(zone);
-		lruvec_init(&zone->lruvec, zone);
-		if (!size)
-			continue;
+			zone->name = zone_names[j];
+			spin_lock_init(&zone->lock);
+			spin_lock_init(&zone->lru_lock);
+			zone_seqlock_init(zone);
+			zone->zone_pgdat = pgdat;
+			zone->zone_mem_region = region;
+
+			zone_pcp_init(zone);
+			lruvec_init(&zone->lruvec, zone);
+			if (!size)
+				continue;
 
-		set_pageblock_order();
-		setup_usemap(pgdat, zone, size);
-		ret = init_currently_empty_zone(zone, zone_start_pfn,
-						size, MEMMAP_EARLY);
-		BUG_ON(ret);
-		memmap_init(size, nid, j, zone_start_pfn);
-		zone_start_pfn += size;
+			set_pageblock_order();
+			setup_usemap(pgdat, zone, size);
+			ret = init_currently_empty_zone(zone, zone_start_pfn,
+							size, MEMMAP_EARLY);
+			BUG_ON(ret);
+			memmap_init(size, nid, j, zone_start_pfn);
+			zone_start_pfn += size;
+		}
 	}
 }
 
@@ -4854,12 +4907,16 @@ static void __init check_for_regular_memory(pg_data_t *pgdat)
 {
 #ifdef CONFIG_HIGHMEM
 	enum zone_type zone_type;
+	struct mem_region *region;
 
 	for (zone_type = 0; zone_type <= ZONE_NORMAL; zone_type++) {
-		struct zone *zone = &pgdat->node_zones[zone_type];
-		if (zone->present_pages) {
-			node_set_state(zone_to_nid(zone), N_NORMAL_MEMORY);
-			break;
+		for_each_mem_region_in_node(region, pgdat->node_id) {
+			struct zone *zone = &region->region_zones[zone_type];
+			if (zone->present_pages) {
+				node_set_state(zone_to_nid(zone),
+					       N_NORMAL_MEMORY);
+				return;
+			}
 		}
 	}
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
