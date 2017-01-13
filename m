Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2B41A6B026B
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 02:15:29 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 127so101728755pfg.5
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 23:15:29 -0800 (PST)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id 9si10320264pfs.203.2017.01.12.23.15.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jan 2017 23:15:28 -0800 (PST)
Received: by mail-pf0-x243.google.com with SMTP id f144so7109136pfa.2
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 23:15:28 -0800 (PST)
From: js1304@gmail.com
Subject: [RFC PATCH 5/5] mm/compaction: run the compaction whenever fragmentation ratio exceeds the threshold
Date: Fri, 13 Jan 2017 16:14:33 +0900
Message-Id: <1484291673-2239-6-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1484291673-2239-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1484291673-2239-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Until now, we invoke the compaction whenever allocation request is stall
due to non-existence of the high order freepage. It is effective since we
don't need a high order freepage in usual and cost of maintaining
high order freepages is quite high. However, it increases latency of high
order allocation request and decreases success rate if allocation request
cannot use the reclaim/compaction. Since there are some workloads that
require high order freepage to boost the performance, it is a matter of
trade-off that we prepares high order freepage in advance. Now, there is
no way to prepare high order freepages, we cannot consider this trade-off.
Therefore, this patch introduces a way to invoke the compaction when
necessary to manage trade-off.

Implementation is so simple. There is a theshold to invoke the full
compaction. If fragmentation ratio reaches this threshold in given order,
we ask the full compaction to kcompactd with a hope that it restores
fragmentation ratio.

If fragmentation ratio is unchanged or worse after full compaction,
further compaction attempt would not be useful. So, this patch
stops the full compaction in this case until the situation changes
to avoid useless compaction effort.

Now, there is no scientific code to detect the situation change.
kcompactd's full compaction would be re-enabled when lower order
triggers kcompactd wake-up or time limit (a second) is passed.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/linux/mmzone.h |   1 +
 mm/compaction.c        | 280 +++++++++++++++++++++++++++++++++++++++++++++++--
 mm/page_alloc.c        |   1 +
 3 files changed, 275 insertions(+), 7 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 94bb4fd..6029335 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -639,6 +639,7 @@ struct zonelist {
 	enum zone_type kcompactd_classzone_idx;
 	wait_queue_head_t kcompactd_wait;
 	struct task_struct *kcompactd;
+	void *kcompactd_state;
 #endif
 #ifdef CONFIG_NUMA_BALANCING
 	/* Lock serializing the migrate rate limiting window */
diff --git a/mm/compaction.c b/mm/compaction.c
index 949198d..58536c1 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1848,6 +1848,87 @@ void compaction_unregister_node(struct node *node)
 }
 #endif /* CONFIG_SYSFS && CONFIG_NUMA */
 
