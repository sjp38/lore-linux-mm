Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id E069F6B02C3
	for <linux-mm@kvack.org>; Wed, 31 May 2017 12:39:32 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id x184so4063841wmf.14
        for <linux-mm@kvack.org>; Wed, 31 May 2017 09:39:32 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g97si13272116wrd.178.2017.05.31.09.39.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 31 May 2017 09:39:31 -0700 (PDT)
Date: Wed, 31 May 2017 18:39:29 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm,oom: add tracepoints for oom reaper-related events
Message-ID: <20170531163928.GZ27783@dhcp22.suse.cz>
References: <1496145932-18636-1-git-send-email-guro@fb.com>
 <20170530123415.GF7969@dhcp22.suse.cz>
 <20170530133335.GB28148@castle>
 <20170530134552.GI7969@dhcp22.suse.cz>
 <20170530185231.GA13412@castle>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170530185231.GA13412@castle>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, kernel-team@fb.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue 30-05-17 19:52:31, Roman Gushchin wrote:
> >From c57e3674efc609f8364f5e228a2c1309cfe99901 Mon Sep 17 00:00:00 2001
> From: Roman Gushchin <guro@fb.com>
> Date: Tue, 23 May 2017 17:37:55 +0100
> Subject: [PATCH v2] mm,oom: add tracepoints for oom reaper-related events
> 
> During the debugging of the problem described in
> https://lkml.org/lkml/2017/5/17/542 and fixed by Tetsuo Handa
> in https://lkml.org/lkml/2017/5/19/383 , I've found that
> the existing debug output is not really useful to understand
> issues related to the oom reaper.
> 
> So, I assume, that adding some tracepoints might help with
> debugging of similar issues.
> 
> Trace the following events:
> 1) a process is marked as an oom victim,
> 2) a process is added to the oom reaper list,
> 3) the oom reaper starts reaping process's mm,
> 4) the oom reaper finished reaping,
> 5) the oom reaper skips reaping.
> 
> How it works in practice? Below is an example which show
> how the problem mentioned above can be found: one process is added
> twice to the oom_reaper list:
> 
> $ cd /sys/kernel/debug/tracing
> $ echo "oom:mark_victim" > set_event
> $ echo "oom:wake_reaper" >> set_event
> $ echo "oom:skip_task_reaping" >> set_event
> $ echo "oom:start_task_reaping" >> set_event
> $ echo "oom:finish_task_reaping" >> set_event
> $ cat trace_pipe
>         allocate-502   [001] ....    91.836405: mark_victim: pid=502
>         allocate-502   [001] .N..    91.837356: wake_reaper: pid=502
>         allocate-502   [000] .N..    91.871149: wake_reaper: pid=502
>       oom_reaper-23    [000] ....    91.871177: start_task_reaping: pid=502
>       oom_reaper-23    [000] .N..    91.879511: finish_task_reaping: pid=502
>       oom_reaper-23    [000] ....    91.879580: skip_task_reaping: pid=502

OK, this is much better! The clue here would be that we got 2
wakeups for the same task, right?
Do you think it would make sense to put more context to those
tracepoints? E.g. skip_task_reaping can be due to lock contention or the
mm gone. wake_reaper is similar.

> Signed-off-by: Roman Gushchin <guro@fb.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: kernel-team@fb.com
> Cc: linux-kernel@vger.kernel.org
> Cc: linux-mm@kvack.org
> ---
>  include/trace/events/oom.h | 80 ++++++++++++++++++++++++++++++++++++++++++++++
>  mm/oom_kill.c              |  7 ++++
>  2 files changed, 87 insertions(+)
> 
> diff --git a/include/trace/events/oom.h b/include/trace/events/oom.h
> index 38baeb2..c3c19d4 100644
> --- a/include/trace/events/oom.h
> +++ b/include/trace/events/oom.h
> @@ -70,6 +70,86 @@ TRACE_EVENT(reclaim_retry_zone,
>  			__entry->wmark_check)
>  );
>  
> +TRACE_EVENT(mark_victim,
> +	TP_PROTO(int pid),
> +
> +	TP_ARGS(pid),
> +
> +	TP_STRUCT__entry(
> +		__field(int, pid)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->pid = pid;
> +	),
> +
> +	TP_printk("pid=%d", __entry->pid)
> +);
> +
> +TRACE_EVENT(wake_reaper,
> +	TP_PROTO(int pid),
> +
> +	TP_ARGS(pid),
> +
> +	TP_STRUCT__entry(
> +		__field(int, pid)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->pid = pid;
> +	),
> +
> +	TP_printk("pid=%d", __entry->pid)
> +);
> +
> +TRACE_EVENT(start_task_reaping,
> +	TP_PROTO(int pid),
> +
> +	TP_ARGS(pid),
> +
> +	TP_STRUCT__entry(
> +		__field(int, pid)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->pid = pid;
> +	),
> +
> +	TP_printk("pid=%d", __entry->pid)
> +);
> +
> +TRACE_EVENT(finish_task_reaping,
> +	TP_PROTO(int pid),
> +
> +	TP_ARGS(pid),
> +
> +	TP_STRUCT__entry(
> +		__field(int, pid)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->pid = pid;
> +	),
> +
> +	TP_printk("pid=%d", __entry->pid)
> +);
> +
> +TRACE_EVENT(skip_task_reaping,
> +	TP_PROTO(int pid),
> +
> +	TP_ARGS(pid),
> +
> +	TP_STRUCT__entry(
> +		__field(int, pid)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->pid = pid;
> +	),
> +
> +	TP_printk("pid=%d", __entry->pid)
> +);
> +
>  #ifdef CONFIG_COMPACTION
>  TRACE_EVENT(compact_retry,
>  
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 04c9143..409b685 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -490,6 +490,7 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
>  
>  	if (!down_read_trylock(&mm->mmap_sem)) {
>  		ret = false;
> +		trace_skip_task_reaping(tsk->pid);
>  		goto unlock_oom;
>  	}
>  
> @@ -500,9 +501,12 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
>  	 */
>  	if (!mmget_not_zero(mm)) {
>  		up_read(&mm->mmap_sem);
> +		trace_skip_task_reaping(tsk->pid);
>  		goto unlock_oom;
>  	}
>  
> +	trace_start_task_reaping(tsk->pid);
> +
>  	/*
>  	 * Tell all users of get_user/copy_from_user etc... that the content
>  	 * is no longer stable. No barriers really needed because unmapping
> @@ -544,6 +548,7 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
>  	 * put the oom_reaper out of the way.
>  	 */
>  	mmput_async(mm);
> +	trace_finish_task_reaping(tsk->pid);
>  unlock_oom:
>  	mutex_unlock(&oom_lock);
>  	return ret;
> @@ -615,6 +620,7 @@ static void wake_oom_reaper(struct task_struct *tsk)
>  	tsk->oom_reaper_list = oom_reaper_list;
>  	oom_reaper_list = tsk;
>  	spin_unlock(&oom_reaper_lock);
> +	trace_wake_reaper(tsk->pid);
>  	wake_up(&oom_reaper_wait);
>  }
>  
> @@ -666,6 +672,7 @@ static void mark_oom_victim(struct task_struct *tsk)
>  	 */
>  	__thaw_task(tsk);
>  	atomic_inc(&oom_victims);
> +	trace_mark_victim(tsk->pid);
>  }
>  
>  /**
> -- 
> 2.7.4

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
