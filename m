Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 6B1F96B0072
	for <linux-mm@kvack.org>; Sat, 22 Nov 2014 23:50:53 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id bj1so7462397pad.23
        for <linux-mm@kvack.org>; Sat, 22 Nov 2014 20:50:53 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id m1si15620363pdm.166.2014.11.22.20.50.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 22 Nov 2014 20:50:52 -0800 (PST)
Received: from fsav201.sakura.ne.jp (fsav201.sakura.ne.jp [210.224.168.163])
	by www262.sakura.ne.jp (8.14.5/8.14.5) with ESMTP id sAN4on9p080943
	for <linux-mm@kvack.org>; Sun, 23 Nov 2014 13:50:49 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Received: from AQUA (KD175108057186.ppp-bb.dion.ne.jp [175.108.57.186])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.14.5/8.14.5) with ESMTP id sAN4onxx080940
	for <linux-mm@kvack.org>; Sun, 23 Nov 2014 13:50:49 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Subject: [PATCH 2/5] mm: Kill shrinker's global semaphore.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201411231349.CAG78628.VFQFOtOSFJMOLH@I-love.SAKURA.ne.jp>
In-Reply-To: <201411231349.CAG78628.VFQFOtOSFJMOLH@I-love.SAKURA.ne.jp>
Message-Id: <201411231350.DHI12456.OLOFFJSFtQVMHO@I-love.SAKURA.ne.jp>
Date: Sun, 23 Nov 2014 13:50:50 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

>From 92aec48e3b2e21c3716654670a24890f34c58683 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Sun, 23 Nov 2014 13:39:25 +0900
Subject: [PATCH 2/5] mm: Kill shrinker's global semaphore.

Currently register_shrinker()/unregister_shrinker() calls down_write()
while shrink_slab() calls down_read_trylock(). This implies that the OOM
killer becomes disabled because shrink_slab() pretends "we reclaimed some
slab memory" even if "no slab memory can be reclaimed" when somebody calls
register_shrinker()/unregister_shrinker() while one of shrinker functions
allocates memory and/or holds mutex which may take unpredictably long
duration to complete.

This patch replaces global semaphore with per a shrinker refcounter
so that shrink_slab() can respond "we could not reclaim slab memory"
when out_of_memory() needs to be called.

Before this patch, response time of addition/removal are unpredictable
when one of shrinkers are in use by shrink_slab(), nearly 0 otherwise.

After this patch, response time of addition is nearly 0. Response time of
removal remains unpredictable when the shrinker to remove is in use by
shrink_slab(), nearly two RCU grace periods otherwise.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 include/linux/shrinker.h |  4 +++
 mm/vmscan.c              | 78 ++++++++++++++++++++++++++++++++++--------------
 2 files changed, 60 insertions(+), 22 deletions(-)

diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
index 68c0970..745246a 100644
--- a/include/linux/shrinker.h
+++ b/include/linux/shrinker.h
@@ -59,6 +59,10 @@ struct shrinker {
 	struct list_head list;
 	/* objs pending delete, per node */
 	atomic_long_t *nr_deferred;
+	/* Number of users holding reference to this object. */
+	atomic_t usage;
+	/* Used for handling concurrent unregistration tracing. */
+	struct list_head gc_list;
 };
 #define DEFAULT_SEEKS 2 /* A good number if you don't know better. */
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index dcb4707..54d2638 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -144,7 +144,7 @@ int vm_swappiness = 60;
 unsigned long vm_total_pages;
 
 static LIST_HEAD(shrinker_list);
-static DECLARE_RWSEM(shrinker_rwsem);
+static DEFINE_SPINLOCK(shrinker_list_lock);
 
 #ifdef CONFIG_MEMCG
 static bool global_reclaim(struct scan_control *sc)
@@ -208,9 +208,16 @@ int register_shrinker(struct shrinker *shrinker)
 	if (!shrinker->nr_deferred)
 		return -ENOMEM;
 
-	down_write(&shrinker_rwsem);
-	list_add_tail(&shrinker->list, &shrinker_list);
-	up_write(&shrinker_rwsem);
+	/*
+	 * Make it possible for list_for_each_entry_rcu(shrinker,
+	 * &shrinker_list, list) in shrink_slab() to find this shrinker.
+	 * We assume that this shrinker is not under unregister_shrinker()
+	 * call.
+	 */
+	atomic_set(&shrinker->usage, 0);
+	spin_lock(&shrinker_list_lock);
+	list_add_tail_rcu(&shrinker->list, &shrinker_list);
+	spin_unlock(&shrinker_list_lock);
 	return 0;
 }
 EXPORT_SYMBOL(register_shrinker);
@@ -220,9 +227,41 @@ EXPORT_SYMBOL(register_shrinker);
  */
 void unregister_shrinker(struct shrinker *shrinker)
 {
-	down_write(&shrinker_rwsem);
-	list_del(&shrinker->list);
-	up_write(&shrinker_rwsem);
+	static LIST_HEAD(shrinker_gc_list);
+	struct shrinker *gc;
+	unsigned int i = 0;
+	int usage;
+
+	/*
+	 * Make it impossible for shrinkers on shrinker_list and shrinkers
+	 * on shrinker_gc_list to call atomic_inc(&shrinker->usage) after
+	 * RCU grace period expires.
+	 */
+	spin_lock(&shrinker_list_lock);
+	list_del_rcu(&shrinker->list);
+	list_for_each_entry(gc, &shrinker_gc_list, gc_list) {
+		if (gc->list.next == &shrinker->list)
+			rcu_assign_pointer(gc->list.next, shrinker->list.next);
+	}
+	list_add_tail(&shrinker->gc_list, &shrinker_gc_list);
+	spin_unlock(&shrinker_list_lock);
+	synchronize_rcu();
+	/*
+	 * Wait for readers until RCU grace period expires after the last
+	 * atomic_dec(&shrinker->usage). Warn if it is taking too long.
+	 */
+	while (1) {
+		usage = atomic_read(&shrinker->usage);
+		if (!usage)
+			break;
+		msleep(100);
+		WARN(++i % 600 == 0, "Shrinker usage=%d\n", usage);
+	}
+	synchronize_rcu();
+	/* Now, nobody is using this shrinker. */
+	spin_lock(&shrinker_list_lock);
+	list_del(&shrinker->gc_list);
+	spin_unlock(&shrinker_list_lock);
 	kfree(shrinker->nr_deferred);
 }
 EXPORT_SYMBOL(unregister_shrinker);
@@ -369,23 +408,15 @@ unsigned long shrink_slab(struct shrink_control *shrinkctl,
 	if (nr_pages_scanned == 0)
 		nr_pages_scanned = SWAP_CLUSTER_MAX;
 
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
+		atomic_inc(&shrinker->usage);
+		rcu_read_unlock();
 		if (!(shrinker->flags & SHRINKER_NUMA_AWARE)) {
 			shrinkctl->nid = 0;
 			freed += shrink_slab_node(shrinkctl, shrinker,
 					nr_pages_scanned, lru_pages);
-			continue;
+			goto next_entry;
 		}
 
 		for_each_node_mask(shrinkctl->nid, shrinkctl->nodes_to_scan) {
@@ -394,9 +425,12 @@ unsigned long shrink_slab(struct shrink_control *shrinkctl,
 						nr_pages_scanned, lru_pages);
 
 		}
+next_entry:
+		rcu_read_lock();
+		atomic_dec(&shrinker->usage);
 	}
-	up_read(&shrinker_rwsem);
-out:
+	rcu_read_unlock();
+
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
