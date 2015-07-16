Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 83185280309
	for <linux-mm@kvack.org>; Thu, 16 Jul 2015 16:55:21 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so23533034wib.0
        for <linux-mm@kvack.org>; Thu, 16 Jul 2015 13:55:21 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fz8si15791766wjb.67.2015.07.16.13.55.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 16 Jul 2015 13:55:19 -0700 (PDT)
Message-ID: <1437080113.3596.2.camel@stgolabs.net>
Subject: [PATCH -next v2] mm: srcu-ify shrinkers
From: Davidlohr Bueso <dave@stgolabs.net>
Date: Thu, 16 Jul 2015 13:55:13 -0700
In-Reply-To: <1434398602.1903.15.camel@stgolabs.net>
References: <1434398602.1903.15.camel@stgolabs.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The shrinker_rwsem is a global lock that protects the shrinker_list,
serializing a shrinking call with register/unregistering the shrinker
itself. As such, this lock is taken mostly for reading. In the unlikely
case that the the list is being modified, we simply return indicating
we want to iterate again. However, the only caller of shrink_slab()
that acknowledges this return is drop_slab_node(), so in practice, the
rest of the callers never try again.

This patch proposes replacing the rwsem with an srcu aware list of
shrinkers, where (un)registering tasks use a spinlock. Upon shrinker
calls, the srcu read lock will guarantee the existence of the structure,
thus safely optimizing the common (read locked) case. These guarantees
also allow us to cleanup and simplify the code, getting rid of the
ugly trylock mechanism to retry the shrinker operation when the list
is concurrently being modified. As Michal pointed this is only worth
mentioning for unregister purposes.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
Changes from v1:
 - Got rid of the trylock, per mhocko.

 fs/super.c  |  8 ++++----
 mm/vmscan.c | 39 ++++++++++++++++++---------------------
 2 files changed, 22 insertions(+), 25 deletions(-)

diff --git a/fs/super.c b/fs/super.c
index b613723..c917817 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -49,8 +49,8 @@ static char *sb_writers_name[SB_FREEZE_LEVELS] = {
  * One thing we have to be careful of with a per-sb shrinker is that we don't
  * drop the last active reference to the superblock from within the shrinker.
  * If that happens we could trigger unregistering the shrinker from within the
- * shrinker path and that leads to deadlock on the shrinker_rwsem. Hence we
- * take a passive reference to the superblock to avoid this from occurring.
+ * shrinker path. Hence we take a passive reference to the superblock to avoid
+ * this from occurring.
  */
 static unsigned long super_cache_scan(struct shrinker *shrink,
 				      struct shrink_control *sc)
@@ -121,8 +121,8 @@ static unsigned long super_cache_count(struct shrinker *shrink,
 	 * Don't call trylock_super as it is a potential
 	 * scalability bottleneck. The counts could get updated
 	 * between super_cache_count and super_cache_scan anyway.
-	 * Call to super_cache_count with shrinker_rwsem held
-	 * ensures the safety of call to list_lru_shrink_count() and
+	 * SRCU guarantees object validity across this call -- thus
+	 * it is safe to call list_lru_shrink_count() and
 	 * s_op->nr_cached_objects().
 	 */
 	if (sb->s_op && sb->s_op->nr_cached_objects)
diff --git a/mm/vmscan.c b/mm/vmscan.c
index c8d8282..fc820cf 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -36,7 +36,7 @@
 #include <linux/cpuset.h>
 #include <linux/compaction.h>
 #include <linux/notifier.h>
-#include <linux/rwsem.h>
+#include <linux/srcu.h>
 #include <linux/delay.h>
 #include <linux/kthread.h>
 #include <linux/freezer.h>
@@ -146,8 +146,9 @@ int vm_swappiness = 60;
  */
 unsigned long vm_total_pages;
 
+DEFINE_STATIC_SRCU(shrinker_srcu);
 static LIST_HEAD(shrinker_list);
-static DECLARE_RWSEM(shrinker_rwsem);
+static DEFINE_SPINLOCK(shrinker_list_lock);
 
 #ifdef CONFIG_MEMCG
 static bool global_reclaim(struct scan_control *sc)
@@ -242,9 +243,9 @@ int register_shrinker(struct shrinker *shrinker)
 	if (!shrinker->nr_deferred)
 		return -ENOMEM;
 
-	down_write(&shrinker_rwsem);
-	list_add_tail(&shrinker->list, &shrinker_list);
-	up_write(&shrinker_rwsem);
+	spin_lock(&shrinker_list_lock);
+	list_add_tail_rcu(&shrinker->list, &shrinker_list);
+	spin_unlock(&shrinker_list_lock);
 	return 0;
 }
 EXPORT_SYMBOL(register_shrinker);
@@ -254,9 +255,14 @@ EXPORT_SYMBOL(register_shrinker);
  */
 void unregister_shrinker(struct shrinker *shrinker)
 {
-	down_write(&shrinker_rwsem);
-	list_del(&shrinker->list);
-	up_write(&shrinker_rwsem);
+	spin_lock(&shrinker_list_lock);
+	list_del_rcu(&shrinker->list);
+	spin_unlock(&shrinker_list_lock);
+	/*
+	 * Before freeing nr_deferred, ensure all srcu
+	 * readers are done with their critical region.
+	 */
+	synchronize_srcu(&shrinker_srcu);
 	kfree(shrinker->nr_deferred);
 }
 EXPORT_SYMBOL(unregister_shrinker);
@@ -408,6 +414,7 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
 				 unsigned long nr_scanned,
 				 unsigned long nr_eligible)
 {
+	int idx;
 	struct shrinker *shrinker;
 	unsigned long freed = 0;
 
@@ -417,18 +424,9 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
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
+	idx = srcu_read_lock(&shrinker_srcu);
 
-	list_for_each_entry(shrinker, &shrinker_list, list) {
+	list_for_each_entry_rcu(shrinker, &shrinker_list, list) {
 		struct shrink_control sc = {
 			.gfp_mask = gfp_mask,
 			.nid = nid,
@@ -444,8 +442,7 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
 		freed += do_shrink_slab(&sc, shrinker, nr_scanned, nr_eligible);
 	}
 
-	up_read(&shrinker_rwsem);
-out:
+	srcu_read_unlock(&shrinker_srcu, idx);
 	cond_resched();
 	return freed;
 }
-- 
2.1.4



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
