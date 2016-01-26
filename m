Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id DAD046B0009
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 10:36:46 -0500 (EST)
Received: by mail-wm0-f48.google.com with SMTP id l65so109181472wmf.1
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 07:36:46 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o126si6169906wmb.73.2016.01.26.07.36.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 26 Jan 2016 07:36:41 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC 2/3] mm, compaction: introduce kcompactd
Date: Tue, 26 Jan 2016 16:36:14 +0100
Message-Id: <1453822575-20835-2-git-send-email-vbabka@suse.cz>
In-Reply-To: <1453822575-20835-1-git-send-email-vbabka@suse.cz>
References: <1453822575-20835-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>

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
difficult to evaluate though.

The current situation wrt the purposes has a few drawbacks:

- compaction is invoked only when a high-order page or hugepage is not
  available (or manually). This might be too late for the purposes of keeping
  memory fragmentation low.
- direct compaction increases latency of allocations. Again, it would be
  better if compaction was performed asynchronously to keep fragmentation low,
  before the allocation itself comes.
- (a special case of the previous) the cost of compaction during THP page
  faults can easily offset the benefits of THP.
- kswapd compaction appears to be complex, fragile and not working in some
  scenarios

To improve the situation, we should be able to benefit from an equivalent of
kswapd, but for compaction - i.e. a background thread which responds to
fragmentation and the need for high-order allocations (including hugepages)
somewhat proactively.

One possibility is to extend the responsibilities of kswapd, which could
however complicate its design too much. It should be better to let kswapd
handle reclaim, as order-0 allocations are often more critical than high-order
ones.

Another possibility is to extend khugepaged, but this kthread is a single
instance and tied to THP configs.

This patch goes with the option of a new set of per-node kthreads called
kcompactd, and lays the foundations, without introducing any new tunables.
The lifecycle mimics kswapd kthreads, including the memory hotplug hooks.

Waking up of the kcompactd threads is also tied to kswapd activity and follows
these rules:
- we don't want to affect any fastpaths, so wake up kcompactd only from the
  slowpath, as it's done for kswapd
- if kswapd is doing reclaim, it's more important than compaction, so don't
  invoke kcompactd until kswapd goes to sleep
- the target order used for kswapd is passed to kcompactd

The kswapd compact/reclaim loop for high-order pages will be removed in the
next patch with the description of what's wrong with it.

In this patch, kcompactd uses the standard compaction_suitable() and
compact_finished() criteria, which means it will most likely have nothing left
to do after kswapd finishes, until the next patch. Kcompactd also mimics
direct compaction somewhat by trying async compaction first and sync compaction
afterwards, and uses the deferred compaction functionality.

Future possible future uses for kcompactd include the ability to wake up
kcompactd on demand in special situations, such as when hugepages are not
available (currently not done due to __GFP_NO_KSWAPD) or when a fragmentation
event (i.e. __rmqueue_fallback()) occurs. It's also possible to perform
periodic compaction with kcompactd.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/compaction.h        |  16 +++
 include/linux/mmzone.h            |   6 +
 include/linux/vm_event_item.h     |   1 +
 include/trace/events/compaction.h |  55 +++++++++
 mm/compaction.c                   | 227 ++++++++++++++++++++++++++++++++++++++
 mm/memory_hotplug.c               |  15 ++-
 mm/page_alloc.c                   |   3 +
 mm/vmscan.c                       |   6 +
 mm/vmstat.c                       |   1 +
 9 files changed, 325 insertions(+), 5 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index 4cd4ddf64cc7..1367c0564d42 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -52,6 +52,10 @@ extern void compaction_defer_reset(struct zone *zone, int order,
 				bool alloc_success);
 extern bool compaction_restarting(struct zone *zone, int order);
 
+extern int kcompactd_run(int nid);
+extern void kcompactd_stop(int nid);
+extern void wakeup_kcompactd(pg_data_t *pgdat, int order, int classzone_idx);
+
 #else
 static inline unsigned long try_to_compact_pages(gfp_t gfp_mask,
 			unsigned int order, int alloc_flags,
@@ -84,6 +88,18 @@ static inline bool compaction_deferred(struct zone *zone, int order)
 	return true;
 }
 
