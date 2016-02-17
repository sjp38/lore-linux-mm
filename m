Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id C0E1B6B0253
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 08:02:42 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id b205so154745981wmb.1
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 05:02:42 -0800 (PST)
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com. [74.125.82.41])
        by mx.google.com with ESMTPS id o126si40591681wma.32.2016.02.17.05.02.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Feb 2016 05:02:41 -0800 (PST)
Received: by mail-wm0-f41.google.com with SMTP id g62so27146261wme.0
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 05:02:41 -0800 (PST)
Date: Wed, 17 Feb 2016 14:02:40 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/6] mm,oom: exclude oom_task_origin processes if they
 are OOM victims.
Message-ID: <20160217130239.GG29196@dhcp22.suse.cz>
References: <201602171928.GDE00540.SLJMOFFQOHtFVO@I-love.SAKURA.ne.jp>
 <201602171932.IDB09391.FSOOtHJLQVFMFO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201602171932.IDB09391.FSOOtHJLQVFMFO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, rientjes@google.com, mgorman@suse.de, oleg@redhat.com, torvalds@linux-foundation.org, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 17-02-16 19:32:00, Tetsuo Handa wrote:
> >From f5531e726caad7431020c027b6900a8e2c678345 Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Wed, 17 Feb 2016 16:32:37 +0900
> Subject: [PATCH 3/6] mm,oom: exclude oom_task_origin processes if they are OOM victims.
> 
> Currently, oom_scan_process_thread() returns OOM_SCAN_SELECT when there
> is a thread which returns oom_task_origin() == true. But it is possible
> that that thread is sharing memory with OOM-unkillable processes or the
> OOM reaper fails to reclaim enough memory. In that case, we must not
> continue selecting such threads forever.
> 
> This patch changes oom_scan_process_thread() not to select a thread
> which returns oom_task_origin() = true if TIF_MEMDIE is already set
> because SysRq-f case can reach here. Since "mm,oom: exclude TIF_MEMDIE
> processes from candidates." made sure that we will choose a !TIF_MEMDIE
> thread when only some of threads are marked TIF_MEMDIE, we don't need to
> check all threads which returns oom_task_origin() == true.

I do not think this is necessary. If you simply do OOM_SCAN_CONTINUE for
TIF_MEMDIE && is_sysrq_oom then you should be covered AFAICS.

> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> ---
>  mm/oom_kill.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index a3868fd..b0c327d 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -308,7 +308,7 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
>  	 * If task is allocating a lot of memory and has been marked to be
>  	 * killed first if it triggers an oom, then select it.
>  	 */
> -	if (oom_task_origin(task))
> +	if (oom_task_origin(task) && !test_tsk_thread_flag(task, TIF_MEMDIE))
>  		return OOM_SCAN_SELECT;
>  
>  	return OOM_SCAN_OK;
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
