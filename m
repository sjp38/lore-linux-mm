Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 42BC16B0269
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 09:27:48 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id v24-v6so2360123wmh.5
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 06:27:48 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g144-v6sor1189304wmg.51.2018.07.19.06.27.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 19 Jul 2018 06:27:47 -0700 (PDT)
From: osalvador@techadventures.net
Subject: [PATCH v2 1/5] mm/page_alloc: Move ifdefery out of free_area_init_core
Date: Thu, 19 Jul 2018 15:27:36 +0200
Message-Id: <20180719132740.32743-2-osalvador@techadventures.net>
In-Reply-To: <20180719132740.32743-1-osalvador@techadventures.net>
References: <20180719132740.32743-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: pasha.tatashin@oracle.com, mhocko@suse.com, vbabka@suse.cz, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Oscar Salvador <osalvador@suse.de>

From: Oscar Salvador <osalvador@suse.de>

Moving the #ifdefs out of the function makes it easier to follow.

Signed-off-by: Oscar Salvador <osalvador@suse.de>
Acked-by: Michal Hocko <mhocko@suse.com>
Reviewed-by: Pavel Tatashin <pasha.tatashin@oracle.com>
---
 mm/page_alloc.c | 50 +++++++++++++++++++++++++++++++++++++-------------
 1 file changed, 37 insertions(+), 13 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e357189cd24a..8a73305f7c55 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6206,6 +6206,37 @@ static unsigned long __paginginit calc_memmap_size(unsigned long spanned_pages,
 	return PAGE_ALIGN(pages * sizeof(struct page)) >> PAGE_SHIFT;
 }
 
+#ifdef CONFIG_NUMA_BALANCING
+static void pgdat_init_numabalancing(struct pglist_data *pgdat)
+{
+	spin_lock_init(&pgdat->numabalancing_migrate_lock);
+	pgdat->numabalancing_migrate_nr_pages = 0;
+	pgdat->numabalancing_migrate_next_window = jiffies;
+}
+#else
+static void pgdat_init_numabalancing(struct pglist_data *pgdat) {}
+#endif
+
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+static void pgdat_init_split_queue(struct pglist_data *pgdat)
+{
+	spin_lock_init(&pgdat->split_queue_lock);
+	INIT_LIST_HEAD(&pgdat->split_queue);
+	pgdat->split_queue_len = 0;
+}
+#else
+static void pgdat_init_split_queue(struct pglist_data *pgdat) {}
+#endif
+
+#ifdef CONFIG_COMPACTION
+static void pgdat_init_kcompactd(struct pglist_data *pgdat)
+{
+	init_waitqueue_head(&pgdat->kcompactd_wait);
+}
+#else
+static void pgdat_init_kcompactd(struct pglist_data *pgdat) {}
+#endif
+
 /*
  * Set up the zone data structures:
  *   - mark all pages reserved
@@ -6220,21 +6251,14 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
 	int nid = pgdat->node_id;
 
 	pgdat_resize_init(pgdat);
-#ifdef CONFIG_NUMA_BALANCING
-	spin_lock_init(&pgdat->numabalancing_migrate_lock);
-	pgdat->numabalancing_migrate_nr_pages = 0;
-	pgdat->numabalancing_migrate_next_window = jiffies;
-#endif
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
-	spin_lock_init(&pgdat->split_queue_lock);
-	INIT_LIST_HEAD(&pgdat->split_queue);
-	pgdat->split_queue_len = 0;
-#endif
+
+	pgdat_init_numabalancing(pgdat);
+	pgdat_init_split_queue(pgdat);
+	pgdat_init_kcompactd(pgdat);
+
 	init_waitqueue_head(&pgdat->kswapd_wait);
 	init_waitqueue_head(&pgdat->pfmemalloc_wait);
-#ifdef CONFIG_COMPACTION
-	init_waitqueue_head(&pgdat->kcompactd_wait);
-#endif
+
 	pgdat_page_ext_init(pgdat);
 	spin_lock_init(&pgdat->lru_lock);
 	lruvec_init(node_lruvec(pgdat));
-- 
2.13.6
