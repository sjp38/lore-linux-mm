Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id BE5D36B0069
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 17:06:58 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rp2so6186830pbb.14
        for <linux-mm@kvack.org>; Fri, 29 Jun 2012 14:06:58 -0700 (PDT)
Date: Fri, 29 Jun 2012 14:06:56 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 3/5] mm, memcg: introduce own oom handler to iterate only
 over its own threads
In-Reply-To: <alpine.DEB.2.00.1206291404530.6040@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1206291405500.6040@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1206251846020.24838@chino.kir.corp.google.com> <alpine.DEB.2.00.1206291404530.6040@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan@kernel.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, cgroups@vger.kernel.org

The global oom killer is serialized by the zonelist being used in the
page allocation.  Concurrent oom kills are thus a rare event and only
occur in systems using mempolicies and with a large number of nodes.

Memory controller oom kills, however, can frequently be concurrent since
there is no serialization once the oom killer is called for oom
conditions in several different memcgs in parallel.

This creates a massive contention on tasklist_lock since the oom killer
requires the readside for the tasklist iteration.  If several memcgs are
calling the oom killer, this lock can be held for a substantial amount of
time, especially if threads continue to enter it as other threads are
exiting.

Since the exit path grabs the writeside of the lock with irqs disabled in
a few different places, this can cause a soft lockup on cpus as a result
of tasklist_lock starvation.

The kernel lacks unfair writelocks, and successful calls to the oom
killer usually result in at least one thread entering the exit path, so
an alternative solution is needed.

This patch introduces a seperate oom handler for memcgs so that they do
not require tasklist_lock for as much time.  Instead, it iterates only
over the threads attached to the oom memcg and grabs a reference to the
selected thread before calling oom_kill_process() to ensure it doesn't
prematurely exit.

This still requires tasklist_lock for the tasklist dump, iterating
children of the selected process, and killing all other threads on the
system sharing the same memory as the selected victim.  So while this
isn't a complete solution to tasklist_lock starvation, it significantly
reduces the amount of time that it is held.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Acked-by: Michal Hocko <mhocko@suse.cz>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/memcontrol.h |    9 +-----
 include/linux/oom.h        |   16 +++++++++++
 mm/memcontrol.c            |   61 +++++++++++++++++++++++++++++++++++++++++++-
 mm/oom_kill.c              |   48 +++++++++++-----------------------
 4 files changed, 93 insertions(+), 41 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -180,7 +180,8 @@ static inline void mem_cgroup_dec_page_stat(struct page *page,
 unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 						gfp_t gfp_mask,
 						unsigned long *total_scanned);
-u64 mem_cgroup_get_limit(struct mem_cgroup *memcg);
+extern void __mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
+				       int order);
 
 void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx);
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
@@ -364,12 +365,6 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 	return 0;
 }
 
-static inline
-u64 mem_cgroup_get_limit(struct mem_cgroup *memcg)
-{
-	return 0;
-}
-
 static inline void mem_cgroup_split_huge_fixup(struct page *head)
 {
 }
diff --git a/include/linux/oom.h b/include/linux/oom.h
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -40,17 +40,33 @@ enum oom_constraint {
 	CONSTRAINT_MEMCG,
 };
 
+enum oom_scan_t {
+	OOM_SCAN_OK,		/* scan thread and find its badness */
+	OOM_SCAN_CONTINUE,	/* do not consider thread for oom kill */
+	OOM_SCAN_ABORT,		/* abort the iteration and return */
+	OOM_SCAN_SELECT,	/* always select this thread first */
+};
+
 extern void compare_swap_oom_score_adj(int old_val, int new_val);
 extern int test_set_oom_score_adj(int new_val);
 
 extern unsigned long oom_badness(struct task_struct *p,
 		struct mem_cgroup *memcg, const nodemask_t *nodemask,
 		unsigned long totalpages);
+extern void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
+			     unsigned int points, unsigned long totalpages,
+			     struct mem_cgroup *memcg, nodemask_t *nodemask,
+			     const char *message);
+
 extern int try_set_zonelist_oom(struct zonelist *zonelist, gfp_t gfp_flags);
 extern void clear_zonelist_oom(struct zonelist *zonelist, gfp_t gfp_flags);
 
