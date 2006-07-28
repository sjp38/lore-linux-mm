From: Nick Piggin <npiggin@suse.de>
Message-Id: <20060515210614.30275.39068.sendpatchset@linux.site>
In-Reply-To: <20060515210529.30275.74992.sendpatchset@linux.site>
References: <20060515210529.30275.74992.sendpatchset@linux.site>
Subject: [patch 5/9] oom: handle current exiting
Date: Fri, 28 Jul 2006 09:21:28 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Nick Piggin <npiggin@suse.de>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

If current *is* exiting, it should actually be allowed to access reserved
memory rather than OOM kill something else. Can't do this via a straight check
in page_alloc.c because that would allow multiple tasks to use up reserves.
Instead cause current to OOM-kill itself which will mark it as TIF_MEMDIE.

The current procedure of simply aborting the OOM-kill if a task is exiting
can lead to OOM deadlocks.

In the case of killing a PF_EXITING task, don't make a lot of noise about it.
This becomes more important in future patches, where we can "kill" OOM_DISABLE
tasks.

Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/mm/oom_kill.c
===================================================================
--- linux-2.6.orig/mm/oom_kill.c
+++ linux-2.6/mm/oom_kill.c
@@ -208,11 +208,26 @@ static struct task_struct *select_bad_pr
 		/*
 		 * This is in the process of releasing memory so wait for it
 		 * to finish before killing some other task by mistake.
+		 *
+		 * However, if p is the current task, we allow the 'kill' to
+		 * go ahead if it is exiting: this will simply set TIF_MEMDIE,
+		 * which will allow it to gain access to memory reserves in
+		 * the process of exiting and releasing its resources.
+		 * Otherwise we could get an OOM deadlock.
 		 */
 		releasing = test_tsk_thread_flag(p, TIF_MEMDIE) ||
 						p->flags & PF_EXITING;
-		if (releasing && !(p->flags & PF_DEAD))
+		if (releasing) {
+			/* PF_DEAD tasks have already released their mm */
+			if (p->flags & PF_DEAD)
+				continue;
+			if (p->flags & PF_EXITING && p == current) {
+				chosen = p;
+				*ppoints = ULONG_MAX;
+				break;
+			}
 			return ERR_PTR(-1UL);
+		}
 		if (p->flags & PF_SWAPOFF)
 			return p;
 
@@ -246,8 +261,11 @@ static void __oom_kill_task(struct task_
 		return;
 	}
 	task_unlock(p);
-	printk(KERN_ERR "%s: Killed process %d (%s).\n",
+
+	if (message) {
+		printk(KERN_ERR "%s: Killed process %d (%s).\n",
 				message, p->pid, p->comm);
+	}
 
 	/*
 	 * We give our sacrificial lamb high priority and access to
@@ -298,8 +316,17 @@ static int oom_kill_process(struct task_
 	struct task_struct *c;
 	struct list_head *tsk;
 
-	printk(KERN_ERR "Out of Memory: Kill process %d (%s) score %li and "
-		"children.\n", p->pid, p->comm, points);
+	/*
+	 * If the task is already exiting, don't alarm the sysadmin or kill
+	 * its children or threads, just set TIF_MEMDIE so it can die quickly
+	 */
+	if (p->flags & PF_EXITING) {
+		__oom_kill_task(p, NULL);
+		return 0;
+	}
+
+	printk(KERN_ERR "Out of Memory: Kill process %d (%s) score %li"
+			" and children.\n", p->pid, p->comm, points);
 	/* Try to kill a child first */
 	list_for_each(tsk, &p->children) {
 		c = list_entry(tsk, struct task_struct, sibling);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
