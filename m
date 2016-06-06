Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 214966B0005
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 03:18:43 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id k192so1903684lfb.1
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 00:18:43 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id df5si24955294wjb.165.2016.06.06.00.18.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 06 Jun 2016 00:18:41 -0700 (PDT)
Date: Mon, 6 Jun 2016 09:18:39 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] oom_reaper: avoid pointless atomic_inc_not_zero usage.
Message-ID: <20160606071839.GB11895@dhcp22.suse.cz>
References: <1465024759-8074-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1465024759-8074-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Arnd Bergmann <arnd@arndb.de>

On Sat 04-06-16 16:19:19, Tetsuo Handa wrote:
> Since commit 36324a990cf578b5 ("oom: clear TIF_MEMDIE after oom_reaper
> managed to unmap the address space") changed to use find_lock_task_mm()
> for finding a mm_struct to reap, it is guaranteed that mm->mm_users > 0
> because find_lock_task_mm() returns a task_struct with ->mm != NULL.
> Therefore, we can safely use atomic_inc().
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Arnd Bergmann <arnd@arndb.de>
> Cc: Andrew Morton <akpm@linux-foundation.org>

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

> ---
>  mm/oom_kill.c | 7 +------
>  1 file changed, 1 insertion(+), 6 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index dfb1ab6..8050fa0 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -474,13 +474,8 @@ static bool __oom_reap_task(struct task_struct *tsk)
>  	p = find_lock_task_mm(tsk);
>  	if (!p)
>  		goto unlock_oom;
> -
>  	mm = p->mm;
> -	if (!atomic_inc_not_zero(&mm->mm_users)) {
> -		task_unlock(p);
> -		goto unlock_oom;
> -	}
> -
> +	atomic_inc(&mm->mm_users);
>  	task_unlock(p);
>  
>  	if (!down_read_trylock(&mm->mmap_sem)) {
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
