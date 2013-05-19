Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 55B036B005A
	for <linux-mm@kvack.org>; Sun, 19 May 2013 16:07:40 -0400 (EDT)
From: Glauber Costa <glommer@openvz.org>
Subject: [PATCH v7 13/34] vmscan: per-node deferred work
Date: Mon, 20 May 2013 00:07:06 +0400
Message-Id: <1368994047-5997-14-git-send-email-glommer@openvz.org>
In-Reply-To: <1368994047-5997-1-git-send-email-glommer@openvz.org>
References: <1368994047-5997-1-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, Dave Chinner <david@fromorbit.com>, hughd@google.com, Glauber Costa <glommer@openvz.org>, Dave Chinner <dchinner@redhat.com>, Mel Gorman <mgorman@suse.de>

We already keep per-node LRU lists for objects being shrunk, but the
work that is deferred from one run to another is kept global. This
creates an impedance problem, where upon node pressure, work deferred
will accumulate and end up being flushed in other nodes.

In large machines, many nodes can accumulate at the same time, all
adding to the global counter.  As we accumulate more and more, we start
to ask for the caches to flush even bigger numbers. The result is that
the caches are depleted and do not stabilize. To achieve stable steady
state behavior, we need to tackle it differently.

In this patch we keep the deferred count per-node, and will never
accumulate that to other nodes.

Signed-off-by: Glauber Costa <glommer@openvz.org>
Cc: Dave Chinner <dchinner@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
---
 include/linux/shrinker.h |  30 +++++-
 mm/vmscan.c              | 245 ++++++++++++++++++++++++++++-------------------
 2 files changed, 175 insertions(+), 100 deletions(-)

diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
index 98be3ab..d70b123 100644
--- a/include/linux/shrinker.h
+++ b/include/linux/shrinker.h
@@ -19,6 +19,8 @@ struct shrink_control {
 
 	/* shrink from these nodes */
 	nodemask_t nodes_to_scan;
+	/* current node being shrunk (for NUMA aware shrinkers) */
+	int nid;
 };
 
 /*
@@ -42,6 +44,8 @@ struct shrink_control {
  * objects freed during the scan, or -1 if progress cannot be made due to
  * potential deadlocks. If -1 is returned, then no further attempts to call the
  * @scan_objects will be made from the current reclaim context.
+ *
+ * @flags determine the shrinker abilities, like numa awareness 
  */
 struct shrinker {
 	int (*shrink)(struct shrinker *, struct shrink_control *sc);
@@ -50,12 +54,34 @@ struct shrinker {
 
 	int seeks;	/* seeks to recreate an obj */
 	long batch;	/* reclaim batch size, 0 = default */
+	unsigned long flags;
 
 	/* These are for internal use */
 	struct list_head list;
-	atomic_long_t nr_in_batch; /* objs pending delete */
+	/*
+	 * We would like to avoid allocating memory when registering a new
+	 * shrinker. All shrinkers will need to keep track of deferred objects,
+	 * and we need a counter for this. If the shrinkers are not NUMA aware,
+	 * this is a small and bounded space that fits into an atomic_long_t.
+	 * This is because that the deferring decisions are global, and we will
+	 * not allocate in this case.
+	 *
+	 * When the shrinker is NUMA aware, we will need this to be a per-node
+	 * array. Numerically speaking, the minority of shrinkers are NUMA
+	 * aware, so this saves quite a bit.
+	 */
+	union {
+		/* objs pending delete */
+		atomic_long_t nr_deferred;
+		/* objs pending delete, per node */
+		atomic_long_t *nr_deferred_node;
+	};
 };
 #define DEFAULT_SEEKS 2 /* A good number if you don't know better. */
-extern void register_shrinker(struct shrinker *);
+
+/* Flags */
+#define SHRINKER_NUMA_AWARE (1 << 0)
+
+extern int register_shrinker(struct shrinker *);
 extern void unregister_shrinker(struct shrinker *);
 #endif
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 35a6a9b..374d2b6 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -155,14 +155,36 @@ static unsigned long get_lru_size(struct lruvec *lruvec, enum lru_list lru)
 }
 
 /*
- * Add a shrinker callback to be called from the vm
+ * Add a shrinker callback to be called from the vm.
+ *
+ * It cannot fail, unless the flag SHRINKER_NUMA_AWARE is specified.
+ * With this flag set, this function will allocate memory and may fail.
  */
