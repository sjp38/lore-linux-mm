Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 125E78D0039
	for <linux-mm@kvack.org>; Tue,  1 Mar 2011 14:10:06 -0500 (EST)
Received: from kpbe12.cbf.corp.google.com (kpbe12.cbf.corp.google.com [172.25.105.76])
	by smtp-out.google.com with ESMTP id p21JA1xt013164
	for <linux-mm@kvack.org>; Tue, 1 Mar 2011 11:10:01 -0800
Received: from pwj8 (pwj8.prod.google.com [10.241.219.72])
	by kpbe12.cbf.corp.google.com with ESMTP id p21J9YGI009055
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 1 Mar 2011 11:09:58 -0800
Received: by pwj8 with SMTP id 8so1255553pwj.41
        for <linux-mm@kvack.org>; Tue, 01 Mar 2011 11:09:34 -0800 (PST)
Date: Tue, 1 Mar 2011 11:09:30 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch] oom: prevent unnecessary oom kills or kernel panics
Message-ID: <alpine.DEB.2.00.1103011108400.28110@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org

This patch revents unnecessary oom kills or kernel panics by reverting
two commits:

	495789a5 (oom: make oom_score to per-process value)
	cef1d352 (oom: multi threaded process coredump don't make deadlock)

First, 495789a5 (oom: make oom_score to per-process value) ignores the
fact that all threads in a thread group do not necessarily exit at the
same time.

It is imperative that select_bad_process() detect threads that are in the
exit path, specifically those with PF_EXITING set, to prevent needlessly
killing additional tasks.  If a process is oom killed and the thread
group leader exits, select_bad_process() cannot detect the other threads
that are PF_EXITING by iterating over only processes.  Thus, it currently
chooses another task unnecessarily for oom kill or panics the machine
when nothing else is eligible.

By iterating over threads instead, it is possible to detect threads that
are exiting and nominate them for oom kill so they get access to memory
reserves.

Second, cef1d352 (oom: multi threaded process coredump don't make
deadlock) erroneously avoids making the oom killer a no-op when an
eligible thread other than current isfound to be exiting.  We want to
detect this situation so that we may allow that exiting thread time to
exit and free its memory; if it is able to exit on its own, that should
free memory so current is no loner oom.  If it is not able to exit on its
own, the oom killer will nominate it for oom kill which, in this case,
only means it will get access to memory reserves.

Without this change, it is easy for the oom killer to unnecessarily
target tasks when all threads of a victim don't exit before the thread
group leader or, in the worst case, panic the machine.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -292,11 +292,11 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
 		unsigned long totalpages, struct mem_cgroup *mem,
 		const nodemask_t *nodemask)
 {
-	struct task_struct *p;
+	struct task_struct *g, *p;
 	struct task_struct *chosen = NULL;
 	*ppoints = 0;
 
-	for_each_process(p) {
+	do_each_thread(g, p) {
 		unsigned int points;
 
 		if (oom_unkillable_task(p, mem, nodemask))
@@ -324,7 +324,7 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
 		 * the process of exiting and releasing its resources.
 		 * Otherwise we could get an easy OOM deadlock.
 		 */
-		if (thread_group_empty(p) && (p->flags & PF_EXITING) && p->mm) {
+		if ((p->flags & PF_EXITING) && p->mm) {
 			if (p != current)
 				return ERR_PTR(-1UL);
 
@@ -337,7 +337,7 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
 			chosen = p;
 			*ppoints = points;
 		}
-	}
+	} while_each_thread(g, p);
 
 	return chosen;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
