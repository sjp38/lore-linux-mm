Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id A41D36B0253
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 11:40:38 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id yy13so13905872pab.3
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 08:40:38 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 89si2946668pfp.25.2016.02.17.08.40.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 17 Feb 2016 08:40:37 -0800 (PST)
Subject: Re: [PATCH 1/6] mm,oom: exclude TIF_MEMDIE processes from candidates.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201602171928.GDE00540.SLJMOFFQOHtFVO@I-love.SAKURA.ne.jp>
	<201602171929.IFG12927.OVFJOQHOSMtFFL@I-love.SAKURA.ne.jp>
	<20160217124100.GE29196@dhcp22.suse.cz>
In-Reply-To: <20160217124100.GE29196@dhcp22.suse.cz>
Message-Id: <201602180140.IHH21322.OSJFHOMtFFOQVL@I-love.SAKURA.ne.jp>
Date: Thu, 18 Feb 2016 01:40:22 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, rientjes@google.com, mgorman@suse.de, oleg@redhat.com, torvalds@linux-foundation.org, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Wed 17-02-16 19:29:33, Tetsuo Handa wrote:
> > >From 142b08258e4c60834602e9b0a734564208bc6397 Mon Sep 17 00:00:00 2001
> > From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > Date: Wed, 17 Feb 2016 16:29:29 +0900
> > Subject: [PATCH 1/6] mm,oom: exclude TIF_MEMDIE processes from candidates.
> > 
> > The OOM reaper kernel thread can reclaim OOM victim's memory before
> > the victim releases it.
> 
> If this is aimed to be preparatory work, which I am not convinced about
> to be honest, then referring to oom reaper is confusing and misleading.
> 

OK. I removed it.

> > But it is possible that a TIF_MEMDIE thread
> > gets stuck at down_read(&mm->mmap_sem) in exit_mm() called from
> > do_exit() due to one of !TIF_MEMDIE threads doing a GFP_KERNEL
> > allocation between down_write(&mm->mmap_sem) and up_write(&mm->mmap_sem)
> > (e.g. mmap()). In that case, we need to use SysRq-f (manual invocation
> > of the OOM killer) because down_read_trylock(&mm->mmap_sem) by the OOM
> > reaper will not succeed.
> 
> But all the tasks sharing the mm with the oom victim will have
> fatal_signal_pending and so they will get access to memory reserves and
> that should help them to finish the allocation request. So the above
> text is misleading.
> 

Not true like explained in "[PATCH v2] mm,oom: don't abort on exiting
processes when selecting a victim.".

> If the down_read is blocked because down_write is blocked then a better
> solution is to make down_write_killable which has been already proposed.
> 
> > Also, there are other situations where the OOM
> > reaper cannot reap the victim's memory (e.g. CONFIG_MMU=n,
> 
> there was no clear evidence that this is a problem on !MMU
> configurations.
> 
> > victim's memory is shared with OOM-unkillable processes) which will
> > require manual SysRq-f for making progress.
> 
> Sharing mm with a task which is hidden from the OOM killer is a clear
> misconfiguration IMO.
>  

Misconfiguration and/or insane stress is no excuse to leave bugs unfixed.

> > However, it is possible that the OOM killer chooses the same OOM victim
> > forever which already has TIF_MEMDIE.
> 
> This can happen only for the sysrq+f case AFAICS. Regular OOM killer
> will stop scanning after it encounters the first TIF_MEMDIE task.
> If you want to handle the sysrq+f case then it should be imho explicit.
> Something I've tries here as patch 1/2
> http://lkml.kernel.org/r/1452632425-20191-1-git-send-email-mhocko@kernel.org
> which has been nacked. Maybe you can try again without
> fatal_signal_pending resp. task_will_free_mem checks which were
> controversial back then. Hiding this into find_lock_non_victim_task_mm
> is just making the code more obscure and harder to read.
> 
> > This is effectively disabling
> > SysRq-f. This patch excludes processes which has a TIF_MEMDIE thread
> >  from OOM victim candidates.
> > 
> > Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> 
> In short I dislike this patch. It makes the code harder to read and the
> same can be solved more straightforward:

Your patch is not doing the same thing. test_tsk_thread_flag() needs to be
checked against all threads as with process_shares_mm(). Otherwise,
find_lock_task_mm() can select a TIF_MEMDIE thread.

Updated patch follows.

> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 078e07ec0906..68cc130c163b 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -281,6 +281,8 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
>  	if (test_tsk_thread_flag(task, TIF_MEMDIE)) {
>  		if (!is_sysrq_oom(oc))
>  			return OOM_SCAN_ABORT;
> +		else
> +			return OOM_SCAN_CONTINUE;
>  	}
>  	if (!task->mm)
>  		return OOM_SCAN_CONTINUE;
> @@ -719,6 +721,9 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
>  
>  			if (process_shares_mm(child, p->mm))
>  				continue;
> +
> +			if (is_sysrq_oom(oc) && test_tsk_thread_flag(child, TIF_MEMDIE))
> +				continue;
>  			/*
>  			 * oom_badness() returns 0 if the thread is unkillable
>  			 */
> -- 
> Michal Hocko
> SUSE Labs
> 
----------
>From 4d305f92e2527b6d86cd366952d598f9e95f095b Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Thu, 18 Feb 2016 01:16:54 +0900
Subject: [PATCH v2] mm,oom: exclude TIF_MEMDIE processes from candidates.

It is possible that a TIF_MEMDIE thread gets stuck at
down_read(&mm->mmap_sem) in exit_mm() called from do_exit() due to
one of !TIF_MEMDIE threads doing a GFP_KERNEL allocation between
down_write(&mm->mmap_sem) and up_write(&mm->mmap_sem) (e.g. mmap()).
In that case, we need to use SysRq-f (manual invocation of the OOM
killer) for making progress.

However, it is possible that the OOM killer chooses the same OOM victim
forever which already has TIF_MEMDIE. This is effectively disabling
SysRq-f. This patch excludes processes which has a TIF_MEMDIE thread
>from OOM victim candidates.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/oom_kill.c | 21 ++++++++++++++++++++-
 1 file changed, 20 insertions(+), 1 deletion(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 6e6abaf..f6f6b47 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -268,6 +268,21 @@ static enum oom_constraint constrained_alloc(struct oom_control *oc,
 }
 #endif
 
+/*
+ * To determine whether a task is an OOM victim, we examine all the task's
+ * threads: if one of those has TIF_MEMDIE then the task is an OOM victim.
+ */
+static bool is_oom_victim(struct task_struct *p)
+{
+	struct task_struct *t;
+
+	for_each_thread(p, t) {
+		if (test_tsk_thread_flag(t, TIF_MEMDIE))
+			return true;
+	}
+	return false;
+}
+
 enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
 			struct task_struct *task, unsigned long totalpages)
 {
@@ -278,9 +293,11 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
 	 * This task already has access to memory reserves and is being killed.
 	 * Don't allow any other task to have access to the reserves.
 	 */
-	if (test_tsk_thread_flag(task, TIF_MEMDIE)) {
+	if (is_oom_victim(task)) {
 		if (!is_sysrq_oom(oc))
 			return OOM_SCAN_ABORT;
+		else
+			return OOM_SCAN_CONTINUE;
 	}
 	if (!task->mm || task->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
 		return OOM_SCAN_CONTINUE;
@@ -711,6 +728,8 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 
 			if (process_shares_mm(child, p->mm))
 				continue;
+			if (is_oom_victim(child))
+				continue;
 			/*
 			 * oom_badness() returns 0 if the thread is unkillable
 			 */
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
