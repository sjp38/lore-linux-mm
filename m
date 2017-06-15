Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6F63C6B0343
	for <linux-mm@kvack.org>; Thu, 15 Jun 2017 06:39:13 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id n7so2660688wrb.0
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 03:39:13 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j1si184729wmd.124.2017.06.15.03.39.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 15 Jun 2017 03:39:11 -0700 (PDT)
Date: Thu, 15 Jun 2017 12:39:09 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch] mm, oom: prevent additional oom kills before memory is
 freed
Message-ID: <20170615103909.GG1486@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1706141632100.93071@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1706141632100.93071@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 14-06-17 16:43:03, David Rientjes wrote:
> If mm->mm_users is not incremented because it is already zero by the oom
> reaper, meaning the final refcount has been dropped, do not set
> MMF_OOM_SKIP prematurely.
> 
> __mmput() may not have had a chance to do exit_mmap() yet, so memory from
> a previous oom victim is still mapped.

true and do we have a _guarantee_ it will do it? E.g. can somebody block
exit_aio from completing? Or can somebody hold mmap_sem and thus block
ksm_exit resp. khugepaged_exit from completing? The reason why I was
conservative and set such a mm as MMF_OOM_SKIP was because I couldn't
give a definitive answer to those questions. And we really _want_ to
have a guarantee of a forward progress here. Killing an additional
proecess is a price to pay and if that doesn't trigger normall it sounds
like a reasonable compromise to me.

> __mput() naturally requires no
> references on mm->mm_users to do exit_mmap().
> 
> Without this, several processes can be oom killed unnecessarily and the
> oom log can show an abundance of memory available if exit_mmap() is in
> progress at the time the process is skipped.

Have you seen this happening in the real life?

> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  mm/oom_kill.c | 13 ++++++-------
>  1 file changed, 6 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -531,6 +531,7 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
>  					 NULL);
>  	}
>  	tlb_finish_mmu(&tlb, 0, -1);
> +	set_bit(MMF_OOM_SKIP, &mm->flags);
>  	pr_info("oom_reaper: reaped process %d (%s), now anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
>  			task_pid_nr(tsk), tsk->comm,
>  			K(get_mm_counter(mm, MM_ANONPAGES)),
> @@ -562,7 +563,11 @@ static void oom_reap_task(struct task_struct *tsk)
>  	if (attempts <= MAX_OOM_REAP_RETRIES)
>  		goto done;
>  
> -
> +	/*
> +	 * Hide this mm from OOM killer because it cannot be reaped since
> +	 * mm->mmap_sem cannot be acquired.
> +	 */
> +	set_bit(MMF_OOM_SKIP, &mm->flags);
>  	pr_info("oom_reaper: unable to reap pid:%d (%s)\n",
>  		task_pid_nr(tsk), tsk->comm);
>  	debug_show_all_locks();
> @@ -570,12 +575,6 @@ static void oom_reap_task(struct task_struct *tsk)
>  done:
>  	tsk->oom_reaper_list = NULL;
>  
> -	/*
> -	 * Hide this mm from OOM killer because it has been either reaped or
> -	 * somebody can't call up_write(mmap_sem).
> -	 */
> -	set_bit(MMF_OOM_SKIP, &mm->flags);
> -
>  	/* Drop a reference taken by wake_oom_reaper */
>  	put_task_struct(tsk);
>  }

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
