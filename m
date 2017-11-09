Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 96226440CD7
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 05:27:20 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id o126so4155208oif.21
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 02:27:20 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id v110si3168491otb.232.2017.11.09.02.27.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 09 Nov 2017 02:27:19 -0800 (PST)
Subject: Re: [PATCH v2] mm, shrinker: make shrinker_list lockless
References: <20171108173740.115166-1-shakeelb@google.com>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <2940c150-577a-30a8-fac3-cf59a49b84b4@I-love.SAKURA.ne.jp>
Date: Thu, 9 Nov 2017 19:26:50 +0900
MIME-Version: 1.0
In-Reply-To: <20171108173740.115166-1-shakeelb@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>, Minchan Kim <minchan@kernel.org>, Huang Ying <ying.huang@intel.com>, Mel Gorman <mgorman@techsingularity.net>, Vladimir Davydov <vdavydov.dev@gmail.com>, Michal Hocko <mhocko@kernel.org>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2017/11/09 2:37, Shakeel Butt wrote:
> In our production, we have observed that the job loader gets stuck for
> 10s of seconds while doing mount operation. It turns out that it was
> stuck in register_shrinker() and some unrelated job was under memory
> pressure and spending time in shrink_slab(). Our machines have a lot
> of shrinkers registered and jobs under memory pressure has to traverse
> all of those memcg-aware shrinkers and do affect unrelated jobs which
> want to register their own shrinkers.
> 
> This patch has made the shrinker_list traversal lockless and shrinker
> register remain fast. For the shrinker unregister, atomic counter
> has been introduced to avoid synchronize_rcu() call. The fields of
> struct shrinker has been rearraged to make sure that the size does
> not increase for x86_64.
> 
> The shrinker functions are allowed to reschedule() and thus can not
> be called with rcu read lock. One way to resolve that is to use
> srcu read lock but then ifdefs has to be used as SRCU is behind
> CONFIG_SRCU. Another way is to just release the rcu read lock before
> calling the shrinker and reacquire on the return. The atomic counter
> will make sure that the shrinker entry will not be freed under us.
> 
> Signed-off-by: Shakeel Butt <shakeelb@google.com>
> ---
> Changelog since v1:
> - release and reacquire rcu lock across shrinker call.
> 
>  include/linux/shrinker.h |  4 +++-
>  mm/vmscan.c              | 54 ++++++++++++++++++++++++++++++------------------
>  2 files changed, 37 insertions(+), 21 deletions(-)
> 

If you can accept serialized register_shrinker()/unregister_shrinker(),
I think that something like shown below can do it.

