Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id D5F576B02FC
	for <linux-mm@kvack.org>; Fri, 26 Oct 2018 07:01:30 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id k25-v6so437112pff.15
        for <linux-mm@kvack.org>; Fri, 26 Oct 2018 04:01:30 -0700 (PDT)
Received: from alexa-out-blr-01.qualcomm.com (alexa-out-blr-01.qualcomm.com. [103.229.18.197])
        by mx.google.com with ESMTPS id g9-v6si7269096pgp.488.2018.10.26.04.01.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Oct 2018 04:01:29 -0700 (PDT)
From: Arun KS <arunks@codeaurora.org>
Subject: [PATCH v1 2/4] mm: Convert zone->managed_pages to atomic variable
Date: Fri, 26 Oct 2018 16:31:00 +0530
Message-Id: <1540551662-26458-3-git-send-email-arunks@codeaurora.org>
In-Reply-To: <1540551662-26458-1-git-send-email-arunks@codeaurora.org>
References: <1540551662-26458-1-git-send-email-arunks@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: keescook@chromium.org, khlebnikov@yandex-team.ru, minchan@kernel.org, getarunks@gmail.com, gregkh@linuxfoundation.org, akpm@linux-foundation.org, mhocko@kernel.org, vbabka@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Arun KS <arunks@codeaurora.org>

managed_page_count_lock will be removed in subsequent patch after
totalram_pages and totalhigh_pages are converted to atomic.

Suggested-by: Michal Hocko <mhocko@suse.com>
Suggested-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Arun KS <arunks@codeaurora.org>

---
Most of the changes are done by below coccinelle script,

@@
struct zone *z;
expression e1;
@@
(
- z->managed_pages = e1
+ atomic_long_set(&z->managed_pages, e1)
|
- e1->managed_pages++
+ atomic_long_inc(&e1->managed_pages)
|
- z->managed_pages
+ zone_managed_pages(z)
)

@@
expression e,e1;
@@
- e->managed_pages += e1
+ atomic_long_add(e1, &e->managed_pages)

@@
expression z;
@@
- z.managed_pages
+ zone_managed_pages(&z)

Then, manually apply following change,
include/linux/mmzone.h

- unsigned long managed_pages;
+ atomic_long_t managed_pages;

+static inline unsigned long zone_managed_pages(struct zone *zone)
+{
+       return (unsigned long)atomic_long_read(&zone->managed_pages);
+}

---
 drivers/gpu/drm/amd/amdkfd/kfd_crat.c |  2 +-
 include/linux/mmzone.h                |  9 +++++--
 lib/show_mem.c                        |  2 +-
 mm/memblock.c                         |  2 +-
 mm/page_alloc.c                       | 44 +++++++++++++++++------------------
 mm/vmstat.c                           |  4 ++--
 6 files changed, 34 insertions(+), 29 deletions(-)

