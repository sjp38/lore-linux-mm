Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id D5909680F85
	for <linux-mm@kvack.org>; Tue,  7 Nov 2017 18:05:24 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id e195so3673279itc.7
        for <linux-mm@kvack.org>; Tue, 07 Nov 2017 15:05:24 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o194sor7001010ita.0.2017.11.07.15.05.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 Nov 2017 15:05:23 -0800 (PST)
From: Shakeel Butt <shakeelb@google.com>
Subject: [PATCH] mm, shrinker: make shrinker_list lockless
Date: Tue,  7 Nov 2017 15:05:09 -0800
Message-Id: <20171107230509.136592-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Huang Ying <ying.huang@intel.com>, Mel Gorman <mgorman@techsingularity.net>, Vladimir Davydov <vdavydov.dev@gmail.com>, Michal Hocko <mhocko@kernel.org>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Shakeel Butt <shakeelb@google.com>

In our production, we have observed that the job loader gets stuck for
10s of seconds while doing mount operation. It turns out that it was
stuck in register_shrinker() and some unrelated job was under memory
pressure and spending time in shrink_slab(). Our machines have a lot
of shrinkers registered and jobs under memory pressure has to traverse
all of those memcg-aware shrinkers and do affect unrelated jobs which
want to register their own shrinkers.

This patch has made the shrinker_list traversal lockless and shrinker
register remain fast. For the shrinker unregister, atomic counter
has been introduced to avoid synchronize_rcu() call. The fields of
struct shrinker has been rearraged to make sure that the size does
not increase.

Signed-off-by: Shakeel Butt <shakeelb@google.com>
---
 include/linux/shrinker.h |  4 +++-
 mm/vmscan.c              | 54 +++++++++++++++++++++++++++++-------------------
 2 files changed, 36 insertions(+), 22 deletions(-)

diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
index 388ff2936a87..434b76ef9367 100644
--- a/include/linux/shrinker.h
+++ b/include/linux/shrinker.h
@@ -60,14 +60,16 @@ struct shrinker {
 	unsigned long (*scan_objects)(struct shrinker *,
 				      struct shrink_control *sc);
 
+	unsigned int flags;
 	int seeks;	/* seeks to recreate an obj */
 	long batch;	/* reclaim batch size, 0 = default */
-	unsigned long flags;
 
 	/* These are for internal use */
 	struct list_head list;
 	/* objs pending delete, per node */
 	atomic_long_t *nr_deferred;
+	/* Number of active do_shrink_slab calls to this shrinker */
+	atomic_t nr_active;
 };
 #define DEFAULT_SEEKS 2 /* A good number if you don't know better. */
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index eb2f0315b8c0..f58c0d973bc4 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -157,7 +157,7 @@ int vm_swappiness = 60;
 unsigned long vm_total_pages;
 
 static LIST_HEAD(shrinker_list);
-static DECLARE_RWSEM(shrinker_rwsem);
+static DEFINE_SPINLOCK(shrinker_lock);
 
 #ifdef CONFIG_MEMCG
 static bool global_reclaim(struct scan_control *sc)
@@ -285,21 +285,40 @@ int register_shrinker(struct shrinker *shrinker)
 	if (!shrinker->nr_deferred)
 		return -ENOMEM;
 
-	down_write(&shrinker_rwsem);
-	list_add_tail(&shrinker->list, &shrinker_list);
-	up_write(&shrinker_rwsem);
+	atomic_set(&shrinker->nr_active, 0);
+	spin_lock(&shrinker_lock);
+	list_add_tail_rcu(&shrinker->list, &shrinker_list);
+	spin_unlock(&shrinker_lock);
 	return 0;
 }
 EXPORT_SYMBOL(register_shrinker);
 
+static void get_shrinker(struct shrinker *shrinker)
+{
+	atomic_inc(&shrinker->nr_active);
+}
+
+static void put_shrinker(struct shrinker *shrinker)
+{
+	if (!atomic_dec_return(&shrinker->nr_active))
+		wake_up_atomic_t(&shrinker->nr_active);
+}
+
+static int shrinker_wait_atomic_t(atomic_t *p)
+{
+	schedule();
+	return 0;
+}
 /*
  * Remove one
  */
 void unregister_shrinker(struct shrinker *shrinker)
 {
-	down_write(&shrinker_rwsem);
-	list_del(&shrinker->list);
-	up_write(&shrinker_rwsem);
+	spin_lock(&shrinker_lock);
+	list_del_rcu(&shrinker->list);
+	spin_unlock(&shrinker_lock);
+	wait_on_atomic_t(&shrinker->nr_active, shrinker_wait_atomic_t,
+			 TASK_UNINTERRUPTIBLE);
 	kfree(shrinker->nr_deferred);
 }
 EXPORT_SYMBOL(unregister_shrinker);
@@ -404,7 +423,7 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 		total_scan -= shrinkctl->nr_scanned;
 		scanned += shrinkctl->nr_scanned;
 
-		cond_resched();
+		cond_resched_rcu();
 	}
 
 	if (next_deferred >= scanned)
@@ -468,18 +487,9 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
 	if (nr_scanned == 0)
 		nr_scanned = SWAP_CLUSTER_MAX;
 
-	if (!down_read_trylock(&shrinker_rwsem)) {
-		/*
-		 * If we would return 0, our callers would understand that we
-		 * have nothing else to shrink and give up trying. By returning
-		 * 1 we keep it going and assume we'll be able to shrink next
-		 * time.
-		 */
-		freed = 1;
-		goto out;
-	}
+	rcu_read_lock();
 
-	list_for_each_entry(shrinker, &shrinker_list, list) {
+	list_for_each_entry_rcu(shrinker, &shrinker_list, list) {
 		struct shrink_control sc = {
 			.gfp_mask = gfp_mask,
 			.nid = nid,
@@ -498,11 +508,13 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
 		if (!(shrinker->flags & SHRINKER_NUMA_AWARE))
 			sc.nid = 0;
 
+		get_shrinker(shrinker);
 		freed += do_shrink_slab(&sc, shrinker, nr_scanned, nr_eligible);
+		put_shrinker(shrinker);
 	}
 
-	up_read(&shrinker_rwsem);
-out:
+	rcu_read_unlock();
+
 	cond_resched();
 	return freed;
 }
-- 
2.15.0.403.gc27cc4dac6-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
