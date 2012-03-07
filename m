Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id AA4126B004A
	for <linux-mm@kvack.org>; Tue,  6 Mar 2012 21:25:07 -0500 (EST)
Received: by ghrr18 with SMTP id r18so3304190ghr.14
        for <linux-mm@kvack.org>; Tue, 06 Mar 2012 18:25:06 -0800 (PST)
Date: Tue, 6 Mar 2012 18:25:03 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, oom: allow exiting tasks to have access to memory
 reserves
Message-ID: <alpine.DEB.2.00.1203061824280.9015@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

The tasklist iteration only checks processes and avoids individual
threads so it is possible that threads that are currently exiting may not
appropriately being selected for oom kill.  This can lead to negative
results such as an innocent process being killed in the interim or, in
the worst case, the machine panicking because there is nothing else to kill.

We automatically select PF_EXITING threads during the tasklist iteration,
so this saves time and prevents threads that haven't yet exited (although
their parent has been oom killed) from getting missed.

Note that by doing this we aren't actually oom killing an exiting thread
but rather giving it full access to memory reserves so it may quickly
exit and free its memory.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c |   16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -568,11 +568,11 @@ void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask)
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
@@ -723,11 +723,11 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
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
