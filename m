Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 16AF56B00D5
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 10:02:00 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v3 20/32] shrinker: Kill old ->shrink API.
Date: Mon,  8 Apr 2013 18:00:47 +0400
Message-Id: <1365429659-22108-21-git-send-email-glommer@parallels.com>
In-Reply-To: <1365429659-22108-1-git-send-email-glommer@parallels.com>
References: <1365429659-22108-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: cgroups@vger.kernel.org, Dave Shrinnker <david@fromorbit.com>, Serge Hallyn <serge.hallyn@canonical.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, hughd@google.com, linux-fsdevel@vger.kernel.org, containers@lists.linux-foundation.org, Greg Thelen <gthelen@google.com>, Dave Chinner <dchinner@redhat.com>

From: Dave Chinner <dchinner@redhat.com>

There are no more users of this API, so kill it dead, dead, dead and
quietly bury the corpse in a shallow, unmarked grave in a dark
forest deep in the hills...

[ glommer: added flowers to the grave ]
Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 include/linux/shrinker.h      | 15 +++++----------
 include/trace/events/vmscan.h |  4 ++--
 mm/vmscan.c                   | 40 ++++++++--------------------------------
 3 files changed, 15 insertions(+), 44 deletions(-)

diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
index e71286f..d4636a0 100644
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
 	long nr_to_scan;
 
 	/* shrink from these nodes */
@@ -24,11 +25,6 @@ struct shrink_control {
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
@@ -44,7 +40,6 @@ struct shrink_control {
  * @scan_objects will be made from the current reclaim context.
  */
 struct shrinker {
-	int (*shrink)(struct shrinker *, struct shrink_control *sc);
 	long (*count_objects)(struct shrinker *, struct shrink_control *sc);
 	long (*scan_objects)(struct shrinker *, struct shrink_control *sc);
 
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
index 6926e09..232dfcb 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -176,14 +176,6 @@ void unregister_shrinker(struct shrinker *shrinker)
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
 /*
  * Call the shrink functions to age shrinkable caches
@@ -229,11 +221,8 @@ unsigned long shrink_slab(struct shrink_control *sc,
 		long batch_size = shrinker->batch ? shrinker->batch
 						  : SHRINK_BATCH;
 
-		if (shrinker->scan_objects) {
-			max_pass = shrinker->count_objects(shrinker, sc);
-			WARN_ON(max_pass < 0);
-		} else
-			max_pass = do_shrinker_shrink(shrinker, sc, 0);
+		max_pass = shrinker->count_objects(shrinker, sc);
+		WARN_ON(max_pass < 0);
 		if (max_pass <= 0)
 			continue;
 
@@ -252,7 +241,7 @@ unsigned long shrink_slab(struct shrink_control *sc,
 		if (total_scan < 0) {
 			printk(KERN_ERR
 			"shrink_slab: %pF negative objects to delete nr=%ld\n",
-			       shrinker->shrink, total_scan);
+			       shrinker->scan_objects, total_scan);
 			total_scan = max_pass;
 		}
 
@@ -286,24 +275,11 @@ unsigned long shrink_slab(struct shrink_control *sc,
 		do {
 			long ret;
 
-			if (shrinker->scan_objects) {
-				sc->nr_to_scan = batch_size;
-				ret = shrinker->scan_objects(shrinker, sc);
-
-				if (ret == -1)
-					break;
-				freed += ret;
-			} else {
-				int nr_before;
-
-				nr_before = do_shrinker_shrink(shrinker, sc, 0);
-				ret = do_shrinker_shrink(shrinker, sc,
-								batch_size);
-				if (ret == -1)
-					break;
-				if (ret < nr_before)
-					freed += nr_before - ret;
-			}
+			sc->nr_to_scan = batch_size;
+			ret = shrinker->scan_objects(shrinker, sc);
+			if (ret == -1)
+				break;
+			freed += ret;
 
 			count_vm_events(SLABS_SCANNED, batch_size);
 			total_scan -= batch_size;
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
