Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 2D0E26B0254
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 12:33:20 -0500 (EST)
Received: by mail-wm0-f48.google.com with SMTP id g62so247490697wme.0
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 09:33:20 -0800 (PST)
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com. [74.125.82.45])
        by mx.google.com with ESMTPS id k4si3361168wje.12.2016.02.17.09.33.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Feb 2016 09:33:18 -0800 (PST)
Received: by mail-wm0-f45.google.com with SMTP id g62so247489772wme.0
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 09:33:18 -0800 (PST)
Date: Wed, 17 Feb 2016 18:33:17 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/6] mm,oom: exclude TIF_MEMDIE processes from candidates.
Message-ID: <20160217173317.GA29370@dhcp22.suse.cz>
References: <201602171928.GDE00540.SLJMOFFQOHtFVO@I-love.SAKURA.ne.jp>
 <201602171929.IFG12927.OVFJOQHOSMtFFL@I-love.SAKURA.ne.jp>
 <20160217124100.GE29196@dhcp22.suse.cz>
 <201602180140.IHH21322.OSJFHOMtFFOQVL@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201602180140.IHH21322.OSJFHOMtFFOQVL@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, rientjes@google.com, mgorman@suse.de, oleg@redhat.com, torvalds@linux-foundation.org, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 18-02-16 01:40:22, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Wed 17-02-16 19:29:33, Tetsuo Handa wrote:
[...]
> > > victim's memory is shared with OOM-unkillable processes) which will
> > > require manual SysRq-f for making progress.
> > 
> > Sharing mm with a task which is hidden from the OOM killer is a clear
> > misconfiguration IMO.
> >  
> 
> Misconfiguration and/or insane stress is no excuse to leave bugs unfixed.

Such a misconfiguration requires administrator privileges and we do not
do not try really hard to prevent admins from shooting themselves into
foot. Especially if that makes the code much more complicated.
 
[...]
> > In short I dislike this patch. It makes the code harder to read and the
> > same can be solved more straightforward:
> 
> Your patch is not doing the same thing. test_tsk_thread_flag() needs to be
> checked against all threads as with process_shares_mm(). Otherwise,
> find_lock_task_mm() can select a TIF_MEMDIE thread.
> 
> Updated patch follows.
[...]
> >From 4d305f92e2527b6d86cd366952d598f9e95f095b Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Thu, 18 Feb 2016 01:16:54 +0900
> Subject: [PATCH v2] mm,oom: exclude TIF_MEMDIE processes from candidates.
> 
> It is possible that a TIF_MEMDIE thread gets stuck at
> down_read(&mm->mmap_sem) in exit_mm() called from do_exit() due to
> one of !TIF_MEMDIE threads doing a GFP_KERNEL allocation between
> down_write(&mm->mmap_sem) and up_write(&mm->mmap_sem) (e.g. mmap()).
> In that case, we need to use SysRq-f (manual invocation of the OOM
> killer) for making progress.
> 
> However, it is possible that the OOM killer chooses the same OOM victim
> forever which already has TIF_MEMDIE. This is effectively disabling
> SysRq-f. This patch excludes processes which has a TIF_MEMDIE thread
> >from OOM victim candidates.
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> ---
>  mm/oom_kill.c | 21 ++++++++++++++++++++-
>  1 file changed, 20 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 6e6abaf..f6f6b47 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -268,6 +268,21 @@ static enum oom_constraint constrained_alloc(struct oom_control *oc,
>  }
>  #endif
>  
> +/*
> + * To determine whether a task is an OOM victim, we examine all the task's
> + * threads: if one of those has TIF_MEMDIE then the task is an OOM victim.
> + */
> +static bool is_oom_victim(struct task_struct *p)
> +{
> +	struct task_struct *t;
> +
> +	for_each_thread(p, t) {
> +		if (test_tsk_thread_flag(t, TIF_MEMDIE))
> +			return true;
> +	}
> +	return false;
> +}
> +
>  enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
>  			struct task_struct *task, unsigned long totalpages)
>  {
> @@ -278,9 +293,11 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
>  	 * This task already has access to memory reserves and is being killed.
>  	 * Don't allow any other task to have access to the reserves.
>  	 */
> -	if (test_tsk_thread_flag(task, TIF_MEMDIE)) {
> +	if (is_oom_victim(task)) {

This will make the scanning much more time consuming (you will check
all the threads in the same thread group for each scanned thread!). I
do not think this is acceptable and it is not really needed for the
!is_sysrq_oom because we are scanning all the threads anyway.

Regarding the is_sysrq_oom case we might indeed select a thread
which doesn't have TIF_MEMDIE but it has been already (group) killed
but an attempt to catch that case is exactly what has been Nacked
previously when I tried to achieve the same thing and had TIF_MEMDIE ||
fatal_signal_pending check
(http://lkml.kernel.org/r/alpine.DEB.2.10.1601121639450.28831@chino.kir.corp.google.com).
This change will basically achieve the same (just in much more expansive
way) so I am not sure it overcomes the previous feedback.

>  		if (!is_sysrq_oom(oc))
>  			return OOM_SCAN_ABORT;
> +		else
> +			return OOM_SCAN_CONTINUE;
>  	}
>  	if (!task->mm || task->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
>  		return OOM_SCAN_CONTINUE;
> @@ -711,6 +728,8 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
>  
>  			if (process_shares_mm(child, p->mm))
>  				continue;
> +			if (is_oom_victim(child))
> +				continue;
>  			/*
>  			 * oom_badness() returns 0 if the thread is unkillable
>  			 */
> -- 
> 1.8.3.1

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
