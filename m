Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 39CE66B0003
	for <linux-mm@kvack.org>; Mon, 21 Dec 2015 03:38:17 -0500 (EST)
Received: by mail-wm0-f48.google.com with SMTP id l126so58950147wml.0
        for <linux-mm@kvack.org>; Mon, 21 Dec 2015 00:38:17 -0800 (PST)
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com. [74.125.82.44])
        by mx.google.com with ESMTPS id g139si34414179wmd.85.2015.12.21.00.38.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Dec 2015 00:38:16 -0800 (PST)
Received: by mail-wm0-f44.google.com with SMTP id p187so58986603wmp.0
        for <linux-mm@kvack.org>; Mon, 21 Dec 2015 00:38:16 -0800 (PST)
Date: Mon, 21 Dec 2015 09:38:14 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm, oom: introduce oom reaper
Message-ID: <20151221083812.GB11089@dhcp22.suse.cz>
References: <1450204575-13052-1-git-send-email-mhocko@kernel.org>
 <20151216165035.38a4d9b84600d6348a3cf4bf@linux-foundation.org>
 <20151217130223.GE18625@dhcp22.suse.cz>
 <CA+55aFxkzeqtxDY8KyR_FA+WKNkQXEHVA_zO8XhW6rqRr778Zw@mail.gmail.com>
 <20151217120004.b5f849e1613a3a367482b379@linux-foundation.org>
 <20151218115454.GE28443@dhcp22.suse.cz>
 <20151218131400.751bc4d582a947c9833c09eb@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151218131400.751bc4d582a947c9833c09eb@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, Andrea Argangeli <andrea@kernel.org>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri 18-12-15 13:14:00, Andrew Morton wrote:
> On Fri, 18 Dec 2015 12:54:55 +0100 Michal Hocko <mhocko@kernel.org> wrote:
> 
> >  	/* Retry the down_read_trylock(mmap_sem) a few times */
> > -	while (attempts++ < 10 && !__oom_reap_vmas(mm))
> > -		msleep_interruptible(100);
> > +	while (attempts++ < 10 && !__oom_reap_vmas(mm)) {
> > +		__set_task_state(current, TASK_IDLE);
> > +		schedule_timeout(HZ/10);
> > +	}
> 
> If you won't, I shall ;)
> 
> 
> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: sched: add schedule_timeout_idle()
> 
> This will be needed in the patch "mm, oom: introduce oom reaper".
> 
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Ingo Molnar <mingo@elte.hu>
> Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Thanks! This makes more sense.

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
> 
>  include/linux/sched.h |    1 +
>  kernel/time/timer.c   |   11 +++++++++++
>  2 files changed, 12 insertions(+)
> 
> diff -puN kernel/time/timer.c~sched-add-schedule_timeout_idle kernel/time/timer.c
> --- a/kernel/time/timer.c~sched-add-schedule_timeout_idle
> +++ a/kernel/time/timer.c
> @@ -1566,6 +1566,17 @@ signed long __sched schedule_timeout_uni
>  }
>  EXPORT_SYMBOL(schedule_timeout_uninterruptible);
>  
> +/*
> + * Like schedule_timeout_uninterruptible(), except this task will not contribute
> + * to load average.
> + */
> +signed long __sched schedule_timeout_idle(signed long timeout)
> +{
> +	__set_current_state(TASK_IDLE);
> +	return schedule_timeout(timeout);
> +}
> +EXPORT_SYMBOL(schedule_timeout_idle);
> +
>  #ifdef CONFIG_HOTPLUG_CPU
>  static void migrate_timer_list(struct tvec_base *new_base, struct hlist_head *head)
>  {
> diff -puN include/linux/sched.h~sched-add-schedule_timeout_idle include/linux/sched.h
> --- a/include/linux/sched.h~sched-add-schedule_timeout_idle
> +++ a/include/linux/sched.h
> @@ -423,6 +423,7 @@ extern signed long schedule_timeout(sign
>  extern signed long schedule_timeout_interruptible(signed long timeout);
>  extern signed long schedule_timeout_killable(signed long timeout);
>  extern signed long schedule_timeout_uninterruptible(signed long timeout);
> +extern signed long schedule_timeout_idle(signed long timeout);
>  asmlinkage void schedule(void);
>  extern void schedule_preempt_disabled(void);
>  
> _

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
