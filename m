Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id B51A18D0008
	for <linux-mm@kvack.org>; Thu,  1 Nov 2012 17:58:20 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa10so2230814pad.14
        for <linux-mm@kvack.org>; Thu, 01 Nov 2012 14:58:20 -0700 (PDT)
Date: Thu, 1 Nov 2012 14:58:18 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, oom: allow exiting threads to have access to memory
 reserves
In-Reply-To: <alpine.DEB.2.00.1211011448490.19373@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1211011451480.19373@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1210222257580.22198@chino.kir.corp.google.com> <CAA25o9ScWUsRr2ziqiEt9U9UvuMuYim+tNpPCyN88Qr53uGhVQ@mail.gmail.com> <alpine.DEB.2.00.1210291158510.10845@chino.kir.corp.google.com> <CAA25o9Rk_C=jaHJwWQ8TJL0NF5_Xv2umwxirtdugF6w3rHruXg@mail.gmail.com>
 <20121030001809.GL15767@bbox> <CAA25o9R0zgW74NRGyZZHy4cFbfuVEmHWVC=4O7SuUjywN+Uvpw@mail.gmail.com> <alpine.DEB.2.00.1210292239290.13203@chino.kir.corp.google.com> <CAA25o9Tp5J6-9JzwEfcZJ4dHQCEKV9_GYO0ZQ05Ttc3QWP=5_Q@mail.gmail.com> <20121031005738.GM15767@bbox>
 <alpine.DEB.2.00.1210311151341.8809@chino.kir.corp.google.com> <20121101024316.GB24883@bbox> <alpine.DEB.2.00.1210312140090.17607@chino.kir.corp.google.com> <CAA25o9SdQ7e5w8=W0faz82nZ7_3N7xbbExKQe0-HsU87hs2MPA@mail.gmail.com>
 <alpine.DEB.2.00.1211011448490.19373@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Luigi Semenzato <semenzato@google.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Dan Magenheimer <dan.magenheimer@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Sonny Rao <sonnyrao@google.com>

Exiting threads, those with PF_EXITING set, can pagefault and require 
memory before they can make forward progress.  This happens, for instance, 
when a process must fault task->robust_list, a userspace structure, before 
detaching its memory.

These threads also aren't guaranteed to get access to memory reserves 
unless oom killed or killed from userspace.  The oom killer won't grant 
memory reserves if other threads are also exiting other than current and 
stalling at the same point.  This prevents needlessly killing processes 
when others are already exiting.

Instead of special casing all the possible sitations between PF_EXITING 
getting set and a thread detaching its mm where it may allocate memory, 
which probably wouldn't get updated when a change is made to the exit 
path, the solution is to give all exiting threads access to memory 
reserves if they call the oom killer.  This allows them to quickly 
allocate, detach its mm, and free the memory it represents.

Acked-by: Minchan Kim <minchan@kernel.org>
Tested-by: Luigi Semenzato <semenzato@google.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 This is old code and has only recently been reported as causing an issue, 
 so deferring to 3.8 seems appropriate.

 mm/oom_kill.c |   31 +++++++++----------------------
 1 file changed, 9 insertions(+), 22 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 79e0f3e..7e9e911 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -310,26 +310,13 @@ enum oom_scan_t oom_scan_process_thread(struct task_struct *task,
 	if (!task->mm)
 		return OOM_SCAN_CONTINUE;
 
-	if (task->flags & PF_EXITING) {
+	if (task->flags & PF_EXITING && !force_kill) {
 		/*
-		 * If task is current and is in the process of releasing memory,
-		 * allow the "kill" to set TIF_MEMDIE, which will allow it to
-		 * access memory reserves.  Otherwise, it may stall forever.
-		 *
-		 * The iteration isn't broken here, however, in case other
-		 * threads are found to have already been oom killed.
+		 * If this task is not being ptraced on exit, then wait for it
+		 * to finish before killing some other task unnecessarily.
 		 */
-		if (task == current)
-			return OOM_SCAN_SELECT;
-		else if (!force_kill) {
-			/*
-			 * If this task is not being ptraced on exit, then wait
-			 * for it to finish before killing some other task
-			 * unnecessarily.
-			 */
-			if (!(task->group_leader->ptrace & PT_TRACE_EXIT))
-				return OOM_SCAN_ABORT;
-		}
+		if (!(task->group_leader->ptrace & PT_TRACE_EXIT))
+			return OOM_SCAN_ABORT;
 	}
 	return OOM_SCAN_OK;
 }
@@ -706,11 +693,11 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 		return;
 
 	/*
-	 * If current has a pending SIGKILL, then automatically select it.  The
-	 * goal is to allow it to allocate so that it may quickly exit and free
-	 * its memory.
+	 * If current has a pending SIGKILL or is exiting, then automatically
+	 * select it.  The goal is to allow it to allocate so that it may
+	 * quickly exit and free its memory.
 	 */
-	if (fatal_signal_pending(current)) {
+	if (fatal_signal_pending(current) || current->flags & PF_EXITING) {
 		set_thread_flag(TIF_MEMDIE);
 		return;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
