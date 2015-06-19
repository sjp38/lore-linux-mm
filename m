Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 1B8F86B008A
	for <linux-mm@kvack.org>; Fri, 19 Jun 2015 11:36:25 -0400 (EDT)
Received: by wgbhy7 with SMTP id hy7so92798487wgb.2
        for <linux-mm@kvack.org>; Fri, 19 Jun 2015 08:36:24 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id el1si5226959wib.120.2015.06.19.08.36.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 19 Jun 2015 08:36:23 -0700 (PDT)
Date: Fri, 19 Jun 2015 17:36:21 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC -v2] panic_on_oom_timeout
Message-ID: <20150619153620.GI4913@dhcp22.suse.cz>
References: <20150617121104.GD25056@dhcp22.suse.cz>
 <201506172131.EFE12444.JMLFOSVOHFOtFQ@I-love.SAKURA.ne.jp>
 <20150617125127.GF25056@dhcp22.suse.cz>
 <201506172259.EAI00575.OFQtVFFSHMOLJO@I-love.SAKURA.ne.jp>
 <20150617154159.GJ25056@dhcp22.suse.cz>
 <201506192030.CAH00597.FQVOtFFLOJMHOS@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201506192030.CAH00597.FQVOtFFLOJMHOS@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On Fri 19-06-15 20:30:10, Tetsuo Handa wrote:
> Michal Hocko wrote:
[...]
> > Fixed in my local version. I will post the new version of the patch
> > after we settle with the approach.
> > 
> 
> I'd like to see now,

Sure see below

[...]
> But oom_victims is incremented via mark_oom_victim() for both global OOM
> and non-global OOM, isn't it? Then, I think that more difficult part is
> exit_oom_victim().

Yes you cannot tell which OOM context has killed a particular task. And
it even shouldn't matter, I believe - see below.

> We can hit a sequence like
> 
>   (1) Task1 in memcg1 hits memcg OOM.
>   (2) Task1 gets TIF_MEMDIE and increments oom_victims.
>   (3) Task2 hits global OOM.
>   (4) Task2 activates 10 seconds of timeout.
>   (5) Task2 gets TIF_MEMDIE and increments oom_victims.
>   (6) Task2 remained unkillable for 1 second since (5).
>   (7) Task2 calls exit_oom_victim().
>   (8) Task2 drops TIF_MEMDIE and decrements oom_victims.
>   (9) panic_on_oom_timer is not deactivated because oom_vctims > 0.
>   (10) Task1 remains unkillable for 10 seconds since (2).
>   (11) panic_on_oom_timer expires and the system will panic while
>        the system is no longer under global OOM.

I find this highly unlikely but yes this is possible. If it really
matters we can check watermarks on all zones and bail out if at least
one is OK from the timer handler.

[...]
>   (1) Task1 in memcg1 hits memcg OOM.
>   (2) Task1 gets TIF_MEMDIE and increments oom_victims.
>   (3) Task2 hits system OOM.
>   (4) Task2 activates 10 seconds of timeout.
>   (5) Task2 gets TIF_MEMDIE and increments oom_victims.
>   (6) Task1 remained unkillable for 9 seconds since (2).
>   (7) Task1 calls exit_oom_victim().
>   (8) Task1 drops TIF_MEMDIE and decrements oom_victims.
>   (9) panic_on_oom_timer is deactivated.
>   (10) Task3 hits system OOM.
>   (11) Task3 again activates 10 seconds of timeout.
>   (12) Task2 remains unkillable for 19 seconds since (5).
>   (13) panic_on_oom_timer expires and the system will panic, but
>        the expected timeout is 10 seconds while actual timeout is
>        19 seconds.
>
> if we deactivate panic_on_oom_timer like
> 
>  void exit_oom_victim(void)
>  {
>  	clear_thread_flag(TIF_MEMDIE);
>  
> +	del_timer(&panic_on_oom_timer);
> 	if (!atomic_dec_return(&oom_victims))
>  		wake_up_all(&oom_victims_wait);
>  }

