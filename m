Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2CCE98E0018
	for <linux-mm@kvack.org>; Mon, 10 Dec 2018 09:13:40 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id f17so4228272edm.20
        for <linux-mm@kvack.org>; Mon, 10 Dec 2018 06:13:40 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l1si1048628edn.1.2018.12.10.06.13.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Dec 2018 06:13:38 -0800 (PST)
Date: Mon, 10 Dec 2018 15:13:37 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/4] kernel.h: Add non_block_start/end()
Message-ID: <20181210141337.GQ1286@dhcp22.suse.cz>
References: <20181210103641.31259-1-daniel.vetter@ffwll.ch>
 <20181210103641.31259-3-daniel.vetter@ffwll.ch>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20181210103641.31259-3-daniel.vetter@ffwll.ch>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Vetter <daniel.vetter@ffwll.ch>
Cc: Intel Graphics Development <intel-gfx@lists.freedesktop.org>, DRI Development <dri-devel@lists.freedesktop.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Daniel Vetter <daniel.vetter@intel.com>, Peter Zijlstra <peterz@infradead.org>

I do not see any scheduler guys Cced and it would be really great to get
their opinion here.

On Mon 10-12-18 11:36:39, Daniel Vetter wrote:
> In some special cases we must not block, but there's not a
> spinlock, preempt-off, irqs-off or similar critical section already
> that arms the might_sleep() debug checks. Add a non_block_start/end()
> pair to annotate these.
> 
> This will be used in the oom paths of mmu-notifiers, where blocking is
> not allowed to make sure there's forward progress.

Considering the only alternative would be to abuse
preempt_{disable,enable}, and that really has a different semantic, I
think this makes some sense. The cotext is preemptible but we do not
want notifier to sleep on any locks, WQ etc.

> Suggested by Michal Hocko.
> 
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: "Christian K�nig" <christian.koenig@amd.com>
> Cc: Daniel Vetter <daniel.vetter@ffwll.ch>
> Cc: "J�r�me Glisse" <jglisse@redhat.com>
> Cc: linux-mm@kvack.org
> Signed-off-by: Daniel Vetter <daniel.vetter@intel.com>
> ---
>  include/linux/kernel.h | 10 +++++++++-
>  include/linux/sched.h  |  4 ++++
>  kernel/sched/core.c    |  6 +++---
>  3 files changed, 16 insertions(+), 4 deletions(-)
> 
> diff --git a/include/linux/kernel.h b/include/linux/kernel.h
> index d6aac75b51ba..c2cf31515b3d 100644
> --- a/include/linux/kernel.h
> +++ b/include/linux/kernel.h
> @@ -251,7 +251,9 @@ extern int _cond_resched(void);
>   * might_sleep - annotation for functions that can sleep
>   *
>   * this macro will print a stack trace if it is executed in an atomic
> - * context (spinlock, irq-handler, ...).
> + * context (spinlock, irq-handler, ...). Additional sections where blocking is
> + * not allowed can be annotated with non_block_start() and non_block_end()
> + * pairs.
>   *
>   * This is a useful debugging help to be able to catch problems early and not
>   * be bitten later when the calling function happens to sleep when it is not
> @@ -260,6 +262,10 @@ extern int _cond_resched(void);
>  # define might_sleep() \
>  	do { __might_sleep(__FILE__, __LINE__, 0); might_resched(); } while (0)
>  # define sched_annotate_sleep()	(current->task_state_change = 0)
> +# define non_block_start() \
> +	do { current->non_block_count++; } while (0)
> +# define non_block_end() \
> +	do { WARN_ON(current->non_block_count-- == 0); } while (0)
>  #else
>    static inline void ___might_sleep(const char *file, int line,
>  				   int preempt_offset) { }
> @@ -267,6 +273,8 @@ extern int _cond_resched(void);
>  				   int preempt_offset) { }
>  # define might_sleep() do { might_resched(); } while (0)
>  # define sched_annotate_sleep() do { } while (0)
> +# define non_block_start() do { } while (0)
> +# define non_block_end() do { } while (0)
>  #endif
>  
>  #define might_sleep_if(cond) do { if (cond) might_sleep(); } while (0)
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index ecffd4e37453..41249dbf8f27 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -916,6 +916,10 @@ struct task_struct {
>  	struct mutex_waiter		*blocked_on;
>  #endif
>  
> +#ifdef CONFIG_DEBUG_ATOMIC_SLEEP
> +	int				non_block_count;
> +#endif
> +
>  #ifdef CONFIG_TRACE_IRQFLAGS
>  	unsigned int			irq_events;
>  	unsigned long			hardirq_enable_ip;
> diff --git a/kernel/sched/core.c b/kernel/sched/core.c
> index 6fedf3a98581..969d7a71f30c 100644
> --- a/kernel/sched/core.c
> +++ b/kernel/sched/core.c
> @@ -6113,7 +6113,7 @@ void ___might_sleep(const char *file, int line, int preempt_offset)
>  	rcu_sleep_check();
>  
>  	if ((preempt_count_equals(preempt_offset) && !irqs_disabled() &&
> -	     !is_idle_task(current)) ||
> +	     !is_idle_task(current) && !current->non_block_count) ||
>  	    system_state == SYSTEM_BOOTING || system_state > SYSTEM_RUNNING ||
>  	    oops_in_progress)
>  		return;
> @@ -6129,8 +6129,8 @@ void ___might_sleep(const char *file, int line, int preempt_offset)
>  		"BUG: sleeping function called from invalid context at %s:%d\n",
>  			file, line);
>  	printk(KERN_ERR
> -		"in_atomic(): %d, irqs_disabled(): %d, pid: %d, name: %s\n",
> -			in_atomic(), irqs_disabled(),
> +		"in_atomic(): %d, irqs_disabled(): %d, non_block: %d, pid: %d, name: %s\n",
> +			in_atomic(), irqs_disabled(), current->non_block_count,
>  			current->pid, current->comm);
>  
>  	if (task_stack_end_corrupted(current))
> -- 
> 2.20.0.rc1
> 

-- 
Michal Hocko
SUSE Labs
