Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id D28CB6B0036
	for <linux-mm@kvack.org>; Sun, 12 May 2013 14:13:37 -0400 (EDT)
From: Glauber Costa <glommer@openvz.org>
Subject: [PATCH v6 05/31] mm: new shrinker API
Date: Sun, 12 May 2013 22:13:26 +0400
Message-Id: <1368382432-25462-6-git-send-email-glommer@openvz.org>
In-Reply-To: <1368382432-25462-1-git-send-email-glommer@openvz.org>
References: <1368382432-25462-1-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, Dave Chinner <david@fromorbit.com>, Dave Chinner <dchinner@redhat.com>, Glauber Costa <glommer@parallels.com>

From: Dave Chinner <dchinner@redhat.com>

The current shrinker callout API uses an a single shrinker call for
multiple functions. To determine the function, a special magical
value is passed in a parameter to change the behaviour. This
complicates the implementation and return value specification for
the different behaviours.

Separate the two different behaviours into separate operations, one
to return a count of freeable objects in the cache, and another to
scan a certain number of objects in the cache for freeing. In
defining these new operations, ensure the return values and
resultant behaviours are clearly defined and documented.

Modify shrink_slab() to use the new API and implement the callouts
for all the existing shrinkers.

Signed-off-by: Dave Chinner <dchinner@redhat.com>
Signed-off-by: Glauber Costa <glommer@parallels.com>
Acked-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/shrinker.h | 36 ++++++++++++++++++++++++----------
 mm/vmscan.c              | 50 +++++++++++++++++++++++++++++++-----------------
 2 files changed, 58 insertions(+), 28 deletions(-)

diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
index ac6b8ee..c277b4e 100644
--- a/include/linux/shrinker.h
+++ b/include/linux/shrinker.h
@@ -4,31 +4,47 @@
 /*
  * This struct is used to pass information from page reclaim to the shrinkers.
  * We consolidate the values for easier extention later.
+ *
+ * The 'gfpmask' refers to the allocation we are currently trying to
+ * fulfil.
+ *
+ * Note that 'shrink' will be passed nr_to_scan == 0 when the VM is
+ * querying the cache size, so a fastpath for that case is appropriate.
  */
 struct shrink_control {
 	gfp_t gfp_mask;
 
 	/* How many slab objects shrinker() should scan and try to reclaim */
-	unsigned long nr_to_scan;
+	long nr_to_scan;
 };
 
 /*
  * A callback you can register to apply pressure to ageable caches.
  *
- * 'sc' is passed shrink_control which includes a count 'nr_to_scan'
- * and a 'gfpmask'.  It should look through the least-recently-used
- * 'nr_to_scan' entries and attempt to free them up.  It should return
- * the number of objects which remain in the cache.  If it returns -1, it means
- * it cannot do any scanning at this time (eg. there is a risk of deadlock).
+ * @shrink() should look through the least-recently-used 'nr_to_scan' entries
+ * and attempt to free them up.  It should return the number of objects which
+ * remain in the cache.  If it returns -1, it means it cannot do any scanning at
+ * this time (eg. there is a risk of deadlock).
  *
- * The 'gfpmask' refers to the allocation we are currently trying to
- * fulfil.
+ * @count_objects should return the number of freeable items in the cache. If
+ * there are no objects to free or the number of freeable items cannot be
+ * determined, it should return 0. No deadlock checks should be done during the
+ * count callback - the shrinker relies on aggregating scan counts that couldn't
+ * be executed due to potential deadlocks to be run at a later call when the
+ * deadlock condition is no longer pending.
  *
- * Note that 'shrink' will be passed nr_to_scan == 0 when the VM is
- * querying the cache size, so a fastpath for that case is appropriate.
+ * @scan_objects will only be called if @count_objects returned a positive
+ * value for the number of freeable objects. The callout should scan the cache
+ * and attempt to free items from the cache. It should then return the number of
+ * objects freed during the scan, or -1 if progress cannot be made due to
+ * potential deadlocks. If -1 is returned, then no further attempts to call the
+ * @scan_objects will be made from the current reclaim context.
  */
 struct shrinker {
 	int (*shrink)(struct shrinker *, struct shrink_control *sc);
+	long (*count_objects)(struct shrinker *, struct shrink_control *sc);
+	long (*scan_objects)(struct shrinker *, struct shrink_control *sc);
+
 	int seeks;	/* seeks to recreate an obj */
 	long batch;	/* reclaim batch size, 0 = default */
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index fa6a853..fd4639c 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -205,19 +205,19 @@ static inline int do_shrinker_shrink(struct shrinker *shrinker,
  *
  * Returns the number of slab objects which we shrunk.
  */
-unsigned long shrink_slab(struct shrink_control *shrink,
+unsigned long shrink_slab(struct shrink_control *shrinkctl,
 			  unsigned long nr_pages_scanned,
 			  unsigned long lru_pages)
 {
 	struct shrinker *shrinker;
-	unsigned long ret = 0;
+	unsigned long freed = 0;
 
 	if (nr_pages_scanned == 0)
 		nr_pages_scanned = SWAP_CLUSTER_MAX;
 
 	if (!down_read_trylock(&shrinker_rwsem)) {
 		/* Assume we'll be able to shrink next time */
-		ret = 1;
+		freed = 1;
 		goto out;
 	}
 
@@ -225,13 +225,16 @@ unsigned long shrink_slab(struct shrink_control *shrink,
 		unsigned long long delta;
 		long total_scan;
 		long max_pass;
-		int shrink_ret = 0;
 		long nr;
 		long new_nr;
 		long batch_size = shrinker->batch ? shrinker->batch
 						  : SHRINK_BATCH;
 
-		max_pass = do_shrinker_shrink(shrinker, shrink, 0);
+		if (shrinker->scan_objects) {
+			max_pass = shrinker->count_objects(shrinker, shrinkctl);
+			WARN_ON(max_pass < 0);
+		} else
+			max_pass = do_shrinker_shrink(shrinker, shrinkctl, 0);
 		if (max_pass <= 0)
 			continue;
 
@@ -248,8 +251,8 @@ unsigned long shrink_slab(struct shrink_control *shrink,
 		do_div(delta, lru_pages + 1);
 		total_scan += delta;
 		if (total_scan < 0) {
-			printk(KERN_ERR "shrink_slab: %pF negative objects to "
-			       "delete nr=%ld\n",
+			printk(KERN_ERR
+			"shrink_slab: %pF negative objects to delete nr=%ld\n",
 			       shrinker->shrink, total_scan);
 			total_scan = max_pass;
 		}
@@ -277,20 +280,31 @@ unsigned long shrink_slab(struct shrink_control *shrink,
 		if (total_scan > max_pass * 2)
 			total_scan = max_pass * 2;
 
-		trace_mm_shrink_slab_start(shrinker, shrink, nr,
+		trace_mm_shrink_slab_start(shrinker, shrinkctl, nr,
 					nr_pages_scanned, lru_pages,
 					max_pass, delta, total_scan);
 
 		while (total_scan >= batch_size) {
-			int nr_before;
+			long ret;
+
+			if (shrinker->scan_objects) {
+				shrinkctl->nr_to_scan = batch_size;
+				ret = shrinker->scan_objects(shrinker, shrinkctl);
+
+				if (ret == -1)
+					break;
+				freed += ret;
+			} else {
+				int nr_before;
+				nr_before = do_shrinker_shrink(shrinker, shrinkctl, 0);
+				ret = do_shrinker_shrink(shrinker, shrinkctl,
+								batch_size);
+				if (ret == -1)
+					break;
+				if (ret < nr_before)
+					freed += nr_before - ret;
+			}
 
-			nr_before = do_shrinker_shrink(shrinker, shrink, 0);
-			shrink_ret = do_shrinker_shrink(shrinker, shrink,
-							batch_size);
-			if (shrink_ret == -1)
-				break;
-			if (shrink_ret < nr_before)
-				ret += nr_before - shrink_ret;
 			count_vm_events(SLABS_SCANNED, batch_size);
 			total_scan -= batch_size;
 
@@ -308,12 +322,12 @@ unsigned long shrink_slab(struct shrink_control *shrink,
 		else
 			new_nr = atomic_long_read(&shrinker->nr_in_batch);
 
-		trace_mm_shrink_slab_end(shrinker, shrink_ret, nr, new_nr);
+		trace_mm_shrink_slab_end(shrinker, freed, nr, new_nr);
 	}
 	up_read(&shrinker_rwsem);
 out:
 	cond_resched();
-	return ret;
+	return freed;
 }
 
 static inline int is_page_cache_freeable(struct page *page)
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
