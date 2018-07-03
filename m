Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 37D546B0271
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 10:26:47 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id j80-v6so1953324itj.8
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 07:26:47 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id a200-v6si887681ioa.166.2018.07.03.07.26.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jul 2018 07:26:45 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH 5/8] mm,oom: Bring OOM notifier to outside of oom_lock.
Date: Tue,  3 Jul 2018 23:25:06 +0900
Message-Id: <1530627910-3415-6-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
In-Reply-To: <1530627910-3415-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
References: <1530627910-3415-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: torvalds@linux-foundation.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Roman Gushchin <guro@fb.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

Since blocking_notifier_call_chain() in out_of_memory() might sleep,
sleeping with oom_lock held is currently an unavoidable problem.

As a preparation for not to sleep with oom_lock held, this patch brings
OOM notifier callbacks to outside of oom_lock. We are planning to
eventually replace OOM notifier callbacks with different mechanisms
(e.g. shrinker API). But such changes are out of scope for this series.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Tejun Heo <tj@kernel.org>
---
 include/linux/oom.h |  1 +
 mm/oom_kill.c       | 38 +++++++++++++++++++++------
 mm/page_alloc.c     | 76 +++++++++++++++++++++++++++++++----------------------
 3 files changed, 76 insertions(+), 39 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index eab409f..d8da2cb 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -101,6 +101,7 @@ extern unsigned long oom_badness(struct task_struct *p,
 		struct mem_cgroup *memcg, const nodemask_t *nodemask,
 		unsigned long totalpages);
 
+extern unsigned long try_oom_notifier(void);
 extern bool out_of_memory(struct oom_control *oc);
 
 extern void exit_oom_victim(void);
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 1a9fae4..d18fe1e 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -871,6 +871,36 @@ int unregister_oom_notifier(struct notifier_block *nb)
 }
 EXPORT_SYMBOL_GPL(unregister_oom_notifier);
 
