Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id BE0726B0260
	for <linux-mm@kvack.org>; Tue,  4 Oct 2016 05:00:23 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id n24so409456557pfb.0
        for <linux-mm@kvack.org>; Tue, 04 Oct 2016 02:00:23 -0700 (PDT)
Received: from mail-pa0-f66.google.com (mail-pa0-f66.google.com. [209.85.220.66])
        by mx.google.com with ESMTPS id fl7si2702956pad.54.2016.10.04.02.00.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Oct 2016 02:00:23 -0700 (PDT)
Received: by mail-pa0-f66.google.com with SMTP id t6so6111308pae.2
        for <linux-mm@kvack.org>; Tue, 04 Oct 2016 02:00:23 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 2/4] mm: replace TIF_MEMDIE checks by tsk_is_oom_victim
Date: Tue,  4 Oct 2016 11:00:07 +0200
Message-Id: <20161004090009.7974-3-mhocko@kernel.org>
In-Reply-To: <20161004090009.7974-1-mhocko@kernel.org>
References: <20161004090009.7974-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

TIF_MEMDIE is set only to the tasks whick were either directly selected
by the OOM killer or passed through mark_oom_victim from the allocator
path. tsk_is_oom_victim is more generic and allows to identify all tasks
(threads) which share the mm with the oom victim.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 kernel/cpuset.c | 9 +++++----
 mm/memcontrol.c | 2 +-
 mm/oom_kill.c   | 2 +-
 3 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index c7fd2778ed50..8e370d9d63ee 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -54,6 +54,7 @@
 #include <linux/time64.h>
 #include <linux/backing-dev.h>
 #include <linux/sort.h>
+#include <linux/oom.h>
 
 #include <asm/uaccess.h>
 #include <linux/atomic.h>
@@ -2487,12 +2488,12 @@ static struct cpuset *nearest_hardwall_ancestor(struct cpuset *cs)
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
@@ -2515,7 +2516,7 @@ static struct cpuset *nearest_hardwall_ancestor(struct cpuset *cs)
  * affect that:
  *	in_interrupt - any node ok (current task context irrelevant)
  *	GFP_ATOMIC   - any node ok
- *	TIF_MEMDIE   - any node ok
+ *	tsk_is_oom_victim - any node ok
  *	GFP_KERNEL   - any node in enclosing hardwalled cpuset ok
  *	GFP_USER     - only nodes in current tasks mems allowed ok.
  */
@@ -2533,7 +2534,7 @@ bool __cpuset_node_allowed(int node, gfp_t gfp_mask)
 	 * Allow tasks that have access to memory reserves because they have
 	 * been OOM killed to get memory anywhere.
 	 */
-	if (unlikely(test_thread_flag(TIF_MEMDIE)))
+	if (unlikely(tsk_is_oom_victim(current)))
 		return true;
 	if (gfp_mask & __GFP_HARDWALL)	/* If hardwall request, stop here */
 		return false;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 6d08f0908d4a..4da2b29d8d72 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1912,7 +1912,7 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	 * bypass the last charges so that they can exit quickly and
 	 * free their memory.
 	 */
-	if (unlikely(test_thread_flag(TIF_MEMDIE) ||
+	if (unlikely(tsk_is_oom_victim(current) ||
 		     fatal_signal_pending(current) ||
 		     current->flags & PF_EXITING))
 		goto force;
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 42c112f0ba23..f47202725ea9 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -477,7 +477,7 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 	 *				[...]
 	 *				out_of_memory
 	 *				  select_bad_process
-	 *				    # no TIF_MEMDIE task selects new victim
+	 *				    # no oom victim, selects new victim
 	 *  unmap_page_range # frees some memory
 	 */
 	mutex_lock(&oom_lock);
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
