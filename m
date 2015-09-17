Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id F3B6B6B0038
	for <linux-mm@kvack.org>; Thu, 17 Sep 2015 15:25:03 -0400 (EDT)
Received: by qgev79 with SMTP id v79so21521286qge.0
        for <linux-mm@kvack.org>; Thu, 17 Sep 2015 12:25:03 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g18si4113590qhc.82.2015.09.17.12.25.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Sep 2015 12:25:03 -0700 (PDT)
Date: Thu, 17 Sep 2015 21:22:04 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] mm/oom_kill.c: don't kill TASK_UNINTERRUPTIBLE tasks
Message-ID: <20150917192204.GA2728@redhat.com>
References: <1442512783-14719-1-git-send-email-kwalker@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1442512783-14719-1-git-send-email-kwalker@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kyle Walker <kwalker@redhat.com>
Cc: akpm@linux-foundation.org, mhocko@suse.cz, rientjes@google.com, hannes@cmpxchg.org, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Stanislav Kozina <skozina@redhat.com>

Add cc's.

On 09/17, Kyle Walker wrote:
>
> Currently, the oom killer will attempt to kill a process that is in
> TASK_UNINTERRUPTIBLE state. For tasks in this state for an exceptional
> period of time, such as processes writing to a frozen filesystem during
> a lengthy backup operation, this can result in a deadlock condition as
> related processes memory access will stall within the page fault
> handler.
>
> Within oom_unkillable_task(), check for processes in
> TASK_UNINTERRUPTIBLE (TASK_KILLABLE omitted). The oom killer will
> move on to another task.
>
> Signed-off-by: Kyle Walker <kwalker@redhat.com>
> ---
>  mm/oom_kill.c | 4 ++++
>  1 file changed, 4 insertions(+)
>
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 1ecc0bc..66f03f8 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -131,6 +131,10 @@ static bool oom_unkillable_task(struct task_struct *p,
>  	if (memcg && !task_in_mem_cgroup(p, memcg))
>  		return true;
>
> +	/* Uninterruptible tasks should not be killed unless in TASK_WAKEKILL */
> +	if (p->state == TASK_UNINTERRUPTIBLE)
> +		return true;
> +

So we can skip a memory hog which, say, does mutex_lock(). And this can't
help if this task is multithreaded, unless all its sub-threads are in "D"
state too oom killer will pick another thread with the same ->mm. Plus
other problems.

But yes, such a deadlock is possible. I would really like to see the comments
from maintainers. In particular, I seem to recall that someone suggested to
try to kill another !TIF_MEMDIE process after timeout, perhaps this is what
we should actually do...

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