+/**
+ * try_oom_notifier - Try to reclaim memory from OOM notifier list.
+ *
+ * Returns non-zero if notifier callbacks released something, zero otherwise.
+ */
+unsigned long try_oom_notifier(void)
+{
+	static DEFINE_MUTEX(oom_notifier_lock);
+	unsigned long freed = 0;
+
+	/*
+	 * In order to protect OOM notifiers which are not thread safe and to
+	 * avoid excessively releasing memory from OOM notifiers which release
+	 * memory every time, this lock serializes/excludes concurrent calls to
+	 * OOM notifiers.
+	 */
+	if (!mutex_trylock(&oom_notifier_lock))
+		return 1;
+	/*
+	 * But teach the lockdep that mutex_trylock() above acts like
+	 * mutex_lock(), for we are not allowed to depend on
+	 * __GFP_DIRECT_RECLAIM && !__GFP_NORETRY allocation here.
+	 */
+	mutex_release(&oom_notifier_lock.dep_map, 1, _THIS_IP_);
+	mutex_acquire(&oom_notifier_lock.dep_map, 0, 0, _THIS_IP_);
+	blocking_notifier_call_chain(&oom_notify_list, 0, &freed);
+	mutex_unlock(&oom_notifier_lock);
+	return freed;
+}
+
 void exit_oom_mm(struct mm_struct *mm)
 {
 	struct task_struct *p, *tmp;
@@ -937,19 +967,11 @@ static bool oom_has_pending_victims(struct oom_control *oc)
  */
 bool out_of_memory(struct oom_control *oc)
 {
-	unsigned long freed = 0;
 	enum oom_constraint constraint = CONSTRAINT_NONE;
 
 	if (oom_killer_disabled)
 		return false;
 
-	if (!is_memcg_oom(oc)) {
-		blocking_notifier_call_chain(&oom_notify_list, 0, &freed);
-		if (freed > 0)
-			/* Got some memory back in the last second. */
-			return true;
-	}
-
 	/*
 	 * If current has a pending SIGKILL or is exiting, then automatically
 	 * select it.  The goal is to allow it to allocate so that it may
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b915533..4cb3602 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3447,10 +3447,50 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
 	return page;
 }
 
+static inline bool can_oomkill(gfp_t gfp_mask, unsigned int order,
+			       const struct alloc_context *ac)
+{
+	/* Coredumps can quickly deplete all memory reserves */
+	if (current->flags & PF_DUMPCORE)
+		return false;
+	/* The OOM killer will not help higher order allocs */
+	if (order > PAGE_ALLOC_COSTLY_ORDER)
+		return false;
+	/*
+	 * We have already exhausted all our reclaim opportunities without any
+	 * success so it is time to admit defeat. We will skip the OOM killer
+	 * because it is very likely that the caller has a more reasonable
+	 * fallback than shooting a random task.
+	 */
+	if (gfp_mask & __GFP_RETRY_MAYFAIL)
+		return false;
+	/* The OOM killer does not needlessly kill tasks for lowmem */
+	if (ac->high_zoneidx < ZONE_NORMAL)
+		return false;
+	if (pm_suspended_storage())
+		return false;
+	/*
+	 * XXX: GFP_NOFS allocations should rather fail than rely on
+	 * other request to make a forward progress.
+	 * We are in an unfortunate situation where out_of_memory cannot
+	 * do much for this context but let's try it to at least get
+	 * access to memory reserved if the current task is killed (see
+	 * out_of_memory). Once filesystems are ready to handle allocation
+	 * failures more gracefully we should just bail out here.
+	 */
+
+	/* The OOM killer may not free memory on a specific node */
+	if (gfp_mask & __GFP_THISNODE)
+		return false;
+
+	return true;
+}
+
 static inline struct page *
 __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 	const struct alloc_context *ac, unsigned long *did_some_progress)
 {
+	const bool oomkill = can_oomkill(gfp_mask, order, ac);
 	struct oom_control oc = {
 		.zonelist = ac->zonelist,
 		.nodemask = ac->nodemask,
@@ -3462,6 +3502,10 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
 
 	*did_some_progress = 0;
 
+	/* Try to reclaim via OOM notifier callback. */
+	if (oomkill)
+		*did_some_progress = try_oom_notifier();
+
 	/*
 	 * Acquire the oom lock.  If that fails, somebody else is
 	 * making progress for us.
@@ -3484,37 +3528,7 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
 	if (page)
 		goto out;
 
-	/* Coredumps can quickly deplete all memory reserves */
-	if (current->flags & PF_DUMPCORE)
-		goto out;
-	/* The OOM killer will not help higher order allocs */
-	if (order > PAGE_ALLOC_COSTLY_ORDER)
-		goto out;
-	/*
-	 * We have already exhausted all our reclaim opportunities without any
-	 * success so it is time to admit defeat. We will skip the OOM killer
-	 * because it is very likely that the caller has a more reasonable
-	 * fallback than shooting a random task.
-	 */
-	if (gfp_mask & __GFP_RETRY_MAYFAIL)
-		goto out;
-	/* The OOM killer does not needlessly kill tasks for lowmem */
-	if (ac->high_zoneidx < ZONE_NORMAL)
-		goto out;
-	if (pm_suspended_storage())
-		goto out;
-	/*
-	 * XXX: GFP_NOFS allocations should rather fail than rely on
-	 * other request to make a forward progress.
-	 * We are in an unfortunate situation where out_of_memory cannot
-	 * do much for this context but let's try it to at least get
-	 * access to memory reserved if the current task is killed (see
-	 * out_of_memory). Once filesystems are ready to handle allocation
-	 * failures more gracefully we should just bail out here.
-	 */
-
-	/* The OOM killer may not free memory on a specific node */
-	if (gfp_mask & __GFP_THISNODE)
+	if (!oomkill)
 		goto out;
 
 	/* Exhausted what can be done so it's blame time */
-- 
1.8.3.1
