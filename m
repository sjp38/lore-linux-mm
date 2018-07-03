Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7DBB96B0266
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 10:26:19 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id f7-v6so1393568oti.5
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 07:26:19 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id n26-v6si449315ote.162.2018.07.03.07.26.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jul 2018 07:26:18 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH 6/8] mm,oom: Make oom_lock static variable.
Date: Tue,  3 Jul 2018 23:25:07 +0900
Message-Id: <1530627910-3415-7-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
In-Reply-To: <1530627910-3415-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
References: <1530627910-3415-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: torvalds@linux-foundation.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Roman Gushchin <guro@fb.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

As a preparation for not to sleep with oom_lock held, this patch makes
oom_lock local to the OOM killer.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Tejun Heo <tj@kernel.org>
---
 drivers/tty/sysrq.c |  2 --
 include/linux/oom.h |  2 --
 mm/memcontrol.c     |  6 +-----
 mm/oom_kill.c       | 47 ++++++++++++++++++++++++++++-------------------
 mm/page_alloc.c     | 24 ++++--------------------
 5 files changed, 33 insertions(+), 48 deletions(-)

diff --git a/drivers/tty/sysrq.c b/drivers/tty/sysrq.c
index 6364890..c8b66b9 100644
--- a/drivers/tty/sysrq.c
+++ b/drivers/tty/sysrq.c
@@ -376,10 +376,8 @@ static void moom_callback(struct work_struct *ignored)
 		.order = -1,
 	};
 
-	mutex_lock(&oom_lock);
 	if (!out_of_memory(&oc))
 		pr_info("OOM request ignored. No task eligible\n");
-	mutex_unlock(&oom_lock);
 }
 
 static DECLARE_WORK(moom_work, moom_callback);
diff --git a/include/linux/oom.h b/include/linux/oom.h
index d8da2cb..5ad2927 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -44,8 +44,6 @@ struct oom_control {
 	unsigned long chosen_points;
 };
 
-extern struct mutex oom_lock;
-
 static inline void set_current_oom_origin(void)
 {
 	current->signal->oom_flag_origin = true;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index c8a75c8..35c33bf 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1198,12 +1198,8 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 		.gfp_mask = gfp_mask,
 		.order = order,
 	};
-	bool ret;
 
-	mutex_lock(&oom_lock);
-	ret = out_of_memory(&oc);
-	mutex_unlock(&oom_lock);
-	return ret;
+	return out_of_memory(&oc);
 }
 
 #if MAX_NUMNODES > 1
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index d18fe1e..a1d3616 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -59,7 +59,7 @@ static inline unsigned long oom_victim_mm_score(struct mm_struct *mm)
 int sysctl_oom_kill_allocating_task;
 int sysctl_oom_dump_tasks = 1;
 
-DEFINE_MUTEX(oom_lock);
+static DEFINE_MUTEX(oom_lock);
 
 #ifdef CONFIG_NUMA
 /**
@@ -965,10 +965,9 @@ static bool oom_has_pending_victims(struct oom_control *oc)
  * OR try to be smart about which process to kill. Note that we
  * don't have to be perfect here, we just have to be good.
  */
-bool out_of_memory(struct oom_control *oc)
+static bool __out_of_memory(struct oom_control *oc,
+			    enum oom_constraint constraint)
 {
-	enum oom_constraint constraint = CONSTRAINT_NONE;
-
 	if (oom_killer_disabled)
 		return false;
 
@@ -991,18 +990,8 @@ bool out_of_memory(struct oom_control *oc)
 	if (oc->gfp_mask && !(oc->gfp_mask & __GFP_FS))
 		return true;
 
-	/*
-	 * Check if there were limitations on the allocation (only relevant for
-	 * NUMA and memcg) that may require different handling.
-	 */
-	constraint = constrained_alloc(oc);
-	if (constraint != CONSTRAINT_MEMORY_POLICY)
-		oc->nodemask = NULL;
 	check_panic_on_oom(oc, constraint);
 
-	if (oom_has_pending_victims(oc))
-		return true;
-
 	if (!is_memcg_oom(oc) && sysctl_oom_kill_allocating_task &&
 	    oom_badness(current, NULL, oc->nodemask, oc->totalpages) > 0) {
 		get_task_struct(current);
@@ -1024,10 +1013,33 @@ bool out_of_memory(struct oom_control *oc)
 	return true;
 }
 
+bool out_of_memory(struct oom_control *oc)
+{
+	enum oom_constraint constraint;
+	bool ret;
+	/*
+	 * Check if there were limitations on the allocation (only relevant for
+	 * NUMA and memcg) that may require different handling.
+	 */
+	constraint = constrained_alloc(oc);
+	if (constraint != CONSTRAINT_MEMORY_POLICY)
+		oc->nodemask = NULL;
+	/*
+	 * If there are OOM victims which current thread can select,
+	 * wait for them to reach __mmput().
+	 */
+	mutex_lock(&oom_lock);
+	if (oom_has_pending_victims(oc))
+		ret = true;
+	else
+		ret = __out_of_memory(oc, constraint);
+	mutex_unlock(&oom_lock);
+	return ret;
+}
+
 /*
  * The pagefault handler calls here because it is out of memory, so kill a
- * memory-hogging task. If oom_lock is held by somebody else, a parallel oom
- * killing is already in progress so do nothing.
+ * memory-hogging task.
  */
 void pagefault_out_of_memory(void)
 {
@@ -1042,9 +1054,6 @@ void pagefault_out_of_memory(void)
 	if (mem_cgroup_oom_synchronize(true))
 		return;
 
-	if (!mutex_trylock(&oom_lock))
-		return;
 	out_of_memory(&oc);
-	mutex_unlock(&oom_lock);
 	schedule_timeout_killable(1);
 }
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4cb3602..4c648f7 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3500,32 +3500,17 @@ static inline bool can_oomkill(gfp_t gfp_mask, unsigned int order,
 	};
 	struct page *page;
 
-	*did_some_progress = 0;
-
 	/* Try to reclaim via OOM notifier callback. */
-	if (oomkill)
-		*did_some_progress = try_oom_notifier();
-
-	/*
-	 * Acquire the oom lock.  If that fails, somebody else is
-	 * making progress for us.
-	 */
-	if (!mutex_trylock(&oom_lock)) {
-		*did_some_progress = 1;
-		return NULL;
-	}
+	*did_some_progress = oomkill ? try_oom_notifier() : 0;
 
 	/*
 	 * Go through the zonelist yet one more time, keep very high watermark
 	 * here, this is only to catch a parallel oom killing, we must fail if
-	 * we're still under heavy pressure. But make sure that this reclaim
-	 * attempt shall not depend on __GFP_DIRECT_RECLAIM && !__GFP_NORETRY
-	 * allocation which will never fail due to oom_lock already held.
+	 * we're still under heavy pressure.
 	 */
-	page = get_page_from_freelist((gfp_mask | __GFP_HARDWALL) &
-				      ~__GFP_DIRECT_RECLAIM, order,
+	page = get_page_from_freelist(gfp_mask | __GFP_HARDWALL, order,
 				      ALLOC_WMARK_HIGH|ALLOC_CPUSET, ac);
-	if (page)
+	if (page || *did_some_progress)
 		goto out;
 
 	if (!oomkill)
@@ -3544,7 +3529,6 @@ static inline bool can_oomkill(gfp_t gfp_mask, unsigned int order,
 					ALLOC_NO_WATERMARKS, ac);
 	}
 out:
-	mutex_unlock(&oom_lock);
 	return page;
 }
 
-- 
1.8.3.1
