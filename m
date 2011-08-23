Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 054706B016E
	for <linux-mm@kvack.org>; Tue, 23 Aug 2011 04:56:53 -0400 (EDT)
From: Dave Chinner <david@fromorbit.com>
Subject: [PATCH 04/13] mm: new shrinker API
Date: Tue, 23 Aug 2011 18:56:17 +1000
Message-Id: <1314089786-20535-5-git-send-email-david@fromorbit.com>
In-Reply-To: <1314089786-20535-1-git-send-email-david@fromorbit.com>
References: <1314089786-20535-1-git-send-email-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, khlebnikov@openvz.org

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

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 include/linux/shrinker.h |   38 +++++++++++++++++++++++++++-----------
 1 files changed, 27 insertions(+), 11 deletions(-)

diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
index 790651b..50f213f 100644
--- a/include/linux/shrinker.h
+++ b/include/linux/shrinker.h
@@ -3,32 +3,47 @@
 
 /*
  * This struct is used to pass information from page reclaim to the shrinkers.
- * We consolidate the values for easier extention later.
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
+ * @scan_objects will only be called if @count_objects returned a positive value
+ * for the number of freeable objects. The callout should scan the cache and
+ * attemp to free items from the cache. It should then return the number of
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
 
@@ -36,6 +51,7 @@ struct shrinker {
 	struct list_head list;
 	long nr;	/* objs pending delete */
 };
+
 #define DEFAULT_SEEKS 2 /* A good number if you don't know better. */
 extern void register_shrinker(struct shrinker *);
 extern void unregister_shrinker(struct shrinker *);
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
