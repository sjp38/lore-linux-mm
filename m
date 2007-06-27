Date: Wed, 27 Jun 2007 07:44:05 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 2/4] oom: select process to kill for cpusets
In-Reply-To: <alpine.DEB.0.99.0706261947490.24949@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.0.99.0706261949140.24949@chino.kir.corp.google.com>
References: <alpine.DEB.0.99.0706261947490.24949@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <andrea@suse.de>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Passes the memory allocation constraint into select_bad_process() so
that, in the CONSTRAINT_CPUSET case, we can exclude tasks that do not
overlap nodes with the triggering task's cpuset.

The OOM killer now invokes select_bad_process() even in the cpuset case
to select a rogue task to kill instead of simply using current.  Although
killing current is guaranteed to help alleviate the OOM condition, it is
by no means guaranteed to be the "best" process to kill.  The
select_bad_process() heuristics will do a much better job of determining
that.

As an added bonus, this also addresses an issue whereas current could be
set to OOM_DISABLE and is not respected for the CONSTRAINT_CPUSET case.
Currently we loop back out to __alloc_pages() waiting for another cpuset
task to trigger the OOM killer that hopefully won't be OOM_DISABLE.  With
this patch, we're guaranteed to find a task to kill that is not
OOM_DISABLE if it matches our eligibility requirements the first time.

If we cannot find any tasks to kill in the cpuset case, we simply make
the entire OOM killer a no-op since it's better for one cpuset to fail
memory allocations repeatedly instead of panicing the entire system.

Cc: Andrea Arcangeli <andrea@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c |   25 +++++++++++++++++--------
 1 files changed, 17 insertions(+), 8 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -187,9 +187,13 @@ static inline int constrained_alloc(struct zonelist *zonelist, gfp_t gfp_mask)
  * Simple selection loop. We chose the process with the highest
  * number of 'points'. We expect the caller will lock the tasklist.
  *
+ * If constraint is CONSTRAINT_CPUSET, then only choose a task that overlaps
+ * the nodes of the task that triggered the OOM killer.
+ *
  * (not docbooked, we don't want this one cluttering up the manual)
  */
-static struct task_struct *select_bad_process(unsigned long *ppoints)
+static struct task_struct *select_bad_process(unsigned long *ppoints,
+					      int constraint)
 {
 	struct task_struct *g, *p;
 	struct task_struct *chosen = NULL;
@@ -221,6 +225,9 @@ static struct task_struct *select_bad_process(unsigned long *ppoints)
 
 		if (p->oomkilladj == OOM_DISABLE)
 			continue;
+		if (constraint == CONSTRAINT_CPUSET &&
+		    !cpuset_excl_nodes_overlap(p))
+			continue;
 
 		points = badness(p, uptime.tv_sec);
 		if (points > *ppoints || !chosen) {
@@ -423,12 +430,6 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask, int order)
 		break;
 
 	case CONSTRAINT_CPUSET:
-		read_lock(&tasklist_lock);
-		oom_kill_process(current, points,
-				 "No available memory in cpuset", gfp_mask, order);
-		read_unlock(&tasklist_lock);
-		break;
-
 	case CONSTRAINT_NONE:
 		if (down_trylock(&OOM_lock))
 			break;
@@ -453,9 +454,17 @@ retry:
 		 * Rambo mode: Shoot down a process and hope it solves whatever
 		 * issues we may have.
 		 */
-		p = select_bad_process(&points);
+		p = select_bad_process(&points, constraint);
 		/* Found nothing?!?! Either we hang forever, or we panic. */
 		if (unlikely(!p)) {
+			/*
+			 * We shouldn't panic the entire system if we can't
+			 * find any eligible tasks to kill in a
+			 * cpuset-constrained OOM condition.  Instead, we do
+			 * nothing and allow other cpusets to continue.
+			 */
+			if (constraint == CONSTRAINT_CPUSET)
+				goto out;
 			read_unlock(&tasklist_lock);
 			cpuset_unlock();
 			panic("Out of memory and no killable processes...\n");

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
