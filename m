Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 5F03D6B0254
	for <linux-mm@kvack.org>; Tue,  1 Sep 2015 09:34:07 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so12824846wic.0
        for <linux-mm@kvack.org>; Tue, 01 Sep 2015 06:34:07 -0700 (PDT)
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com. [209.85.212.182])
        by mx.google.com with ESMTPS id s17si3219118wij.44.2015.09.01.06.34.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Sep 2015 06:34:06 -0700 (PDT)
Received: by wicjd9 with SMTP id jd9so33440303wic.1
        for <linux-mm@kvack.org>; Tue, 01 Sep 2015 06:34:05 -0700 (PDT)
Date: Tue, 1 Sep 2015 15:34:04 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/oom: Suppress unnecessary "sharing same memory"
 message.
Message-ID: <20150901133403.GE8810@dhcp22.suse.cz>
References: <201508292014.ICI39552.tQJOFFOVMSOFHL@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201508292014.ICI39552.tQJOFFOVMSOFHL@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: rientjes@google.com, hannes@cmpxchg.org, linux-mm@kvack.org

On Sat 29-08-15 20:14:54, Tetsuo Handa wrote:
[...]
> >From 540e1ba8db5e7044134d838a256f28080cdba0f0 Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Sat, 29 Aug 2015 19:24:06 +0900
> Subject: [PATCH] mm/oom: Suppress unnecessary "sharing same memory" message.
> 
> If the mm struct which an OOM victim is using is shared by e.g. 1000
> other thread groups, the kernel would emit the
> 
>   "Kill process %d (%s) sharing same memory\n"
> 
> line for 1000 times.
> 
> Currently, OOM killer by SysRq-f can get stuck (i.e. SysRq-f is unable
> to kill a different task due to choosing the same OOM victim forever)
> if there is already an OOM victim. The user who presses SysRq-f need to
> check the
> 
>   "Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB\n"
> 
> line in order to judge whether SysRq-f got stuck or not, but the 1000
> "Kill process" lines sweeps the "Killed process" line out of console
> screen, making it impossible to judge whether OOM killer by SysRq-f got
> stuck or not.

Dunno, the argumentation seems quite artificial to me and not really
relevant. Even when you see "Killed process..." then it doesn't mean
anything. And you are quite likely to get swamped by the same messages
the first time you hit sysrq+f.

I do agree that repeating those messages is quite annoying though and it
doesn't make sense to print them if the task is known to have
fatal_signal_pending already. So I do agree with the patch but I would
really appreciate rewording of the changelog.

I would be also tempted to change pr_err to pr_info for "Kill process %d
(%s) sharing same memory\n"

> Fixing the stuck problem is outside of this patch's scope.

> This patch
> reduces the "Kill process" lines by printing that line only if SIGKILL
> is not pending.
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> ---
>  mm/oom_kill.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 1ecc0bc..4816fb7 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -576,6 +576,8 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
>  		    !(p->flags & PF_KTHREAD)) {
>  			if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
>  				continue;
> +			if (fatal_signal_pending(p))
> +				continue;
>  
>  			task_lock(p);	/* Protect ->comm from prctl() */
>  			pr_err("Kill process %d (%s) sharing same memory\n",
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
