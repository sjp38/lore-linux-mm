Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 4ABAB6B0253
	for <linux-mm@kvack.org>; Thu, 27 Aug 2015 04:44:47 -0400 (EDT)
Received: by wijn1 with SMTP id n1so48128608wij.0
        for <linux-mm@kvack.org>; Thu, 27 Aug 2015 01:44:46 -0700 (PDT)
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com. [209.85.212.174])
        by mx.google.com with ESMTPS id b4si15083199wic.119.2015.08.27.01.44.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Aug 2015 01:44:45 -0700 (PDT)
Received: by widdq5 with SMTP id dq5so70622157wid.1
        for <linux-mm@kvack.org>; Thu, 27 Aug 2015 01:44:45 -0700 (PDT)
Date: Thu, 27 Aug 2015 10:44:43 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] android, lmk: Reverse the order of setting
 TIF_MEMDIE and sending SIGKILL.
Message-ID: <20150827084443.GE14367@dhcp22.suse.cz>
References: <201508262117.FAH43726.tOFMVJSLQOFHFO@I-love.SAKURA.ne.jp>
 <201508262119.IHA93770.JOOtFHMSFLOQVF@I-love.SAKURA.ne.jp>
 <201508270034.GEH35997.SFOMOVLFtOHFQJ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201508270034.GEH35997.SFOMOVLFtOHFQJ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: gregkh@linuxfoundation.org, arve@android.com, riandrews@android.com, devel@driverdev.osuosl.org, linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org

On Thu 27-08-15 00:34:47, Tetsuo Handa wrote:
> Reposting updated version as it turned out that we can call do_send_sig_info()
> with task_lock held. ;-) ( http://marc.info/?l=linux-mm&m=144059948628905&w=2 )
> 
> Tetsuo Handa wrote:
> > Should selected_tasksize be added to rem even when TIF_MEMDIE was not set?
> Commit e1099a69a624 "android, lmk: avoid setting TIF_MEMDIE if process
> has already exited" changed not to add selected_tasksize to rem. But I
> noticed that rem is initialized to 0 and there is only one addition
> (i.e. rem += selected_tasksize means rem = selected_tasksize) since
> commit 7dc19d5affd7 "drivers: convert shrinkers to new count/scan API".
> I don't know what values we should return, but this patch restores
> pre commit e1099a69a624 because omitting a call to mark_oom_victim()
> due to race will not prevent from reclaiming memory because we already
> sent SIGKILL.
> ------------------------------------------------------------
> >From b7075abd3a1e903e88f1755c68adc017d2125b0d Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Thu, 27 Aug 2015 00:13:57 +0900
> Subject: [PATCH 2/2] android, lmk: Send SIGKILL before setting TIF_MEMDIE.
> 
> It was observed that setting TIF_MEMDIE before sending SIGKILL at
> oom_kill_process() allows memory reserves to be depleted by allocations
> which are not needed for terminating the OOM victim.
> 
> This patch reverts commit 6bc2b856bb7c ("staging: android: lowmemorykiller:
> set TIF_MEMDIE before send kill sig"), for oom_kill_process() was updated
> to send SIGKILL before setting TIF_MEMDIE.
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  drivers/staging/android/lowmemorykiller.c | 17 ++++++-----------
>  1 file changed, 6 insertions(+), 11 deletions(-)
> 
> diff --git a/drivers/staging/android/lowmemorykiller.c b/drivers/staging/android/lowmemorykiller.c
> index d5d25e4..af604cf 100644
> --- a/drivers/staging/android/lowmemorykiller.c
> +++ b/drivers/staging/android/lowmemorykiller.c
> @@ -156,26 +156,21 @@ next:
>  	}
>  	if (selected) {
>  		task_lock(selected);
> -		if (!selected->mm) {
> -			/* Already exited, cannot do mark_tsk_oom_victim() */
> -			task_unlock(selected);
> -			goto out;
> -		}
> +		lowmem_print(1, "send sigkill to %d (%s), adj %hd, size %d\n",
> +			     selected->pid, selected->comm,
> +			     selected_oom_score_adj, selected_tasksize);
> +		send_sig(SIGKILL, selected, 0);
>  		/*
>  		 * FIXME: lowmemorykiller shouldn't abuse global OOM killer
>  		 * infrastructure. There is no real reason why the selected
>  		 * task should have access to the memory reserves.
>  		 */
> -		mark_oom_victim(selected);
> -		lowmem_print(1, "send sigkill to %d (%s), adj %hd, size %d\n",
> -			     selected->pid, selected->comm,
> -			     selected_oom_score_adj, selected_tasksize);
> +		if (selected->mm)
> +			mark_oom_victim(selected);
>  		task_unlock(selected);
>  		lowmem_deathpending_timeout = jiffies + HZ;
> -		send_sig(SIGKILL, selected, 0);
>  		rem += selected_tasksize;
>  	}
> -out:
>  	lowmem_print(4, "lowmem_scan %lu, %x, return %lu\n",
>  		     sc->nr_to_scan, sc->gfp_mask, rem);
>  	rcu_read_unlock();
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
