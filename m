Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9C9DD6B025E
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 07:14:44 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id i4so14489724wmg.2
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 04:14:44 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id il2si2464330wjb.258.2016.07.07.04.14.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 07 Jul 2016 04:14:43 -0700 (PDT)
Date: Thu, 7 Jul 2016 13:14:41 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/8] mm,oom_reaper: Remove pointless kthread_run()
 failure check.
Message-ID: <20160707111440.GG5379@dhcp22.suse.cz>
References: <201607031135.AAH95347.MVOHQtFJFLOOFS@I-love.SAKURA.ne.jp>
 <201607031136.GGI52642.OMLFFOHQtFVJOS@I-love.SAKURA.ne.jp>
 <20160703124246.GA23902@redhat.com>
 <201607040103.DEB48914.HQFFJFOOOVtSLM@I-love.SAKURA.ne.jp>
 <20160703171022.GA31065@redhat.com>
 <201607040653.DJB81254.FFOOSHFOQMtJLV@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201607040653.DJB81254.FFOOSHFOQMtJLV@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: oleg@redhat.com, linux-mm@kvack.org, akpm@linux-foundation.org, rientjes@google.com, vdavydov@parallels.com, mst@redhat.com

On Mon 04-07-16 06:53:49, Tetsuo Handa wrote:
[...]
> >From 977b0f4368a7ca07af7e519aa8795e7b2ee653d0 Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Mon, 4 Jul 2016 06:40:05 +0900
> Subject: [PATCH 1/8] mm,oom_reaper: Don't boot without OOM reaper kernel thread.
> 
> We are trying to prove that OOM livelock is impossible for CONFIG_MMU=y
> kernels (as long as OOM killer is invoked) because the OOM reaper always
> gives feedback to the OOM killer. Therefore, preserving code which
> continues without OOM reaper no longer makes sense.
> 
> Since oom_init() is called before OOM-killable userspace processes are
> started, the system will panic if out_of_memory() is called before
> oom_init() returns. Therefore, oom_reaper_th == NULL check in
> wake_oom_reaper() is pointless.
> 
> If kthread_run() in oom_init() fails due to reasons other than
> out_of_memory(), userspace processes won't be able to start as well.
> Therefore, trying to continue with error message is also pointless.
> But in case something unexpected occurred, let's explicitly add
> BUG_ON() check.

I have said that earlier already. The oom_reaper is not crucial for the
standard system operation. Panicing on this failure seems like an over
reaction. It is true that the system might panic just right after for
other reasons but that is not the reason to panic here.

> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

I am not going to ack nor nak this patch because it will have no
practical effect.

> ---
>  mm/oom_kill.c | 13 +++----------
>  1 file changed, 3 insertions(+), 10 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 7d0a275..079ce96 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -447,7 +447,6 @@ bool process_shares_mm(struct task_struct *p, struct mm_struct *mm)
>   * OOM Reaper kernel thread which tries to reap the memory used by the OOM
>   * victim (if that is possible) to help the OOM killer to move on.
>   */
> -static struct task_struct *oom_reaper_th;
>  static DECLARE_WAIT_QUEUE_HEAD(oom_reaper_wait);
>  static struct task_struct *oom_reaper_list;
>  static DEFINE_SPINLOCK(oom_reaper_lock);
> @@ -629,9 +628,6 @@ static int oom_reaper(void *unused)
>  
>  void wake_oom_reaper(struct task_struct *tsk)
>  {
> -	if (!oom_reaper_th)
> -		return;
> -
>  	/* tsk is already queued? */
>  	if (tsk == oom_reaper_list || tsk->oom_reaper_list)
>  		return;
> @@ -647,12 +643,9 @@ void wake_oom_reaper(struct task_struct *tsk)
>  
>  static int __init oom_init(void)
>  {
> -	oom_reaper_th = kthread_run(oom_reaper, NULL, "oom_reaper");
> -	if (IS_ERR(oom_reaper_th)) {
> -		pr_err("Unable to start OOM reaper %ld. Continuing regardless\n",
> -				PTR_ERR(oom_reaper_th));
> -		oom_reaper_th = NULL;
> -	}
> +	struct task_struct *p = kthread_run(oom_reaper, NULL, "oom_reaper");
> +
> +	BUG_ON(IS_ERR(p));
>  	return 0;
>  }
>  subsys_initcall(oom_init)
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
