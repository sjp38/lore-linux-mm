Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 12B316B0253
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 07:17:00 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id b85so4952948pfj.22
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 04:17:00 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id a87si3614048pfe.222.2017.11.02.04.16.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 02 Nov 2017 04:16:58 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH v2 1/2] mm,oom: Move last second allocation to inside the OOM killer.
Date: Thu,  2 Nov 2017 20:16:47 +0900
Message-Id: <1509621408-4066-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
In-Reply-To: <201711022015.BBE95844.QOHtJFMLFOOSVF@I-love.SAKURA.ne.jp>
References: <201711022015.BBE95844.QOHtJFMLFOOSVF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>

__alloc_pages_may_oom() is doing last second allocation attempt using
ALLOC_WMARK_HIGH before calling out_of_memory(). This had two reasons.

The first reason is explained in the comment that it aims to catch
potential parallel OOM killing. But there is no longer parallel OOM
killing (in the sense that out_of_memory() is called "concurrently")
because we serialize out_of_memory() calls using oom_lock.

The second reason is explained by Andrea Arcangeli (who added that code)
that it aims to reduce the likelihood of OOM livelocks and be sure to
invoke the OOM killer. There was a risk of livelock or anyway of delayed
OOM killer invocation if ALLOC_WMARK_MIN is used, for relying on last
few pages which are constantly allocated and freed in the meantime will
not improve the situation. But there is no longer possibility of OOM
livelocks or failing to invoke the OOM killer because we need to mask
__GFP_DIRECT_RECLAIM for last second allocation attempt because oom_lock
prevents __GFP_DIRECT_RECLAIM && !__GFP_NORETRY allocations which last
second allocation attempt indirectly involve from failing.

However, parallel OOM killing still exists (in the sense that
out_of_memory() is called "consecutively"). Sometimes doing last second
allocation attempt after selecting an OOM victim can succeed because
somebody (maybe previously killed OOM victims) might have managed to free
memory while we were selecting an OOM victim which can take quite some
time, for setting MMF_OOM_SKIP by exiting OOM victims is not serialized
by oom_lock. This suggests that giving up last second allocation attempt
as soon as ALLOC_WMARK_HIGH as of before selecting an OOM victim fails
can be pre-mature. Therefore, this patch moves last second allocation
attempt to after selecting an OOM victim. This patch is expected to reduce
the time window for potentially pre-mature OOM killing considerably.

Since the OOM killer does not always kill a process consuming significant
amount of memory (the OOM killer kills a process with highest OOM score
(or instead one of its children if any)), there will be cases where
ALLOC_WMARK_HIGH fails and ALLOC_WMARK_MIN succeeds.
Since the gap between ALLOC_WMARK_HIGH and ALLOC_WMARK_MIN can be changed
by /proc/sys/vm/min_free_kbytes parameter, using ALLOC_WMARK_MIN for last
second allocation attempt might be better for minimizing number of OOM
victims. But that change should be done in a separate patch. This patch
just clarifies that ALLOC_WMARK_HIGH is an arbitrary choice.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Suggested-by: Michal Hocko <mhocko@suse.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/oom.h | 13 +++++++++++++
 mm/oom_kill.c       | 14 ++++++++++++++
 mm/page_alloc.c     | 41 ++++++++++++++++++++++++-----------------
 3 files changed, 51 insertions(+), 17 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index 76aac4c..5ac2556 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -13,6 +13,8 @@
 struct notifier_block;
 struct mem_cgroup;
 struct task_struct;
+struct alloc_context;
+struct page;
 
 /*
  * Details of the page allocation that triggered the oom killer that are used to
@@ -37,6 +39,15 @@ struct oom_control {
 	 */
 	const int order;
 
+	/* Context for really last second allocation attempt. */
+	const struct alloc_context *ac;
+	/*
+	 * Set by the OOM killer if ac != NULL and last second allocation
+	 * attempt succeeded. If ac != NULL, the caller must check for
+	 * page != NULL.
+	 */
+	struct page *page;
+
 	/* Used by oom implementation, do not set */
 	unsigned long totalpages;
 	struct task_struct *chosen;
