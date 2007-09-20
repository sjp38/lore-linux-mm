Date: Thu, 20 Sep 2007 13:23:23 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 8/9] oom: compare cpuset mems_allowed instead of exclusive
 ancestors
In-Reply-To: <alpine.DEB.0.9999.0709201321530.25753@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.0.9999.0709201322080.25753@chino.kir.corp.google.com>
References: <alpine.DEB.0.9999.0709201318090.25753@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709201319300.25753@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709201319520.25753@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709201320521.25753@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709201321070.25753@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709201321220.25753@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709201321380.25753@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709201321530.25753@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <andrea@suse.de>, Christoph Lameter <clameter@sgi.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Instead of testing for overlap in the memory nodes of the the nearest
exclusive ancestor of both current and the candidate task, it is better
to simply test for intersection between the task's mems_allowed in their
task descriptors.  This does not require taking callback_mutex since it
is only used as a hint in the badness scoring.

Tasks that do not have an intersection in their mems_allowed with the
current task are not explicitly restricted from being OOM killed because
it is quite possible that the candidate task has allocated memory there
before and has since changed its mems_allowed.

Cc: Andrea Arcangeli <andrea@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/cpuset.h |    6 ++++--
 kernel/cpuset.c        |   43 +++++++++++--------------------------------
 mm/oom_kill.c          |    2 +-
 3 files changed, 16 insertions(+), 35 deletions(-)

diff --git a/include/linux/cpuset.h b/include/linux/cpuset.h
--- a/include/linux/cpuset.h
+++ b/include/linux/cpuset.h
@@ -45,7 +45,8 @@ static int inline cpuset_zone_allowed_hardwall(struct zone *z, gfp_t gfp_mask)
 		__cpuset_zone_allowed_hardwall(z, gfp_mask);
 }
 
-extern int cpuset_excl_nodes_overlap(const struct task_struct *p);
+extern int cpuset_mems_allowed_intersects(const struct task_struct *tsk1,
+					  const struct task_struct *tsk2);
 
 #define cpuset_memory_pressure_bump() 				\
 	do {							\
@@ -113,7 +114,8 @@ static inline int cpuset_zone_allowed_hardwall(struct zone *z, gfp_t gfp_mask)
 	return 1;
 }
 
-static inline int cpuset_excl_nodes_overlap(const struct task_struct *p)
+static inline int cpuset_mems_allowed_intersects(const struct task_struct *tsk1,
+						 const struct task_struct *tsk2)
 {
 	return 1;
 }
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -2566,41 +2566,20 @@ int cpuset_mem_spread_node(void)
 EXPORT_SYMBOL_GPL(cpuset_mem_spread_node);
 
 /**
- * cpuset_excl_nodes_overlap - Do we overlap @p's mem_exclusive ancestors?
- * @p: pointer to task_struct of some other task.
- *
- * Description: Return true if the nearest mem_exclusive ancestor
- * cpusets of tasks @p and current overlap.  Used by oom killer to
- * determine if task @p's memory usage might impact the memory
- * available to the current task.
- *
- * Call while holding callback_mutex.
+ * cpuset_mems_allowed_intersects - Does @tsk1's mems_allowed intersect @tsk2's?
+ * @tsk1: pointer to task_struct of some task.
+ * @tsk2: pointer to task_struct of some other task.
+ *
+ * Description: Return true if @tsk1's mems_allowed intersects the
+ * mems_allowed of @tsk2.  Used by the OOM killer to determine if
+ * one of the task's memory usage might impact the memory available
+ * to the other.
  **/
 
-int cpuset_excl_nodes_overlap(const struct task_struct *p)
+int cpuset_mems_allowed_intersects(const struct task_struct *tsk1,
+				   const struct task_struct *tsk2)
 {
-	const struct cpuset *cs1, *cs2;	/* my and p's cpuset ancestors */
-	int overlap = 1;		/* do cpusets overlap? */
-
-	task_lock(current);
-	if (current->flags & PF_EXITING) {
-		task_unlock(current);
-		goto done;
-	}
-	cs1 = nearest_exclusive_ancestor(current->cpuset);
-	task_unlock(current);
-
-	task_lock((struct task_struct *)p);
-	if (p->flags & PF_EXITING) {
-		task_unlock((struct task_struct *)p);
-		goto done;
-	}
-	cs2 = nearest_exclusive_ancestor(p->cpuset);
-	task_unlock((struct task_struct *)p);
-
-	overlap = nodes_intersects(cs1->mems_allowed, cs2->mems_allowed);
-done:
-	return overlap;
+	return nodes_intersects(tsk1->mems_allowed, tsk2->mems_allowed);
 }
 
 /*
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -143,7 +143,7 @@ unsigned long badness(struct task_struct *p, unsigned long uptime)
 	 * because p may have allocated or otherwise mapped memory on
 	 * this node before. However it will be less likely.
 	 */
-	if (!cpuset_excl_nodes_overlap(p))
+	if (!cpuset_mems_allowed_intersects(current, p))
 		points /= 8;
 
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
