Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 97D8E6B0253
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 10:06:08 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r190so19333744wmr.0
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 07:06:08 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t4si3417879wjk.56.2016.07.07.07.06.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 07 Jul 2016 07:06:07 -0700 (PDT)
Date: Thu, 7 Jul 2016 16:06:05 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 6/8] mm,oom_reaper: Stop clearing TIF_MEMDIE on remote
 thread.
Message-ID: <20160707140604.GN5379@dhcp22.suse.cz>
References: <201607031135.AAH95347.MVOHQtFJFLOOFS@I-love.SAKURA.ne.jp>
 <201607031140.BDG64095.VJFOOLHSFMFtOQ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201607031140.BDG64095.VJFOOLHSFMFtOQ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, oleg@redhat.com, rientjes@google.com, vdavydov@parallels.com, mst@redhat.com

On Sun 03-07-16 11:40:41, Tetsuo Handa wrote:
> >From 00b7a14653c9700429f89e4512f6000a39cce59d Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Sat, 2 Jul 2016 23:03:03 +0900
> Subject: [PATCH 6/8] mm,oom_reaper: Stop clearing TIF_MEMDIE on remote thread.
> 
> Since oom_has_pending_mm() controls whether to select next OOM victim,
> we no longer need to clear TIF_MEMDIE on remote thread. Therefore,
> revert related changes in commit 36324a990cf578b5 ("oom: clear TIF_MEMDIE
> after oom_reaper managed to unmap the address space") and
> commit e26796066fdf929c ("oom: make oom_reaper freezable") and
> commit 74070542099c66d8 ("oom, suspend: fix oom_reaper vs.
> oom_killer_disable race").

The last revert is not safe. See
http://lkml.kernel.org/r/1467365190-24640-3-git-send-email-mhocko@kernel.org

> This patch temporarily breaks what commit 36324a990cf578b5 ("oom: clear
> TIF_MEMDIE after oom_reaper managed to unmap the address space") and
> commit 449d777d7ad6d7f9 ("mm, oom_reaper: clear TIF_MEMDIE for all tasks
> queued for oom_reaper") try to solve due to oom_has_pending_mm().
> Future patch in this series will fix it.
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> ---
>  include/linux/oom.h    |  2 +-
>  kernel/exit.c          |  2 +-
>  kernel/power/process.c | 12 ------------
>  mm/oom_kill.c          | 15 ++-------------
>  4 files changed, 4 insertions(+), 27 deletions(-)
> 
> diff --git a/include/linux/oom.h b/include/linux/oom.h
> index 5991d41..4844325 100644
> --- a/include/linux/oom.h
> +++ b/include/linux/oom.h
> @@ -98,7 +98,7 @@ extern enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
>  
>  extern bool out_of_memory(struct oom_control *oc);
>  
> -extern void exit_oom_victim(struct task_struct *tsk);
> +extern void exit_oom_victim(void);
>  
>  extern int register_oom_notifier(struct notifier_block *nb);
>  extern int unregister_oom_notifier(struct notifier_block *nb);
> diff --git a/kernel/exit.c b/kernel/exit.c
> index 84ae830..1b1dada 100644
> --- a/kernel/exit.c
> +++ b/kernel/exit.c
> @@ -511,7 +511,7 @@ static void exit_mm(struct task_struct *tsk)
>  	mm_update_next_owner(mm);
>  	mmput(mm);
>  	if (test_thread_flag(TIF_MEMDIE))
> -		exit_oom_victim(tsk);
> +		exit_oom_victim();
>  }
>  
>  static struct task_struct *find_alive_thread(struct task_struct *p)
> diff --git a/kernel/power/process.c b/kernel/power/process.c
> index 0c2ee97..df058be 100644
> --- a/kernel/power/process.c
> +++ b/kernel/power/process.c
> @@ -146,18 +146,6 @@ int freeze_processes(void)
>  	if (!error && !oom_killer_disable())
>  		error = -EBUSY;
>  
> -	/*
> -	 * There is a hard to fix race between oom_reaper kernel thread
> -	 * and oom_killer_disable. oom_reaper calls exit_oom_victim
> -	 * before the victim reaches exit_mm so try to freeze all the tasks
> -	 * again and catch such a left over task.
> -	 */
> -	if (!error) {
> -		pr_info("Double checking all user space processes after OOM killer disable... ");
> -		error = try_to_freeze_tasks(true);
> -		pr_cont("\n");
> -	}
> -
>  	if (error)
>  		thaw_processes();
>  	return error;
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 55e0ffb..45e7de2 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -582,15 +582,7 @@ static void oom_reap_task(struct task_struct *tsk)
>  	debug_show_all_locks();
>  
>  done:
> -	/*
> -	 * Clear TIF_MEMDIE because the task shouldn't be sitting on a
> -	 * reasonably reclaimable memory anymore or it is not a good candidate
> -	 * for the oom victim right now because it cannot release its memory
> -	 * itself nor by the oom reaper.
> -	 */
>  	tsk->oom_reaper_list = NULL;
> -	exit_oom_victim(tsk);
> -
>  	/* Drop a reference taken by wake_oom_reaper */
>  	put_task_struct(tsk);
>  	/* Drop a reference taken above. */
> @@ -600,8 +592,6 @@ done:
>  
>  static int oom_reaper(void *unused)
>  {
> -	set_freezable();
> -
>  	while (true) {
>  		struct task_struct *tsk = NULL;
>  
> @@ -688,10 +678,9 @@ void mark_oom_victim(struct task_struct *tsk, struct oom_control *oc)
>  /**
>   * exit_oom_victim - note the exit of an OOM victim
>   */
> -void exit_oom_victim(struct task_struct *tsk)
> +void exit_oom_victim(void)
>  {
> -	if (!test_and_clear_tsk_thread_flag(tsk, TIF_MEMDIE))
> -		return;
> +	clear_thread_flag(TIF_MEMDIE);
>  
>  	if (!atomic_dec_return(&oom_victims))
>  		wake_up_all(&oom_victims_wait);
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
