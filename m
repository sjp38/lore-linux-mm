Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 338626B0005
	for <linux-mm@kvack.org>; Mon, 11 Jul 2016 09:16:21 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id o80so25764823wme.1
        for <linux-mm@kvack.org>; Mon, 11 Jul 2016 06:16:21 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 203si910227wmh.93.2016.07.11.06.16.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 11 Jul 2016 06:16:20 -0700 (PDT)
Date: Mon, 11 Jul 2016 15:16:18 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 4/6] mm,oom_reaper: Make OOM reaper use list of mm_struct.
Message-ID: <20160711131618.GG1811@dhcp22.suse.cz>
References: <201607080058.BFI87504.JtFOOFQFVHSLOM@I-love.SAKURA.ne.jp>
 <201607080104.JDA41505.OtOFMSLOQVJFHF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201607080104.JDA41505.OtOFMSLOQVJFHF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, oleg@redhat.com, rientjes@google.com, vdavydov@parallels.com, mst@redhat.com

On Fri 08-07-16 01:04:46, Tetsuo Handa wrote:
> >From acc85fdd36452e39bace6aa73b3aaa41bbe776a5 Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Fri, 8 Jul 2016 00:39:36 +0900
> Subject: [PATCH 4/6] mm,oom_reaper: Make OOM reaper use list of mm_struct.
> 
> Since OOM reaping is per mm_struct operation, it is natural to use
> list of mm_struct used by OOM victims. By using list of mm_struct,
> we can eliminate find_lock_task_mm() usage from the OOM reaper.

Again, the changelog doesn't state why getting rid of find_lock_task_mm
is useful.

You are also dropping exit_oom_victim from the oom reaper without any
explanation in the changelog.

> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

I haven't spotted anything obviously wrong with the patch. Conceptually
this sounds like a right approach. It is a bit sad we have to keep the
oom victim around as well but I guess this is acceptable.

That being said, I think that going mm queuing way is better than
keeping mm alive in signal_struct long term.

> ---
>  include/linux/oom.h |   8 -----
>  mm/memcontrol.c     |   1 -
>  mm/oom_kill.c       | 100 +++++++++++++++-------------------------------------
>  3 files changed, 29 insertions(+), 80 deletions(-)

The code reduction is really nice! Few notes below

[...]

>  #define MAX_OOM_REAP_RETRIES 10
> -static void oom_reap_task(struct task_struct *tsk)
> +static void oom_reap_task(struct task_struct *tsk, struct mm_struct *mm)
>  {
>  	int attempts = 0;
> -	struct mm_struct *mm = NULL;
> -	struct task_struct *p = find_lock_task_mm(tsk);
>  
>  	/*
> -	 * Make sure we find the associated mm_struct even when the particular
> -	 * thread has already terminated and cleared its mm.
> -	 * We might have race with exit path so consider our work done if there
> -	 * is no mm.
> +	 * Check MMF_OOM_REAPED in case oom_kill_process() found this mm
> +	 * pinned.
>  	 */
> -	if (!p)
> -		goto done;
> -	mm = p->mm;
> -	atomic_inc(&mm->mm_count);
> -	task_unlock(p);
> +	if (test_bit(MMF_OOM_REAPED, &mm->flags))
> +		return;
>  
>  	/* Retry the down_read_trylock(mmap_sem) a few times */
>  	while (attempts++ < MAX_OOM_REAP_RETRIES && !__oom_reap_task(tsk, mm))
>  		schedule_timeout_idle(HZ/10);
>  
>  	if (attempts <= MAX_OOM_REAP_RETRIES)
> -		goto done;
> +		return;
>  
>  	/* Ignore this mm because somebody can't call up_write(mmap_sem). */
>  	set_bit(MMF_OOM_REAPED, &mm->flags);

This seems unnecessary when oom_reaper always calls exit_oom_mm. The
same applies to __oom_reap_task. Which then means that the flag is
turning into a misnomer. MMF_SKIP_OOM would fit better its current
meaning.

[...]

> @@ -600,41 +572,31 @@ static int oom_reaper(void *unused)
>  	set_freezable();
>  
>  	while (true) {
> -		struct task_struct *tsk = NULL;
> -
> -		wait_event_freezable(oom_reaper_wait, oom_reaper_list != NULL);
> -		spin_lock(&oom_reaper_lock);
> -		if (oom_reaper_list != NULL) {
> -			tsk = oom_reaper_list;
> -			oom_reaper_list = tsk->oom_reaper_list;
> -		}
> -		spin_unlock(&oom_reaper_lock);
> -
> -		if (tsk)
> -			oom_reap_task(tsk);
> +		struct mm_struct *mm;
> +		struct task_struct *victim;
> +
> +		wait_event_freezable(oom_reaper_wait,
> +				     !list_empty(&oom_mm_list));
> +		mutex_lock(&oom_lock);
> +		mm = list_first_entry(&oom_mm_list, struct mm_struct,
> +				      oom_mm.list);
> +		victim = mm->oom_mm.victim;
> +		/*
> +		 * Take a reference on current victim thread in case
> +		 * oom_reap_task() raced with mark_oom_victim() by
> +		 * other threads sharing this mm.
> +		 */
> +		get_task_struct(victim);

If you didn't play old_task games in mark_oom_victim then you wouldn't
need this AFAIU.

> +		mutex_unlock(&oom_lock);
> +		oom_reap_task(victim, mm);
> +		put_task_struct(victim);
> +		/* Drop references taken by mark_oom_victim() */
> +		exit_oom_mm(mm);

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
