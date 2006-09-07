Date: Thu, 7 Sep 2006 12:34:56 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [patch] oom: don't kill current when another OOM in progress
Message-ID: <20060907103456.GA3077@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

A previous patch to allow an exiting task to OOM kill itself (and thereby
avoid a little deadlock) introduced a problem.  We don't want the PF_EXITING
task, even if it is 'current', to access mem reserves if there is already a
TIF_MEMDIE process in the system sucking up reserves.

Also make the commenting a little bit clearer, and note that our current
scheme of effectively single threading the OOM killer is not itself perfect.

Signed-off-by: Nick Piggin <npiggin@suse.de>


Index: linux-2.6/mm/oom_kill.c
===================================================================
--- linux-2.6.orig/mm/oom_kill.c
+++ linux-2.6/mm/oom_kill.c
@@ -217,6 +217,18 @@ static struct task_struct *select_bad_pr
 			continue;
 
 		/*
+		 * This task already has access to memory reserves and is
+		 * being killed. Don't allow any other task access to the
+		 * memory reserve.
+		 *
+		 * Note: this may have a chance of deadlock if it gets
+		 * blocked waiting for another task which itself is waiting
+		 * for memory. Is there a better alternative?
+		 */
+		if (test_tsk_thread_flag(p, TIF_MEMDIE))
+			return ERR_PTR(-1UL);
+
+		/*
 		 * This is in the process of releasing memory so wait for it
 		 * to finish before killing some other task by mistake.
 		 *
@@ -224,16 +236,15 @@ static struct task_struct *select_bad_pr
 		 * go ahead if it is exiting: this will simply set TIF_MEMDIE,
 		 * which will allow it to gain access to memory reserves in
 		 * the process of exiting and releasing its resources.
-		 * Otherwise we could get an OOM deadlock.
+		 * Otherwise we could get an easy OOM deadlock.
 		 */
-		if ((p->flags & PF_EXITING) && p == current) {
+		if (p->flags & PF_EXITING) {
+			if (p != current)
+				return ERR_PTR(-1UL);
+
 			chosen = p;
 			*ppoints = ULONG_MAX;
-			break;
 		}
-		if ((p->flags & PF_EXITING) ||
-				test_tsk_thread_flag(p, TIF_MEMDIE))
-			return ERR_PTR(-1UL);
 
 		if (p->oomkilladj == OOM_DISABLE)
 			continue;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
