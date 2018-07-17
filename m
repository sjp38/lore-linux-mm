Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9F4B26B0010
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 06:56:56 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id q18-v6so261803wrr.12
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 03:56:56 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h45-v6sor345303wrh.8.2018.07.17.03.56.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 17 Jul 2018 03:56:55 -0700 (PDT)
From: osalvador@techadventures.net
Subject: [RFC PATCH 3/3] mm: Make free_area_init_node call certain functions only when booting
Date: Tue, 17 Jul 2018 12:56:22 +0200
Message-Id: <20180717105622.12410-4-osalvador@techadventures.net>
In-Reply-To: <20180717105622.12410-1-osalvador@techadventures.net>
References: <20180717105622.12410-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: pasha.tatashin@oracle.com, mhocko@suse.com, vbabka@suse.cz, akpm@linux-foundation.org, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

From: Oscar Salvador <osalvador@suse.de>

If free_area_init_node got called from memhotplug code, we do not need
to call calculate_node_totalpages(), as the node has no pages.

We do not need to set the range for the deferred initialization either,
as memmap_init_zone skips that when the context is MEMMAP_HOTPLUG.

Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 mm/page_alloc.c | 37 ++++++++++++++++++++++---------------
 1 file changed, 22 insertions(+), 15 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3bf939393ca1..d2562751dbfd 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6299,8 +6299,6 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
 	spin_lock_init(&pgdat->lru_lock);
 	lruvec_init(node_lruvec(pgdat));
 
-	pgdat->per_cpu_nodestats = &boot_nodestats;
-
 	for (j = 0; j < MAX_NR_ZONES; j++) {
 		struct zone *zone = pgdat->node_zones + j;
 
@@ -6386,6 +6384,21 @@ static void __ref alloc_node_mem_map(struct pglist_data *pgdat)
 static void __ref alloc_node_mem_map(struct pglist_data *pgdat) { }
 #endif /* CONFIG_FLAT_NODE_MEM_MAP */
 
+#ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
+static void pgdat_set_deferred_range(pg_data_t *pgdat)
+{
+	/*
+	 * We start only with one section of pages, more pages are added as
+	 * needed until the rest of deferred pages are initialized.
+	 */
+	pgdat->static_init_pgcnt = min_t(unsigned long, PAGES_PER_SECTION,
+						pgdat->node_spanned_pages);
+	pgdat->first_deferred_pfn = ULONG_MAX;
+}
+#else
+static void pgdat_set_deferred_range(pg_data_t *pgdat) {}
+#endif
+
 void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
 		unsigned long node_start_pfn, unsigned long *zholes_size)
 {
@@ -6407,20 +6420,14 @@ void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
 #else
 	start_pfn = node_start_pfn;
 #endif
-	calculate_node_totalpages(pgdat, start_pfn, end_pfn,
-				  zones_size, zholes_size);
-
-	alloc_node_mem_map(pgdat);
+	if (system_state == SYSTEM_BOOTING) {
+		calculate_node_totalpages(pgdat, start_pfn, end_pfn,
+					  zones_size, zholes_size);
+		alloc_node_mem_map(pgdat);
+		pgdat_set_deferred_range(pgdat);
+		pgdat->per_cpu_nodestats = &boot_nodestats;
+	}
 
-#ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
-	/*
-	 * We start only with one section of pages, more pages are added as
-	 * needed until the rest of deferred pages are initialized.
-	 */
-	pgdat->static_init_pgcnt = min_t(unsigned long, PAGES_PER_SECTION,
-					 pgdat->node_spanned_pages);
-	pgdat->first_deferred_pfn = ULONG_MAX;
-#endif
 	free_area_init_core(pgdat);
 }
 
-- 
2.13.6
