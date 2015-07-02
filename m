Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8EC8A9003CE
	for <linux-mm@kvack.org>; Thu,  2 Jul 2015 04:47:28 -0400 (EDT)
Received: by wgjx7 with SMTP id x7so56815535wgj.2
        for <linux-mm@kvack.org>; Thu, 02 Jul 2015 01:47:28 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id nb7si7680708wjc.10.2015.07.02.01.47.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 02 Jul 2015 01:47:24 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC 1/4] mm, compaction: introduce kcompactd
Date: Thu,  2 Jul 2015 10:46:32 +0200
Message-Id: <1435826795-13777-2-git-send-email-vbabka@suse.cz>
In-Reply-To: <1435826795-13777-1-git-send-email-vbabka@suse.cz>
References: <1435826795-13777-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>

Memory compaction can be currently performed in several contexts:

- kswapd balancing a zone after a high-order allocation failure
- direct compaction to satisfy a high-order allocation, including THP page
  fault attemps
- khugepaged trying to collapse a hugepage
- manually from /proc

The purpose of compaction is two-fold. The obvious purpose is to satisfy a
(pending or future) high-order allocation, and is easy to evaluate. The other
purpose is to keep overal memory fragmentation low and help the
anti-fragmentation mechanism. The success wrt the latter purpose is more
difficult to evaluate.

The current situation wrt the purposes has a few drawbacks:

- compaction is invoked only when a high-order page or hugepage is not
  available (or manually). This might be too late for the purposes of keeping
  memory fragmentation low.
- direct compaction increases latency of allocations. Again, it would be
  better if compaction was performed asynchronously to keep fragmentation low,
  before the allocation itself comes.
- (a special case of the previous) the cost of compaction during THP page
  faults can easily offset the benefits of THP.

To improve the situation, we need an equivalent of kswapd, but for compaction.
E.g. a background thread which responds to fragmentation and the need for
high-order allocations (including hugepages) somewhat proactively.

One possibility is to extend the responsibilities of kswapd, which could
however complicate its design too much. It should be better to let kswapd
handle reclaim, as order-0 allocations are often more critical than high-order
ones.

Another possibility is to extend khugepaged, but this kthread is a single
instance and tied to THP configs.

This patch goes with the option of a new set of per-node kthreads called
kcompactd, and lays the foundations. The lifecycle mimics kswapd kthreads.

The work loop of kcompactd currently mimics an pageblock-order direct
compaction attempt each 15 seconds. This might not be enough to keep
fragmentation low, and needs evaluation.

When there's not enough free memory for compaction, kswapd is woken up for
reclaim only (not compaction/reclaim).

Further patches will add the ability to wake up kcompactd on demand in special
situations such as when hugepages are not available, or when a fragmentation
event occured.

Not-yet-signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/compaction.h |  11 +++
 include/linux/mmzone.h     |   4 ++
 mm/compaction.c            | 173 +++++++++++++++++++++++++++++++++++++++++++++
 mm/memory_hotplug.c        |  15 ++--
 mm/page_alloc.c            |   3 +
 5 files changed, 201 insertions(+), 5 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index aa8f61c..a2525d8 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -51,6 +51,9 @@ extern void compaction_defer_reset(struct zone *zone, int order,
 				bool alloc_success);
 extern bool compaction_restarting(struct zone *zone, int order);
 
+extern int kcompactd_run(int nid);
+extern void kcompactd_stop(int nid);
+
 #else
 static inline unsigned long try_to_compact_pages(gfp_t gfp_mask,
 			unsigned int order, int alloc_flags,
@@ -83,6 +86,14 @@ static inline bool compaction_deferred(struct zone *zone, int order)
 	return true;
 }
 
+static int kcompactd_run(int nid)
+{
+	return 0;
+}
+extern void kcompactd_stop(int nid)
+{
+}
+
 #endif /* CONFIG_COMPACTION */
 
 #if defined(CONFIG_COMPACTION) && defined(CONFIG_SYSFS) && defined(CONFIG_NUMA)
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 54d74f6..bc96a23 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -762,6 +762,10 @@ typedef struct pglist_data {
 	/* Number of pages migrated during the rate limiting time interval */
 	unsigned long numabalancing_migrate_nr_pages;
 #endif
+#ifdef CONFIG_COMPACTION
+	struct task_struct *kcompactd;
+	wait_queue_head_t kcompactd_wait;
+#endif
 } pg_data_t;
 
 #define node_present_pages(nid)	(NODE_DATA(nid)->node_present_pages)
