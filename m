Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id B2EF36B0038
	for <linux-mm@kvack.org>; Sat, 28 Oct 2017 04:07:50 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id n137so18726311iod.20
        for <linux-mm@kvack.org>; Sat, 28 Oct 2017 01:07:50 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id b11si6652490ioj.72.2017.10.28.01.07.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 28 Oct 2017 01:07:49 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] mm,oom: Try last second allocation before and after selecting an OOM victim.
Date: Sat, 28 Oct 2017 17:07:09 +0900
Message-Id: <1509178029-10156-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Manish Jaggi <mjaggi@caviumnetworks.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Vlastimil Babka <vbabka@suse.cz>

This patch splits last second allocation attempt into two locations, once
before selecting an OOM victim and again after selecting an OOM victim,
and uses normal watermark for last second allocation attempts.

As of linux-2.6.11, nothing prevented from concurrently calling
out_of_memory(). TIF_MEMDIE test in select_bad_process() tried to avoid
needless OOM killing. Thus, it was safe to do __GFP_DIRECT_RECLAIM
allocation (apart from which watermark should be used) just before
calling out_of_memory().

As of linux-2.6.24, try_set_zone_oom() was added to
__alloc_pages_may_oom() by commit ff0ceb9deb6eb017 ("oom: serialize out
of memory calls") which effectively started acting as a kind of today's
mutex_trylock(&oom_lock).

As of linux-4.2, try_set_zone_oom() was replaced with oom_lock by
commit dc56401fc9f25e8f ("mm: oom_kill: simplify OOM killer locking").
At least by this time, it became no longer safe to do
__GFP_DIRECT_RECLAIM allocation with oom_lock held.

And as of linux-4.13, last second allocation attempt stopped using
__GFP_DIRECT_RECLAIM by commit e746bf730a76fe53 ("mm,page_alloc: don't
call __node_reclaim() with oom_lock held.").

Therefore, there is no longer valid reason to use ALLOC_WMARK_HIGH for
last second allocation attempt [1]. And this patch changes to do normal
allocation attempt, with handling of ALLOC_OOM added in order to mitigate
extra OOM victim selection problem reported by Manish Jaggi [2].

Doing really last second allocation attempt after selecting an OOM victim
will also help the OOM reaper to start reclaiming memory without waiting
for oom_lock to be released.

[1] http://lkml.kernel.org/r/20160128163802.GA15953@dhcp22.suse.cz
[2] http://lkml.kernel.org/r/e6c83a26-1d59-4afd-55cf-04e58bdde188@caviumnetworks.com

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Fixes: 696453e66630ad45 ("mm, oom: task_will_free_mem should skip oom_reaped tasks")
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Manish Jaggi <mjaggi@caviumnetworks.com>
---
 include/linux/oom.h | 13 +++++++++++++
 mm/oom_kill.c       | 13 +++++++++++++
 mm/page_alloc.c     | 47 ++++++++++++++++++++++++++++++++++-------------
 3 files changed, 60 insertions(+), 13 deletions(-)

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
index 26add8a..dcde1d5 100644
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
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 97687b3..ba0ef7b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3265,7 +3265,7 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
 
 static inline struct page *
 __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
-	const struct alloc_context *ac, unsigned long *did_some_progress)
+	struct alloc_context *ac, unsigned long *did_some_progress)
 {
 	struct oom_control oc = {
 		.zonelist = ac->zonelist,
@@ -3273,6 +3273,7 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
 		.memcg = NULL,
 		.gfp_mask = gfp_mask,
 		.order = order,
+		.ac = ac,
 	};
 	struct page *page;
 
@@ -3289,15 +3290,11 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
 	}
 
 	/*
-	 * Go through the zonelist yet one more time, keep very high watermark
-	 * here, this is only to catch a parallel oom killing, we must fail if
-	 * we're still under heavy pressure. But make sure that this reclaim
-	 * attempt shall not depend on __GFP_DIRECT_RECLAIM && !__GFP_NORETRY
-	 * allocation which will never fail due to oom_lock already held.
+	 * Try almost last second allocation attempt before we select an OOM
+	 * victim, for somebody might have managed to free memory or the OOM
+	 * killer might have called mark_oom_victim(current).
 	 */
-	page = get_page_from_freelist((gfp_mask | __GFP_HARDWALL) &
-				      ~__GFP_DIRECT_RECLAIM, order,
-				      ALLOC_WMARK_HIGH|ALLOC_CPUSET, ac);
+	page = alloc_pages_before_oomkill(&oc);
 	if (page)
 		goto out;
 
@@ -3335,16 +3332,18 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
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
@@ -4114,6 +4113,28 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 	return page;
 }
 
+struct page *alloc_pages_before_oomkill(struct oom_control *oc)
+{
+	/*
+	 * Make sure that this allocation attempt shall not depend on
+	 * __GFP_DIRECT_RECLAIM && !__GFP_NORETRY allocation, for the caller is
+	 * already holding oom_lock.
+	 */
+	const gfp_t gfp_mask = oc->gfp_mask & ~__GFP_DIRECT_RECLAIM;
+	struct alloc_context *ac = oc->ac;
+	unsigned int alloc_flags = gfp_to_alloc_flags(gfp_mask);
+	const int reserve_flags = __gfp_pfmemalloc_flags(gfp_mask);
+
+	/* Need to update zonelist if selected as OOM victim. */
+	if (reserve_flags) {
+		alloc_flags = reserve_flags;
+		ac->zonelist = node_zonelist(numa_node_id(), gfp_mask);
+		ac->preferred_zoneref = first_zones_zonelist(ac->zonelist,
+					ac->high_zoneidx, ac->nodemask);
+	}
+	return get_page_from_freelist(gfp_mask, oc->order, alloc_flags, ac);
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