----------
diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
index 388ff29..e2272dd 100644
--- a/include/linux/shrinker.h
+++ b/include/linux/shrinker.h
@@ -62,9 +62,10 @@ struct shrinker {
 
 	int seeks;	/* seeks to recreate an obj */
 	long batch;	/* reclaim batch size, 0 = default */
-	unsigned long flags;
+	unsigned int flags;
 
 	/* These are for internal use */
+	atomic_t nr_active; /* Counted only if !SHRINKER_PERMANENT */
 	struct list_head list;
 	/* objs pending delete, per node */
 	atomic_long_t *nr_deferred;
@@ -74,6 +75,7 @@ struct shrinker {
 /* Flags */
 #define SHRINKER_NUMA_AWARE	(1 << 0)
 #define SHRINKER_MEMCG_AWARE	(1 << 1)
+#define SHRINKER_PERMANENT	(1 << 2)
 
 extern int register_shrinker(struct shrinker *);
 extern void unregister_shrinker(struct shrinker *);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 1c1bc95..e963359 100644
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
@@ -297,9 +298,14 @@ int register_shrinker(struct shrinker *shrinker)
  */
 void unregister_shrinker(struct shrinker *shrinker)
 {
-	down_write(&shrinker_rwsem);
-	list_del(&shrinker->list);
-	up_write(&shrinker_rwsem);
+	BUG_ON(shrinker->flags & SHRINKER_PERMANENT);
+	mutex_lock(&shrinker_lock);
+	list_del_rcu(&shrinker->list);
+	synchronize_rcu();
+	while (atomic_read(&shrinker->nr_active))
+		msleep(1);
+	synchronize_rcu();
+	mutex_unlock(&shrinker_lock);
 	kfree(shrinker->nr_deferred);
 }
 EXPORT_SYMBOL(unregister_shrinker);
@@ -468,18 +474,9 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
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
+		bool permanent;
 		struct shrink_control sc = {
 			.gfp_mask = gfp_mask,
 			.nid = nid,
@@ -498,11 +495,16 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
 		if (!(shrinker->flags & SHRINKER_NUMA_AWARE))
 			sc.nid = 0;
 
+		permanent = (shrinker->flags & SHRINKER_PERMANENT);
+		if (!permanent)
+			atomic_inc(&shrinker->nr_active);
+		rcu_read_unlock();
 		freed += do_shrink_slab(&sc, shrinker, nr_scanned, nr_eligible);
+		rcu_read_lock();
+		if (!permanent)
+			atomic_dec(&shrinker->nr_active);
 	}
-
-	up_read(&shrinker_rwsem);
-out:
+	rcu_read_unlock();
 	cond_resched();
 	return freed;
 }
----------

If you want parallel register_shrinker()/unregister_shrinker(), something like
shown below on top of shown above will do it.

----------
diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
index e2272dd..471b2f6 100644
--- a/include/linux/shrinker.h
+++ b/include/linux/shrinker.h
@@ -67,6 +67,7 @@ struct shrinker {
 	/* These are for internal use */
 	atomic_t nr_active; /* Counted only if !SHRINKER_PERMANENT */
 	struct list_head list;
+	struct list_head gc_list;
 	/* objs pending delete, per node */
 	atomic_long_t *nr_deferred;
 };
diff --git a/mm/vmscan.c b/mm/vmscan.c
index e963359..a216dc5 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -157,7 +157,7 @@ struct scan_control {
 unsigned long vm_total_pages;
 
 static LIST_HEAD(shrinker_list);
-static DEFINE_MUTEX(shrinker_lock);
+static DEFINE_SPINLOCK(shrinker_lock);
 
 #ifdef CONFIG_MEMCG
 static bool global_reclaim(struct scan_control *sc)
@@ -286,9 +286,9 @@ int register_shrinker(struct shrinker *shrinker)
 		return -ENOMEM;
 
 	atomic_set(&shrinker->nr_active, 0);
-	mutex_lock(&shrinker_lock);
+	spin_lock(&shrinker_lock);
 	list_add_tail_rcu(&shrinker->list, &shrinker_list);
-	mutex_unlock(&shrinker_lock);
+	spin_unlock(&shrinker_lock);
 	return 0;
 }
 EXPORT_SYMBOL(register_shrinker);
@@ -298,15 +298,30 @@ int register_shrinker(struct shrinker *shrinker)
  */
 void unregister_shrinker(struct shrinker *shrinker)
 {
+	static LIST_HEAD(shrinker_gc_list);
+	struct shrinker *gc;
+
 	BUG_ON(shrinker->flags & SHRINKER_PERMANENT);
-	mutex_lock(&shrinker_lock);
+	spin_lock(&shrinker_lock);
 	list_del_rcu(&shrinker->list);
+	/*
+	 * Need to update ->list.next if concurrently unregistering shrinkers
+	 * can find this shrinker, for this shrinker's unregistration might
+	 * complete before their unregistrations complete.
+	 */
+	list_for_each_entry(gc, &shrinker_gc_list, gc_list) {
+		if (gc->list.next == &shrinker->list)
+			rcu_assign_pointer(gc->list.next, shrinker->list.next);
+	}
+	list_add_tail(&shrinker->gc_list, &shrinker_gc_list);
+	spin_unlock(&shrinker_lock);
 	synchronize_rcu();
 	while (atomic_read(&shrinker->nr_active))
 		msleep(1);
 	synchronize_rcu();
-	mutex_unlock(&shrinker_lock);
+	spin_lock(&shrinker_lock);
+	list_del(&shrinker->gc_list);
+	spin_unlock(&shrinker_lock);
 	kfree(shrinker->nr_deferred);
 }
 EXPORT_SYMBOL(unregister_shrinker);
----------

F.Y.I. When I posted above change at
http://lkml.kernel.org/r/201411231350.DHI12456.OLOFFJSFtQVMHO@I-love.SAKURA.ne.jp ,
Michal Hocko commented like below.

  I thought that {un}register_shrinker are really unlikely
  paths called during initialization and tear down which usually do not
  happen during OOM conditions.

  I cannot judge the patch itself as this is out of my area but is the
  complexity worth it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
