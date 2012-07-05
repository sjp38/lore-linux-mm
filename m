Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 0E7916B0071
	for <linux-mm@kvack.org>; Thu,  5 Jul 2012 05:49:56 -0400 (EDT)
From: Jiang Liu <jiang.liu@huawei.com>
Subject: [PATCH 3/4] mm/hotplug: free zone->pageset when a zone becomes empty
Date: Thu, 5 Jul 2012 17:45:31 +0800
Message-ID: <1341481532-1700-3-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1341481532-1700-1-git-send-email-jiang.liu@huawei.com>
References: <1341481532-1700-1-git-send-email-jiang.liu@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Minchan Kim <minchan@kernel.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, Rusty Russell <rusty@rustcorp.com.au>, Yinghai Lu <yinghai@kernel.org>, Tony Luck <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Bjorn Helgaas <bhelgaas@google.com>, Keping Chen <chenkeping@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jiang Liu <liuj97@gmail.com>, Wei Wang <Bessel.Wang@huawei.com>

When a zone becomes empty after memory offlining, free zone->pageset.
Otherwise it will cause memory leak when adding memory to the empty
zone again because build_all_zonelists() will allocate zone->pageset
for an empty zone.

Signed-off-by: Jiang Liu <liuj97@gmail.com>
Signed-off-by: Wei Wang <Bessel.Wang@huawei.com>
---
 include/linux/mm.h  |    1 +
 mm/memory_hotplug.c |    3 +++
 mm/page_alloc.c     |   13 +++++++++++++
 3 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index b36d08c..f8b62f2 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1331,6 +1331,7 @@ void warn_alloc_failed(gfp_t gfp_mask, int order, const char *fmt, ...);
 extern void setup_per_cpu_pageset(void);
 
 extern void zone_pcp_update(struct zone *zone);
+extern void zone_pcp_reset(struct zone *zone);
 
 /* nommu.c */
 extern atomic_long_t mmap_pages_allocated;
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index bce80c7..998b792 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -966,6 +966,9 @@ repeat:
 
 	init_per_zone_wmark_min();
 
+	if (!populated_zone(zone))
+		zone_pcp_reset(zone);
+
 	if (!node_present_pages(node)) {
 		node_clear_state(node, N_HIGH_MEMORY);
 		kswapd_stop(node);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ebf319d..5964b7a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5872,6 +5872,19 @@ void free_contig_range(unsigned long pfn, unsigned nr_pages)
 #endif
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
+void zone_pcp_reset(struct zone *zone)
+{
+	unsigned long flags;
+
+	/* avoid races with drain_pages()  */
+	local_irq_save(flags);
+	if (zone->pageset != &boot_pageset) {
+		free_percpu(zone->pageset);
+		zone->pageset = &boot_pageset;
+	}
+	local_irq_restore(flags);
+}
+
 /*
  * All pages in the range must be isolated before calling this.
  */
-- 
1.7.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
