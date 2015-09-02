Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id DFD696B0254
	for <linux-mm@kvack.org>; Wed,  2 Sep 2015 10:24:50 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so21078565wic.0
        for <linux-mm@kvack.org>; Wed, 02 Sep 2015 07:24:50 -0700 (PDT)
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com. [209.85.212.176])
        by mx.google.com with ESMTPS id i19si2853479wjr.127.2015.09.02.07.24.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Sep 2015 07:24:49 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so19582427wic.1
        for <linux-mm@kvack.org>; Wed, 02 Sep 2015 07:24:49 -0700 (PDT)
Date: Wed, 2 Sep 2015 16:24:47 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/oom: Suppress unnecessary "sharing same
 memory"message.
Message-ID: <20150902142447.GC8985@dhcp22.suse.cz>
References: <201508292014.ICI39552.tQJOFFOVMSOFHL@I-love.SAKURA.ne.jp>
 <20150901133403.GE8810@dhcp22.suse.cz>
 <201509022027.AEH95817.VFFOHtMQOLFOJS@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201509022027.AEH95817.VFFOHtMQOLFOJS@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: rientjes@google.com, hannes@cmpxchg.org, linux-mm@kvack.org

On Wed 02-09-15 20:27:20, Tetsuo Handa wrote:
[...]
> >From 7268b614a159cd7cb307c7dfab6241b72d9cef93 Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Wed, 2 Sep 2015 20:03:16 +0900
> Subject: [PATCH v2] mm/oom: Suppress unnecessary "sharing same memory" message.
> 
> oom_kill_process() sends SIGKILL to other thread groups sharing
> victim's mm. But printing
> 
>   "Kill process %d (%s) sharing same memory\n"
> 
> lines makes no sense if they already have pending SIGKILL.
> This patch reduces the "Kill process" lines by printing
> that line with info level only if SIGKILL is not pending.
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

I do not expect this would have a big effect in practice but it is true
that it saves some pointless output without clobbering the code much so
it makes sense to me.

Acked-by: Michal Hocko <mhocko@suse.com>

Wrt. pr_err -> pr_info I think this makes some sense as well because it
is true that users might intentionally push away the useful information
about the killed task this way. Not that it is a big problem but
still...

But who knows maybe somebody depends on this information even on the
pr_err loglevel. I know that David is relying on parsing oom reports
quite heavily so he might have more to tell about it.

> ---
>  mm/oom_kill.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 1ecc0bc..610da01 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -576,9 +576,11 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
>  		    !(p->flags & PF_KTHREAD)) {
>  			if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
>  				continue;
> +			if (fatal_signal_pending(p))
> +				continue;
>  
>  			task_lock(p);	/* Protect ->comm from prctl() */
> -			pr_err("Kill process %d (%s) sharing same memory\n",
> +			pr_info("Kill process %d (%s) sharing same memory\n",
>  				task_pid_nr(p), p->comm);
>  			task_unlock(p);
>  			do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
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
