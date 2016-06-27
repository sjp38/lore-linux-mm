Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id B3FFE6B0253
	for <linux-mm@kvack.org>; Mon, 27 Jun 2016 11:50:43 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id d2so217302693qkg.0
        for <linux-mm@kvack.org>; Mon, 27 Jun 2016 08:50:43 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k83si13547838qkh.95.2016.06.27.08.50.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Jun 2016 08:50:42 -0700 (PDT)
Date: Mon, 27 Jun 2016 17:51:20 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] mm,oom: use per signal_struct flag rather than clear
	TIF_MEMDIE
Message-ID: <20160627155119.GA17686@redhat.com>
References: <1466766121-8164-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp> <20160624215627.GA1148@redhat.com> <201606251444.EGJ69787.FtMOFJOLSHFQOV@I-love.SAKURA.ne.jp> <20160627092326.GD31799@dhcp22.suse.cz> <20160627103609.GE31799@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160627103609.GE31799@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, vdavydov@virtuozzo.com, rientjes@google.com

On 06/27, Michal Hocko wrote:
>
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -237,6 +237,8 @@ void free_task(struct task_struct *tsk)
>  	ftrace_graph_exit_task(tsk);
>  	put_seccomp_filter(tsk);
>  	arch_release_task_struct(tsk);
> +	if (tsk->active_mm)
> +		mmdrop(tsk->active_mm);
>  	free_task_struct(tsk);
>  }
>  EXPORT_SYMBOL(free_task);
> @@ -1022,6 +1024,8 @@ static int copy_mm(unsigned long clone_flags, struct task_struct *tsk)
>  good_mm:
>  	tsk->mm = mm;
>  	tsk->active_mm = mm;
> +	/* to be release in the final task_put */
> +	atomic_inc(&mm->mm_count);
>  	return 0;

No, I don't think this can work.

Note that tsk->active_mm in free_task() points to the random mm "borrowed"
from the previous/random task in context_switch() if task->mm == NULL. This
is true for kthreads and for the task which has already called exit_mm().

> -	p = find_lock_task_mm(tsk);
> -	if (!p)
> -		goto unlock_oom;
> -	mm = p->mm;
> +	task_lock(tsk);
> +	mm = tsk->active_mm;

The same. We can't know where this ->active_mm points to.

Just suppose that this tsk schedules after exit_mm(). When it gets CPU
again tsk->active_mm will point to ->mm of another task which in turns
called schedule() to make this tsk active.

Yes I agree, it would be nice to remove find_lock_task_mm(). And in
fact it would be nice to kill task_struct->mm (but this needs a lot
of cleanups). We probably want signal_struct->mm, but this is a bit
complicated (locking).

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
