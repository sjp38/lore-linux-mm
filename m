Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id E19C66B0005
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 10:36:48 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id o80so15022813wme.1
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 07:36:48 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a64si6243482wmc.86.2016.07.12.07.36.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 12 Jul 2016 07:36:47 -0700 (PDT)
Date: Tue, 12 Jul 2016 16:36:46 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 4/8] mm,oom: Close oom_has_pending_mm race.
Message-ID: <20160712143646.GO14586@dhcp22.suse.cz>
References: <1468330163-4405-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <1468330163-4405-5-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1468330163-4405-5-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, oleg@redhat.com, rientjes@google.com, vdavydov@parallels.com, mst@redhat.com

On Tue 12-07-16 22:29:19, Tetsuo Handa wrote:
> Previous patch ignored a situation where oom_has_pending_mm() returns
> false due to all threads which mm->oom_mm.victim belongs to have reached
> TASK_DEAD state, for there might be other thread groups sharing that mm.
> 
> This patch handles such situation by always updating mm->oom_mm.victim.
> By applying this patch, the comm/pid pair printed at oom_kill_process()
> and oom_reap_task() might differ. But that will not be a critical
> problem.

I am not really sure this is worth it and that the approach actually
works reliable. The given tsk might drop or might have dropped already
its memcg association or mempolicy by the time we replace the original
one which still holds relevant data. So you are replacing one corner
case by another. It is hard to tell which one is more likely.

This patch is not really needed for correctness so I would rather wait
for reports than over engineer at this stage.

> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> ---
>  mm/oom_kill.c | 22 +++++++++++++++++-----
>  1 file changed, 17 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 07e8c1a..0b78133 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -688,6 +688,7 @@ subsys_initcall(oom_init)
>  void mark_oom_victim(struct task_struct *tsk)
>  {
>  	struct mm_struct *mm = tsk->mm;
> +	struct task_struct *old_tsk;
>  
>  	WARN_ON(oom_killer_disabled);
>  	/* OOM killer might race with memcg OOM */
> @@ -705,15 +706,26 @@ void mark_oom_victim(struct task_struct *tsk)
>  	/*
>  	 * Since mark_oom_victim() is called from multiple threads,
>  	 * connect this mm to oom_mm_list only if not yet connected.
> +	 *
> +	 * But task_in_oom_domain(mm->oom_mm.victim, memcg, nodemask) in
> +	 * oom_has_pending_mm() might return false after all threads in one
> +	 * thread group (which mm->oom_mm.victim belongs to) reached TASK_DEAD
> +	 * state. In that case, the same mm will be selected by another thread
> +	 * group (which mm->oom_mm.victim does not belongs to). Therefore,
> +	 * we need to replace the old task with the new task (at least when
> +	 * task_in_oom_domain() returned false).
>  	 */
> -	if (!mm->oom_mm.victim) {
> +	get_task_struct(tsk);
> +	spin_lock(&oom_mm_lock);
> +	old_tsk = mm->oom_mm.victim;
> +	mm->oom_mm.victim = tsk;
> +	if (!old_tsk) {
>  		atomic_inc(&mm->mm_count);
> -		get_task_struct(tsk);
> -		mm->oom_mm.victim = tsk;
> -		spin_lock(&oom_mm_lock);
>  		list_add_tail(&mm->oom_mm.list, &oom_mm_list);
> -		spin_unlock(&oom_mm_lock);
>  	}
> +	spin_unlock(&oom_mm_lock);
> +	if (old_tsk)
> +		put_task_struct(old_tsk);
>  }
>  
>  /**
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
