Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 230776B0071
	for <linux-mm@kvack.org>; Thu,  2 Oct 2014 11:49:43 -0400 (EDT)
Received: by mail-wi0-f171.google.com with SMTP id em10so1873479wid.16
        for <linux-mm@kvack.org>; Thu, 02 Oct 2014 08:49:42 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ks9si5786833wjb.72.2014.10.02.08.49.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 02 Oct 2014 08:49:40 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 1/4] mm: introduce single zone pcplists drain
Date: Thu,  2 Oct 2014 17:48:57 +0200
Message-Id: <1412264940-15738-2-git-send-email-vbabka@suse.cz>
In-Reply-To: <1412264940-15738-1-git-send-email-vbabka@suse.cz>
References: <1412264940-15738-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Xishi Qiu <qiuxishi@huawei.com>, Vladimir Davydov <vdavydov@parallels.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

The functions for draining per-cpu pages back to buddy allocators currently
always operate on all zones. There are however several cases where the drain
is only needed in the context of a single zone, and spilling other pcplists
is a waste of time both due to the extra spilling and later refilling.

This patch introduces new zone pointer parameter to drain_all_pages() and
changes the dummy parameter of drain_local_pages() to be also a zone pointer.
When NULL is passed, the functions operate on all zones as usual. Passing a
specific zone pointer reduces the work to the single zone.

All callers are updated to pass the NULL pointer in this patch. Conversion
to single zone (where appropriate) is done in further patches.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Cc: Xishi Qiu <qiuxishi@huawei.com>
Cc: Vladimir Davydov <vdavydov@parallels.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/linux/gfp.h |  4 +--
 mm/memory-failure.c |  4 +--
 mm/memory_hotplug.c |  4 +--
 mm/page_alloc.c     | 81 ++++++++++++++++++++++++++++++++++++-----------------
 mm/page_isolation.c |  2 +-
 5 files changed, 63 insertions(+), 32 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 41b30fd..07d2699 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -381,8 +381,8 @@ extern void free_kmem_pages(unsigned long addr, unsigned int order);
 
 void page_alloc_init(void);
 void drain_zone_pages(struct zone *zone, struct per_cpu_pages *pcp);
-void drain_all_pages(void);
-void drain_local_pages(void *dummy);
+void drain_all_pages(struct zone *zone);
+void drain_local_pages(struct zone *zone);
 
 /*
  * gfp_allowed_mask is set to GFP_BOOT_MASK during early boot to restrict what
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 8639f6b..851b4d7 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -233,7 +233,7 @@ void shake_page(struct page *p, int access)
 		lru_add_drain_all();
 		if (PageLRU(p))
 			return;
-		drain_all_pages();
+		drain_all_pages(NULL);
 		if (PageLRU(p) || is_free_buddy_page(p))
 			return;
 	}
@@ -1661,7 +1661,7 @@ static int __soft_offline_page(struct page *page, int flags)
 			if (!is_free_buddy_page(page))
 				lru_add_drain_all();
 			if (!is_free_buddy_page(page))
-				drain_all_pages();
+				drain_all_pages(NULL);
 			SetPageHWPoison(page);
 			if (!is_free_buddy_page(page))
 				pr_info("soft offline: %#lx: page leaked\n",
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 29d8693..55a5441 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1699,7 +1699,7 @@ repeat:
 	if (drain) {
 		lru_add_drain_all();
 		cond_resched();
-		drain_all_pages();
+		drain_all_pages(NULL);
 	}
 
 	pfn = scan_movable_pages(start_pfn, end_pfn);
@@ -1721,7 +1721,7 @@ repeat:
 	lru_add_drain_all();
 	yield();
 	/* drain pcp pages, this is synchronous. */
-	drain_all_pages();
+	drain_all_pages(NULL);
 	/*
 	 * dissolve free hugepages in the memory block before doing offlining
 	 * actually in order to make hugetlbfs's object counting consistent.
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 736d8e1..bc3db3e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1276,55 +1276,75 @@ void drain_zone_pages(struct zone *zone, struct per_cpu_pages *pcp)
 #endif
 
 /*
- * Drain pages of the indicated processor.
+ * Drain pcplists of the indicated processor and zone.
  *
  * The processor must either be the current processor and the
  * thread pinned to the current processor or a processor that
  * is not online.
  */
