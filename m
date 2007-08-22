Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 05 of 24] avoid selecting already killed tasks
Message-Id: <de62eb332b1dfee7e493.1187786932@v2.random>
In-Reply-To: <patchbomb.1187786927@v2.random>
Date: Wed, 22 Aug 2007 14:48:52 +0200
From: Andrea Arcangeli <andrea@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

# HG changeset patch
# User Andrea Arcangeli <andrea@suse.de>
# Date 1187778125 -7200
# Node ID de62eb332b1dfee7e493043b20e560283ef42f67
# Parent  871b7a4fd566de0811207628b74abea0a73341f6
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
@@ -367,6 +367,12 @@ static int oom_kill_process(struct task_
 		c = list_entry(tsk, struct task_struct, sibling);
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
