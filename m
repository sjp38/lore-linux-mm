Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id F100E8D003B
	for <linux-mm@kvack.org>; Sat, 12 Mar 2011 20:15:33 -0500 (EST)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id p2D1FTsU019192
	for <linux-mm@kvack.org>; Sat, 12 Mar 2011 17:15:30 -0800
Received: from pwi4 (pwi4.prod.google.com [10.241.219.4])
	by wpaz9.hot.corp.google.com with ESMTP id p2D1FRAA017873
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 12 Mar 2011 17:15:28 -0800
Received: by pwi4 with SMTP id 4so1199925pwi.11
        for <linux-mm@kvack.org>; Sat, 12 Mar 2011 17:15:27 -0800 (PST)
Date: Sat, 12 Mar 2011 17:15:25 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm] oom: avoid deferring oom killer if exiting task is being
 traced
In-Reply-To: <alpine.DEB.2.00.1103121709230.10317@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1103121715030.10317@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1103011108400.28110@chino.kir.corp.google.com> <20110303100030.B936.A69D9226@jp.fujitsu.com> <20110308134233.GA26884@redhat.com> <alpine.DEB.2.00.1103081549530.27910@chino.kir.corp.google.com> <20110309151946.dea51cde.akpm@linux-foundation.org>
 <alpine.DEB.2.00.1103111142260.30699@chino.kir.corp.google.com> <20110312123413.GA18351@redhat.com> <alpine.DEB.2.00.1103121709230.10317@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Andrey Vagin <avagin@openvz.org>

The oom killer naturally defers killing anything if it finds an eligible
task that is already exiting and has yet to detach its ->mm.  This avoids
unnecessarily killing tasks when one is already in the exit path and may
free enough memory that the oom killer is no longer needed.  This is
detected by PF_EXITING since threads that have already detached its ->mm
are no longer considered at all.

The problem with always deferring when a thread is PF_EXITING, however,
is that it may never actually exit when being traced, specifically if
another task is tracing it with PTRACE_O_TRACEEXIT.  The oom killer does
not want to defer in this case since there is no guarantee that thread
will ever exit without intervention.

This patch will now only defer the oom killer when a thread is PF_EXITING
and no ptracer has stopped its progress in the exit path.  It also
ensures that a child is sacrificed for the chosen parent only if it has
a different ->mm as the comment implies: this ensures that the thread
group leader is always targeted appropriately.

Reported-by: Oleg Nesterov <oleg@redhat.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c |   40 +++++++++++++++++++++++++---------------
 1 files changed, 25 insertions(+), 15 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -31,6 +31,7 @@
 #include <linux/memcontrol.h>
 #include <linux/mempolicy.h>
 #include <linux/security.h>
+#include <linux/ptrace.h>
 
 int sysctl_panic_on_oom;
 int sysctl_oom_kill_allocating_task;
@@ -316,22 +317,29 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
 		if (test_tsk_thread_flag(p, TIF_MEMDIE))
 			return ERR_PTR(-1UL);
 
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
 		if (p->flags & PF_EXITING) {
-			if (p != current)
-				return ERR_PTR(-1UL);
-
-			chosen = p;
-			*ppoints = 1000;
+			/*
+			 * If p is the current task and is in the process of
+			 * releasing memory, we allow the "kill" to set
+			 * TIF_MEMDIE, which will allow it to gain access to
+			 * memory reserves.  Otherwise, it may stall forever.
+			 *
+			 * The loop isn't broken here, however, in case other
+			 * threads are found to have already been oom killed.
+			 */
+			if (p == current) {
+				chosen = p;
+				*ppoints = 1000;
+			} else {
+				/*
+				 * If this task is not being ptraced on exit,
+				 * then wait for it to finish before killing
+				 * some other task unnecessarily.
+				 */
+				if (!(task_ptrace(p->group_leader) &
+							PT_TRACE_EXIT))
+					return ERR_PTR(-1UL);
+			}
 		}
 
 		points = oom_badness(p, mem, nodemask, totalpages);
@@ -493,6 +501,8 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 		list_for_each_entry(child, &t->children, sibling) {
 			unsigned int child_points;
 
+			if (child->mm == p->mm)
+				continue;
 			/*
 			 * oom_badness() returns 0 if the thread is unkillable
 			 */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
