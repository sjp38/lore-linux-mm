Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1151A6B007E
	for <linux-mm@kvack.org>; Wed, 18 May 2016 08:51:42 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id w143so28346303wmw.3
        for <linux-mm@kvack.org>; Wed, 18 May 2016 05:51:42 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id e138si14587309wmf.84.2016.05.18.05.51.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 May 2016 05:51:40 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id n129so12665566wmn.1
        for <linux-mm@kvack.org>; Wed, 18 May 2016 05:51:40 -0700 (PDT)
Date: Wed, 18 May 2016 14:51:38 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm,oom: speed up select_bad_process() loop.
Message-ID: <20160518125138.GH21654@dhcp22.suse.cz>
References: <1463574024-8372-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1463574024-8372-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, rientjes@google.com, linux-mm@kvack.org, Oleg Nesterov <oleg@redhat.com>

On Wed 18-05-16 21:20:24, Tetsuo Handa wrote:
> Since commit 3a5dda7a17cf3706 ("oom: prevent unnecessary oom kills or
> kernel panics"), select_bad_process() is using for_each_process_thread().
> 
> Since oom_unkillable_task() scans all threads in the caller's thread group
> and oom_task_origin() scans signal_struct of the caller's thread group, we
> don't need to call oom_unkillable_task() and oom_task_origin() on each
> thread. Also, since !mm test will be done later at oom_badness(), we don't
> need to do !mm test on each thread. Therefore, we only need to do
> TIF_MEMDIE test on each thread.
> 
> If we track number of TIF_MEMDIE threads inside signal_struct, we don't
> need to do TIF_MEMDIE test on each thread. This will allow
> select_bad_process() to use for_each_process().

I am wondering whether signal_struct is the best way forward. The oom
killing is more about mm_struct than anything else. We can record that
the mm was oom killed in mm->flags (similar to MMF_OOM_REAPED). I guess
this would require more work at this stage so maybe starting with signal
struct is not that bad afterall. Just thinking...

> This patch adds a counter to signal_struct for tracking how many
> TIF_MEMDIE threads are in a given thread group, and check it at
> oom_scan_process_thread() so that select_bad_process() can use
> for_each_process() rather than for_each_process_thread().

In general I do agree that for_each_process is preferable. I guess you
are missing one case here, though (or maybe just forgot to refresh the
patch because the changelog mentions !mm test):

[...]
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index c0e37dd..1ac24e8 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -283,10 +283,8 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
>  	 * This task already has access to memory reserves and is being killed.
>  	 * Don't allow any other task to have access to the reserves.
>  	 */
> -	if (test_tsk_thread_flag(task, TIF_MEMDIE)) {
> -		if (!is_sysrq_oom(oc))
> -			return OOM_SCAN_ABORT;
> -	}
> +	if (!is_sysrq_oom(oc) && atomic_read(&task->signal->oom_victims))
> +		return OOM_SCAN_ABORT;
>  	if (!task->mm)
>  		return OOM_SCAN_CONTINUE;

So let's say that the group leader is gone, now you would skip the whole
thread group AFAICS. This is an easy way to hide from the OOM killer,
unless I've missed something.

You can safely drop if (!task->mm) check because oom_badness does
find_lock_task_mm so we will catch this case anyway.

Other than that the patch looks good to me.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
