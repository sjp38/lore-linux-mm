Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 06F5C6B0169
	for <linux-mm@kvack.org>; Mon, 25 Jul 2011 20:12:48 -0400 (EDT)
Received: from kpbe13.cbf.corp.google.com (kpbe13.cbf.corp.google.com [172.25.105.77])
	by smtp-out.google.com with ESMTP id p6Q0Cghg018612
	for <linux-mm@kvack.org>; Mon, 25 Jul 2011 17:12:46 -0700
Received: from pzk5 (pzk5.prod.google.com [10.243.19.133])
	by kpbe13.cbf.corp.google.com with ESMTP id p6Q0CcwE020533
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 25 Jul 2011 17:12:41 -0700
Received: by pzk5 with SMTP id 5so11745428pzk.31
        for <linux-mm@kvack.org>; Mon, 25 Jul 2011 17:12:38 -0700 (PDT)
Date: Mon, 25 Jul 2011 17:12:37 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] oom: avoid killing kthreads if they assume the oom killed
 thread's mm
Message-ID: <alpine.DEB.2.00.1107251711460.26480@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org

After selecting a task to kill, the oom killer iterates all processes and
kills all other threads that share the same mm_struct in different thread
groups.  It would not otherwise be helpful to kill a thread if its memory
would not be subsequently freed.

A kernel thread, however, may assume a user thread's mm by using
use_mm().  This is only temporary and should not result in sending a
SIGKILL to that kthread.

This patch ensures that only user threads and not kthreads are sent a
SIGKILL if they share the same mm_struct as the oom killed task.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -433,7 +433,7 @@ static int oom_kill_task(struct task_struct *p, struct mem_cgroup *mem)
 	task_unlock(p);
 
 	/*
-	 * Kill all processes sharing p->mm in other thread groups, if any.
+	 * Kill all user processes sharing p->mm in other thread groups, if any.
 	 * They don't get access to memory reserves or a higher scheduler
 	 * priority, though, to avoid depletion of all memory or task
 	 * starvation.  This prevents mm->mmap_sem livelock when an oom killed
@@ -443,7 +443,8 @@ static int oom_kill_task(struct task_struct *p, struct mem_cgroup *mem)
 	 * signal.
 	 */
 	for_each_process(q)
-		if (q->mm == mm && !same_thread_group(q, p)) {
+		if (q->mm == mm && !same_thread_group(q, p) &&
+		    !(q->flags & PF_KTHREAD)) {
 			task_lock(q);	/* Protect ->comm from prctl() */
 			pr_err("Kill process %d (%s) sharing same memory\n",
 				task_pid_nr(q), q->comm);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
