Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3FBD9440846
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 09:25:36 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id m7so3090590pga.8
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 06:25:36 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id p64si2738364pga.259.2017.08.24.06.25.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 24 Aug 2017 06:25:34 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [RFC PATCH 2/2] mm,oom: Try last second allocation after selecting an OOM victim.
Date: Thu, 24 Aug 2017 21:18:26 +0900
Message-Id: <1503577106-9196-2-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
In-Reply-To: <1503577106-9196-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
References: <1503577106-9196-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Manish Jaggi <mjaggi@caviumnetworks.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.com>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Vlastimil Babka <vbabka@suse.cz>

Manish Jaggi noticed that running LTP oom01/oom02 ltp tests with high core
count causes random kernel panics when an OOM victim which consumed memory
in a way the OOM reaper does not help was selected by the OOM killer [1].

Since commit 696453e66630ad45 ("mm, oom: task_will_free_mem should skip
oom_reaped tasks") changed task_will_free_mem(current) in out_of_memory()
to return false as soon as MMF_OOM_SKIP is set, many threads sharing the
victim's mm were not able to try allocation from memory reserves after the
OOM reaper gave up reclaiming memory.

I proposed a patch which alllows task_will_free_mem(current) in
out_of_memory() to ignore MMF_OOM_SKIP for once so that all OOM victim
threads are guaranteed to have tried ALLOC_OOM allocation attempt before
start selecting next OOM victims [2], for Michal Hocko did not like
calling get_page_from_freelist() from the OOM killer which is a layer
violation [3]. But now, Michal thinks that calling get_page_from_freelist()
after task_will_free_mem(current) test is better than allowing
task_will_free_mem(current) to ignore MMF_OOM_SKIP for once [4], for
this would help other cases when we race with an exiting tasks or somebody
managed to free memory while we were selecting an OOM victim which can take
quite some time.

Thus, this patch brings "struct alloc_context" into the OOM killer layer
and does really last second get_page_from_freelist() attempt inside
oom_kill_process(). This patch calls whole __alloc_pages_slowpath() than
cherry-picks get_page_from_freelist() call, for we need to try ALLOC_OOM
allocation if task_is_oom_victim(current) == true (because
task_will_free_mem(current) not to ignore MMF_OOM_SKIP might have prevented
current thread from trying ALLOC_OOM allocation).

Although this patch tries to close all possible races which lead to
premature OOM killer invocation, compared to approaches which preserves
the layer and retry __alloc_pages_slowpath() without oom_lock held (e.g.
[2]), there are two races which cannot be closed by this patch.

  (1) Since we cannot use direct reclaim for this allocation attempt due to
      oom_lock already held, an OOM victim will be prematurely killed which
      could have been avoided if direct reclaim with oom_lock released was
      used.

  (2) Since we call panic() before calling oom_kill_process() when there is
      no killable process, panic() will be prematurely called which could
      have been avoided if [2] is used. For example, if a multithreaded
      application running with a dedicated CPUs/memory was OOM-killed, we
      can wait until ALLOC_OOM allocation fails to solve OOM situation.

Which approach should we take (this patch and/or [2]) ?

[1] http://lkml.kernel.org/r/e6c83a26-1d59-4afd-55cf-04e58bdde188@caviumnetworks.com
[2] http://lkml.kernel.org/r/201708191523.BJH90621.MHOOFFQSOLJFtV@I-love.SAKURA.ne.jp
[3] http://lkml.kernel.org/r/20160129152307.GF32174@dhcp22.suse.cz
[4] http://lkml.kernel.org/r/20170821131851.GJ25956@dhcp22.suse.cz

Fixes: 696453e66630ad45 ("mm, oom: task_will_free_mem should skip oom_reaped tasks")
Reported-by: Manish Jaggi <mjaggi@caviumnetworks.com>
Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/oom.h | 13 +++++++++++++
 mm/oom_kill.c       | 13 +++++++++++++
 mm/page_alloc.c     | 27 +++++++++++++++++++++------
 3 files changed, 47 insertions(+), 6 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index 76aac4c..eb92aa8 100644
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
+	struct alloc_context *ac;
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
 
+extern struct page *alloc_pages_before_oomkill(struct oom_control *oc);
+
 /* sysctls */
 extern int sysctl_oom_dump_tasks;
 extern int sysctl_oom_kill_allocating_task;
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 99736e0..fe1aa30 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -832,6 +832,19 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
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
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 788318f..90b2de9 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3277,7 +3277,8 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
 
 static inline struct page *
 __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
-	const struct alloc_context *ac, unsigned long *did_some_progress)
+		      struct alloc_context *ac,
+		      unsigned long *did_some_progress)
 {
 	struct oom_control oc = {
 		.zonelist = ac->zonelist,
@@ -3285,6 +3286,7 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
 		.memcg = NULL,
 		.gfp_mask = gfp_mask,
 		.order = order,
+		.ac = ac,
 	};
 	struct page *page;
 
@@ -3347,16 +3349,17 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
 		goto out;
 
 	/* Exhausted what can be done so it's blamo time */
-	if (out_of_memory(&oc) || WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL)) {
+	if (out_of_memory(&oc)) {
+		*did_some_progress = 1;
+		page = oc.page;
+	} else if (WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL)) {
 		*did_some_progress = 1;
-
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
@@ -4126,6 +4129,18 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 	return page;
 }
 
+struct page *alloc_pages_before_oomkill(struct oom_control *oc)
+{
+	/*
+	 * Make sure that this allocation attempt shall not depend on
+	 * __GFP_DIRECT_RECLAIM && !__GFP_NORETRY allocation, for the caller is
+	 * already holding oom_lock.
+	 */
+	return __alloc_pages_slowpath((oc->gfp_mask | __GFP_NOWARN) &
+				      ~(__GFP_DIRECT_RECLAIM | __GFP_NOFAIL),
+				      oc->order, oc->ac);
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