diff --git a/drivers/gpu/drm/amd/amdkfd/kfd_crat.c b/drivers/gpu/drm/amd/amdkfd/kfd_crat.c
index 56412b0..c0e55bb 100644
--- a/drivers/gpu/drm/amd/amdkfd/kfd_crat.c
+++ b/drivers/gpu/drm/amd/amdkfd/kfd_crat.c
@@ -848,7 +848,7 @@ static int kfd_fill_mem_info_for_cpu(int numa_node_id, int *avail_size,
 	 */
 	pgdat = NODE_DATA(numa_node_id);
 	for (zone_type = 0; zone_type < MAX_NR_ZONES; zone_type++)
-		mem_in_bytes += pgdat->node_zones[zone_type].managed_pages;
+		mem_in_bytes += zone_managed_pages(&pgdat->node_zones[zone_type]);
 	mem_in_bytes <<= PAGE_SHIFT;
 
 	sub_type_hdr->length_low = lower_32_bits(mem_in_bytes);
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 8555509..597b0c7 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -435,7 +435,7 @@ struct zone {
 	 * adjust_managed_page_count() should be used instead of directly
 	 * touching zone->managed_pages and totalram_pages.
 	 */
-	unsigned long		managed_pages;
+	atomic_long_t		managed_pages;
 	unsigned long		spanned_pages;
 	unsigned long		present_pages;
 
@@ -524,6 +524,11 @@ enum pgdat_flags {
 	PGDAT_RECLAIM_LOCKED,		/* prevents concurrent reclaim */
 };
 
+static inline unsigned long zone_managed_pages(struct zone *zone)
+{
+	return (unsigned long)atomic_long_read(&zone->managed_pages);
+}
+
 static inline unsigned long zone_end_pfn(const struct zone *zone)
 {
 	return zone->zone_start_pfn + zone->spanned_pages;
@@ -814,7 +819,7 @@ static inline bool is_dev_zone(const struct zone *zone)
  */
 static inline bool managed_zone(struct zone *zone)
 {
-	return zone->managed_pages;
+	return zone_managed_pages(zone);
 }
 
 /* Returns true if a zone has memory */
diff --git a/lib/show_mem.c b/lib/show_mem.c
index 0beaa1d..eefe67d 100644
--- a/lib/show_mem.c
+++ b/lib/show_mem.c
@@ -28,7 +28,7 @@ void show_mem(unsigned int filter, nodemask_t *nodemask)
 				continue;
 
 			total += zone->present_pages;
-			reserved += zone->present_pages - zone->managed_pages;
+			reserved += zone->present_pages - zone_managed_pages(zone);
 
 			if (is_highmem_idx(zoneid))
 				highmem += zone->present_pages;
diff --git a/mm/memblock.c b/mm/memblock.c
index eddcac2..14a6219 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -2001,7 +2001,7 @@ void reset_node_managed_pages(pg_data_t *pgdat)
 	struct zone *z;
 
 	for (z = pgdat->node_zones; z < pgdat->node_zones + MAX_NR_ZONES; z++)
-		z->managed_pages = 0;
+		atomic_long_set(&z->managed_pages, 0);
 }
 
 void __init reset_all_zones_managed_pages(void)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f045191..f077849 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1275,7 +1275,7 @@ void __free_pages_core(struct page *page, unsigned int order)
 		set_page_count(p, 0);
 	}
 
-	page_zone(page)->managed_pages += nr_pages;
+	atomic_long_add(nr_pages, &page_zone(page)->managed_pages);
 	set_page_refcounted(page);
 	__free_pages(page, order);
 }
