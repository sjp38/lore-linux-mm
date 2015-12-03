Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id F37DE6B0038
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 03:19:53 -0500 (EST)
Received: by padhx2 with SMTP id hx2so64588833pad.1
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 00:19:53 -0800 (PST)
Received: from out21.biz.mail.alibaba.com (out21.biz.mail.alibaba.com. [205.204.114.132])
        by mx.google.com with ESMTP id z12si10561837pfi.102.2015.12.03.00.19.51
        for <linux-mm@kvack.org>;
        Thu, 03 Dec 2015 00:19:53 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
Subject: Re: [patch] mm, oom: avoid attempting to kill init sharing same memory
Date: Thu, 03 Dec 2015 16:19:34 +0800
Message-ID: <05dd01d12da3$5888bb10$099a3130$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, chenjie6@huawei.com, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, David.Woodhouse@intel.com

> 
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

Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

>  I removed stable from this patch since the alternative would most likely
>  be to panic the system for no killable processes anyway.  There's a very
>  small likelihood this patch would allow for a recoverable system.
> 
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
> --


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
