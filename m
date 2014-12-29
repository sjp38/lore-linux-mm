Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id C79176B0038
	for <linux-mm@kvack.org>; Mon, 29 Dec 2014 07:32:32 -0500 (EST)
Received: by mail-wi0-f179.google.com with SMTP id ex7so21932739wid.6
        for <linux-mm@kvack.org>; Mon, 29 Dec 2014 04:32:32 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r15si58556472wij.73.2014.12.29.04.32.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 29 Dec 2014 04:32:31 -0800 (PST)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH 1/2] oom: Don't count on mm-less current process.
Date: Mon, 29 Dec 2014 13:32:06 +0100
Message-Id: <1419856327-673-2-git-send-email-mhocko@suse.cz>
In-Reply-To: <1419856327-673-1-git-send-email-mhocko@suse.cz>
References: <1419856327-673-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

out_of_memory() doesn't trigger the OOM killer if the current task is already
exiting or it has fatal signals pending, and gives the task access to memory
reserves instead. However, doing so is wrong if out_of_memory() is called by
an allocation (e.g. from exit_task_work()) after the current task has already
released its memory and cleared TIF_MEMDIE at exit_mm(). If we again set
TIF_MEMDIE to post-exit_mm() current task, the OOM killer will be blocked by
the task sitting in the final schedule() waiting for its parent to reap it.
It will trigger an OOM livelock if its parent is unable to reap it due to
doing an allocation and waiting for the OOM killer to kill it.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Acked-by: Michal Hocko <mhocko@suse.cz>
---
 mm/oom_kill.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index d503e9ce1c7b..f82dd13cca68 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -643,8 +643,12 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 	 * If current has a pending SIGKILL or is exiting, then automatically
 	 * select it.  The goal is to allow it to allocate so that it may
 	 * quickly exit and free its memory.
+	 *
+	 * But don't select if current has already released its mm and cleared
+	 * TIF_MEMDIE flag at exit_mm(), otherwise an OOM livelock may occur.
 	 */
-	if (fatal_signal_pending(current) || task_will_free_mem(current)) {
+	if (current->mm &&
+	    (fatal_signal_pending(current) || task_will_free_mem(current))) {
 		set_thread_flag(TIF_MEMDIE);
 		return;
 	}
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
