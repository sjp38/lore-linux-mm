Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0ACFA6B0007
	for <linux-mm@kvack.org>; Wed,  1 Aug 2018 08:24:00 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id y13-v6so3620652wma.1
        for <linux-mm@kvack.org>; Wed, 01 Aug 2018 05:23:59 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l138-v6sor1396053wma.65.2018.08.01.05.23.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 01 Aug 2018 05:23:58 -0700 (PDT)
From: osalvador@techadventures.net
Subject: [PATCH v6 4/5] mm/page_alloc: Inline function to handle CONFIG_DEFERRED_STRUCT_PAGE_INIT
Date: Wed,  1 Aug 2018 14:23:47 +0200
Message-Id: <20180801122348.21588-5-osalvador@techadventures.net>
In-Reply-To: <20180801122348.21588-1-osalvador@techadventures.net>
References: <20180801122348.21588-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, vbabka@suse.cz, pasha.tatashin@oracle.com, mgorman@techsingularity.net, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dan.j.williams@intel.com, david@redhat.com, Oscar Salvador <osalvador@suse.de>

From: Oscar Salvador <osalvador@suse.de>

Let us move the code between CONFIG_DEFERRED_STRUCT_PAGE_INIT
to an inline function.
Not having an ifdef in the function makes the code more readable.

Signed-off-by: Oscar Salvador <osalvador@suse.de>
Acked-by: Michal Hocko <mhocko@suse.com>
Reviewed-by: Pavel Tatashin <pasha.tatashin@oracle.com>
---
 mm/page_alloc.c | 26 +++++++++++++++++---------
 1 file changed, 17 insertions(+), 9 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 607f98f8816d..56ee8c029759 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6366,6 +6366,22 @@ static void __ref alloc_node_mem_map(struct pglist_data *pgdat)
 static void __ref alloc_node_mem_map(struct pglist_data *pgdat) { }
 #endif /* CONFIG_FLAT_NODE_MEM_MAP */
 
+#ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
+static inline void pgdat_set_deferred_range(pg_data_t *pgdat)
+{
+	/*
+	 * We start only with one section of pages, more pages are added as
+	 * needed until the rest of deferred pages are initialized.
+	 */
+
+	pgdat->static_init_pgcnt = min_t(unsigned long, PAGES_PER_SECTION,
+						pgdat->node_spanned_pages);
+	pgdat->first_deferred_pfn = ULONG_MAX;
+}
+#else
+static inline void pgdat_set_deferred_range(pg_data_t *pgdat) {}
+#endif
+
 void __meminit free_area_init_node(int nid, unsigned long *zones_size,
 				   unsigned long node_start_pfn,
 				   unsigned long *zholes_size)
@@ -6392,16 +6408,8 @@ void __meminit free_area_init_node(int nid, unsigned long *zones_size,
 				  zones_size, zholes_size);
 
 	alloc_node_mem_map(pgdat);
+	pgdat_set_deferred_range(pgdat);
 
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