+#define KCOMPACTD_INDEX_GAP (200)
+
+struct kcompactd_zone_state {
+	int target_order;
+	int target_ratio;
+	int failed;
+	unsigned long failed_time;
+	struct contig_page_info info;
+};
+
+struct kcompactd_state {
+	struct kcompactd_zone_state zone_state[MAX_NR_ZONES];
+};
+
+static int kcompactd_order;
+static unsigned int kcompactd_ratio;
+
+static ssize_t order_show(struct kobject *kobj,
+			struct kobj_attribute *attr, char *buf)
+{
+	return sprintf(buf, "%d\n", kcompactd_order);
+}
+
+static ssize_t order_store(struct kobject *kobj,
+			struct kobj_attribute *attr,
+			const char *buf, size_t count)
+{
+	int order;
+	int ret;
+
+	ret = kstrtoint(buf, 10, &order);
+	if (ret)
+		return -EINVAL;
+
+	/* kcompactd's compaction will be disabled when order is -1 */
+	if (order >= MAX_ORDER || order < -1)
+		return -EINVAL;
+
+	kcompactd_order = order;
+	return count;
+}
+
+static ssize_t ratio_show(struct kobject *kobj,
+			struct kobj_attribute *attr, char *buf)
+{
+	return sprintf(buf, "%u\n", kcompactd_ratio);
+}
+
+static ssize_t ratio_store(struct kobject *kobj,
+			struct kobj_attribute *attr,
+			const char *buf, size_t count)
+{
+	unsigned int ratio;
+	int ret;
+
+	ret = kstrtouint(buf, 10, &ratio);
+	if (ret)
+		return -EINVAL;
+
+	if (ratio > 1000)
+		return -EINVAL;
+
+	kcompactd_ratio = ratio;
+	return count;
+}
+
+static struct kobj_attribute order_attr = __ATTR_RW(order);
+static struct kobj_attribute ratio_attr = __ATTR_RW(ratio);
+
+static struct attribute *kcompactd_attrs[] = {
+	&order_attr.attr,
+	&ratio_attr.attr,
+	NULL,
+};
+
+static struct attribute_group kcompactd_attr_group = {
+	.attrs = kcompactd_attrs,
+	.name = "kcompactd",
+};
+
+
 static inline bool kcompactd_work_requested(pg_data_t *pgdat)
 {
 	return pgdat->kcompactd_max_order > 0 || kthread_should_stop();
@@ -1858,6 +1939,11 @@ static bool kcompactd_node_suitable(pg_data_t *pgdat)
 	int zoneid;
 	struct zone *zone;
 	enum zone_type classzone_idx = pgdat->kcompactd_classzone_idx;
+	int order;
+
+	order = pgdat->kcompactd_max_order;
+	if (order == INT_MAX)
+		order = -1;
 
 	for (zoneid = 0; zoneid <= classzone_idx; zoneid++) {
 		zone = &pgdat->node_zones[zoneid];
@@ -1865,14 +1951,116 @@ static bool kcompactd_node_suitable(pg_data_t *pgdat)
 		if (!populated_zone(zone))
 			continue;
 
-		if (compaction_suitable(zone, pgdat->kcompactd_max_order, 0,
-					classzone_idx) == COMPACT_CONTINUE)
+		if (compaction_suitable(zone, order, 0, classzone_idx)
+			== COMPACT_CONTINUE)
 			return true;
 	}
 
 	return false;
 }
 
