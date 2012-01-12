Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 5795F6B005A
	for <linux-mm@kvack.org>; Wed, 11 Jan 2012 22:24:24 -0500 (EST)
Received: by ggnp4 with SMTP id p4so957693ggn.14
        for <linux-mm@kvack.org>; Wed, 11 Jan 2012 19:24:23 -0800 (PST)
Date: Wed, 11 Jan 2012 19:24:20 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch 1/3] mm, oom: avoid looping when chosen thread detaches its
 mm
Message-ID: <alpine.DEB.2.00.1201111922500.3982@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org

oom_kill_task() returns non-zero iff the chosen process does not have any
threads with an attached ->mm.

In such a case, it's better to just return to the page allocator and
retry the allocation because memory could have been freed in the interim
and the oom condition may no longer exist.  It's unnecessary to loop in
the oom killer and find another thread to kill.

This allows both oom_kill_task() and oom_kill_process() to be converted
to void functions.  If the oom condition persists, the oom killer will be
recalled.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c |   56 ++++++++++++++++++++------------------------------------
 1 files changed, 20 insertions(+), 36 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -434,14 +434,14 @@ static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
 }
 
 #define K(x) ((x) << (PAGE_SHIFT-10))
-static int oom_kill_task(struct task_struct *p, struct mem_cgroup *mem)
+static void oom_kill_task(struct task_struct *p, struct mem_cgroup *mem)
 {
 	struct task_struct *q;
 	struct mm_struct *mm;
 
 	p = find_lock_task_mm(p);
 	if (!p)
-		return 1;
+		return;
 
 	/* mm cannot be safely dereferenced after task_unlock(p) */
 	mm = p->mm;
@@ -477,15 +477,13 @@ static int oom_kill_task(struct task_struct *p, struct mem_cgroup *mem)
 
 	set_tsk_thread_flag(p, TIF_MEMDIE);
 	force_sig(SIGKILL, p);
-
-	return 0;
 }
 #undef K
 
-static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
-			    unsigned int points, unsigned long totalpages,
-			    struct mem_cgroup *mem, nodemask_t *nodemask,
-			    const char *message)
+static void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
+			     unsigned int points, unsigned long totalpages,
+			     struct mem_cgroup *mem, nodemask_t *nodemask,
+			     const char *message)
 {
 	struct task_struct *victim = p;
 	struct task_struct *child;
@@ -501,7 +499,7 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 	 */
 	if (p->flags & PF_EXITING) {
 		set_tsk_thread_flag(p, TIF_MEMDIE);
-		return 0;
+		return;
 	}
 
 	task_lock(p);
@@ -533,7 +531,7 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 		}
 	} while_each_thread(p, t);
 
-	return oom_kill_task(victim, mem);
+	oom_kill_task(victim, mem);
 }
 
 /*
@@ -580,15 +578,10 @@ void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t gfp_mask)
 	check_panic_on_oom(CONSTRAINT_MEMCG, gfp_mask, 0, NULL);
 	limit = mem_cgroup_get_limit(mem) >> PAGE_SHIFT;
 	read_lock(&tasklist_lock);
-retry:
 	p = select_bad_process(&points, limit, mem, NULL);
-	if (!p || PTR_ERR(p) == -1UL)
-		goto out;
-
-	if (oom_kill_process(p, gfp_mask, 0, points, limit, mem, NULL,
-				"Memory cgroup out of memory"))
-		goto retry;
-out:
+	if (p && PTR_ERR(p) != -1UL)
+		oom_kill_process(p, gfp_mask, 0, points, limit, mem, NULL,
+				 "Memory cgroup out of memory");
 	read_unlock(&tasklist_lock);
 }
 #endif
@@ -745,33 +738,24 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 	if (sysctl_oom_kill_allocating_task &&
 	    !oom_unkillable_task(current, NULL, nodemask) &&
 	    current->mm) {
-		/*
-		 * oom_kill_process() needs tasklist_lock held.  If it returns
-		 * non-zero, current could not be killed so we must fallback to
-		 * the tasklist scan.
-		 */
-		if (!oom_kill_process(current, gfp_mask, order, 0, totalpages,
-				NULL, nodemask,
-				"Out of memory (oom_kill_allocating_task)"))
-			goto out;
+		oom_kill_process(current, gfp_mask, order, 0, totalpages, NULL,
+				 nodemask,
+				 "Out of memory (oom_kill_allocating_task)");
+		goto out;
 	}
 
-retry:
 	p = select_bad_process(&points, totalpages, NULL, mpol_mask);
-	if (PTR_ERR(p) == -1UL)
-		goto out;
-
 	/* Found nothing?!?! Either we hang forever, or we panic. */
 	if (!p) {
 		dump_header(NULL, gfp_mask, order, NULL, mpol_mask);
 		read_unlock(&tasklist_lock);
 		panic("Out of memory and no killable processes...\n");
 	}
-
-	if (oom_kill_process(p, gfp_mask, order, points, totalpages, NULL,
-				nodemask, "Out of memory"))
-		goto retry;
-	killed = 1;
+	if (PTR_ERR(p) != -1UL) {
+		oom_kill_process(p, gfp_mask, order, points, totalpages, NULL,
+				 nodemask, "Out of memory");
+		killed = 1;
+	}
 out:
 	read_unlock(&tasklist_lock);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
