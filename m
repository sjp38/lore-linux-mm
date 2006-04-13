From: Dave Peterson <dsp@llnl.gov>
Subject: [PATCH 2/2] mm: fix mm_struct reference counting bugs in mm/oom_kill.c
Date: Thu, 13 Apr 2006 14:52:08 -0700
MIME-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200604131452.08292.dsp@llnl.gov>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, riel@surriel.com, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

The patch below fixes some mm_struct reference counting bugs in
badness().

Signed-Off-By: David S. Peterson <dsp@llnl.gov>
---

Index: linux-2.6.17-rc1-oom/mm/oom_kill.c
===================================================================
--- linux-2.6.17-rc1-oom.orig/mm/oom_kill.c	2006-04-13 14:25:16.000000000 -0700
+++ linux-2.6.17-rc1-oom/mm/oom_kill.c	2006-04-13 14:31:47.000000000 -0700
@@ -47,14 +47,17 @@ unsigned long badness(struct task_struct
 {
 	unsigned long points, cpu_time, run_time, s;
 	struct list_head *tsk;
+	struct mm_struct *mm, *child_mm;
 
-	if (!p->mm)
+	mm = get_task_mm(p);
+
+	if (mm == NULL)
 		return 0;
 
 	/*
 	 * The memory size of the process is the basis for the badness.
 	 */
-	points = p->mm->total_vm;
+	points = mm->total_vm;
 
 	/*
 	 * Processes which fork a lot of child processes are likely
@@ -67,10 +70,21 @@ unsigned long badness(struct task_struct
 	list_for_each(tsk, &p->children) {
 		struct task_struct *chld;
 		chld = list_entry(tsk, struct task_struct, sibling);
-		if (chld->mm != p->mm && chld->mm)
-			points += chld->mm->total_vm/2 + 1;
+
+		if (chld->mm == mm)
+			continue;
+
+		child_mm = get_task_mm(chld);
+
+		if (child_mm == NULL)
+			continue;
+
+		points += child_mm->total_vm/2 + 1;
+		mmput(child_mm);
 	}
 
+	mmput(mm);
+
 	/*
 	 * CPU time is in tens of seconds and run time is in thousands
          * of seconds. There is no particular reason for this other than

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
