From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] mm/vmscan: Kill shrinker's global semaphore.
Date: Wed, 21 May 2014 20:57:41 +0900
Message-ID: <201405212057.FHD48466.VOQLFFtSMFHOJO@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundation.org, riel@redhat.com, dchinner@redhat.com, kosaki.motohiro@jp.fujitsu.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-Id: linux-mm.kvack.org

I'm trying to identify the cause of stalls with 100% CPU usage when
a certain type of memory pressure is given. I noticed that some of
shrinker functions may take unpredictably long duration to complete.
Since shrinker list is protected by a global semaphore, I came to worry
that (e.g.) umount operation which involves deactivate_locked_super()
might become unresponding for very long time. Maybe we want to kill
global semaphore?
----------
>From ba9c6a433377b92ded32217176a77e00c4ca488b Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Wed, 21 May 2014 15:05:17 +0900
Subject: [PATCH] mm/vmscan: Kill shrinker's global semaphore.

Currently register_shrinker()/unregister_shrinker() calls
down_write(&shrinker_rwsem) while shrink_slab() calls
down_read_trylock(&shrinker_rwsem).

While it is expected that shrinker functions do not allocate memory,
there are shrinker functions that allocate memory and/or hold mutex
which may take unpredictably long duration to complete.

Therefore, if one of shrinkers takes too long time (maybe due to a bug),
other shrinkers cannot be registered or unregistered due to use of
global semaphore.

This patch replaces global semaphore with per a shrinker refcounter.

Before this patch, response time of addition/removal are unpredictable
when one of shrinkers are in use by shrink_slab(), nearly 0 otherwise.

After this patch, response time of addition is nearly 0. Response time of
removal remains unpredictable when the shrinker to remove is in use by
shrink_slab(), nearly RCU grace period otherwise.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 include/linux/shrinker.h |   4 ++
 mm/vmscan.c              | 100 ++++++++++++++++++++++++++++++++++++-----------
 2 files changed, 82 insertions(+), 22 deletions(-)

diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
index 68c0970..c16b0aa 100644
--- a/include/linux/shrinker.h
+++ b/include/linux/shrinker.h
@@ -59,6 +59,10 @@ struct shrinker {
 	struct list_head list;
 	/* objs pending delete, per node */
 	atomic_long_t *nr_deferred;
+	/* Number of users holding reference to this object. */
+	atomic_t usage;
+	/* Used for GC tracing. */
+	struct list_head gc_list;
 };
 #define DEFAULT_SEEKS 2 /* A good number if you don't know better. */
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 32c661d..c0db2fc 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -133,7 +133,8 @@ int vm_swappiness = 60;
 unsigned long vm_total_pages;	/* The total number of pages which the VM controls */
 
 static LIST_HEAD(shrinker_list);
-static DECLARE_RWSEM(shrinker_rwsem);
+static LIST_HEAD(shrinker_gc_list);
+static DEFINE_SPINLOCK(shrinker_list_lock);
 
 #ifdef CONFIG_MEMCG
 static bool global_reclaim(struct scan_control *sc)
@@ -196,9 +197,17 @@ int register_shrinker(struct shrinker *shrinker)
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
+	list_add_tail(&shrinker->gc_list, &shrinker_gc_list);
+	spin_unlock(&shrinker_list_lock);
 	return 0;
 }
 EXPORT_SYMBOL(register_shrinker);
@@ -208,9 +217,61 @@ EXPORT_SYMBOL(register_shrinker);
  */
 void unregister_shrinker(struct shrinker *shrinker)
 {
-	down_write(&shrinker_rwsem);
-	list_del(&shrinker->list);
-	up_write(&shrinker_rwsem);
+	struct shrinker *gc;
+	unsigned int i = 0;
+
+	/*
+	 * For explanation, this function refers shrinker objects like
+	 * shrinker[x-2], shrinker[x-1], shrinker[x] and assumes that
+	 *
+	 *   shrinker_list.next      == &shrinker[x-2].list
+	 *   shrinker[x-2].list.prev == &shrinker_list
+	 *   shrinker[x-2].list.next == &shrinker[x].list
+	 *   shrinker[x].list.prev   == &shrinker[x-2].list
+	 *   shrinker[x].list.next   == &shrinker_list
+	 *   shrinker_list.prev      == &shrinker[x].list
+	 *   shrinker[x-1].list.prev == LIST_POISON2
+	 *   shrinker[x-1].list.next == &shrinker[x].list
+	 *
+	 * when this function is called for deleting shrinker[x] after
+	 * this function is called for deleting shrinker[x-1].
+	 *
+	 * First, make it impossible for list_for_each_entry_rcu(shrinker,
+	 * &shrinker_list, list) in shrink_slab() to find shrinker[x]
+	 * after RCU grace period. Note that we need to do
+	 *
+	 *   shrinker[x-1].list.next = shrinker[x].list.next
+	 *
+	 * when we do
+	 *
+	 *   shrinker[x-2].list.next = shrinker[x].list.next
+	 *
+	 * because shrinker[x-1] may be still in use.
+	 */
+	spin_lock(&shrinker_list_lock);
+	list_del_rcu(&shrinker->list);
+	list_for_each_entry(gc, &shrinker_gc_list, list) {
+		if (gc->list.next == &shrinker->list)
+			gc->list.next = shrinker->list.next;
+	}
+	spin_unlock(&shrinker_list_lock);
+	synchronize_rcu();
+	/*
+	 * Wait for readers who acquired a reference to shrinker[x]
+	 * before RCU grace period.
+	 */
+	while (atomic_read(&shrinker->usage)) {
+		msleep(100);
+		if (++i % 600)
+			continue;
+		pr_info("Process %d (%s) blocked at %s for %u seconds\n",
+			task_pid_nr(current), current->comm, __func__,
+			i / 10);
+	}
+	/* Now, nobody is using this shrinker. */
+	spin_lock(&shrinker_list_lock);
+	list_del(&shrinker->gc_list);
+	spin_unlock(&shrinker_list_lock);
 	kfree(shrinker->nr_deferred);
 }
 EXPORT_SYMBOL(unregister_shrinker);
@@ -357,23 +418,15 @@ unsigned long shrink_slab(struct shrink_control *shrinkctl,
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
@@ -382,9 +435,12 @@ unsigned long shrink_slab(struct shrink_control *shrinkctl,
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
