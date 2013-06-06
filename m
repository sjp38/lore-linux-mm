Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 021AC6B005A
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 16:35:01 -0400 (EDT)
From: Glauber Costa <glommer@openvz.org>
Subject: [PATCH v11 14/25] vmscan: per-node deferred work
Date: Fri,  7 Jun 2013 00:34:47 +0400
Message-Id: <1370550898-26711-15-git-send-email-glommer@openvz.org>
In-Reply-To: <1370550898-26711-1-git-send-email-glommer@openvz.org>
References: <1370550898-26711-1-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, mgorman@suse.de, david@fromorbit.com, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suze.cz, hannes@cmpxchg.org, hughd@google.com, gthelen@google.com, Glauber Costa <glommer@openvz.org>, Dave Chinner <dchinner@redhat.com>

The list_lru infrastructure already keeps per-node LRU lists in its
node-specific list_lru_node arrays and provide us with a per-node API, and the
shrinkers are properly equiped with node information. This means that we can
now focus our shrinking effort in a single node, but the work that is deferred
from one run to another is kept global at nr_in_batch. Work can be deferred,
for instance, during direct reclaim under a GFP_NOFS allocation, where
situation, all the filesystem shrinkers will be prevented from running and
accumulate in nr_in_batch the amount of work they should have done, but could
not.

This creates an impedance problem, where upon node pressure, work deferred will
accumulate and end up being flushed in other nodes. The problem we describe is
particularly harmful in big machines, where many nodes can accumulate at the
same time, all adding to the global counter nr_in_batch.  As we accumulate
more and more, we start to ask for the caches to flush even bigger numbers. The
result is that the caches are depleted and do not stabilize. To achieve stable
steady state behavior, we need to tackle it differently.

In this patch we keep the deferred count per-node, in the new array
nr_deferred[] (the name is also a bit more descriptive) and will never
accumulate that to other nodes.

[ v11: simplified numa awareness handling ]

Signed-off-by: Glauber Costa <glommer@openvz.org>
Cc: Dave Chinner <dchinner@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
---
 include/linux/shrinker.h |  14 ++-
 mm/vmscan.c              | 241 +++++++++++++++++++++++++++--------------------
 2 files changed, 152 insertions(+), 103 deletions(-)

diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
index 76f520c..8f80f24 100644
--- a/include/linux/shrinker.h
+++ b/include/linux/shrinker.h
@@ -19,6 +19,8 @@ struct shrink_control {
 
 	/* shrink from these nodes */
 	nodemask_t nodes_to_scan;
+	/* current node being shrunk (for NUMA aware shrinkers) */
+	int nid;
 };
 
 #define SHRINK_STOP (~0UL)
