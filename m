Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id B0EE46B0253
	for <linux-mm@kvack.org>; Mon, 30 May 2016 02:52:16 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id a136so24672832wme.1
        for <linux-mm@kvack.org>; Sun, 29 May 2016 23:52:16 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id uk6si21602185wjc.239.2016.05.29.23.52.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 29 May 2016 23:52:15 -0700 (PDT)
Date: Mon, 30 May 2016 08:52:13 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm,oom_reaper: don't call mmput_async() without
 atomic_inc_not_zero()
Message-ID: <20160530065213.GC22928@dhcp22.suse.cz>
References: <1464423365-5555-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1464423365-5555-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Arnd Bergmann <arnd@arndb.de>

On Sat 28-05-16 17:16:05, Tetsuo Handa wrote:
> Commit e2fe14564d3316d1 ("oom_reaper: close race with exiting task")
> reduced frequency of needlessly selecting next OOM victim, but was
> calling mmput_async() when atomic_inc_not_zero() failed.
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Arnd Bergmann <arnd@arndb.de>
> Cc: Andrew Morton <akpm@linux-foundation.org>

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

> ---
>  mm/oom_kill.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index dfb1ab6..0d781b8 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -478,6 +478,7 @@ static bool __oom_reap_task(struct task_struct *tsk)
>  	mm = p->mm;
>  	if (!atomic_inc_not_zero(&mm->mm_users)) {
>  		task_unlock(p);
> +		mm = NULL;
>  		goto unlock_oom;
>  	}
>  
> -- 
> 1.8.3.1
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
