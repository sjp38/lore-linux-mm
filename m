Received: from Relay1.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id AF31120F9E
	for <linux-mm@kvack.org>; Fri,  8 Jun 2007 22:06:54 +0200 (CEST)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 05 of 16] avoid selecting already killed tasks
Message-Id: <2ebc46595ead0f1790c6.1181332983@v2.random>
In-Reply-To: <patchbomb.1181332978@v2.random>
Date: Fri, 08 Jun 2007 22:03:03 +0200
From: Andrea Arcangeli <andrea@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

# HG changeset patch
# User Andrea Arcangeli <andrea@suse.de>
# Date 1181332960 -7200
# Node ID 2ebc46595ead0f1790c6ec1d0302dd60ffbb1978
# Parent  baa866fedc79cb333b90004da2730715c145f1d5
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
@@ -366,6 +366,12 @@ static int oom_kill_process(struct task_
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