+static int kcompactd_run(int nid)
+{
+	return 0;
+}
+static void kcompactd_stop(int nid)
+{
+}
+
+static void wakeup_kcompactd(pg_data_t *pgdat, int order, int classzone_idx)
+{
+}
+
 #endif /* CONFIG_COMPACTION */
 
 #if defined(CONFIG_COMPACTION) && defined(CONFIG_SYSFS) && defined(CONFIG_NUMA)
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 33bb1b19273e..412613a91e15 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -664,6 +664,12 @@ typedef struct pglist_data {
 					   mem_hotplug_begin/end() */
 	int kswapd_max_order;
 	enum zone_type classzone_idx;
+#ifdef CONFIG_COMPACTION
+	int kcompactd_max_order;
+	enum zone_type kcompactd_classzone_idx;
+	wait_queue_head_t kcompactd_wait;
+	struct task_struct *kcompactd;
+#endif
 #ifdef CONFIG_NUMA_BALANCING
 	/* Lock serializing the migrate rate limiting window */
 	spinlock_t numabalancing_migrate_lock;
diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index 67c1dbd19c6d..58ecc056ee45 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -53,6 +53,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		COMPACTMIGRATE_SCANNED, COMPACTFREE_SCANNED,
 		COMPACTISOLATED,
 		COMPACTSTALL, COMPACTFAIL, COMPACTSUCCESS,
+		KCOMPACTD_WAKE,
 #endif
 #ifdef CONFIG_HUGETLB_PAGE
 		HTLB_BUDDY_PGALLOC, HTLB_BUDDY_PGALLOC_FAIL,
diff --git a/include/trace/events/compaction.h b/include/trace/events/compaction.h
index c92d1e1cbad9..223450aeb49e 100644
--- a/include/trace/events/compaction.h
+++ b/include/trace/events/compaction.h
@@ -350,6 +350,61 @@ DEFINE_EVENT(mm_compaction_defer_template, mm_compaction_defer_reset,
 );
 #endif
 
+TRACE_EVENT(mm_compaction_kcompactd_sleep,
+
+	TP_PROTO(int nid),
+
+	TP_ARGS(nid),
+
+	TP_STRUCT__entry(
+		__field(int, nid)
+	),
+
+	TP_fast_assign(
+		__entry->nid = nid;
+	),
+
+	TP_printk("nid=%d", __entry->nid)
+);
+
+DECLARE_EVENT_CLASS(kcompactd_wake_template,
+
+	TP_PROTO(int nid, int order, enum zone_type classzone_idx),
+
+	TP_ARGS(nid, order, classzone_idx),
+
+	TP_STRUCT__entry(
+		__field(int, nid)
+		__field(int, order)
+		__field(enum zone_type, classzone_idx)
+	),
+
+	TP_fast_assign(
+		__entry->nid = nid;
+		__entry->order = order;
+		__entry->classzone_idx = classzone_idx;
+	),
+
+	TP_printk("nid=%d order=%d classzone_idx=%-8s",
+		__entry->nid,
+		__entry->order,
+		__print_symbolic(__entry->classzone_idx, ZONE_TYPE))
+);
+
+DEFINE_EVENT(kcompactd_wake_template, mm_compaction_wakeup_kcompactd,
+
+	TP_PROTO(int nid, int order, enum zone_type classzone_idx),
+
+	TP_ARGS(nid, order, classzone_idx)
+);
+
+DEFINE_EVENT(kcompactd_wake_template, mm_compaction_kcompactd_wake,
+
+	TP_PROTO(int nid, int order, enum zone_type classzone_idx),
+
+	TP_ARGS(nid, order, classzone_idx)
+);
+
 #endif /* _TRACE_COMPACTION_H */
 
 /* This part must be outside protection */
diff --git a/mm/compaction.c b/mm/compaction.c
index 585de54dbe8c..7452975fa481 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -17,6 +17,9 @@
 #include <linux/balloon_compaction.h>
 #include <linux/page-isolation.h>
 #include <linux/kasan.h>
+#include <linux/kthread.h>
+#include <linux/freezer.h>
+#include <linux/module.h>
 #include "internal.h"
 
 #ifdef CONFIG_COMPACTION
@@ -29,6 +32,7 @@ static inline void count_compact_events(enum vm_event_item item, long delta)
 {
 	count_vm_events(item, delta);
 }
+
 #else
 #define count_compact_event(item) do { } while (0)
 #define count_compact_events(item, delta) do { } while (0)
@@ -1759,4 +1763,227 @@ void compaction_unregister_node(struct node *node)
 }
 #endif /* CONFIG_SYSFS && CONFIG_NUMA */
 
