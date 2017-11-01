Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id DD6066B0038
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 07:54:40 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id e68so2174650oih.21
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 04:54:40 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id k6si289945ote.380.2017.11.01.04.54.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 01 Nov 2017 04:54:39 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH 1/2] mm,oom: Move last second allocation to inside the OOM killer.
Date: Wed,  1 Nov 2017 20:54:27 +0900
Message-Id: <1509537268-4726-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Michal Hocko <mhocko@suse.com>

__alloc_pages_may_oom() is doing last second allocation attempt using
ALLOC_WMARK_HIGH before calling out_of_memory(). This has two motivations.
The first one is explained by the comment that it aims to catch potential
parallel OOM killing and the second one was explained by Andrea Arcangeli
as follows:
: Elaborating the comment: the reason for the high wmark is to reduce
: the likelihood of livelocks and be sure to invoke the OOM killer, if
: we're still under pressure and reclaim just failed. The high wmark is
: used to be sure the failure of reclaim isn't going to be ignored. If
: using the min wmark like you propose there's risk of livelock or
: anyway of delayed OOM killer invocation.

But there is no parallel OOM killing (in the sense that out_of_memory() is
called "concurrently") because we serialize out_of_memory() calls using
oom_lock. Regarding the latter, there is no possibility of OOM livelocks
nor possibility of failing to invoke the OOM killer because we mask
__GFP_DIRECT_RECLAIM for last second allocation attempt because oom_lock
prevents __GFP_DIRECT_RECLAIM && !__GFP_NORETRY allocations which last
second allocation attempt indirectly involve from failing.

However, parallel OOM killing still exists (in the sense that
out_of_memory() is called "consecutively"). Sometimes doing last second
allocation attempt after selecting an OOM victim can succeed because
somebody might have managed to free memory while we were selecting an OOM
victim which can take quite some time. This suggests that giving up last
second allocation attempt as soon as ALLOC_WMARK_HIGH as of before
selecting an OOM victim fails can be premature.

Therefore, this patch moves last second allocation attempt to after
selecting an OOM victim. This patch is expected to reduce the time window
for potentially pre-mature OOM killing considerably, but this patch will
cause last second allocation attempt always fail if out_of_memory() is
not called.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Suggested-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/oom.h | 13 +++++++++++++
 mm/oom_kill.c       | 23 +++++++++++++++++++++++
 mm/page_alloc.c     | 38 +++++++++++++++++++++-----------------
 3 files changed, 57 insertions(+), 17 deletions(-)

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
index 26add8a..118ecdb 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -870,6 +870,19 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 	}
 	task_unlock(p);
 
+	/*
+	 * Try really last second allocation attempt after we selected an OOM
+	 * victim, for somebody might have managed to free memory while we were
+	 * selecting an OOM victim which can take quite some time.
+	 */
+	if (oc->ac) {
+		oc->page = alloc_pages_before_oomkill(oc);
+		if (oc->page) {
+			put_task_struct(p);
+			return;
+		}
+	}
+
 	if (__ratelimit(&oom_rs))
 		dump_header(oc, p);
 
@@ -1081,6 +1094,16 @@ bool out_of_memory(struct oom_control *oc)
 	select_bad_process(oc);
 	/* Found nothing?!?! Either we hang forever, or we panic. */
 	if (!oc->chosen && !is_sysrq_oom(oc) && !is_memcg_oom(oc)) {
+		/*
+		 * Try really last second allocation attempt, for somebody
+		 * might have managed to free memory while we were trying to
+		 * find an OOM victim.
+		 */
+		if (oc->ac) {
+			oc->page = alloc_pages_before_oomkill(oc);
+			if (oc->page)
+				return true;
+		}
 		dump_header(oc, NULL);
 		panic("Out of memory and no killable processes...\n");
 	}
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 97687b3..6654f52 100644
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
@@ -4114,6 +4104,20 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 	return page;
 }
 
+struct page *alloc_pages_before_oomkill(const struct oom_control *oc)
+{
+	/*
+	 * Go through the zonelist yet one more time, keep very high watermark
+	 * here, this is only to catch a parallel oom killing, we must fail if
+	 * we're still under heavy pressure. But make sure that this reclaim
+	 * attempt shall not depend on __GFP_DIRECT_RECLAIM && !__GFP_NORETRY
+	 * allocation which will never fail due to oom_lock already held.
+	 */
+	return get_page_from_freelist((oc->gfp_mask | __GFP_HARDWALL) &
+				      ~__GFP_DIRECT_RECLAIM, oc->order,
+				      ALLOC_WMARK_HIGH|ALLOC_CPUSET, oc->ac);
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
