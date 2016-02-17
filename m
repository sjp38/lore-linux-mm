Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 9EF636B0255
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 17:31:56 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id fy10so18540810pac.1
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 14:31:56 -0800 (PST)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id 133si4616870pfa.203.2016.02.17.14.31.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Feb 2016 14:31:55 -0800 (PST)
Received: by mail-pa0-x233.google.com with SMTP id fy10so18540662pac.1
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 14:31:55 -0800 (PST)
Date: Wed, 17 Feb 2016 14:31:54 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] mm,oom: exclude oom_task_origin processes if they
 are OOM-unkillable.
In-Reply-To: <1455719460-7690-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <alpine.DEB.2.10.1602171430500.15429@chino.kir.corp.google.com>
References: <1455719460-7690-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: mhocko@kernel.org, akpm@linux-foundation.org, mgorman@suse.de, oleg@redhat.com, torvalds@linux-foundation.org, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 17 Feb 2016, Tetsuo Handa wrote:

> oom_scan_process_thread() returns OOM_SCAN_SELECT when there is a
> thread which returns oom_task_origin() == true. But it is possible
> that such thread is marked as OOM-unkillable. In that case, the OOM
> killer must not select such process.
> 
> Since it is meaningless to return OOM_SCAN_OK for OOM-unkillable
> process because subsequent oom_badness() call will return 0, this
> patch changes oom_scan_process_thread to return OOM_SCAN_CONTINUE
> if that process is marked as OOM-unkillable (regardless of
> oom_task_origin()).
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Suggested-by: Michal Hocko <mhocko@kernel.org>
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

I'm getting multiple emails from you with the identical patch, something 
is definitely wacky in your toolchain.

Anyway, this is NACK'd since task->signal->oom_score_adj is checked under 
task_lock() for threads with memory attached, that's the purpose of 
finding the correct thread in oom_badness() and taking task_lock().  We 
aren't going to duplicate logic in several functions that all do the same 
thing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
