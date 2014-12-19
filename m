Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id D7E696B006E
	for <linux-mm@kvack.org>; Fri, 19 Dec 2014 07:07:59 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id rd3so1098562pab.14
        for <linux-mm@kvack.org>; Fri, 19 Dec 2014 04:07:59 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id bi8si13928540pdb.223.2014.12.19.04.07.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 19 Dec 2014 04:07:58 -0800 (PST)
Subject: Re: [RFC PATCH] oom: Don't count on mm-less current process.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20141216124714.GF22914@dhcp22.suse.cz>
	<201412172054.CFJ78687.HFFLtVMOOJSQFO@I-love.SAKURA.ne.jp>
	<20141217130807.GB24704@dhcp22.suse.cz>
	<201412182111.JCE48417.QFOJSFtMOHFLOV@I-love.SAKURA.ne.jp>
	<20141218153341.GB832@dhcp22.suse.cz>
In-Reply-To: <20141218153341.GB832@dhcp22.suse.cz>
Message-Id: <201412192107.IGJ09885.OFHSMJtLFFOVQO@I-love.SAKURA.ne.jp>
Date: Fri, 19 Dec 2014 21:07:53 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com

Michal Hocko wrote:
> On Thu 18-12-14 21:11:26, Tetsuo Handa wrote:
> > > > But I think the condition whether TIF_MEMDIE
> > > > flag should be set or not should be same between the memcg OOM killer and
> > > > the global OOM killer, for a thread inside some memcg with TIF_MEMDIE flag
> > > > can prevent the global OOM killer from killing other threads when the memcg
> > > > OOM killer and the global OOM killer run concurrently (the worst corner case).
> > > > When a malicious user runs a memory consumer program which triggers memcg OOM
> > > > killer deadlock inside some memcg, it will result in the global OOM killer
> > > > deadlock when the global OOM killer is triggered by other user's tasks.
> > >
> > > Hope that the above exaplains your concerns here.
> > >
> >
> > Thread1 in memcg1 asks for memory, and thread1 gets requested amount of
> > memory without triggering the global OOM killer, and requested amount of
> > memory is charged to memcg1, and the memcg OOM killer is triggered.
> > While the memcg OOM killer is searching for a victim from threads in
> > memcg1, thread2 in memcg2 asks for the memory. Thread2 fails to get
> > requested amount of memory without triggering the global OOM killer.
> > Now the global OOM killer starts searching for a victim from all threads
> > whereas the memcg OOM killer chooses thread1 in memcg1 and sets TIF_MEMDIE
> > flag on thread1 in memcg1. Then, the global OOM killer finds that thread1
> > in memcg1 already has TIF_MEMDIE flag set, and waits for thread1 in memcg1
> > to terminate than chooses another victim from all threads. However, when
> > thread1 in memcg1 cannot be terminated immediately for some reason, thread2
> > in memcg2 is blocked by thread1 in memcg1.
>
> Sigh... T1 triggers memcg OOM killer _only_ from the page fault path and so it
> will get to signal processing right away and eventually gets to exit_mm
> where it releases its memory. If that doesn't suffice to release enough
> memory then we are back to the original problem. So I do not think memcg
> adds anything new to the problem.
>
The memcg OOM killer is triggered upon page fault than memory charge, I see.
But the memcg OOM killer is not relevant to my concern. It's a matter of
which OOM killer sets TIF_MEMDIE flag.

> > [...]
> > > I think focusing on only mm-less case makes no sense, for with-mm case
> > ruins efforts made for mm-less case.
>
> No. It is quite opposite. Excluding mm less current from PF_EXITING
> resp. fatal_signal_pending heuristics makes perfect sense from the OOM
> killer POV. The reasons are described in the changelog.
>

OK. Below is an updated patch.
----------------------------------------
>From 3c68c66a72f0dbfc66f9799a00fbaa1f0217befb Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Fri, 19 Dec 2014 20:49:06 +0900
Subject: [PATCH v2] oom: Don't count on mm-less current process.

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
---
 mm/oom_kill.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 481d550..e87391f 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -649,8 +649,12 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 	 * If current has a pending SIGKILL or is exiting, then automatically
 	 * select it.  The goal is to allow it to allocate so that it may
 	 * quickly exit and free its memory.
+	 *
+	 * But don't select if current has already released its mm and cleared
+	 * TIF_MEMDIE flag at exit_mm(), otherwise an OOM livelock may occur.
 	 */
-	if (fatal_signal_pending(current) || task_will_free_mem(current)) {
+	if ((fatal_signal_pending(current) || task_will_free_mem(current)) &&
+	    current->mm) {
 		set_thread_flag(TIF_MEMDIE);
 		return;
 	}
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
