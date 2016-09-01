Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8C87D6B0069
	for <linux-mm@kvack.org>; Thu,  1 Sep 2016 05:51:19 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id e7so56766596lfe.0
        for <linux-mm@kvack.org>; Thu, 01 Sep 2016 02:51:19 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id 204si15508356wmj.131.2016.09.01.02.51.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Sep 2016 02:51:16 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id w207so7579646wmw.0
        for <linux-mm@kvack.org>; Thu, 01 Sep 2016 02:51:16 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC 1/4] mm, oom: do not rely on TIF_MEMDIE for memory reserves access
Date: Thu,  1 Sep 2016 11:51:01 +0200
Message-Id: <1472723464-22866-2-git-send-email-mhocko@kernel.org>
In-Reply-To: <1472723464-22866-1-git-send-email-mhocko@kernel.org>
References: <1472723464-22866-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

For ages we have been relying on TIF_MEMDIE thread flag to mark OOM
victims and then, among other things, to give these threads full
access to memory reserves. There are few shortcomings of this
implementation, though.

First of all and the most serious one is that the full access to memory
reserves is quite dangerous because we leave no safety room for the
system to operate and potentially do last emergency steps to move on.

Secondly this flag is per task_struct while the OOM killer operates
on mm_struct granularity so all processes sharing the given mm are
killed. Giving the full access to all these task_structs could leave to
a quick memory reserves depletion. We have tried to reduce this risk by
giving TIF_MEMDIE only to the main thread and the currently allocating
task but that doesn't really solve this problem while it surely opens up
a room for corner cases - e.g. GFP_NO{FS,IO} requests might loop inside
the allocator without access to memory reserves because a particular
thread was not the group leader.

Now that we have the oom reaper and that all oom victims are reapable
(after "oom, oom_reaper: allow to reap mm shared by the kthreads")
we can be more conservative and grant only partial access to memory
reserves because there are reasonable chances of the parallel memory
freeing. We still want some access to reserves because we do not
want other consumers to eat up the victim's freed memory. oom victims
will still contend with __GFP_HIGH users but those shouldn't be so
aggressive to starve oom victims completely.

Introduce ALLOC_OOM flag and give all tsk_is_oom_victim tasks access to
the half of the reserves. This makes the access to reserves independent
on which task has passed through mark_oom_victim. Also drop any
usage of TIF_MEMDIE from the page allocator proper and replace it by
tsk_is_oom_victim as well which will make page_alloc.c completely
TIF_MEMDIE free finally.

CONFIG_MMU=n doesn't have oom reaper so let's stick to the original
ALLOC_NO_WATERMARKS approach but be careful because they still might
deplete all the memory reserves so keep the semantic as close to the
original implementation as possible and give them access to memory
reserves only up to exit_mm (when tsk->mm is cleared) rather than while
tsk_is_oom_victim which is until signal struct is gone.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/internal.h   | 11 +++++++++++
 mm/oom_kill.c   |  9 +++++----
 mm/page_alloc.c | 57 ++++++++++++++++++++++++++++++++++++++++++++++-----------
 3 files changed, 62 insertions(+), 15 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index 5214bf8e3171..f693c4e61a0a 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -460,6 +460,17 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 /* Mask to get the watermark bits */
 #define ALLOC_WMARK_MASK	(ALLOC_NO_WATERMARKS-1)
 
