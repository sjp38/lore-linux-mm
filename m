Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id EBDBB6B007E
	for <linux-mm@kvack.org>; Fri, 27 May 2016 04:11:01 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id h68so13308732lfh.2
        for <linux-mm@kvack.org>; Fri, 27 May 2016 01:11:01 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id t5si10651475wmg.3.2016.05.27.01.11.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 May 2016 01:11:00 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id e3so12432913wme.2
        for <linux-mm@kvack.org>; Fri, 27 May 2016 01:11:00 -0700 (PDT)
Date: Fri, 27 May 2016 10:10:59 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] oom_reaper: don't call mmput_async() on uninitialized mm
Message-ID: <20160527081059.GE27686@dhcp22.suse.cz>
References: <1464336081-994232-1-git-send-email-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1464336081-994232-1-git-send-email-arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Johannes Weiner <hannes@cmpxchg.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 27-05-16 10:00:48, Arnd Bergmann wrote:
> The change to the oom_reaper to hold a mutex inside __oom_reap_task()
> accidentally started calling mmput_async() on the local
> mm before that variable got initialized, as reported by gcc
> in linux-next:
> 
> mm/oom_kill.c: In function '__oom_reap_task':
> mm/oom_kill.c:537:2: error: 'mm' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> 
> This rearranges the code slightly back to the state before patch
> but leaves the lock in place. The error handling in the function
> still looks a bit confusing and could probably be improved
> but I could not come up with a solution that made me happy
> for now.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: mmotm ("oom_reaper: close race with exiting task")

Thanks for catching that Arnd?

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/oom_kill.c | 12 ++++++++----
>  1 file changed, 8 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 1685890d424e..255cb5f48019 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -447,7 +447,7 @@ static bool __oom_reap_task(struct task_struct *tsk)
>  	struct task_struct *p;
>  	struct zap_details details = {.check_swap_entries = true,
>  				      .ignore_dirty = true};
> -	bool ret = true;
> +	bool ret;
>  
>  	/*
>  	 * We have to make sure to not race with the victim exit path
> @@ -472,13 +472,16 @@ static bool __oom_reap_task(struct task_struct *tsk)
>  	 * is no mm.
>  	 */
>  	p = find_lock_task_mm(tsk);
> -	if (!p)
> -		goto unlock_oom;
> +	if (!p) {
> +		mutex_unlock(&oom_lock);
> +		return true;
> +	}
>  
>  	mm = p->mm;
>  	if (!atomic_inc_not_zero(&mm->mm_users)) {
>  		task_unlock(p);
> -		goto unlock_oom;
> +		mutex_unlock(&oom_lock);
> +		return true;
>  	}
>  
>  	task_unlock(p);
> @@ -527,6 +530,7 @@ static bool __oom_reap_task(struct task_struct *tsk)
>  	 * to release its memory.
>  	 */
>  	set_bit(MMF_OOM_REAPED, &mm->flags);
> +	ret = true;
>  unlock_oom:
>  	mutex_unlock(&oom_lock);
>  	/*
> -- 
> 2.7.0
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
