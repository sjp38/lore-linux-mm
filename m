Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 07 of 13] don't depend on PF_EXITING tasks to go away
Message-Id: <ee9691f08d054949b771.1199778638@v2.random>
In-Reply-To: <patchbomb.1199778631@v2.random>
Date: Tue, 08 Jan 2008 08:50:38 +0100
From: Andrea Arcangeli <andrea@cpushare.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

# HG changeset patch
# User Andrea Arcangeli <andrea@suse.de>
# Date 1199470022 -3600
# Node ID ee9691f08d054949b7718cff94c4f132d97626de
# Parent  dd5900d0aa4e5f1b81364346465be53db897246f
don't depend on PF_EXITING tasks to go away

A PF_EXITING task don't have TIF_MEMDIE set so it might get stuck in
memory allocations without access to the PF_MEMALLOC pool (said that
ideally do_exit would better not require memory allocations, especially
not before calling exit_mm). The same way we raise its privilege to
TIF_MEMDIE if it's the current task, we should do it even if it's not
the current task to speedup oom killing.

Signed-off-by: Andrea Arcangeli <andrea@suse.de>

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -233,16 +233,16 @@ static struct task_struct *select_bad_pr
 		 * This is in the process of releasing memory so wait for it
 		 * to finish before killing some other task by mistake.
 		 *
-		 * However, if p is the current task, we allow the 'kill' to
-		 * go ahead if it is exiting: this will simply set TIF_MEMDIE,
-		 * which will allow it to gain access to memory reserves in
-		 * the process of exiting and releasing its resources.
-		 * Otherwise we could get an easy OOM deadlock.
+		 * We must however set TIF_MEMDIE on this task so we select it with
+		 * maximum points. This PF_EXITING task may be out of the scheduler
+		 * and zombie and it may have released all its memory already and
+		 * furthermore we want to give it access to all the memory reserves.
+		 *
+		 * If it's too late and this selected task can't release any memory
+		 * anymore the memdie_jiffies will timeout and fallback in killing
+		 * a new task later.
 		 */
 		if (p->flags & PF_EXITING) {
-			if (p != current)
-				return ERR_PTR(-1UL);
-
 			chosen = p;
 			*ppoints = ULONG_MAX;
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
