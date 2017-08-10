Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1BEA36B02F3
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 03:50:29 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id r7so8487wrb.0
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 00:50:29 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id x18si5699923edi.261.2017.08.10.00.50.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Aug 2017 00:50:27 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id q189so2048951wmd.0
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 00:50:27 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 2/2] mm: replace TIF_MEMDIE checks by tsk_is_oom_victim
Date: Thu, 10 Aug 2017 09:50:19 +0200
Message-Id: <20170810075019.28998-3-mhocko@kernel.org>
In-Reply-To: <20170810075019.28998-1-mhocko@kernel.org>
References: <20170810075019.28998-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

TIF_MEMDIE is set only to the tasks whick were either directly selected
by the OOM killer or passed through mark_oom_victim from the allocator
path. tsk_is_oom_victim is more generic and allows to identify all tasks
(threads) which share the mm with the oom victim.

Please note that the freezer still needs to check TIF_MEMDIE because
we cannot thaw tasks which do not participage in oom_victims counting
otherwise a !TIF_MEMDIE task could interfere after oom_disbale returns.

Changes since v1
- fix implicit declaration of function 'tsk_is_oom_victim' reported by
  0day

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 kernel/cgroup/cpuset.c | 9 +++++----
 mm/memcontrol.c        | 2 +-
 2 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/kernel/cgroup/cpuset.c b/kernel/cgroup/cpuset.c
index ca8376e5008c..734ae4fa9775 100644
--- a/kernel/cgroup/cpuset.c
+++ b/kernel/cgroup/cpuset.c
@@ -56,6 +56,7 @@
 #include <linux/time64.h>
 #include <linux/backing-dev.h>
 #include <linux/sort.h>
+#include <linux/oom.h>
 
 #include <linux/uaccess.h>
 #include <linux/atomic.h>
@@ -2497,12 +2498,12 @@ static struct cpuset *nearest_hardwall_ancestor(struct cpuset *cs)
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
@@ -2525,7 +2526,7 @@ static struct cpuset *nearest_hardwall_ancestor(struct cpuset *cs)
  * affect that:
  *	in_interrupt - any node ok (current task context irrelevant)
  *	GFP_ATOMIC   - any node ok
- *	TIF_MEMDIE   - any node ok
+ *	tsk_is_oom_victim   - any node ok
  *	GFP_KERNEL   - any node in enclosing hardwalled cpuset ok
  *	GFP_USER     - only nodes in current tasks mems allowed ok.
  */
@@ -2543,7 +2544,7 @@ bool __cpuset_node_allowed(int node, gfp_t gfp_mask)
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
-- 
2.13.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
