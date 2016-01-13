Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 3672B828DF
	for <linux-mm@kvack.org>; Tue, 12 Jan 2016 19:41:52 -0500 (EST)
Received: by mail-pf0-f169.google.com with SMTP id q63so73313060pfb.1
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 16:41:52 -0800 (PST)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id xc4si22183639pab.244.2016.01.12.16.41.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jan 2016 16:41:51 -0800 (PST)
Received: by mail-pa0-x22e.google.com with SMTP id yy13so255581684pab.3
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 16:41:51 -0800 (PST)
Date: Tue, 12 Jan 2016 16:41:50 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC 1/3] oom, sysrq: Skip over oom victims and killed tasks
In-Reply-To: <1452632425-20191-2-git-send-email-mhocko@kernel.org>
Message-ID: <alpine.DEB.2.10.1601121639450.28831@chino.kir.corp.google.com>
References: <1452632425-20191-1-git-send-email-mhocko@kernel.org> <1452632425-20191-2-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Tue, 12 Jan 2016, Michal Hocko wrote:

> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index abefeeb42504..2b9dc5129a89 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -326,6 +326,17 @@ static struct task_struct *select_bad_process(struct oom_control *oc,
>  		case OOM_SCAN_OK:
>  			break;
>  		};
> +
> +		/*
> +		 * If we are doing sysrq+f then it doesn't make any sense to
> +		 * check OOM victim or killed task because it might be stuck
> +		 * and unable to terminate while the forced OOM might be the
> +		 * only option left to get the system back to work.
> +		 */
> +		if (is_sysrq_oom(oc) && (test_tsk_thread_flag(p, TIF_MEMDIE) ||
> +				fatal_signal_pending(p)))
> +			continue;
> +
>  		points = oom_badness(p, NULL, oc->nodemask, totalpages);
>  		if (!points || points < chosen_points)
>  			continue;

I think you can make a case for testing TIF_MEMDIE here since there is no 
chance of a panic from the sysrq trigger.  However, I'm not convinced that 
checking fatal_signal_pending() is appropriate.  I think it would be 
better for sysrq+f to first select a process with fatal_signal_pending() 
set so it silently gets access to memory reserves and then a second 
sysrq+f to choose a different process, if necessary, because of 
TIF_MEMDIE.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