@@ -2254,7 +2254,7 @@ static void reserve_highatomic_pageblock(struct page *page, struct zone *zone,
 	 * Limit the number reserved to 1 pageblock or roughly 1% of a zone.
 	 * Check is race-prone but harmless.
 	 */
-	max_managed = (zone->managed_pages / 100) + pageblock_nr_pages;
+	max_managed = (zone_managed_pages(zone) / 100) + pageblock_nr_pages;
 	if (zone->nr_reserved_highatomic >= max_managed)
 		return;
 
@@ -4658,7 +4658,7 @@ static unsigned long nr_free_zone_pages(int offset)
 	struct zonelist *zonelist = node_zonelist(numa_node_id(), GFP_KERNEL);
 
 	for_each_zone_zonelist(zone, z, zonelist, offset) {
-		unsigned long size = zone->managed_pages;
+		unsigned long size = zone_managed_pages(zone);
 		unsigned long high = high_wmark_pages(zone);
 		if (size > high)
 			sum += size - high;
@@ -4765,7 +4765,7 @@ void si_meminfo_node(struct sysinfo *val, int nid)
 	pg_data_t *pgdat = NODE_DATA(nid);
 
 	for (zone_type = 0; zone_type < MAX_NR_ZONES; zone_type++)
-		managed_pages += pgdat->node_zones[zone_type].managed_pages;
+		managed_pages += zone_managed_pages(&pgdat->node_zones[zone_type]);
 	val->totalram = managed_pages;
 	val->sharedram = node_page_state(pgdat, NR_SHMEM);
 	val->freeram = sum_zone_node_page_state(nid, NR_FREE_PAGES);
@@ -4774,7 +4774,7 @@ void si_meminfo_node(struct sysinfo *val, int nid)
 		struct zone *zone = &pgdat->node_zones[zone_type];
 
 		if (is_highmem(zone)) {
-			managed_highpages += zone->managed_pages;
+			managed_highpages += zone_managed_pages(zone);
 			free_highpages += zone_page_state(zone, NR_FREE_PAGES);
 		}
 	}
@@ -4981,7 +4981,7 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
 			K(zone_page_state(zone, NR_ZONE_UNEVICTABLE)),
 			K(zone_page_state(zone, NR_ZONE_WRITE_PENDING)),
 			K(zone->present_pages),
-			K(zone->managed_pages),
+			K(zone_managed_pages(zone)),
 			K(zone_page_state(zone, NR_MLOCK)),
 			zone_page_state(zone, NR_KERNEL_STACK_KB),
 			K(zone_page_state(zone, NR_PAGETABLE)),
@@ -5643,7 +5643,7 @@ static int zone_batchsize(struct zone *zone)
 	 * The per-cpu-pages pools are set to around 1000th of the
 	 * size of the zone.
 	 */
-	batch = zone->managed_pages / 1024;
+	batch = zone_managed_pages(zone) / 1024;
 	/* But no more than a meg. */
 	if (batch * PAGE_SIZE > 1024 * 1024)
 		batch = (1024 * 1024) / PAGE_SIZE;
@@ -5754,7 +5754,7 @@ static void pageset_set_high_and_batch(struct zone *zone,
 {
 	if (percpu_pagelist_fraction)
 		pageset_set_high(pcp,
-			(zone->managed_pages /
+			(zone_managed_pages(zone) /
 				percpu_pagelist_fraction));
 	else
 		pageset_set_batch(pcp, zone_batchsize(zone));
@@ -6309,7 +6309,7 @@ static void __meminit pgdat_init_internals(struct pglist_data *pgdat)
 static void __meminit zone_init_internals(struct zone *zone, enum zone_type idx, int nid,
 							unsigned long remaining_pages)
 {
-	zone->managed_pages = remaining_pages;
+	atomic_long_set(&zone->managed_pages, remaining_pages);
 	zone_set_nid(zone, nid);
 	zone->name = zone_names[idx];
 	zone->zone_pgdat = NODE_DATA(nid);
@@ -7062,7 +7062,7 @@ static int __init cmdline_parse_movablecore(char *p)
 void adjust_managed_page_count(struct page *page, long count)
 {
 	spin_lock(&managed_page_count_lock);
-	page_zone(page)->managed_pages += count;
+	atomic_long_add(count, &page_zone(page)->managed_pages);
 	totalram_pages += count;
 #ifdef CONFIG_HIGHMEM
 	if (PageHighMem(page))
@@ -7110,7 +7110,7 @@ void free_highmem_page(struct page *page)
 {
 	__free_reserved_page(page);
 	totalram_pages++;
-	page_zone(page)->managed_pages++;
+	atomic_long_inc(&page_zone(page)->managed_pages);
 	totalhigh_pages++;
 }
 #endif
@@ -7243,7 +7243,7 @@ static void calculate_totalreserve_pages(void)
 		for (i = 0; i < MAX_NR_ZONES; i++) {
 			struct zone *zone = pgdat->node_zones + i;
 			long max = 0;
-			unsigned long managed_pages = zone->managed_pages;
+			unsigned long managed_pages = zone_managed_pages(zone);
 
 			/* Find valid and maximum lowmem_reserve in the zone */
 			for (j = i; j < MAX_NR_ZONES; j++) {
@@ -7279,7 +7279,7 @@ static void setup_per_zone_lowmem_reserve(void)
 	for_each_online_pgdat(pgdat) {
 		for (j = 0; j < MAX_NR_ZONES; j++) {
 			struct zone *zone = pgdat->node_zones + j;
-			unsigned long managed_pages = zone->managed_pages;
+			unsigned long managed_pages = zone_managed_pages(zone);
 
 			zone->lowmem_reserve[j] = 0;
 
@@ -7297,7 +7297,7 @@ static void setup_per_zone_lowmem_reserve(void)
 					lower_zone->lowmem_reserve[j] =
 						managed_pages / sysctl_lowmem_reserve_ratio[idx];
 				}
-				managed_pages += lower_zone->managed_pages;
+				managed_pages += zone_managed_pages(lower_zone);
 			}
 		}
 	}
@@ -7316,14 +7316,14 @@ static void __setup_per_zone_wmarks(void)
 	/* Calculate total number of !ZONE_HIGHMEM pages */
 	for_each_zone(zone) {
 		if (!is_highmem(zone))
-			lowmem_pages += zone->managed_pages;
+			lowmem_pages += zone_managed_pages(zone);
 	}
 
 	for_each_zone(zone) {
 		u64 tmp;
 
 		spin_lock_irqsave(&zone->lock, flags);
-		tmp = (u64)pages_min * zone->managed_pages;
+		tmp = (u64)pages_min * zone_managed_pages(zone);
 		do_div(tmp, lowmem_pages);
 		if (is_highmem(zone)) {
 			/*
@@ -7337,7 +7337,7 @@ static void __setup_per_zone_wmarks(void)
 			 */
 			unsigned long min_pages;
 
-			min_pages = zone->managed_pages / 1024;
+			min_pages = zone_managed_pages(zone) / 1024;
 			min_pages = clamp(min_pages, SWAP_CLUSTER_MAX, 128UL);
 			zone->watermark[WMARK_MIN] = min_pages;
 		} else {
@@ -7354,7 +7354,7 @@ static void __setup_per_zone_wmarks(void)
 		 * ensure a minimum size on small systems.
 		 */
 		tmp = max_t(u64, tmp >> 2,
-			    mult_frac(zone->managed_pages,
+			    mult_frac(zone_managed_pages(zone),
 				      watermark_scale_factor, 10000));
 
 		zone->watermark[WMARK_LOW]  = min_wmark_pages(zone) + tmp;
@@ -7484,8 +7484,8 @@ static void setup_min_unmapped_ratio(void)
 		pgdat->min_unmapped_pages = 0;
 
 	for_each_zone(zone)
-		zone->zone_pgdat->min_unmapped_pages += (zone->managed_pages *
-				sysctl_min_unmapped_ratio) / 100;
+		zone->zone_pgdat->min_unmapped_pages += (zone_managed_pages(zone) *
+						         sysctl_min_unmapped_ratio) / 100;
 }
 
 
@@ -7512,8 +7512,8 @@ static void setup_min_slab_ratio(void)
 		pgdat->min_slab_pages = 0;
 
 	for_each_zone(zone)
-		zone->zone_pgdat->min_slab_pages += (zone->managed_pages *
-				sysctl_min_slab_ratio) / 100;
+		zone->zone_pgdat->min_slab_pages += (zone_managed_pages(zone) *
+						     sysctl_min_slab_ratio) / 100;
 }
 
 int sysctl_min_slab_ratio_sysctl_handler(struct ctl_table *table, int write,
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 6038ce5..9fee037 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -227,7 +227,7 @@ int calculate_normal_threshold(struct zone *zone)
 	 * 125		1024		10	16-32 GB	9
 	 */
 
-	mem = zone->managed_pages >> (27 - PAGE_SHIFT);
+	mem = zone_managed_pages(zone) >> (27 - PAGE_SHIFT);
 
 	threshold = 2 * fls(num_online_cpus()) * (1 + fls(mem));
 
@@ -1569,7 +1569,7 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
 		   high_wmark_pages(zone),
 		   zone->spanned_pages,
 		   zone->present_pages,
-		   zone->managed_pages);
+		   zone_managed_pages(zone));
 
 	seq_printf(m,
 		   "\n        protection: (%ld",
-- 
1.9.1
