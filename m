Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 92B266B0038
	for <linux-mm@kvack.org>; Sat, 19 Sep 2015 04:22:41 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so58183153wic.0
        for <linux-mm@kvack.org>; Sat, 19 Sep 2015 01:22:41 -0700 (PDT)
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com. [209.85.212.182])
        by mx.google.com with ESMTPS id jb19si2941935wic.122.2015.09.19.01.22.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 19 Sep 2015 01:22:40 -0700 (PDT)
Received: by wicge5 with SMTP id ge5so58182853wic.0
        for <linux-mm@kvack.org>; Sat, 19 Sep 2015 01:22:39 -0700 (PDT)
Date: Sat, 19 Sep 2015 10:22:38 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/oom_kill.c: don't kill TASK_UNINTERRUPTIBLE tasks
Message-ID: <20150919082237.GB28815@dhcp22.suse.cz>
References: <1442512783-14719-1-git-send-email-kwalker@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1442512783-14719-1-git-send-email-kwalker@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kyle Walker <kwalker@redhat.com>
Cc: akpm@linux-foundation.org, rientjes@google.com, hannes@cmpxchg.org, vdavydov@parallels.com, oleg@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 17-09-15 13:59:43, Kyle Walker wrote:
> Currently, the oom killer will attempt to kill a process that is in
> TASK_UNINTERRUPTIBLE state. For tasks in this state for an exceptional
> period of time, such as processes writing to a frozen filesystem during
> a lengthy backup operation, this can result in a deadlock condition as
> related processes memory access will stall within the page fault
> handler.

I am not familiar with the fs freezing code so I might be missing
something important here. __sb_start_write waits for the frozen fs by
wait_event which is really UN sleep. Why cannot we sleep here in IN
sleep and return with EINTR when interrupted? I would consider this
a better behavior not only because of OOM because having unkillable
tasks in general is undesirable. AFAIU the fs might be frozen for ever
and admin cannot do anything about the pending processes.

> Within oom_unkillable_task(), check for processes in
> TASK_UNINTERRUPTIBLE (TASK_KILLABLE omitted). The oom killer will
> move on to another task.

Nack to this. TASK_UNINTERRUPTIBLE should be time constrained/bounded
state. Using it as an oom victim criteria makes the victim selection
less deterministic which is undesirable. As much as I am aware of
potential issues with the current implementation, making the behavior
more random doesn't really help.

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
>  	/* p may not have freeable memory in nodemask */
>  	if (!has_intersects_mems_allowed(p, nodemask))
>  		return true;
> -- 
> 2.4.3

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