+extern enum oom_scan_t oom_scan_process_thread(struct task_struct *task,
+		unsigned long totalpages, const nodemask_t *nodemask,
+		bool force_kill);
 extern void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 				     int order);
+
 extern void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 		int order, nodemask_t *mask, bool force_kill);
 extern int register_oom_notifier(struct notifier_block *nb);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1453,7 +1453,7 @@ static int mem_cgroup_count_children(struct mem_cgroup *memcg)
 /*
  * Return the memory (and swap, if configured) limit for a memcg.
  */
-u64 mem_cgroup_get_limit(struct mem_cgroup *memcg)
+static u64 mem_cgroup_get_limit(struct mem_cgroup *memcg)
 {
 	u64 limit;
 	u64 memsw;
@@ -1469,6 +1469,65 @@ u64 mem_cgroup_get_limit(struct mem_cgroup *memcg)
 	return min(limit, memsw);
 }
 
+void __mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
+				int order)
+{
+	struct mem_cgroup *iter;
+	unsigned long chosen_points = 0;
+	unsigned long totalpages;
+	unsigned int points = 0;
+	struct task_struct *chosen = NULL;
+
+	totalpages = mem_cgroup_get_limit(memcg) >> PAGE_SHIFT ? : 1;
+	for_each_mem_cgroup_tree(iter, memcg) {
+		struct cgroup *cgroup = iter->css.cgroup;
+		struct cgroup_iter it;
+		struct task_struct *task;
+
+		cgroup_iter_start(cgroup, &it);
+		while ((task = cgroup_iter_next(cgroup, &it))) {
+			switch (oom_scan_process_thread(task, totalpages, NULL,
+							false)) {
+			case OOM_SCAN_SELECT:
+				if (chosen)
+					put_task_struct(chosen);
+				chosen = task;
+				chosen_points = ULONG_MAX;
+				get_task_struct(chosen);
+				/* fall through */
+			case OOM_SCAN_CONTINUE:
+				continue;
+			case OOM_SCAN_ABORT:
+				cgroup_iter_end(cgroup, &it);
+				mem_cgroup_iter_break(memcg, iter);
+				if (chosen)
+					put_task_struct(chosen);
+				return;
+			case OOM_SCAN_OK:
+				break;
+			};
+			points = oom_badness(task, memcg, NULL, totalpages);
+			if (points > chosen_points) {
+				if (chosen)
+					put_task_struct(chosen);
+				chosen = task;
+				chosen_points = points;
+				get_task_struct(chosen);
+			}
+		}
+		cgroup_iter_end(cgroup, &it);
+	}
+
+	if (!chosen)
+		return;
+	points = chosen_points * 1000 / totalpages;
+	read_lock(&tasklist_lock);
+	oom_kill_process(chosen, gfp_mask, order, points, totalpages, memcg,
+			 NULL, "Memory cgroup out of memory");
+	read_unlock(&tasklist_lock);
+	put_task_struct(chosen);
+}
+
 static unsigned long mem_cgroup_reclaim(struct mem_cgroup *memcg,
 					gfp_t gfp_mask,
 					unsigned long flags)
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -288,20 +288,13 @@ static enum oom_constraint constrained_alloc(struct zonelist *zonelist,
 }
 #endif
 
