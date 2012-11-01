Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id A94286B0062
	for <linux-mm@kvack.org>; Thu,  1 Nov 2012 00:49:01 -0400 (EDT)
Received: by mail-da0-f41.google.com with SMTP id i14so1072854dad.14
        for <linux-mm@kvack.org>; Wed, 31 Oct 2012 21:49:01 -0700 (PDT)
Date: Wed, 31 Oct 2012 21:48:57 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: zram OOM behavior
In-Reply-To: <20121101024316.GB24883@bbox>
Message-ID: <alpine.DEB.2.00.1210312140090.17607@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1210222257580.22198@chino.kir.corp.google.com> <CAA25o9ScWUsRr2ziqiEt9U9UvuMuYim+tNpPCyN88Qr53uGhVQ@mail.gmail.com> <alpine.DEB.2.00.1210291158510.10845@chino.kir.corp.google.com> <CAA25o9Rk_C=jaHJwWQ8TJL0NF5_Xv2umwxirtdugF6w3rHruXg@mail.gmail.com>
 <20121030001809.GL15767@bbox> <CAA25o9R0zgW74NRGyZZHy4cFbfuVEmHWVC=4O7SuUjywN+Uvpw@mail.gmail.com> <alpine.DEB.2.00.1210292239290.13203@chino.kir.corp.google.com> <CAA25o9Tp5J6-9JzwEfcZJ4dHQCEKV9_GYO0ZQ05Ttc3QWP=5_Q@mail.gmail.com> <20121031005738.GM15767@bbox>
 <alpine.DEB.2.00.1210311151341.8809@chino.kir.corp.google.com> <20121101024316.GB24883@bbox>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>
Cc: Luigi Semenzato <semenzato@google.com>, linux-mm@kvack.org, Dan Magenheimer <dan.magenheimer@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Sonny Rao <sonnyrao@google.com>

On Thu, 1 Nov 2012, Minchan Kim wrote:

> It's not true any more.
> 3.6 includes following code in try_to_free_pages
> 
>         /*   
>          * Do not enter reclaim if fatal signal is pending. 1 is returned so
>          * that the page allocator does not consider triggering OOM
>          */
>         if (fatal_signal_pending(current))
>                 return 1;
> 
> So the hunged task never go to the OOM path and could be looping forever.
> 

Ah, interesting.  This is from commit 5515061d22f0 ("mm: throttle direct 
reclaimers if PF_MEMALLOC reserves are low and swap is backed by network 
storage").  Thanks for adding Mel to the cc.

The oom killer specifically has logic for this condition: when calling 
out_of_memory() the first thing it does is

	if (fatal_signal_pending(current))
		set_thread_flag(TIF_MEMDIE);

to allow it access to memory reserves so that it may exit if it's having 
trouble.  But that ends up never happening because of the above code that 
Minchan has identified.

So we either need to do set_thread_flag(TIF_MEMDIE) in try_to_free_pages() 
as well or revert that early return entirely; there's no justification 
given for it in the comment nor in the commit log.  I'd rather remove it 
and allow the oom killer to trigger and grant access to memory reserves 
itself if necessary.

Mel, how does commit 5515061d22f0 deal with threads looping forever if 
they need memory in the exit path since the oom killer never gets called?

That aside, it doesn't seem like this is the issue that Luigi is reporting 
since his patch that avoids deferring the oom killer presumably fixes the 
issue for him.  So it turns out the oom killer must be getting called.

Luigi, can you try this instead?  It applies to the latest git but should 
be easily modified to apply to any 3.x kernel you're running.
---
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
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
