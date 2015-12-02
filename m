Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 3BBC76B0038
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 05:35:52 -0500 (EST)
Received: by wmvv187 with SMTP id v187so247959285wmv.1
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 02:35:51 -0800 (PST)
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com. [74.125.82.51])
        by mx.google.com with ESMTPS id o8si3379500wjy.224.2015.12.02.02.35.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Dec 2015 02:35:51 -0800 (PST)
Received: by wmec201 with SMTP id c201so246332402wme.0
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 02:35:51 -0800 (PST)
Date: Wed, 2 Dec 2015 11:35:49 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] oom kill init lead panic
Message-ID: <20151202103549.GB25290@dhcp22.suse.cz>
References: <1449037856-23990-1-git-send-email-chenjie6@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1449037856-23990-1-git-send-email-chenjie6@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: chenjie6@huawei.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, David.Woodhouse@intel.com, zhihui.gao@huawei.com, lizefan@huawei.com, akpm@linux-foundation.org, stable@vger.kernel.org

On Wed 02-12-15 14:30:56, chenjie6@huawei.com wrote:
> From: chenjie <chenjie6@huawei.com>
> 
> when oom happened we can see:
> Out of memory: Kill process 9134 (init) score 3 or sacrifice child
> Killed process 9134 (init) total-vm:1868kB, anon-rss:84kB, file-rss:572kB
> Kill process 1 (init) sharing same memory
> ...
> Kernel panic - not syncing: Attempted to kill init! exitcode=0x00000009
> 
> That's because:
>         the busybox init will vfork a process,oom_kill_process found
> the init not the children,their mm is the same when vfork.

It is quite unlikely that killing the task would help to free much
memory so if this is really the only oom victim it is to be expected to
panic sooner or later but this is in line with oom_unkillable_task()
so it makes sense.
 
> Cc: <stable@vger.kernel.org>
> Signed-off-by: Chen Jie <chenjie6@huawei.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> 
> ---
>  mm/oom_kill.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index d13a339..a0ddebd 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -608,6 +608,8 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
>  			continue;
>  		if (unlikely(p->flags & PF_KTHREAD))
>  			continue;
> +		if (!is_global_init(p))
> +			continue;
>  		if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
>  			continue;
>  
> -- 
> 1.8.0
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