Yes I was thinking about this as well because the primary assumption
of the OOM killer is that the victim will release some memory. And it
doesn't matter whether the OOM killer was constrained or the global
one. So the above looks good at first sight, I am just afraid it is too
relaxed for cases where many tasks are sharing mm.

> If we want to avoid premature or over-delayed timeout, I think we need to
> update timeout at exit_oom_victim() by doing something like
> 
>  void exit_oom_victim(void)
>  {
>  	clear_thread_flag(TIF_MEMDIE);
>  
> +	/*
> +	 * If current thread got TIF_MEMDIE due to global OOM, we need to
> +	 * update panic_on_oom_timer to "jiffies till the nearest timeout
> +	 * of all threads which got TIF_MEMDIE due to global OOM" and
> +	 * delete panic_on_oom_timer if "there is no more threads which
> +	 * got TIF_MEMDIE due to global OOM".
> +	 */
> +	if (/* Was I OOM-killed due to global OOM? */) {
> +		mutex_lock(&oom_lock); /* oom_lock needed for avoiding race. */
> +		if (/* Am I the last thread ? */) {
> +			del_timer(&panic_on_oom_timer);
> +		else
> +			mod_timer(&panic_on_oom_timer,
> +				  /* jiffies of the nearest timeout */);
> +		mutex_unlock(&oom_lock);
> +	}

I think you are missing an important point. The context which has caused
the killing is not important. As mentioned above even constrained OOM
killer will relief the global OOM condition as well.

The primary problem that we have is that we do not have any reliable
under_oom() check and we simply try to approximate it by heuristics
which work well enough in most cases. I admit that oom_victims is not
the ideal one and there might be better. As mentioned above we can check
watermarks on all zones and cancel the timer if at least one allows for
an allocation. But there are surely downsides of that approach as well
because the OOM killer could have been triggered for a higher order
allocation and we might be still under OOM for those requests.

There is no simple answer here I am afraid. So let's focus on being
reasonably good and simple rather than complex and still not perfect.

>  	if (!atomic_dec_return(&oom_victims))
>  		wake_up_all(&oom_victims_wait);
>  }
> 
> but we don't have hint for finding global OOM victims from all TIF_MEMDIE
> threads and when is the nearest timeout among all global OOM victims.

> We need to keep track of per global OOM victim's timeout (e.g. "struct
> task_struct"->memdie_start ) ?

I do not think this will help anything. It will just lead to a different
set of corner cases. E.g.

1) mark_oom_victim(T1) memdie_start = jiffies
2) fatal_signal_pending(T2) memdie_start = jiffies + delta
3) T2 releases memory - No OOM anymore
4) out_of_memory - check_memdie_timeout(T1) - KABOOM

[...]

> Well, do we really need to set TIF_MEMDIE to non-global OOM victims?

As already said non-global OOM victim will free some memory as well so
the global OOM killer shouldn't kill new tasks if there is a chance
that another victim will release a memory. TIF_MEMDIE acts as a lock.

> I'm wondering how {memcg,cpuset,mempolicy} OOM stall can occur because
> there is enough memory (unless global OOM runs concurrently) for any
> operations (e.g. XFS filesystem's writeback, workqueue) which non-global
> OOM victims might depend on to make forward progress.

Same like for the global case. The victim is uninterruptibly blocked on
a resource/lock/event.
 
[...]
> By the way, I think we can replace
> 
>   if (!atomic_dec_return(&oom_victims))
> 
> with
> 
>   if (atomic_dec_and_test(&oom_victims))
> 
> . But this logic puzzles me. The number of threads that are killed by
> the OOM killer can be larger than value of oom_victims. This means that
> there might be fatal_signal_pending() threads even after oom_victims drops
> to 0. Why waiting for only TIF_MEMDIE threads at oom_killer_disable() is
> considered sufficient?

Please have look at c32b3cbe0d06 ("oom, PM: make OOM detection in the
freezer path raceless") which imho explains it.

---
