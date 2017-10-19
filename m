Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 926046B0253
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 07:44:29 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id r202so3367196wmd.17
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 04:44:29 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i18si7499248wrh.332.2017.10.19.04.44.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Oct 2017 04:44:27 -0700 (PDT)
Date: Thu, 19 Oct 2017 13:44:24 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,page_alloc: Serialize out_of_memory() and allocation
 stall messages.
Message-ID: <20171019114424.4db2hohyyogpjq5f@dhcp22.suse.cz>
References: <1508410262-4797-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1508410262-4797-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Cong Wang <xiyou.wangcong@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, "yuwang.yuwang" <yuwang.yuwang@alibaba-inc.com>

On Thu 19-10-17 19:51:02, Tetsuo Handa wrote:
> The printk() flooding problem caused by concurrent warn_alloc() calls was
> already pointed out by me, and there are reports of soft lockups caused by
> warn_alloc(). But this problem is left unhandled because Michal does not
> like serialization from allocation path because he is worrying about
> unexpected side effects and is asking to identify the root cause of soft
> lockups and fix it. But at least consuming CPU resource by not serializing
> concurrent printk() plays some role in the soft lockups, for currently
> printk() can consume CPU resource forever as long as somebody is appending
> to printk() buffer, and writing to consoles also needs CPU resource. That
> is, needlessly consuming CPU resource when calling printk() has unexpected
> side effects.
> 
> Although a proposal for offloading writing to consoles to a dedicated
> kernel thread is in progress, it is not yet accepted. And, even after
> the proposal is accepted, writing to printk() buffer faster than the
> kernel thread can write to consoles will result in loss of messages.
> We should refrain from "appending to printk() buffer" and "consuming CPU
> resource" at the same time if possible. We should try to (and we can)
> avoid appending to printk() buffer when printk() is concurrently called
> for reporting the OOM killer and allocation stalls, in order to reduce
> possibility of hitting soft lockups and getting unreadably-jumbled
> messages.
> 
> Although avoid mixing both memory allocation stall/failure messages and
> the OOM killer messages would be nice, oom_lock mutex should not be used
> for this purpose, for waiting for oom_lock mutex at warn_alloc() can
> prevent anybody from calling out_of_memory() from __alloc_pages_may_oom()
> because currently __alloc_pages_may_oom() does not wait for oom_lock
> (i.e. causes OOM lockups after all). Therefore, this patch adds a mutex
> named "oom_printk_lock". Although using mutex_lock() in order to allow
> printk() to use CPU resource for writing to consoles is better from the
> point of view of flushing printk(), this patch uses mutex_trylock() for
> allocation stall messages because Michal does not like serialization.

Hell no! I've tried to be patient with you but it seems that is just
pointless waste of time. Such an approach is absolutely not acceptable.
You are adding an additional lock dependency into the picture. Say that
there is somebody stuck in warn_alloc path and cannot make a further
progress because printk got stuck. Now you are blocking oom_kill_process
as well. So the cure might be even worse than the problem.

If the warn_alloc is really causing issues and you do not want to spend
energy into identifying _what_ is the actual problem then I would rather
remove the stall warning than add a fishy code.

> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Reported-by: Cong Wang <xiyou.wangcong@gmail.com>
> Reported-by: yuwang.yuwang <yuwang.yuwang@alibaba-inc.com>
> Reported-by: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> Cc: Petr Mladek <pmladek@suse.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> ---
>  include/linux/oom.h | 1 +
>  mm/oom_kill.c       | 5 +++++
>  mm/page_alloc.c     | 4 +++-
>  3 files changed, 9 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/oom.h b/include/linux/oom.h
> index 76aac4c..1425767 100644
> --- a/include/linux/oom.h
> +++ b/include/linux/oom.h
> @@ -44,6 +44,7 @@ struct oom_control {
>  };
>  
>  extern struct mutex oom_lock;
> +extern struct mutex oom_printk_lock;
>  
>  static inline void set_current_oom_origin(void)
>  {
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 26add8a..5aef9a6 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -54,6 +54,7 @@
>  int sysctl_oom_dump_tasks = 1;
>  
>  DEFINE_MUTEX(oom_lock);
> +DEFINE_MUTEX(oom_printk_lock);
>  
>  #ifdef CONFIG_NUMA
>  /**
> @@ -1074,7 +1075,9 @@ bool out_of_memory(struct oom_control *oc)
>  	    current->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
>  		get_task_struct(current);
>  		oc->chosen = current;
> +		mutex_lock(&oom_printk_lock);
>  		oom_kill_process(oc, "Out of memory (oom_kill_allocating_task)");
> +		mutex_unlock(&oom_printk_lock);
>  		return true;
>  	}
>  
> @@ -1085,8 +1088,10 @@ bool out_of_memory(struct oom_control *oc)
>  		panic("Out of memory and no killable processes...\n");
>  	}
>  	if (oc->chosen && oc->chosen != (void *)-1UL) {
> +		mutex_lock(&oom_printk_lock);
>  		oom_kill_process(oc, !is_memcg_oom(oc) ? "Out of memory" :
>  				 "Memory cgroup out of memory");
> +		mutex_unlock(&oom_printk_lock);
>  		/*
>  		 * Give the killed process a good chance to exit before trying
>  		 * to allocate memory again.
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 97687b3..3766687 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3990,11 +3990,13 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
>  		goto nopage;
>  
>  	/* Make sure we know about allocations which stall for too long */
> -	if (time_after(jiffies, alloc_start + stall_timeout)) {
> +	if (time_after(jiffies, alloc_start + stall_timeout) &&
> +	    mutex_trylock(&oom_printk_lock)) {
>  		warn_alloc(gfp_mask & ~__GFP_NOWARN, ac->nodemask,
>  			"page allocation stalls for %ums, order:%u",
>  			jiffies_to_msecs(jiffies-alloc_start), order);
>  		stall_timeout += 10 * HZ;
> +		mutex_unlock(&oom_printk_lock);
>  	}
>  
>  	/* Avoid recursion of direct reclaim */
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
