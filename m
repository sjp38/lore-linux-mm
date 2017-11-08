Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id D19AC6B02C9
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 12:38:29 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id d66so6066019ioe.23
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 09:38:29 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y3sor1998786itg.14.2017.11.08.09.38.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 08 Nov 2017 09:38:28 -0800 (PST)
From: Shakeel Butt <shakeelb@google.com>
Subject: [PATCH v2] mm, shrinker: make shrinker_list lockless
Date: Wed,  8 Nov 2017 09:37:40 -0800
Message-Id: <20171108173740.115166-1-shakeelb@google.com>
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
not increase for x86_64.

The shrinker functions are allowed to reschedule() and thus can not
be called with rcu read lock. One way to resolve that is to use
srcu read lock but then ifdefs has to be used as SRCU is behind
CONFIG_SRCU. Another way is to just release the rcu read lock before
calling the shrinker and reacquire on the return. The atomic counter
will make sure that the shrinker entry will not be freed under us.

Signed-off-by: Shakeel Butt <shakeelb@google.com>
---
Changelog since v1:
- release and reacquire rcu lock across shrinker call.

 include/linux/shrinker.h |  4 +++-
 mm/vmscan.c              | 54 ++++++++++++++++++++++++++++++------------------
 2 files changed, 37 insertions(+), 21 deletions(-)

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
index eb2f0315b8c0..6cec46ac6d95 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -157,7 +157,7 @@ int vm_swappiness = 60;
 unsigned long vm_total_pages;
 
 static LIST_HEAD(shrinker_list);
-static DECLARE_RWSEM(shrinker_rwsem);
+static DEFINE_SPINLOCK(shrinker_lock);
 
 #ifdef CONFIG_MEMCG
 static bool global_reclaim(struct scan_control *sc)
@@ -285,21 +285,42 @@ int register_shrinker(struct shrinker *shrinker)
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
+	rcu_read_unlock();
+}
+
+static void put_shrinker(struct shrinker *shrinker)
+{
+	rcu_read_lock();
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
@@ -468,18 +489,9 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
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
@@ -498,11 +510,13 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
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
