Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 193826B0253
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 07:54:21 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id a4so26645005wme.1
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 04:54:21 -0800 (PST)
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com. [74.125.82.51])
        by mx.google.com with ESMTPS id c2si1674363wjb.214.2016.02.17.04.54.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Feb 2016 04:54:19 -0800 (PST)
Received: by mail-wm0-f51.google.com with SMTP id g62so158482144wme.1
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 04:54:19 -0800 (PST)
Date: Wed, 17 Feb 2016 13:54:18 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/6] mm,oom: don't abort on exiting processes when
 selecting a victim.
Message-ID: <20160217125418.GF29196@dhcp22.suse.cz>
References: <201602171928.GDE00540.SLJMOFFQOHtFVO@I-love.SAKURA.ne.jp>
 <201602171930.AII18204.FMOSVFQFOJtLOH@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201602171930.AII18204.FMOSVFQFOJtLOH@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, rientjes@google.com, mgorman@suse.de, oleg@redhat.com, torvalds@linux-foundation.org, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 17-02-16 19:30:41, Tetsuo Handa wrote:
> >From 22bd036766e70f0df38c38f3ecc226e857d20faf Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Wed, 17 Feb 2016 16:30:59 +0900
> Subject: [PATCH 2/6] mm,oom: don't abort on exiting processes when selecting a victim.
> 
> Currently, oom_scan_process_thread() returns OOM_SCAN_ABORT when there
> is a thread which is exiting. But it is possible that that thread is
> blocked at down_read(&mm->mmap_sem) in exit_mm() called from do_exit()
> whereas one of threads sharing that memory is doing a GFP_KERNEL
> allocation between down_write(&mm->mmap_sem) and up_write(&mm->mmap_sem)
> (e.g. mmap()). Under such situation, the OOM killer does not choose a
> victim, which results in silent OOM livelock problem.

Again, such a thread/task will have fatal_signal_pending and so have
access to memory reserves. So the text is slightly misleading imho.
Sure if the memory reserves are depleted then we will not move on but
then it is not clear whether the current patch helps either.

> This patch changes oom_scan_process_thread() not to return OOM_SCAN_ABORT
> when there is a thread which is exiting.

The same patch has been poseted already [1] so at least Johannes' s-o-b
(and CC) would be appropriate. As I've already said I am not against
this change, especially after oom_reaper is merged and the patch
description reformulated.

[1] http://lkml.kernel.org/r/569433bb.diO0RgkTdhop9gmH%25akpm%40linux-foundation.org
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> ---
>  mm/oom_kill.c | 3 ---
>  1 file changed, 3 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 27949ef..a3868fd 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -311,9 +311,6 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
>  	if (oom_task_origin(task))
>  		return OOM_SCAN_SELECT;
>  
> -	if (task_will_free_mem(task) && !is_sysrq_oom(oc))
> -		return OOM_SCAN_ABORT;
> -
>  	return OOM_SCAN_OK;
>  }
>  
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
