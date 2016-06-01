Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0E3F86B0260
	for <linux-mm@kvack.org>; Wed,  1 Jun 2016 18:53:15 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id di3so23671241pab.0
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 15:53:15 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id o72si53766878pfj.148.2016.06.01.15.53.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Jun 2016 15:53:14 -0700 (PDT)
Date: Wed, 1 Jun 2016 15:53:13 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm,oom_reaper: don't call mmput_async() without
 atomic_inc_not_zero()
Message-Id: <20160601155313.dc3aa18eb6ad0e163d44b355@linux-foundation.org>
In-Reply-To: <1464423365-5555-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
References: <1464423365-5555-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Arnd Bergmann <arnd@arndb.de>

On Sat, 28 May 2016 17:16:05 +0900 Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> wrote:

> Commit e2fe14564d3316d1 ("oom_reaper: close race with exiting task")
> reduced frequency of needlessly selecting next OOM victim, but was
> calling mmput_async() when atomic_inc_not_zero() failed.

Changelog fail.

> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -478,6 +478,7 @@ static bool __oom_reap_task(struct task_struct *tsk)
>  	mm = p->mm;
>  	if (!atomic_inc_not_zero(&mm->mm_users)) {
>  		task_unlock(p);
> +		mm = NULL;
>  		goto unlock_oom;
>  	}

This looks like a pretty fatal bug.  I assume the result of hitting
that race will be a kernel crash, yes?

Is it even possible to hit that race?  find_lock_task_mm() takes some
care to prevent a NULL ->mm.  But I guess a concurrent mmput() doesn't
require task_lock().  Kinda makes me wonder what's the point in even
having find_lock_task_mm() if its guarantee on ->mm is useless...


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
