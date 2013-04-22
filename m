Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id F282F6B0002
	for <linux-mm@kvack.org>; Mon, 22 Apr 2013 11:07:52 -0400 (EDT)
Received: by mail-la0-f50.google.com with SMTP id el20so5452720lab.23
        for <linux-mm@kvack.org>; Mon, 22 Apr 2013 08:07:51 -0700 (PDT)
From: Sergey Dyasly <dserrg@gmail.com>
Subject: [PATCH] oom: add pending SIGKILL check for chosen victim
Date: Mon, 22 Apr 2013 19:06:24 +0400
Message-Id: <1366643184-3627-1-git-send-email-dserrg@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Sha Zhengju <handai.szj@taobao.com>, Sergey Dyasly <dserrg@gmail.com>

Currently, fatal_signal_pending() check is issued only for task that invoked
oom killer. Add the same check for oom killer's chosen victim.

This eliminates regression with killing multithreaded processes which was
introduced by commit 6b0c81b3be114a93f79bd4c5639ade5107d77c21
(mm, oom: reduce dependency on tasklist_lock). When one of threads
was oom-killed, other threads could also become victims of oom killer, which
can cause an infinite loop.

There is a race with task->thread_group RCU protected list deletion/iteration:
now only a reference to a chosen thread of dying threadgroup is held, so when
the thread doesn't have PF_EXITING flag yet and dump_header() is called
to print info, it already has SIGKILL and can call do_exit(), which removes
the thread from the thread_group list. After printing info, oom killer
is doing while_each_thread() on this thread and it still has next reference
to some other thread, but no other thread has next reference to this one.
This causes the infinite loop with tasklist_lock read held.

When SIGKILL is sent to a task, it's also sent to all tasks in the same
threadgroup. This information can be used to prevent triggering further
oom killers for this threadgroup and avoid the infinite loop.

Signed-off-by: Sergey Dyasly <dserrg@gmail.com>
---
 mm/oom_kill.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 79e451a..5c42dd3 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -413,10 +413,11 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 					      DEFAULT_RATELIMIT_BURST);
 
 	/*
-	 * If the task is already exiting, don't alarm the sysadmin or kill
-	 * its children or threads, just set TIF_MEMDIE so it can die quickly
+	 * If the task already has a pending SIGKILL or is exiting, don't alarm
+	 * the sysadmin or kill its children or threads, just set TIF_MEMDIE
+	 * so it can die quickly
 	 */
-	if (p->flags & PF_EXITING) {
+	if (fatal_signal_pending(p) || p->flags & PF_EXITING) {
 		set_tsk_thread_flag(p, TIF_MEMDIE);
 		put_task_struct(p);
 		return;
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