diff --git a/mm/compaction.c b/mm/compaction.c
index 018f08d..fcbc093 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -17,6 +17,8 @@
 #include <linux/balloon_compaction.h>
 #include <linux/page-isolation.h>
 #include <linux/kasan.h>
+#include <linux/kthread.h>
+#include <linux/freezer.h>
 #include "internal.h"
 
 #ifdef CONFIG_COMPACTION
@@ -29,6 +31,10 @@ static inline void count_compact_events(enum vm_event_item item, long delta)
 {
 	count_vm_events(item, delta);
 }
+
+//TODO: add tuning knob
+static unsigned int kcompactd_sleep_millisecs __read_mostly = 15000;
+
 #else
 #define count_compact_event(item) do { } while (0)
 #define count_compact_events(item, delta) do { } while (0)
@@ -1714,4 +1720,171 @@ void compaction_unregister_node(struct node *node)
 }
 #endif /* CONFIG_SYSFS && CONFIG_NUMA */
 
+/*
+ * Has any special work been requested of kcompactd?
+ */
+static bool kcompactd_work_requested(pg_data_t *pgdat)
+{
+	return false;
+}
+
+static void kcompactd_do_work(pg_data_t *pgdat)
+{
+	/*
+	 * //TODO: smarter decisions on how much to compact. Using pageblock
+	 * order might result in no compaction, until fragmentation builds up
+	 * too much. Using order -1 could be too aggressive on large zones.
+	 *
+	 * With no special task, compact all zones so that a pageblock-order
+	 * page is allocatable. Wake up kswapd if there's not enough free
+	 * memory for compaction.
+	 */
+	int zoneid;
+	struct zone *zone;
+	struct compact_control cc = {
+		.order = pageblock_order,
+		.mode = MIGRATE_SYNC,
+		.ignore_skip_hint = true,
+	};
+
+	for (zoneid = 0; zoneid < MAX_NR_ZONES; zoneid++) {
+
+		int suitable;
+
+		zone = &pgdat->node_zones[zoneid];
+		if (!populated_zone(zone))
+			continue;
+
+		suitable = compaction_suitable(zone, cc.order, 0, 0);
+
+		if (suitable == COMPACT_SKIPPED) {
+			/*
+			 * We pass order==0 to kswapd so it doesn't compact by
+			 * itself. We just need enough free pages to proceed
+			 * with compaction here on next kcompactd wakeup.
+			 */
+			wakeup_kswapd(zone, 0, 0);
+			continue;
+		}
+		if (suitable == COMPACT_PARTIAL)
+			continue;
+
+		cc.nr_freepages = 0;
+		cc.nr_migratepages = 0;
+		cc.zone = zone;
+		INIT_LIST_HEAD(&cc.freepages);
+		INIT_LIST_HEAD(&cc.migratepages);
+
+		compact_zone(zone, &cc);
+
+		if (zone_watermark_ok(zone, cc.order,
+						low_wmark_pages(zone), 0, 0))
+			compaction_defer_reset(zone, cc.order, false);
+
+		VM_BUG_ON(!list_empty(&cc.freepages));
+		VM_BUG_ON(!list_empty(&cc.migratepages));
+	}
+
+}
+
+/*
+ * The background compaction daemon, started as a kernel thread
+ * from the init process.
+ */
+static int kcompactd(void *p)
+{
+	pg_data_t *pgdat = (pg_data_t*)p;
+	struct task_struct *tsk = current;
+
+	const struct cpumask *cpumask = cpumask_of_node(pgdat->node_id);
+
+	if (!cpumask_empty(cpumask))
+		set_cpus_allowed_ptr(tsk, cpumask);
+
+	set_freezable();
+
+	while (!kthread_should_stop()) {
+		kcompactd_do_work(pgdat);
+
+		wait_event_freezable_timeout(pgdat->kcompactd_wait,
+				kcompactd_work_requested(pgdat),
+			msecs_to_jiffies(kcompactd_sleep_millisecs));
+	}
+
+	return 0;
+}
+
+/*
+ * This kcompactd start function will be called by init and node-hot-add.
+ * On node-hot-add, kcompactd will moved to proper cpus if cpus are hot-added.
+ */
+int kcompactd_run(int nid)
+{
+	pg_data_t *pgdat = NODE_DATA(nid);
+	int ret = 0;
+
+	if (pgdat->kcompactd)
+		return 0;
+
+	pgdat->kcompactd = kthread_run(kcompactd, pgdat, "kcompactd%d", nid);
+	if (IS_ERR(pgdat->kcompactd)) {
+		pr_err("Failed to start kcompactd on node %d\n", nid);
+		ret = PTR_ERR(pgdat->kcompactd);
+		pgdat->kcompactd = NULL;
+	}
+	return ret;
+}
+
+/*
+ * Called by memory hotplug when all memory in a node is offlined. Caller must
+ * hold mem_hotplug_begin/end().
+ */
+void kcompactd_stop(int nid)
+{
+	struct task_struct *kcompactd = NODE_DATA(nid)->kcompactd;
+
+	if (kcompactd) {
+		kthread_stop(kcompactd);
+		NODE_DATA(nid)->kcompactd = NULL;
+	}
+}
+
+/*
+ * It's optimal to keep kcompactd on the same CPUs as their memory, but
+ * not required for correctness. So if the last cpu in a node goes
+ * away, we get changed to run anywhere: as the first one comes back,
+ * restore their cpu bindings.
+ */
+static int cpu_callback(struct notifier_block *nfb, unsigned long action,
+			void *hcpu)
+{
+	int nid;
+
+	if (action == CPU_ONLINE || action == CPU_ONLINE_FROZEN) {
+		for_each_node_state(nid, N_MEMORY) {
+			pg_data_t *pgdat = NODE_DATA(nid);
+			const struct cpumask *mask;
+
+			mask = cpumask_of_node(pgdat->node_id);
+
+			if (cpumask_any_and(cpu_online_mask, mask) < nr_cpu_ids)
+				/* One of our CPUs online: restore mask */
+				set_cpus_allowed_ptr(pgdat->kcompactd, mask);
+		}
+	}
+	return NOTIFY_OK;
+}
+
+static int __init kcompactd_init(void)
+{
+	int nid;
+
+	for_each_node_state(nid, N_MEMORY)
+		kcompactd_run(nid);
+	hotcpu_notifier(cpu_callback, 0);
+	return 0;
+}
+
+module_init(kcompactd_init)
+
 #endif /* CONFIG_COMPACTION */
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 9e88f74..3412aa4 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -32,6 +32,7 @@
 #include <linux/hugetlb.h>
 #include <linux/memblock.h>
 #include <linux/bootmem.h>
