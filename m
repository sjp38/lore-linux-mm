Date: Wed, 27 Jun 2007 07:44:09 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 3/4] oom: extract select helper function
In-Reply-To: <alpine.DEB.0.99.0706261949140.24949@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.0.99.0706261949490.24949@chino.kir.corp.google.com>
References: <alpine.DEB.0.99.0706261947490.24949@chino.kir.corp.google.com>
 <alpine.DEB.0.99.0706261949140.24949@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Extracts the call to select_bad_process() and the corresponding check for
a NULL return value or call to oom_kill_process() to its own function.
This will be used later for the cpuset case where we will require
different locking mechanisms than the generic case.

Cc: Andrea Arcangeli <andrea@suse.de>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c |   53 ++++++++++++++++++++++++++++-------------------------
 1 files changed, 28 insertions(+), 25 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -390,6 +390,32 @@ static int oom_is_deadlocked(unsigned long *last_tif_memdie)
 	return 1;
 }
 
+static void select_and_kill_process(gfp_t gfp_mask, int order, int constraint)
+{
+	struct task_struct *p;
+	unsigned long points = 0;
+
+retry:
+	p = select_bad_process(&points, constraint);
+	/* Found nothing?!?! Either we hang forever, or we panic. */
+	if (unlikely(!p)) {
+		/*
+		 * We shouldn't panic the entire system if we can't find any
+		 * eligible tasks to kill in a cpuset-constrained OOM
+		 * condition.  Instead, we do nothing and allow other cpusets
+		 * to continue.
+		 */
+		if (constraint == CONSTRAINT_CPUSET)
+			return;
+		read_unlock(&tasklist_lock);
+		cpuset_unlock();
+		panic("Out of memory and no killable processes...\n");
+	}
+
+	if (oom_kill_process(p, points, "Out of memory", gfp_mask, order))
+		goto retry;
+}
+
 /**
  * out_of_memory - kill the "best" process when we run out of memory
  *
@@ -400,8 +426,6 @@ static int oom_is_deadlocked(unsigned long *last_tif_memdie)
  */
 void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask, int order)
 {
-	struct task_struct *p;
-	unsigned long points = 0;
 	unsigned long freed = 0;
 	int constraint;
 	static DECLARE_MUTEX(OOM_lock);
@@ -424,7 +448,7 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask, int order)
 	switch (constraint) {
 	case CONSTRAINT_MEMORY_POLICY:
 		read_lock(&tasklist_lock);
-		oom_kill_process(current, points,
+		oom_kill_process(current, 0,
 				 "No available memory (MPOL_BIND)", gfp_mask, order);
 		read_unlock(&tasklist_lock);
 		break;
@@ -449,29 +473,8 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask, int order)
 			cpuset_unlock();
 			panic("out of memory. panic_on_oom is selected\n");
 		}
-retry:
-		/*
-		 * Rambo mode: Shoot down a process and hope it solves whatever
-		 * issues we may have.
-		 */
-		p = select_bad_process(&points, constraint);
-		/* Found nothing?!?! Either we hang forever, or we panic. */
-		if (unlikely(!p)) {
-			/*
-			 * We shouldn't panic the entire system if we can't
-			 * find any eligible tasks to kill in a
-			 * cpuset-constrained OOM condition.  Instead, we do
-			 * nothing and allow other cpusets to continue.
-			 */
-			if (constraint == CONSTRAINT_CPUSET)
-				goto out;
-			read_unlock(&tasklist_lock);
-			cpuset_unlock();
-			panic("Out of memory and no killable processes...\n");
-		}
 
-		if (oom_kill_process(p, points, "Out of memory", gfp_mask, order))
-			goto retry;
+		select_and_kill_process(gfp_mask, order, constraint);
 
 	out:
 		read_unlock(&tasklist_lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
