Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 5612D6B0005
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 09:39:20 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id b205so158676505wmb.1
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 06:39:20 -0800 (PST)
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com. [74.125.82.41])
        by mx.google.com with ESMTPS id fy9si2340238wjb.72.2016.02.17.06.39.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Feb 2016 06:39:19 -0800 (PST)
Received: by mail-wm0-f41.google.com with SMTP id c200so216979025wme.0
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 06:39:19 -0800 (PST)
Date: Wed, 17 Feb 2016 15:39:17 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm,oom: don't abort on exiting processes when
 selecting a victim.
Message-ID: <20160217143917.GP29196@dhcp22.suse.cz>
References: <1455719485-7730-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1455719485-7730-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, rientjes@google.com, mgorman@suse.de, oleg@redhat.com, torvalds@linux-foundation.org, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>

On Wed 17-02-16 23:31:25, Tetsuo Handa wrote:
> Currently, oom_scan_process_thread() returns OOM_SCAN_ABORT when there is
> a thread which is exiting. But it is possible that that thread is blocked
> at down_read(&mm->mmap_sem) in exit_mm() called from do_exit() whereas
> one of threads sharing that memory is doing a GFP_KERNEL allocation
> between down_write(&mm->mmap_sem) and up_write(&mm->mmap_sem)
> (e.g. mmap()).
> 
> ----------
> T1                  T2
>                     Calls mmap()
> Calls _exit(0)
>                     Arrives at vm_mmap_pgoff()
> Arrives at do_exit()
> Gets PF_EXITING via exit_signals()
>                     Calls down_write(&mm->mmap_sem)
>                     Calls do_mmap_pgoff()
> Calls down_read(&mm->mmap_sem) from exit_mm()
>                     Calls out of memory via a GFP_KERNEL allocation but
>                     oom_scan_process_thread(T1) returns OOM_SCAN_ABORT
> ----------
> 
> down_read(&mm->mmap_sem) by T1 is waiting for up_write(&mm->mmap_sem) by
> T2 while oom_scan_process_thread() by T2 is waiting for T1 to set
> T1->mm = NULL. Under such situation, the OOM killer does not choose
> a victim, which results in silent OOM livelock problem.
> 
> This patch changes oom_scan_process_thread() not to return OOM_SCAN_ABORT
> when there is a thread which is exiting.

Thank you for the updated changelog. This makes much more sense now.
This problem exists for quite some time but I would be hesitant to
mark it for stable because the side effects are quite hard to evaluate.
We could e.g. see a premature OOM killer invocation while the currently
exiting task just didn't get to finish and release its mm.

> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/oom_kill.c | 3 ---
>  1 file changed, 3 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index cf87153..6e6abaf 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -292,9 +292,6 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
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