@@ -44,6 +46,8 @@ struct shrink_control {
  * due to potential deadlocks. If SHRINK_STOP is returned, then no further
  * attempts to call the @scan_objects will be made from the current reclaim
  * context.
+ *
+ * @flags determine the shrinker abilities, like numa awareness
  */
 struct shrinker {
 	int (*shrink)(struct shrinker *, struct shrink_control *sc);
@@ -54,12 +58,18 @@ struct shrinker {
 
 	int seeks;	/* seeks to recreate an obj */
 	long batch;	/* reclaim batch size, 0 = default */
+	unsigned long flags;
 
 	/* These are for internal use */
 	struct list_head list;
-	atomic_long_t nr_in_batch; /* objs pending delete */
+	/* objs pending delete, per node */
+	atomic_long_t *nr_deferred;
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
index f39cae0..22ac8de 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -155,14 +155,31 @@ static unsigned long get_lru_size(struct lruvec *lruvec, enum lru_list lru)
 }
 
 /*
- * Add a shrinker callback to be called from the vm
+ * Add a shrinker callback to be called from the vm.
  */
-void register_shrinker(struct shrinker *shrinker)
+int register_shrinker(struct shrinker *shrinker)
 {
-	atomic_long_set(&shrinker->nr_in_batch, 0);
+	size_t size = sizeof(*shrinker->nr_deferred);
+
+	/*
+	 * If we only have one possible node in the system anyway, save
+	 * ourselves the trouble and disable NUMA aware behavior. This way we
+	 * will save memory and some small loop time later.
+	 */
+	if (nr_node_ids == 1)
+		shrinker->flags &= ~SHRINKER_NUMA_AWARE;
+
+	if (shrinker->flags & SHRINKER_NUMA_AWARE)
+		size *= nr_node_ids;
+
+	shrinker->nr_deferred = kzalloc(size, GFP_KERNEL);
+	if (!shrinker->nr_deferred)
+		return -ENOMEM;
+
 	down_write(&shrinker_rwsem);
 	list_add_tail(&shrinker->list, &shrinker_list);
 	up_write(&shrinker_rwsem);
+	return 0;
 }
 EXPORT_SYMBOL(register_shrinker);
 
@@ -186,6 +203,118 @@ static inline int do_shrinker_shrink(struct shrinker *shrinker,
 }
 
 #define SHRINK_BATCH 128
+
+static unsigned long
+shrink_slab_node(struct shrink_control *shrinkctl, struct shrinker *shrinker,
+		 unsigned long nr_pages_scanned, unsigned long lru_pages)
+{
+	unsigned long freed = 0;
+	unsigned long long delta;
+	long total_scan;
+	long max_pass;
+	long nr;
+	long new_nr;
+	int nid = shrinkctl->nid;
+	long batch_size = shrinker->batch ? shrinker->batch
+					  : SHRINK_BATCH;
+
+	if (shrinker->count_objects)
+		max_pass = shrinker->count_objects(shrinker, shrinkctl);
+	else
+		max_pass = do_shrinker_shrink(shrinker, shrinkctl, 0);
+	if (max_pass == 0)
+		return 0;
+
+	/*
+	 * copy the current shrinker scan count into a local variable
+	 * and zero it so that other concurrent shrinker invocations
+	 * don't also do this scanning work.
+	 */
+	nr = atomic_long_xchg(&shrinker->nr_deferred[nid], 0);
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
+
+		if (shrinker->scan_objects) {
+			unsigned long ret;
+			shrinkctl->nr_to_scan = batch_size;
+			ret = shrinker->scan_objects(shrinker, shrinkctl);
+
+			if (ret == SHRINK_STOP)
+				break;
+			freed += ret;
+		} else {
+			int nr_before;
+			long ret;
+
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
+		new_nr = atomic_long_add_return(total_scan,
+						&shrinker->nr_deferred[nid]);
+	else
+		new_nr = atomic_long_read(&shrinker->nr_deferred[nid]);
+
+	trace_mm_shrink_slab_end(shrinker, freed, nr, new_nr);
+	return freed;
+}
+
 /*
  * Call the shrink functions to age shrinkable caches
  *
@@ -227,108 +356,18 @@ unsigned long shrink_slab(struct shrink_control *shrinkctl,
 	}
 
 	list_for_each_entry(shrinker, &shrinker_list, list) {
-		unsigned long long delta;
-		long total_scan;
-		long max_pass;
-		long nr;
-		long new_nr;
-		long batch_size = shrinker->batch ? shrinker->batch
-						  : SHRINK_BATCH;
-
-		if (shrinker->count_objects)
-			max_pass = shrinker->count_objects(shrinker, shrinkctl);
-		else
-			max_pass = do_shrinker_shrink(shrinker, shrinkctl, 0);
-		if (max_pass == 0)
-			continue;
-
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
-		}
-
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
-
-			if (shrinker->scan_objects) {
-				unsigned long ret;
-				shrinkctl->nr_to_scan = batch_size;
-				ret = shrinker->scan_objects(shrinker, shrinkctl);
+		for_each_node_mask(shrinkctl->nid, shrinkctl->nodes_to_scan) {
+			if (!node_online(shrinkctl->nid))
+				continue;
 
-				if (ret == SHRINK_STOP)
-					break;
-				freed += ret;
-			} else {
-				int nr_before;
-				long ret;
-
-				nr_before = do_shrinker_shrink(shrinker, shrinkctl, 0);
-				ret = do_shrinker_shrink(shrinker, shrinkctl,
-								batch_size);
-				if (ret == -1)
-					break;
-				if (ret < nr_before)
-					freed += nr_before - ret;
-			}
+			if (!(shrinker->flags & SHRINKER_NUMA_AWARE) &&
+			    (shrinkctl->nid != 0))
+				break;
 
-			count_vm_events(SLABS_SCANNED, batch_size);
-			total_scan -= batch_size;
+			freed += shrink_slab_node(shrinkctl, shrinker,
+				 nr_pages_scanned, lru_pages);
 
-			cond_resched();
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