-static void drain_pages(unsigned int cpu)
+static void drain_pages_zone(unsigned int cpu, struct zone *zone)
 {
 	unsigned long flags;
-	struct zone *zone;
+	struct per_cpu_pageset *pset;
+	struct per_cpu_pages *pcp;
 
-	for_each_populated_zone(zone) {
-		struct per_cpu_pageset *pset;
-		struct per_cpu_pages *pcp;
+	local_irq_save(flags);
+	pset = per_cpu_ptr(zone->pageset, cpu);
 
-		local_irq_save(flags);
-		pset = per_cpu_ptr(zone->pageset, cpu);
+	pcp = &pset->pcp;
+	if (pcp->count) {
+		free_pcppages_bulk(zone, pcp->count, pcp);
+		pcp->count = 0;
+	}
+	local_irq_restore(flags);
+}
 
-		pcp = &pset->pcp;
-		if (pcp->count) {
-			free_pcppages_bulk(zone, pcp->count, pcp);
-			pcp->count = 0;
-		}
-		local_irq_restore(flags);
+/*
+ * Drain pcplists of all zones on the indicated processor.
+ *
+ * The processor must either be the current processor and the
+ * thread pinned to the current processor or a processor that
+ * is not online.
+ */
+static void drain_pages(unsigned int cpu)
+{
+	struct zone *zone;
+
+	for_each_populated_zone(zone) {
+		drain_pages_zone(cpu, zone);
 	}
 }
 
 /*
  * Spill all of this CPU's per-cpu pages back into the buddy allocator.
+ *
+ * The CPU has to be pinned. When zone parameter is non-NULL, spill just
+ * the single zone's pages.
  */
-void drain_local_pages(void *arg)
+void drain_local_pages(struct zone *zone)
 {
-	drain_pages(smp_processor_id());
+	int cpu = smp_processor_id();
+
+	if (zone)
+		drain_pages_zone(cpu, zone);
+	else
+		drain_pages(cpu);
 }
 
 /*
  * Spill all the per-cpu pages from all CPUs back into the buddy allocator.
  *
+ * When zone parameter is non-NULL, spill just the single zone's pages.
+ *
  * Note that this code is protected against sending an IPI to an offline
  * CPU but does not guarantee sending an IPI to newly hotplugged CPUs:
  * on_each_cpu_mask() blocks hotplug and won't talk to offlined CPUs but
  * nothing keeps CPUs from showing up after we populated the cpumask and
  * before the call to on_each_cpu_mask().
  */
-void drain_all_pages(void)
+void drain_all_pages(struct zone *zone)
 {
 	int cpu;
-	struct per_cpu_pageset *pcp;
-	struct zone *zone;
 
 	/*
 	 * Allocate in the BSS so we wont require allocation in
@@ -1339,20 +1359,31 @@ void drain_all_pages(void)
 	 * disables preemption as part of its processing
 	 */
 	for_each_online_cpu(cpu) {
+		struct per_cpu_pageset *pcp;
+		struct zone *z;
 		bool has_pcps = false;
-		for_each_populated_zone(zone) {
+
+		if (zone) {
 			pcp = per_cpu_ptr(zone->pageset, cpu);
-			if (pcp->pcp.count) {
+			if (pcp->pcp.count)
 				has_pcps = true;
-				break;
+		} else {
+			for_each_populated_zone(z) {
+				pcp = per_cpu_ptr(z->pageset, cpu);
+				if (pcp->pcp.count) {
+					has_pcps = true;
+					break;
+				}
 			}
 		}
+
 		if (has_pcps)
 			cpumask_set_cpu(cpu, &cpus_with_pcps);
 		else
 			cpumask_clear_cpu(cpu, &cpus_with_pcps);
 	}
-	on_each_cpu_mask(&cpus_with_pcps, drain_local_pages, NULL, 1);
+	on_each_cpu_mask(&cpus_with_pcps, (smp_call_func_t) drain_local_pages,
+								zone, 1);
 }
 
 #ifdef CONFIG_HIBERNATION
@@ -2434,7 +2465,7 @@ retry:
 	 * pages are pinned on the per-cpu lists. Drain them and try again
 	 */
 	if (!page && !drained) {
-		drain_all_pages();
+		drain_all_pages(NULL);
 		drained = true;
 		goto retry;
 	}
@@ -6386,7 +6417,7 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 	 */
 
 	lru_add_drain_all();
-	drain_all_pages();
+	drain_all_pages(NULL);
 
 	order = 0;
 	outer_start = start;
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index d1473b2..a57f082 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -67,7 +67,7 @@ out:
 
 	spin_unlock_irqrestore(&zone->lock, flags);
 	if (!ret)
-		drain_all_pages();
+		drain_all_pages(NULL);
 	return ret;
 }
 
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
