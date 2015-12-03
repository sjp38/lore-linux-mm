Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 31B616B0257
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 03:12:04 -0500 (EST)
Received: by wmvv187 with SMTP id v187so14506767wmv.1
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 00:12:03 -0800 (PST)
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com. [74.125.82.45])
        by mx.google.com with ESMTPS id z186si13122373wmz.15.2015.12.03.00.12.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Dec 2015 00:12:03 -0800 (PST)
Received: by wmvv187 with SMTP id v187so14506268wmv.1
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 00:12:02 -0800 (PST)
Date: Thu, 3 Dec 2015 09:12:01 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch] mm, oom: avoid attempting to kill init sharing same
 memory
Message-ID: <20151203081200.GA9264@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1512021509460.14638@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1512021509460.14638@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, chenjie6@huawei.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, David.Woodhouse@intel.com, zhihui.gao@huawei.com, lizefan@huawei.com

On Wed 02-12-15 15:10:28, David Rientjes wrote:
> From: Chen Jie <chenjie6@huawei.com>
> 
> It's possible that an oom killed victim shares an ->mm with the init
> process and thus oom_kill_process() would end up trying to kill init as
> well.
> 
> This has been shown in practice:
> 
> 	Out of memory: Kill process 9134 (init) score 3 or sacrifice child
> 	Killed process 9134 (init) total-vm:1868kB, anon-rss:84kB, file-rss:572kB
> 	Kill process 1 (init) sharing same memory
> 	...
> 	Kernel panic - not syncing: Attempted to kill init! exitcode=0x00000009
> 
> And this will result in a kernel panic.
> 
> If a process is forked by init and selected for oom kill while still
> sharing init_mm, then it's likely this system is in a recoverable state.
> However, it's better not to try to kill init and allow the machine to
> panic due to unkillable processes.
> 
> [rientjes@google.com: rewrote changelog]
> Acked-by: Michal Hocko <mhocko@suse.com>
> Signed-off-by: Chen Jie <chenjie6@huawei.com>
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  I removed stable from this patch since the alternative would most likely
>  be to panic the system for no killable processes anyway.  There's a very
>  small likelihood this patch would allow for a recoverable system.

Agreed.

>  mm/oom_kill.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
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

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
