Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9F8778E00FB
	for <linux-mm@kvack.org>; Sun, 27 Jan 2019 11:58:35 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id t2so12120400pfj.15
        for <linux-mm@kvack.org>; Sun, 27 Jan 2019 08:58:35 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y5si29696720pgk.49.2019.01.27.08.58.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 Jan 2019 08:58:34 -0800 (PST)
Date: Sun, 27 Jan 2019 17:58:28 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3] oom, oom_reaper: do not enqueue same task twice
Message-ID: <20190127165828.GC18811@dhcp22.suse.cz>
References: <6da6ca69-5a6e-a9f6-d091-f89a8488982a@gmail.com>
 <72aa8863-a534-b8df-6b9e-f69cf4dd5c4d@i-love.sakura.ne.jp>
 <33a07810-6dbc-36be-5bb6-a279773ccf69@i-love.sakura.ne.jp>
 <34e97b46-0792-cc66-e0f2-d72576cdec59@i-love.sakura.ne.jp>
 <2b0c7d6c-c58a-da7d-6f0a-4900694ec2d3@gmail.com>
 <1d161137-55a5-126f-b47e-b2625bd798ca@i-love.sakura.ne.jp>
 <20190127083724.GA18811@dhcp22.suse.cz>
 <ec0d0580-a2dd-f329-9707-0cb91205a216@i-love.sakura.ne.jp>
 <20190127114021.GB18811@dhcp22.suse.cz>
 <e865a044-2c10-9858-f4ef-254bc71d6cc2@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <e865a044-2c10-9858-f4ef-254bc71d6cc2@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Arkadiusz =?utf-8?Q?Mi=C5=9Bkiewicz?= <a.miskiewicz@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, Aleksa Sarai <asarai@suse.de>, Jay Kamat <jgkamat@fb.com>, Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm <linux-mm@kvack.org>

On Sun 27-01-19 23:57:38, Tetsuo Handa wrote:
[...]
> >From 9c9e935fc038342c48461aabca666f1b544e32b1 Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Sun, 27 Jan 2019 23:51:37 +0900
> Subject: [PATCH v3] oom, oom_reaper: do not enqueue same task twice
> 
> Arkadiusz reported that enabling memcg's group oom killing causes
> strange memcg statistics where there is no task in a memcg despite
> the number of tasks in that memcg is not 0. It turned out that there
> is a bug in wake_oom_reaper() which allows enqueuing same task twice
> which makes impossible to decrease the number of tasks in that memcg
> due to a refcount leak.
> 
> This bug existed since the OOM reaper became invokable from
> task_will_free_mem(current) path in out_of_memory() in Linux 4.7,
> but memcg's group oom killing made it easier to trigger this bug by
> calling wake_oom_reaper() on the same task from one out_of_memory()
> request.
> 
> Fix this bug using an approach used by commit 855b018325737f76
> ("oom, oom_reaper: disable oom_reaper for oom_kill_allocating_task").
> As a side effect of this patch, this patch also avoids enqueuing
> multiple threads sharing memory via task_will_free_mem(current) path.
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Reported-by: Arkadiusz Miśkiewicz <arekm@maven.pl>
> Tested-by: Arkadiusz Miśkiewicz <arekm@maven.pl>
> Fixes: af8e15cc85a25315 ("oom, oom_reaper: do not enqueue task if it is on the oom_reaper_list head")

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/sched/coredump.h | 1 +
>  mm/oom_kill.c                  | 4 ++--
>  2 files changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/sched/coredump.h b/include/linux/sched/coredump.h
> index ec912d0..ecdc654 100644
> --- a/include/linux/sched/coredump.h
> +++ b/include/linux/sched/coredump.h
> @@ -71,6 +71,7 @@ static inline int get_dumpable(struct mm_struct *mm)
>  #define MMF_HUGE_ZERO_PAGE	23      /* mm has ever used the global huge zero page */
>  #define MMF_DISABLE_THP		24	/* disable THP for all VMAs */
>  #define MMF_OOM_VICTIM		25	/* mm is the oom victim */
> +#define MMF_OOM_REAP_QUEUED	26	/* mm was queued for oom_reaper */
>  #define MMF_DISABLE_THP_MASK	(1 << MMF_DISABLE_THP)
>  
>  #define MMF_INIT_MASK		(MMF_DUMPABLE_MASK | MMF_DUMP_FILTER_MASK |\
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index f0e8cd9..059e617 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -647,8 +647,8 @@ static int oom_reaper(void *unused)
>  
>  static void wake_oom_reaper(struct task_struct *tsk)
>  {
> -	/* tsk is already queued? */
> -	if (tsk == oom_reaper_list || tsk->oom_reaper_list)
> +	/* mm is already queued? */
> +	if (test_and_set_bit(MMF_OOM_REAP_QUEUED, &tsk->signal->oom_mm->flags))
>  		return;
>  
>  	get_task_struct(tsk);
> -- 
> 1.8.3.1

-- 
Michal Hocko
SUSE Labs
