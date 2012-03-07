Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 510D56B004A
	for <linux-mm@kvack.org>; Wed,  7 Mar 2012 02:22:39 -0500 (EST)
Received: by iajr24 with SMTP id r24so10725002iaj.14
        for <linux-mm@kvack.org>; Tue, 06 Mar 2012 23:22:38 -0800 (PST)
Date: Tue, 6 Mar 2012 23:22:36 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch v2] mm, oom: allow exiting tasks to have access to memory
 reserves
In-Reply-To: <alpine.DEB.2.00.1203062316430.4158@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1203062321590.4158@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1203061824280.9015@chino.kir.corp.google.com> <4F570286.8020704@gmail.com> <alpine.DEB.2.00.1203062316430.4158@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

The tasklist iteration only checks processes and avoids individual
threads so it is possible that threads that are currently exiting may not
appropriately being selected for oom kill.  This can lead to negative
results such as an innocent process being killed in the interim or, in
the worst case, the machine panicking because there is nothing else to kill.

We automatically select PF_EXITING threads during the tasklist iteration in
select_bad_process(), so this saves time and prevents threads that haven't
yet exited (although their parent has been oom killed) from getting missed.
It also allows that code to be removed from select_bad_process().

Note that by doing this we aren't actually oom killing an exiting thread
but rather giving it full access to memory reserves so it may quickly
exit and free its memory.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c |   40 +++++++++++++---------------------------
 1 file changed, 13 insertions(+), 27 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -342,26 +342,12 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
 
 		if (p->flags & PF_EXITING) {
 			/*
-			 * If p is the current task and is in the process of
-			 * releasing memory, we allow the "kill" to set
-			 * TIF_MEMDIE, which will allow it to gain access to
-			 * memory reserves.  Otherwise, it may stall forever.
-			 *
-			 * The loop isn't broken here, however, in case other
-			 * threads are found to have already been oom killed.
+			 * If this task is not being ptraced on exit, then wait
+			 * for it to finish before killing some other task
+			 * unnecessarily.
 			 */
-			if (p == current) {
-				chosen = p;
-				*ppoints = 1000;
-			} else {
-				/*
-				 * If this task is not being ptraced on exit,
-				 * then wait for it to finish before killing
-				 * some other task unnecessarily.
-				 */
-				if (!(p->group_leader->ptrace & PT_TRACE_EXIT))
-					return ERR_PTR(-1UL);
-			}
+			if (!(p->group_leader->ptrace & PT_TRACE_EXIT))
+				return ERR_PTR(-1UL);
 		}
 
 		points = oom_badness(p, memcg, nodemask, totalpages);
@@ -568,11 +554,11 @@ void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask)
 	struct task_struct *p;
 
 	/*
-	 * If current has a pending SIGKILL, then automatically select it.  The
-	 * goal is to allow it to allocate so that it may quickly exit and free
-	 * its memory.
+	 * If current is exiting (or going to exit), then automatically select
+	 * it.  The goal is to allow it to allocate so that it may quickly exit
+	 * and free its memory.
 	 */
-	if (fatal_signal_pending(current)) {
+	if (fatal_signal_pending(current) || (current->flags & PF_EXITING)) {
 		set_thread_flag(TIF_MEMDIE);
 		return;
 	}
@@ -723,11 +709,11 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 		return;
 
 	/*
-	 * If current has a pending SIGKILL, then automatically select it.  The
-	 * goal is to allow it to allocate so that it may quickly exit and free
-	 * its memory.
+	 * If current is exiting (or going to exit), then automatically select
+	 * it.  The goal is to allow it to allocate so that it may quickly exit
+	 * and free its memory.
 	 */
-	if (fatal_signal_pending(current)) {
+	if (fatal_signal_pending(current) || (current->flags & PF_EXITING)) {
 		set_thread_flag(TIF_MEMDIE);
 		return;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
