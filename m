Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 45BDB6B0261
	for <linux-mm@kvack.org>; Thu, 26 May 2016 02:23:00 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id x1so92353285pav.3
        for <linux-mm@kvack.org>; Wed, 25 May 2016 23:23:00 -0700 (PDT)
Received: from mail-pa0-x241.google.com (mail-pa0-x241.google.com. [2607:f8b0:400e:c03::241])
        by mx.google.com with ESMTPS id v2si4363479pfi.223.2016.05.25.23.22.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 May 2016 23:22:59 -0700 (PDT)
Received: by mail-pa0-x241.google.com with SMTP id f8so7971853pag.0
        for <linux-mm@kvack.org>; Wed, 25 May 2016 23:22:59 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH v3 6/6] mm/cma: remove per zone CMA stat
Date: Thu, 26 May 2016 15:22:28 +0900
Message-Id: <1464243748-16367-7-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1464243748-16367-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1464243748-16367-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Rui Teng <rui.teng@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Now, all reserved pages for CMA region are belong to the ZONE_CMA
so we don't need to maintain CMA stat in other zones. Remove it.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 fs/proc/meminfo.c      |  2 +-
 include/linux/cma.h    |  6 ++++++
 include/linux/mmzone.h |  1 -
 mm/cma.c               | 15 +++++++++++++++
 mm/page_alloc.c        |  5 ++---
 mm/vmstat.c            |  1 -
 6 files changed, 24 insertions(+), 6 deletions(-)

diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index 8372046..bd853725c 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -167,7 +167,7 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 #endif
 #ifdef CONFIG_CMA
 		, K(totalcma_pages)
-		, K(global_page_state(NR_FREE_CMA_PAGES))
+		, K(cma_get_free())
 #endif
 		);
 
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
index 236d0bd..59f2181 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -130,7 +130,6 @@ enum zone_stat_item {
 	WORKINGSET_ACTIVATE,
 	WORKINGSET_NODERECLAIM,
 	NR_ANON_TRANSPARENT_HUGEPAGES,
-	NR_FREE_CMA_PAGES,
 	NR_VM_ZONE_STAT_ITEMS };
 
 /*
diff --git a/mm/cma.c b/mm/cma.c
index bd436e4..6dbddf2 100644
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
index e1c17d15..da6e6cf 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -63,6 +63,7 @@
 #include <linux/sched/rt.h>
 #include <linux/page_owner.h>
 #include <linux/kthread.h>
+#include <linux/cma.h>
 
 #include <asm/sections.h>
 #include <asm/tlbflush.h>
@@ -4351,7 +4352,7 @@ void show_free_areas(unsigned int filter)
 		global_page_state(NR_BOUNCE),
 		global_page_state(NR_FREE_PAGES),
 		free_pcp,
-		global_page_state(NR_FREE_CMA_PAGES));
+		cma_get_free());
 
 	for_each_populated_zone(zone) {
 		int i;
@@ -4391,7 +4392,6 @@ void show_free_areas(unsigned int filter)
 			" bounce:%lukB"
 			" free_pcp:%lukB"
 			" local_pcp:%ukB"
-			" free_cma:%lukB"
 			" writeback_tmp:%lukB"
 			" pages_scanned:%lu"
 			" all_unreclaimable? %s"
@@ -4424,7 +4424,6 @@ void show_free_areas(unsigned int filter)
 			K(zone_page_state(zone, NR_BOUNCE)),
 			K(free_pcp),
 			K(this_cpu_read(zone->pageset->pcp.count)),
-			K(zone_page_state(zone, NR_FREE_CMA_PAGES)),
 			K(zone_page_state(zone, NR_WRITEBACK_TEMP)),
 			K(zone_page_state(zone, NR_PAGES_SCANNED)),
 			(!zone_reclaimable(zone) ? "yes" : "no")
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 8d18d1e..9607f99 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -750,7 +750,6 @@ const char * const vmstat_text[] = {
 	"workingset_activate",
 	"workingset_nodereclaim",
 	"nr_anon_transparent_hugepages",
-	"nr_free_cma",
 
 	/* enum writeback_stat_item counters */
 	"nr_dirty_threshold",
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
