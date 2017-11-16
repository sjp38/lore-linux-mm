Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4179228025F
	for <linux-mm@kvack.org>; Thu, 16 Nov 2017 05:56:52 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id v21so4039393ioi.5
        for <linux-mm@kvack.org>; Thu, 16 Nov 2017 02:56:52 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id b21si575949iob.153.2017.11.16.02.56.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Nov 2017 02:56:50 -0800 (PST)
Subject: Re: [PATCH 1/2] mm,vmscan: Kill global shrinker lock.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1510609063-3327-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20171115090251.umpd53zpvp42xkvi@dhcp22.suse.cz>
	<201711151958.CBI60413.FHQMtFLFOOSOJV@I-love.SAKURA.ne.jp>
	<20171115132836.GA6524@cmpxchg.org>
In-Reply-To: <20171115132836.GA6524@cmpxchg.org>
Message-Id: <201711161956.EBF57883.QFFMOLOVSOHJFt@I-love.SAKURA.ne.jp>
Date: Thu, 16 Nov 2017 19:56:37 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org
Cc: mhocko@kernel.org, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, vdavydov.dev@gmail.com, akpm@linux-foundation.org, shakeelb@google.com, gthelen@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Johannes Weiner wrote:
> On Wed, Nov 15, 2017 at 07:58:09PM +0900, Tetsuo Handa wrote:
> > I think that Minchan's approach depends on how
> > 
> >   In our production, we have observed that the job loader gets stuck for
> >   10s of seconds while doing mount operation. It turns out that it was
> >   stuck in register_shrinker() and some unrelated job was under memory
> >   pressure and spending time in shrink_slab(). Our machines have a lot
> >   of shrinkers registered and jobs under memory pressure has to traverse
> >   all of those memcg-aware shrinkers and do affect unrelated jobs which
> >   want to register their own shrinkers.
> > 
> > is interpreted. If there were 100000 shrinkers and each do_shrink_slab() call
> > took 1 millisecond, aborting the iteration as soon as rwsem_is_contended() would
> > help a lot. But if there were 10 shrinkers and each do_shrink_slab() call took
> > 10 seconds, aborting the iteration as soon as rwsem_is_contended() would help
> > less. Or, there might be some specific shrinker where its do_shrink_slab() call
> > takes 100 seconds. In that case, checking rwsem_is_contended() is too lazy.
> 
> In your patch, unregister() waits for shrinker->nr_active instead of
> the lock, which is decreased in the same location where Minchan drops
> the lock. How is that different behavior for long-running shrinkers?

My patch waits for only one shrinker which unregister_shrinker() is trying to
unregister. Minchan's patch waits for the longest-running in-flight shrinkers.
The difference is that my patch is not disturbed by other in-flight shrinkers
unless the shrinker which unregister_shrinker() is trying to unregister is
the longest-running in-flight shrinker, but it is natural (and required thing)
to wait for the shrinker which unregister_shrinker() is trying to unregister.
This will make difference if some shrinker which unregister_shrinker() is not
trying to unregister is doing crazy stuff.

> 
> Anyway, I suspect it's many shrinkers and many concurrent invocations,
> so the lockbreak granularity you both chose should be fine.
> 

So far, Shakeel's environment does not seem to have shrinkers which do
crazy stuff. But if there is, my approach will reduce the latency.

If we can tolerate per "struct task_struct" marker, I think we can remove
atomic variables.

---
 include/linux/sched.h    |  1 +
 include/linux/shrinker.h |  1 +
 mm/vmscan.c              | 67 ++++++++++++++++++++++++++++++++----------------
 3 files changed, 47 insertions(+), 22 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index a5dc7c9..f7eed9b 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1098,6 +1098,7 @@ struct task_struct {
 	/* Used by LSM modules for access restriction: */
 	void				*security;
 #endif
+	struct shrinker			*active_shrinker; /* Not for deref. */
 
 	/*
 	 * New fields for task_struct should be added above here, so that
diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
index 388ff29..77cfd3f 100644
--- a/include/linux/shrinker.h
+++ b/include/linux/shrinker.h
@@ -66,6 +66,7 @@ struct shrinker {
 
 	/* These are for internal use */
 	struct list_head list;
+	struct list_head gc_list;
 	/* objs pending delete, per node */
 	atomic_long_t *nr_deferred;
 };
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 1c1bc95..c6b2f5c 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -157,7 +157,7 @@ struct scan_control {
 unsigned long vm_total_pages;
 
 static LIST_HEAD(shrinker_list);
-static DECLARE_RWSEM(shrinker_rwsem);
+static DEFINE_SPINLOCK(shrinker_lock);
 
 #ifdef CONFIG_MEMCG
 static bool global_reclaim(struct scan_control *sc)
@@ -285,9 +285,9 @@ int register_shrinker(struct shrinker *shrinker)
 	if (!shrinker->nr_deferred)
 		return -ENOMEM;
 
-	down_write(&shrinker_rwsem);
-	list_add_tail(&shrinker->list, &shrinker_list);
-	up_write(&shrinker_rwsem);
+	spin_lock(&shrinker_lock);
+	list_add_tail_rcu(&shrinker->list, &shrinker_list);
+	spin_unlock(&shrinker_lock);
 	return 0;
 }
 EXPORT_SYMBOL(register_shrinker);
@@ -297,9 +297,40 @@ int register_shrinker(struct shrinker *shrinker)
  */
 void unregister_shrinker(struct shrinker *shrinker)
 {
-	down_write(&shrinker_rwsem);
-	list_del(&shrinker->list);
-	up_write(&shrinker_rwsem);
+	struct task_struct *g, *p;
+	static LIST_HEAD(shrinker_gc_list);
+	struct shrinker *gc;
+
+	spin_lock(&shrinker_lock);
+	list_del_rcu(&shrinker->list);
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
+	synchronize_rcu();
+ retry:
+	rcu_read_lock();
+	for_each_process_thread(g, p) {
+		if (unlikely(p->active_shrinker == shrinker)) {
+			get_task_struct(p);
+			rcu_read_unlock();
+			while (p->active_shrinker == shrinker)
+				schedule_timeout_uninterruptible(1);
+			put_task_struct(p);
+			goto retry;
+		}
+	}
+	rcu_read_unlock();
+	spin_lock(&shrinker_lock);
+	list_del(&shrinker->gc_list);
+	spin_unlock(&shrinker_lock);
 	kfree(shrinker->nr_deferred);
 }
 EXPORT_SYMBOL(unregister_shrinker);
@@ -468,18 +499,8 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
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
@@ -498,11 +519,13 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
 		if (!(shrinker->flags & SHRINKER_NUMA_AWARE))
 			sc.nid = 0;
 
+		current->active_shrinker = shrinker;
+		rcu_read_unlock();
 		freed += do_shrink_slab(&sc, shrinker, nr_scanned, nr_eligible);
+		rcu_read_lock();
 	}
-
-	up_read(&shrinker_rwsem);
-out:
+	rcu_read_unlock();
+	current->active_shrinker = NULL;
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
