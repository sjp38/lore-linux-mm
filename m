Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id AE1E06B007E
	for <linux-mm@kvack.org>; Tue, 24 May 2016 07:46:15 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id o70so7956863lfg.1
        for <linux-mm@kvack.org>; Tue, 24 May 2016 04:46:15 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id w15si23022756wmw.102.2016.05.24.04.46.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 May 2016 04:46:14 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id 67so5279220wmg.0
        for <linux-mm@kvack.org>; Tue, 24 May 2016 04:46:14 -0700 (PDT)
Date: Tue, 24 May 2016 13:46:12 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: oom: do not reap task if there are live threads in
 threadgroup
Message-ID: <20160524114612.GG8259@dhcp22.suse.cz>
References: <1464087628-7318-1-git-send-email-vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1464087628-7318-1-git-send-email-vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 24-05-16 14:00:28, Vladimir Davydov wrote:
> If the current process is exiting, we don't invoke oom killer, instead
> we give it access to memory reserves and try to reap its mm in case
> nobody is going to use it. There's a mistake in the code performing this
> check - we just ignore any process of the same thread group no matter if
> it is exiting or not - see try_oom_reaper. Fix it.

This is not a problem with the current code because of 98748bd72200
("oom: consider multi-threaded tasks in task_will_free_mem") which got
merged later on, however.

The check is not needed so we can indeed drop it.

Fixes: 3ef22dfff239 ("oom, oom_reaper: try to reap tasks which skip
regular OOM killer path")

Just in case somebody wants to backport only 3ef22dfff239.

> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

> ---
>  mm/oom_kill.c | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index c0e37dd1422f..03bf7a472296 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -618,8 +618,6 @@ void try_oom_reaper(struct task_struct *tsk)
>  
>  			if (!process_shares_mm(p, mm))
>  				continue;
> -			if (same_thread_group(p, tsk))
> -				continue;
>  			if (fatal_signal_pending(p))
>  				continue;
>  
> -- 
> 2.1.4

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