-void register_shrinker(struct shrinker *shrinker)
+int register_shrinker(struct shrinker *shrinker)
 {
-	atomic_long_set(&shrinker->nr_in_batch, 0);
+	/*
+	 * If we only have one possible node in the system anyway, save
+	 * ourselves the trouble and disable NUMA aware behavior. This way we
+	 * will allocate nothing and save memory and some small loop time
+	 * later.
+	 */
+	if (nr_node_ids == 1)
+		shrinker->flags &= ~SHRINKER_NUMA_AWARE;
+
+	if (shrinker->flags & SHRINKER_NUMA_AWARE) {
+		size_t size;
+
+		size = sizeof(*shrinker->nr_deferred_node) * nr_node_ids;
+		shrinker->nr_deferred_node = kzalloc(size, GFP_KERNEL);
+		if (!shrinker->nr_deferred_node)
+			return -ENOMEM;
+	} else
+		atomic_long_set(&shrinker->nr_deferred, 0);
+
 	down_write(&shrinker_rwsem);
 	list_add_tail(&shrinker->list, &shrinker_list);
 	up_write(&shrinker_rwsem);
+	return 0;
 }
 EXPORT_SYMBOL(register_shrinker);
 
@@ -186,6 +208,116 @@ static inline int do_shrinker_shrink(struct shrinker *shrinker,
 }
 
 #define SHRINK_BATCH 128
+
+static unsigned long
+shrink_slab_node(struct shrink_control *shrinkctl, struct shrinker *shrinker,
+		 unsigned long nr_pages_scanned, unsigned long lru_pages,
+		 atomic_long_t *deferred)
+{
+	unsigned long freed = 0;
+	unsigned long long delta;
+	long total_scan;
+	long max_pass;
+	long nr;
+	long new_nr;
+	long batch_size = shrinker->batch ? shrinker->batch
+					  : SHRINK_BATCH;
+
+	if (shrinker->scan_objects) {
+		max_pass = shrinker->count_objects(shrinker, shrinkctl);
+		WARN_ON(max_pass < 0);
+	} else
+		max_pass = do_shrinker_shrink(shrinker, shrinkctl, 0);
+	if (max_pass <= 0)
+		return 0;
+
+	/*
+	 * copy the current shrinker scan count into a local variable
+	 * and zero it so that other concurrent shrinker invocations
+	 * don't also do this scanning work.
+	 */
+	nr = atomic_long_xchg(deferred, 0);
+
+	total_scan = nr;
+	delta = (4 * nr_pages_scanned) / shrinker->seeks;
+	delta *= max_pass;
+	do_div(delta, lru_pages + 1);
+	total_scan += delta;
+	if (total_scan < 0) {
+		printk(KERN_ERR
+		"shrink_slab: %pF negative objects to delete nr=%ld\n",
+		       shrinker->shrink, total_scan);
+		total_scan = max_pass;
+	}
+
+	/*
+	 * We need to avoid excessive windup on filesystem shrinkers
+	 * due to large numbers of GFP_NOFS allocations causing the
+	 * shrinkers to return -1 all the time. This results in a large
+	 * nr being built up so when a shrink that can do some work
+	 * comes along it empties the entire cache due to nr >>>
+	 * max_pass.  This is bad for sustaining a working set in
+	 * memory.
+	 *
+	 * Hence only allow the shrinker to scan the entire cache when
+	 * a large delta change is calculated directly.
+	 */
+	if (delta < max_pass / 4)
+		total_scan = min(total_scan, max_pass / 2);
+
+	/*
+	 * Avoid risking looping forever due to too large nr value:
+	 * never try to free more than twice the estimate number of
+	 * freeable entries.
+	 */
+	if (total_scan > max_pass * 2)
+		total_scan = max_pass * 2;
+
+	trace_mm_shrink_slab_start(shrinker, shrinkctl, nr,
+				nr_pages_scanned, lru_pages,
+				max_pass, delta, total_scan);
+
+	while (total_scan >= batch_size) {
+		long ret;
+
+		if (shrinker->scan_objects) {
+			shrinkctl->nr_to_scan = batch_size;
+			ret = shrinker->scan_objects(shrinker, shrinkctl);
+
+			if (ret == -1)
+				break;
+			freed += ret;
+		} else {
+			int nr_before;
+			nr_before = do_shrinker_shrink(shrinker, shrinkctl, 0);
+			ret = do_shrinker_shrink(shrinker, shrinkctl,
+							batch_size);
+			if (ret == -1)
+				break;
+			if (ret < nr_before)
+				freed += nr_before - ret;
+		}
+
+		count_vm_events(SLABS_SCANNED, batch_size);
+		total_scan -= batch_size;
+
+		cond_resched();
+	}
+
+	/*
+	 * move the unused scan count back into the shrinker in a
+	 * manner that handles concurrent updates. If we exhausted the
+	 * scan, there is no need to do an update.
+	 */
+	if (total_scan > 0)
+		new_nr = atomic_long_add_return(total_scan, deferred);
+	else
+		new_nr = atomic_long_read(deferred);
+
+	trace_mm_shrink_slab_end(shrinker, freed, nr, new_nr);
+	return freed;
+}
+
 /*
  * Call the shrink functions to age shrinkable caches
  *
@@ -222,107 +354,24 @@ unsigned long shrink_slab(struct shrink_control *shrinkctl,
 	}
 
 	list_for_each_entry(shrinker, &shrinker_list, list) {
-		unsigned long long delta;
-		long total_scan;
-		long max_pass;
-		long nr;
-		long new_nr;
-		long batch_size = shrinker->batch ? shrinker->batch
-						  : SHRINK_BATCH;
 
-		if (shrinker->scan_objects) {
-			max_pass = shrinker->count_objects(shrinker, shrinkctl);
-			WARN_ON(max_pass < 0);
-		} else
-			max_pass = do_shrinker_shrink(shrinker, shrinkctl, 0);
-		if (max_pass <= 0)
-			continue;
+		if (!(shrinker->flags & SHRINKER_NUMA_AWARE)) {
+			shrinkctl->nid = 0;
 
-		/*
-		 * copy the current shrinker scan count into a local variable
-		 * and zero it so that other concurrent shrinker invocations
-		 * don't also do this scanning work.
-		 */
-		nr = atomic_long_xchg(&shrinker->nr_in_batch, 0);
-
-		total_scan = nr;
-		delta = (4 * nr_pages_scanned) / shrinker->seeks;
-		delta *= max_pass;
-		do_div(delta, lru_pages + 1);
-		total_scan += delta;
-		if (total_scan < 0) {
-			printk(KERN_ERR
-			"shrink_slab: %pF negative objects to delete nr=%ld\n",
-			       shrinker->shrink, total_scan);
-			total_scan = max_pass;
+			freed += shrink_slab_node(shrinkctl, shrinker,
+				 nr_pages_scanned, lru_pages,
+				 &shrinker->nr_deferred);
+			continue;
 		}
 
