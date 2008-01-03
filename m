Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 11 of 11] not-wait-memdie
Message-Id: <504e981185254a12282d.1199326157@v2.random>
In-Reply-To: <patchbomb.1199326146@v2.random>
Date: Thu, 03 Jan 2008 03:09:17 +0100
From: Andrea Arcangeli <andrea@cpushare.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

# HG changeset patch
# User Andrea Arcangeli <andrea@suse.de>
# Date 1199325619 -3600
# Node ID 504e981185254a12282df2add7c3c1131eb810dc
# Parent  30fd9dd17ca34a24f0666be2e5e52d3369b0090b
not-wait-memdie

Don't wait tif-memdie tasks forever because they may be stuck in some kernel
lock owned by some task that requires memory to exit the critical section.

Signed-off-by: Andrea Arcangeli <andrea@suse.de>

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -215,21 +215,14 @@ static struct task_struct *select_bad_pr
 		if (is_global_init(p))
 			continue;
 
-		/*
-		 * This task already has access to memory reserves and is
-		 * being killed. Don't allow any other task access to the
-		 * memory reserve.
-		 *
-		 * Note: this may have a chance of deadlock if it gets
-		 * blocked waiting for another task which itself is waiting
-		 * for memory. Is there a better alternative?
-		 *
-		 * Better not to skip PF_EXITING tasks, since they
-		 * don't have access to the PF_MEMALLOC pool until
-		 * we select them here first.
-		 */
-		if (test_tsk_thread_flag(p, TIF_MEMDIE))
-			return ERR_PTR(-1UL);
+		if (unlikely(test_tsk_thread_flag(p, TIF_MEMDIE))) {
+			/*
+			 * Hopefully we already waited long enough,
+			 * or exit_mm already run, but we must try to kill
+			 * another task to avoid deadlocking.
+			 */
+			continue;
+		}
 
 		if (p->oomkilladj == OOM_DISABLE)
 			continue;
@@ -478,12 +471,8 @@ retry:
 		 * issues we may have.
 		 */
 		p = select_bad_process(&points);
-
-		if (PTR_ERR(p) == -1UL)
-			goto out;
-
 		/* Found nothing?!?! Either we hang forever, or we panic. */
-		if (!p) {
+		if (unlikely(!p)) {
 			read_unlock(&tasklist_lock);
 			panic("Out of memory and no killable processes...\n");
 		}
@@ -495,7 +484,6 @@ retry:
 		break;
 	}
 
-out:
 	read_unlock(&tasklist_lock);
 
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
