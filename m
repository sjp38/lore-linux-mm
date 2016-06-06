Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id B43266B0005
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 17:13:42 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id di3so220524369pab.0
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 14:13:42 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id tv9si28673894pac.109.2016.06.06.14.13.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jun 2016 14:13:41 -0700 (PDT)
Date: Mon, 6 Jun 2016 14:13:40 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] oom_reaper: avoid pointless atomic_inc_not_zero usage.
Message-Id: <20160606141340.86c96c1d3dc29823438313d9@linux-foundation.org>
In-Reply-To: <1465024759-8074-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
References: <1465024759-8074-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Arnd Bergmann <arnd@arndb.de>

On Sat,  4 Jun 2016 16:19:19 +0900 Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> wrote:

> Since commit 36324a990cf578b5 ("oom: clear TIF_MEMDIE after oom_reaper
> managed to unmap the address space") changed to use find_lock_task_mm()
> for finding a mm_struct to reap, it is guaranteed that mm->mm_users > 0
> because find_lock_task_mm() returns a task_struct with ->mm != NULL.
> Therefore, we can safely use atomic_inc().
> 
> ...
>
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

In an off-list email (please don't do that!) you asked me to replace
mmoom_reaper-dont-call-mmput_async-without-atomic_inc_not_zero.patch
with this above patch.

But the
mmoom_reaper-dont-call-mmput_async-without-atomic_inc_not_zero.patch
changelog is pretty crappy:

: Commit e2fe14564d3316d1 ("oom_reaper: close race with exiting task")
: reduced frequency of needlessly selecting next OOM victim, but was
: calling mmput_async() when atomic_inc_not_zero() failed.

because it doesn't explain that the patch potentially fixes a kernel
crash.

And the changelog for this above patch is similarly crappy - it fails
to described the end-user visible effects of the bug which is being
fixed.  Please *always* do this.  Always always always.

Please send me a complete changelog for this patch, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
