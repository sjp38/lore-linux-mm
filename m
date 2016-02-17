Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 49DA96B0005
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 09:48:37 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id g62so240601363wme.0
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 06:48:37 -0800 (PST)
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com. [74.125.82.49])
        by mx.google.com with ESMTPS id m3si4931382wmb.52.2016.02.17.06.48.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Feb 2016 06:48:36 -0800 (PST)
Received: by mail-wm0-f49.google.com with SMTP id a4so31492995wme.1
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 06:48:35 -0800 (PST)
Date: Wed, 17 Feb 2016 15:48:34 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm,oom: exclude oom_task_origin processes if they are
 OOM-unkillable.
Message-ID: <20160217144834.GQ29196@dhcp22.suse.cz>
References: <1455719460-7690-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1455719460-7690-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, rientjes@google.com, mgorman@suse.de, oleg@redhat.com, torvalds@linux-foundation.org, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 17-02-16 23:31:00, Tetsuo Handa wrote:
> oom_scan_process_thread() returns OOM_SCAN_SELECT when there is a
> thread which returns oom_task_origin() == true. But it is possible
> that such thread is marked as OOM-unkillable. In that case, the OOM
> killer must not select such process.

As already pointed out swapoff or ksm run_store are the only users of
OOM_FLAG_ORIGIN and it would be insane to run them from an oom disabled
context. So I wouldn't care much about this part that much and consider
the patch to be more of a cleanup rather than a bug fix.

> Since it is meaningless to return OOM_SCAN_OK for OOM-unkillable
> process because subsequent oom_badness() call will return 0, this
> patch changes oom_scan_process_thread to return OOM_SCAN_CONTINUE
> if that process is marked as OOM-unkillable (regardless of
> oom_task_origin()).
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Suggested-by: Michal Hocko <mhocko@kernel.org>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/oom_kill.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 7653055..cf87153 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -282,7 +282,7 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
>  		if (!is_sysrq_oom(oc))
>  			return OOM_SCAN_ABORT;
>  	}
> -	if (!task->mm)
> +	if (!task->mm || task->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
>  		return OOM_SCAN_CONTINUE;
>  
>  	/*
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