-		/*
-		 * We need to avoid excessive windup on filesystem shrinkers
-		 * due to large numbers of GFP_NOFS allocations causing the
-		 * shrinkers to return -1 all the time. This results in a large
-		 * nr being built up so when a shrink that can do some work
-		 * comes along it empties the entire cache due to nr >>>
-		 * max_pass.  This is bad for sustaining a working set in
-		 * memory.
-		 *
-		 * Hence only allow the shrinker to scan the entire cache when
-		 * a large delta change is calculated directly.
-		 */
-		if (delta < max_pass / 4)
-			total_scan = min(total_scan, max_pass / 2);
-
-		/*
-		 * Avoid risking looping forever due to too large nr value:
-		 * never try to free more than twice the estimate number of
-		 * freeable entries.
-		 */
-		if (total_scan > max_pass * 2)
-			total_scan = max_pass * 2;
-
-		trace_mm_shrink_slab_start(shrinker, shrinkctl, nr,
-					nr_pages_scanned, lru_pages,
-					max_pass, delta, total_scan);
-
-		while (total_scan >= batch_size) {
-			long ret;
-
-			if (shrinker->scan_objects) {
-				shrinkctl->nr_to_scan = batch_size;
-				ret = shrinker->scan_objects(shrinker, shrinkctl);
-
-				if (ret == -1)
-					break;
-				freed += ret;
-			} else {
-				int nr_before;
-				nr_before = do_shrinker_shrink(shrinker, shrinkctl, 0);
-				ret = do_shrinker_shrink(shrinker, shrinkctl,
-								batch_size);
-				if (ret == -1)
-					break;
-				if (ret < nr_before)
-					freed += nr_before - ret;
-			}
-
-			count_vm_events(SLABS_SCANNED, batch_size);
-			total_scan -= batch_size;
+		for_each_node_mask(shrinkctl->nid, shrinkctl->nodes_to_scan) {
+			if (!node_online(shrinkctl->nid))
+				continue;
 
-			cond_resched();
+			freed += shrink_slab_node(shrinkctl, shrinker,
+				 nr_pages_scanned, lru_pages,
+				 &shrinker->nr_deferred_node[shrinkctl->nid]);
 		}
-
-		/*
-		 * move the unused scan count back into the shrinker in a
-		 * manner that handles concurrent updates. If we exhausted the
-		 * scan, there is no need to do an update.
-		 */
-		if (total_scan > 0)
-			new_nr = atomic_long_add_return(total_scan,
-					&shrinker->nr_in_batch);
-		else
-			new_nr = atomic_long_read(&shrinker->nr_in_batch);
-
-		trace_mm_shrink_slab_end(shrinker, freed, nr, new_nr);
 	}
 	up_read(&shrinker_rwsem);
 out:
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
