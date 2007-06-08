Received: from Relay2.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id 6E3D2218CA
	for <linux-mm@kvack.org>; Fri,  8 Jun 2007 22:07:17 +0200 (CEST)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 08 of 16] don't depend on PF_EXITING tasks to go away
Message-Id: <60059913ab07906fceda.1181332986@v2.random>
In-Reply-To: <patchbomb.1181332978@v2.random>
Date: Fri, 08 Jun 2007 22:03:06 +0200
From: Andrea Arcangeli <andrea@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

# HG changeset patch
# User Andrea Arcangeli <andrea@suse.de>
# Date 1181332961 -7200
# Node ID 60059913ab07906fceda14ffa72f2c77ef282fca
# Parent  aafcc5c9057f11d88c43b823c241f14a5ebdd638
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
@@ -233,27 +233,13 @@ static struct task_struct *select_bad_pr
 		 * Note: this may have a chance of deadlock if it gets
 		 * blocked waiting for another task which itself is waiting
 		 * for memory. Is there a better alternative?
+		 *
+		 * Better not to skip PF_EXITING tasks, since they
+		 * don't have access to the PF_MEMALLOC pool until
+		 * we select them here first.
 		 */
 		if (test_tsk_thread_flag(p, TIF_MEMDIE))
 			return ERR_PTR(-1UL);
-
-		/*
-		 * This is in the process of releasing memory so wait for it
-		 * to finish before killing some other task by mistake.
-		 *
-		 * However, if p is the current task, we allow the 'kill' to
-		 * go ahead if it is exiting: this will simply set TIF_MEMDIE,
-		 * which will allow it to gain access to memory reserves in
-		 * the process of exiting and releasing its resources.
-		 * Otherwise we could get an easy OOM deadlock.
-		 */
-		if (p->flags & PF_EXITING) {
-			if (p != current)
-				return ERR_PTR(-1UL);
-
-			chosen = p;
-			*ppoints = ULONG_MAX;
-		}
 
 		if (p->oomkilladj == OOM_DISABLE)
 			continue;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
