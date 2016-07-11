Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id CD4DF6B0005
	for <linux-mm@kvack.org>; Mon, 11 Jul 2016 09:22:51 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id p41so16789412lfi.0
        for <linux-mm@kvack.org>; Mon, 11 Jul 2016 06:22:51 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d17si3999310wmh.142.2016.07.11.06.22.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 11 Jul 2016 06:22:50 -0700 (PDT)
Date: Mon, 11 Jul 2016 15:22:49 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 6/6] mm,oom: Stop clearing TIF_MEMDIE on remote thread.
Message-ID: <20160711132248.GI1811@dhcp22.suse.cz>
References: <201607080058.BFI87504.JtFOOFQFVHSLOM@I-love.SAKURA.ne.jp>
 <201607080107.ADG65168.QJLFFOFOHMOSVt@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201607080107.ADG65168.QJLFFOFOHMOSVt@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, oleg@redhat.com, rientjes@google.com, vdavydov@parallels.com, mst@redhat.com

On Fri 08-07-16 01:07:47, Tetsuo Handa wrote:
> >From fefcbf2412e38b006281cf1d20f9e3a2bb76714f Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Fri, 8 Jul 2016 00:42:48 +0900
> Subject: [PATCH 6/6] mm,oom: Stop clearing TIF_MEMDIE on remote thread.
> 
> Since oom_has_pending_mm() controls whether to select next OOM victim,
> we are no longer clearing TIF_MEMDIE on remote thread.

The changelog is quite cryptic. What about:
"
Since no kernel code path needs to clear TIF_MEMDIE flag on a remote
thread we can drop the task parameter and enforce that actually.
"
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

with the updated changelog
Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/oom.h | 2 +-
>  kernel/exit.c       | 2 +-
>  mm/oom_kill.c       | 5 ++---
>  3 files changed, 4 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/oom.h b/include/linux/oom.h
> index 27be4ba..90e98ea 100644
> --- a/include/linux/oom.h
> +++ b/include/linux/oom.h
> @@ -90,7 +90,7 @@ extern enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
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
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index b6b79ae..d120cb1 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -632,10 +632,9 @@ void mark_oom_victim(struct task_struct *tsk)
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
