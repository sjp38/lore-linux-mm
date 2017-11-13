Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 98E836B0261
	for <linux-mm@kvack.org>; Mon, 13 Nov 2017 16:38:13 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id u10so3585958otc.21
        for <linux-mm@kvack.org>; Mon, 13 Nov 2017 13:38:13 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id h85si2250574oib.418.2017.11.13.13.38.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 13 Nov 2017 13:38:12 -0800 (PST)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH 2/2] mm,vmscan: Allow parallel registration/unregistration of shrinkers.
Date: Tue, 14 Nov 2017 06:37:43 +0900
Message-Id: <1510609063-3327-2-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
In-Reply-To: <1510609063-3327-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
References: <1510609063-3327-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Huang Ying <ying.huang@intel.com>, Mel Gorman <mgorman@techsingularity.net>, Vladimir Davydov <vdavydov.dev@gmail.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Shakeel Butt <shakeelb@google.com>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Shakeel Butt and Greg Thelen noticed that the job loader running in their
production can get stuck for 10s of seconds while doing mount operation,
for some unrelated job was blocking register_shrinker() due to calling
do_shrink_slab() triggered by memory pressure when the job loader doing
mount operation (which is regularly done) called register_shrinker().

Their machines have a lot of shrinkers registered and jobs under memory
pressure have to traverse all of those memcg-aware shrinkers and do affect
unrelated jobs which want to register/unregister their own shrinkers.

This patch allows processing register_shrinker()/unregister_shrinker() in
parallel so that each shrinker loaded/unloaded by the job loader will not
be blocked waiting for other shrinkers.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Shakeel Butt <shakeelb@google.com>
Cc: Greg Thelen <gthelen@google.com>
---
 include/linux/shrinker.h |  1 +
 mm/vmscan.c              | 26 +++++++++++++++++++++-----
 2 files changed, 22 insertions(+), 5 deletions(-)

diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
index 333a1d0..05ba330 100644
--- a/include/linux/shrinker.h
+++ b/include/linux/shrinker.h
@@ -67,6 +67,7 @@ struct shrinker {
 	/* These are for internal use */
 	atomic_t nr_active;
 	struct list_head list;
+	struct list_head gc_list;
 	/* objs pending delete, per node */
 	atomic_long_t *nr_deferred;
 };
diff --git a/mm/vmscan.c b/mm/vmscan.c
index c8996e8..48ff848 100644
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
@@ -298,13 +298,29 @@ int register_shrinker(struct shrinker *shrinker)
  */
 void unregister_shrinker(struct shrinker *shrinker)
 {
-	mutex_lock(&shrinker_lock);
+	static LIST_HEAD(shrinker_gc_list);
+	struct shrinker *gc;
+
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
 		schedule_timeout_uninterruptible(1);
 	synchronize_rcu();
-	mutex_unlock(&shrinker_lock);
+	spin_lock(&shrinker_lock);
+	list_del(&shrinker->gc_list);
+	spin_unlock(&shrinker_lock);
 	kfree(shrinker->nr_deferred);
 }
 EXPORT_SYMBOL(unregister_shrinker);
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