-enum oom_scan_t {
-	OOM_SCAN_OK,		/* scan thread and find its badness */
-	OOM_SCAN_CONTINUE,	/* do not consider thread for oom kill */
-	OOM_SCAN_ABORT,		/* abort the iteration and return */
-	OOM_SCAN_SELECT,	/* always select this thread first */
-};
-
-static enum oom_scan_t oom_scan_process_thread(struct task_struct *task,
-		struct mem_cgroup *memcg, unsigned long totalpages,
-		const nodemask_t *nodemask, bool force_kill)
+enum oom_scan_t oom_scan_process_thread(struct task_struct *task,
+		unsigned long totalpages, const nodemask_t *nodemask,
+		bool force_kill)
 {
 	if (task->exit_state)
 		return OOM_SCAN_CONTINUE;
-	if (oom_unkillable_task(task, memcg, nodemask))
+	if (oom_unkillable_task(task, NULL, nodemask))
 		return OOM_SCAN_CONTINUE;
 
 	/*
@@ -348,8 +341,8 @@ static enum oom_scan_t oom_scan_process_thread(struct task_struct *task,
  * (not docbooked, we don't want this one cluttering up the manual)
  */
 static struct task_struct *select_bad_process(unsigned int *ppoints,
-		unsigned long totalpages, struct mem_cgroup *memcg,
-		const nodemask_t *nodemask, bool force_kill)
+		unsigned long totalpages, const nodemask_t *nodemask,
+		bool force_kill)
 {
 	struct task_struct *g, *p;
 	struct task_struct *chosen = NULL;
@@ -358,7 +351,7 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
 	do_each_thread(g, p) {
 		unsigned int points;
 
-		switch (oom_scan_process_thread(p, memcg, totalpages, nodemask,
+		switch (oom_scan_process_thread(p, totalpages, nodemask,
 						force_kill)) {
 		case OOM_SCAN_SELECT:
 			chosen = p;
@@ -371,7 +364,7 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
 		case OOM_SCAN_OK:
 			break;
 		};
-		points = oom_badness(p, memcg, nodemask, totalpages);
+		points = oom_badness(p, NULL, nodemask, totalpages);
 		if (points > chosen_points) {
 			chosen = p;
 			chosen_points = points;
@@ -442,10 +435,10 @@ static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
 }
 
 #define K(x) ((x) << (PAGE_SHIFT-10))
-static void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
-			     unsigned int points, unsigned long totalpages,
-			     struct mem_cgroup *memcg, nodemask_t *nodemask,
-			     const char *message)
+void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
+		      unsigned int points, unsigned long totalpages,
+		      struct mem_cgroup *memcg, nodemask_t *nodemask,
+		      const char *message)
 {
 	struct task_struct *victim = p;
 	struct task_struct *child;
@@ -563,10 +556,6 @@ static void check_panic_on_oom(enum oom_constraint constraint, gfp_t gfp_mask,
 void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 			      int order)
 {
-	unsigned long limit;
-	unsigned int points = 0;
-	struct task_struct *p;
-
 	/*
 	 * If current has a pending SIGKILL, then automatically select it.  The
 	 * goal is to allow it to allocate so that it may quickly exit and free
@@ -578,13 +567,7 @@ void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	}
 
 	check_panic_on_oom(CONSTRAINT_MEMCG, gfp_mask, order, NULL);
-	limit = mem_cgroup_get_limit(memcg) >> PAGE_SHIFT ? : 1;
-	read_lock(&tasklist_lock);
-	p = select_bad_process(&points, limit, memcg, NULL, false);
-	if (p && PTR_ERR(p) != -1UL)
-		oom_kill_process(p, gfp_mask, order, points, limit, memcg, NULL,
-				 "Memory cgroup out of memory");
-	read_unlock(&tasklist_lock);
+	__mem_cgroup_out_of_memory(memcg, gfp_mask, order);
 }
 #endif
 
@@ -709,7 +692,7 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 	struct task_struct *p;
 	unsigned long totalpages;
 	unsigned long freed = 0;
-	unsigned int points;
+	unsigned int uninitialized_var(points);
 	enum oom_constraint constraint = CONSTRAINT_NONE;
 	int killed = 0;
 
@@ -747,8 +730,7 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 		goto out;
 	}
 
-	p = select_bad_process(&points, totalpages, NULL, mpol_mask,
-			       force_kill);
+	p = select_bad_process(&points, totalpages, mpol_mask, force_kill);
 	/* Found nothing?!?! Either we hang forever, or we panic. */
 	if (!p) {
 		dump_header(NULL, gfp_mask, order, NULL, mpol_mask);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