+/*
+ * Only MMU archs have async oom victim reclaim - aka oom_reaper so we
+ * cannot assume a reduced access to memory reserves is sufficient for
+ * !MMU
+ */
+#ifdef CONFIG_MMU
+#define ALLOC_OOM		0x08
+#else
+#define ALLOC_OOM		ALLOC_NO_WATERMARKS
+#endif
+
 #define ALLOC_HARDER		0x10 /* try to alloc harder */
 #define ALLOC_HIGH		0x20 /* __GFP_HIGH set */
 #define ALLOC_CPUSET		0x40 /* check for correct cpuset */
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 0034baf35f0c..b11977585c7b 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -816,7 +816,8 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 
 	/*
 	 * If the task is already exiting, don't alarm the sysadmin or kill
-	 * its children or threads, just set TIF_MEMDIE so it can die quickly
+	 * its children or threads, just give it access to memory reserves
+	 * so it can die quickly
 	 */
 	task_lock(p);
 	if (task_will_free_mem(p)) {
@@ -876,9 +877,9 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 	mm = victim->mm;
 	atomic_inc(&mm->mm_count);
 	/*
-	 * We should send SIGKILL before setting TIF_MEMDIE in order to prevent
-	 * the OOM victim from depleting the memory reserves from the user
-	 * space under its control.
+	 * We should send SIGKILL before granting access to memory reserves
+	 * in order to prevent the OOM victim from depleting the memory
+	 * reserves from the user space under its control.
 	 */
 	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
 	mark_oom_victim(victim);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ee3997859f14..b10025aa3dc7 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2737,7 +2737,7 @@ bool __zone_watermark_ok(struct zone *z, unsigned int order, unsigned long mark,
 {
 	long min = mark;
 	int o;
-	const bool alloc_harder = (alloc_flags & ALLOC_HARDER);
+	const bool alloc_harder = (alloc_flags & (ALLOC_HARDER|ALLOC_OOM));
 
 	/* free_pages may go negative - that's OK */
 	free_pages -= (1 << order) - 1;
@@ -2750,10 +2750,19 @@ bool __zone_watermark_ok(struct zone *z, unsigned int order, unsigned long mark,
 	 * the high-atomic reserves. This will over-estimate the size of the
 	 * atomic reserve but it avoids a search.
 	 */
-	if (likely(!alloc_harder))
+	if (likely(!alloc_harder)) {
 		free_pages -= z->nr_reserved_highatomic;
-	else
-		min -= min / 4;
+	} else {
+		/*
+		 * OOM victims can try even harder than normal ALLOC_HARDER
+		 * users
+		 */
+		if (alloc_flags & ALLOC_OOM)
+			min -= min / 2;
+		else
+			min -= min / 4;
+	}
+
 
 #ifdef CONFIG_CMA
 	/* If allocation can't use CMA areas don't use free CMA pages */
@@ -2995,7 +3004,7 @@ void warn_alloc_failed(gfp_t gfp_mask, unsigned int order, const char *fmt, ...)
 	 * of allowed nodes.
 	 */
 	if (!(gfp_mask & __GFP_NOMEMALLOC))
-		if (test_thread_flag(TIF_MEMDIE) ||
+		if (tsk_is_oom_victim(current) ||
 		    (current->flags & (PF_MEMALLOC | PF_EXITING)))
 			filter &= ~SHOW_MEM_FILTER_NODES;
 	if (in_interrupt() || !(gfp_mask & __GFP_DIRECT_RECLAIM))
@@ -3309,6 +3318,22 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
 	return alloc_flags;
 }
 
+static bool oom_reserves_allowed(struct task_struct *tsk)
+{
+	if (!tsk_is_oom_victim(tsk))
+		return false;
+
+	/*
+	 * !MMU doesn't have oom reaper so we shouldn't risk the memory reserves
+	 * depletion and shouldn't give access to memory reserves passed the
+	 * exit_mm
+	 */
+	if (!IS_ENABLED(CONFIG_MMU) && !tsk->mm)
+		return false;
+
+	return true;
+}
+
 bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 {
 	if (unlikely(gfp_mask & __GFP_NOMEMALLOC))
@@ -3320,7 +3345,7 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 		return true;
 	if (!in_interrupt() &&
 			((current->flags & PF_MEMALLOC) ||
-			 unlikely(test_thread_flag(TIF_MEMDIE))))
+			 oom_reserves_allowed(current)))
 		return true;
 
 	return false;
@@ -3424,6 +3449,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 						struct alloc_context *ac)
 {
 	bool can_direct_reclaim = gfp_mask & __GFP_DIRECT_RECLAIM;
+	bool reserves;
 	struct page *page = NULL;
 	unsigned int alloc_flags;
 	unsigned long did_some_progress;
@@ -3514,15 +3540,24 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	if (gfp_mask & __GFP_KSWAPD_RECLAIM)
 		wake_all_kswapds(order, ac);
 
-	if (gfp_pfmemalloc_allowed(gfp_mask))
-		alloc_flags = ALLOC_NO_WATERMARKS;
+	/*
+	 * Distinguish requests which really need access to whole memory
+	 * reserves from oom victims which can live with their own reserve
+	 */
+	reserves = gfp_pfmemalloc_allowed(gfp_mask);
+	if (reserves) {
+		if (tsk_is_oom_victim(current))
+			alloc_flags = ALLOC_OOM;
+		else
+			alloc_flags = ALLOC_NO_WATERMARKS;
+	}
 
 	/*
 	 * Reset the zonelist iterators if memory policies can be ignored.
 	 * These allocations are high priority and system rather than user
 	 * orientated.
 	 */
-	if (!(alloc_flags & ALLOC_CPUSET) || (alloc_flags & ALLOC_NO_WATERMARKS)) {
+	if (!(alloc_flags & ALLOC_CPUSET) || reserves) {
 		ac->zonelist = node_zonelist(numa_node_id(), gfp_mask);
 		ac->preferred_zoneref = first_zones_zonelist(ac->zonelist,
 					ac->high_zoneidx, ac->nodemask);
@@ -3558,8 +3593,8 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 		goto nopage;
 	}
 
-	/* Avoid allocations with no watermarks from looping endlessly */
-	if (test_thread_flag(TIF_MEMDIE) && !(gfp_mask & __GFP_NOFAIL))
+	/* Avoid allocations for oom victims from looping endlessly */
+	if (tsk_is_oom_victim(current) && !(gfp_mask & __GFP_NOFAIL))
 		goto nopage;
 
 
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
