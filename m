Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 04 of 11] avoid selecting already killed tasks
Message-Id: <4cf8805b5695a8a3fb7c.1199326150@v2.random>
In-Reply-To: <patchbomb.1199326146@v2.random>
Date: Thu, 03 Jan 2008 03:09:10 +0100
From: Andrea Arcangeli <andrea@cpushare.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

# HG changeset patch
# User Andrea Arcangeli <andrea@suse.de>
# Date 1199324664 -3600
# Node ID 4cf8805b5695a8a3fb7c1d11fa4d41d0b2650cb0
# Parent  71f1d848763c80f336f7f9f23dcbe8f7e43c82aa
avoid selecting already killed tasks

If the killed task doesn't go away because it's waiting on some other
task who needs to allocate memory, to release the i_sem or some other
lock, we must fallback to killing some other task in order to kill the
original selected and already oomkilled task, but the logic that kills
the childs first, would deadlock, if the already oom-killed task was
actually the first child of the newly oom-killed task.

Signed-off-by: Andrea Arcangeli <andrea@suse.de>

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -363,6 +363,12 @@ static int oom_kill_process(struct task_
 	list_for_each_entry(c, &p->children, sibling) {
 		if (c->mm == p->mm)
 			continue;
+		/*
+		 * We cannot select tasks with TIF_MEMDIE already set
+		 * or we'll hard deadlock.
+		 */
+		if (unlikely(test_tsk_thread_flag(c, TIF_MEMDIE)))
+			continue;
 		if (!oom_kill_task(c))
 			return 0;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
