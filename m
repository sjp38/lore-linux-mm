Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 77398830DE
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 01:08:09 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id le9so249044850pab.0
        for <linux-mm@kvack.org>; Sun, 28 Aug 2016 22:08:09 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id z23si37132180pfi.90.2016.08.28.22.08.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Aug 2016 22:08:08 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id g202so8637174pfb.1
        for <linux-mm@kvack.org>; Sun, 28 Aug 2016 22:08:08 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH v5 6/6] mm/cma: remove per zone CMA stat
Date: Mon, 29 Aug 2016 14:07:35 +0900
Message-Id: <1472447255-10584-7-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1472447255-10584-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1472447255-10584-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Now, all reserved pages for CMA region are belong to the ZONE_CMA
so we don't need to maintain CMA stat in other zones. Remove it.

Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 fs/proc/meminfo.c      |  2 +-
 include/linux/cma.h    |  6 ++++++
 include/linux/mmzone.h |  1 -
 mm/cma.c               | 15 +++++++++++++++
 mm/page_alloc.c        |  7 +++----
 mm/vmstat.c            |  1 -
 6 files changed, 25 insertions(+), 7 deletions(-)

diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index 8a42849..0ca6f38 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -151,7 +151,7 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 #ifdef CONFIG_CMA
 	show_val_kb(m, "CmaTotal:       ", totalcma_pages);
 	show_val_kb(m, "CmaFree:        ",
-		    global_page_state(NR_FREE_CMA_PAGES));
+		    cma_get_free());
 #endif
 
 	hugetlb_report_meminfo(m);
diff --git a/include/linux/cma.h b/include/linux/cma.h
index 29f9e77..816290c 100644
--- a/include/linux/cma.h
+++ b/include/linux/cma.h
@@ -28,4 +28,10 @@ extern int cma_init_reserved_mem(phys_addr_t base, phys_addr_t size,
 					struct cma **res_cma);
 extern struct page *cma_alloc(struct cma *cma, size_t count, unsigned int align);
 extern bool cma_release(struct cma *cma, const struct page *pages, unsigned int count);
+
+#ifdef CONFIG_CMA
+extern unsigned long cma_get_free(void);
+#else
+static inline unsigned long cma_get_free(void) { return 0; }
+#endif
 #endif
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 24e46ca..8bc2611 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -113,7 +113,6 @@ enum zone_stat_item {
 	NUMA_LOCAL,		/* allocation from local node */
 	NUMA_OTHER,		/* allocation from other node */
 #endif
-	NR_FREE_CMA_PAGES,
 	NR_VM_ZONE_STAT_ITEMS };
 
 enum node_stat_item {
diff --git a/mm/cma.c b/mm/cma.c
index c1bae7f..981633b 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -54,6 +54,21 @@ unsigned long cma_get_size(const struct cma *cma)
 	return cma->count << PAGE_SHIFT;
 }
 
+unsigned long cma_get_free(void)
+{
+	struct zone *zone;
+	unsigned long freecma = 0;
+
+	for_each_populated_zone(zone) {
+		if (!is_zone_cma(zone))
+			continue;
+
+		freecma += zone_page_state(zone, NR_FREE_PAGES);
+	}
+
+	return freecma;
+}
+
 static unsigned long cma_bitmap_aligned_mask(const struct cma *cma,
 					     int align_order)
 {
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ca17de9..587d542 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -65,6 +65,7 @@
 #include <linux/kthread.h>
 #include <linux/memcontrol.h>
 #include <linux/random.h>
+#include <linux/cma.h>
 
 #include <asm/sections.h>
 #include <asm/tlbflush.h>
@@ -4206,7 +4207,7 @@ void show_free_areas(unsigned int filter)
 		global_page_state(NR_BOUNCE),
 		global_page_state(NR_FREE_PAGES),
 		free_pcp,
-		global_page_state(NR_FREE_CMA_PAGES));
+		cma_get_free());
 
 	for_each_online_pgdat(pgdat) {
 		printk("Node %d"
@@ -4287,7 +4288,6 @@ void show_free_areas(unsigned int filter)
 			" bounce:%lukB"
 			" free_pcp:%lukB"
 			" local_pcp:%ukB"
-			" free_cma:%lukB"
 			"\n",
 			zone->name,
 			K(zone_page_state(zone, NR_FREE_PAGES)),
@@ -4309,8 +4309,7 @@ void show_free_areas(unsigned int filter)
 			K(zone_page_state(zone, NR_PAGETABLE)),
 			K(zone_page_state(zone, NR_BOUNCE)),
 			K(free_pcp),
-			K(this_cpu_read(zone->pageset->pcp.count)),
-			K(zone_page_state(zone, NR_FREE_CMA_PAGES)));
+			K(this_cpu_read(zone->pageset->pcp.count)));
 		printk("lowmem_reserve[]:");
 		for (i = 0; i < MAX_NR_ZONES; i++)
 			printk(" %ld", zone->lowmem_reserve[i]);
diff --git a/mm/vmstat.c b/mm/vmstat.c
index ce5838b..93dfd9d 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -951,7 +951,6 @@ const char * const vmstat_text[] = {
 	"numa_local",
 	"numa_other",
 #endif
-	"nr_free_cma",
 
 	/* Node-based counters */
 	"nr_inactive_anon",
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
