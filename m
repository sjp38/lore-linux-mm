Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f200.google.com (mail-ig0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 178346B007E
	for <linux-mm@kvack.org>; Thu, 26 May 2016 10:30:18 -0400 (EDT)
Received: by mail-ig0-f200.google.com with SMTP id sq19so142340307igc.0
        for <linux-mm@kvack.org>; Thu, 26 May 2016 07:30:18 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 9si10046760otq.36.2016.05.26.07.30.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 26 May 2016 07:30:17 -0700 (PDT)
Subject: Re: [PATCH 1/6] mm, oom: do not loop over all tasks if there are no external tasks sharing mm
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1464266415-15558-1-git-send-email-mhocko@kernel.org>
	<1464266415-15558-2-git-send-email-mhocko@kernel.org>
In-Reply-To: <1464266415-15558-2-git-send-email-mhocko@kernel.org>
Message-Id: <201605262330.EEB52182.OtMFOJHFLOSFVQ@I-love.SAKURA.ne.jp>
Date: Thu, 26 May 2016 23:30:06 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, linux-mm@kvack.org
Cc: rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, mhocko@suse.com

Michal Hocko wrote:
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 5bb2f7698ad7..0e33e912f7e4 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -820,6 +820,13 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
>  	task_unlock(victim);
>  
>  	/*
> +	 * skip expensive iterations over all tasks if we know that there
> +	 * are no users outside of threads in the same thread group
> +	 */
> +	if (atomic_read(&mm->mm_users) <= get_nr_threads(victim))
> +		goto oom_reap;

Is this really safe? Isn't it possible that victim thread's thread group has
more than atomic_read(&mm->mm_users) threads which are past exit_mm() and blocked
at exit_task_work() which are before __exit_signal() from release_task() from
exit_notify()?

> +
> +	/*
>  	 * Kill all user processes sharing victim->mm in other thread groups, if
>  	 * any.  They don't get access to memory reserves, though, to avoid
>  	 * depletion of all memory.  This prevents mm->mmap_sem livelock when an

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
