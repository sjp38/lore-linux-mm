Date: Wed, 19 Sep 2007 11:24:39 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 8/8] oom: do not check cpuset in badness scoring
In-Reply-To: <alpine.DEB.0.9999.0709190351460.23538@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.0.9999.0709190352030.23538@chino.kir.corp.google.com>
References: <alpine.DEB.0.9999.0709181950170.25510@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709190350001.23538@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709190350240.23538@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709190350410.23538@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709190350560.23538@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709190351140.23538@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709190351290.23538@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709190351460.23538@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <andrea@suse.de>, Christoph Lameter <clameter@sgi.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

It is no longer necessary to check whether a task's cpuset nodes overlap
with current because the tasklist has already been filtered with respect
to zones shared in the zonelist.

This leads to a nice optimization since callback_mutex is no longer
required; we can now have parallel OOM killings happening in separate
cpusets if their memory is mutually exclusive.

Cc: Andrea Arcangeli <andrea@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/cpuset.h |    6 ------
 kernel/cpuset.c        |   27 ---------------------------
 mm/oom_kill.c          |   11 -----------
 3 files changed, 0 insertions(+), 44 deletions(-)

diff --git a/include/linux/cpuset.h b/include/linux/cpuset.h
--- a/include/linux/cpuset.h
+++ b/include/linux/cpuset.h
@@ -58,9 +58,6 @@ extern void __cpuset_memory_pressure_bump(void);
 extern const struct file_operations proc_cpuset_operations;
 extern char *cpuset_task_status_allowed(struct task_struct *task, char *buffer);
 
-extern void cpuset_lock(void);
-extern void cpuset_unlock(void);
-
 extern int cpuset_mem_spread_node(void);
 
 static inline int cpuset_do_page_mem_spread(void)
@@ -128,9 +125,6 @@ static inline char *cpuset_task_status_allowed(struct task_struct *task,
 	return buffer;
 }
 
-static inline void cpuset_lock(void) {}
-static inline void cpuset_unlock(void) {}
-
 static inline int cpuset_mem_spread_node(void)
 {
 	return 0;
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -2524,33 +2524,6 @@ int __cpuset_zone_allowed_hardwall(struct zone *z, gfp_t gfp_mask)
 }
 
 /**
- * cpuset_lock - lock out any changes to cpuset structures
- *
- * The out of memory (oom) code needs to mutex_lock cpusets
- * from being changed while it scans the tasklist looking for a
- * task in an overlapping cpuset.  Expose callback_mutex via this
- * cpuset_lock() routine, so the oom code can lock it, before
- * locking the task list.  The tasklist_lock is a spinlock, so
- * must be taken inside callback_mutex.
- */
-
-void cpuset_lock(void)
-{
-	mutex_lock(&callback_mutex);
-}
-
-/**
- * cpuset_unlock - release lock on cpuset changes
- *
- * Undo the lock taken in a previous cpuset_lock() call.
- */
-
-void cpuset_unlock(void)
-{
-	mutex_unlock(&callback_mutex);
-}
-
-/**
  * cpuset_mem_spread_node() - On which node to begin search for a page
  *
  * If a task is marked PF_SPREAD_PAGE or PF_SPREAD_SLAB (as for
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -145,14 +145,6 @@ unsigned long badness(struct task_struct *p, unsigned long uptime)
 		points /= 4;
 
 	/*
-	 * If p's nodes don't overlap ours, it may still help to kill p
-	 * because p may have allocated or otherwise mapped memory on
-	 * this node before. However it will be less likely.
-	 */
-	if (!cpuset_excl_nodes_overlap(p))
-		points /= 8;
-
-	/*
 	 * Adjust the score by oomkilladj.
 	 */
 	if (p->oomkilladj) {
@@ -532,7 +524,6 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask, int order)
 	 * NUMA) that may require different handling.
 	 */
 	constraint = constrained_alloc(zonelist, gfp_mask);
-	cpuset_lock();
 	read_lock(&tasklist_lock);
 
 	switch (constraint) {
@@ -575,7 +566,6 @@ retry:
 		/* Found nothing?!?! Either we hang forever, or we panic. */
 		if (!p) {
 			read_unlock(&tasklist_lock);
-			cpuset_unlock();
 			panic("Out of memory and no killable processes...\n");
 		}
 
@@ -587,7 +577,6 @@ retry:
 
 out:
 	read_unlock(&tasklist_lock);
-	cpuset_unlock();
 
 	/*
 	 * Give "p" a good chance of killing itself before we

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
