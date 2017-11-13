Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0A8E06B0266
	for <linux-mm@kvack.org>; Mon, 13 Nov 2017 16:38:16 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id u10so3586002otc.21
        for <linux-mm@kvack.org>; Mon, 13 Nov 2017 13:38:16 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id g55si1672377otd.345.2017.11.13.13.38.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 13 Nov 2017 13:38:14 -0800 (PST)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH 1/2] mm,vmscan: Kill global shrinker lock.
Date: Tue, 14 Nov 2017 06:37:42 +0900
Message-Id: <1510609063-3327-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Huang Ying <ying.huang@intel.com>, Mel Gorman <mgorman@techsingularity.net>, Vladimir Davydov <vdavydov.dev@gmail.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Shakeel Butt <shakeelb@google.com>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

When shrinker_rwsem was introduced, it was assumed that
register_shrinker()/unregister_shrinker() are really unlikely paths
which are called during initialization and tear down. But nowadays,
register_shrinker()/unregister_shrinker() might be called regularly.
This patch prepares for allowing parallel registration/unregistration
of shrinkers.

Since do_shrink_slab() can reschedule, we cannot protect shrinker_list
using one RCU section. But using atomic_inc()/atomic_dec() for each
do_shrink_slab() call will not impact so much.

This patch uses polling loop with short sleep for unregister_shrinker()
rather than wait_on_atomic_t(), for we can save reader's cost (plain
atomic_dec() compared to atomic_dec_and_test()), we can expect that
do_shrink_slab() of unregistering shrinker likely returns shortly, and
we can avoid khungtaskd warnings when do_shrink_slab() of unregistering
shrinker unexpectedly took so long.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 include/linux/shrinker.h |  3 ++-
 mm/vmscan.c              | 41 +++++++++++++++++++----------------------
 2 files changed, 21 insertions(+), 23 deletions(-)

diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
index 388ff29..333a1d0 100644
--- a/include/linux/shrinker.h
+++ b/include/linux/shrinker.h
@@ -62,9 +62,10 @@ struct shrinker {
 
 	int seeks;	/* seeks to recreate an obj */
 	long batch;	/* reclaim batch size, 0 = default */
-	unsigned long flags;
+	unsigned int flags;
 
 	/* These are for internal use */
+	atomic_t nr_active;
 	struct list_head list;
 	/* objs pending delete, per node */
 	atomic_long_t *nr_deferred;
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 1c1bc95..c8996e8 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -157,7 +157,7 @@ struct scan_control {
 unsigned long vm_total_pages;
 
 static LIST_HEAD(shrinker_list);
-static DECLARE_RWSEM(shrinker_rwsem);
+static DEFINE_MUTEX(shrinker_lock);
 
 #ifdef CONFIG_MEMCG
 static bool global_reclaim(struct scan_control *sc)
@@ -285,9 +285,10 @@ int register_shrinker(struct shrinker *shrinker)
 	if (!shrinker->nr_deferred)
 		return -ENOMEM;
 
-	down_write(&shrinker_rwsem);
-	list_add_tail(&shrinker->list, &shrinker_list);
-	up_write(&shrinker_rwsem);
+	atomic_set(&shrinker->nr_active, 0);
+	mutex_lock(&shrinker_lock);
+	list_add_tail_rcu(&shrinker->list, &shrinker_list);
+	mutex_unlock(&shrinker_lock);
 	return 0;
 }
 EXPORT_SYMBOL(register_shrinker);
@@ -297,9 +298,13 @@ int register_shrinker(struct shrinker *shrinker)
  */
 void unregister_shrinker(struct shrinker *shrinker)
 {
-	down_write(&shrinker_rwsem);
-	list_del(&shrinker->list);
-	up_write(&shrinker_rwsem);
+	mutex_lock(&shrinker_lock);
+	list_del_rcu(&shrinker->list);
+	synchronize_rcu();
+	while (atomic_read(&shrinker->nr_active))
+		schedule_timeout_uninterruptible(1);
+	synchronize_rcu();
+	mutex_unlock(&shrinker_lock);
 	kfree(shrinker->nr_deferred);
 }
 EXPORT_SYMBOL(unregister_shrinker);
@@ -468,18 +473,8 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
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
-
-	list_for_each_entry(shrinker, &shrinker_list, list) {
+	rcu_read_lock();
+	list_for_each_entry_rcu(shrinker, &shrinker_list, list) {
 		struct shrink_control sc = {
 			.gfp_mask = gfp_mask,
 			.nid = nid,
@@ -498,11 +493,13 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
 		if (!(shrinker->flags & SHRINKER_NUMA_AWARE))
 			sc.nid = 0;
 
+		atomic_inc(&shrinker->nr_active);
+		rcu_read_unlock();
 		freed += do_shrink_slab(&sc, shrinker, nr_scanned, nr_eligible);
+		rcu_read_lock();
+		atomic_dec(&shrinker->nr_active);
 	}
-
-	up_read(&shrinker_rwsem);
-out:
+	rcu_read_unlock();
 	cond_resched();
 	return freed;
 }
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
