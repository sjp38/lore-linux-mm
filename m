Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id AE9C06B0005
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 11:24:39 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id x1so53665271pav.3
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 08:24:39 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id vl8si19279438pab.245.2016.06.02.08.24.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 02 Jun 2016 08:24:38 -0700 (PDT)
Subject: Re: [PATCH 7/6] mm, oom: task_will_free_mem should skip oom_reaped tasks
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1464613556-16708-1-git-send-email-mhocko@kernel.org>
	<1464876183-15559-1-git-send-email-mhocko@kernel.org>
In-Reply-To: <1464876183-15559-1-git-send-email-mhocko@kernel.org>
Message-Id: <201606030024.BIJ82362.MFOVJFHQOOtSLF@I-love.SAKURA.ne.jp>
Date: Fri, 3 Jun 2016 00:24:31 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, linux-mm@kvack.org
Cc: rientjes@google.com, oleg@redhat.com, mhocko@suse.com

Michal Hocko wrote:
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index dacfb6ab7b04..d6e121decb1a 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -766,6 +766,15 @@ bool task_will_free_mem(struct task_struct *task)
>  		return true;
>  	}
>  
> +	/*
> +	 * This task has already been drained by the oom reaper so there are
> +	 * only small chances it will free some more
> +	 */
> +	if (test_bit(MMF_OOM_REAPED, &mm->flags)) {
> +		task_unlock(p);
> +		return false;
> +	}
> +

I think this check should be done before

	if (atomic_read(&mm->mm_users) <= 1) {
		task_unlock(p);
		return true;
	}

because it is possible that task_will_free_mem(task) is the only thread
using task->mm (i.e. atomic_read(&mm->mm_users) == 1).

>  	/* pin the mm to not get freed and reused */
>  	atomic_inc(&mm->mm_count);
>  	task_unlock(p);
> -- 
> 2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
