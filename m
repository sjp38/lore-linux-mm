Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id B19E16B0096
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 16:35:39 -0400 (EDT)
From: Glauber Costa <glommer@openvz.org>
Subject: [PATCH v11 24/25] shrinker: Kill old ->shrink API.
Date: Fri,  7 Jun 2013 00:34:57 +0400
Message-Id: <1370550898-26711-25-git-send-email-glommer@openvz.org>
In-Reply-To: <1370550898-26711-1-git-send-email-glommer@openvz.org>
References: <1370550898-26711-1-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, mgorman@suse.de, david@fromorbit.com, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suze.cz, hannes@cmpxchg.org, hughd@google.com, gthelen@google.com, Dave Chinner <dchinner@redhat.com>, Glauber Costa <glommer@openvz.org>

From: Dave Chinner <dchinner@redhat.com>

There are no more users of this API, so kill it dead, dead, dead and
quietly bury the corpse in a shallow, unmarked grave in a dark
forest deep in the hills...

[ glommer: added flowers to the grave ]
Signed-off-by: Dave Chinner <dchinner@redhat.com>
Signed-off-by: Glauber Costa <glommer@openvz.org>
Reviewed-by: Greg Thelen <gthelen@google.com>
Acked-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/shrinker.h      | 15 +++++----------
 include/trace/events/vmscan.h |  4 ++--
 mm/vmscan.c                   | 40 ++++++++--------------------------------
 3 files changed, 15 insertions(+), 44 deletions(-)

diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
index 8f80f24..68c0970 100644
--- a/include/linux/shrinker.h
+++ b/include/linux/shrinker.h
@@ -7,14 +7,15 @@
  *
  * The 'gfpmask' refers to the allocation we are currently trying to
  * fulfil.
- *
- * Note that 'shrink' will be passed nr_to_scan == 0 when the VM is
- * querying the cache size, so a fastpath for that case is appropriate.
  */
 struct shrink_control {
 	gfp_t gfp_mask;
 
-	/* How many slab objects shrinker() should scan and try to reclaim */
+	/*
+	 * How many objects scan_objects should scan and try to reclaim.
+	 * This is reset before every call, so it is safe for callees
+	 * to modify.
+	 */
 	unsigned long nr_to_scan;
 
 	/* shrink from these nodes */
@@ -27,11 +28,6 @@ struct shrink_control {
 /*
  * A callback you can register to apply pressure to ageable caches.
  *
- * @shrink() should look through the least-recently-used 'nr_to_scan' entries
- * and attempt to free them up.  It should return the number of objects which
- * remain in the cache.  If it returns -1, it means it cannot do any scanning at
- * this time (eg. there is a risk of deadlock).
- *
  * @count_objects should return the number of freeable items in the cache. If
  * there are no objects to free or the number of freeable items cannot be
  * determined, it should return 0. No deadlock checks should be done during the
@@ -50,7 +46,6 @@ struct shrink_control {
  * @flags determine the shrinker abilities, like numa awareness
  */
 struct shrinker {
-	int (*shrink)(struct shrinker *, struct shrink_control *sc);
 	unsigned long (*count_objects)(struct shrinker *,
 				       struct shrink_control *sc);
 	unsigned long (*scan_objects)(struct shrinker *,
diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index 63cfccc..132a985 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -202,7 +202,7 @@ TRACE_EVENT(mm_shrink_slab_start,
 
 	TP_fast_assign(
 		__entry->shr = shr;
-		__entry->shrink = shr->shrink;
+		__entry->shrink = shr->scan_objects;
 		__entry->nr_objects_to_shrink = nr_objects_to_shrink;
 		__entry->gfp_flags = sc->gfp_mask;
 		__entry->pgs_scanned = pgs_scanned;
@@ -241,7 +241,7 @@ TRACE_EVENT(mm_shrink_slab_end,
 
 	TP_fast_assign(
 		__entry->shr = shr;
-		__entry->shrink = shr->shrink;
+		__entry->shrink = shr->scan_objects;
 		__entry->unused_scan = unused_scan_cnt;
 		__entry->new_scan = new_scan_cnt;
 		__entry->retval = shrinker_retval;
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 22ac8de..fe73724 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -194,14 +194,6 @@ void unregister_shrinker(struct shrinker *shrinker)
 }
 EXPORT_SYMBOL(unregister_shrinker);
 
-static inline int do_shrinker_shrink(struct shrinker *shrinker,
-				     struct shrink_control *sc,
-				     unsigned long nr_to_scan)
-{
-	sc->nr_to_scan = nr_to_scan;
-	return (*shrinker->shrink)(shrinker, sc);
-}
-
 #define SHRINK_BATCH 128
 
 static unsigned long
@@ -218,10 +210,7 @@ shrink_slab_node(struct shrink_control *shrinkctl, struct shrinker *shrinker,
 	long batch_size = shrinker->batch ? shrinker->batch
 					  : SHRINK_BATCH;
 
-	if (shrinker->count_objects)
-		max_pass = shrinker->count_objects(shrinker, shrinkctl);
-	else
-		max_pass = do_shrinker_shrink(shrinker, shrinkctl, 0);
+	max_pass = shrinker->count_objects(shrinker, shrinkctl);
 	if (max_pass == 0)
 		return 0;
 
@@ -240,7 +229,7 @@ shrink_slab_node(struct shrink_control *shrinkctl, struct shrinker *shrinker,
 	if (total_scan < 0) {
 		printk(KERN_ERR
 		"shrink_slab: %pF negative objects to delete nr=%ld\n",
-		       shrinker->shrink, total_scan);
+		       shrinker->scan_objects, total_scan);
 		total_scan = max_pass;
 	}
 
@@ -273,26 +262,13 @@ shrink_slab_node(struct shrink_control *shrinkctl, struct shrinker *shrinker,
 
 	while (total_scan >= batch_size) {
 
-		if (shrinker->scan_objects) {
-			unsigned long ret;
-			shrinkctl->nr_to_scan = batch_size;
-			ret = shrinker->scan_objects(shrinker, shrinkctl);
-
-			if (ret == SHRINK_STOP)
-				break;
-			freed += ret;
-		} else {
-			int nr_before;
-			long ret;
+		unsigned long ret;
+		shrinkctl->nr_to_scan = batch_size;
+		ret = shrinker->scan_objects(shrinker, shrinkctl);
 
-			nr_before = do_shrinker_shrink(shrinker, shrinkctl, 0);
-			ret = do_shrinker_shrink(shrinker, shrinkctl,
-							batch_size);
-			if (ret == -1)
-				break;
-			if (ret < nr_before)
-				freed += nr_before - ret;
-		}
+		if (ret == SHRINK_STOP)
+			break;
+		freed += ret;
 
 		count_vm_events(SLABS_SCANNED, batch_size);
 		total_scan -= batch_size;
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
