Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id C01336B0032
	for <linux-mm@kvack.org>; Mon,  9 Sep 2013 11:31:07 -0400 (EDT)
Received: by mail-la0-f48.google.com with SMTP id er20so5001677lab.21
        for <linux-mm@kvack.org>; Mon, 09 Sep 2013 08:31:05 -0700 (PDT)
From: Sergey Dyasly <dserrg@gmail.com>
Subject: [PATCH] OOM killer: wait for tasks with pending SIGKILL to exit
Date: Mon,  9 Sep 2013 19:30:24 +0400
Message-Id: <1378740624-2456-1-git-send-email-dserrg@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.cz>, Rusty Russell <rusty@rustcorp.com.au>, Sha Zhengju <handai.szj@taobao.com>, Oleg Nesterov <oleg@redhat.com>, Sergey Dyasly <dserrg@gmail.com>

If OOM killer finds a task which is about to exit or is already doing so,
there is no need to kill anyone. It should just wait until task dies.

Add missing fatal_signal_pending() check and allow selected task to use memory
reserves in order to exit quickly.

Also remove redundant PF_EXITING check after victim has been selected.

Signed-off-by: Sergey Dyasly <dserrg@gmail.com>
---
 mm/oom_kill.c | 17 +++++------------
 1 file changed, 5 insertions(+), 12 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 98e75f2..ef83b81 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -275,13 +275,16 @@ enum oom_scan_t oom_scan_process_thread(struct task_struct *task,
 	if (oom_task_origin(task))
 		return OOM_SCAN_SELECT;
 
-	if (task->flags & PF_EXITING && !force_kill) {
+	if ((task->flags & PF_EXITING || fatal_signal_pending(task)) &&
+	    !force_kill) {
 		/*
 		 * If this task is not being ptraced on exit, then wait for it
 		 * to finish before killing some other task unnecessarily.
 		 */
-		if (!(task->group_leader->ptrace & PT_TRACE_EXIT))
+		if (!(task->group_leader->ptrace & PT_TRACE_EXIT)) {
+			set_tsk_thread_flag(task, TIF_MEMDIE);
 			return OOM_SCAN_ABORT;
+		}
 	}
 	return OOM_SCAN_OK;
 }
@@ -412,16 +415,6 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
 					      DEFAULT_RATELIMIT_BURST);
 
-	/*
-	 * If the task is already exiting, don't alarm the sysadmin or kill
-	 * its children or threads, just set TIF_MEMDIE so it can die quickly
-	 */
-	if (p->flags & PF_EXITING) {
-		set_tsk_thread_flag(p, TIF_MEMDIE);
-		put_task_struct(p);
-		return;
-	}
-
 	if (__ratelimit(&oom_rs))
 		dump_header(p, gfp_mask, order, memcg, nodemask);
 
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