+static int kcompactd_check_ratio(pg_data_t *pgdat, int zoneid)
+{
+	int i;
+	int unusable_free_avg;
+	struct zone *zone;
+	struct kcompactd_state *state;
+	struct kcompactd_zone_state *zone_state;
+	struct contig_page_info info;
+	int index;
+
+	state = pgdat->kcompactd_state;
+	zone_state = &state->zone_state[zoneid];
+	zone = &pgdat->node_zones[zoneid];
+
+	fill_contig_page_info(zone, &info);
+	for (i = PAGE_ALLOC_COSTLY_ORDER + 1; i <= kcompactd_order; i++) {
+		unusable_free_avg = zone->free_area[i].unusable_free_avg >>
+					UNUSABLE_INDEX_FACTOR;
+
+		if (unusable_free_avg >= kcompactd_ratio)
+			return i;
+
+		index = unusable_free_index(i, &info);
+		if (index >= kcompactd_ratio &&
+			(kcompactd_ratio > unusable_free_avg + KCOMPACTD_INDEX_GAP))
+			return i;
+	}
+
+	return -1;
+}
+
+static void kcompactd_check_result(pg_data_t *pgdat, int classzone_idx)
+{
+	int zoneid;
+	struct zone *zone;
+	struct kcompactd_state *state;
+	struct kcompactd_zone_state *zone_state;
+	int unusable_free_avg;
+	unsigned long flags;
+	int prev_index, curr_index;
+
+	for (zoneid = 0; zoneid <= classzone_idx; zoneid++) {
+		zone = &pgdat->node_zones[zoneid];
+		if (!populated_zone(zone))
+			continue;
+
+		state = pgdat->kcompactd_state;
+		zone_state = &state->zone_state[zoneid];
+		unusable_free_avg =
+			zone->free_area[zone_state->target_order].unusable_free_avg >>
+				UNUSABLE_INDEX_FACTOR;
+		if (unusable_free_avg < zone_state->target_ratio) {
+			zone_state->failed = 0;
+			continue;
+		}
+
+		prev_index = unusable_free_index(zone_state->target_order,
+						&zone_state->info);
+		spin_lock_irqsave(&zone->lock, flags);
+		fill_contig_page_info(zone, &zone_state->info);
+		spin_unlock_irqrestore(&zone->lock, flags);
+
+		curr_index = unusable_free_index(zone_state->target_order,
+						&zone_state->info);
+		if (curr_index < zone_state->target_ratio ||
+			curr_index < prev_index) {
+			zone_state->failed = 0;
+			continue;
+		}
+
+		zone_state->failed++;
+		zone_state->failed_time = jiffies;
+	}
+}
+
+static bool kcompactd_should_skip(pg_data_t *pgdat, int classzone_idx)
+{
+	struct kcompactd_state *state;
+	struct kcompactd_zone_state *zone_state;
+	int target_order;
+	unsigned long recharge_time;
+
+	target_order = kcompactd_check_ratio(pgdat, classzone_idx);
+	if (target_order < 0)
+		return true;
+
+	state = pgdat->kcompactd_state;
+	zone_state = &state->zone_state[classzone_idx];
+	if (!zone_state->failed)
+		return false;
+
+	if (target_order < zone_state->target_order)
+		return false;
+
+	recharge_time = zone_state->failed_time;
+	recharge_time += HZ * (1 << zone_state->failed);
+	if (time_after(jiffies, recharge_time))
+		return false;
+
+	return true;
+}
+
 static void kcompactd_do_work(pg_data_t *pgdat)
 {
 	/*
@@ -1880,6 +2068,7 @@ static void kcompactd_do_work(pg_data_t *pgdat)
 	 * order is allocatable.
 	 */
 	int zoneid;
+	int cpu;
 	struct zone *zone;
 	struct compact_control cc = {
 		.order = pgdat->kcompactd_max_order,
@@ -1889,10 +2078,19 @@ static void kcompactd_do_work(pg_data_t *pgdat)
 		.gfp_mask = GFP_KERNEL,
 
 	};
+	struct kcompactd_state *state;
+	struct kcompactd_zone_state *zone_state;
+	unsigned long flags;
 	trace_mm_compaction_kcompactd_wake(pgdat->node_id, cc.order,
 							cc.classzone_idx);
 	count_vm_event(KCOMPACTD_WAKE);
 
+	/* Force to run full compaction */
+	if (cc.order == INT_MAX) {
+		cc.order = -1;
+		cc.whole_zone = true;
+	}
+
 	for (zoneid = 0; zoneid <= cc.classzone_idx; zoneid++) {
 		int status;
 
@@ -1915,8 +2113,29 @@ static void kcompactd_do_work(pg_data_t *pgdat)
 
 		if (kthread_should_stop())
 			return;
+
+		if (is_via_compact_memory(cc.order)) {
+			state = pgdat->kcompactd_state;
+			zone_state = &state->zone_state[zoneid];
+			zone_state->target_order =
+				kcompactd_check_ratio(pgdat, zoneid);
+			zone_state->target_ratio = kcompactd_ratio;
+			if (zone_state->target_order < 0)
+				continue;
+
+			spin_lock_irqsave(&zone->lock, flags);
+			fill_contig_page_info(zone, &zone_state->info);
+			spin_unlock_irqrestore(&zone->lock, flags);
+		}
+
 		status = compact_zone(zone, &cc);
 
+		VM_BUG_ON(!list_empty(&cc.freepages));
+		VM_BUG_ON(!list_empty(&cc.migratepages));
+
+		if (is_via_compact_memory(cc.order))
+			continue;
+
 		if (status == COMPACT_SUCCESS) {
 			compaction_defer_reset(zone, cc.order, false);
 		} else if (status == COMPACT_PARTIAL_SKIPPED || status == COMPACT_COMPLETE) {
@@ -1926,9 +2145,6 @@ static void kcompactd_do_work(pg_data_t *pgdat)
 			 */
 			defer_compaction(zone, cc.order);
 		}
-
-		VM_BUG_ON(!list_empty(&cc.freepages));
-		VM_BUG_ON(!list_empty(&cc.migratepages));
 	}
 
 	/*
@@ -1940,6 +2156,16 @@ static void kcompactd_do_work(pg_data_t *pgdat)
 		pgdat->kcompactd_max_order = 0;
 	if (pgdat->kcompactd_classzone_idx >= cc.classzone_idx)
 		pgdat->kcompactd_classzone_idx = pgdat->nr_zones - 1;
+
+	/* Do not invoke compaction immediately if we did full compaction */
+	if (is_via_compact_memory(cc.order)) {
+		pgdat->kcompactd_max_order = 0;
+		cpu = get_cpu();
+		lru_add_drain_cpu(cpu);
+		drain_local_pages(NULL);
+		put_cpu();
+		kcompactd_check_result(pgdat, cc.classzone_idx);
+	}
 }
 
 void wakeup_kcompactd(pg_data_t *pgdat, int order, int classzone_idx)