+static bool kcompactd_work_requested(pg_data_t *pgdat)
+{
+	return pgdat->kcompactd_max_order > 0;
+}
+
+static bool kcompactd_node_suitable(pg_data_t *pgdat)
+{
+	int zoneid;
+	struct zone *zone;
+
+	for (zoneid = 0; zoneid < MAX_NR_ZONES; zoneid++) {
+		zone = &pgdat->node_zones[zoneid];
+
+		if (!populated_zone(zone))
+			continue;
+
+		if (compaction_suitable(zone, pgdat->kcompactd_max_order, 0,
+					pgdat->kcompactd_classzone_idx)
+							== COMPACT_CONTINUE)
+			return true;
+	}
+
+	return false;
+}
+
+static void kcompactd_do_work(pg_data_t *pgdat)
+{
+	/*
+	 * With no special task, compact all zones so that a page of requested
+	 * order is allocatable.
+	 */
+	int zoneid;
+	struct zone *zone;
+	struct compact_control cc = {
+		.order = pgdat->kcompactd_max_order,
+		.classzone_idx = pgdat->kcompactd_classzone_idx,
+		.mode = MIGRATE_ASYNC,
+		.ignore_skip_hint = true,
+
+	};
+	bool success = false;
+
+	trace_mm_compaction_kcompactd_wake(pgdat->node_id, cc.order,
+							cc.classzone_idx);
+	count_vm_event(KCOMPACTD_WAKE);
+
+retry:
+	for (zoneid = 0; zoneid < MAX_NR_ZONES; zoneid++) {
+		int status;
+
+		zone = &pgdat->node_zones[zoneid];
+		if (!populated_zone(zone))
+			continue;
+
+		if (compaction_deferred(zone, cc.order))
+			continue;
+
+		if (compaction_suitable(zone, cc.order, 0, zoneid) !=
+							COMPACT_CONTINUE)
+			continue;
+
+		cc.nr_freepages = 0;
+		cc.nr_migratepages = 0;
+		cc.zone = zone;
+		INIT_LIST_HEAD(&cc.freepages);
+		INIT_LIST_HEAD(&cc.migratepages);
+
+		status = compact_zone(zone, &cc);
+
+		if (zone_watermark_ok(zone, cc.order, low_wmark_pages(zone),
+						cc.classzone_idx, 0)) {
+			success = true;
+			compaction_defer_reset(zone, cc.order, false);
+		} else if (cc.mode != MIGRATE_ASYNC &&
+						status == COMPACT_COMPLETE) {
+			defer_compaction(zone, cc.order);
+		}
+
+		VM_BUG_ON(!list_empty(&cc.freepages));
+		VM_BUG_ON(!list_empty(&cc.migratepages));
+	}
+
+	if (!success && cc.mode == MIGRATE_ASYNC) {
+		cc.mode = MIGRATE_SYNC_LIGHT;
+		goto retry;
+	}
+
+	/*
+	 * Regardless of success, we are done until woken up next. But remember
+	 * the requested order/classzone_idx in case it was higher/tighter than
+	 * our current ones
+	 */
+	if (pgdat->kcompactd_max_order <= cc.order)
+		pgdat->kcompactd_max_order = 0;
+	if (pgdat->classzone_idx >= cc.classzone_idx)
+		pgdat->classzone_idx = pgdat->nr_zones - 1;
+}
+
+void wakeup_kcompactd(pg_data_t *pgdat, int order, int classzone_idx)
+{
+	if (!order)
+		return;
+
+	if (pgdat->kcompactd_max_order < order)
+		pgdat->kcompactd_max_order = order;
+
+	if (pgdat->kcompactd_classzone_idx > classzone_idx)
+		pgdat->kcompactd_classzone_idx = classzone_idx;
+
+	if (!waitqueue_active(&pgdat->kcompactd_wait))
+		return;
+
+	if (!kcompactd_node_suitable(pgdat))
+		return;
+
+	trace_mm_compaction_wakeup_kcompactd(pgdat->node_id, order,
+							classzone_idx);
+	wake_up_interruptible(&pgdat->kcompactd_wait);
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
+	pgdat->kcompactd_max_order = 0;
+	pgdat->kcompactd_classzone_idx = pgdat->nr_zones - 1;
+
+	while (!kthread_should_stop()) {
+		trace_mm_compaction_kcompactd_sleep(pgdat->node_id);
+		wait_event_freezable(pgdat->kcompactd_wait,
+				kcompactd_work_requested(pgdat));
+
+		kcompactd_do_work(pgdat);
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
index 4af58a3a8ffa..bb5651b4ecf3 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -33,6 +33,7 @@
 #include <linux/hugetlb.h>
 #include <linux/memblock.h>
 #include <linux/bootmem.h>
+#include <linux/compaction.h>
 
 #include <asm/tlbflush.h>
 
@@ -1042,7 +1043,7 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 	arg.nr_pages = nr_pages;
 	node_states_check_changes_online(nr_pages, zone, &arg);
 
-	nid = pfn_to_nid(pfn);
+	nid = zone_to_nid(zone);
 
 	ret = memory_notify(MEM_GOING_ONLINE, &arg);
 	ret = notifier_to_errno(ret);
@@ -1082,7 +1083,7 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 	pgdat_resize_unlock(zone->zone_pgdat, &flags);
 
 	if (onlined_pages) {
-		node_states_set_node(zone_to_nid(zone), &arg);
+		node_states_set_node(nid, &arg);
 		if (need_zonelists_rebuild)
 			build_all_zonelists(NULL, NULL);
 		else
@@ -1093,8 +1094,10 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 
 	init_per_zone_wmark_min();
 
-	if (onlined_pages)
-		kswapd_run(zone_to_nid(zone));
+	if (onlined_pages) {
+		kswapd_run(nid);
+		kcompactd_run(nid);
+	}
 
 	vm_total_pages = nr_free_pagecache_pages();
 
@@ -1858,8 +1861,10 @@ static int __ref __offline_pages(unsigned long start_pfn,
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
index 63358d9f9aa9..7747eb36e789 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5212,6 +5212,9 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
 #endif
 	init_waitqueue_head(&pgdat->kswapd_wait);
 	init_waitqueue_head(&pgdat->pfmemalloc_wait);
+#ifdef CONFIG_COMPACTION
+	init_waitqueue_head(&pgdat->kcompactd_wait);
+#endif
 	pgdat_page_ext_init(pgdat);
 
 	for (j = 0; j < MAX_NR_ZONES; j++) {
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 72d52d3aef74..1449e21c55cc 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3408,6 +3408,12 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int order, int classzone_idx)
 		 */
 		reset_isolation_suitable(pgdat);
 
+		/*
+		 * We have freed the memory, now we should compact it to make
+		 * allocation of the requested order possible.
+		 */
+		wakeup_kcompactd(pgdat, order, classzone_idx);
+
 		if (!kthread_should_stop())
 			schedule();
 
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 40b2c74ddf16..25a0a65c65cc 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -826,6 +826,7 @@ const char * const vmstat_text[] = {
 	"compact_stall",
 	"compact_fail",
 	"compact_success",
+	"compact_kcompatd_wake",
 #endif
 
 #ifdef CONFIG_HUGETLB_PAGE
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
