Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id C42156B025F
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 05:12:02 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id z36so26278063wrb.13
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 02:12:02 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id 16si14633699wrt.399.2017.07.27.02.12.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jul 2017 02:12:01 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id q189so11726519wmd.0
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 02:12:01 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 2/2] mm: replace TIF_MEMDIE checks by tsk_is_oom_victim
Date: Thu, 27 Jul 2017 11:03:57 +0200
Message-Id: <20170727090357.3205-3-mhocko@kernel.org>
In-Reply-To: <20170727090357.3205-1-mhocko@kernel.org>
References: <20170727090357.3205-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Roman Gushchin <guro@fb.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

TIF_MEMDIE is set only to the tasks whick were either directly selected
by the OOM killer or passed through mark_oom_victim from the allocator
path. tsk_is_oom_victim is more generic and allows to identify all tasks
(threads) which share the mm with the oom victim.

Please note that the freezer still needs to check TIF_MEMDIE because
we cannot thaw tasks which do not participage in oom_victims counting
otherwise a !TIF_MEMDIE task could interfere after oom_disbale returns.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 kernel/cgroup/cpuset.c | 8 ++++----
 mm/memcontrol.c        | 2 +-
 mm/oom_kill.c          | 2 +-
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/kernel/cgroup/cpuset.c b/kernel/cgroup/cpuset.c
index ca8376e5008c..1cc53dff0d94 100644
--- a/kernel/cgroup/cpuset.c
+++ b/kernel/cgroup/cpuset.c
@@ -2497,12 +2497,12 @@ static struct cpuset *nearest_hardwall_ancestor(struct cpuset *cs)
  * If we're in interrupt, yes, we can always allocate.  If @node is set in
  * current's mems_allowed, yes.  If it's not a __GFP_HARDWALL request and this
  * node is set in the nearest hardwalled cpuset ancestor to current's cpuset,
- * yes.  If current has access to memory reserves due to TIF_MEMDIE, yes.
+ * yes.  If current has access to memory reserves as an oom victim, yes.
  * Otherwise, no.
  *
  * GFP_USER allocations are marked with the __GFP_HARDWALL bit,
  * and do not allow allocations outside the current tasks cpuset
- * unless the task has been OOM killed as is marked TIF_MEMDIE.
+ * unless the task has been OOM killed.
  * GFP_KERNEL allocations are not so marked, so can escape to the
  * nearest enclosing hardwalled ancestor cpuset.
  *
@@ -2525,7 +2525,7 @@ static struct cpuset *nearest_hardwall_ancestor(struct cpuset *cs)
  * affect that:
  *	in_interrupt - any node ok (current task context irrelevant)
  *	GFP_ATOMIC   - any node ok
- *	TIF_MEMDIE   - any node ok
+ *	tsk_is_oom_victim   - any node ok
  *	GFP_KERNEL   - any node in enclosing hardwalled cpuset ok
  *	GFP_USER     - only nodes in current tasks mems allowed ok.
  */
@@ -2543,7 +2543,7 @@ bool __cpuset_node_allowed(int node, gfp_t gfp_mask)
 	 * Allow tasks that have access to memory reserves because they have
 	 * been OOM killed to get memory anywhere.
 	 */
-	if (unlikely(test_thread_flag(TIF_MEMDIE)))
+	if (unlikely(tsk_is_oom_victim(current)))
 		return true;
 	if (gfp_mask & __GFP_HARDWALL)	/* If hardwall request, stop here */
 		return false;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 544d47e5cbbd..86a48affb938 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1896,7 +1896,7 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	 * bypass the last charges so that they can exit quickly and
 	 * free their memory.
 	 */
-	if (unlikely(test_thread_flag(TIF_MEMDIE) ||
+	if (unlikely(tsk_is_oom_victim(current) ||
 		     fatal_signal_pending(current) ||
 		     current->flags & PF_EXITING))
 		goto force;
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index c9f3569a76c7..65cc2f9aaa05 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -483,7 +483,7 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 	 *				[...]
 	 *				out_of_memory
 	 *				  select_bad_process
-	 *				    # no TIF_MEMDIE task selects new victim
+	 *				    # no TIF_MEMDIE, selects new victim
 	 *  unmap_page_range # frees some memory
 	 */
 	mutex_lock(&oom_lock);
-- 
2.13.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