@@ -101,6 +112,8 @@ extern unsigned long oom_badness(struct task_struct *p,
 
 extern struct task_struct *find_lock_task_mm(struct task_struct *p);
 
+extern struct page *alloc_pages_before_oomkill(const struct oom_control *oc);
+
 /* sysctls */
 extern int sysctl_oom_dump_tasks;
 extern int sysctl_oom_kill_allocating_task;
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 26add8a..452e35c 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -1072,6 +1072,9 @@ bool out_of_memory(struct oom_control *oc)
 	if (!is_memcg_oom(oc) && sysctl_oom_kill_allocating_task &&
 	    current->mm && !oom_unkillable_task(current, NULL, oc->nodemask) &&
 	    current->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
+		oc->page = alloc_pages_before_oomkill(oc);
+		if (oc->page)
+			return true;
 		get_task_struct(current);
 		oc->chosen = current;
 		oom_kill_process(oc, "Out of memory (oom_kill_allocating_task)");
@@ -1079,6 +1082,17 @@ bool out_of_memory(struct oom_control *oc)
 	}
 
 	select_bad_process(oc);
+	/*
+	 * Try really last second allocation attempt after we selected an OOM
+	 * victim, for somebody might have managed to free memory while we were
+	 * selecting an OOM victim which can take quite some time.
+	 */
+	oc->page = alloc_pages_before_oomkill(oc);
+	if (oc->page) {
+		if (oc->chosen && oc->chosen != (void *)-1UL)
+			put_task_struct(oc->chosen);
+		return true;
+	}
 	/* Found nothing?!?! Either we hang forever, or we panic. */
 	if (!oc->chosen && !is_sysrq_oom(oc) && !is_memcg_oom(oc)) {
 		dump_header(oc, NULL);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 97687b3..1607326 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3273,6 +3273,7 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
 		.memcg = NULL,
 		.gfp_mask = gfp_mask,
 		.order = order,
+		.ac = ac,
 	};
 	struct page *page;
 
@@ -3288,19 +3289,6 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
 		return NULL;
 	}
 
-	/*
-	 * Go through the zonelist yet one more time, keep very high watermark
-	 * here, this is only to catch a parallel oom killing, we must fail if
-	 * we're still under heavy pressure. But make sure that this reclaim
-	 * attempt shall not depend on __GFP_DIRECT_RECLAIM && !__GFP_NORETRY
-	 * allocation which will never fail due to oom_lock already held.
-	 */
-	page = get_page_from_freelist((gfp_mask | __GFP_HARDWALL) &
-				      ~__GFP_DIRECT_RECLAIM, order,
-				      ALLOC_WMARK_HIGH|ALLOC_CPUSET, ac);
-	if (page)
-		goto out;
-
 	/* Coredumps can quickly deplete all memory reserves */
 	if (current->flags & PF_DUMPCORE)
 		goto out;
@@ -3335,16 +3323,18 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
 		goto out;
 
 	/* Exhausted what can be done so it's blamo time */
-	if (out_of_memory(&oc) || WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL)) {
+	if (out_of_memory(&oc)) {
+		*did_some_progress = 1;
+		page = oc.page;
+	} else if (WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL)) {
 		*did_some_progress = 1;
 
 		/*
 		 * Help non-failing allocations by giving them access to memory
 		 * reserves
 		 */
-		if (gfp_mask & __GFP_NOFAIL)
-			page = __alloc_pages_cpuset_fallback(gfp_mask, order,
-					ALLOC_NO_WATERMARKS, ac);
+		page = __alloc_pages_cpuset_fallback(gfp_mask, order,
+						     ALLOC_NO_WATERMARKS, ac);
 	}
 out:
 	mutex_unlock(&oom_lock);
@@ -4114,6 +4104,23 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 	return page;
 }
 
+struct page *alloc_pages_before_oomkill(const struct oom_control *oc)
+{
+	/*
+	 * This allocation attempt must not depend on __GFP_DIRECT_RECLAIM &&
+	 * !__GFP_NORETRY allocation which will never fail due to oom_lock
+	 * already held. And since this allocation attempt does not sleep,
+	 * there is no reason we must use high watermark here.
+	 */
+	int alloc_flags = ALLOC_CPUSET | ALLOC_WMARK_HIGH;
+	gfp_t gfp_mask = oc->gfp_mask | __GFP_HARDWALL;
+
+	if (!oc->ac)
+		return NULL;
+	gfp_mask &= ~__GFP_DIRECT_RECLAIM;
+	return get_page_from_freelist(gfp_mask, oc->order, alloc_flags, oc->ac);
+}
+
 static inline bool prepare_alloc_pages(gfp_t gfp_mask, unsigned int order,
 		int preferred_nid, nodemask_t *nodemask,
 		struct alloc_context *ac, gfp_t *alloc_mask,
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
