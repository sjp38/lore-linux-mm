Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8F6746B000D
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 08:47:40 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id h18-v6so1007929wmb.8
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 05:47:40 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u4-v6sor1619017wrt.37.2018.07.18.05.47.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 18 Jul 2018 05:47:39 -0700 (PDT)
From: osalvador@techadventures.net
Subject: [PATCH 3/3] mm/page_alloc: Split context in free_area_init_node
Date: Wed, 18 Jul 2018 14:47:22 +0200
Message-Id: <20180718124722.9872-4-osalvador@techadventures.net>
In-Reply-To: <20180718124722.9872-1-osalvador@techadventures.net>
References: <20180718124722.9872-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: pasha.tatashin@oracle.com, mhocko@suse.com, vbabka@suse.cz, iamjoonsoo.kim@lge.com, aaron.lu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Oscar Salvador <osalvador@suse.de>

From: Oscar Salvador <osalvador@suse.de>

If free_area_init_node gets called from memhotplug code,
we do not need to call calculate_node_totalpages(),
as the node has no pages.

The same goes for the deferred initialization, as
memmap_init_zone skips that when the context is MEMMAP_HOTPLUG.

Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 mm/page_alloc.c | 37 +++++++++++++++++++++++++------------
 1 file changed, 25 insertions(+), 12 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d652a3ad720c..99c342eeb5db 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6388,12 +6388,28 @@ static void __ref alloc_node_mem_map(struct pglist_data *pgdat)
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
 	pg_data_t *pgdat = NODE_DATA(nid);
 	unsigned long start_pfn = 0;
 	unsigned long end_pfn = 0;
+	bool no_hotplug_context = node_online(nid);
 
 	/* pg_data_t should be reset to zero when it's allocated */
 	WARN_ON(pgdat->nr_zones || pgdat->kswapd_classzone_idx);
@@ -6409,20 +6425,17 @@ void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
 #else
 	start_pfn = node_start_pfn;
 #endif
-	calculate_node_totalpages(pgdat, start_pfn, end_pfn,
-				  zones_size, zholes_size);
 
-	alloc_node_mem_map(pgdat);
-
-#ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
-	/*
-	 * We start only with one section of pages, more pages are added as
-	 * needed until the rest of deferred pages are initialized.
+	/* Memhotplug is the only place where free_area_init_node gets called
+	 * with the node being still offline.
 	 */
-	pgdat->static_init_pgcnt = min_t(unsigned long, PAGES_PER_SECTION,
-					 pgdat->node_spanned_pages);
-	pgdat->first_deferred_pfn = ULONG_MAX;
-#endif
+	if (no_hotplug_context) {
+		calculate_node_totalpages(pgdat, start_pfn, end_pfn,
+					  zones_size, zholes_size);
+		alloc_node_mem_map(pgdat);
+		pgdat_set_deferred_range(pgdat);
+	}
+
 	free_area_init_core(pgdat);
 }
 
-- 
2.13.6
