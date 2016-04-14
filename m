Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 902E56B0005
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 10:01:57 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id s2so168739946iod.0
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 07:01:57 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 97si14226921otb.140.2016.04.14.07.01.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 14 Apr 2016 07:01:56 -0700 (PDT)
Subject: Re: [PATCH] mm,oom_reaper: Use try_oom_reaper() for reapability test.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1460631391-8628-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20160414112146.GD2850@dhcp22.suse.cz>
	<201604142034.BIF60426.FLFMVOHOJQStOF@I-love.SAKURA.ne.jp>
	<20160414120106.GF2850@dhcp22.suse.cz>
	<20160414123448.GG2850@dhcp22.suse.cz>
In-Reply-To: <20160414123448.GG2850@dhcp22.suse.cz>
Message-Id: <201604142301.BJG51570.LFSOOVFMHJQtOF@I-love.SAKURA.ne.jp>
Date: Thu, 14 Apr 2016 23:01:41 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, oleg@redhat.com, rientjes@google.com, linux-mm@kvack.org

Michal Hocko wrote:
> On Thu 14-04-16 20:34:18, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> [...]
> > > The patch seems correct I just do not see any point in it because I do
> > > not think it handles any real life situation. I basically consider any
> > > workload where only _certain_ thread(s) or process(es) sharing the mm have
> > > OOM_SCORE_ADJ_MIN set as invalid. Why should we care about those? This
> > > requires root to cripple the system. Or am I missing a valid
> > > configuration where this would make any sense?
> > 
> > Because __oom_reap_task() as of current linux.git marks only one of
> > thread groups as OOM_SCORE_ADJ_MIN and happily disables further reaping
> > (which I'm utilizing such behavior for catching bugs which occur under
> > almost OOM situation).
> 
> I am not really sure I understand what you mean here. Let me try. You
> have N tasks sharing the same mm. OOM killer selects one of them and
> kills it, grants TIF_MEMDIE and schedules it for oom_reaper. Now the oom
> reaper handles that task and marks it OOM_SCORE_ADJ_MIN. Others will
> have fatal_signal_pending without OOM_SCORE_ADJ_MIN. The shared mm was
> already reaped so there is not much left we can do about it. What now?

You finally understood what I mean here.

Say, there are TG1 and TG2 sharing the same mm which are marked as
OOM_SCORE_ADJ_MAX. First round of the OOM killer selects TG1 and sends
SIGKILL to TG1 and TG2. The OOM reaper reaps memory via TG1 and marks
TG1 as OOM_SCORE_ADJ_MIN and revokes TIF_MEMDIE from TG1. Then, next
round of the OOM killer selects TG2 and sends SIGKILL to TG1 and TG2.
But since TG1 is already marked as OOM_SCORE_ADJ_MIN by the OOM reaper,
the OOM reaper is not called.

This is a situation which the patch you show below will solve.

> 
> A different question is whether it makes any sense to pick a task with
> oom reaped mm as a new victim. This would happen if either the memory
> is not reapable much or the mm was quite small. I agree that we do not
> handle this case now same as we haven't before. An mm specific flag
> would handle that I believe. Something like the following. Is this what
> you are worried about or am I still missing your point?
> ---
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index acfc32b30704..7bd0fa9db199 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -512,6 +512,7 @@ static inline int get_dumpable(struct mm_struct *mm)
>  
>  #define MMF_HAS_UPROBES		19	/* has uprobes */
>  #define MMF_RECALC_UPROBES	20	/* MMF_HAS_UPROBES can be wrong */
> +#define MMF_OOM_REAPED		21	/* mm has been already reaped */
>  
>  #define MMF_INIT_MASK		(MMF_DUMPABLE_MASK | MMF_DUMP_FILTER_MASK)
>  
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 716759e3eaab..d5a4d08f2031 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -286,6 +286,13 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
>  		return OOM_SCAN_CONTINUE;
>  
>  	/*
> +	 * mm of this task has already been reaped so it doesn't make any
> +	 * sense to select it as a new oom victim.
> +	 */
> +	if (test_bit(MMF_OOM_REAPED, &task->mm->flags))

You checked for task->mm != NULL at previous line but nothing prevents
that task from setting task->mm = NULL before arriving at this line.

> +		return OOM_SCAN_CONTINUE;
> +
> +	/*
>  	 * If task is allocating a lot of memory and has been marked to be
>  	 * killed first if it triggers an oom, then select it.
>  	 */
> @@ -513,7 +520,7 @@ static bool __oom_reap_task(struct task_struct *tsk)
>  	 * This task can be safely ignored because we cannot do much more
>  	 * to release its memory.
>  	 */
> -	tsk->signal->oom_score_adj = OOM_SCORE_ADJ_MIN;
> +	test_bit(MMF_OOM_REAPED, &mm->flags);
>  out:
>  	mmput(mm);
>  	return ret;

Michal Hocko wrote:
> On Thu 14-04-16 14:01:06, Michal Hocko wrote:
> [...]
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index 716759e3eaab..d5a4d08f2031 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -286,6 +286,13 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
> >  		return OOM_SCAN_CONTINUE;
> >  
> >  	/*
> > +	 * mm of this task has already been reaped so it doesn't make any
> > +	 * sense to select it as a new oom victim.
> > +	 */
> > +	if (test_bit(MMF_OOM_REAPED, &task->mm->flags))
> > +		return OOM_SCAN_CONTINUE;
> 
> This will have to move to oom_badness to where we check for
> OOM_SCORE_ADJ_MIN to catch the case where we try to sacrifice a child...

oom_badness() should return 0 if MMF_OOM_REAPED is set (please be careful
with race task->mm becoming NULL). But oom_scan_process_thread() should not
return OOM_SCAN_ABORT if one of threads in TG1 or TG2 still has TIF_MEMDIE
(because it is possible that one of threads in TG1 or TG2 gets TIF_MEMDIE
via the fatal_signal_pending(current) shortcut in out_of_memory()).

> 
> In the meantime I have generated a full patch and will repost it with
> other oom reaper follow ups sometimes next week.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
