Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 59D836B0253
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 08:10:37 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id g62so236619737wme.0
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 05:10:37 -0800 (PST)
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com. [74.125.82.46])
        by mx.google.com with ESMTPS id a8si40568879wmh.97.2016.02.17.05.10.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Feb 2016 05:10:36 -0800 (PST)
Received: by mail-wm0-f46.google.com with SMTP id c200so212760744wme.0
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 05:10:36 -0800 (PST)
Date: Wed, 17 Feb 2016 14:10:35 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/6] mm,oom: exclude oom_task_origin processes if they
 are OOM-unkillable.
Message-ID: <20160217131034.GH29196@dhcp22.suse.cz>
References: <201602171928.GDE00540.SLJMOFFQOHtFVO@I-love.SAKURA.ne.jp>
 <201602171933.HFD51078.LOSFVMFQFOJHOt@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201602171933.HFD51078.LOSFVMFQFOJHOt@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, rientjes@google.com, mgorman@suse.de, oleg@redhat.com, torvalds@linux-foundation.org, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 17-02-16 19:33:07, Tetsuo Handa wrote:
> >From 4924ca3031444bfb831b2d4f004e5a613ad48d68 Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Wed, 17 Feb 2016 16:35:12 +0900
> Subject: [PATCH 4/6] mm,oom: exclude oom_task_origin processes if they are OOM-unkillable.
> 
> oom_scan_process_thread() returns OOM_SCAN_SELECT when there is a
> thread which returns oom_task_origin() == true. But it is possible
> that that thread is marked as OOM-unkillable.
> 
> This patch changes oom_scan_process_thread() not to select it
> if it is marked as OOM-unkillable.

oom_task_origin is only swapoff and ksm_store right now. I seriously
doubt anybody sane will run them as OOM disabled (directly or
indirectly).

But you have a point that returing anything but OOM_SCAN_CONTINUE for
OOM_SCORE_ADJ_MIN from oom_scan_process_thread sounds suboptimal.
Sure such a check would be racy but do we actually care about a OOM vs.
oom_score_adj_write. I am dubious to say the least.

So wouldn't it make more sense to check for OOM_SCORE_ADJ_MIN at the
very top of oom_scan_process_thread instead?
 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> ---
>  mm/oom_kill.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index b0c327d..ebc6764 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -308,7 +308,8 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
>  	 * If task is allocating a lot of memory and has been marked to be
>  	 * killed first if it triggers an oom, then select it.
>  	 */
> -	if (oom_task_origin(task) && !test_tsk_thread_flag(task, TIF_MEMDIE))
> +	if (oom_task_origin(task) && !test_tsk_thread_flag(task, TIF_MEMDIE) &&
> +	    task->signal->oom_score_adj != OOM_SCORE_ADJ_MIN)
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