@@ -1947,6 +2173,11 @@ void wakeup_kcompactd(pg_data_t *pgdat, int order, int classzone_idx)
 	if (!order)
 		return;
 
+	if (order == INT_MAX) {
+		if (kcompactd_should_skip(pgdat, classzone_idx))
+			return;
+	}
+
 	if (pgdat->kcompactd_max_order < order)
 		pgdat->kcompactd_max_order = order;
 
@@ -2000,18 +2231,42 @@ static int kcompactd(void *p)
  */
 int kcompactd_run(int nid)
 {
+	int i;
+	struct kcompactd_state *state;
+	struct kcompactd_zone_state *zone_state;
 	pg_data_t *pgdat = NODE_DATA(nid);
-	int ret = 0;
+	struct zone *zone;
+	int ret = -ENOMEM;
 
 	if (pgdat->kcompactd)
 		return 0;
 
+	state = kzalloc(sizeof(struct kcompactd_state), GFP_KERNEL);
+	if (!state)
+		goto err;
+
+	for (i = 0; i < MAX_NR_ZONES; i++) {
+		zone = &pgdat->node_zones[i];
+		zone_state = &state->zone_state[i];
+		if (!populated_zone(zone))
+			continue;
+
+		zone_state->failed = 0;
+	}
+
 	pgdat->kcompactd = kthread_run(kcompactd, pgdat, "kcompactd%d", nid);
 	if (IS_ERR(pgdat->kcompactd)) {
-		pr_err("Failed to start kcompactd on node %d\n", nid);
 		ret = PTR_ERR(pgdat->kcompactd);
 		pgdat->kcompactd = NULL;
+		kfree(state);
+		goto err;
 	}
+	pgdat->kcompactd_state = (void *)state;
+
+	return 0;
+
+err:
+	pr_err("Failed to start kcompactd on node %d\n", nid);
 	return ret;
 }
 
@@ -2065,6 +2320,17 @@ static int __init kcompactd_init(void)
 		return ret;
 	}
 
+	kcompactd_order = -1;
+	kcompactd_ratio = 800;
+
+#ifdef CONFIG_SYSFS
+	ret = sysfs_create_group(mm_kobj, &kcompactd_attr_group);
+	if (ret) {
+		pr_err("kcompactd: failed to register sysfs callbacks.\n");
+		return ret;
+	}
+#endif
+
 	for_each_node_state(nid, N_MEMORY)
 		kcompactd_run(nid);
 	return 0;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5a22708..f3c2099 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -776,6 +776,7 @@ static void update_unusable_free_index(struct zone *zone)
 					128, UNUSABLE_INDEX_FACTOR);
 		}
 
+		wakeup_kcompactd(zone->zone_pgdat, INT_MAX, zone_idx(zone));
 		zone->unusable_free_index_updated = jiffies + HZ / 10;
 	} while (1);
 }
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