+#include <linux/compaction.h>
 
 #include <asm/tlbflush.h>
 
@@ -1000,7 +1001,7 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 	arg.nr_pages = nr_pages;
 	node_states_check_changes_online(nr_pages, zone, &arg);
 
-	nid = pfn_to_nid(pfn);
+	nid = zone_to_nid(zone);
 
 	ret = memory_notify(MEM_GOING_ONLINE, &arg);
 	ret = notifier_to_errno(ret);
@@ -1040,7 +1041,7 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 	pgdat_resize_unlock(zone->zone_pgdat, &flags);
 
 	if (onlined_pages) {
-		node_states_set_node(zone_to_nid(zone), &arg);
+		node_states_set_node(nid, &arg);
 		if (need_zonelists_rebuild)
 			build_all_zonelists(NULL, NULL);
 		else
@@ -1051,8 +1052,10 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 
 	init_per_zone_wmark_min();
 
-	if (onlined_pages)
-		kswapd_run(zone_to_nid(zone));
+	if (onlined_pages) {
+		kswapd_run(nid);
+		kcompactd_run(nid);
+	}
 
 	vm_total_pages = nr_free_pagecache_pages();
 
@@ -1782,8 +1785,10 @@ static int __ref __offline_pages(unsigned long start_pfn,
 		zone_pcp_update(zone);
 
 	node_states_clear_node(node, &arg);
-	if (arg.status_change_nid >= 0)
+	if (arg.status_change_nid >= 0) {
 		kswapd_stop(node);
+		kcompactd_stop(node);
+	}
 
 	vm_total_pages = nr_free_pagecache_pages();
 	writeback_set_ratelimit();
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ebffa0e..d9cd834 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4910,6 +4910,9 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 #endif
 	init_waitqueue_head(&pgdat->kswapd_wait);
 	init_waitqueue_head(&pgdat->pfmemalloc_wait);
+#ifdef CONFIG_COMPACTION
+	init_waitqueue_head(&pgdat->kcompactd_wait);
+#endif
 	pgdat_page_ext_init(pgdat);
 
 	for (j = 0; j < MAX_NR_ZONES; j++) {
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
