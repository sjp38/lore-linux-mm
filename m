Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 411C86B0005
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 07:41:03 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id g62so26309683wme.0
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 04:41:03 -0800 (PST)
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com. [74.125.82.50])
        by mx.google.com with ESMTPS id iy4si1636602wjb.144.2016.02.17.04.41.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Feb 2016 04:41:02 -0800 (PST)
Received: by mail-wm0-f50.google.com with SMTP id b205so153930729wmb.1
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 04:41:01 -0800 (PST)
Date: Wed, 17 Feb 2016 13:41:00 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/6] mm,oom: exclude TIF_MEMDIE processes from candidates.
Message-ID: <20160217124100.GE29196@dhcp22.suse.cz>
References: <201602171928.GDE00540.SLJMOFFQOHtFVO@I-love.SAKURA.ne.jp>
 <201602171929.IFG12927.OVFJOQHOSMtFFL@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201602171929.IFG12927.OVFJOQHOSMtFFL@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, rientjes@google.com, mgorman@suse.de, oleg@redhat.com, torvalds@linux-foundation.org, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 17-02-16 19:29:33, Tetsuo Handa wrote:
> >From 142b08258e4c60834602e9b0a734564208bc6397 Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Wed, 17 Feb 2016 16:29:29 +0900
> Subject: [PATCH 1/6] mm,oom: exclude TIF_MEMDIE processes from candidates.
> 
> The OOM reaper kernel thread can reclaim OOM victim's memory before
> the victim releases it.

If this is aimed to be preparatory work, which I am not convinced about
to be honest, then referring to oom reaper is confusing and misleading.

> But it is possible that a TIF_MEMDIE thread
> gets stuck at down_read(&mm->mmap_sem) in exit_mm() called from
> do_exit() due to one of !TIF_MEMDIE threads doing a GFP_KERNEL
> allocation between down_write(&mm->mmap_sem) and up_write(&mm->mmap_sem)
> (e.g. mmap()). In that case, we need to use SysRq-f (manual invocation
> of the OOM killer) because down_read_trylock(&mm->mmap_sem) by the OOM
> reaper will not succeed.

But all the tasks sharing the mm with the oom victim will have
fatal_signal_pending and so they will get access to memory reserves and
that should help them to finish the allocation request. So the above
text is misleading.

If the down_read is blocked because down_write is blocked then a better
solution is to make down_write_killable which has been already proposed.

> Also, there are other situations where the OOM
> reaper cannot reap the victim's memory (e.g. CONFIG_MMU=n,

there was no clear evidence that this is a problem on !MMU
configurations.

> victim's memory is shared with OOM-unkillable processes) which will
> require manual SysRq-f for making progress.

Sharing mm with a task which is hidden from the OOM killer is a clear
misconfiguration IMO.
 
> However, it is possible that the OOM killer chooses the same OOM victim
> forever which already has TIF_MEMDIE.

This can happen only for the sysrq+f case AFAICS. Regular OOM killer
will stop scanning after it encounters the first TIF_MEMDIE task.
If you want to handle the sysrq+f case then it should be imho explicit.
Something I've tries here as patch 1/2
http://lkml.kernel.org/r/1452632425-20191-1-git-send-email-mhocko@kernel.org
which has been nacked. Maybe you can try again without
fatal_signal_pending resp. task_will_free_mem checks which were
controversial back then. Hiding this into find_lock_non_victim_task_mm
is just making the code more obscure and harder to read.

> This is effectively disabling
> SysRq-f. This patch excludes processes which has a TIF_MEMDIE thread
>  from OOM victim candidates.
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

In short I dislike this patch. It makes the code harder to read and the
same can be solved more straightforward:

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 078e07ec0906..68cc130c163b 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -281,6 +281,8 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
 	if (test_tsk_thread_flag(task, TIF_MEMDIE)) {
 		if (!is_sysrq_oom(oc))
 			return OOM_SCAN_ABORT;
+		else
+			return OOM_SCAN_CONTINUE;
 	}
 	if (!task->mm)
 		return OOM_SCAN_CONTINUE;
@@ -719,6 +721,9 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 
 			if (process_shares_mm(child, p->mm))
 				continue;
+
+			if (is_sysrq_oom(oc) && test_tsk_thread_flag(child, TIF_MEMDIE))
+				continue;
 			/*
 			 * oom_badness() returns 0 if the thread is unkillable
 			 */
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
