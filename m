Date: Wed, 12 Sep 2007 05:49:35 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 12 of 24] show mem information only when a task is
 actually being killed
Message-Id: <20070912054935.d0961e4a.akpm@linux-foundation.org>
In-Reply-To: <1473d573b9ba8a913baf.1187786939@v2.random>
References: <patchbomb.1187786927@v2.random>
	<1473d573b9ba8a913baf.1187786939@v2.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, 22 Aug 2007 14:48:59 +0200 Andrea Arcangeli <andrea@suse.de> wrote:

> # HG changeset patch
> # User Andrea Arcangeli <andrea@suse.de>
> # Date 1187778125 -7200
> # Node ID 1473d573b9ba8a913bafa42da2cac5dcca274204
> # Parent  adf88d0ba0d17beaceee47f7b8e0acbd97ddc320
> show mem information only when a task is actually being killed
> 
> Don't show garbage while VM_is_OOM and the timeout didn't trigger.
> 

whoa, now that's weird.

The diff you sent has:

 oom_kill.c |  184 ++++++++++++++++++++++++++++++-------------------------------
 1 file changed, 92 insertions(+), 92 deletions(-)

but when I apply it and rediff it, I get

 oom_kill.c |   29 +++++++++++++++--------------
 1 file changed, 15 insertions(+), 14 deletions(-)

which is below.  It's the same change, only the diff came out much better.

_does_ mercurial have its own diff?



> diff -puN mm/oom_kill.c~oom-handling-show-mem-information-only-when-a-task-is-actually-being-killed mm/oom_kill.c
> --- a/mm/oom_kill.c~oom-handling-show-mem-information-only-when-a-task-is-actually-being-killed
> +++ a/mm/oom_kill.c
> @@ -280,7 +280,7 @@ static void __oom_kill_task(struct task_
>  	force_sig(SIGKILL, p);
>  }
>  
> -static int oom_kill_task(struct task_struct *p)
> +static int oom_kill_task(struct task_struct *p, gfp_t gfp_mask, int order)
>  {
>  	struct mm_struct *mm;
>  	struct task_struct *g, *q;
> @@ -307,6 +307,14 @@ static int oom_kill_task(struct task_str
>  			return 1;
>  	} while_each_thread(g, q);
>  
> +	if (printk_ratelimit()) {
> +		printk(KERN_WARNING "%s invoked oom-killer: "
> +			"gfp_mask=0x%x, order=%d, oomkilladj=%d\n",
> +			current->comm, gfp_mask, order, current->oomkilladj);
> +		dump_stack();
> +		show_mem();
> +	}
> +
>  	__oom_kill_task(p, 1);
>  
>  	/*
> @@ -323,7 +331,7 @@ static int oom_kill_task(struct task_str
>  }
>  
>  static int oom_kill_process(struct task_struct *p, unsigned long points,
> -		const char *message)
> +			    const char *message, gfp_t gfp_mask, int order)
>  {
>  	struct task_struct *c;
>  	struct list_head *tsk;
> @@ -351,10 +359,10 @@ static int oom_kill_process(struct task_
>  		 */
>  		if (unlikely(test_tsk_thread_flag(c, TIF_MEMDIE)))
>  			continue;
> -		if (!oom_kill_task(c))
> +		if (!oom_kill_task(c, gfp_mask, order))
>  			return 0;
>  	}
> -	return oom_kill_task(p);
> +	return oom_kill_task(p, gfp_mask, order);
>  }
>  
>  static BLOCKING_NOTIFIER_HEAD(oom_notify_list);
> @@ -394,13 +402,6 @@ void out_of_memory(struct zonelist *zone
>  
>  	if (down_trylock(&OOM_lock))
>  		return;
> -	if (printk_ratelimit()) {
> -		printk(KERN_WARNING "%s invoked oom-killer: "
> -			"gfp_mask=0x%x, order=%d, oomkilladj=%d\n",
> -			current->comm, gfp_mask, order, current->oomkilladj);
> -		dump_stack();
> -		show_mem();
> -	}
>  
>  	if (sysctl_panic_on_oom == 2)
>  		panic("out of memory. Compulsory panic_on_oom is selected.\n");
> @@ -428,12 +429,12 @@ void out_of_memory(struct zonelist *zone
>  	switch (constraint) {
>  	case CONSTRAINT_MEMORY_POLICY:
>  		oom_kill_process(current, points,
> -				"No available memory (MPOL_BIND)");
> +				 "No available memory (MPOL_BIND)", gfp_mask, order);
>  		break;
>  
>  	case CONSTRAINT_CPUSET:
>  		oom_kill_process(current, points,
> -				"No available memory in cpuset");
> +				 "No available memory in cpuset", gfp_mask, order);
>  		break;
>  
>  	case CONSTRAINT_NONE:
> @@ -452,7 +453,7 @@ retry:
>  			panic("Out of memory and no killable processes...\n");
>  		}
>  
> -		if (oom_kill_process(p, points, "Out of memory"))
> +		if (oom_kill_process(p, points, "Out of memory", gfp_mask, order))
>  			goto retry;
>  
>  		break;

I don't really understand this change.  A better changelog which more fully
describes the problem whcih is being addressed would help, please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
