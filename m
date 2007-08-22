Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 22 of 24] extract select helper function
Message-Id: <8807a4d14b241b2d1132.1187786949@v2.random>
In-Reply-To: <patchbomb.1187786927@v2.random>
Date: Wed, 22 Aug 2007 14:49:09 +0200
From: Andrea Arcangeli <andrea@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

# HG changeset patch
# User David Rientjes <rientjes@google.com>
# Date 1187778125 -7200
# Node ID 8807a4d14b241b2d1132fde7f83834603b6cf093
# Parent  855dc37d74ab151d7a0c640d687b34ee05996235
extract select helper function

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
@@ -391,6 +391,32 @@ static int oom_is_deadlocked(unsigned lo
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
@@ -401,8 +427,6 @@ static int oom_is_deadlocked(unsigned lo
  */
 void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask, int order)
 {
-	struct task_struct *p;
-	unsigned long points = 0;
 	unsigned long freed = 0;
 	int constraint;
 	static DECLARE_MUTEX(OOM_lock);
@@ -425,7 +449,7 @@ void out_of_memory(struct zonelist *zone
 	switch (constraint) {
 	case CONSTRAINT_MEMORY_POLICY:
 		read_lock(&tasklist_lock);
-		oom_kill_process(current, points,
+		oom_kill_process(current, 0,
 				 "No available memory (MPOL_BIND)", gfp_mask, order);
 		read_unlock(&tasklist_lock);
 		break;
@@ -450,29 +474,8 @@ void out_of_memory(struct zonelist *zone
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
-
-		if (oom_kill_process(p, points, "Out of memory", gfp_mask, order))
-			goto retry;
+
+		select_and_kill_process(gfp_mask, order, constraint);
 
 	out:
 		read_unlock(&tasklist_lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
