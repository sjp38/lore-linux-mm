Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id 6B1616B0005
	for <linux-mm@kvack.org>; Sat,  5 Mar 2016 09:37:30 -0500 (EST)
Received: by mail-ig0-f178.google.com with SMTP id ir4so19792604igb.1
        for <linux-mm@kvack.org>; Sat, 05 Mar 2016 06:37:30 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id j10si4180589igx.27.2016.03.05.06.37.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 05 Mar 2016 06:37:29 -0800 (PST)
Subject: Re: [PATCH] mm,oom: Do not sleep with oom_lock held.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201603031941.CBC81272.OtLMSFVOFJHOFQ@I-love.SAKURA.ne.jp>
	<20160304160519.GG31257@dhcp22.suse.cz>
In-Reply-To: <20160304160519.GG31257@dhcp22.suse.cz>
Message-Id: <201603052337.EHH60964.VLJMHFQSFOOtFO@I-love.SAKURA.ne.jp>
Date: Sat, 5 Mar 2016 23:37:14 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: rientjes@google.com, hannes@cmpxchg.org, linux-mm@kvack.org

Michal Hocko wrote:
> On Thu 03-03-16 19:42:00, Tetsuo Handa wrote:
> > Michal, before we think about whether to add preempt_disable()/preempt_enable_no_resched()
> > to oom_kill_process(), will you accept this patch?
> > This is one of problems which annoy kmallocwd patch on CONFIG_PREEMPT_NONE=y kernels.
> 
> I dunno. It makes the code worse and it doesn't solve the underlying
> problem (have a look at OOM notifiers which are blockable). Also
> !PREEMPT only solution doesn't sound very useful as most of the
> configurations will have PREEMPT enabled. I agree that having the OOM
> killer preemptible is far from ideal, though, but this is harder than
> just this sleep. Long term we should focus on making the oom context
> not preemptible.
> 

I think we are holding oom_lock inappropriately.

  /**
   * mark_oom_victim - mark the given task as OOM victim
   * @tsk: task to mark
   *
   * Has to be called with oom_lock held and never after
   * oom has been disabled already.

This assumption is not true when lowmemorykiller is used.

   */
  void mark_oom_victim(struct task_struct *tsk)
  {
  	WARN_ON(oom_killer_disabled);
  	/* OOM killer might race with memcg OOM */
  	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE))
  		return;

Since both global OOM and memcg OOM hold oom_lock, global OOM and memcg
OOM cannot race. Global OOM and memcg OOM can race with lowmemorykiller.

If we use per memcg oom_lock, we would be able to reduce latency when
concurrent memcg OOMs are in progress.

I'm wondering why freezing_slow_path() allows TIF_MEMDIE threads to escape from
the __refrigerator(). If the purpose of escaping is to release memory, waiting
for existing TIF_MEMDIE threads is not sufficient if an mm is shared by multiple
threads. We need to let all threads sharing that mm to escape when we choose an
OOM victim. If we can assume that freezer depends on CONFIG_MMU=y, we can reclaim
memory using the OOM reaper without setting TIF_MEMDIE. That will get rid of
oom_killer_disable() and related exclusion code based on oom_lock.

If we allow dying (SIGKILL pending or PF_EXITING) threads to access some of
memory reserves, lowmemorykiller will be able to stop using TIF_MEMDIE. And
above assumption becomes always true. Also, since memcg OOMs are less urgent
than global OOM, memcg OOMs might be able to stop using TIF_MEMDIE as well.

Then, only global OOM will use global oom_lock and TIF_MEMDIE. That is, we
can offload handling of global OOM to a kernel thread which can run on any
CPU with preemption disabled. The oom_lock will become unneeded because only
one kernel thread will use it. If we add timestamp field to task_struct or
signal_struct for recording when SIGKILL was delivered, we can emit warnings
when victims cannot terminate.

I think we are in chicken-and-egg riddle about oom_lock and TIF_MEMDIE.

> Anyway, wouldn't this be simpler?

Yes, I'm OK with your version.

> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 5d5eca9d6737..c84e7841007e 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -901,15 +901,9 @@ bool out_of_memory(struct oom_control *oc)
>  		dump_header(oc, NULL, NULL);
>  		panic("Out of memory and no killable processes...\n");
>  	}
> -	if (p && p != (void *)-1UL) {
> +	if (p && p != (void *)-1UL)
>  		oom_kill_process(oc, p, points, totalpages, NULL,
>  				 "Out of memory");
> -		/*
> -		 * Give the killed process a good chance to exit before trying
> -		 * to allocate memory again.
> -		 */
> -		schedule_timeout_killable(1);
> -	}
>  	return true;
>  }
>  
> @@ -944,4 +938,10 @@ void pagefault_out_of_memory(void)
>  	}
>  
>  	mutex_unlock(&oom_lock);
> +
> +	/*
> +	 * Give the killed process a good chance to exit before trying
> +	 * to allocate memory again.
> +	 */
> +	schedule_timeout_killable(1);

Oh, I forgot this. Sleeping not only when setting TIF_MEMDIE but also
waiting for existing TIF_MEMDIE to be cleared will save CPU cycles.

>  }
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 1993894b4219..496498c4c32c 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2888,6 +2881,13 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
>  	}
>  out:
>  	mutex_unlock(&oom_lock);
> +	if (*did_some_progress) {

I think this line should be

	if (*did_some_progress && !page)

because oom_killer_disabled && __GFP_NOFAIL likely makes page != NULL

> +		/*
> +		 * Give the killed process a good chance to exit before trying
> +		 * to allocate memory again.
> +		 */
> +		schedule_timeout_killable(1);
> +	}

and this closing } is not needed.

Sleeping when out_of_memory() was not called due to !__GFP_NOFAIL && !__GFP_FS
will help somebody else to make a progress for us? (My version did not change it.)

 | - GFP_NOFS is another one which would be good to discuss. Its primary
 |   use is to prevent from reclaim recursion back into FS. This makes
 |   such an allocation context weaker and historically we haven't
 |   triggered OOM killer and rather hopelessly retry the request and
 |   rely on somebody else to make a progress for us. There are two issues
 |   here.

>  	return page;
>  }
>  
> -- 
> Michal Hocko
> SUSE Labs
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
